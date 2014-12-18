package cryptopals

import (
	"encoding/base64"
	"encoding/hex"
)

func hexToBase64(src string) (string, error) {
	data, err := hex.DecodeString(src)
	if err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(data), nil
}
