var PUBNUB, channel, here_now_test, history_test, nodeunit, presence_test, publish_dummy, publish_test, pubnub, run_dummy_subscribe, subscribe_test, time_test, uuid_test, detailed_history_test_1, detailed_history_test_2, detailed_history_test_3;

PUBNUB = require('../temp');

nodeunit = require('nodeunit');

channel = 'unit-test-pubnub-nodejs';

pubnub = PUBNUB.init({
    publish_key:'demo',
    subscribe_key:'demo'
});

publish_dummy = function (channel, callback, message) {
    if (callback === null) {
        callback = function () {
        };
    }
    return pubnub.publish({
        channel:channel,
        message:message || { test:"test" },
        callback:callback
    });
};

var publish_callback = function(message) {};
var temp_channel = channel + '-' + pubnub.uuid();

publish_dummy(temp_channel, publish_callback, 'first');
publish_dummy(temp_channel, publish_callback, 'second');

publish_test = function (test) {
    test.expect(2);
    return publish_dummy(channel, function (response) {
        test.ok(response[0] === 1);
        test.ok(response[1] === "Sent");
        test.done();
    });
};

time_test = function (test) {
    test.expect(1);
    return pubnub.time(function (time) {
        test.ok(time);
        test.done();
    });
};

uuid_test = function (test) {
    test.expect(1);
    return pubnub.uuid(function (uuid) {
        test.ok(uuid);
        test.done();
    });
};

detailed_history_test_1 = function (test) {
    test.expect(2);
    return pubnub.detailedHistory({
        count:1,
        channel:channel,
        callback:function (messages) {
            test.ok(messages);
            test.ok(messages[0][0].test === "test");
            test.done();
        }
    });
};

detailed_history_test_2 = function (test) {

    test.expect(2);

    return pubnub.detailedHistory({
        count:1,
        channel:temp_channel,
        callback:function (messages) {
            test.notEqual(messages, null);
            test.equal(messages[0][0], "second");
            test.done();
        }
    });
};

detailed_history_test_3 = function (test) {

    test.expect(2);

    return pubnub.detailedHistory({
        count:1,
        channel:temp_channel,
        reverse:'true',
        callback:function (messages) {
            test.notEqual(messages, null);
            test.equal(messages[0][0], "first");
            test.done();
        }
    });
};


history_test = function (test) {
    test.expect(2);
    return pubnub.history({
        limit:1,
        channel:channel,
        callback:function (messages) {
            test.ok(messages);
            test.ok(messages[0].test === "test");
            test.done();
        }
    });
};

subscribe_test = function (test) {
    var test_channel;
    test_channel = 'channel-' + PUBNUB.unique();
    test.expect(2);
    return pubnub.subscribe({
        channel:test_channel,
        connect:function () {
            return publish_dummy(test_channel);
        },
        callback:function (message) {
            test.ok(message);
            test.ok(message.test === "test");
            test.done();
            return {stop:true};
        }
    });
};

run_dummy_subscribe = function (channel) {
    var pubnub = PUBNUB.init({
        publish_key:'demo',
        subscribe_key:'demo'
    });
    return pubnub.subscribe({
        channel:channel,
        connect:function () {
            return {stop:true};
        },
        callback:function () {
            return {stop:true};
        }
    });
};

presence_test = function (test) {
    var test_channel;
    test_channel = 'channel-' + PUBNUB.unique();
    test.expect(3);
    return pubnub.presence({
        channel:test_channel,
        connect:function () {
            run_dummy_subscribe(test_channel);
        },
        callback:function (message) {
            test.ok(message);
            test.ok(message.action === "join");
            test.ok(message.occupancy === 1);
            test.done();
            return {stop:true};
        }
    });
};

here_now_test = function (test) {
    var test_channel;
    test_channel = 'channel-' + PUBNUB.unique();
    test.expect(3);

    pubnub.here_now({
        channel:test_channel,
        callback:function (message) {
            test.notEqual(message, null);
            test.equal(message.occupancy, 0);
            test.equal(message.uuids.length, 0);
            test.done();
            return {stop:true };
        }
    });

};

module.exports = {
  "Publish Test": publish_test,
  "History Test": history_test,
  "Time Test": time_test,
  "UUID Test": uuid_test,
  "Subscribe Test": subscribe_test,
  "Presence Test": presence_test,
    "Here Now Test":here_now_test,
    "Detailed History Test 1":detailed_history_test_1,
    "Detailed History Test 2":detailed_history_test_2,
    "Detailed History Test 3":detailed_history_test_3
};
