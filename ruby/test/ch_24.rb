# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'
require 'cryptopals/rng'
require 'cryptopals/xor'
require 'cryptopals/util'
require 'digest/md5'

class TestChallenge24 < Minitest::Test
  def setup
    @rng = Cryptopals::RNG::MT19937.new
    @bs = Cryptopals::RNG::ByteStream.new(@rng)
  end

  def rng_ctr(seed, data)
    @bs.clear!
    @rng.reseed(seed)
    data.xor_with(@bs.take(data.length).map(&:chr).join)
  end

  def gen_one(input)
    s = rand(65536)
    l = 6 + rand(30)
    p = Cryptopals.random_ascii(l) + input
    [s, rng_ctr(s, p)]
  end

  def gen_two
    seed = Time.now.to_i
    @bs.clear!
    @rng.reseed(seed)
    [seed, @bs.take(16).map(&:chr).join.to_hex]
  end

  def check_token(bytes, range)
    t = Time.now.to_i
    l = bytes.length
    range.each do |o|
      @bs.clear!
      @rng.reseed(t + o)
      return true if bytes == @bs.take(l).map(&:chr).join
    end

    false
  end

  def test_ch_24
    5.times do
      p = Cryptopals.random_ascii(32 + rand(1025))
      s = Time.now.to_i + rand(128)
      c = rng_ctr(s, p)
      d = rng_ctr(s, c)
      assert_equal p, d
    end

    s, c = gen_one('A' * 14)
    nc = c.slice(-14, 14)
    f = 'A' * c.length
    sg = 0.upto(65536) do |x|
      ct = rng_ctr(x, f)
      break x if ct.slice(-14, 14) == nc
    end
    assert_equal s, sg

    10.times do
      assert check_token(gen_two.last.from_hex, -5..5)
      assert !check_token(Digest::MD5.hexdigest(Time.now.to_s).from_hex, -5..5)
    end
  end
end
