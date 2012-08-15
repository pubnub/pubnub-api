/* ---------------------------------------------------------------------------

    Init PubNub and Get your PubNub API Keys:
    http://www.pubnub.com/account#api-keys

--------------------------------------------------------------------------- */
var pubnub = require("./../pubnub.js").init({
    publish_key   : "demo",
    subscribe_key : "demo"
})                                         // PubNub Module
,   userid  = Math.random() * 1000000 | 1  // Random UID
,   channel = "my_channel"                 // Communication Channel
,   users   = {}                           // List of Chaters
,   lines   = [];                          // Local History

/* ---------------------------------------------------------------------------
Open Network Connection to PubNub
--------------------------------------------------------------------------- */
pubnub.subscribe({
    channel  : channel,
    connect  : function() {
        console.log("Ready To Receive Messages");
    },
    callback : function(update) {
        // Create New User if Need Be.
        update.userid in users || (users[update.userid] = '');

        // New Line?
        if (
            update.key.indexOf('\r') >= 0 ||
            update.key.indexOf('\n') >= 0
        ) {
            lines.push(chatln( update.userid, users[update.userid] ));
            users[update.userid] = '';
            return render();
        }

        // Append Key(s)
        users[update.userid] += update.key;

        // Draw
        render();
    }
});

/* ---------------------------------------------------------------------------
Render Chat
--------------------------------------------------------------------------- */
function chatln( user, message ) { return user + ': ' + message + '\r\n' }
function render() {
    // Clear Screen
    process.stdout.write('\u001B[2J\u001B[0;0f');

    // Print History Lines
    lines.forEach(function(line){ process.stdout.write(line) });
    console.log('---------------------------------------------------------');

    // Print Active Lines
    for (var user in users) process.stdout.write(chatln( user, users[user] ));
}

/* ---------------------------------------------------------------------------
Keystrokes
--------------------------------------------------------------------------- */
require('tty').setRawMode(true);    
process.openStdin().on( 'keypress', function (chunk, key) {
    // Watch for Exit Command
    if (key && key.ctrl && key.name == 'c') return process.exit();

    // Send Keystroke
    pubnub.publish({
        channel : channel,
        message : { userid : userid, key : chunk }
    });
} );
