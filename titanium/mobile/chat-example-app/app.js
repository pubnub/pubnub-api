// -------------------------------------------------------------------------
// INCLUDE PUBNUB CHAT MODULE
// -------------------------------------------------------------------------
Ti.include('pubnub-chat.js');

// -------------------------------------------------------------------------
// CREATE PUBNUB CHAT WINDOW
// -------------------------------------------------------------------------
//
// Returns an Object with Titanium Window Inside
//
var pubnub_chat_window = PUBNUB_CHAT({
    "chat-room" : "my-random-conversation",
    "window"    : {
        title           : 'My Chat Room',
        backgroundColor : '#fff'
    }
});

// -------------------------------------------------------------------------
// TITANIUM WINDOW OBJECT
// -------------------------------------------------------------------------
//
// Open Chat Window
//
PUBNUB_CHAT.chat_window.open();

