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

Ti.App.HereNow = function(setup) {

    // ----------------------------------
    // CREATE BASE UI TAB AND ROOT WINDOW
    // ----------------------------------
    var data_window = Ti.UI.createWindow(setup['window']);

    var table = Ti.UI.createTableView({
        separatorColor : (isAndroid) ? '#000' : '#fff',
        top            : (isAndroid) ? '60dp' : 40,
        height         : '80%'
    });


    // Append First Row (Blank)
    table.appendRow(Ti.UI.createTableViewRow({
        className : "pubnub_data"
    }));

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

    // Here Now Button
    var here_now_button = Ti.UI.createButton({
        title         : 'Here Now',
        top           : 4,
        right         : 150,
        width         : (isAndroid) ? '100dp' : 100,
        height        : (isAndroid) ? '50dp' : 30,
        borderRadius  : 6,
        shadowColor   : "#001",
        shadowOffset  : { x : 1, y : 1 },
        style         : Ti.UI.iPhone.SystemButtonStyle.PLAIN,
        font          : {
            fontSize   : (isAndroid) ? '18dp' : 16,
            fontWeight : 'bold'
        },
        backgroundGradient : {
            type          : 'linear',
            colors        : [ '#058cf5', '#015fe6' ],
            startPoint    : { x : 0, y : 0 },
            endPoint      : { x : 2, y : 50 },
            backFillStart : false
        }
    });
    // here now button Touch
    here_now_button.addEventListener( 'touchstart', function(e) {
        pubnub.here_now({
            channel  : setup['channel'],
            connect  : function() {
                    append_data("Receiving Here Now data ...");
            },
            callback : function(message) {
                    append_data( JSON.stringify(message), message.color );
            },
            error : function() {
                    append_data( "Lost Connection...", "#f00" );
            }
        });
    });

    // Listen for Return Key Press
    data_window.addEventListener( 'open', function(e) {
        textfield.focus();
    });

    data_window.add(table);
    data_window.add(here_now_button);

    this.data_window = data_window;
    this.my_color    = rnd_color();
    this.pubnub      = pubnub;

    return this;
};

