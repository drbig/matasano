# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/xor'

class TestXOR < Minitest::Test
  def test_xor_one
    assert_equal "xde\x7F,e\x7F,m,xi\x7Fx",                                   'this is a test'.xor_one(12)
    assert_equal "\xF4\xE8\xE9\xF3\xA0\xE9\xF3\xA0\xE1\xA0\xF4\xE5\xF3\xF4",  'this is a test'.xor_one(128)
  end

  def test_xor_one_error
    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_one('test') }
    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_one(:sym) }
    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_one(0.1) }
  end
end
