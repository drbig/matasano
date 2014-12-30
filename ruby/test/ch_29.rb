# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/hash'
require 'cryptopals/util'

class TestChallenge29 < Minitest::Test
  def setup
    @key = Cryptopals.random_ascii(16)
  end

  def sign(msg)
    Cryptopals::Hash.sha1(@key + msg)
  end

  def verify(msg, sig)
    sig == Cryptopals::Hash.sha1(@key + msg)
  end

  def comment_parse(data)
    out = Hash.new
    data.split(';').map do |e|
      k, v = e.split('=')
      out[k] = v
    end
    out
  end

  def is_admin?(hsh)
    hsh['admin'] == 'true'
  end

  def test_ch_29
    @key = Cryptopals.random_ascii(6 + rand(11))
    m = 'comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon'
    s = sign(m)

    assert verify(m, s)
    assert !is_admin?(comment_parse(m))

    t = ';admin=true'
    am = nil
    ks = 6.upto(16) do |i|
      si = i + m.length
      p = Cryptopals::Hash.fips_180_pad(si)
      am = m + p + t
      as = Cryptopals::Hash.fips_180_1(t, :from => s, :size => si)
      break i if verify(am, as)
    end

    assert_equal @key.length, ks
    assert is_admin?(comment_parse(am))
  end
end
