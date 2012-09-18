(function(){

// -- 
// -- DOM ELEMENT POINTERS
// -- 
var logger            = PUBNUB.$('pubnub-logger')
,   publish_button    = PUBNUB.$('publish-button')
,   subscribe_button  = PUBNUB.$('subscribe-button')
,   subscribe_channel = PUBNUB.$('subscribe-channel')
,   publish_text      = PUBNUB.$('publish-text')
,   connected         = PUBNUB.$('pubnub-connected')
,   channel_name      = '';


// -- 
// -- BASIC LOG OUTPUT FUNCTION
// -- 
function log(data) {
    logger.innerHTML = 
        '\n' + log.line++ + ': ' +
        JSON.stringify(data) + (
        channel_name ?
        ' - from "' + channel_name + '" Channel.' :
        '' ) + logger.innerHTML;
}
log.line = 1;


// -- 
// -- SEND A MESSAGE FUNCTION
// -- 
function send_message(message) {
    PUBNUB.publish({
        channel : channel_name,
        message : message
    });
}


// -- 
// -- LISTING FOR MESSAGES
// -- 
function listen(channel) {
    // -- UNSUBSCRIBE FROM PREVIOUS CHANNEL
    PUBNUB.unsubscribe({ channel : channel_name});

    // -- SAVE NEW CHANNEL NAME
    channel_name = channel || 'titanium-demo';

    // -- SUBSCRIBE TO NEW CHANNEL
    PUBNUB.subscribe({
        channel  : channel_name,
        callback : log
    });

    // -- UPDATE CONNECTED STATUS
    connected.innerHTML = 'CONNECTED to "' + channel_name + '"';
    PUBNUB.css( connected, { color : "green" } );
}


// -- 
// -- BIND SUBSCRIBE BUTTON
// -- 
PUBNUB.bind( 'mousedown,touchstart', subscribe_button, function() {
    listen(subscribe_channel.value);
} );


// -- 
// -- BIND PUBLISH BUTTON
// -- 
PUBNUB.bind( 'mousedown,touchstart', publish_button, function() {
    // -- PUBLISH THE VALUE OF THE TEXTBOX INPUT
    send_message( publish_text.value || 'EMPTY MESSAGE' );
} );


// -- 
// -- GENERAL STARTUP COMPLETE MESSAGE
// -- 
log("Startup Complete");

})();
