(function(){

/*
    www.pubnub.com - PubNub realtime push service in the cloud. 
    http://www.pubnub.com/blog/mouse-speak - Mouse Speak 

    PubNub Real Time Push APIs and Notifications Framework
    Copyright (c) 2010 Stephen Blum
    http://www.google.com/profiles/blum.stephen

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

var bind        = PUBNUB.bind
,   css         = PUBNUB.css
,   body        = PUBNUB.search('body')[0]
,   doc         = document.documentElement
,   now         = function(){return+new Date}
,   mice        = {}
,   channel     = 'mouse-speak'
,   mousefade   = 30000  // Time before user is considered Inactive
,   textbox     = PUBNUB.create('input')
,   focused     = 0      // Focused on Textbox?
,   lastpos     = []     // Last Sent Position
,   lasttxt     = ''     // Last Sent Text
,   lastletrs   = {}     // Prevent Redraw Spam (Fading Text)
,   sentcnt     = 0      // Number of Messages Sent
,   uuid        = 0      // User Identification
,   wait        = 120    // Publish Rate Limit (Time Between Data Push)
,   maxmsg      = 34     // Max Message Length
,   moffset     = -60    // Offset of Mouse Position
,   timed       = 0      // Timeout for Publish Limiter
,   lastsent    = 0      // Last Sent Timestamp
,   nohtml      = /[<>]/g;


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
            height : sprite.image.height
        } );

        Sprite.setframe( sprite, 0 );
        Sprite.append(sprite.node);

        return sprite;
    },

    ground : PUBNUB.search('body')[0],
    append : function(node) {
        Sprite.ground.appendChild(node);
    },

    setframe : function( sprite, cell, offset ) {
        var offset = offset || {};
        if (typeof offset.top == 'number')
            sprite.image.offset.top = offset.top;
        if (typeof offset.left == 'number')
            sprite.image.offset.left = offset.left;

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
     * sprite.animate( [[10, 10, .2, [[frame,dur], ...], loopanimate ], ... )
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

        Sprite.stop_all(sprite);

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

    if (!e) return [0,0];

    var tch  = e.touches && e.touches[0]
    ,   tchp = 0;

    if (tch) {
        PUBNUB.each( e.touches, function(touch) {
            posx = touch.pageX;
            posy = touch.pageY;

            // Send Normal Touch on First Touch
            if (!tchp) return;

            // Must be more touches!
            // send({ 'pageX' : posx, 'pageY' : posy, 'uuid' : uuid+tchp++ });
        } );
    }
    else if (e.pageX) {
        posx = e.pageX;
        posy = e.pageY;
    }
    else {try{
        posx = e.clientX + body.scrollLeft + doc.scrollLeft;
        posy = e.clientY + body.scrollTop  + doc.scrollTop;
    }catch(e){}}

    posx += moffset*2;
    posy += moffset/4|1;

    if (posx <= moffset*2) posx = 0;
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

    // Get Local Timestamp
    var right_now = now()
    ,   mouse     = mice[uuid];

    // Don't continue if too soon (but check back)
    if (lastsent + wait > right_now) {
        // Come back and check after waiting.
        clearTimeout(timed);
        timed = setTimeout( function() {send(e)}, wait );

        return 1;
    }

    // Set Last Sent to Right Now.
    lastsent = right_now;

    // Capture User Input
    var pos   = get_pos(e)
    ,   txt   = get_txt()
    //,   xuuid = e['uuid']
    ,   msg   = { 'uuid' : /*xuuid ||*/ uuid };

    if (!mouse) return user_joined(msg);

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
    if (lasttxt != txt || !(sentcnt++ % 3)) {
        lasttxt    = txt;
        msg['txt'] = txt || ' ';
    }

    // No point sending nothing.
    if (!(msg['txt'] || msg['pos'])) return 1;

    // Set so we won't get jittery mice.
    msg['c'] = (mice[uuid].last||1) + 2;

    PUBNUB.publish({
        channel : channel,
        message : msg
    });

    msg['force'] = 1;
    user_updated(msg);

    return 1;
}

// User Joined
function user_joined(message) {
    var pos   = message['pos'] || [10,10]
    ,   mouse = Sprite.create({
        image : {
            width : 260,
            height : 30,
            offset : {
                top : 200,
                left : 0
            }
        },
        cell : {
            count : 1 // horizontal cell count
        },

        left : pos[1],
        top : pos[0],

        framerate : 50
    });


    // Do something when you mouseover.
    if (uuid != message['uuid']) bind( 'mouseover', mouse.node, function() {
        Sprite.move( mouse, {
            'opacity' : 0.5/*,
            'top'     : Math.ceil(Math.random()*150),
            'left'    : 10*/
        }, wait );
    } );

    // Set Prettier Text
    PUBNUB.attr( mouse.node, 'class', 'mouse-speak' );

    // Save UUID
    PUBNUB.attr( mouse.node, 'uuid', message['uuid'] );

    // Save User
    mice[message['uuid']] = mouse;

    // Save Animation Key States
    mouse.last_seen_message = '';

    // Update User
    user_updated(message);
}

