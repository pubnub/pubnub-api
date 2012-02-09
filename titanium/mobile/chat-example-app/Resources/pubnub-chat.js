var isAndroid = (Ti.Platform.osname=='android');



// ----------------------------------
// INCLUDE PUBNUB
// ----------------------------------
Ti.include('./pubnub.js');

// ----------------------------------
// INIT PUBNUB
// ----------------------------------
var pubnub = PubNub.init({
    publish_key   : 'pub-bce1efb0-dd32-4025-ba70-7ad27951b0f5',
    subscribe_key : 'sub-e9e365ab-5286-11e1-a51a-eb16d07a8bf6',
    ssl           : false,
    origin        : 'pubsub.pubnub.com'
});

// ----------------------------------
// RANDOM COLOR
// ----------------------------------
function rnd_hex(light) { return Math.ceil(Math.random()*9) }
function rnd_color() {
    return '#'+PubNub.map(
        Array(3).join().split(','), rnd_hex
    ).join('');
}

Ti.App.Chat = function(setup) {
    // ----------------------------------
    // LISTEN FOR MESSAGES
    // ----------------------------------
    pubnub.subscribe({
        channel  : setup['chat-room'],
        connect  : function() {
            append_chat_message("Entered Chat...");
        },
        callback : function(message) {
            append_chat_message( message.text, message.color );
        },
        error : function() {
            append_chat_message( "Lost Connection...", "#f00" );
        }
    });

    // ----------------------------------
    // SEND MESSAGE
    // ----------------------------------
    function send_a_message(message) {
        if (!message) return;

        pubnub.publish({
            channel  : setup['chat-room'],
            message  : { text : message, color : this.my_color },
            callback : function(info) {
                if (!info[0]) setTimeout(function() {
                    send_a_message(message)
                }, 2000 );
            }
        });
    }


    // ----------------------------------
    // CREATE BASE UI TAB AND ROOT WINDOW
    // ----------------------------------
    var chat_window = Ti.UI.createWindow(setup['window']);
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

    // Text Chat History
    var table = Ti.UI.createTableView({
        separatorColor : (isAndroid) ? '#000' : '#fff',
        top            : (isAndroid) ? '60dp' : 40,
        height         : '80%'
    });

    // Send Button
    var button = Ti.UI.createButton({
        title         : 'Send',
        top           : 4,
        right         : 4,
        width         : (isAndroid) ? '60dp' : 60,
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

    // Append First Row (Blank)
    table.appendRow(Ti.UI.createTableViewRow({
        className : "pubnub_chat"
    }));

    // Append New Chat Message
    function append_chat_message( message, color ) {
        var row = Ti.UI.createTableViewRow({
            className          : "pubnub_chat",
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

    // Listen for Send Button Touch
    button.addEventListener( 'touchstart', function(e) {
        send_a_message(textfield.value);
        textfield.value = "";
        textfield.focus();
    });

    // Listen for Return Key Press
    textfield.addEventListener( 'return', function(e) {
        send_a_message(textfield.value);
        textfield.value = "";
        textfield.focus();
    });

    // Listen for Return Key Press
    chat_window.addEventListener( 'open', function(e) {
        textfield.focus();
    });

    chat_window.add(table);
    chat_window.add(button);
    chat_window.add(textfield);

    this.chat_window = chat_window;
    this.my_color    = rnd_color();
    this.pubnub      = pubnub;

    append_chat_message(" ");
    append_chat_message(" ");
    append_chat_message(" ");
    append_chat_message("Connecting...");

    return this;
};

