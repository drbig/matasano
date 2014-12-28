# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/rng'

class TestChallenge22 < Minitest::Test
  def setup
    @rng = Cryptopals::RNG::MT19937.new
  end

  def get_random
    seed = Time.now.to_i + 40 + rand(961)
    now = seed + 40 + rand(961)
    @rng.reseed(seed)
    [now, seed, @rng.random]
  end

  def brute_seed(now, num)
    1000.downto(0).each do |o|
      seed = now - o
      @rng.reseed(seed)
      return seed if @rng.random == num
    end
    nil
  end

  def test_ch_22
    3.times do
      t, s, n = get_random
      assert_equal s, brute_seed(t, n)
    end
  end
end
