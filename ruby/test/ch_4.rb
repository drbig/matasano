# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'
require 'cryptopals/xor'

DATA_FILE = File.join(File.dirname(__FILE__), '..', '..', 'data', '1-4.txt')

class TestChallenge < Minitest::Test
  def test_ch_4
    found = Array.new
    File.open(DATA_FILE, 'r') do |f|
      f.each_line.with_index do |l, i|
        c = l.chop.from_hex
        k = c.xor_break_byte.first
        found.push([k, c.xor_with(k[1])]) if k[0] > 0.5
      end
    end

    assert_equal 1, found.length
    assert_equal 53, found.first.first[1]
    assert_equal "Now that the party is jumping\n", found.first.last
  end
end
