package pubnub

import (
	"testing"
)

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
