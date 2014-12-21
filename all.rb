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

def cbc_enc(src, key, iv)
  xk = iv.dup
  ciph = Array.new
  src.each_slice(key.length) do |b|
    @enc.reset
    @enc.encrypt
    @enc.key = key
    b = pkcs_pad(b, key.length) if b.length < key.length
    ciph += xk = @enc.update(bytes2str(xor_two(b, xk)) + "\0").bytes
  end
  ciph
end

#require 'base64'
#data = Array.new
#File.open('data/2-10.txt', 'r') do |f|
#  f.each_line do |l|
#    l.chop!
#    data += Base64.decode64(l).bytes
#  end
#end
#plain = cbc_dec(data, 'YELLOW SUBMARINE', [0] * 16)
#pp bytes2str(plain)

#c = cbc_enc(
#  'IBM invented the cipher-block chaining (CBC) mode of operation in 1976.'.bytes,
#  'YELLOW SUBMARINE', [0] * 16
#)
#pp bytes2str(cbc_dec(c, 'YELLOW SUBMARINE', [0] * 16))

def rand_bytes(len); 1.upto(len).collect { rand(256) }; end
def rand_ascii(len); 1.upto(len).collect { 32 + rand(96) }; end

@ecb = OpenSSL::Cipher.new('AES-128-ECB')
@cbc = OpenSSL::Cipher.new('AES-128-CBC')
@keylen = 16

def gen_crap(input)
  c = 5 + rand(6)
  src = rand_bytes(c) + input.bytes + rand_bytes(c)
  if rand > 0.5
    @cbc.reset
    @cbc.encrypt
    @cbc.key_len = @keylen
    key = @cbc.random_key
    iv = @cbc.random_iv
    ciph = @cbc.update(bytes2str(src)) + @cbc.final
    [:cbc, [input, src], [key, iv], ciph]
  else
    @ecb.reset
    @ecb.encrypt
    @ecb.key_len = @keylen
    key = @ecb.random_key
    ciph = @ecb.update(bytes2str(src)) + @ecb.final
    [:ecb, [input, src], [key], ciph]
  end
end

def mode_oracle(len, samples, keylen)
  s = len * samples
  c = gen_crap(('A' * len) * samples)
  ch = c.last.bytes
  r = ch.length - s
  b = [0, 0]
  0.upto(r) do |o|
    i = ch.slice(o, s)
    g = guess_keylen(i, 2, keylen).first
    if g.first > b.first
      b = g
    end
  end
  # this might even guess the keylength
  #[c.first, @key.length, b]
  if b.first > 10
    [c.first, :ecb]
  else
    [c.first, :cbc]
  end
end

#1.upto(16) do |i|
#  pp [i, mode_oracle(4, 16, 32)]
#end

require 'base64'
@unknown_str = Base64.decode64('Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHddXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QYnkK')
pp @key = bytes2str(rand_ascii(16))

def oracle_12(input)
  src = input + @unknown_str
  @ecb.reset
  @ecb.encrypt
  @ecb.key = @key
  @ecb.update(src) + @ecb.final
end

# ok, i got it now. the block size is the cipher bit size,
# e.g. for AES I have 128 bits (16 bytes), 192 bits (24 bytes) and
# 256 bytes (32 bytes). for OpenSSL it seems that the key length has
# to be at least the block length - but key data after the block length
# is never used! e.g. under AES128 keys 'YELLOW SUBMARINE' and
# 'YELLOW SUBMARINE SECRET' both produce _the same output_.
# so having a 128 character passphrase is a waste and false sense of
# better security if a site uses 128 bit block size...
#
# discover block size
#pp i = oracle_12('A').bytes.first
#2.upto(32) do |o|
#  c = oracle_12('A' * o).bytes
#  pp c.slice(0, o)
#  if c[o-1] == i
#    puts "block size: #{o-1}"
#    break
#  end
#end

# test if ecb
#def mode_oracle_12(len, samples, keylen)
#  s = len * samples
#  ch = oracle_12(('A' * len) * samples).bytes
#  r = ch.length - s
#  b = [0, 0]
#  0.upto(r) do |o|
#    i = ch.slice(o, s)
#    g = guess_keylen(i, 2, keylen).first
#    if g.first > b.first
#      b = g
#    end
#  end
#  if b.first > 10
#    :ecb
#  else
#    :cbc
#  end
#end
#
#pp mode_oracle_12(4, 16, 32)

pp bsize = 128

#puts 'making dictionary...'
#dict = Array.new(256, 0)
#0.upto(255) do |b|
#  c = oracle_12(('A' * (bsize - 1)) + b.chr).bytes
#  dict[b] = c[bsize-1]
#end
#
#c = oracle_12('A' * (bsize - 1)).bytes
#c1 = c[bsize - 1]
#
#p1 = dict.index(c1)
#puts "#{c1} -> #{p1} \"#{p1.chr}\""

plain = Array.new

1.upto(117) do |x|
  dict = Hash.new
  0.upto(255) do |b|
    src = ('A' * (bsize - x)) + plain.join + b.chr
    c = oracle_12(src).bytes.slice(0, bsize)
    dict[c] = b
  end
  cb = oracle_12('A' * (bsize - x)).bytes.slice(0, bsize)
  plain.push(dict[cb].chr)
  print '.'
end
puts
pp plain.join
pp plain.join == @unknown_str
