# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/block'

class TestChallenge11 < Minitest::Test
  def setup
    @cb = Cryptopals::Block
  end

  def gen_crap(input)
    c = 5 + rand(6)
    p = Cryptopals.random_bytes(c) + input + Cryptopals.random_bytes(c)
    p.encrypt
  end

  def test_ch_11
    [128, 256].each do |s|
      @cb.set_cipher(OpenSSL::Cipher::AES, s, :ECB)
      1.upto(16) do
        assert @cb.ecb_detect(nil, s) {|i| gen_crap(i) }
      end
    end

    [128, 256].each do |s|
      @cb.set_cipher(OpenSSL::Cipher::AES, s, :CBC)
      1.upto(16) do
        assert_equal false, @cb.ecb_detect(nil, s) {|i| gen_crap(i) }
      end
    end
  end
end
