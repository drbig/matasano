# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/pkey'
require 'cryptopals/util'

class TestChallenge40 < Minitest::Test
  def test_ch_40
    10.times do
      # plaintext to encrypt
      p = Cryptopals.random_ascii(32 + rand(33))
      # get three samples, each under new random key
      data = 3.times.collect do
        # use 512 bit long key to speed this test up
        r = Cryptopals::PKey::RSA.new(:bits => 512)
        # collect ciphertext and public modulus
        [r.encrypt(p), r.pub_key.last] #
      end
      # gather the moduli
      ns = data.collect {|(_, n)| n }
      # calculate and collect m_s_n
      msn = ns.combination(2).map {|(a, b)| a * b }.reverse
      # calculate result sans last mod operation
      res = 0
      0.upto(2) {|i| res += data[i].first * msn[i] * msn[i].invmod(ns[i]) }
      # calculate N_012
      nall = ns.inject(1) {|a, x| a * x }
      # finalize result
      res %= nall
      # cube root proper (Newton's method)
      plainnum = res.nroot(3)
      # uncheese the plainnumber to plaintext
      plaintext = plainnum.to_s(16).from_hex
      # voila
      assert_equal p, plaintext
    end
  end
end
