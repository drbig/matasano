# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/rng'

class TestRNG < Minitest::Test
  def test_MT19937
    rng = Cryptopals::RNG::MT19937.new(5)
    a = rng.take(32)
    rng.reseed(5)
    b = rng.take(32)
    assert a == b
  end
end
