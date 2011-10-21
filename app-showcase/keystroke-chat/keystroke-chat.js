(function(){

// ------------------------------------------------------------------------- //
// Utility Functions
// ------------------------------------------------------------------------- //
var store = localStorage
,   db    = store && {
    set    : function( key, val ) {db.remove(key);store.setItem(key,val)},
    get    : function(key) { return store.getItem(key) },
    remove : function(key) { store.removeItem(key) }
};

// ------------------------------------------------------------------------- //
// Templates and HTML
// ------------------------------------------------------------------------- //
var message_bubble_tpl = '<div style="display:inline-block;float:left;font-family:Arial;width:382px;background-color:#{background};color:#fff;text-shadow:#000 0 1px 1px;background-image:-moz-linear-gradient(rgba(255,255,255,0.8)0%,rgba(0,0,0,0)100%);background-image:-webkit-gradient(linear,left top,left bottom,from(rgba(255,255,255,0.8)),to(rgba(0,0,0,0)));border:0;margin:10px;padding:10px 20px 10px 20px;border-radius:50px;-moz-border-radius:50px;-webkit-border-radius:50px;overflow:hidden;-o-transition:all 0.3s;-moz-transition:all 0.3s;-webkit-transition:all 0.3s;transition:all 0.3s;position:relative;"><strong>{username}&nbsp;-&nbsp;</strong>&nbsp;{message}</div>'
,   interface_tpl = '<div style="width:400px;background:#fff;border:0px solid #ccc;margin:10px;padding:10px;border-radius:12px;-moz-border-radius:12px;-webkit-border-radius:12px;"><div style="font-family:Arial;font-size:11px;margin:0 10px 10px 0;text-align:right;"><a href="#" id="keystroke-chat-username-change">Change Username</a></div><textarea id="keystroke-chat-input" style="width:370px;height:40px;font-weight:normal;padding:14px;border:0px solid #999;border-radius:20px;-moz-border-radius:20px;-webkit-border-radius:4px;-webkit-box-shadow:inset #aaa 0 1px 5px;-moz-box-shadow:inset #aaa 0 1px 5px;box-shadow:inset #aaa 0 1px 5px;text-shadow:#bbb 0 1px 2px;overflow-x:hidden;-o-transition:all 0.3s;-moz-transition:all 0.3s;-webkit-transition:all 0.3s;transition:all 0.3s;"></textarea><div><button id="keystroke-chat-send" style="margin-top:10px;width:150px;padding:2px;color:#fff;font-weight:bold;font-size:12px;border-radius:70px;-moz-border-radius:70px;-webkit-border-radius:70px;cursor:pointer;text-shadow:rgba(0,0,0,0.5)0 -1px 2px;background-color:#44d5ff;background-image:-moz-linear-gradient(rgba(255,255,255,0.7)0%,rgba(255,255,255,0)20%,rgba(255,255,255,0.2)80%,rgba(0,0,0,0.3)100%);background-image:-webkit-gradient(linear,left top,left bottom,from(rgba(255,255,255,0.7)),color-stop(0.2,rgba(255,255,255,0)),color-stop(0.8,rgba(255,255,255,0.2)),to(rgba(0,0,0,0.3)));box-shadow:0 -1px 2px #000;-moz-box-shadow:0 -1px 2px #000;-webkit-box-shadow:0 -1px 2px #000;-o-transition:all 0.3s;-moz-transition:all 0.3s;-webkit-transition:all 0.3s;transition:all 0.3s;border:0px;">New Bubble</button>&nbsp;<button id="keystroke-chat-turn-off" style="margin-top:10px;width:150px;padding:2px;color:#fff;font-weight:bold;font-size:12px;border-radius:70px;-moz-border-radius:70px;-webkit-border-radius:70px;cursor:pointer;text-shadow:rgba(0,0,0,0.5)0 -1px 2px;background:#f44;background-image:-moz-linear-gradient(rgba(255,255,255,0.7)0%,rgba(255,255,255,0)20%,rgba(255,255,255,0.2)80%,rgba(0,0,0,0.3)100%);background-image:-webkit-gradient(linear,left top,left bottom,from(rgba(255,255,255,0.7)),color-stop(0.2,rgba(255,255,255,0)),color-stop(0.8,rgba(255,255,255,0.2)),to(rgba(0,0,0,0.3)));box-shadow:0 -1px 2px #000;-moz-box-shadow:0 -1px 2px #000;-webkit-box-shadow:0 -1px 2px #000;border:0px;">Turn OFF</button></div></div><div id="keystroke-chat-messages"></div></div><div id="keystroke-chat-messages"></div><audio id=keystroke-chat-audio preload ><source src=http://pubnub.s3.amazonaws.com/general/preview.ogg type=audio/ogg ></audio>';


// ------------------------------------------------------------------------- //
// Setup
// ------------------------------------------------------------------------- //
var settings  = PUBNUB.$('real-time-keystrok-chat') ||
                alert('Missing DIV for Keystroke Chat')
,   channel   = PUBNUB.attr( settings, 'channel' )
,   topic     = PUBNUB.attr( settings, 'topic' )
,   pubrate   = +PUBNUB.attr( settings, 'pubrate' )
,   maxmsg    = -PUBNUB.attr( settings, 'max-message' )
,   maxbbl    = +PUBNUB.attr( settings, 'max-bubble-flood' )
,   curbbl    = 0
,   username  = db && db.get('username') || 'Anonymous'
,   uuid      = PUBNUB.uuid(function(id){ uuid = id })
,   bubbles   = {}
,   publishes = 1
,   type_ival = 1
,   is_done   = 0
,   typing    = 0
,   br_rx     = /[\r\n<>]/g;

settings.innerHTML = interface_tpl;

var message_area    = PUBNUB.$('keystroke-chat-messages')
,   post_message    = PUBNUB.$('keystroke-chat-send')
,   username_change = PUBNUB.$('keystroke-chat-username-change')
,   turn_off        = PUBNUB.$('keystroke-chat-turn-off')
,   audio           = PUBNUB.$('keystroke-chat-audio')
,   textarea        = PUBNUB.$('keystroke-chat-input');


// ------------------------------------------------------------------------- //
// Receive Keystrokes
// ------------------------------------------------------------------------- //
PUBNUB.subscribe({
    'channel'  : channel,
    'callback' : function(message) {
        var the_uuid = message['uuid'];

        // Add Bubble if not present.
        if (!bubbles[the_uuid]) {
            var new_bubble = PUBNUB.create('div');

            message_area.insertBefore(
                new_bubble,
                message_area.firstChild
            );

            bubbles[the_uuid] = new_bubble;
            bubbles[the_uuid]['last'] = 0;
        }

        // Alias Bubble Div
        var bubble = bubbles[the_uuid];

        // Ignore Latent Unsynchronized Messages
        if (bubble['last'] > message['last']) return;
        bubble['last'] = message['last'];

        // Update The Message Text Body
        bubble.innerHTML = PUBNUB.supplant( message_bubble_tpl, {
            'username'   : message['user'] || 'Anonymous',
            'background' : the_uuid.slice(-3),
            'message'    : message['text']
        } );

        // Animate For Cool Effect
        if (!bubble['shown']) {
            bubble['shown'] = 1;
            PUBNUB.css( bubble.firstChild, { 'top' : 100 } );
            setTimeout( function() {
                PUBNUB.css( bubble.firstChild, { 'top' : '0' } );
            }, 10 );
        }
    }
});

// ------------------------------------------------------------------------- //
// Send Keystrokes
// ------------------------------------------------------------------------- //
var send_keystroke = PUBNUB.updater( function() { setTimeout(function(){
    if (!uuid) return;

    PUBNUB.publish({
        'channel' : channel,
        'message' : {
            'uuid' : uuid,
            'user' : username,
            'last' : ++publishes,
            'text' : (textarea.value || '')
                     .slice(maxmsg)
                     .replace( br_rx, '' )
        }
    });
}, 20 ) }, pubrate );

PUBNUB.bind( 'keydown', textarea, function(e) {
    if (e.keyCode == 13) return new_bubble();

    typing || PUBNUB.events.fire('typing-started');
    typing = 1;

    clearTimeout(type_ival);

    type_ival = setTimeout( function() {
        PUBNUB.events.fire('typing-stopped');
        typing = 0;
    }, 1000 );

    send_keystroke();

    return true;
} );

// ------------------------------------------------------------------------- //
// New Bubble
// ------------------------------------------------------------------------- //
function new_bubble() {
    // Prevent Flooding
    if (curbbl > maxbbl) return PUBNUB.css( post_message, {
        'backgroundColor' : '#f00',
        'color' : '#000'
    } );

    curbbl++;

    uuid = publishes + uuid;
    setTimeout( function() {
        textarea.value = '';
        textarea.focus();
        send_keystroke();
    }, 20 );
}

setInterval( function() {
    // Show Okay to make New Bubble
    if (curbbl > maxbbl) PUBNUB.css( post_message, {
        'backgroundColor' : '#44d5ff',
        'color' : '#fff'
    } );

    curbbl = curbbl > 0 ? curbbl - 1 : 0;
}, 5000 );

PUBNUB.bind( 'mousedown,touchstart', post_message, new_bubble );

// ------------------------------------------------------------------------- //
// Typing Started
// ------------------------------------------------------------------------- //
PUBNUB.events.bind( 'typing-started', function() {
    if (is_done) return;
    if (textarea.value.indexOf('please the textbox:') < 0) return;

    audio.currentTime = 10;
    audio.play();
    var type_vel = 1000;

    function increasing_blink(timer) { setTimeout( function() {
        PUBNUB.css( textarea, { background : '#fff', color : '#222' } );

        if (audio.currentTime > 37)
            PUBNUB.events.fire('typing-no-longer-needed');

        typing && !is_done && setTimeout( function() {
            PUBNUB.css( textarea, { background : '#4e2', color : '#fff' } );
            type_vel < 140 && (type_vel = 200);
            increasing_blink(type_vel -= 50);
        }, timer );
    }, timer ); }
    is_done || increasing_blink(type_vel);

} );

PUBNUB.events.bind( 'typing-no-longer-needed', function() {
    is_done = 1;

    PUBNUB.each( PUBNUB.search('*'), function(elm) {
        PUBNUB.css( elm, { 'background' : '#f31' } );
    } );
} );

// ------------------------------------------------------------------------- //
// Typing Stopped
// ------------------------------------------------------------------------- //
PUBNUB.events.bind( 'typing-stopped', function() {
    PUBNUB.css( textarea, { background : '#fff' } );
    audio.pause();
} );

// ------------------------------------------------------------------------- //
// Change Username
// ------------------------------------------------------------------------- //
PUBNUB.bind( 'mousedown,touchstart', username_change, function() {
    username = (prompt('Username:')||'None').substr( 0, 10 );
    send_keystroke();

    // Save Username if Possible
    db && db.set( 'username', username );
} );

// ------------------------------------------------------------------------- //
// Turn OFF
// ------------------------------------------------------------------------- //
PUBNUB.bind( 'click', turn_off, function() {
    var turn_it_off = confirm("Turn OFF?");
    if (!turn_it_off) return;
    
    PUBNUB.css( settings, { 'display' : 'none' } );
    PUBNUB.unsubscribe({ 'channel' : channel });
} );


})();
