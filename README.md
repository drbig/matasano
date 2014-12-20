# matasano

Sharing my progress and solutions to the [the matasano crypto challenges](http://cryptopals.com/). Obviously, this is one big **spoiler**. You have been warned.

Current status: **fun in progress**

- Set 1
  1. [Convert hex to base64](http://cryptopals.com/sets/1/challenges/1) - **Done**
  2. [Fixed XOR](http://cryptopals.com/sets/1/challenges/2) - **Done**
  3. [Single-byte XOR cipher](http://cryptopals.com/sets/1/challenges/3) - **Done**
  4. [Detect single-character XOR](http://cryptopals.com/sets/1/challenges/4) - **Done**
  5. [Implement repeating-key XOR](http://cryptopals.com/sets/1/challenges/5) - **Done**
  6. [Break repeating-key XOR](http://cryptopals.com/sets/1/challenges/6) - **Done**
  7. [AES in ECB mode](http://cryptopals.com/sets/1/challenges/7) - **Done**
  8. [Detect AES in ECB mode](http://cryptopals.com/sets/1/challenges/8) - *Probably done*
- Set 2
  9. [Implement PKCS#7 padding](http://cryptopals.com/sets/2/challenges/9) - **Done**
  10. [Implement CBC mode](http://cryptopals.com/sets/2/challenges/10) - **Done**
  11. [An ECB/CBC detection oracle](http://cryptopals.com/sets/2/challenges/11) - WIP

*All hacking is done in Ruby, in a single file*. I prefer this free-form style where I mix my functions and test snippets, commenting stuff in and out. I plan to separate the functions and test cases into some sane file hierarchy once I feel I'm done with the challenges themselves. I'm even tempted to wrap it all as a test suite or Rakefile.

All of the code here is 100% genuine own code, done by me. No looksees, copy & paste etc. I might have looked up the theory of some topics in proper literature though (you should too, probably).

### Thoughts and notes

Ruby really kicks ass when it comes to hacking and *learning* new things. Go not so much, but I've learned that Unicode-centric approach is problematic for hacking ASCII-based crypto. I don't see any real speed difference between my Ruby code and my Go code.

### High-level spoilers

Reading code is one thing, knowing the right output is another. If you believe knowing the right outputs is *really* the thing that will help you *understand* what's going on have a looksee [here](https://github.com/drbig/matasano/blob/master/SPOILERS.txt). There are also some spoilerific/sanity-ensuring notes.

## Licensing

Licensed under [CC BY-NC-SA](http://creativecommons.org/licenses/by-nc-sa/4.0/), see LICENSE.txt for details.

Copyright (c) 2014 Piotr S. Staszewski
