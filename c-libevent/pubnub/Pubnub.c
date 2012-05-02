#include "Pubnub.h"

PUBNUB pubnub;
string timeToken = "0";
char random[32];

/* Function prototypes */
void init(string, string, string, string, bool);
void _requestPublish(string * url_components, int size,void (*callback1)(json_object *));
void _requestHistory(string * url_components, int size);
void _requestSubcribe(string * url_components, int size);
double _requestTime(string * url_components, int size);
string strconcat(string, string);
string getHMacSHA256(string, string);
void encode(unsigned char *, char *, char *);
void encodeURL(char[], char[]);

// Callback function
static void _commonCallback(struct evhttp_request *req, void *arg);
void (*callback)(json_object *);

/* Added overloaded method to share cipher_key with cipher_key (plaintext)
 *
 * @param string Publish Key.
 * @param String Subscribe Key.
 * @param string Secret Key.
 * @param string Cipher Key.
 * @param bool SSL Enabled.
 */
void Pubnub_overload1(string publish_key, string subscribe_key, string secret_key, string cipher_key, bool ssl_on) {
	init(publish_key, subscribe_key, secret_key, cipher_key, ssl_on);
}

/**
 * PubNub 3.0
 *
 * Prepare PubNub Class State.
 *
 * @param String Publish Key.
 * @param String Subscribe Key.
 * @param String Secret Key.
 * @param bool SSL Enabled.
 */
void Pubnub_overload2(string publish_key, string subscribe_key, string secret_key, bool ssl_on) {
	init(publish_key, subscribe_key, secret_key, "", ssl_on);
}

/**
 * PubNub 3.0 without SSL
 *
 * Prepare PubNub Class State.
 *
 * @param string Publish Key.
 * @param string Subscribe Key.
 * @param string Secret Key.
 */
void Pubnub_overload3(string publish_key, string subscribe_key, string secret_key) {
	init(publish_key, subscribe_key, secret_key, "", 0);
}

/**
 * PubNub 2.0 Compatibility
 *
 * Prepare PubNub Class State.
 *
 * @param string Publish Key.
 * @param string Subscribe Key.
 */
void Pubnub_overload4(string publish_key, string subscribe_key) {
	init(publish_key, subscribe_key, "", "", false);
}
/**
 * Init
 *
 * Prepare PubNub Class State.
 *
 * @param string Publish Key.
 * @param string Subscribe Key.
 * @param string Secret Key.
 * @param string Cipher Key.
 * @param bool SSL Enabled.
 */
void init(string publish_key, string subscribe_key, string secret_key, string cipher_key, bool ssl_on) {
	string abc;
	size_t old_size;
	pubnub.LIMIT = _LIMIT;
	pubnub.ORIGIN = _ORIGIN;
	pubnub.PUBLISH_KEY = publish_key;
	pubnub.SUBSCRIBE_KEY = subscribe_key;
	pubnub.SECRET_KEY = secret_key;
	pubnub.CIPHER_KEY = cipher_key;
	pubnub.SSL = ssl_on;

	// SSL On?
	if (pubnub.SSL) {
		abc = strconcat("https://", pubnub.ORIGIN);
	} else {
		abc = strconcat("http://", pubnub.ORIGIN);
	}

	old_size = strlen(abc);
	pubnub.ORIGIN = malloc(old_size + 1);
	strcpy(pubnub.ORIGIN, abc);
}

/**
 * Common_callback (static function)
 *
 * @param struct evhttp_request *req.
 * @param  void *arg.
 */
static void _commonCallback(struct evhttp_request *req, void *arg) {
	struct request_context *ctx = (struct request_context *) arg;
	struct evhttp_uri *new_uri = NULL;
	const char *new_location = NULL;

	if(req==NULL)
	{
		event_base_loopexit(ctx->base, 0);
		return;
	}

	// Response is ready
	switch (req->response_code) {
	case HTTP_OK:
		// Response received.
		event_base_loopexit(ctx->base, 0);
		break;

	case HTTP_MOVEPERM:
	case HTTP_MOVETEMP:
		new_location = evhttp_find_header(req->input_headers, "Location");
		if (!new_location)
			return;

		new_uri = evhttp_uri_parse(new_location);
		if (!new_uri)
			return;

		evhttp_uri_free(ctx->uri);
		ctx->uri = new_uri;
		return;

	default:
		// FAILURE
		event_base_loopexit(ctx->base, 0);
		return;
	}

	evbuffer_add_buffer(ctx->buffer, req->input_buffer);
	ctx->ok = 1;
}

