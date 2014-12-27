# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'
require 'cryptopals/block'
require 'cryptopals/util'
require 'cryptopals/xor'

class TestChallenge20 < Minitest::Test
  DATA_FILE = File.join(File.dirname(__FILE__), '..', '..', 'data', '3-20.txt')

  def setup
    @cb = Cryptopals::Block
    @cb.set_cipher(OpenSSL::Cipher::AES, 128, :CTR, :key => Cryptopals.random_ascii(16), :iv => :null)
    @data = Array.new
    File.open(DATA_FILE, 'r') do |f|
      f.each_line do |l|
        @data.push(l.chop.from_base64)
      end
    end
  end

  def test_ch_20
    cs = @data.map(&:encrypt)
    min = 2**32
    cs.each {|e| min = [min, e.length].min }
    assert_equal 53, min
    ps = @data.map {|e| e.slice(0, min) }
    csc = cs.map {|e| e.slice(0, min) }
    all = csc.join
    assert_equal 53 * @data.length, all.length
    keys = all.xor_break_mod(:keylengths => [[nil, min]])
    key = keys.first.last.first
    ps.each_with_index do |p, i|
      assert p.dist_hamming(csc[i].xor_with(key)) < 2
    end
  end
end
