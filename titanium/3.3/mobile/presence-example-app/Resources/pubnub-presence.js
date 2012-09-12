// ----------------------------------
// Detect Platform
// ----------------------------------
var isAndroid = Ti.Platform.osname === 'android';

// ----------------------------------
// INIT PUBNUB
// ----------------------------------
var pubnub = require('pubnub').init({
    publish_key   : 'demo',
    subscribe_key : 'demo',
    ssl           : false,
    origin        : 'pubsub.pubnub.com'
});

// ----------------------------------
// RANDOM COLOR
// ----------------------------------
function rnd_hex(light) { return Math.ceil(Math.random()*9) }
function rnd_color() {
    return '#'+pubnub.map(
        Array(3).join().split(','), rnd_hex
    ).join('');
}

Ti.App.Presence = function(setup) {
    // ----------------------------------
    // LISTEN FOR MESSAGES
    // ----------------------------------
    pubnub.presence({
        channel  : setup['channel'],
        connect  : function() {
            append_data("Receiving Presence data ...");
        },
        callback : function(message) {
            append_data( JSON.stringify(message), message.color );
        },
        error : function() {
            append_data( "Lost Connection...", "#f00" );
        }
    });

    // ----------------------------------
    // CREATE BASE UI TAB AND ROOT WINDOW
    // ----------------------------------
    var data_window = Ti.UI.createWindow(setup['window']);
    var textfield   = Ti.UI.createTextField({
        width       : (isAndroid) ? '75%' : 247,
        height      : (isAndroid) ? '50dp' : 30,
        left        : 4,
        top         : 4,
        color       : "#111",
        value       : "",
        border      : 1,
        borderStyle : Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        borderRadius : 4,
        font        : {
            fontSize   : (isAndroid) ? '18dp' : 14,
            fontWeight : 'bold'
        }
    });

    var table = Ti.UI.createTableView({
        separatorColor : (isAndroid) ? '#000' : '#fff',
        top            : (isAndroid) ? '60dp' : 40,
        height         : '80%'
    });


    // Append First Row (Blank)
    table.appendRow(Ti.UI.createTableViewRow({
        className : "pubnub_data"
    }));

    // Append New Presence Event
    function append_data( message, color ) {
        var row = Ti.UI.createTableViewRow({
            className          : "pubnub_data",
            backgroundGradient : {
                type          : 'linear',
                colors        : [ "#fff", '#eeeeed' ],
                startPoint    : { x : 0, y : 0 },
                endPoint      : { x : 0, y : 70 },
                backFillStart : false
            }
        });

        var label = Ti.UI.createLabel({
            text   : message || "no-message",
            height : (isAndroid) ? '50dp' : 'auto',
            width  : 'auto',
            color  : color || "#111",
            left   : 10,
            font   : { 
                fontSize : (isAndroid) ? '19dp' : 14,
                fontWeight: (isAndroid) ? 'bold' : 'normal'
            }
        });

        row.add(label);
        table.insertRowBefore( 0, row );
    }

    // Subscribe button Touch
    subscribe_button.addEventListener( 'touchstart', function(e) {
        pubnub.subscribe({
            channel  : setup['channel'],
            callback : function(message) { },
            error : function() { }
        });
    });

    // Unubscribe button Touch
    unsubscribe_button.addEventListener( 'touchstart', function(e) {
        pubnub.unsubscribe({
            channel  : setup['channel']
        });
    });

    // Listen for Return Key Press
    data_window.addEventListener( 'open', function(e) {
        textfield.focus();
    });

    data_window.add(table);

    this.data_window = data_window;
    this.my_color    = rnd_color();
    this.pubnub      = pubnub;

    return this;
};

