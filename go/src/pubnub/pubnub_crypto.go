package pubnub

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
)

func GetHmacSha256(secret_key string, input string) string {
	hmac_sha256 := hmac.New(sha256.New, []byte(secret_key))
	io.WriteString(hmac_sha256, input)
	return fmt.Sprintf("%x", hmac_sha256.Sum(nil))
}

func GenUUID() (string, error) {
	uuid := make([]byte, 16)
	n, err := rand.Read(uuid)
	if n != len(uuid) || err != nil {
		return "", err
	}
	// TODO: verify the two lines implement RFC 4122 correctly
	uuid[8] = 0x80 // variant bits see page 5
	uuid[4] = 0x40 // version 4 Pseudo Random, see page 7

	return hex.EncodeToString(uuid), nil
}
