package cryptopals

import (
	"bufio"
	"encoding/hex"
	"fmt"
	"os"
	"sort"
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
