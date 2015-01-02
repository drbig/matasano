# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/keyexchange'

class TestChallenge33 < Minitest::Test
  def test_ch_33
    5.times do
      a = Cryptopals::KeyExchange::DH.new
      b = Cryptopals::KeyExchange::DH.new
      pa = a.public
      pb = b.public
      sa = a.private(pb)
      sb = b.private(pa)
      assert_equal sa, sb
    end

    5.times do
      p = rand(Cryptopals::KeyExchange::DH::P)
      a = Cryptopals::KeyExchange::DH.new(:p => p)
      b = Cryptopals::KeyExchange::DH.new(:p => p)
      pa = a.public
      pb = b.public
      sa = a.private(pb)
      sb = b.private(pa)
      assert_equal sa, sb
    end
  end
end
