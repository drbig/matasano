# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/hash'
require 'cryptopals/util'

class TestChallenge28 < Minitest::Test
  def setup
    @key = Cryptopals.random_ascii(16)
  end

  def sign(msg)
    Cryptopals::Hash.sha1(@key + msg)
  end

  def verify(msg, sig)
    sig == Cryptopals::Hash.sha1(@key + msg)
  end

  def test_ch_28
    10.times do
      m = Cryptopals.random_ascii(200 + rand(1000))
      s = sign(m)
      assert verify(m, s)

      @key = Cryptopals.random_ascii(16)
    end

    # let's keep it _very_ simple
    @key = '1'
    m = '1'
    s = sign(m)
    0.upto(255) do |b|
      next if b.chr == m
      assert !verify(b.chr, s)
    end
    0.upto(255) do |b|
      next if b.chr == @key
      s = Cryptopals::Hash.sha1(b.chr + m)
      assert !verify(m, s)
    end
  end
end
