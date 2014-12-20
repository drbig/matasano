#!/usr/bin/env ruby
# coding: utf-8

require 'pp'

def bytes2str(ary); ary.map(&:chr).join; end
def hex2bytes(str); str.scan(/../).map {|e| e.to_i(16) }; end
def bytes2hex(ary); ary.map {|e| '%02x' % e }.join; end

def xor_byte(src, byte); src.map {|e| e ^ byte }; end
def xor_two(a, b); a.zip(b).map {|(x, y)| x ^ y }; end
def xor_mod(src, key)
  l = key.length
  src.map.with_index {|e, i| e ^ key[i % l] }
end

#a = hex2bytes '1c0111001f010100061a024b53535009181c'
#b = hex2bytes '686974207468652062756c6c277320657965'
#c = xor_two(a, b)
#pp bytes2str(c)

#src = <<EOF
#Burning 'em, if you ain't quick and nimble
#I go crazy when I hear a cymbal
#EOF
#cip = xor_mod(src.bytes, 'ICE'.bytes)
#pp bytes2hex(cip)

# from http://en.wikipedia.org/wiki/Letter_frequency
ENGLISH = {
  'e' => 12.702,
  't' => 9.056,
  'a' => 8.167,
  'o' => 7.507,
  'i' => 6.996,
  'n' => 6.749,
  's' => 6.327,
  'h' => 6.094,
  'r' => 5.987,
  'd' => 4.253,
  'l' => 4.025,
  'c' => 2.782,
  'u' => 2.758,
  'm' => 2.406,
  'w' => 2.360,
  'f' => 2.228,
  'g' => 2.015,
  'y' => 1.974,
  'p' => 1.929,
  'b' => 1.492,
  'v' => 0.978,
  'k' => 0.772,
  'j' => 0.153,
  'x' => 0.150,
  'q' => 0.095,
  'z' => 0.074,
}

def xor_break_byte(ary)
  l = ary.length.to_f
  ls = ENGLISH.keys.length.to_f
  keys = Array.new
  0.upto(255) do |k|
    freqs = Hash.new(0.0)
    ok = true
    xor_byte(ary, k).each do |b|
      # fast check if 'printable'
      if b > 127
        ok = false
        break
      end
      # case-insensitive
      c = b.chr.downcase
      freqs[c] += 1.0 if ENGLISH.has_key? c
    end
    next unless ok
    score = 0.0
    freqs.each_pair do |c, v|
      # we only care about the difference from the model
      score += ((ENGLISH[c] - (v / l)).abs / ENGLISH[c]) / ls
    end
    keys.push([score, k])
  end
  keys.sort! {|(a, _), (b, _)| b <=> a }
end

#a = hex2bytes '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
#c = xor_break_byte(a)
#pp c.first
#pp bytes2str(xor_byte(a, c[0][1]))

def hamming(a, b)
  a.zip(b).inject(0) do |d, (x, y)|
    v = x ^ y
    # using Kernighan method for bit counting
    while v > 0
      v &= v - 1
      d += 1
    end
    d
  end
end

#pp hamming('this is a test'.bytes, 'wokka wokka!!!'.bytes)
#pp hamming('wokka wokka!!!'.bytes, 'this is a test'.bytes)
#pp hamming([0], [1])
#pp hamming([0], [3])

#File.open('data/1-4.txt', 'r') do |f|
#  i = 1
#  f.each_line do |l|
#    b = xor_break_byte(hex2bytes(l.chop!))
#    if b.length > 0 && b[0][0] > 0.55
#      puts "#{i} #{l}"
#      pp b[0]
#      pp bytes2str(xor_byte(hex2bytes(l), b[0][1]))
#    end
#    i += 1
#  end
#end

#def guess_keylen(src, min, max)
#  l = src.length
#  lens = Array.new
#  min.upto(max) do |k|
#    a = src.slice(0, k)
#    b = src.slice(k, k)
#    score = hamming(a, b).to_f / l.to_f
#    lens.push([score, k])
#  end
#  lens.sort! {|(a, _), (b, _)| a <=> b }
#end

