require 'cryptopals'

module Cryptopals
  class RNGError < Error; end

  module RNG
    class MT19937
      include Enumerable

      attr_reader :seed
      attr_accessor :index, :state

      def initialize(seed = 0)
        reseed(seed)
      end

      def reseed(seed)
        @index = 0
        @state = Array.new(0, 624)
        @seed = @state[0] = seed
        1.upto(623) do |i|
          @state[i] = (1812433253 * (@state[i - 1] ^ (@state[i - 1] >> 30) + i)) & 0xffffffff
        end
      end

      def random
        generate if @index == 0
        y = @state[@index]
        @index = (@index + 1) % 624

        y ^= y >> 11
        y ^= ((y << 7)  & 2636928640)
        y ^= ((y << 15) & 4022730752)
        y ^= y >> 18
      end

      def each
        loop do yield random end
      end

      def clone(&source)
        raise RNGError, 'no source given' unless source

        @index = 0
        0.upto(623) do |i|
          y = source.call

          y ^= y >> 18
          y ^= ((y << 15) & 4022730752)
          n = y
          5.times { n = y ^ ((n << 7) & 2636928640) }
          y = n
          2.times { n = y ^ (n >> 11) }
          @state[i] = n
        end
      end

      private
      def generate
        0.upto(623) do |i|
          y = (@state[i] & 0x80000000) + (@state[(i + 1) % 624] & 0x7fffffff)
          @state[i] = @state[(i + 397) % 624] ^ (y >> 1)
          @state[i] = @state[i] ^ 2567483615 if y % 2 != 0
        end
      end
    end
  end
end
