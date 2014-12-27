# matasano

Sharing my progress and solutions to the [the matasano crypto challenges](http://cryptopals.com/). Obviously, this is one big **spoiler**. You have been warned.

Current status: **fun in progress**, at [Set 3](http://cryptopals.com/sets/3/)

- Set 1
  1. [Convert hex to base64](http://cryptopals.com/sets/1/challenges/1) - **Done**
  2. [Fixed XOR](http://cryptopals.com/sets/1/challenges/2) - **Done**
  3. [Single-byte XOR cipher](http://cryptopals.com/sets/1/challenges/3) - **Done**
  4. [Detect single-character XOR](http://cryptopals.com/sets/1/challenges/4) - **Done**
  5. [Implement repeating-key XOR](http://cryptopals.com/sets/1/challenges/5) - **Done**
  6. [Break repeating-key XOR](http://cryptopals.com/sets/1/challenges/6) - **Done**
  7. [AES in ECB mode](http://cryptopals.com/sets/1/challenges/7) - **Done**
  8. [Detect AES in ECB mode](http://cryptopals.com/sets/1/challenges/8) - **Done**
- Set 2
  9. [Implement PKCS#7 padding](http://cryptopals.com/sets/2/challenges/9) - **Done**
  10. [Implement CBC mode](http://cryptopals.com/sets/2/challenges/10) - **Done**
  11. [An ECB/CBC detection oracle](http://cryptopals.com/sets/2/challenges/11) - **Done**
  12. [Byte-at-a-time ECB decryption (Simple)](http://cryptopals.com/sets/2/challenges/12) - **Done**
  13. [ECB cut-and-paste](http://cryptopals.com/sets/2/challenges/13) - **Done**
  14. [Byte-at-a-time ECB decryption (Harder)](http://cryptopals.com/sets/2/challenges/14) - **Done**
  15. [PKCS#7 padding validation](http://cryptopals.com/sets/2/challenges/15) - **Done**
  16. [CBC bitflipping attacks](http://cryptopals.com/sets/2/challenges/16) - **Done**
- Set 3
  17. [The CBC padding oracle](http://cryptopals.com/sets/3/challenges/17) - **Done**
  18. [Implement CTR, the stream cipher mode](http://cryptopals.com/sets/3/challenges/18) - **Done**
  19. [Break fixed-nonce CTR mode using substitutions](http://cryptopals.com/sets/3/challenges/19) - Skipped (for now)
  20. [Break fixed-nonce CTR statistically](http://cryptopals.com/sets/3/challenges/20) - **Done**

~~*All hacking is done in Ruby, in a single file*. I prefer this free-form style where I mix my functions and test snippets, commenting stuff in and out. I plan to separate the functions and test cases into some sane file hierarchy once I feel I'm done with the challenges themselves. I'm even tempted to wrap it all as a test suite or Rakefile.~~

All of the code here is 100% genuine own code, done by me. No looksees, copy & paste etc. I might have looked up the theory of some topics in proper literature though (you should too, probably).

Currently Sets 1 - 2 are done 'properly' in Ruby:

    $ cd ruby && rake test:challenge:all
    Run options: -v --seed 17746
    
    # Running:
    
    TestChallenge01#test_ch_01 = 0.00 s = .
    TestChallenge02#test_ch_02 = 0.00 s = .
    TestChallenge03#test_ch_03 = 0.01 s = .
    TestChallenge04#test_ch_04 = 1.57 s = .
    TestChallenge05#test_ch_05 = 0.00 s = .
    TestChallenge06#test_ch_06 = 0.40 s = .
    TestChallenge07#test_ch_07 = 0.00 s = .
    TestChallenge08#test_ch_08 = 0.13 s = .
    TestChallenge09#test_ch_09 = 0.00 s = .
    TestChallenge10#test_ch_10 = 0.01 s = .
    TestChallenge11#test_ch_11 = 0.00 s = .
    TestChallenge12#test_ch_12 = 0.37 s = .
    TestChallenge13#test_ch_13 = 0.00 s = .
    TestChallenge14#test_ch_14 = 4.60 s = .
    TestChallenge15#test_ch_15 = 0.00 s = .
    TestChallenge16#test_ch_16 = 0.00 s = .
    
    Finished in 7.102223s, 2.2528 runs/s, 14.7841 assertions/s.
    
    16 runs, 105 assertions, 0 failures, 0 errors, 0 skips

There are also unit tests for the library (`rake test:unit:all`, but note that some are non-deterministic where a failure doesn't necessarily mean the code is wrong).

The general idea is to have the unit tests not depend on the challenges data inputs. This might not be exactly the case for now. (I've also noted that some of my `assert_equal`s are backwards, oh well, conventions...)

### Thoughts and notes

Ruby really kicks ass when it comes to hacking and *learning* new things. Go not so much, but I've learned that Unicode-centric approach is problematic for hacking ASCII-based crypto. I don't see any real speed difference between my Ruby code and my Go code.

### High-level spoilers

Reading code is one thing, knowing the right output is another. If you believe knowing the right outputs is *really* the thing that will help you *understand* what's going on have a looksee [here](https://github.com/drbig/matasano/blob/master/SPOILERS.txt). There are also some spoilerific/sanity-ensuring notes.

## Licensing

Licensed under [CC BY-NC-SA](http://creativecommons.org/licenses/by-nc-sa/4.0/), see LICENSE.txt for details.

Copyright (c) 2014 Piotr S. Staszewski
