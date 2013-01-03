# encoding: utf-8
require 'test_helper'

class StrongboxioTest < Test::Unit::TestCase

	FILENAME = 'test/2fe22f4d-bd41-476a-8159-c6e0b6487f7d.sbox'
	PASSWORD = 'pWY4ic9q'

	def test_decrypt_from_file
		expect = '<Payload><SchemaVersion>2.4</SchemaVersion><PayloadInfo><SchemaVersion>1.0</SchemaVersion><IP>PyOQP3GmNEA3T5BjBOiPg,DU4Qm4btjyejD1TYGoUjQ,nC9jzQ4Tv3RsrfxHzghe4A,YlVFCZO1FqBT91H0M3XmQA,WIVON6o61vebxLKJhXKQ,sQgzfRSQEkCJo25tVi47Q</IP><MT>2012-11-27T23:29:23.18873Z</MT><SD>xJ2VL0VourNV3a7cOJkinAMkVVEJJahV17MlbE5x8w</SD></PayloadInfo><PayloadData><T /><CE><SBE ID="7ijIF8xabBZjKsEKpUFnag" II="4" MT="634896555753103810" CT="634896555753102130" AC="0"><N>VanCity bank info</N><D>credit card, debit card, online banking</D><T>Credit, Debit, Card, Online, Banking</T><CE><TFE ID="K87JOu1lge4X7SSKE9elDQ" II="4" MT="634896555753103820"><N>credit card number</N><C>1234 5678 9012 3456</C></TFE><TFE ID="PTsGYmJb7f1B8nIquZfAMQ" II="4" MT="634896555753104130"><N>credit card expiration</N><C>11/2012</C></TFE><TFE ID="sfRgujycbbKIad58FkC1vg" II="4" MT="634896555753104380"><N>credit card verification value</N><C>123</C></TFE><TFE ID="bK7Vba0t2oupLiRGjEkt5Q" II="4" MT="634896555753104690"><N>debit card PIN</N><C>1234</C></TFE><TFE ID="2j9hKQJqCvbrVpmfRqJVA" II="4" MT="634896555753104970"><N>online banking password</N><C>qwerty</C></TFE></CE></SBE><SBE ID="L35bmTNw34lQnA70hmEVmg" II="3" MT="634896550747551430" CT="634896550747549900" AC="0"><N>fake Gmail account</N><D>used for Stackoverflow</D><T>Fake Gmail Stackoverflow</T><CE><TFE ID="Zmjyh5cMoj5s1AuH18EJA" II="3" MT="634896550747551440"><N>username</N><C>ima_fake@gmail.com</C></TFE><TFE ID="bOudR7nlwP40bo6V23jw" II="3" MT="634896550747551750"><N>password</N><C>password1</C></TFE><TFE ID="klbjFvsyyDEs956gkduKg" II="3" MT="634896550747552080"><N>gender</N><C>other</C></TFE><TFE ID="ckdoh9oM478UliFoeg" II="3" MT="634896550747552370"><N>backup</N><C>bart_simpson@gmail.com</C></TFE></CE></SBE><SBE ID="SwH6NoXPhg7qXLOUlDQyQ" II="2" MT="634896545666557670" CT="634896545666556630" AC="0"><N>just a name</N><D></D><T /><CE><TFE ID="u9LEZ2H2jQlzqc7a5vD2iA" II="2" MT="634896545666557680"><N /><C /></TFE></CE></SBE><SBE ID="ZoPVBFNFdOlRLT0FLO9BVQ" II="5" MT="634896557631887530" CT="634896545082402010" AC="0"><N>test item name</N><D>test item description</D><T>Test, Item, Tag1, Tag2, Tag3</T><CE><TFE ID="NyRRL7tmBMr0VrDoyzfwg" II="1" MT="634896545082426060"><N>test field name</N><C>test secure text</C></TFE></CE></SBE></CE></PayloadData></Payload>'
		d = Strongboxio.decrypt(FILENAME, PASSWORD)
		assert_equal expect, d
	end

	def test_static_render
		d = Strongboxio.decrypt(FILENAME, PASSWORD)
		assert_equal 0, Strongboxio.render(d) # not checking puts (and don't want to waste memory on creating string)
	end

	def test_strongboxio_instantiation
		# #<Strongboxio:0x1011b2e28 @sbox={"PayloadData"=>[{"CE"=>[{"C"=>"1234 5678 9012 3456", "N"=>"credit card number"}, {"C"=>"11/2012", "N"=>"credit card expiration"}, {"C"=>"123", "N"=>"credit card verification value"}, {"C"=>"1234", "N"=>"debit card PIN"}, {"C"=>"qwerty", "N"=>"online banking password"}], "AC"=>"0", "N"=>"VanCity bank info", "D"=>"credit card, debit card, online banking", "CT"=>"634896555753102130", "MT"=>"634896555753103810", "T"=>"Credit, Debit, Card, Online, Banking"}, {"CE"=>[{"C"=>"ima_fake@gmail.com", "N"=>"username"}, {"C"=>"password1", "N"=>"password"}, {"C"=>"other", "N"=>"gender"}, {"C"=>"bart_simpson@gmail.com", "N"=>"backup"}], "AC"=>"0", "N"=>"fake Gmail account", "D"=>"used for Stackoverflow", "CT"=>"634896550747549900", "MT"=>"634896550747551430", "T"=>"Fake Gmail Stackoverflow"}, {"CE"=>[{}], "AC"=>"0", "N"=>"just a name", "CT"=>"634896545666556630", "MT"=>"634896545666557670"}, {"CE"=>[{"C"=>"test secure text", "N"=>"test field name"}], "AC"=>"0", "N"=>"test item name", "D"=>"test item description", "CT"=>"634896545082402010", "MT"=>"634896557631887530", "T"=>"Test, Item, Tag1, Tag2, Tag3"}], "MT"=>"2012-11-27T23:29:23.18873Z"}>

		d = Strongboxio.decrypt(FILENAME, PASSWORD)
		sbox = Strongboxio.new(d)
		assert_equal 'Strongboxio', sbox.class.to_s
		assert_equal '2012-11-27T23:29:23.18873Z', sbox.sbox['MT']
	end

	def test_instance_render
		d = Strongboxio.decrypt(FILENAME, PASSWORD)
		sbox = Strongboxio.new(d)
		assert_equal 0, sbox.render # not checking puts (and don't want to waste memory on creating string)
	end

end

