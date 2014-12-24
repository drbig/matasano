require 'base64'
require 'cryptopals'

module Cryptopals
  class OddLengthError < Error; end
end

class String
  def from_hex
    raise Cryptopals::OddLengthError if length % 2 != 0
    scan(/../).map {|e| e.to_i(16).chr }.join
  end

  def to_hex
    each_byte.map {|e| '%02x' % e }.join
  end

  def from_base64
    Base64.decode64(self)
  end

  def to_base64
    Base64.encode64(self).gsub("\n", '')
  end
end
