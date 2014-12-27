require 'openssl'
require 'cryptopals'
require 'cryptopals/util'

module Cryptopals
  class BlockError < Error; end
  class PaddingError < BlockError; end

  module Block
    @cipher_params = nil
    @cipher = nil

    def self.set_cipher(obj, size, mode, opts = {})
      @cipher = obj.new(size, mode)

      if opts[:key] && opts[:key] != :random && opts[:key] != :null
        raise BlockError, 'key length and block size mismatch' if opts[:key].length != (size / 8)
      end
      if opts[:iv] && opts[:iv] != :random && opts[:iv] != :null
        raise BlockError, 'iv length and block size mismatch' if opts[:key].length != (size / 8)
      end

      @cipher_params = {
        :cipher => obj.name.split('::').last,
        :size => size,
        :mode => mode.upcase,
        :key => opts[:key] || :random,
        :iv => opts[:iv] || :random
      }
    end

    def self.get_cipher
      @cipher_params
    end

    def self.set_cipher_params(opts = {})
      key = opts[:key] || @cipher_params[:key]
      iv = opts[:iv] || @cipher_params[:iv]
      bs = @cipher_params[:size] / 8

      key = case key
            when :random
              @cipher.random_key
            when :null
              @cipher.key = "\0" * bs
            else
              @cipher.key = key
            end

      if @cipher_params[:mode] != :ECB
        iv = case iv
             when :random
               @cipher.random_iv
             when :null
               @cipher.iv = "\0" * bs
             else
               @cipher.iv = iv
             end
      end

      [key, iv]
    end
    private_class_method :set_cipher_params

    def self.do_cipher(data, op, opts = {})
      raise BlockError, 'no cipher set' unless @cipher

      @cipher.reset
      @cipher.send(op)
      p = set_cipher_params(opts)

      c = @cipher.update(data)
      c += @cipher.final unless opts[:raw]

      if opts[:debug]
        [c] + p
      else
        c
      end
    end
    private_class_method :do_cipher

    def self.encrypt(data, opts = {})
      do_cipher(data, :encrypt, opts)
    end

    def self.decrypt(data, opts = {})
      do_cipher(data, :decrypt, opts)
    end

    def self.ecb_detect(data, size, opts = {}, &oracle)
      raise BlockError, 'bad block size' if size % 8 != 0

      bs = size / 8
      min = opts[:min] || 4
      if oracle
        f = 'A' * (bs * 6)
        data = oracle.call(f)
      end

      s = data.to_slices(bs).combination(2).inject(0) do |a, (x, y)|
        a += 1 if x == y
        if a == min
          if opts[:debug]
            return [true, a]
          else
            return true
          end
        end
        a
      end

      if opts[:debug]
        [false, s]
      else
        false
      end
    end

    def self.ecb_blocksize(opts = {}, &oracle)
      raise BlockError, 'no oracle given' unless oracle

      runs = opts[:runs] || 10
      min = 2 ** 32
      max = 0
      1.upto(runs) do
        l = oracle.call('').length
        min = [min, l].min
        max = [max, l].max
      end

      bs = nil
      i = 1
      while true
        l = oracle.call('A' * i).length
        if l > max
          bs = (l - max) * 8
          break
        end
        i += 1
      end

      if opts[:debug]
        [bs, min, max]
      else
        bs
      end
    end

    def self.ecb_reveal(len, offset, size, opts = {}, &oracle)
      raise BlockError, 'no oracle given' unless oracle

      bs = size / 8                             # block size (all in bytes)
      fs = Cryptopals.block_align(offset, size) # pre-fudge block length
      bufs = Cryptopals.block_align(len, size)  # cracking buffer length
      prfu = 'F' * ((fs - offset) + bs)         # pre-fudge string (align cracking buffer)
      pofu = 'F' * (bufs - len)                 # post-fudge string (align target string)
      glen = fs + (2 * bs) + (2 * bufs)         # good length (all alligned, max ciphertext length)
      bp = fs + bufs                            # position of cracking block
      plain = Array.new

      1.upto(len) do |p|
        dict = Hash.new
        0.upto(255) do |b|
          src = prfu + ('A' * (bufs - p)) + plain.join + b.chr + pofu
          while c = oracle.call(src)
            next unless c.length == glen
            dict[c.slice(bp, bs)] = b.chr
            break
          end
        end

        src = prfu + ('A' * (bufs - p))
        while cb = oracle.call(src).slice(bp, bs)
          next unless dict.has_key? cb
          plain.push(dict[cb])
          break
        end
      end

      plain.join
    end

    def self.cbc_padding_vector(plain, cipher, pos, bs)
      a = "\0" * bs
      p = bs - pos
      (bs - 2).downto(pos) do |i|
        a[i + 1] = (p ^ plain[i + 1].ord ^ cipher[i + 1].ord).chr
      end
      a
    end
    private_class_method :cbc_padding_vector

    def self.cbc_padding(data, size, opts = {}, &oracle)
      raise BlockError, 'no oracle given' unless oracle

      bs = size / 8
      iv = opts[:iv] || ("\0" * bs)
      cbs = [iv] + data.to_slices(bs)
      plains = Array.new

      (cbs.length - 1).downto(1) do |i|
        p = ' ' * bs
        a = "\0" * bs
        pb = cbs[i - 1]
        (bs - 1).downto(0) do |j|
          0.upto(255) do |b|
            a[j] = b.chr
            if oracle.call(a + cbs[i])
              p[j] = ((bs - j) ^ pb[j].ord ^ a[j].ord).chr
              a = cbc_padding_vector(p, pb, j - 1, bs)
              break
            end
          end
        end
        plains.unshift(p.dup)
      end

      plains.join
    end
  end
end

class String
  def pkcs7_pad(size)
    c = bytes.each_slice(size).to_a.last.pack('c*')
    b = size - c.length
    self + (b.chr * b)
  end

  def pkcs7_check
    p = bytes.last
    return true if p > 64
    if bytes.slice(-p, p).all? {|b| b == p }
      slice(0, length - p)
    else
      raise Cryptopals::PaddingError, 'bad padding'
    end
  end

  def encrypt(opts = {})
    Cryptopals::Block.encrypt(self, opts)
  end

  def decrypt(opts = {})
    Cryptopals::Block.decrypt(self, opts)
  end

  def is_ecb?(size = 16, opts = {})
    Cryptopals::Block.ecb_detect(self, size, opts)
  end
end
