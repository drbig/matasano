# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/block'
require 'cryptopals/conv'
require 'cryptopals/util'

require 'pp'

class TestChallenge17 < Minitest::Test
  def setup
    @cb = Cryptopals::Block
    @cb.set_cipher(OpenSSL::Cipher::AES, 128, :CBC, :key => Cryptopals.random_ascii(16), :iv => :null)
    @data = [
      'MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=',
      'MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=',
      'MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==',
      'MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==',
      'MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl',
      'MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==',
      'MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==',
      'MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=',
      'MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=',
      'MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93'
    ].map {|e| e.from_base64 }
  end

  def test_ch_17
    @data.each do |p|
      c = p.encrypt
      r = @cb.cbc_padding(c, 128) do |i|
        begin
          i.decrypt
          true
        rescue OpenSSL::Cipher::CipherError
          false
        end
      end

      assert_equal p, r.pkcs7_check
    end
  end
end
