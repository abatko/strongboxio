#!/usr/bin/env ruby

require 'rubygems' if defined?RUBY_VERSION && RUBY_VERSION =~ /^1.8/ # for requiring gem dependency in Ruby 1.8
require 'highline/import' # ask
require 'strongboxio'

def get_filename(filename=ARGV[0])
  if filename.nil?
    puts "Usage #{$0} input.sbox" ; exit
  else
    if File.exist?(filename)
      if !File.readable?(filename)
        puts "file #{filename} is not readable!" ; exit
      end
    else
      puts "file #{filename} does not exist!" ; exit
    end
  end
  filename
end

filename = get_filename

password = ask('Enter the password to unlock this box: ') { |q| q.echo = '*' }

d = Strongboxio.decrypt(filename, password)

begin
  sbox = Strongboxio.new(d)
rescue => e
  puts "Error: #{e}"
  yn = ask('Continue anyway? [yN] ')
  exit unless yn =~ /^[yY]\Z/
  sbox = Strongboxio.new(d, true)
end

sbox.render

