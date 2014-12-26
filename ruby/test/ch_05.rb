# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'
require 'cryptopals/xor'

class TestChallenge05 < Minitest::Test
  DATA_FILE = File.join(File.dirname(__FILE__), '..', '..', 'data', '1-4.txt')

  def test_ch_05
    assert_equal '0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f',
                 "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"\
                 .xor_with('ICE', true).to_hex
  end
end
