package cryptopals

import (
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"math"
	"sort"
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
type englishSample struct {
	score float64
	text  string
	key   []byte
}

func (i englishSample) String() string {
	return fmt.Sprintf(`%f %v : "%s"`, i.score, i.key, i.text)
}

type ByScore []englishSample

func (xs ByScore) Len() int           { return len(xs) }
func (xs ByScore) Swap(i, j int)      { xs[i], xs[j] = xs[j], xs[i] }
func (xs ByScore) Less(i, j int) bool { return xs[i].score < xs[j].score }

// major vowels after:
// http://en.wikipedia.org/wiki/Letter_frequency#Relative_frequencies_of_letters_in_the_English_language
var englishFreqs = map[byte]float64{
	'e': 12.702,
	'a': 8.167,
	'o': 7.507,
	'i': 6.996,
	'u': 2.758,
}

func breakSimpleXOR(src string) ([]englishSample, error) {
	dst, err := hex.DecodeString(src)
	if err != nil {
		return nil, err
	}
	n := float64(len(dst))
	nf := len(englishFreqs)
	out := make([]englishSample, 0, 128)
	for k := byte(0); ; k++ {
		freqs := make(map[byte]float64, nf)
		for i, b := range dst {
			p := b ^ k
			dst[i] = p
			if _, ok := englishFreqs[p]; ok {
				freqs[p] += 1.0
			}
		}
		score := float64(0)
		for i, v := range freqs {
			score += (math.Abs(englishFreqs[i]-(v/n)) / englishFreqs[i]) / float64(nf)
		}
		if score >= 0.75 {
			out = append(out, englishSample{score, string(dst), []byte{k}})
		}
		if k == 255 {
			break
		}
	}
	sort.Sort(sort.Reverse(ByScore(out)))
	return out, nil
}
