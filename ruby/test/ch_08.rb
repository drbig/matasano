# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'
require 'cryptopals/block'

class TestChallenge08 < Minitest::Test
  DATA_FILE = File.join(File.dirname(__FILE__), '..', '..', 'data', '1-8.txt')

  def setup
    @data = Array.new
    File.open(DATA_FILE, 'r') do |f|
      f.each_line {|l| @data.push l.chop.from_hex }
    end
  end

  def test_ch_08
    # first raw version
    #s = @data.map.with_index do |e, i|
    #  [e.bytes.each_slice(16).map {|b| b.pack('c*') }.combination(2)\
    #   .inject(0) {|a, (x, y)| x == y ? a += 1 : a }, i]
    #end.sort {|a, b| b <=> a }
    #assert_equal s.first, [6, 132]

    s = @data.map.with_index do |e, i|
      o, s = e.is_ecb?(16, :debug => true)
      o ? [s, i] : nil
    end.compact

    assert_equal 1, s.length
    assert_equal [4, 132], s.first
  end
end
