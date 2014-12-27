# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/block'
require 'cryptopals/conv'
require 'cryptopals/util'
require 'cryptopals/xor'

class TestChallenge18 < Minitest::Test
  def setup
    @cb = Cryptopals::Block
    @cb.set_cipher(OpenSSL::Cipher::AES, 128, :ECB, :key => 'YELLOW SUBMARINE')
    @data = 'L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ=='.from_base64
  end

  def ctr_do(str)
    str.to_slices(16).map.with_index do |b, i|
      cnt = ("\x00" * 8) + i.chr + ("\x00" * 7)
      key = cnt.encrypt.slice(0, b.length)
      b.xor_with(key)
    end.join
  end

  def test_ch_18
    p = ctr_do(@data)
    assert_equal "Yo, VIP Let's kick it Ice, Ice, baby Ice, Ice, baby ", p
    c = ctr_do(p)
    assert_equal @data, c
  end
end
