# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/block'

class TestChallenge15 < Minitest::Test
  def test_ch_15
    assert_equal 'ICE ICE BABY',      "ICE ICE BABY\x04\x04\x04\x04".pkcs7_check
    assert_equal "ICE ICE BABY\x01",  "ICE ICE BABY\x01\x03\x03\x03".pkcs7_check

    assert_raises(Cryptopals::PaddingError) { "ICE ICE BABY\x05\x05\x05\x05".pkcs7_check }
    assert_raises(Cryptopals::PaddingError) { "ICE ICE BABY\x01\x02\x03\x04".pkcs7_check }
  end
end
