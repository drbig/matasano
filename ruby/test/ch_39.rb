# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/pkey'
require 'cryptopals/util'

class TestChallenge39 < Minitest::Test
  def test_ch_39
    10.times do
      # the key length of RSA is the bit length of the modulus
      # (n). So for n = 1024 -> 1024 / 8 = 128 -> maximum length
      # of string that can be encrypted, ala block size (?)
      # at least that's my current understanding
      #
      # here for speed lets have a smaller key length
      r = Cryptopals::PKey::RSA.new(:bits => 512)
      10.times do
        p = Cryptopals.random_ascii(32 + rand(33))
        c = r.encrypt(p)
        assert_equal p, r.decrypt(c)
      end
    end
  end
end
