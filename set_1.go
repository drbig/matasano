package cryptopals

import (
	"encoding/base64"
	"encoding/hex"
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
