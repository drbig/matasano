# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/xor'

class TestXOR < Minitest::Test
  def test_xor_with_byte
    assert_equal "xde\x7F,e\x7F,m,xi\x7Fx", 'this is a test'.xor_with(12)
    assert_equal 'this is a test', "xde\x7F,e\x7F,m,xi\x7Fx".xor_with(12)
    assert_equal "\xF4\xE8\xE9\xF3\xA0\xE9\xF3\xA0\xE1\xA0\xF4\xE5\xF3\xF4", 'this is a test'.xor_with(128)
    assert_equal 'this is a test', "\xF4\xE8\xE9\xF3\xA0\xE9\xF3\xA0\xE1\xA0\xF4\xE5\xF3\xF4".xor_with(128)

    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with(-12) }
    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with(256) }
  end

  def test_xor_with_string
    assert_equal 'the kid don\'t play', "\x1C\x01\x11\x00\x1F\x01\x01\x00\x06\x1A\x02KSSP\t\x18\x1C".xor_with('hit the bull\'s eye')
    assert_equal 'hit the bull\'s eye', "\x1C\x01\x11\x00\x1F\x01\x01\x00\x06\x1A\x02KSSP\t\x18\x1C".xor_with('the kid don\'t play')

    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with('ab') }
  end

  def test_xor_with_string_mod
    assert_equal "\x00\r\x1A\aT\f\x00T\x15E\a\x11\a\x11", 'this is a test'.xor_with('test', true)
    assert_equal 'this is a test', "\x00\r\x1A\aT\f\x00T\x15E\a\x11\a\x11".xor_with('test', true)
  end

  def test_xor_with_wrong_class
    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with(:sym) }
    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with(0.1) }
    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with([1]) }
  end
end
