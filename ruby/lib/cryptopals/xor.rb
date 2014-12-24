require 'base64'
require 'cryptopals'

module Cryptopals
  class XORKeyError < Error; end
end

class String
  def xor_with(key, mod = false)
    if key.is_a? Integer
      raise Cryptopals::XORKeyError, 'key byte out of range' if key < 0 || key > 255
      each_byte.map {|b| (b ^ key).chr }.join
    elsif key.is_a? String
      if mod
        k = key.bytes
        l = k.length
        each_byte.map.with_index {|b, i| (b ^ k[i % l] ).chr }.join
      else
        raise Cryptopals::XORKeyError, 'mismatched key length' if length != key.length
        bytes.zip(key.bytes).map {|(a, b)| (a ^ b).chr }.join
      end
    else
      raise Cryptopals::XORKeyError, 'wrong key class'
    end
  end
end
