require 'base64'
require 'cryptopals'

class String
  def dist_hamming(other)
    raise Cryptopals::Error, 'length mismatch' if length != other.length
    bytes.zip(other.bytes).inject(0) do |d, (x, y)|
       v = x ^ y
       while v > 0
         v &= v - 1
         d += 1
       end
       d
    end
  end
end