package cryptopals

import (
	//"bufio"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"io/ioutil"
	"os"
	//"sort"
	"testing"
)

type caseHexToBase64 struct {
	in, out string
}

func TestHexToBase64(t *testing.T) {
	cases := []caseHexToBase64{
		caseHexToBase64{"49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d", "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"},
		caseHexToBase64{"1234", "EjQ="},
		caseHexToBase64{"ffff", "//8="},
		caseHexToBase64{"deadbeef", "3q2+7w=="},
	}

	for i, c := range cases {
		o, err := hexToBase64(c.in)
		if err != nil {
			t.Errorf("(%d) Error: %s", i+1, err)
			continue
		}
		if o != c.out {
			t.Errorf("(%d) Mismatch: %s != %s", i+1, c.out, o)
		}
	}
}

type caseFixedHexXOR struct {
	a, b, out string
}

func TestFixedHexXOR(t *testing.T) {
	cases := []caseFixedHexXOR{
		caseFixedHexXOR{"1c0111001f010100061a024b53535009181c", "686974207468652062756c6c277320657965", "746865206b696420646f6e277420706c6179"},
	}

	for i, c := range cases {
		o, err := fixedHexXOR(c.a, c.b)
		if err != nil {
			t.Errorf("(%d) Error: %s", i+1, err)
			continue
		}
		if o != c.out {
			t.Errorf("(%d) Mismatch: %s != %s", i+1, c.out, o)
		}
	}
}

type caseBreakSimpleXOR struct {
	in string
	n  int
}

func TestBreakSimpleXOR(t *testing.T) {
	cases := []caseBreakSimpleXOR{
		caseBreakSimpleXOR{"1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736", 3},
	}

	for i, c := range cases {
		o, err := breakSimpleXOR(c.in, true)
		if err != nil {
			t.Errorf("(%d) Error: %s", i+1, err)
			continue
		}
		t.Logf("Case %d", i+1)
		n := c.n
		if len(o) < n {
			n = len(o)
		}
		for j := 0; j < n; j++ {
			t.Logf("(%d) %s", i+1, o[j])
		}
	}
}

/*
func TestMultiSimpleXOR(t *testing.T) {
	f, err := os.Open("data/1-4.txt")
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()
	cands := make([]englishSample, 0, 128)
	scn := bufio.NewScanner(f)
	i := 1
	for scn.Scan() {
		txt := scn.Text()
		o, err := breakSimpleXOR(txt, true)
		if err != nil {
			t.Errorf("(%d) Error: %s", i, err)
			continue
		} else {
			for j, s := range o {
				if s.score < 0.60 {
					break
				}
				s.rest = fmt.Sprintf("line: %d", j+1)
				cands = append(cands, s)
			}
		}
		i++
	}
	sort.Sort(sort.Reverse(ByScore(cands)))
	for i, c := range cands {
		t.Logf("(%d) %s", i+1, c)
	}
}
*/

type caseRepXOR struct {
	in, key []byte
	out     string
}

func TestRepXOR(t *testing.T) {
	cases := []caseRepXOR{
		caseRepXOR{[]byte("Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"), []byte("ICE"), "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"},
	}

	for i, c := range cases {
		dst := make([]byte, len(c.in))
		repXOR(dst, c.in, c.key)
		o := hex.EncodeToString(dst)
		if o != c.out {
			t.Errorf("(%d) Mismatch: %s != %s", i+1, c.out, o)
		}
	}
}

// 1/6
// hammer time
type caseNail struct {
	a, b []byte
	d    int
}

func TestHammer(t *testing.T) {
	cases := []caseNail{
		caseNail{[]byte{0}, []byte{1}, 1},
		caseNail{[]byte{0}, []byte{2}, 1},
		caseNail{[]byte{0}, []byte{3}, 2},
		caseNail{[]byte("this is a test"), []byte("wokka wokka!!!"), 37},
	}
	for i, c := range cases {
		d := hammer(c.a, c.b)
		if d != c.d {
			t.Errorf("(%d) Mismatch: %d != %d", i+1, c.d, d)
		}
	}
}

// abuse tastes!
type caseKSG_S struct {
	in, key []byte
}

type caseKSG_O struct {
	cipher []byte
	n      int
}

