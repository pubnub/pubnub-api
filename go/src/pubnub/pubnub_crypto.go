package pubnub

import (
	"crypto/hmac"
	"crypto/sha256"
	"fmt"
	"io"
)

func GetHmacSha256(secret_key string, input string) string {
	hmac_sha256 := hmac.New(sha256.New, []byte(secret_key))
	io.WriteString(hmac_sha256, input)
	return fmt.Sprintf("%x", hmac_sha256.Sum(nil))
}
