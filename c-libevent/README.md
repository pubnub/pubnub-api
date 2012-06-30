##### YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
##### http://www.pubnub.com/account

## PubNub 3.1 Real-time Cloud Push API - C-libevent

www.pubnub.com - PubNub Real-time Push Service in the Cloud.

PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
This is a cloud-based service for broadcasting Real-time messages
to thousands of web and mobile clients simultaneously.

##### PubNub C-libevent Client API Boiler Plate


##### 	Install following libraries
 	libevent-2.0.18-stable
	openssl-0.9.8l
	json-c-0.9

	Add Pubnub.h to your project
	Include Pubnub.h to your class header 
	#include<Pubnub.h>

    Make sure your class follow the Pubnub protocol

-------------------------------------------------------------------------------
c-libevent : (Init)
-------------------------------------------------------------------------------
```C
		//Initialize pubnub state
		Pubnub_overload1(
		"demo",  // PUBLISH_KEY
		"demo",  // SUBSCRIBE_KEY
		"",      // SECRET_KEY
		"",      // CIPHER_KEY (cipher key is optional)
		false    // SSL_ON?
	);
```

-------------------------------------------------------------------------------
c-libevent : (Publish)
-------------------------------------------------------------------------------
```C
		// Create callback function for publish
		static void publish_callback(json_object *obj)
		{
			printf("\n OUTPUT Message:::%s", json_object_to_json_string(obj));
			write(1, json_object_to_json_string(obj), strlen(json_object_to_json_string(obj)));
		}
		// WAS startup configuration
		#ifdef _WIN32
			WSADATA WSAData;
			WSAStartup(0x101, &WSAData);
		#else
		if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
			return (1);
		#endif
		// Initialize pubnub state
		Pubnub_overload1("demo","demo","","",false);		
		// Create object of structure struct_publish
		struct_publish args = {
				.channel = "hello_world",
				.message="{\"Name\":\"Happy Birthday To You\"}",
				.cb= publish_callback,
				.type = 1
		};	    
		// Publish Message (string)
		publish( &args );
		// Publish json_object array
		json_object *my_array = json_object_new_array();
		json_object_array_add(my_array, json_object_new_string("hello"));
		struct struct_publish args2 = { 
				.channel = "hello_world", 
				.message = my_array, 
				.cb = publish_callback, 
				.type = 2 
		};
		// Publish Message (array of json object)
		publish(&args2);			
		// Publish json_object
		json_object * my_object = json_object_new_object();
		json_object_object_add(my_object, "some_val", json_object_new_string("hello"));
		struct struct_publish args1 = { 
				.channel = "hello_world", 
				.message = my_object,
					  .cb = publish_callback, 
				.type = 3 
		};
		// Publish Message (json object)
		publish(&args1);
```	

-------------------------------------------------------------------------------
c-libevent : (Subscribe)
-------------------------------------------------------------------------------
```C
		// Create callback function for subscribe
		static void subscribe_callback(json_object *obj)
		{
			printf("\n OUTPUT Message:::%s", json_object_to_json_string(obj));
			write(1, json_object_to_json_string(obj), strlen(json_object_to_json_string(obj)));
		}		
		// WAS startup configuration
		#ifdef _WIN32
			WSADATA WSAData;
			WSAStartup(0x101, &WSAData);
		#else
		if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
			return (1);
		#endif
		// Initialize pubnub state
		Pubnub_overload1("demo","demo","","",false);		
		// Create object of structure struct_subscribe
		struct_subscribe args = {
			.channel = "hello_world",
			.cb= subscribe_callback
		};
		//call subscribe() method
		subscribe(&args);
```

-------------------------------------------------------------------------------
c-libevent : (History)
-------------------------------------------------------------------------------
```C
		// Create callback function for history
		static void history_callback(json_object *obj)
		{
			printf("\n OUTPUT Message:::%s", json_object_to_json_string(obj));
			write(1, json_object_to_json_string(obj), strlen(json_object_to_json_string(obj)));
		}
		// WAS startup configuration
		#ifdef _WIN32
			WSADATA WSAData;
			WSAStartup(0x101, &WSAData);
		#else
		if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
			return (1);
		#endif
		// Initialize pubnub state
		Pubnub_overload1("demo","demo","demo","",false);
		// Create object of structure struct_history
		struct_history  args = {
			.channel = "hello_world",
			.limit=2,
			.cb= history_callback
		};
		//call subscribe() method
		history(args);        
```

-------------------------------------------------------------------------------
c-libevent : (Time)
-------------------------------------------------------------------------------
```C
		//Get the time		
		// WAS startup configuration
		#ifdef _WIN32
			WSADATA WSAData;
			WSAStartup(0x101, &WSAData);
		#else
			if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
			return (1);
		#endif		
		// Initialize pubnub state
		Pubnub_overload1("demo","demo","","",false);		
		// call gettime() function		
		double time = getTime();		
		// Display result
		printf("Time:::%lf",time);
```

-------------------------------------------------------------------------------
c-libevent : (UUID)
-------------------------------------------------------------------------------
```C
		// Get UUID		
		// WAS startup configuration
		#ifdef _WIN32
			WSADATA WSAData;
			WSAStartup(0x101, &WSAData);
		#else
		if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
			return (1);
		#endif
		// Initialize pubnub state
		Pubnub_overload1("demo","demo","","",false);
		// call uuid()
		char * str_uuid;	
		str_uuid = uuid();
		// Display result
		printf("UUID:::%s",str_uuid);
```
