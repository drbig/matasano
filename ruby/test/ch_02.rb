# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'
require 'cryptopals/xor'

class TestChallenge02 < Minitest::Test
  def test_ch_02
    assert_equal '746865206b696420646f6e277420706c6179', \
                 '1c0111001f010100061a024b53535009181c'.from_hex\
                 .xor_with('686974207468652062756c6c277320657965'.from_hex)\
                 .to_hex
  end
end
