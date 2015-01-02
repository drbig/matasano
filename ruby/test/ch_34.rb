# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/keyexchange'
require 'digest/sha1'
require 'openssl'

class TestChallenge34 < Minitest::Test
  # Ugly ...
  class Alice
    def initialize
      @p = rand(31337)
      @g = 2
      @dh = Cryptopals::KeyExchange::DH.new(:p => @p, :g => @g)
      @pub = @dh.public
      @cip = OpenSSL::Cipher::AES.new(128, :CBC)
    end

    def interact(obj)
      pub_b = obj.get_public(@p, @g, @pub)
      priv = @dh.private(pub_b)
      key = Digest::SHA1.hexdigest(priv.to_s).slice(0, 16)
      msgs = Array.new
      3.times do
        iv = Cryptopals.random_ascii(16)
        @cip.reset
        @cip.encrypt
        @cip.key = key
        @cip.iv = iv
        msg = "test at #{Time.now.to_s}: " + Cryptopals.random_ascii(4 + rand(12))
        res = obj.echo(@cip.update(msg) + @cip.final + iv)
        iv_b = res.slice(-16, 16)
        cmsg_b = res.slice(0, res.length - 16)
        @cip.reset
        @cip.decrypt
        @cip.key = key
        @cip.iv = iv_b
        msg_b = @cip.update(cmsg_b) + @cip.final
        msgs.push([msg, msg_b])
      end
      msgs
    end
  end

  class Bob
    def initialize
      @cip = OpenSSL::Cipher::AES.new(128, :CBC)
    end

    def get_public(p, g, pub_a)
      @dh = Cryptopals::KeyExchange::DH.new(:p => p, :g => g)
      @pub = @dh.public
      @priv = @dh.private(pub_a)
      @key = Digest::SHA1.hexdigest(@priv.to_s).slice(0, 16)
      @pub
    end

    def echo(cmsg_a)
      iv_a = cmsg_a.slice(-16, 16)
      cmsg_a = cmsg_a.slice(0, cmsg_a.length - 16)
      @cip.reset
      @cip.decrypt
      @cip.key = @key
      @cip.iv = iv_a
      msg_a = @cip.update(cmsg_a) + @cip.final
      @cip.reset
      @cip.encrypt
      @cip.key = @key
      iv = Cryptopals.random_ascii(16)
      @cip.iv = iv
      @cip.update(msg_a) + @cip.final + iv
    end
  end

  class Eve
    attr_reader :seen

    def initialize(other)
      @seen = Array.new

      @other = other
      @cip = OpenSSL::Cipher::AES.new(128, :CBC)
      @key = Digest::SHA1.hexdigest('0').slice(0, 16)
    end

    def get_public(p, g, pub_a)
      @p = p
      @g = g
      @pub_a = pub_a
      @pub_b = @other.get_public(p, g, p)
      p
    end

    def echo(cmsg_a)
      iv_a = cmsg_a.slice(-16, 16)
      cmsg_aa = cmsg_a.slice(0, cmsg_a.length - 16)
      @cip.reset
      @cip.decrypt
      @cip.key = @key
      @cip.iv = iv_a
      msg_a = @cip.update(cmsg_aa) + @cip.final

      cmsg_b = @other.echo(cmsg_a)

      iv_b = cmsg_b.slice(-16, 16)
      cmsg_bb = cmsg_b.slice(0, cmsg_b.length - 16)
      @cip.reset
      @cip.decrypt
      @cip.key = @key
      @cip.iv = iv_b
      msg_b = @cip.update(cmsg_bb) + @cip.final

      @seen.push([msg_a, msg_b])

      cmsg_b
    end
  end
  # ... Done.

  def test_ch_34
    10.times do
      Alice.new.interact(Bob.new).each {|(a, b)| assert_equal a, b }
    end

    10.times do
      e = Eve.new(Bob.new)
      m = Alice.new.interact(e)
      m.each {|(a, b)| assert_equal a, b }
      e.seen.each {|(a, b)| assert_equal a, b }
      assert_equal m, e.seen
    end
  end
end
