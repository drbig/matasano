# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/pkey'
require 'cryptopals/util'

# 64 bit key length is a cheat. For anything real a better
# integer cube root function would be required.
class TestChallenge40 < Minitest::Test
  def test_ch_40
    10.times do
      # plaintext to encrypt
      p = Cryptopals.random_ascii(8)
      # get three samples, each under new random key
      data = 3.times.collect do
        r = Cryptopals::PKey::RSA.new(:bits => 64)
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
      # in a perfect world we would just get an exact cube root,
      # but floats are crap, mathn and ** (1r/3) is crap too,
      # and I'm too lazy for Newton's method
      almost = Math.cbrt(res).to_i
      while (diff = res - (almost ** 3)) != 0
        diff < 0 ? almost -= 1 : almost += 1
      end
      # uncheese the plainnumber to plaintext
      plain = almost.to_s(16).from_hex
      # voila
      assert_equal p, plain
    end
  end
end
