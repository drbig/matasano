# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/block'

class TestBlock < Minitest::Test
  def test_pkcs7_pad
    assert_equal "YELLOW SUBMARINE",          'YELLOW SUBMARINE'.pkcs7_pad(16)
    assert_equal "YELLOW SUBMARIN\x01",       'YELLOW SUBMARIN'.pkcs7_pad(16)
    assert_equal "YELLOW SUBMARI\x02\x02",    'YELLOW SUBMARI'.pkcs7_pad(16)
    assert_equal "YELLOW SUBMAR\x03\x03\x03", 'YELLOW SUBMAR'.pkcs7_pad(16)
    assert_equal "YELLOW SUBMAR\x03\x03\x03", 'YELLOW SUBMAR'.pkcs7_pad(8)
  end
end
