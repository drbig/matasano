# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'
require 'cryptopals/xor'

class TestChallenge6 < Minitest::Test
  DATA_FILE = File.join(File.dirname(__FILE__), '..', '..', 'data', '1-6.txt')

  def setup
    @data = String.new
    File.open(DATA_FILE, 'r') do |f|
      f.each_line {|l| @data += l.chop.from_base64 }
    end
  end

  def test_ch_6
    assert_equal [[29, ["Terminator X: Bring the noise"]]],
                 @data.xor_break_mod(:n => 1)
  end
end
