require 'openssl'  # for decryption
require 'zlib'     # for decompression
require 'base64'   # for decoding
require 'rubygems' if defined?RUBY_VERSION && RUBY_VERSION =~ /^1.8/ # for requiring gem dependency in Ruby 1.8
require 'nokogiri' # for xml parsing

require 'strongboxio/version'

class Strongboxio

	STRONGBOX_VERSION = 3
	VERSION_LENGTH = 1
	SALT_LENGTH = 64
	IV_LENGTH = 16
	KEY_LENGTH = 32
	RANDOM_VALUE_LENGTH = 64
	CIPHER = 'AES-256-CBC'
	PAYLOAD_SCHEMA_VERSION = '2.4'
	UNIX_EPOCH_IN_100NS_INTERVALS = 621355968000000000 # .NET time format: number of 100-nanosecond intervals since .NET epoch: January 1, 0001 at 00:00:00.000 (midnight)

	def self.decrypt(sbox_filename, password)
		# open the xml file
		f = File.open(sbox_filename)
		data = Nokogiri::XML(f)
		f.close

		# extract the Data node
		data = data.xpath('//Data').text
		base64_error_msg = 'expected Base64 encoded byte string from the StrongBox.Payload.Data element of the xml of a Strongbox file'
		raise "#{base64_error_msg}, but got nothing" if data.length == 0
		raise "#{base64_error_msg}, but it does not resemble Base64" unless self.resembles_base64?(data)

		data = Base64.decode64(data)

		#version = data.getbyte(0)   # ruby 1.9
		version = data.bytes.to_a[0] # ruby 1.8 friendly
		raise "expected version number #{STRONGBOX_VERSION}, but got #{version}" unless version == STRONGBOX_VERSION

		salt = data.slice(1, SALT_LENGTH)
		raise "expected salt length #{SALT_LENGTH}, but got #{salt.length}" unless salt.length == SALT_LENGTH

		iv = data.bytes.to_a.slice((1+64), IV_LENGTH).pack('C*')
		raise "expected iv length #{IV_LENGTH}, but got #{iv.length}" unless iv.length == IV_LENGTH

		key = Digest::SHA256.digest(salt + password)
		raise "expected key length #{KEY_LENGTH}, but got #{key.length}" unless key.length == KEY_LENGTH

		# prepare for decryption
		d = OpenSSL::Cipher.new(CIPHER)
		d.decrypt
		d.key = key
		d.iv	= iv

		# decrypt the portion beyond the header
		begin
			data = '' << d.update(data.slice((VERSION_LENGTH+SALT_LENGTH+IV_LENGTH)..-1)) << d.final
		rescue => e
			raise "Error decrypting. You probably entered the password incorrectly. Specific error: #{e}"
		end

		# decompress the portion beyond the random value
		#z = Zlib::Inflate.new
		#z = Zlib::Inflate.new(-Zlib::BEST_COMPRESSION) # works for Strongbox
		z = Zlib::Inflate.new(-Zlib::MAX_WBITS) # works for Strongbox!
		#z = Zlib::Inflate.new(Zlib::MAX_WBITS) # works for roundtrip
		data = z.inflate(data.slice(RANDOM_VALUE_LENGTH..-1))
		z.finish
		z.close

		data
	end

	def self.render(decrypted_sbox, continue_despite_unexpected_payload_schema_version=false)
		data = Nokogiri::XML(decrypted_sbox)

		payload_schema_version = data.xpath('//Payload').xpath('SchemaVersion').text
		unless payload_schema_version == PAYLOAD_SCHEMA_VERSION
			raise "expected schema version #{PAYLOAD_SCHEMA_VERSION}, but got #{payload_schema_version}" unless continue_despite_unexpected_payload_schema_version
		end

		mt = data.xpath('//Payload').xpath('PayloadInfo').xpath('MT').text
		puts mt

		data.xpath('//PayloadData').each { |payload_data|
			payload_data.xpath('//SBE').each { |entity|
				puts
				name = entity.xpath('N').text
				puts "#{name}" if name.length > 0
				description = entity.xpath('D').text
				puts "#{description}" if description.length > 0
				tags = entity.xpath('T').text
				puts "#{tags}" if tags.length > 0
				ce = entity.xpath('CE')
				ce.xpath('TFE').each { |tfe|
					name = tfe.xpath('N').text
					puts "#{name}:" if name.length > 0
					content = tfe.xpath('C').text
					puts "#{content}" if content.length > 0
				}
			}
		}
	end

	def assemble(decrypted_sbox, continue_despite_unexpected_payload_schema_version=false)
		data = Nokogiri::XML(decrypted_sbox)

		payload_schema_version = data.xpath('//Payload').xpath('SchemaVersion').text
		unless payload_schema_version == PAYLOAD_SCHEMA_VERSION
			raise "expected schema version #{PAYLOAD_SCHEMA_VERSION}, but got #{payload_schema_version}" unless continue_despite_unexpected_payload_schema_version
		end

		sbox = {}

		mt = data.xpath('//Payload').xpath('PayloadInfo').xpath('MT').text
		sbox['MT'] = mt

		data.xpath('//PayloadData').each { |payload_data|

			sbox['PayloadData'] = []

			payload_data.xpath('//SBE').each_with_index { |strongbox_entity, sbe_index|

				sbox['PayloadData'][sbe_index] = {}

				sbe_mt = strongbox_entity.attr('MT') # ModifiedTimestamp.Ticks
				sbox['PayloadData'][sbe_index]['MT'] = sbe_mt if sbe_mt.length > 0

				sbe_ct = strongbox_entity.attr('CT') # CreatedTimestamp.Ticks
				sbox['PayloadData'][sbe_index]['CT'] = sbe_ct if sbe_ct.length > 0

				sbe_ac = strongbox_entity.attr('AC') # accessCount
				sbox['PayloadData'][sbe_index]['AC'] = sbe_ac if sbe_ac.length > 0

				sbe_name = strongbox_entity.xpath('N').text
				sbox['PayloadData'][sbe_index]['N'] = sbe_name if sbe_name.length > 0

				sbe_description = strongbox_entity.xpath('D').text
				sbox['PayloadData'][sbe_index]['D'] = sbe_description if sbe_description.length > 0

				sbe_tags = strongbox_entity.xpath('T').text
				sbox['PayloadData'][sbe_index]['T'] = sbe_tags if sbe_tags.length > 0

				child_entity = strongbox_entity.xpath('CE')
				if child_entity.length > 0
					sbox['PayloadData'][sbe_index]['CE'] = []

					child_entity.xpath('TFE').each_with_index { |text_field_entity, ce_index|

						sbox['PayloadData'][sbe_index]['CE'][ce_index] = {}

						tfe_name = text_field_entity.xpath('N').text
						sbox['PayloadData'][sbe_index]['CE'][ce_index]['N'] = tfe_name if tfe_name.length > 0

						tfe_content = text_field_entity.xpath('C').text
						sbox['PayloadData'][sbe_index]['CE'][ce_index]['C'] = tfe_content if tfe_content.length > 0
					}
				end
			}
		}

		sbox
	end

	def render(verbose=false)
		puts sbox['MT']

		sbox['PayloadData'].each { |payload_data|
			puts
			puts payload_data['N'] unless payload_data['N'].nil?
			puts payload_data['D'] unless payload_data['D'].nil?
			puts payload_data['T'] unless payload_data['T'].nil?
			payload_data['CE'].each { |strongbox_entity|
				puts strongbox_entity['N'] + ': ' unless strongbox_entity['N'].nil?
				puts strongbox_entity['C']        unless strongbox_entity['C'].nil?
			}
			puts "Access Count: #{payload_data['AC']}" if !payload_data['AC'].nil? && verbose
			puts "#{convert_time_from_dot_net_epoch(payload_data['MT'].to_i)} (modify time)" if !payload_data['MT'].nil? && verbose
			puts "#{convert_time_from_dot_net_epoch(payload_data['CT'].to_i)} (create time)" if !payload_data['CT'].nil? && verbose
		}
	end

	#attr_accessor :decrypted_sbox
	attr_accessor :sbox

	# create an instance of Strongbox
	def initialize(decrypted_sbox, continue_despite_unexpected_payload_schema_version=false)
		super()
		#self.decrypted_sbox = decrypted_sbox
		self.sbox = assemble(decrypted_sbox, continue_despite_unexpected_payload_schema_version)
	end

private

	def self.resembles_base64?(string)
		string.length % 4 == 0 && string =~ /^[A-Za-z0-9+\/=]+\Z/
	end

	def convert_time_from_dot_net_epoch(t)
		Time.at((t-UNIX_EPOCH_IN_100NS_INTERVALS)*1e-7).utc.getlocal
	end
end

#class String
#	def resembles_base64?
#		self.length % 4 == 0 && self =~ /^[A-Za-z0-9+\/=]+\Z/
#	end
#end
