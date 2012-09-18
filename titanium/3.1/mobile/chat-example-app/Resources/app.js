// -------------------------------------------------------------------------
// INCLUDE PUBNUB CHAT MODULE
// -------------------------------------------------------------------------
Ti.include('./pubnub-chat.js');

// -------------------------------------------------------------------------
// CREATE PUBNUB CHAT WINDOW
// -------------------------------------------------------------------------
//
// Returns an Object with Titanium Window Inside
//
var pubnub_chat_window = Ti.App.Chat({
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
pubnub_chat_window.chat_window.open();
