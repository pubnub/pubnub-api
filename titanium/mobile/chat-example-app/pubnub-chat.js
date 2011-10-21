// ----------------------------------
// INCLUDE PUBNUB
// ----------------------------------
Ti.include('pubnub.js');

// ----------------------------------
// INIT PUBNUB
// ----------------------------------
var pubnub = PUBNUB.init({
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
    return '#'+PUBNUB.map(
        Array(3).join().split(','), rnd_hex
    ).join('');
}

PUBNUB_CHAT = function(setup) {
    // ----------------------------------
    // LISTEN FOR MESSAGES
    // ----------------------------------
    pubnub.subscribe({
        channel  : setup['chat-room'],
        connect  : function() {
            append_chat_message("Entered Chat Room...");
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
            message  : { text : message, color : PUBNUB_CHAT.my_color },
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
    var chat_window = Titanium.UI.createWindow(setup['window']);
    var textfield   = Titanium.UI.createTextField({
        width       : 247,
        height      : 30,
        left        : 4,
        top         : 4,
        color       : "#111",
        value       : "",
        border      : 1,
        borderStyle : Titanium.UI.INPUT_BORDERSTYLE_ROUNDED,
        font        : {
            fontSize   : 14,
            fontWeight : 'bold'
        }
    });

    // Text Chat History
    var table = Titanium.UI.createTableView({
        separatorColor : '#fff',
        bottom         : 2,
        height         : 420
    });

    // Send Button
    var button = Titanium.UI.createButton({
        title         : 'Send',
        top           : 4,
        right         : 4,
        width         : 60,
        height        : 30,
        borderRadius  : 6,
        shadowColor   : "#001",
        shadowOffset  : { x : 1, y : 1 },
        style         : Titanium.UI.iPhone.SystemButtonStyle.PLAIN,
        font          : {
            fontSize   : 16,
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
    table.appendRow(Titanium.UI.createTableViewRow({
        className : "pubnub_chat"
    }));

    // Append New Chat Message
    function append_chat_message( message, color ) {
        var row = Titanium.UI.createTableViewRow({
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
            height : 'auto',
            width  : 'auto',
            color  : color || "#111",
            left   : 10,
            font   : { fontSize : 13}
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

    PUBNUB_CHAT.chat_window = chat_window;
    PUBNUB_CHAT.my_color    = rnd_color();

    append_chat_message(" ");
    append_chat_message(" ");
    append_chat_message(" ");
    append_chat_message("Connecting...");

    return PUBNUB_CHAT;
};
