require 'base64'
require 'openssl'
require 'cryptopals'

module Cryptopals
  class BlockError < Error; end
  class PaddingError < BlockError; end

  @cipher_pool = Hash.new

  def self.get_cipher(cipher)
    @cipher_pool[cipher] ||= OpenSSL::Cipher.new(cipher)
  end
end

class String
  def pkcs7_pad(size)
    c = bytes.each_slice(size).to_a.last.pack('c*')
    b = size - c.length
    self + (b.chr * b)
  end

  def pkcs7_check
    p = str.bytes.last
    return true if p > 64
    if bytes.slice(-p, p).all? {|b| b == p }
      slice(0, length - p)
    else
      raise PaddingError, 'bad padding'
    end
  end
end
