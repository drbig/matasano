#!/usr/bin/env ruby
# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'sinatra'
require 'cryptopals/chash'
require 'cryptopals/util'
require 'pp'

KEY = Cryptopals.random_ascii(16)
DELAY = (ARGV.shift || 0.05).to_f

def insecure_compare(a, b)
  t = [a.length, b.length].min
  0.upto(t) do |i|
    return false unless a[i] == b[i]
    sleep(DELAY)
  end
  true
end

def verify(msg, sig)
  insecure_compare(sig, Cryptopals::CHash.hmac(KEY, msg))
end

get '/delay' do
  DELAY.to_s
end

get '/key' do
  KEY
end

get '/quit' do
  Process.kill('TERM', Process.pid)
end

get '/test/:file/:sig' do |f, s|
  status verify(f, s) ? 200 : 500
end
