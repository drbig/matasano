require 'cryptopals'
require 'cryptopals/conv'
require 'cryptopals/util'
require 'openssl'

module Cryptopals
  class PKeyError < Error; end

  module PKey
    class RSA
      def initialize(opts = {})
        bits = opts[:bits] || 1024
        @e = opts[:e] || 3
        @p = opts[:p] || OpenSSL::BN.generate_prime(bits / 2).to_i
        @q = opts[:q] || OpenSSL::BN.generate_prime(bits / 2).to_i

        @n = @p * @q
        et = ((@p - 1) * (@q - 1))
        @d = @e.invmod(et)
      end

      def pub_key;  [@e, @n]; end
      def priv_key; [@d, @n]; end

      def encrypt_n(n); n.expmod(@e, @n); end
      def decrypt_n(n); n.expmod(@d, @n); end

      def encrypt(msg)
        encrypt_n(msg.to_hex.to_i(16))
      end

      def decrypt(cip)
        decrypt_n(cip).to_s(16).from_hex
      end
    end
  end
end
