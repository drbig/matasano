# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/pkey'
require 'cryptopals/util'

class TestChallenge39 < Minitest::Test
  def test_ch_39
    10.times do
      # generating 1 kilobit RSA keys is expensive as usual,
      # so here let's make them shorter...
      # also: the bit length seems to set the maximum length
      # of the 'string' that can be encrypted, which does make
      # some intuitive sense (we're operating modulo)
      r = Cryptopals::PKey::RSA.new(:bits => 256)
      10.times do
        p = Cryptopals.random_ascii(16 + rand(32))
        c = r.encrypt(p)
        assert_equal p, r.decrypt(c)
      end
    end
  end
end
