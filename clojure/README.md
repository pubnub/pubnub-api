# clj-pubnub

Original Author: [DOO.net](https://github.com/doo/clj-pubnub).

Clojure client for [PubNub](http://www.pubnub.com/).

## Usage

### Publishing

```clojure
;; The client should always be required with an alias
(require '[clj-pubnub.client :as pubnub])

;; Configuration can be passed directly
(pubnub/publish {:pub-key "demo" :sub-key "demo"} "my_channel" {:hello "world"})

;; ... or through a binding
(binding [pubnub/config {:pub-key "demo" :sub-key "demo"}]
  (pubnub/publish "my_channel" {:hello "world"}))

;; ... or by setting it globally
(pubnub/set-config! {:pub-key "demo" :sub-key "demo"})
(pubnub/publish "my_channel" {:hello "world"})

;; SSL and signing is also supported
(pubnub/publish {:pub-key "demo"
                 :sub-key "demo"
                 :secret-key "demo"
                 :ssl true}
                "my_channel"
                {:hello "world"})
```

## License

Copyright (C) 2012 Moritz Heidkamp, doo GmbH

Distributed under the Eclipse Public License, the same as Clojure.
