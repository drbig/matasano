# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/chash'
require 'open-uri'

class TestChallenge32 < Minitest::Test
  WEB = File.join(File.dirname(__FILE__), 'web_ch_31.rb')
  DELAY = '0.005'
  CHARS = (('a'..'f').to_a + ('0'..'9').to_a).shuffle

  def setup
    skip 'takes too long to include here'

    @pid = Process.spawn("#{WEB} #{DELAY}", 2 => '/dev/null', 1 => '/dev/null')
    sleep 1 # whatever
  end

  def req(path)
    begin
      open('http://localhost:4567/' + path).read
    rescue
      nil
    end
  end

  def test_ch_32
    assert_equal DELAY, req('delay')

    f = 'test.txt'
    p = "test/#{f}/"

    k = req('key')
    ps = Cryptopals::CHash.hmac(k, f)

    s = String.new
    r = true
    t = 0.0048
    while r
      f = false

      CHARS.each do |c|
        tms = Array.new
        5.times do
          start = Time.now.to_f
          if req(p + s + c)
            s += c
            r = false
            f = true
            break
          end
          tms.push(Time.now.to_f - start)
        end
        break unless r
        time = tms.inject(0.0) {|a, x| a += x } / tms.size.to_f
        if time > t
          print '.'
          s += c
          t = time + 0.004
          f = true
          break
        end
      end

      unless f
        print "\n"
        flunk "didn't work\n"
      end
    end
    print "\n"

    assert_equal ps, s
  end

  def teardown
    unless skipped?
      req('quit')
      Process.waitpid(@pid)
    end
  end
end