# the above function has been implemented as per the instructions.
# i doesn't work, really. i guess it's probably me, but anyways, the
# function below is much simpler and actually works.
def guess_keylen(src, min, max)
  l = src.length
  lens = Array.new
  min.upto(max) do |k|
    hits = 0
    src.each_with_index do |b, i|
      if b == src[i + k % l]
        hits += 1
      end
    end
    lens.push([hits, k])
  end
  lens.sort! {|(a, _), (b, _)| b <=> a }
end

# padded versions are here just to enable me to use Array#transpose later
def xor_byte_padded(src, byte)
  src.map do |e|
    if e < 0
      nil
    else
      e ^ byte
    end
  end.compact
end

def xor_break_byte_padded(ary)
  l = ary.length.to_f
  ls = ENGLISH.keys.length.to_f
  keys = Array.new
  0.upto(255) do |k|
    freqs = Hash.new(0.0)
    ok = true
    xor_byte_padded(ary, k).each do |b|
      if b > 127
        ok = false
        break
      end
      c = b.chr.downcase
      freqs[c] += 1.0 if ENGLISH.has_key? c
    end
    next unless ok
    score = 0.0
    freqs.each_pair do |c, v|
      score += ((ENGLISH[c] - (v / l)).abs / ENGLISH[c]) / ls
    end
    keys.push([score, k])
  end
  keys.sort! {|(a, _), (b, _)| b <=> a }
end

#require 'base64'
#data = Array.new
#File.open('data/1-6.txt', 'r') do |f|
#  f.each_line do |l|
#    l.chop!
#    data += Base64.decode64(l).bytes
#  end
#end
#pp data.length
#ks = guess_keylen(data, 2, 40)
#pp keylen = ks[0][1]
#pp padding = keylen - (data.length % keylen)
#pdata = data.dup + ([-1] * padding)
#pp pdata.length
#buckets = pdata.each_slice(keylen).to_a.transpose
#key = Array.new
#buckets.each do |b|
#  xor_break_byte_padded(b).each do |(s, k)|
#    next if k < 32 || k > 127
#    key.push(k)
#    break
#  end
#end
#pp bytes2str(key)
#pp key = 'Terminator X: Bring the noise'
#plain = bytes2str(xor_mod(data, key.bytes))
#puts plain if plain.ascii_only?

#require 'base64'
#require 'openssl'
#data = String.new
#File.open('data/1-7.txt', 'r') do |f|
#  f.each_line do |l|
#    l.chop!
#    data += Base64.decode64(l)
#  end
#end
#cip = OpenSSL::Cipher.new('AES-128-ECB')
#pp key = 'YELLOW SUBMARINE'
#cip.decrypt
#cip.key = key
#plain = cip.update(data) + cip.final
#puts plain if plain.ascii_only?

#data = Array.new
#File.open('data/1-8.txt', 'r') do |f|
#  f.each_line do |l|
#    l.chop!
#    data.push(hex2bytes(l))
#  end
#end
#pp data.length
#scores = Array.new
#data.each_with_index do |b, i|
#  scores.push([i, guess_keylen(b, 2, b.length - 1).first])
#end
#scores.sort! {|(_, (x, _)), (_, (y, _))| y <=> x }
#pp scores

def pkcs_pad(ary, len)
  b = len - ary.length
  ary.dup + ([b] * b)
end

#pp bytes2str(pkcs_pad('YELLOW SUBMARINE'.bytes, 20))

require 'openssl'
@dec = OpenSSL::Cipher.new('AES-128-ECB')
@enc = OpenSSL::Cipher.new('AES-128-ECB')

def cbc_dec(src, key, iv)
  xk = iv.dup
  plain = Array.new
  src.each_slice(key.length) do |b|
    # seems we do need to reset everything for each block and
    # the str to decrypt must have length > key length.
    # i guess it's due to OpenSSL implementation quirkiness?
    @dec.reset
    @dec.decrypt
    @dec.key = key
    ob = @dec.update(bytes2str(b) + "\0")
    plain += xor_two(ob.bytes, xk)
    xk = b
  end
  plain
end

require 'base64'
data = Array.new
File.open('data/2-10.txt', 'r') do |f|
  f.each_line do |l|
    l.chop!
    data += Base64.decode64(l).bytes
  end
end

plain = cbc_dec(data, 'YELLOW SUBMARINE', [0] * 16)
pp bytes2str(plain)
