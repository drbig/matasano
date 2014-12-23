# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'

class TestConv < Minitest::Test
  def test_from_hex
    assert_equal "\xff\xff",  'ffff'.from_hex
    assert_equal "\x0\x0",    '0000'.from_hex
    assert_equal "\xde\xad",  'dead'.from_hex
  end

  def test_from_hex_error
    assert_raises(Cryptopals::OddLengthError) { '0'.from_hex }
    assert_raises(Cryptopals::OddLengthError) { 'aaa'.from_hex }
  end

  def test_to_hex
    assert_equal '01',        "\x1".to_hex
    assert_equal 'ffff',      "\xff\xff".to_hex
    assert_equal 'deadbeef',  "\xde\xad\xbe\xef".to_hex
    assert_equal '61',        "a".to_hex
  end

  def test_from_base64
    assert_equal '//8=',      "\xff\xff".to_base64
    assert_equal '3q2+7w==',  "\xde\xad\xbe\xef".to_base64
    assert_equal 'YQ==',      "a".to_base64
  end

  def test_to_base64
    assert_equal 'aGVsbG8=',  "hello".to_base64
    assert_equal 'AQIDBA==',  "\x01\x02\x03\x04".to_base64
  end
end
