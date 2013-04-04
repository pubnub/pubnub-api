package pubnubMessaging

import (
    "crypto/aes"
    "crypto/cipher"
    "crypto/hmac"
    "crypto/rand"
    "crypto/sha256"
    "encoding/base64"
    "encoding/hex"
    "fmt"
    "io"
)

var _IV = "0123456789012345"

func GetHmacSha256(secretKey string, input string) string {
    hmacSha256 := hmac.New(sha256.New, []byte(secretKey))
    io.WriteString(hmacSha256, input)
    return fmt.Sprintf("%x", hmacSha256.Sum(nil))
}

func GenUuid() (string, error) {
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

func Pkcs5pad(data []byte, blocksize int) []byte {
    pad := blocksize - len(data)%blocksize
    b := make([]byte, pad, pad)
    for i := 0; i < pad; i++ {
        b[i] = uint8(pad)
    }
    return append(data, b...)
}

func Pkcs5unpad(data []byte) []byte {
    if len(data) == 0 {
        return data
    }
    pad := int(data[len(data)-1])
    return data[0 : len(data)-pad]
}

func EncryptString(cipherKey string, message string) string {
    block, _ := AesCipher(cipherKey)

    value := []byte(message)
    value = Pkcs5pad(value, aes.BlockSize)

    blockmode := cipher.NewCBCEncrypter(block, []byte(_IV))
    cipherBytes := make([]byte, len(value))
    blockmode.CryptBlocks(cipherBytes, value)

    return fmt.Sprintf("%s", Encode(cipherBytes))
}

func DecryptString(cipherKey string, message string) string { //need add error catching
    block, _ := AesCipher(cipherKey)
    value, _ := Decode([]byte(message))

    decrypter := cipher.NewCBCDecrypter(block, []byte(_IV))
    decrypted := make([]byte, len(value))
    decrypter.CryptBlocks(decrypted, value)

    return fmt.Sprintf("%s", Pkcs5unpad(decrypted))
}

func AesCipher(cipherKey string) (cipher.Block, error) {
    block, err := aes.NewCipher(EncryptCipherKey(cipherKey))
    if err != nil {
        return nil, err
    }
    return block, nil
}

func EncryptCipherKey(cipherKey string) []byte {
    hash := sha256.New()
    hash.Write([]byte(cipherKey))

    sha256String := hash.Sum(nil)[:16]
    return []byte(hex.EncodeToString(sha256String))
}

//Encodes a value using base64
func Encode(value []byte) []byte {
    encoded := make([]byte, base64.StdEncoding.EncodedLen(len(value)))
    base64.StdEncoding.Encode(encoded, value)
    return encoded
}

//Decodes a value using base64 
func Decode(value []byte) ([]byte, error) {
    decoded := make([]byte, base64.StdEncoding.DecodedLen(len(value)))
    b, err := base64.StdEncoding.Decode(decoded, value)
    if err != nil {
        return nil, err
    }
    return decoded[:b], nil
}