void strip(char *s) {
	char *p2 = s;
	while(*s != '\0') {
		if(*s != '\t' && *s != '\n' && *s != '\\') {
			*p2++ = *s++;
		} else {
			++s;
		}
	}
	*p2 = '\0';
}

/**
 * Publish
 *
 * Send a message to a channel.
 *
 * @param struct struct_publish *args.
 */
void publish(struct struct_publish *args) {
	//callback = args->cb;
	string signature = "0";
	string url[7];
	string msg;
	if (args->type == 1) {
		if (strlen(pubnub.CIPHER_KEY) > 0) {
			char* string1=encryptString(pubnub.CIPHER_KEY,args->message);
			json_object *obj=json_object_new_string(string1);
			char* temp = json_object_get_string(obj);
			msg=strconcat("\"",temp);
			msg=strconcat(msg,"\"");
		}else{
			msg = json_object_get_string(json_object_new_string(args->message));
			msg=strconcat("\"",msg);
			msg=strconcat(msg,"\"");
		}
	} else if (args->type == 2) {
		if (strlen(pubnub.CIPHER_KEY) > 0) {
			json_object *obj =encryptJSONArray(pubnub.CIPHER_KEY,args->message);
			msg = json_object_get_string(obj);
		}else{
			msg = json_object_get_string(args->message);
		}
	} else if (args->type == 3) {
		if (strlen(pubnub.CIPHER_KEY) > 0) {
			json_object *obj =encryptJSONObject(pubnub.CIPHER_KEY,args->message);
			msg = json_object_get_string(obj);
		}else{
			msg = json_object_get_string(args->message);
		}
	}

	if (strlen(pubnub.SECRET_KEY) > 0) {
		// Generate String to Sign
		string string_to_sign;
		string_to_sign = strconcat(pubnub.PUBLISH_KEY, "/");
		string_to_sign = strconcat(string_to_sign, pubnub.SUBSCRIBE_KEY);
		string_to_sign = strconcat(string_to_sign, "/");
		string_to_sign = strconcat(string_to_sign, pubnub.SECRET_KEY);
		string_to_sign = strconcat(string_to_sign, "/");
		string_to_sign = strconcat(string_to_sign, args->channel);
		string_to_sign = strconcat(string_to_sign, "/");
		string_to_sign = strconcat(string_to_sign, msg);
		signature = getHMacSHA256(pubnub.SECRET_KEY, string_to_sign);
	}

	url[0] = "publish";
	url[1] = pubnub.PUBLISH_KEY;
	url[2] = pubnub.SUBSCRIBE_KEY;
	url[3] = signature;
	url[4] = args->channel;
	url[5] = "0";
	url[6] = msg;

	_requestPublish(url, 7,args->cb);
}

/**
 * Subscribe
 *
 * Listen for a message on a channel.
 *
 * @param struct struct_subscribe *args.
 */
void subscribe(struct struct_subscribe *args) {
	callback = args->cb;
	string url[5];
	int j = 5;
	while (1) {
		j--;
		url[0] = "\subscribe";
		url[1] = pubnub.SUBSCRIBE_KEY;
		url[2] = args->channel;
		url[3] = "0";
		url[4] = timeToken;

		// Wait for Message
		_requestSubcribe(url, 5);
	}
}
/**
 * History
 *
 * Load history from a channel.
 *
 * @param struct struct_history *args.
 */
void history(struct struct_history * args) {
	callback = args->cb;
	string url[5];
	url[0] = "history";
	url[1] = pubnub.SUBSCRIBE_KEY;
	url[2] = args->channel;
	url[3] = "0";
	char str[33];
	itoa(args->limit, str, 10);
	url[4] = str;
	return _requestHistory(url, 5);
}

