# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/block'
require 'cryptopals/conv'
require 'cryptopals/xor'
require 'cryptopals/util'

class TestChallenge10 < Minitest::Test
  DATA_FILE = File.join(File.dirname(__FILE__), '..', '..', 'data', '2-10.txt')

  def setup
    @data = String.new
    File.open(DATA_FILE, 'r') do |f|
      f.each_line {|l| @data += l.chop.from_base64 }
    end

    Cryptopals::Block.set_cipher(OpenSSL::Cipher::AES, 128, :ECB,
                                 :key => 'YELLOW SUBMARINE')
  end

  def cbc_dec(str)
    xk = "\0" * 16
    plain = String.new
    str.to_slices(16).each do |s|
      pb = (s + "\0").decrypt(:raw => true)
      plain += pb.xor_with(xk)
      xk = s
    end
    plain
  end

  def cbc_enc(str)
    xk = "\0" * 16
    ciph = String.new
    str.to_slices(16).each do |s|
      s = s.pkcs7_pad(16) if s.length < 16
      ciph += xk = (s.xor_with(xk) + "\0").encrypt(:raw => true)
    end
    ciph
  end

  def test_ch_10
    plain = cbc_dec(@data)
    ciph = cbc_enc(plain)
    plain2 = cbc_dec(ciph)

    assert_equal ciph, @data
    assert_equal plain, plain2
  end
end
