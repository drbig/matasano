# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/block'
require 'cryptopals/util'
require 'uri'

class TestChallenge13 < Minitest::Test
  def setup
    @cb = Cryptopals::Block
    @cb.set_cipher(OpenSSL::Cipher::AES, 128, :ECB, :key => Cryptopals.random_ascii(16))
  end

  def profile_for(email)
    "email=#{email.gsub(/=|&/, '')}&uid=10&role=user"
  end

  def profile_parse(str)
    Hash[URI.decode_www_form(str)]
  end

  def is_user?(hsh)
    hsh['role'] == 'user'
  end

  def is_admin?(hsh)
    hsh['role'] == 'admin'
  end

  def test_ch_13
    assert is_user?(profile_parse(profile_for('foo@bar.com')))
    assert is_user?(profile_parse(profile_for('foo@bar.com&admin=true')))
    assert is_user?(profile_parse(profile_for('admin=true&admin=true&admin=true')))

    cut = profile_for('1234567890' + 'admin'.pkcs7_pad(16)).encrypt.slice(16, 16)
    paste = profile_for('1234567891234').encrypt.slice(0, 32) + cut
    p = profile_parse(paste.decrypt)

    assert is_admin?(p)
    assert_equal false, is_user?(p)
  end
end
