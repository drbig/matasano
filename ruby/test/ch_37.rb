# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/keyexchange'
require 'cryptopals/util'
require 'openssl'

class TestChallenge37 < Minitest::Test
  # Not Ugly ...
  class Proto
    attr_reader :out_rd
    attr_accessor :input

    def initialize(email, password, opts = {})
      @N = opts[:N] || Cryptopals::KeyExchange::DH::P
      @g = opts[:g] || 2
      @k = opts[:k] || 3
      @I = email
      @P = password

      @out_rd, @out_wr = IO.pipe
      @output = @out_wr
      @input = nil

      setup
    end

    def connect(proto)
      @input = proto.out_rd
      proto.input = @out_rd
    end

    def setup; end
  end

  class Server < Proto
    def setup
      @salt = rand(31337)
      xH = OpenSSL::Digest::SHA256.hexdigest(@salt.to_s + @P)
      x = xH.to_i(16)
      @v = @g.expmod(x, @N)
    end

    def run
      fail unless @input

      @Ic = @input.readline.chop
      @A = @input.readline.to_i

      @b = rand(@N)
      @B = (@k * @v) + @g.expmod(@b, @N)
      @output.puts @salt.to_s
      @output.puts @B.to_s

      @uH = OpenSSL::Digest::SHA256.hexdigest(@A.to_s + @B.to_s)
      @u = @uH.to_i(16)

      @S = (@A * @v.expmod(@u, @N)).expmod(@b, @N)
      #puts "server S: #{@S}"
      @K = OpenSSL::Digest::SHA256.hexdigest(@S.to_s)

      my_hmac = OpenSSL::HMAC.new(@K, OpenSSL::Digest.new('sha1')).update(@salt.to_s).hexdigest
      cl_hmac = @input.readline.chop

      # for verbose debugging
      #puts "server hmac: #{my_hmac}\nclient hmac: #{cl_hmac}"

      if my_hmac == cl_hmac
        @output.puts 'OK'
      else
        @output.puts 'FAIL'
      end
    end
  end

  class EvilClient < Proto
    attr_accessor :fake_a

    def setup
      @fake_a = 0
      @K = OpenSSL::Digest::SHA256.hexdigest('0')
    end

    def run
      fail unless @input

      @output.puts @I
      @output.puts @fake_a.to_s

      @salt = @input.readline.to_i
      @input.readline.to_i

      my_hmac = OpenSSL::HMAC.new(@K, OpenSSL::Digest.new('sha1')).update(@salt.to_s).hexdigest
      @output.puts my_hmac

      @input.readline.chop
    end
  end
  # ... Done.

  def test_ch_37
    10.times do
      s = Server.new('foo@bar.com', Cryptopals.random_ascii(6 + rand(16)))
      c = EvilClient.new('foo@bar.com', '')
      c.connect(s)
      Thread.new { s.run }
      assert_equal 'OK', c.run
    end

    10.times do
      s = Server.new('foo@bar.com', Cryptopals.random_ascii(6 + rand(16)))
      c = EvilClient.new('foo@bar.com', '')
      c.fake_a = Cryptopals::KeyExchange::DH::P
      c.connect(s)
      Thread.new { s.run }
      assert_equal 'OK', c.run
    end
  end
end
