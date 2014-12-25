# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'
require 'cryptopals/xor'

class TestChallenge3 < Minitest::Test
  def test_ch_3
    c = '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'.from_hex
    k = c.xor_break_byte.first[1]
    assert_equal 'Cooking MC\'s like a pound of bacon', c.xor_with(k)
  end
end
