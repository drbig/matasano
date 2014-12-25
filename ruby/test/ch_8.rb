# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'

class TestChallenge8 < Minitest::Test
  DATA_FILE = File.join(File.dirname(__FILE__), '..', '..', 'data', '1-8.txt')

  def setup
    @data = Array.new
    File.open(DATA_FILE, 'r') do |f|
      f.each_line {|l| @data.push l.chop.from_hex }
    end
  end

  def test_ch_8
    s = @data.map.with_index do |e, i|
      [e.bytes.each_slice(16).map {|b| b.pack('c*') }.combination(2)\
       .inject(0) {|a, (x, y)| x == y ? a += 1 : a }, i]
    end.sort {|a, b| b <=> a }

    assert_equal s.first, [6, 132]
  end
end
