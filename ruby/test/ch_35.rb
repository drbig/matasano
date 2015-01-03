# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/keyexchange'
require 'digest/sha1'
require 'openssl'

class TestChallenge35 < Minitest::Test
  # Ugly ...
  class Alice
    def initialize
      @dh = Cryptopals::KeyExchange::DH.new
      @pub = @dh.public
      @cip = OpenSSL::Cipher::AES.new(128, :CBC)
    end

    def interact(obj)
      pub_b = obj.get_public(@dh.p, @dh.g, @pub)
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

    # g = 1 -> key = 1.to_s
    # g = p -> key = 0.to_s
    # g = p - 1 -> key = (p - 1).to_s OR 1.to_s !! 
    # unless we fix it with pub_a = 1 and pub_b = 1
    # then key = 1.to_s
    #
    # i guess this excercise is more for ECDH, but for
    # plain DH why not just inject A and B as 0 and don't
    # care at all for p and g. it seems like a good idea
    # to check the parameters in such negotiating schemes
    # e.g. p > 0, g > 1, |p - g| > some bigger number,
    # A > 1, B > 1 etc.

    def initialize(other, g)
      @seen = Array.new

      @other = other
      @cip = OpenSSL::Cipher::AES.new(128, :CBC)
      @g = g
      case g
      when :one
        @key = Digest::SHA1.hexdigest('1').slice(0, 16)
      when :p
        @key = Digest::SHA1.hexdigest('0').slice(0, 16)
      when :pminus
        @key = Digest::SHA1.hexdigest('1').slice(0, 16)
      end
    end

    def get_public(p, g, pub_a)
      @p = p
      @g_a = g
      @pub_a = pub_a
      case @g
      when :one
        @pub_b = @other.get_public(p, 1, 1)
      when :p
        @pub_b = @other.get_public(p, p, 0)
      when :pminus
        @pub_b = @other.get_public(p, p - 1, 1)
        1
      end
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

  def test_ch_35
    10.times do
      e = Eve.new(Bob.new, :one)
      m = Alice.new.interact(e)
      m.each {|(a, b)| assert_equal a, b }
      e.seen.each {|(a, b)| assert_equal a, b }
      assert_equal m, e.seen
    end

    10.times do
      e = Eve.new(Bob.new, :p)
      m = Alice.new.interact(e)
      m.each {|(a, b)| assert_equal a, b }
      e.seen.each {|(a, b)| assert_equal a, b }
      assert_equal m, e.seen
    end

    10.times do
      e = Eve.new(Bob.new, :pminus)
      m = Alice.new.interact(e)
      m.each {|(a, b)| assert_equal a, b }
      e.seen.each {|(a, b)| assert_equal a, b }
      assert_equal m, e.seen
    end
  end
end