/**
 * Time
 *
 * Timestamp from PubNub Cloud.
 *
 * @return double timestamp.
 */
double getTime() {
	string url[2];
	url[0] = "time";
	url[1] = "0";
	return _requestTime(url, 2);
}

/**
 * UUID
 *
 * 32 digit UUID generation at client side.
 *
 * @return string  uuid.
 */
string uuid() {
	int count;
	unsigned short int length = 32;
	srand((unsigned int) time(0));
	count = 0;
	for (count = 0; count < length;) {
		random[count] = (rand() % 26) + 97;
		random[++count] = (rand() % 10) + 48;
		random[++count] = (rand() % 26) + 65;
		srand(rand());
	}
	random[length - 1] = '\0';
	return random;
}

/**
 * _requestPublish
 *
 * @param string* url_components.
 * @param int size.
 */
void _requestPublish(string * url_components, int size,void (*callback1)(json_object *)) {
	string url;
	int i;
	url = "/";
	for (i = 0; i < size; i++) {
		char url2[strlen(url_components[i]) + 1];
		strcpy(url2, url_components[i]);
		url2[strlen(url_components[i])]='\0';
		char enc[sizeof(url2) * 3];
		encodeURL(url2,enc);
		const char*r=enc;
		url = strconcat(url,r);
		if(i != size-1)
			url=strconcat(url,"/");
	}
	struct evbuffer *data = request_url(pubnub.ORIGIN, 80, url, _commonCallback);

	if (data) {
		const char *joined1 = evbuffer_pullup(data, -1);

		json_object * obj = json_tokener_parse(joined1);

		if (callback1 != NULL)
		{
			callback1(json_object_get(obj));
		}
		evbuffer_free(data);

	}
}

/**
 * _requestSubcribe
 *
 * @param string* url_components.
 * @param int size.
 */
void _requestSubcribe(string * url_components, int size) {
	string url;
	int i;
	url = "/";
	for (i = 0; i < size; i++) {
		char url2[strlen(url_components[i]) + 1];
		strcpy(url2, url_components[i]);
		url2[strlen(url_components[i])]='\0';
		char enc[sizeof(url2) * 3];
		encodeURL(url2,enc);
		const char* r=enc;
		url = strconcat(url,r);
		if(i != size-1)
			url=strconcat(url,"/");
	}

	struct evbuffer *data = request_url(pubnub.ORIGIN, 80, url, _commonCallback);
	if (data) {
		const char * joined1 = evbuffer_pullup(data, evbuffer_get_length(data));
		json_object * obj = json_tokener_parse(joined1);
		json_object * timeT = json_object_array_get_idx(obj, 1);
		json_object * meg = json_object_array_get_idx(obj, 0);
		char * time = json_object_to_json_string(timeT);
		char s1[strlen(time) - 1];int
		i = 0, j = 0;
		for (i = 0; i <= strlen(time); i++) {
			if (i == 0 || i == strlen(time) - 1) {
			} else {
				s1[j] = time[i];
				j++;
			}
		}
		s1[strlen(time)] = '\0';
		timeToken = malloc(sizeof(char) * strlen(s1));
		timeToken = strconcat(s1, "");
		json_object * encrypted  = json_object_new_object();
		if(strlen(pubnub.CIPHER_KEY) > 0)
		{
			encrypted = decrypt(pubnub.CIPHER_KEY,meg);
		}else
		{
			encrypted=meg;
		}
		if (callback != NULL)
		{
			callback(encrypted);
		}
		evbuffer_free(data);
	}
}

/**
 * _requestHistory
 *
 * @param string * url_components.
 * @param int size.
 */
