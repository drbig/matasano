# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'
require 'cryptopals/stream'

class TestChallenge18 < Minitest::Test
  def setup
    @data = 'L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ=='.from_base64
  end

  def test_ch_18
    ctr = Cryptopals::Stream::CTR.new(OpenSSL::Cipher::AES, 128) do |bs, n, i|
      ("\x00" * 8) + [i].pack('Q')
    end
    ctr.key = 'YELLOW SUBMARINE'
    ctr.nonce = ''

    p = ctr.apply(@data)
    assert_equal "Yo, VIP Let's kick it Ice, Ice, baby Ice, Ice, baby ", p
    c = ctr.apply(p)
    assert_equal @data, c
  end
end
