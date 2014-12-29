# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/conv'
require 'cryptopals/stream'
require 'cryptopals/xor'
require 'cryptopals/util'
require 'openssl'

require 'pp'

class TestChallenge25 < Minitest::Test
  DATA_FILE = File.join(File.dirname(__FILE__), '..', '..', 'data', '4-25.txt')

  def setup
    @ctr = Cryptopals::Stream::CTR.new(OpenSSL::Cipher::AES, 128) do |bs, n, i|
      n.xor_with([0, i].pack('Q*'))
    end
    @ctr.key = Cryptopals.random_ascii(16)
    @ctr.nonce = Cryptopals.random_ascii(16)

    data = String.new
    File.open(DATA_FILE, 'r') do |f|
      f.each_line do |l|
        data += l.chop.from_base64
      end
    end
    dec = OpenSSL::Cipher.new('AES-128-ECB')
    dec.decrypt
    dec.key = 'YELLOW SUBMARINE'
    @plain = dec.update(data) + dec.final
    @cipher = @ctr.apply(@plain)
  end

  # TODO: Maybe separate key stream generation from CTR?
  # That would make the below both easier and more efficient.
  def splice(offset, newtext)
    bf = offset / 16
    tf = bf * 16
    tt = Cryptopals.block_align(offset + newtext.length, 128)
    sf = offset - tf
    st = sf + newtext.length
    src = @plain[tf..tt]
    src[sf..st] = newtext
    [src, bf]
  end

  def edit(offset, newtext)
    src, bf = splice(offset, newtext)
    @ctr.apply(src, :offset => bf)
  end

  def test_ch_25
    assert_equal @plain.length, @cipher.length
    assert_equal @plain, @ctr.apply(@cipher)

    # basically as long as we can see the ciphertext after
    # a change we can recover the original plaintext. i.e.
    # we can do it aribitrary-length-update at a time just
    # fine.
    plain = String.new
    f = 'A' * 16
    @cipher.to_slices(16).each_with_index do |s, i|
      nc = edit(i * 16, f)
      k = f.xor_with(nc.slice(0, 16))
      plain += s.xor_with(k.slice(0, s.length))
    end

    assert_equal @plain, plain
  end
end
