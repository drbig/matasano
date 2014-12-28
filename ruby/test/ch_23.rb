# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/rng'

class TestChallenge23 < Minitest::Test
  def test_ch_23
    3.times do
      source = Cryptopals::RNG::MT19937.new(Time.now.to_i)
      clone = Cryptopals::RNG::MT19937.new
      clone.clone { source.random }
      32.times do
        assert_equal source.random, clone.random
      end
    end
  end
end
