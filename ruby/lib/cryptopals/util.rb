require 'cryptopals'

module Cryptopals
  def self.random_bytes(size)
    1.upto(size).map { rand(256).chr }.join
  end

  def self.random_ascii(size)
    1.upto(size).map { (32 + rand(95)).chr }.join
  end

  # Model is a Hash of chr (byte as a string) - cum. prob. (float)
  # Key - values are in ascending order of cum. prob.
  #
  # TODO: Maybe I should do formal models?
  def self.random_model(size, model)
    1.upto(size).map do
      r = 100.0 * rand
      model.each_pair do |b, p|
        break b if p >= r
      end
    end.join
  end

  def self.block_align(num, size)
    bs = size / 8
    num + (bs - (num % bs))
  end

  def self.bytes_with_dist(from, dist, ascii = false)
    if ascii
      min = 32
      max = 126
    else
      min = 0
      max = 255
    end

    min.upto(max).map {|b| from.dist_hamming(b.chr) == dist ? b.chr : nil }.compact
  end
end

class String
  def to_slices(size)
    bytes.each_slice(size).map {|s| s.pack('c*') }
  end

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

class Integer
  def expmod(e, m)
    raise ArgumentError, 'negative exponent' if e < 0
    p = 1
    b = self % m
    until e.zero?
      p = (p * b) % m if e.odd?
      e >>= 1
      b = (b * b) % m
    end
    p
  end

  # after http://en.m.wikipedia.org/wiki/Extended_Euclidean_algorithm#Modular_integers
  #
  def invmod(n)
    t = 0
    r = n
    newt = 1
    newr = self
    until newr.zero?
      q = r / newr
      t, newt = newt, t - q * newt
      r, newr = newr, r - q * newr
    end
    return nil if r > 1
    t += n if t < 0
    t
  end
end
