test( 1, 'Ready to Test' );
test( PUBNUB, 'PubNub Lib Exists' );

// Encryption Unit Tests
test(PUBNUB.secure, "PubNub AES Lib Exists");

var aes = PUBNUB.secure({
    publish_key: "demo",
    subscribe_key: "demo",
    cipher_key: "enigma"
});


test(aes, "AES PubNub Object Instantiated");

encryptionTests();

p.time(function(time){
    test( time, 'TimeToken' );
    test( time > 0, 'Time Value' );
});

p.uuid(function(uuid){
    test( uuid, 'UUID Response');
    test( uuid.length > 10, 'UUID Long Enough');
});

function publish_test(con) {
    con || test( 1, 'Connection Established' );

    p.publish({
        channel  : channel,
        message  : { test : "test" },
        callback : function(response) {
            test( response[0], 'Successful Publish' );
            test( response[1] === 'Sent', 'Success With Demo' );
            history_test();
        }
    });
}

publish_test(1);

function history_test() {
    p.history({
        limit    : 1,
        channel  : channel,
        callback : function(messages) {
            test( messages, 'History Response' );
            console.log(messages);
            test( messages[0][0].test === "test", 'History Content' );
        }
    });
}

p.subscribe({
    channel  : channel,
    connect  : publish_test,
    callback : function( message, stack ) {
        p.unsubscribe({ channel : channel });
        test( message, 'Subscribe Message' );
        test( message.test === "test", 'Subscribe Message Data' );
        test( stack[1], 'TimeToken Returned: ' + stack[1] );
    }
});

/* ------------------------------------------------------------------
--- MANY CONNECTIONS TESTS
------------------------------------------------------------------ */
p.map( Array(many_con_tst).join('-').split('-'), function( _, conn ) {
    var chan = 'many-conn-test-' + conn;
    test( chan, 'Many Connections: ' + conn + ' Connecting...' );

    p.subscribe({
        channel  : chan,
        connect  : function() {
            test( chan, 'Many Connections: ' + conn + ' Connected!' );
            p.publish({ channel : chan, message : chan });
        },
        callback : function(message) {
            test(
                chan === message,
                'Many Connections: ' + conn + ' Received'
            );
            setTimeout(
                function() { p.unsubscribe({ channel : chan }) },
                5000
            );
        }
    });
} );

/* ------------------------------------------------------------------
--- TESTING NEW CONNECTION RESTORE FEATURE
------------------------------------------------------------------ */
var restore_channel = 'restore-channel'+Math.random();
p.subscribe({
    restore  : true,
    channel  : restore_channel,
    callback : function(){},
    connect  : function() {
        p.unsubscribe({ channel : restore_channel });

        // Send Message While Not Connected
        p.publish({
            channel  : restore_channel,
            message  : 'test',
            callback : function() {
                p.subscribe({
                    restore  : true,
                    channel  : restore_channel,
                    callback : function( message, stack ) {
                        p.unsubscribe({ channel : restore_channel });
                        test(
                            message === "test",
                            'Subscribe Restore'
                        );
                    }
                });
            }
        });
    }
});

function encryptionTests() {
    var test_plain_string_1 = "Pubnub Messaging API 1";
    var test_plain_string_2 = "Pubnub Messaging API 2";
    var test_plain_object_1 = {"foo": {"bar": "foobar"}};
    var test_plain_object_2 = {"this stuff": {"can get": "complicated!"}};
    var test_plain_unicode_1 = '漢語'
    var test_cipher_string_1 = "f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=";
    var test_cipher_string_2 = "f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=";
    var test_cipher_object_1 = "GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g=";
    var test_cipher_object_2 = "zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF";
    var test_cipher_unicode_1 = "WvztVJ5SPNOcwrKsDrGlWQ==";

    test(aes.raw_encrypt(test_plain_string_1) == test_cipher_string_1, "AES String Encryption Test 1");
    test(aes.raw_encrypt(test_plain_string_2) == test_cipher_string_2, "AES String Encryption Test 2");
    test(aes.raw_encrypt(test_plain_object_1) == test_cipher_object_1, "AES Object Encryption Test 1");
    test(aes.raw_encrypt(test_plain_object_2) == test_cipher_object_2, "AES Object Encryption Test 2");
    test(aes.raw_encrypt(test_plain_unicode_1) == test_cipher_unicode_1, "AES Unicode Encryption Test 1");
    test(aes.raw_decrypt(test_cipher_string_1) == test_plain_string_1, "AES String Decryption Test 1");
    test(aes.raw_decrypt(test_cipher_string_2) == test_plain_string_2, "AES String Decryption Test 2");
    test(JSON.stringify(aes.raw_decrypt(test_cipher_object_1)) == JSON.stringify(test_plain_object_1), "AES Object Decryption Test 1");
    test(JSON.stringify(aes.raw_decrypt(test_cipher_object_2)) == JSON.stringify(test_plain_object_2), "AES Object Decryption Test 2");
    test(aes.raw_decrypt(test_cipher_unicode_1) == test_plain_unicode_1, "AES Unicode Decryption Test 1");

    var s = PUBNUB.secure({"cipher_key": "enigma", "subscribe_key": "demo", "publish_key": "demo"})

    aes_channel = "hello_world";

    function aes_publish_test() {

        test(1, 'Beginning AES Publish / Subscribe / History Tests');

        function aes_history_test() {
            s.history({
                limit: 1,
                reverse: false,
                channel: aes_channel,
                callback: function (data) {
                    test(data, 'AES History Response');
                    test(data[0][0].test === "test", 'AES History Content');
                }
            });
        }

        s.publish({
            channel: aes_channel,
            message: { test: "test" },
            callback: function (response) {
                test(response[0], 'AES Successful Publish ' + response[0]);
                test(response[1], 'AES Success With Demo ' + response[1]);
                setTimeout(aes_history_test, 2500);
            }
        });
    }

    aes_publish_test();

    s.subscribe({
        channel: aes_channel,
        connect: aes_publish_test,
        presence: function (message, envelope, aes_channel) {

        },
        callback: function (message, envelope, aes_channel) {
            test(message, 'AES Subscribe Message');
            test(message.test === "test", 'AES Subscribe Message Data');
            test(envelope[1], 'AES TimeToken Returned: ' + envelope[1]);
        }
    });

}
