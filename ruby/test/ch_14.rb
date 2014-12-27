# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/block'
require 'cryptopals/conv'
require 'cryptopals/util'

class TestChallenge14 < Minitest::Test
  def setup
    @cb = Cryptopals::Block
    @cb.set_cipher(OpenSSL::Cipher::AES, 128, :ECB, :key => Cryptopals.random_ascii(16))
    @target = 'Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK'.from_base64
  end

  def gen_crap(input)
    p = Cryptopals.random_bytes(6) + input + @target
    p.encrypt
  end

  def test_ch_14
    assert_equal 128, @cb.ecb_blocksize(:runs => 1) {|i| gen_crap(i) }
    assert @cb.ecb_detect(nil, 128) {|i| gen_crap(i) }
    assert_equal "Rollin' in my 5.0\nWith my rag-top down so my hair can blow\nThe girlies on standby waving just to say hi\nDid you stop?", @cb.ecb_reveal(117, 6, 128) {|i| gen_crap(i) }
  end
end
