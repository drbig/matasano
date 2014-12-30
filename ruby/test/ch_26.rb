# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/block'
require 'cryptopals/conv'
require 'cryptopals/util'
require 'uri'

class TestChallenge26 < Minitest::Test
  def setup
    @cb = Cryptopals::Block
    @cb.set_cipher(OpenSSL::Cipher::AES, 128, :CTR,
                   :key => Cryptopals.random_ascii(16),
                   :iv => Cryptopals.random_ascii(16))
  end

  def comment_for(data)
    "comment1=cooking%20MCs;#{URI.encode_www_form({:userdata => data})};comment2=%20like%20a%20pound%20of%20bacon"
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

  def test_ch_26
    assert_equal false, is_admin?(comment_parse(comment_for(';admin=true')))
    assert_equal false, is_admin?(comment_parse(comment_for('admin=true;admin=true')))
    assert_equal false, is_admin?(comment_parse(comment_for('%3badmin%3dtrue%3b')))

    assert_includes Cryptopals.bytes_with_dist(';', 1, true), '3'
    assert_includes Cryptopals.bytes_with_dist('=', 1, true), '5'

    c = comment_for('aaaaa3admin5true').encrypt
    c[32 + 5]  = (c[32 + 5].ord  ^ 8).chr
    c[32 + 11] = (c[32 + 11].ord ^ 8).chr
    p = comment_parse(c.decrypt)

    assert is_admin?(p)
  end
end
