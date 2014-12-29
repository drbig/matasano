require 'openssl'
require 'cryptopals'
require 'cryptopals/util'
require 'cryptopals/xor'

module Cryptopals
  class StreamError < Error; end

  module Stream
    class CTR
      attr_accessor :key, :nonce, :counter
      attr_reader :size

      def initialize(obj, size, opts = {}, &counter)
        raise StreamError, 'no counter given' unless counter

        @cipher = obj.new(size, :ECB)
        @size = size
        @bs = size / 8
        @counter = counter
        @key = opts[:key] || :random
        @nonce = opts[:nonce] || :random
      end

      def apply(data, opts = {})
        @cipher.reset
        @cipher.encrypt
        k, n = set_cipher_params(opts)

        out = data.to_slices(@bs).map.with_index do |b, i|
          cnt = @counter.call(@bs, n, i)
          key = (@cipher.update(cnt) + @cipher.final).slice(0, b.length)
          b.xor_with(key)
        end.join

        if opts[:debug]
          [out, k, n]
        else
          out
        end
      end

      private
      def set_cipher_params(opts = {})
        key = opts[:key] || @key
        nonce = opts[:nonce] || @nonce

        key = case key
               when :random
                 @cipher.random_key
               when :null
                 @cipher.key = "\0" * @bs
               else
                 @cipher.key = key
               end

        nonce = case nonce
                 when :random
                   Cryptopals.random_bytes(@bs)
                 when :null
                   "\0" * @bs
                 else
                   nonce
                 end

        [key, nonce]
      end
    end
  end
end
