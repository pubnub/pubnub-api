PUBNUB.subscribe( { channel : 'my_test_channel' },
function(message) {
    if ('some_text' in message) {
        alert(message.some_text);
    }
} );

