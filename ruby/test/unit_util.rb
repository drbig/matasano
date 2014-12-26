# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/util'

class TestConv < Minitest::Test
  def test_dist_hamming
    assert_equal 37,  'this is a test'.dist_hamming('wokka wokka!!!')
    assert_equal 37,  'wokka wokka!!!'.dist_hamming('this is a test')
    assert_equal 1,   "\x00".dist_hamming("\x01")
    assert_equal 2,   "\x00".dist_hamming("\x03")
    assert_equal 2,   "\x01\x01".dist_hamming("\x00\x00")
  end

  def test_dist_hamming_error
    assert_raises(Cryptopals::Error) { '123'.dist_hamming('1') }
  end

  def test_to_slices
    assert_equal ['ab', 'cd', 'e'],         'abcde'.to_slices(2)
    assert_equal ["\x01\x02", "\x03\x04"],  "\x01\x02\x03\x04".to_slices(2)
    assert_equal ['abc'],                   'abc'.to_slices(4)
    assert_equal ['abcd', 'efgh'],          'abcdefgh'.to_slices(4)
  end
end