void _requestHistory(string * url_components, int size) {
	string url;
	int i;
	url = "/";
	for (i = 0; i < size; i++) {
		char url2[strlen(url_components[i]) + 1];
		strcpy(url2, url_components[i]);
		url2[strlen(url_components[i])]='\0';
		char enc[sizeof(url2) * 3];
		encodeURL(url2,enc);
		const char*r=enc;
		url = strconcat(url,r);
		if(i != size-1)
			url=strconcat(url,"/");
	}
	struct evbuffer *data = request_url(pubnub.ORIGIN, 80, url, _commonCallback);

	if (data) {
		const char *joined1 = evbuffer_pullup(data, -1);
		json_object * obj = json_tokener_parse(joined1);

		if(strlen(pubnub.CIPHER_KEY) > 0)
		{
			obj = decryptHistry(pubnub.CIPHER_KEY,obj);
		}

		if (callback != NULL)
		{
			callback(obj);
		}
		evbuffer_free(data);
	}
}

/**
 * _requestTime
 *
 * @param string * url_components.
 * @param int size.
 */
double _requestTime(string * url_components, int size) {
	double retVAl;
	string url;
	int i;
	url = "/";
	for (i = 0; i < size; i++) {
		char url2[strlen(url_components[i]) + 1];
		strcpy(url2, url_components[i]);
		url2[strlen(url_components[i])]='\0';
		char enc[sizeof(url2) * 3];
		encodeURL(url2,enc);

		const char*r=enc;
		url = strconcat(url,r);
		if(i != size-1)
			url=strconcat(url,"/");
	}
	struct evbuffer *data = request_url(pubnub.ORIGIN, 80, url, _commonCallback);
	if (data) {
		const char *joined1 = evbuffer_pullup(data, evbuffer_get_length(data));
		json_object * obj = json_object_new_string_len(joined1, evbuffer_get_length(data));
		char * tim = json_object_get_string(obj);
		tim++;
		tim[strlen(tim) - 1] = 0;
		retVAl = atof(tim);
		evbuffer_free(data);
	}
	return retVAl;
}

/**
 * getHMacSHA256
 *
 * @param string secret_key.
 * @param string input.
 */
char* getHMacSHA256(string secret_key,string input)
{
	unsigned char* key = (unsigned char*) secret_key;
	unsigned char* data = (unsigned char*) input;
	unsigned char* result;
	unsigned int result_len = 32;
	//  static char res_hexstring[32];
	int i=0;
	char*  sig=(unsigned char*) malloc(sizeof(char) * result_len);

	HMAC_CTX ctx;

	result = (unsigned char*) malloc(sizeof(char) * result_len);

	ENGINE_load_builtin_engines();
	ENGINE_register_all_complete();

	HMAC_CTX_init(&ctx);
	HMAC_Init_ex(&ctx, key, 16, EVP_sha256(), NULL);
	HMAC_Update(&ctx, data, 8);
	HMAC_Final(&ctx, result, &result_len);
	HMAC_CTX_cleanup(&ctx);
	for (i = 0; i < result_len; i++)
	{
		sprintf(&(sig[i*2]), "%02x", result[i]);
	}
	return sig;
}

char rfc3986[256] = { 0 };
char html5[256] = { 0 };

/**
 * encode
 *
 * @param unsigned char *s
 * @param  char *enc.
 * @param char *tb.
 */
void encode(unsigned char *s, char *enc, char *tb) {
	for (; *s; s++) {
		if (tb[*s])
			sprintf(enc, "%c", tb[*s]);
		else
			sprintf(enc, "%%%02X", *s);
		while (*++enc)
			;
	}
}

/**
 * encodeURL
 *
 * @param char url[].
 * @param  char enc[].
 */
void encodeURL(char url[], char enc[]) {
	int i;
	for (i = 0; i < 256; i++) {
		rfc3986[i] =
				isalnum(i) || i == '~' || i == '-' || i == '.' || i == '_' ?
						i : 0;
		html5[i] =
				isalnum(i) || i == '*' || i == '-' || i == '.' || i == '_' ? i :
						(i == ' ') ? '+' : 0;
	}
	encode(url, enc, rfc3986);
}

/**
 * strconcat
 *
 * @param string s1.
 * @param string s2.
 */
string strconcat(string s1, string s2) {

	size_t old_size;
	string t;
	old_size = strlen(s1);
	t = malloc(old_size + strlen(s2) + 1);
	strcpy(t, s1);

	strcpy(t + old_size, s2);
	return t;
}
