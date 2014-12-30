# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/block'
require 'cryptopals/conv'
require 'cryptopals/util'
require 'cryptopals/xor'
require 'uri'

class TestChallenge27 < Minitest::Test
  def setup
    @ki = Cryptopals.random_ascii(16)
    @cb = Cryptopals::Block
    @cb.set_cipher(OpenSSL::Cipher::AES, 128, :CBC, 
                   :key => @ki, :iv => @ki)
  end

  def comment_for(data = '')
    "comment1=cooking%20MCs;#{URI.encode_www_form({:userdata => data})};comment2=%20like%20a%20pound%20of%20bacon"
  end

  def comment_parse(data)
    return [false, data] unless data.ascii_only?

    out = Hash.new
    data.split(';').map do |e|
      k, v = e.split('=')
      out[k] = v
    end
    [true, out]
  end

  def test_ch_27
    c = comment_for.encrypt
    a = c.dup
    a[16..31] = "\x0" * 16
    a[32..47] = c[0..15]
    assert_equal c.length, a.length
    s, p2 = comment_parse(a.decrypt)
    assert !s
    k = p2.slice(0, 16).xor_with(p2.slice(32, 16))
    assert_equal @ki, k
  end
end
