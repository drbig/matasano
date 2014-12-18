package cryptopals

import (
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