func TestKSG(t *testing.T) {
	cin := []caseKSG_S{
		caseKSG_S{[]byte("A double-blind trial is one where neither the subject nor the testers know who has recieved treatment, and who is in the control group. It is vital that there are no clues available to distinguish between the different groups, either for the subjects or the testers. In a clinical drugs trial for example, it would not be suitable for some people to be given blue pills and others red pills, so an identical placebo pill should be used, typically a sugar pill with no medical value."), []byte("lolapalooza")},
		caseKSG_S{[]byte("Scientific research involving humans is extremely challenging to conduct because of the difficulty in finding appropriate control groups. This is one of the reasons animal experiments (for instance involving inbred strains of mice) are so common."), []byte("this is a test")},
		caseKSG_S{[]byte("In research, a blind trial is an experiment where certain information about the test is concealed from the subjects and/or the testers, in order to reduce sources of bias in the results. A scientific approach requires the use of control groups to determine the significance of observations in (clinical) trials. The members of the control group receive either no treatment or the standard treatment."), []byte("ice ice baby")},
		caseKSG_S{[]byte("For each block, the single-byte XOR key that produces the best looking histogram is the repeating-key XOR key byte for that block. Put them together and you have the key.This code is going to turn out to be surprisingly useful later on. Breaking repeating-key XOR (Vigenere) statistically is obviously an academic exercise, a Crypto 101 thing. But more people to break it than can actually break it, and a similar technique breaks something much more important."), []byte("another ugly test")},
		caseKSG_S{[]byte("The overall comic is an allusion to horsepower, a similar-sounding but completely different concept. Horsepower is a measurement of power (work per unit time). Another commonly referenced unit for power is the watt. 1 horsepower is meant to be approximately the amount of power a horse can deliver. In contrast, Randall uses the horse to measure mass (of spacecraft themselves, and of the payload they carry)."), []byte("another ugly test")},
		caseKSG_S{[]byte("The top pane of the comic shows the mass of various spacecraft, while the bottom shows the amount of mass which various rockets can deliver to low Earth orbit. There are also several joke insertions. In the top, one is T-Rex. In the bottom, another is Pegasus (the payload capacity given as one Pegasus); this is a reference to both Pegasus the rocket and Pegasus the mythical flying stallion. Atlas-Centaur is also measured in centaurs, a reference to the half-human half-horse creatures of Greek mythology. The bottom also gives the 1981 Oldsmobile as 4 horses; this references the carrying capacity (by weight) of the Oldsmobile, not the ability of an Oldsmobile to launch that payload into low Earth orbit."), []byte("another ugly test")},
	}
	cout := make([]caseKSG_O, 0, len(cin))
	t.Logf("Generating inputs")
	for i, c := range cin {
		t.Logf("(%d) \"%s\"@\"%s\"", i+1, c.in, c.key)
		dst := make([]byte, len(c.in))
		repXOR(dst, c.in, c.key)
		cout = append(cout, caseKSG_O{dst, len(c.key)})
	}
	t.Logf("Testing sampled keys")
	for i, c := range cout {
		t.Logf("(%d) Real key length: %d", i+1, c.n)
		for j, k := range bestKSG(c.cipher, 3, 40) {
			t.Logf("(%d) %d. Key: %s", i+1, j+1, k)
			if j > 1 {
				break
			}
		}
	}
}

var buff []byte

func TestLoadData(t *testing.T) {
	f, err := os.Open("data/1-6.txt")
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()
	dec := base64.NewDecoder(base64.StdEncoding, f)
	buff, err = ioutil.ReadAll(dec)
	if err != nil {
		t.Fatal(err)
	}
	t.Logf("Loaded %d bytes.", len(buff))
}

var keys []keySample

func TestRealKSG(t *testing.T) {
	keys = bestKSG(buff, 2, 40)
	for j, k := range keys {
		t.Logf("%d. Key: %s", j+1, k)
	}
}

/*
func TestRealBreak(t *testing.T) {
	keylen := 29
	//for _, k := range keys {
	//keylen := k.size
	t.Logf("Testing for KEYLEN %d", keylen)
	blocks := make([][]byte, 0, 32)
	t.Log("Making blocks...")
	for x := 0; x < len(buff); x += keylen {
		blk := make([]byte, 0, keylen)
		for j := 0; j < keylen; j++ {
			if x+j >= len(buff) {
				break
			}
			blk = append(blk, buff[x+j])
		}
		blocks = append(blocks, blk)
	}
	t.Logf("Made %d blocks", len(blocks))
	buckets := make([][]byte, 0, keylen)
	t.Log("Transposing blocks...")
	for x := 0; x < keylen; x++ {
		bkt := make([]byte, 0, 256)
		for _, b := range blocks {
			if x >= len(b) {
				break
			}
			bkt = append(bkt, b[x])
		}
		buckets = append(buckets, bkt)
	}
	t.Log("Got buckets:")
	for i, b := range buckets {
		t.Logf("%d - %d", i, len(b))
	}
	t.Log("Running simple XOR break...")
	keyy := make([]byte, keylen)
	for x := 0; x < keylen; x++ {
		o, err := breakSimpleXOR(string(buckets[x]), false)
		if err != nil {
			t.Fatal(err)
		}
		if len(o) < 2 {
			t.Logf("%d - Nothing found?", x)
		} else {
			t.Logf("%d - %f %s", x, o[1].score, o[1].key)
			keyy[x] = o[1].key[0]
		}
	}
	t.Logf("KEY: \"%s\"", string(keyy))
	//	}
}

*/
func TestDupa(t *testing.T) {
	dst := make([]byte, len(buff))
	repXOR(dst, buff, []byte("Terminator X: Bring the noise"))
	fmt.Printf("%s", string(dst))
}
