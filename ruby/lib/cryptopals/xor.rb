require 'base64'
require 'cryptopals'

module Cryptopals
  class XORKeyError < Error; end
end

class String
  def xor_one(key)
    raise Cryptopals::XORKeyError, 'single byte key expected' unless key.kind_of? Integer
    each_byte.map {|b| (b ^ key).chr }.join
  end

  def xor_two(key)
    raise Cryptopals::XORKeyError, 'mismatched key length' if length != key.length
    bytes.zip(key.bytes).map {|(a, b)| (a ^ b).chr }.join
  end

  def xor_mod(key)
    k = key.bytes
    l = k.length
    each_bytr.map.with_index {|b, i| (b ^ k[i % l] ).chr }.join
  end
end
