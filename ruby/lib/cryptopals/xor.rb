require 'base64'
require 'cryptopals'

module Cryptopals
  class XORKeyError < Error; end
  class XORModelError < Error; end

  MODELS = {
    :en => {
      'e' => 12.702, 't' => 9.056, 'a' => 8.167, 'o' => 7.507,
      'i' => 6.996,  'n' => 6.749, 's' => 6.327, 'h' => 6.094,
      'r' => 5.987,  'd' => 4.253, 'l' => 4.025, 'c' => 2.782,
      'u' => 2.758,  'm' => 2.406, 'w' => 2.360, 'f' => 2.228,
      'g' => 2.015,  'y' => 1.974, 'p' => 1.929, 'b' => 1.492,
      'v' => 0.978,  'k' => 0.772, 'j' => 0.153, 'x' => 0.150,
      'q' => 0.095,  'z' => 0.074,
    }
  }
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

  def xor_break_byte(opts = {})
    n = opts[:n] || 3
    lang = opts[:lang] || :en
    model = opts[:model] || Cryptopals::MODELS[lang]
    raise XORModelError, 'empty model' if model.nil?

    l = length.to_f
    ls = model.keys.length.to_f
    keys = Array.new
    0.upto(255) do |k|
      freqs = Hash.new(0.0)
      xor_with(k).each_byte do |b|
        c = b.chr
        freqs[c] += 1.0 if model.has_key? c
      end
      score = 0.0
      freqs.each_pair do |c, v|
        score += ((model[c] - (v / l)).abs / model[c]) / ls
      end
      keys.push([score, k])
    end
    keys.sort! {|(a, _), (b, _)| b <=> a }.slice(0, n)
  end

  # this seems to work reliably only for larger portions
  # of ciphertext (e.g > 512 bytes) and longer keys
  # (e.g. > 8 bytes), at least based only on the
  # random-model tests.
  def xor_guess_keylen(min, max, opts = {})
    n = opts[:n] || 3

    l = length
    keys = Array.new
    min.upto(max) do |k|
      hits = 0.0
      each_byte.with_index do |b, i|
        hits += 1.0 if b == self[(i + k) % l].ord
      end
      keys.push([hits / l.to_f, k])
    end
    keys.sort! {|(a, _), (b, _)| b <=> a }.slice(0, n)
  end
end
