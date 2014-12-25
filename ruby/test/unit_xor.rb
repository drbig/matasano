# coding: ascii
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'cryptopals/xor'

class TestXOR < Minitest::Test
  def setup
    # for xor_guess_keylen and xor_break_mod
    # assumes normalized and sorted model!
    model = Cryptopals::MODELS[:en]
    sum = 0
    @model = Hash[model.keys.zip(model.values.map {|x| sum += x })]
  end

  # generate a string from @model
  def gen_string(length)
    1.upto(length).map do
      r = 100.0 * rand
      @model.each_pair do |b, p|
        break b if p >= r
      end
    end.join
  end

  # random ascii
  def gen_ascii(length)
    1.upto(length).map { (32 + rand(95)).chr }.join
  end

  def test_xor_with_byte
    assert_equal "xde\x7F,e\x7F,m,xi\x7Fx", 'this is a test'.xor_with(12)
    assert_equal 'this is a test', "xde\x7F,e\x7F,m,xi\x7Fx".xor_with(12)
    assert_equal "\xF4\xE8\xE9\xF3\xA0\xE9\xF3\xA0\xE1\xA0\xF4\xE5\xF3\xF4", 'this is a test'.xor_with(128)
    assert_equal 'this is a test', "\xF4\xE8\xE9\xF3\xA0\xE9\xF3\xA0\xE1\xA0\xF4\xE5\xF3\xF4".xor_with(128)

    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with(-12) }
    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with(256) }
  end

  def test_xor_with_string
    assert_equal 'the kid don\'t play', "\x1C\x01\x11\x00\x1F\x01\x01\x00\x06\x1A\x02KSSP\t\x18\x1C".xor_with('hit the bull\'s eye')
    assert_equal 'hit the bull\'s eye', "\x1C\x01\x11\x00\x1F\x01\x01\x00\x06\x1A\x02KSSP\t\x18\x1C".xor_with('the kid don\'t play')

    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with('ab') }
  end

  def test_xor_with_string_mod
    assert_equal "\x00\r\x1A\aT\f\x00T\x15E\a\x11\a\x11", 'this is a test'.xor_with('test', true)
    assert_equal 'this is a test', "\x00\r\x1A\aT\f\x00T\x15E\a\x11\a\x11".xor_with('test', true)
  end

  def test_xor_with_wrong_class
    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with(:sym) }
    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with(0.1) }
    assert_raises(Cryptopals::XORKeyError) { 'test'.xor_with([1]) }
  end

  def test_xor_break_byte
    [
      ['this is a test', [32, 54, 128]],
      ['some longer test to test it nicely', [11, 93, 123]],
      ['What About Capitalized Stuff?', [43, 78, 211]]
    ].each do |(p, ks)|
      ks.each do |k|
        c = p.xor_with(k)
        assert_equal k, c.xor_break_byte.first[1]
      end
    end
  end

  def test_xor_guess_keylen
    [
      [512,  ['short key sdsf', 'who knows what', 'a much longer key for fun']],
      [1024, ['no short keys?', '%sgj3*923jd0-2', 'H*(hdlk3h8(&Goidh389)(()u']],
      [2048, ['!@#$%^123 werwe', 'abcdef a test', 'completely not random']]
    ].each do |(s, ks)|
      p = gen_string(s)
      ks.each do |k|
        l = k.length
        c = p.xor_with(k, true)
        assert_includes c.xor_guess_keylen(4, 32).map(&:last), l
      end
    end
  end

  def test_xor_break_mod
    p = gen_string(4096)
    [21, 25, 31].each do |kl|
      k = gen_ascii(kl)
      c = p.xor_with(k, true)
      assert_equal [[kl, [k]]], c.xor_break_mod(:n => 1)
    end
  end
end