fading_text.trx = /X\(8/g;
function fading_text( message, mouse ) { 
    var p      = PUBNUB
    ,   lastln = mouse.last_seen_message.length
    ,   text   = lastln < message.length ? message.substr(lastln) : message;

    p.each( text.split(''), function( key, pos ) {
        // Delete Command
        if (key === '+' && mouse.node.getElementsByTagName('span')[0]) {
            return mouse.node.removeChild(mouse.node.getElementsByTagName('span')[0]);
        }

        var span = p.create('span');

        span.innerHTML = key === ' ' ? '&nbsp;' : key;

        if (pos < 5)
            p.attr( span, 'class', 'mouse-letter' );
        else
            p.attr( span, 'class', 'mouse-letter-speedy' );

        if (mouse.node.firstChild)
            mouse.node.insertBefore( span, mouse.node.firstChild );
        else
            mouse.node.appendChild(span);

        setTimeout( function() { 
            p.attr(
                span,
                'style', [
                'text-shadow: 0 0 0 #e45',
                '-webkit-transform: rotate(0deg) scale(1.0) translateX(0px)',
                '-moz-transform: rotate(0deg) scale(1.0) translateX(0px)',
                '-ms-transform: rotate(0deg) scale(1.0) translateX(0px)',
                '-o-transform: rotate(0deg) scale(1.0) translateX(0px)',
                'transform: rotate(0deg) scale(1.0) translateX(0px)'
            ].join(';') );
        }, 80 * pos );
    } );

    p.each( mouse.node.getElementsByTagName('span'), function( spn, pos ) {
        var blur = (maxmsg/1.5|1)
        ,   chng = pos - blur;

        if (pos < blur) return;

        if (!('gone' in spn)) setTimeout( function() { p.attr(
            spn,
            'style', [
            'text-shadow: 0 0 '+chng+'px #e45',
            '-webkit-transform: rotate(0deg) scale(1.0) translateX(0px)',
            '-moz-transform: rotate(0deg) scale(1.0) translateX(0px)',
            '-ms-transform: rotate(0deg) scale(1.0) translateX(0px)',
            '-o-transform: rotate(0deg) scale(1.0) translateX(0px)',
            'transform: rotate(0deg) scale(1.0) translateX(0px)'
        ].join(';') ); }, 1000 );

        if (pos < maxmsg) return;

        if ('gone' in spn) return;
        spn.gone = 1;

        setTimeout( function() {
            p.attr(
                spn,
                'style', [
                'opacity:0'
            ].join(';') );
        }, 3000 );
    } );

    mouse.last_seen_message = message;
}

// User has Moved Mouse or Typed
function user_updated(message) {
    var pos   = message['pos']
    ,   click = message['click']
    ,   txt   = message['txt']
    ,   last  = message['c']
    ,   force = message['force']
    ,   tuuid = message['uuid']
    ,   mouse = mice[tuuid];

    if (!mouse) return user_joined(message);

    // Common to reset value if page reloaded
    if (last && (mouse.last||0) - last > 100)
        mouse.last = last;

    // Self
    ///if (force) mouse.last = last;

    // Prevent Jitter from Early Publish
    if (
        !force            &&
        last              &&
        mouse.last        &&
        mouse.last > last
    ) return;

    // Set last for the future.
    if (last) mouse.last = last;

    // Update Text Display
    if (txt && lastletrs[tuuid] != txt) {
        fading_text( txt.replace( nohtml, ' ' ), mouse );
    }

    txt && (lastletrs[tuuid] = txt);

    // Set Delay to Fade User Out on No Activity.
    mouse.timerfade && clearTimeout(mouse.timerfade);
    mouse.timerfade = setTimeout( function() {
        PUBNUB.css( mouse.node, { 'opacity' : 0.4 } );
        clearTimeout(mouse.timerfade);
        mouse.timerfade = setTimeout( function() {
            PUBNUB.css( mouse.node, { 'display' : 'none' } );
        }, mousefade );
    }, mousefade );

    // Reshow if hidden.
    PUBNUB.css( mouse.node, {
        'display' : 'block',
        'opacity' : 1.0
    } );

    // Move Player.
    if (pos) {
        Sprite.move( mouse, {
            'left' : pos[0],
            'top'  : pos[1]
        }, wait - 10 );

        // Change Direction
        if (pos[0] > mouse.left)
            Sprite.setframe( mouse, 0, { top : 200 } );
        else if (pos[0] < mouse.left)
            Sprite.setframe( mouse, 0, { top : 200 } );
    }
}

// Receive Mice Friends
PUBNUB.subscribe( { channel : channel }, user_updated );

// Capture Text Journey
function keystroke( e, key ) {
    setTimeout( function(){
        if (',13,27,'.indexOf(','+key+',') !== -1) textbox.value = ' ';
        if (8 === key) textbox.value += '+';
        send(e);
    }, 20 );
    return (8 !== key);
}

var ignore_keys = ',18,37,38,39,40,46,20,17,35,36,33,34,16,9,91,';
function focusize() {focused = 1;return 1}
function monopuff(e) {
    var key = e.keyCode;

    if (ignore_keys.indexOf(','+key+',') !== -1)
        return 0;

    if (!focused)
        textbox.focus();

    return keystroke( e, key );
}
function get_txt() {
    var val = (textbox.value||'')
    ,   len = val.length;

    if (len > maxmsg) {
        textbox.value = '';
    }
    else if (val.indexOf(init_text) > 0) {
        textbox.value = val = val.replace( init_text, '' );
    }

    return val;
}

// Load UUID and Send First Message
if (!uuid) PUBNUB.uuid(function(id){
    // Get UUID
    uuid = id;

    // User Landed on Page (First Message)
    setTimeout( function(){send({})}, wait );
});

// Add Input Textbox
PUBNUB.css( textbox, {
    'position' : 'absolute',
    'top'      : -10000,
    'left'     : 0
} );
var init_text = 'Hello. Start Typing... ';
textbox.value = init_text;
body.appendChild(textbox);

// Setup Events
bind( 'mousemove',  document, send );
bind( 'touchmove',  document, send );
bind( 'touchstart', document, send );
bind( 'touchend',   document, send );
bind( 'keydown',    document, monopuff );
bind( 'touchmove,mousemove,mousedown,touchstart', document, function() {
    '-stop' in parent && parent['-stop']();
    textbox.focus();
    return true;
} );


})()
