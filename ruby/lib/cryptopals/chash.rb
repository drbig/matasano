# coding: ascii
require 'cryptopals'
require 'cryptopals/conv'
require 'cryptopals/util'
require 'stringio'

module Cryptopals
  class HashError < Error; end

  module CHash
    # c&p from md4
    def self.md4_pad(size)
      input = 'A' * size
      mask = (1 << 32) - 1
      bit_len = input.size << 3
      input += "\x80"
      input += "\x00" while (input.size % 64) != 56
      input += [bit_len & mask, bit_len >> 32].pack("V2")
      raise HashError, 'failed to pad to correct length' if (input.size % 64) != 0
      input.slice(size, input.length)
    end

    # after http://rosettacode.org/wiki/MD4#Ruby
    #
    def self.md4(input, opts = {})
      # fix encoding
      input = input.force_encoding('ascii-8bit')

      # functions
      mask = (1 << 32) - 1
      f = proc {|x, y, z| x & y | x.^(mask) & z}
      g = proc {|x, y, z| x & y | x & z | y & z}
      h = proc {|x, y, z| x ^ y ^ z}
      r = proc {|v, s| (v << s).&(mask) | (v.&(mask) >> (32 - s))}

      # initial hash
      if opts[:from]
        a, b, c, d = opts[:from].from_hex.to_slices(4).map {|e| e.unpack('V').first }
      else
        a, b, c, d = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
      end

      if opts[:size]
        bit_len = opts[:size] + 1
        bit_len += 1 while (bit_len % 64) != 56
        bit_len += 8
        bit_len += input.size
        bit_len = bit_len << 3
      else
        bit_len = input.size << 3
      end

      input += "\x80"
      input += "\x00" while (input.size % 64) != 56
      input += [bit_len & mask, bit_len >> 32].pack("V2")

      raise HashError, 'failed to pad to correct length' if (input.size % 64) != 0

      io = StringIO.new(input)
      block = ''

      while io.read(64, block)
        x = block.unpack('V16')

        # Process this block.
        aa, bb, cc, dd = a, b, c, d
        [0, 4, 8, 12].each {|i|
          a = r[a + f[b, c, d] + x[i],  3]; i += 1
          d = r[d + f[a, b, c] + x[i],  7]; i += 1
          c = r[c + f[d, a, b] + x[i], 11]; i += 1
          b = r[b + f[c, d, a] + x[i], 19]
        }
        [0, 1, 2, 3].each {|i|
          a = r[a + g[b, c, d] + x[i] + 0x5a827999,  3]; i += 4
          d = r[d + g[a, b, c] + x[i] + 0x5a827999,  5]; i += 4
          c = r[c + g[d, a, b] + x[i] + 0x5a827999,  9]; i += 4
          b = r[b + g[c, d, a] + x[i] + 0x5a827999, 13]
        }
        [0, 2, 1, 3].each {|i|
          a = r[a + h[b, c, d] + x[i] + 0x6ed9eba1,  3]; i += 8
          d = r[d + h[a, b, c] + x[i] + 0x6ed9eba1,  9]; i -= 4
          c = r[c + h[d, a, b] + x[i] + 0x6ed9eba1, 11]; i += 8
          b = r[b + h[c, d, a] + x[i] + 0x6ed9eba1, 15]
        }
        a = (a + aa) & mask
        b = (b + bb) & mask
        c = (c + cc) & mask
        d = (d + dd) & mask
      end

      [a, b, c, d].pack('V4').unpack('H*').first
    end

    def self.sha1(input, rev = 1, opts = {})
      case rev
      when 1
        fips_180_1(input, opts)
      when 2
        fips_180_2(input, opts)
      else
        raise HashError, 'no such FIPS 180 revision'
      end
    end

    # c&p from fips_180_1
    def self.fips_180_pad(size)
      input = 'A' * size
      mask = 0xffffffff
      bit_len = input.size << 3
      input += "\x80"
      input += "\x00" while (input.size % 64) != 56
      input += [bit_len >> 32, bit_len & mask].pack('N2')
      raise HashError, 'failed to pad to correct length' if (input.size % 64) != 0
      input.slice(size, input.length)
    end

    # after http://rosettacode.org/wiki/SHA-1#Ruby
    #
    # This is a simple, pure-Ruby implementation of SHA-1, following
    # the algorithm in FIPS 180-1.
    def self.fips_180_1(input, opts = {})
      # fix encoding
      input = input.force_encoding('ascii-8bit')

      # functions and constants
      mask = 0xffffffff
      s = proc{|n, x| ((x << n) & mask) | (x >> (32 - n))}
      f = [
        proc {|b, c, d| (b & c) | (b.^(mask) & d)},
        proc {|b, c, d| b ^ c ^ d},
        proc {|b, c, d| (b & c) | (b & d) | (c & d)},
        proc {|b, c, d| b ^ c ^ d},
      ].freeze
      k = [0x5a827999, 0x6ed9eba1, 0x8f1bbcdc, 0xca62c1d6].freeze

      # initial hash
      if opts[:from]
        h = opts[:from].from_hex.to_slices(4).map {|e| e.unpack('N').first }
      else
        h = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0]
      end

      if opts[:size]
        bit_len = opts[:size] + 1
        bit_len += 1 while (bit_len % 64) != 56
        bit_len += 8
        bit_len += input.size
        bit_len = bit_len << 3
      else
        bit_len = input.size << 3
      end

      input += "\x80"
      input += "\x00" while (input.size % 64) != 56
      input += [bit_len >> 32, bit_len & mask].pack('N2')

      raise HashError, 'failed to pad to correct length' if (input.size % 64) != 0

      io = StringIO.new(input)
      block = ''

      while io.read(64, block)
        w = block.unpack('N16')

        # Process block.
        (16..79).each {|t| w[t] = s[1, w[t-3] ^ w[t-8] ^ w[t-14] ^ w[t-16]]}

        a, b, c, d, e = h
        t = 0
        4.times do |i|
          20.times do
            temp = (s[5, a] + f[i][b, c, d] + e + w[t] + k[i]) & mask
            a, b, c, d, e = temp, a, s[30, b], c, d
            t += 1
          end
        end

        [a,b,c,d,e].each_with_index {|x,i| h[i] = (h[i] + x) & mask}
      end

      h.pack('N5').to_hex
    end

    # after https://gist.github.com/tstevens/925415
    #
    # FIPS 180-2 -- relevant section #'s below
    # Pulls parts from Wiki pseudocode and http://ruby.janlelis.de/17-sha-256
    def self.fips_180_2(input, opts = {})
      # fix encoding
      input = input.force_encoding('ascii-8bit')

      # 5.3.1 - Initial hash value
      z = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0

      # 5.1.1
      length = input.length*8
      input << 0x80
      input << 0 while input.size % 64 != 56
      input += [length].pack('Q').reverse

      #6.1.2
      input.unpack('C*').each_slice(64){|chunk|

        #6.1.2 - 1. Prepare the message schedule
        w = []
        chunk.each_slice(4){|a,b,c,d| w << (((a<<8|b)<<8|c)<<8|d) }

        #Expand from sixteen to eighty -- 6.1.2 - 1. Prepare the message schedule
        (16..79).map{|i|
          w[i] = (w[i-3] ^ w[i-8] ^ w[i-14] ^ w[i-16]).lrc & 0xffffffff
        }

        #6.1.2 - 2. Initialize the five working variables.
        a,b,c,d,e = z

        (0..79).each{|i|  # 6.1.2 - 3. & 4.1.1 - SHA-1 Functions
          case i
          when 0..19
            f = ((b & c) | (~b & d))
            k = 0x5A827999
          when 20..39
            f = (b ^ c ^ d)
            k = 0x6ED9EBA1
          when 40..59
            f = ((b & c) | (b & d) | (c & d))
            k = 0x8F1BBCDC
          when 60..79
            f = (b ^ c ^ d)
            k = 0xCA62C1D6
          end

          temp = (a.lrc(5) & 0xffffffff) + f + e + k + w[i] & 0xffffffff

          e = d
          d = c
          c = b.lrc(30) & 0xffffffff
          b = a
          a = temp
        }

        # 6.1.2 - 4. Compute the ith intermediate hash value
        z[0] = z[0] + a & 0xffffffff
        z[1] = z[1] + b & 0xffffffff
        z[2] = z[2] + c & 0xffffffff
        z[3] = z[3] + d & 0xffffffff
        z[4] = z[4] + e & 0xffffffff
      }

      # Produce the final hash value (big-endian)
      '%.8x'*5 % z
    end
  end
end

class Integer
  def lrc(n = 1)
    self << n | self >> (32 - n)
  end
end
