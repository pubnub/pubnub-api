package pubnub

import (
	"fmt"
	"testing"
)

var _plain_string = "\"Pubnub Messaging API 1\""
var _plain_string_base64 = "IlB1Ym51YiBNZXNzYWdpbmcgQVBJIDEi"
var _plain_string_aes_256_cbc = "f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0="
var _chipher_key = "enigma"
var _chipher_key_encrypt_string = "3637613466343566306431643962633630363438366663343264633439343136"

func TestUUID(t *testing.T) {
	uuid, err := GenUUID()
	if err != nil {
		t.Fatalf("GenUUID error %s", err)
	}
	t.Logf("uuid[%s]\n", uuid)
}

func BenchmarkUUID(b *testing.B) {
	m := make(map[string]int, 1000)
	for i := 0; i < b.N; i++ {
		uuid, err := GenUUID()
		if err != nil {
			b.Fatalf("GenUUID error %s", err)
		}
		b.StopTimer()
		c := m[uuid]
		if c > 0 {
			b.Fatalf("duplicate uuid[%s] count %d", uuid, c)
		}
		m[uuid] = c + 1
		b.StartTimer()
	}
}

func TestPkcs5pad(t *testing.T) {
	//If len less then 16
	test_value := []byte("test")
	test_value = Pkcs5pad(test_value, 16)
	if len(test_value) != 16 {
		t.Fatalf("Padding error when message less than 16 bytes")
	}

	//If len larger or equal 16
	test_value = []byte(_plain_string)
	test_value = Pkcs5pad(test_value, 16)
	if len(test_value) != 32 {
		t.Fatalf("Padding error when message larger than 16 bytes")
	}

	test_value = []byte("0123456789012345")
	test_value = Pkcs5pad(test_value, 16)
	if len(test_value) != 32 {
		t.Fatalf("Padding error when message equal 16 bytes")
	}
}

func TestPkcs5unpad(t *testing.T) {
	//If len less then 16 should
	test_value := []byte("test")
	value_len := len(test_value)
	test_value = Pkcs5pad(test_value, 16)
	test_value = Pkcs5unpad(test_value)
	if len(test_value) != value_len {
		t.Fatalf("Unpadding error when message less than 16 bytes")
	}

	//If len larger or equal 16
	test_value = []byte(_plain_string)
	value_len = len(test_value)
	test_value = Pkcs5pad(test_value, 16)
	test_value = Pkcs5unpad(test_value)
	if len(test_value) != value_len {
		t.Fatalf("Unpadding error when message larger than 16 bytes")
	}

	test_value = []byte("0123456789012345")
	value_len = len(test_value)
	test_value = Pkcs5pad(test_value, 16)
	test_value = Pkcs5unpad(test_value)
	if len(test_value) != value_len {
		t.Fatalf("Unpadding error when message equal 16 bytes")
	}
}

func TestEncode(t *testing.T) {
	test_value := encode([]byte(_plain_string))
	if fmt.Sprintf("%s", test_value) != _plain_string_base64 {
		t.Fatalf("Encode error,  %s", test_value)
	}
}

func TestDecode(t *testing.T) {
	test_value, _ := decode([]byte(_plain_string_base64))
	if fmt.Sprintf("%s", test_value) != _plain_string {
		t.Fatalf("Decode error, %s", test_value)
	}
}

func TestEncryptCipherKey(t *testing.T) {
	test_value := fmt.Sprintf("%x", encryptCipherKey(_chipher_key))
	if test_value != _chipher_key_encrypt_string {
		t.Fatalf("Encrypt cipher key error,  %x", test_value)
	}
}

func TestEncryptString(t *testing.T) {
	test_value := EncryptString(_chipher_key, _plain_string)
	if test_value != _plain_string_aes_256_cbc {
		t.Fatalf("Encrypt string error, %s", test_value)
	}
}

func TestDecryptString(t *testing.T) {
	test_value := DecryptString(_chipher_key, _plain_string_aes_256_cbc)
	if test_value != _plain_string {
		t.Fatalf("Decrypt string error, %s", test_value)
	}
}
