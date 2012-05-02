/*
 * Pubnub.h
 */
#ifndef PUBNUB_H_
#define PUBNUB_H_

#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>

#include <openssl/engine.h>
#include <openssl/hmac.h>
#include <openssl/evp.h>
#include <openssl/rand.h>

#include <event2/event.h>
#include <event2/buffer.h>
#include <event2/http.h>
#include <event2/http_struct.h>

#include "json.h"

//Constant declarations
#define _LIMIT 1800;
#define _ORIGIN "pubsub.pubnub.com";

//Type definitions for char * and true/false for SSL
typedef char * string;
typedef enum {true=1,false=0} bool;

typedef enum object_type {
  String=1,
  Array=2,
  JSON_Object=3
}object_type;


/**
 * Structure for publish message
 *
 * @param string channel.
 * @param string message.it may be string or json_object
 * @param void (* cb)(json_object *). //callback
 */

typedef struct struct_publish {
	string channel;
	void* message;
	void (* cb)(json_object *);
	enum object_type type;
}struct_publish;

/**
 * Structure for subscribe message
 *
 * @param string channel.
 * @param void (* cb)(json_object *). //callback
 */

typedef struct struct_subscribe {
	string  channel;
	void (* cb)(json_object *);
}struct_subscribe;


/**
 * Structure for history
 *
 * @param string channel.
 * @param int limit.
 * @param void (* cb)(json_object *). //callback
 */

typedef struct struct_history {
	char* channel;
	int limit;
	void (*cb)(json_object *);
}struct_history;

/**
 * Structure for contex
 *
 * @param struct evhttp_uri *uri;
 * @param struct event_base *base.
 * @param struct evhttp_connection *cn.
 * @param struct evhttp_request *req.
 * @param struct evbuffer *buffer.
 * @param int ok.
 */
typedef struct request_context {
	struct evhttp_uri *uri;
	struct event_base *base;
	struct evhttp_connection *cn;
	struct evhttp_request *req;
	struct evbuffer *buffer;
	int ok;
}request_context;

/**
 * Structure to share cipher_key
 * With cipher_key (plaintext)
 *
 * @param string Publish Key.
 * @param string Subscribe Key.
 * @param string Secret Key.
 * @param string Cipher Key.
 * @param bool SSL Enabled.
 */

typedef struct Pubnub {
	string ORIGIN;
	string PUBLISH_KEY;
	string SUBSCRIBE_KEY;
	string SECRET_KEY;
	string  CIPHER_KEY;
	int LIMIT;
	bool SSL;
}PUBNUB;

// Method declarations
void Pubnub_overload1 (string publish_key,string subscribe_key,string secret_key,string  cipher_key,bool ssl_on);
void Pubnub_overload2 (string publish_key,string subscribe_key,string secret_key,bool ssl_on);
void Pubnub_overload3 (string publish_key,string subscribe_key,string secret_key );
void Pubnub_overload4 (string publish_key,string subscribe_key);
void publish (struct_publish *);
void subscribe (struct_subscribe *);
void history (struct_history *);
double getTime ();
string uuid ();

#endif
