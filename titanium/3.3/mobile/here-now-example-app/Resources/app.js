// -------------------------------------------------------------------------
// INCLUDE PUBNUB HERE NOW MODULE
// -------------------------------------------------------------------------
Ti.include('./pubnub-here-now.js');

// -------------------------------------------------------------------------
// CREATE PUBNUB PRESENCE DATA WINDOW
// -------------------------------------------------------------------------
//
// Returns an Object with Titanium Window Inside
//
var pubnub_data_window = Ti.App.HereNow({
    "channel" : "hello_world",
    "window"    : {
        title           : 'Data',
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
