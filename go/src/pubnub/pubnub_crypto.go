package pubnub

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/hmac"
	"crypto/md5"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"io"
)

var _IV = []byte{0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05}

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

func EncryptString(chipher_key string, message string) string {
	block, _ := aes_cipher(chipher_key)

	value := []byte(message)

	stream := cipher.NewCTR(block, _IV)
	stream.XORKeyStream(value, value)

	return fmt.Sprintf("%s", encode(value))
}

func DecryptString(chipher_key string, message string) string { //need add error catching
	block, _ := aes_cipher(chipher_key)
	value, _ := decode([]byte(message))

	stream := cipher.NewCTR(block, _IV)
	stream.XORKeyStream(value, value)

	return fmt.Sprintf("%s", value)
}

func aes_cipher(chipher_key string) (cipher.Block, error) {
	hash := md5.New()
	io.WriteString(hash, chipher_key)
	block, err := aes.NewCipher(hash.Sum(nil))
	if err != nil {
		return nil, err
	}
	return block, nil
}

//Encodes a value using base64
func encode(value []byte) []byte {
	encoded := make([]byte, base64.StdEncoding.EncodedLen(len(value)))
	base64.StdEncoding.Encode(encoded, value)
	return encoded
}

//Decodes a value using base64 
func decode(value []byte) ([]byte, error) {
	decoded := make([]byte, base64.StdEncoding.DecodedLen(len(value)))
	b, err := base64.StdEncoding.Decode(decoded, value)
	if err != nil {
		return nil, err
	}
	return decoded[:b], nil
}
