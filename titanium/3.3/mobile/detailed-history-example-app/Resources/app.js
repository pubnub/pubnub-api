// -------------------------------------------------------------------------
// INCLUDE PUBNUB DETAILED HISTORY MODULE
// -------------------------------------------------------------------------
Ti.include('./pubnub-detailed-history.js');

// -------------------------------------------------------------------------
// CREATE PUBNUB DATA WINDOW
// -------------------------------------------------------------------------
//
// Returns an Object with Titanium Window Inside
//
var pubnub_data_window = Ti.App.DetailedHistory({
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
