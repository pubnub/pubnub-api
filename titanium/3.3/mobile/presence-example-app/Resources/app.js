// -------------------------------------------------------------------------
// INCLUDE PUBNUB PRESENCE MODULE
// -------------------------------------------------------------------------
Ti.include('./pubnub-presence.js');

// -------------------------------------------------------------------------
// CREATE PUBNUB DATA WINDOW
// -------------------------------------------------------------------------
//
// Returns an Object with Titanium Window Inside
//
var pubnub_data_window = Ti.App.Presence({
    "channel" : "hello_world",
    "window"    : {
        title           : 'Presence Data',
        backgroundColor : '#fff'
    }
});

// -------------------------------------------------------------------------
// TITANIUM WINDOW OBJECT
// -------------------------------------------------------------------------
//
// Open Chat Window
//
pubnub_data_window.data_window.open();
