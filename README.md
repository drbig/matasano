# matasano [![Build Status](https://travis-ci.org/drbig/matasano.svg?branch=master)](https://travis-ci.org/drbig/matasano)

Sharing my progress and solutions to the [the matasano crypto challenges](http://cryptopals.com/). Obviously, this is one big **spoiler**. You have been warned.

Current status: **fun in progress**, at [Set 5](http://cryptopals.com/sets/5/)

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
  21. [Implement the MT19937 Mersenne Twister RNG](http://cryptopals.com/sets/3/challenges/21) - **Done**
  22. [Crack an MT19937 seed](http://cryptopals.com/sets/3/challenges/22) - **Done**
  23. [Clone an MT19937 RNG from its output](http://cryptopals.com/sets/3/challenges/23) - **Done**
  24. [Create the MT19937 stream cipher and break it](http://cryptopals.com/sets/3/challenges/24) - **Done**
- Set 4
  25. [Break "random access read/write" AES CTR](http://cryptopals.com/sets/4/challenges/25) - **Done**
  26. [CTR bitflipping](http://cryptopals.com/sets/4/challenges/26) - **Done**
  27. [Recover the key from CBC with IV=Key](http://cryptopals.com/sets/4/challenges/27) - **Done**
  28. [Implement a SHA-1 keyed MAC](http://cryptopals.com/sets/4/challenges/28) - **Done**
  29. [Break a SHA-1 keyed MAC using length extension](http://cryptopals.com/sets/4/challenges/29) - **Done**
  30. [Break an MD4 keyed MAC using length extension](http://cryptopals.com/sets/4/challenges/30) - **Done**
  31. [Implement and break HMAC-SHA1 with an artificial timing leak](http://cryptopals.com/sets/4/challenges/31) - **Done**
  32. [Break HMAC-SHA1 with a slightly less artificial timing leak](http://cryptopals.com/sets/4/challenges/32) - *Probably done*
- Set 5
  33. [Implement Diffie-Hellman](http://cryptopals.com/sets/5/challenges/33) - In progress

All of the code here is 100% genuine own code, done by me. No looksees, copy & paste (unless that was a part of the exercise) etc. I might have looked up the theory of some topics in proper literature though (you should too, probably).

The challenges are now run by [Travis](https://travis-ci.org/drbig/matasano). Note that my code requires a *modern* Ruby - 2.1.5 should work, 1.9.3 and below probably wont.

There are also unit tests for the library (`rake test:unit:all`, but note that some are non-deterministic where a failure doesn't necessarily mean the code is wrong).

The general idea is to have the unit tests not depend on the challenges data inputs. This might not be exactly the case for now. (I've also noted that some of my `assert_equal`s are backwards, oh well, conventions...)

### Thoughts and notes

Ruby really kicks ass when it comes to hacking and *learning* new things. Go not so much, but I've learned that Unicode-centric approach is problematic for hacking ASCII-based crypto. I don't see any real speed difference between my Ruby code and my Go code.

I've deleted the Go sources as I'm not going to get back to them.

Having done the first four sets: this stuff is both amazingly eye-opening and scary at the same time. Are you seeding your PRNGs with current time (in NTP-synchronized world...)? Do you think SHA1(key || msg) is a secure way to do a MAC? Well, if so you're doing it very wrong, and that's just the tip of the proverbial iceberg.

### High-level spoilers

Note: last update around end of Set 2.

Reading code is one thing, knowing the right output is another. If you believe knowing the right outputs is *really* the thing that will help you *understand* what's going on have a looksee [here](https://github.com/drbig/matasano/blob/master/SPOILERS.txt). There are also some spoilerific/sanity-ensuring notes.

## Licensing

Licensed under [CC BY-NC-SA](http://creativecommons.org/licenses/by-nc-sa/4.0/), see LICENSE.txt for details.

Copyright (c) 2014 Piotr S. Staszewski
