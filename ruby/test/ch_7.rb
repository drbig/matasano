# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'
require 'openssl'

class TestChallenge7 < Minitest::Test
  DATA_FILE = File.join(File.dirname(__FILE__), '..', '..', 'data', '1-7.txt')

  def setup
    @data = String.new
    File.open(DATA_FILE, 'r') do |f|
      f.each_line {|l| @data += l.chop.from_base64 }
    end
    @dec = OpenSSL::Cipher.new('AES-128-ECB')
  end

  def test_ch_7
    @dec.reset
    @dec.key = 'YELLOW SUBMARINE'
    p = @dec.update(@data) + @dec.final
    assert p.ascii_only?
  end
end
