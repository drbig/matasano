package cryptopals

import (
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"math"
	"sort"
	"strings"
	"unsafe"
)

func hexToBase64(src string) (string, error) {
	data, err := hex.DecodeString(src)
	if err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(data), nil
}

// fastXOR ripped out of src/crypto/cipher/xor.go
// works only on x86 and amd64
const wordSize = int(unsafe.Sizeof(uintptr(0)))

func fixedHexXOR(a, b string) (string, error) {
	ba, err := hex.DecodeString(a)
	if err != nil {
		return "", nil
	}
	bb, err := hex.DecodeString(b)
	if err != nil {
		return "", nil
	}

	n := len(ba)
	if len(bb) < n {
		n = len(bb)
	}
	dst := make([]byte, n)

	w := n / wordSize
	if w > 0 {
		dw := *(*[]uintptr)(unsafe.Pointer(&dst))
		aw := *(*[]uintptr)(unsafe.Pointer(&ba))
		bw := *(*[]uintptr)(unsafe.Pointer(&bb))
		for i := 0; i < w; i++ {
			dw[i] = aw[i] ^ bw[i]
		}
	}

	for i := (n - n%wordSize); i < n; i++ {
		dst[i] = ba[i] ^ bb[i]
	}

	return hex.EncodeToString(dst), nil
}

// following is for the first 'challenge'
// 1/3
// also used for 1/4
type englishSample struct {
	score float64
	text  string
	key   []byte
	rest  string
}

func (i englishSample) String() string {
	return fmt.Sprintf(`%f %v : "%s" rest: "%s"`, i.score, i.key, i.text, i.rest)
}

type ByScore []englishSample

func (xs ByScore) Len() int           { return len(xs) }
func (xs ByScore) Swap(i, j int)      { xs[i], xs[j] = xs[j], xs[i] }
func (xs ByScore) Less(i, j int) bool { return xs[i].score < xs[j].score }

// major vowels after:
// http://en.wikipedia.org/wiki/Letter_frequency#Relative_frequencies_of_letters_in_the_English_language
var englishFreqs = map[string]float64{
	"e": 12.702,
	"t": 9.056,
	"a": 8.167,
	"o": 7.507,
	"i": 6.996,
	"n": 6.749,
	"s": 6.327,
	"h": 6.094,
	"r": 5.987,
	"d": 4.253,
	"l": 4.025,
	"c": 2.782,
	"u": 2.758,
	"m": 2.406,
	"w": 2.360,
	"f": 2.228,
}

func breakSimpleXOR(src string, decode bool) ([]englishSample, error) {
	var bsrc []byte
	if decode {
		var err error
		bsrc, err = hex.DecodeString(src)
		if err != nil {
			return nil, err
		}
	} else {
		bsrc = []byte(src)
	}
	n := len(bsrc)
	nf := len(englishFreqs)
	fNf := float64(nf)
	dst := make([]byte, n)
	out := make([]englishSample, 0, 128)
	for k := byte(0); ; k++ {
		freqs := make(map[string]float64, nf)
		prnt := true
		seen := float64(0)
		for i, b := range bsrc {
			c := b ^ k
			if (c < 32) || (c > 126) {
				prnt = false
				break
			}
			dst[i] = c
			p := strings.ToLower(string(c))
			if _, ok := englishFreqs[p]; ok {
				freqs[p] += 1.0
				seen += 1
			}
		}
		if prnt {
			score := float64(0)
			for i, v := range freqs {
				score += (math.Abs(englishFreqs[i]-(v/seen)) / englishFreqs[i]) / fNf
			}
			out = append(out, englishSample{score, string(dst), []byte{k}, ""})
		}
		if k == 255 {
			break
		}
	}
	sort.Sort(sort.Reverse(ByScore(out)))
	return out, nil
}

// 1/5
// plain []byte
func repXOR(dst, src, key []byte) {
	n := len(key)
	for i, s := range src {
		dst[i] = s ^ key[i%n]
	}
}

// 1/6
// fun. below.

// hammer the Hamming distance!
func hammer(a, b []byte) int {
	if len(a) != len(b) {
		panic("broken hammer!!11!1!")
	}
	d := 0
	for i, x := range a {
		v := x ^ b[i]
		c := 0
		for ; v > 0; c++ {
			v &= v - 1
		}
		d += c
	}
	return d
}
