(ns clj-pubnub.client
  (:use [digest :only [digest]])
  (:require [clj-http.client :as http]
            [cheshire.core :as json]
            [clojure.contrib.string :as str]))

(defonce ^{:dynamic true} config
  {})

(defn set-config! [settings]
  (alter-var-root (var config) (constantly settings)))

(def default-origin
  "pubsub.pubnub.com")

(defn- sign [channel message pub-key sub-key secret-key]
  (if secret-key
    (->> [pub-key sub-key secret-key channel]
         (str/join "/")
         (digest "md5"))
    "0"))

;; What a terrible hack ... gotta love the Java API
(defn- encode-path-segment [segment]
  (-> (java.net.URI. nil nil (str "/" segment) nil)
      (str)
      (.substring 1)))

(defn- build-publish-uri [config channel message]
  (let [message (json/generate-string message)
        {:keys [pub-key sub-key secret-key origin ssl]} config]
    (str (if ssl "https" "http") "://"
         (->> [(or origin default-origin)
               "publish"
               pub-key
               sub-key
               (sign channel message pub-key sub-key secret-key)
               channel
               "0"
               message]
              (map encode-path-segment)
              (str/join "/")))))

(defn publish
  ([channel message]
     (publish config channel message))
  ([config channel message]
     ({:pre [(string? channel)
             (every? config [:pub-key :sub-key])]}
      (let [uri (build-publish-uri config channel message)]
        (println uri)
        (http/get uri)))))