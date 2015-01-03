# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/keyexchange'
require 'cryptopals/util'
require 'openssl'

class TestChallenge36 < Minitest::Test
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

  class Client < Proto
    def run
      fail unless @input

      @a = rand(@N)
      @A = @g.expmod(@a, @N)
      @output.puts @I
      @output.puts @A.to_s

      @salt = @input.readline.to_i
      @B = @input.readline.to_i

      @uH = OpenSSL::Digest::SHA256.hexdigest(@A.to_s + @B.to_s)
      @u = @uH.to_i(16)

      xH = OpenSSL::Digest::SHA256.hexdigest(@salt.to_s + @P)
      x = xH.to_i(16)
      @S = (@B - @k * @g.expmod(x, @N)).expmod(@a + @u * x, @N)
      @K = OpenSSL::Digest::SHA256.hexdigest(@S.to_s)

      my_hmac = OpenSSL::HMAC.new(@K, OpenSSL::Digest.new('sha1')).update(@salt.to_s).hexdigest
      @output.puts my_hmac

      @input.readline.chop
    end
  end
  # ... Done.

  def test_ch_36
    10.times do
      k = Cryptopals.random_ascii(6 + rand(16))
      s = Server.new('foo@bar.com', k)
      c = Client.new('foo@bar.com', k)
      c.connect(s)
      Thread.new { s.run }
      assert_equal 'OK', c.run
    end

    10.times do
      s = Server.new('foo@bar.com', Cryptopals.random_ascii(6 + rand(16)))
      c = Client.new('foo@bar.com', Cryptopals.random_ascii(6 + rand(16)))
      c.connect(s)
      Thread.new { s.run }
      assert_equal 'FAIL', c.run
    end
  end
end
