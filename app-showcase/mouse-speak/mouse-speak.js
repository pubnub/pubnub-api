(function(){

var PUB      = PUBNUB
,   bind     = PUB.bind
,   css      = PUB.css
,   body     = PUB.search('body')[0]
,   now      = function(){return+new Date}
,   mice     = {}
,   channel  = 'mouse-speak'
,   textbox  = PUBNUB.create('input')
,   focused  = 0    // Focused on Textbox?
,   lastpos  = []   // Last Sent Position
,   lasttxt  = ''   // Last Sent Text
,   sentcnt  = 0    // Number of Messages Sent
,   uuid     = ''   // User Identification
,   wait     = 200  // Publish Limit Delay
,   maxmsg   = 100  // Max Message Length
,   moffset  = 20   // Offset of Mouse Position
,   timed    = 0    // Timeout for Publish Limiter
,   lastsent = 0    // Last Sent Timestamp
,   nohtml   = /[<>]/g;

var Sprite = {
    /**
     * Adds to screen and creates DOM Object
     */
    create : function(sprite) {
        sprite.intervals = {
            animate : 0,
            move    : {}
        };

        sprite.cell.size = Math.floor(sprite.image.width / sprite.cell.count);
        sprite.node = PUBNUB.create('div');

        sprite.opacity = sprite.opacity || 1.0;

        PUBNUB.css( sprite.node, {
            opacity : sprite.opacity,
            position : 'absolute',
            top : sprite.top,
            left : sprite.left ,
            width : sprite.cell.size,
            height : sprite.image.height,
            backgroundRepeat: 'no-repeat',
            backgroundImage: 'url(' + sprite.image.url + ')'
        } );

        Sprite.setframe( sprite, 0 );
        Sprite.append(sprite.node);

        return sprite;
    },

    ground : body,
    append : function(node) {
        Sprite.ground.appendChild(node);
    },

    setframe : function( sprite, cell ) {
        PUBNUB.css( sprite.node, {
            backgroundPosition : '-' +
                (sprite.cell.size * cell + sprite.image.offset.left) +
                'px -' + sprite.image.offset.top + 'px'
        } );
    },

    /**
     * sprite.animate( [[frame, duration], []...] )
     * sprite.animate( [[], [], []] )
     * sprite.animate( [[0, .2], [1, .4], [2, .5]] )
     */
    animate : function( sprite, pattern, loop, callback, position ) {
        // Clear Any Other Animation
        if (!position) {
            position = 0;
            Sprite.stop_animate(sprite);
        }

        // if last frame, and no loop, then leave, else restart
        if (position === pattern.length) {
            if (loop === 0) return callback && callback();
            else {
                loop--;
                position = 0;
            }
        }

        // Multi format compatibility ([frame, delay]) or (frame)
        var frame = pattern[position][0] || pattern[position]
        ,   delay = pattern[position][1] || .1;

        sprite.intervals.animate = setTimeout( function() {
            // Update Current Frame
            Sprite.setframe( sprite, frame );

            // Next Frame
            Sprite.animate( sprite, pattern, loop, callback, position + 1 );
        }, delay * 1000 );
    },


    /**
     * Move and Animate Combined!!!
     *
     * sprite.animate( [ [left, top, duration, [animate] ], []...] )
     * sprite.animate( [[], [], []] )
     * sprite.animate( [[10, 10, .2, [ANIMATEPARAMS], loopanimate ], ... )
     */
    movie : function( sprite, pattern, loop, callback, position ) {
        // Clear Any Other Animation
        if (!position) {
            position = 0;
            Sprite.stop_all(sprite);
        }

        // if last frame, and no loop, then leave, else restart
        if (position === pattern.length) {
            if (loop === 0) return callback && callback();
            else {
                loop--;
                position = 0;
            }
        }

        // Update Animator
        if (pattern[position][2]) Sprite.animate(
            sprite,
            pattern[position][2],
            pattern[position][3] || 0
        );

    // [{top:0,opacity:.5}, 500, 0, 0],
        // Update Mover
        Sprite.move(
            sprite,
            pattern[position][0],
            pattern[position][1],
            function() {
                Sprite.movie( sprite, pattern, loop, callback, position + 1 );
            }
        );
    },

    /**
     * move sprite from one place to another.
     */
    move : function( sprite, properties, duration, callback ) {
        var start_time   = now();

        PUBNUB.each( properties, function( property, value ) {
            var current_time = start_time
            ,   end_time     = start_time + duration
            ,   start_prop   = sprite[property] || 0
            ,   distance     = value - start_prop
            ,   update       = {}
            ,   ikey         = property + value;

            Sprite.stop_move( sprite, ikey );
            sprite.intervals.move[ikey] = setInterval( function() {
                current_time = now();

                sprite[property] = (
                    end_time <= current_time
                    ? value
                    : ( distance * (current_time - start_time)
                        / duration + start_prop )
                );

                update[property] = sprite[property];
                PUBNUB.css( sprite.node, update );

                if ( end_time <= current_time && sprite.intervals.move ) {
                    Sprite.stop_move( sprite, ikey );
                    callback && callback();
                }

            }, Math.ceil(1000 / sprite.framerate) );
        } );
    },

    /**
     * Stop movie
     */
    stop_all : function(sprite) {
        clearTimeout(sprite.intervals.animate);
        PUBNUB.each( sprite.intervals.move, function( ikey ) {
            clearInterval(sprite.intervals.move[ikey]);
        } );
    },

    /**
     * Stop move.
     */
    stop_move : function( sprite, ikey ) {
        clearInterval(sprite.intervals.move[ikey]);
    },

    /**
     * Stop animate.
     */
    stop_animate : function(sprite) {
        clearTimeout(sprite.intervals.animate);
    },

    /**
     * 
     */
    somefunction : function(  ) {
    }
};


/*
    Get Mouse/Touch Position
    ------------------------
    Return Touch or Mouse Position... :-)
*/
function get_pos(e) {
    var posx = 0
    ,   posy = 0;

    if (!e) var e = window.event;

    if (!e) return [0,0];

    var touch = e['touches'] && e.touches[0];

    if (touch) {
        posx = touch.pageX;
        posy = touch.pageY;
    }
    else if (e.pageX || e.pageY) {
        posx = e.pageX;
        posy = e.pageY;
    }
    else if (e.clientX || e.clientY) {
        posx = e.clientX + body.scrollLeft
            + document.documentElement.scrollLeft;
        posy = e.clientY + body.scrollTop
            + document.documentElement.scrollTop;
    }

    posx += moffset;
    posy += moffset;

    if (posx <= moffset) posx = 0;
    if (posy <= moffset) posy = 0;

    return [posx, posy];
}


/*
    Send (Publish)
    --------------
    Publishes user's state to the group.
    Only send what was changed.
*/
function send(e) {
    // Leave if no UUID yet.
    if (!uuid) return;

    // If this is yourself, then Update UI RIGHT NOW!
    // TODO

    // Get Local Timestamp
    var right_now = now();

    // Don't continue if too soon (but check back)
    if (lastsent + wait > right_now) {
        // Come back and check after waiting.
        clearTimeout(timed);
        timed = setTimeout( function() {send(e)}, wait );

        return 0;
    }

    // Set Last Sent to Right Now.
    lastsent = right_now;

    // Capture User Input
    var pos = get_pos(e)
    ,   txt = get_txt()
    ,   msg = { uuid : uuid };

    // Don't send if no change in Position.
    if (!(
        lastpos[0] == pos[0] &&
        lastpos[1] == pos[1] ||
        !pos[0]              ||
        !pos[1]
    )) {
        // Update Last Position
        lastpos[0] = pos[0];
        lastpos[1] = pos[1];
        msg['pos'] = pos;
    }

    // Check Last Sent Text
    if (lasttxt != txt || !(sentcnt % 3)) {
        lasttxt    = txt;
        msg['txt'] = txt || ' ';
    }

    // No point sending nothing.
    if (!(msg['txt'] || msg['pos'])) return 0;

    /*
    console.log(JSON.stringify({
        channel : channel,
        message : msg
    }));
    */

    sentcnt++;

    PUB.publish({
        channel : channel,
        message : msg
    });

    return 0;
}

// User Joined
function user_joined(message) {
    var pos   = message['pos'] || [100,100]
    ,   mouse = Sprite.create({
        image : {
            url : 'mouse.png',
            width : 180,
            height : 100,
            offset : {
                top : 0,
                left : 0
            }
        },
        cell : {
            count : 1 // horizontal cell count
        },

        left : pos[1],
        top : pos[0],

        framerate : 24
    });

    // Set Class
    // attr( mouse.node, 'class', 'mouse-div' );

    // Set Prettier Text
    PUB.css( mouse.node, {
        'padding' : '20px',
        'fontSize' : '12px',
        'textShadow' : '#000 1px 1px 4px'
    } );

    // Save UUID
    PUB.attr( mouse.node, 'uuid', message['uuid'] );

    // Save User
    mice[message['uuid']] = mouse;

    // Update User
    user_updated(message);
}

// User has Moved Mouse or Typed
function user_updated(message) {
    var pos   = message['pos']
    ,   txt   = message['txt']
    ,   mouse = mice[message['uuid']];

    /*if (pos) PUB.css( mouse.node, {
        'top'  : pos[1],
        'left' : pos[0]
    } );*/
    // Sprite.move( Player.sprite, {left:40, top:30,opacity:.2}, 400,
    if (pos) Sprite.move( mouse, {
        'top'  : pos[1],
        'left' : pos[0]
    }, wait );

    if (txt) mouse.node.innerHTML = txt.replace( nohtml, '' );
}

// Receive Mice Friends
PUB.subscribe( { channel : channel }, function(message) {
    //TODO Remove this!!!!
    console.log(JSON.stringify(message));

    // Get User
    var theuuid = message['uuid'];

    // New User?
    if (!mice[theuuid]) return user_joined(message);

    // Update Existing User
    user_updated(message);
} );

// Capture Text Journey
function keystroke(e) {setTimeout(function(){
    if (e.keyCode==13) textbox.value = ' ';
    send(e);
},20);return 1}
function focused() {focused = 1;return 1}
function sevenofnine() {focused = 0;return 1}
function monopuff() {if (!focused){textbox.focus();focused = 1}return 1}
function get_txt() {return (textbox.value||'').slice( 0, maxmsg )}

// Load UUID and Send First Message
PUB.uuid(function(id){
    // Get UUID
    uuid = id;

    // User Landed on Page (First Message)
    setTimeout( send, wait );
});

// Add Input Textbox
PUB.css( textbox, {
    'position' : 'absolute',
    'top'      : -10000,
    'left'     : 0
} );
body.appendChild(textbox);

// Setup Events
bind( 'mousemove', document, send );
bind( 'touchmove', document, send );
bind( 'touchstart', document, send );
bind( 'keydown', document, monopuff );
bind( 'keyup', document, keystroke );

// Setup For Any Input Event.
PUB.each( search('input'), function(input) {
    bind( 'focus', input, focused );
    bind( 'blur', input, sevenofnine );
} );

})()
