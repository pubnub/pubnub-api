var test    = require('testling');
var PUBNUB  = require('../pubnub-3.3.1');
var channel = 'unit-test-pubnub-channel';

test('PUBNUB JavaScript API', function (test) {
    var pubnub = PUBNUB.init({
        publish_key   : 'demo',
        subscribe_key : 'demo'
    });

    test.plan(14);

    test.ok(PUBNUB);

    test.ok(pubnub);
    test.ok(pubnub.publish);
    test.ok(pubnub.subscribe);
    test.ok(pubnub.history);
    test.ok(pubnub.detailedHistory);
    test.ok(pubnub.time);

    function publish_test() {
        pubnub.publish({
            channel  : channel,
            message  : { test : "test" },
            callback : function(response) {
                test.ok(response[0]);
                test.equal( response[1], 'Sent' );
            }
        });
    }

    function time_test() {
        pubnub.time(function(time){
            test.ok(time);
            uuid_test();
        });
    }

    function uuid_test() {
        pubnub.uuid(function(uuid){
            test.ok(uuid);
            history_test();
        });
    }

    function history_test(history) {
        pubnub.history({
            limit    : 1,
            channel  : channel,
            callback : function(messages) {
                test.ok(messages);
                test.equal( messages[0].test, "test" );
                test.end();
            }
        });
    }

    function detailedHistory_test(history) {
        pubnub.detailedHistory({
            count    : 1,
            channel  : channel,
            callback : function(messages) {
                test.ok(messages);
                test.equal( messages[0][0].test, "test" );
                test.end();
            }
        });
    }
    pubnub.subscribe({
        channel  : channel,
        connect  : publish_test,
        callback : function(message) {
            test.ok(message);
            test.equal( message.test, "test" );
            time_test();
        }
    });

});

