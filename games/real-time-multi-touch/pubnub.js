(function(){


// ---------------
// Utility
// ---------------

var db     = this['localStorage']
,   PUB    = PUBNUB
,   now    = function(){return+new Date}
,   cookie = {
    get : function(key) {
        if (db) return db.getItem(key);
        if ((document.cookie||'').indexOf(key) == -1) return null;
        return ((document.cookie||'').match(
            RegExp(key+'=([^;]+)')
        )||[])[1] || null;
    },
    set : function( key, value ) {
        if (db) return db.setItem( key, value );
        document.cookie = key + '=' + value +
            '; expires=Thu, 1 Aug 2030 20:00:00 UTC; path=/';
    }
};

function updater( fun, rate ) {
    var timeout
    ,   last    = 0
    ,   runnit  = function() {
        var right_now = now();

        if (last + rate > right_now) {
            clearTimeout(timeout);
            timeout = setTimeout( runnit, rate );
        }
        else {
            last = now();
            fun();
        }
    };

    // Provide Rate Limited Function Call
    return runnit;
}

function mouse(e) {
    if (!e) return [[0,0]];

    var tch  = e.touches && e.touches[0]
    ,   mpos = [];

    if (tch) {
        PUB.each( e.touches, function(touch) {
            mpos.push([ touch.pageX, touch.pageY ]);
        } );
    }
    else if (e.pageX) {
        mpos.push([ e.pageX, e.pageY ]);
    }
    else {try{
        mpos.push([
            e.clientX + body.scrollLeft + doc.scrollLeft,
            e.clientY + body.scrollTop  + doc.scrollTop
        ]);
    }catch(e){}}

    return mpos;
}


/**
 * OFFSET
 * ======
 * offset( search('div')[0], 'Width' );
 * offset( search('div')[0], 'Height' );
 * offset( search('div')[0], 'Top' );
 * offset( search('div')[0], 'Left' );
 */
function offset( node, what ) {
    var pos  = 0
    ,   what = what || 'Top';

    while (node) {
        pos += node['offset'+what];
        node = node.offsetParent;
    }

    return pos
}

/**
 * WINFO
 * =====
 * var window_info = winfot();
 * log(window_info.height);
 */
function winfo() {
    return {
        height    : this.innerHeight ||
                    document.documentElement.clientHeight ||
                    document.body.clientHeight,
        scrollTop : document.documentElement.scrollTop ||
                    document.body.scrollTop,
        size      : offset(search('body')[0], 'Height')
    }
}


/* --------
   Provide a Player Creation/Management Interface.
   -------- */

var players = (function(){
    var players_obj = {};
    return {
        add : function(player) {
            players_obj[player['uuid']] = player;
            return player;
        },
        get : function(uuid) {
            return players_obj[uuid];
        },
        all : function() {
            return players_obj;
        }
    };
})();

/* --------
   Capture Current User's Information.
   -------- */

function current_player(ready) {
    function is_ready() {
        if (player['uuid'] && player['joined']) {
            players.add(player);
            ready(player)
        }
    }

    var player = {
        'uuid' : PUB.uuid(function(uuid){
            player['uuid'] = uuid;
            is_ready();
        }),
        'joined' : PUB.time(function(time){
            player['joined'] = time;
            is_ready();
        })
    };
}



// ---------------
// Sprite
// ---------------


var bind    = PUB.bind
,   each    = PUB.each
,   ground  = PUB.search('body')[0];

function painterr(node) {
    ground = node;
}

function create(sprite) {
    sprite.intervals = {
        animate : 0,
        move    : {}
    };

    sprite.cell.size = Math.floor(sprite.image.width / sprite.cell.count);
    sprite.node      = PUB.create('div');
    sprite.opacity   = sprite.opacity || 1.0;

    css( sprite.node, {
        opacity          : sprite.opacity,
        position         : 'absolute',
        top              : sprite.top,
        left             : sprite.left,
        width            : sprite.cell.size,
        height           : sprite.image.height,
        backgroundRepeat : 'no-repeat'//,
        // backgroundImage  : 'url(' + sprite.image.url + ')'
    } );

    setframe( sprite, 0 );
    append(sprite.node);

    return sprite;
}

function append(node) {
    ground.appendChild(node);
}

function setframe( sprite, cell, offset ) {
    var offset = offset || {};
    if (typeof offset.top == 'number')
        sprite.image.offset.top = offset.top;
    if (typeof offset.left == 'number')
        sprite.image.offset.left = offset.left;

    css( sprite.node, {
        backgroundPosition : '-' +
            (sprite.cell.size * cell + sprite.image.offset.left) +
            'px -' + sprite.image.offset.top + 'px'
    } );
}

/**
 * sprite.animate( [[frame, duration], []...] )
 * sprite.animate( [[], [], []] )
 * sprite.animate( [[0, .2], [1, .4], [2, .5]] )
 */
function animate( sprite, pattern, loop, callback, position ) {
    // Clear Any Other Animation
    if (!position) {
        position = 0;
        stop_animate(sprite);
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
        setframe( sprite, frame );

        // Next Frame
        animate( sprite, pattern, loop, callback, position + 1 );
    }, delay * 1000 );
}


/**
 * Move and Animate Combined!!!
 *
 * sprite.animate( [ [left, top, duration, [animate] ], []...] )
 * sprite.animate( [[], [], []] )
 * sprite.animate( [[10, 10, .2, [ANIMATEPARAMS], loopanimate ], ... )
 * sprite.animate( [[10, 10, .2, [[frame,dur], ...], loopanimate ], ... )
 */
function movie( sprite, pattern, loop, callback, position ) {
    // Clear Any Other Animation
    if (!position) {
        position = 0;
        stop_all(sprite);
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
    if (pattern[position][2]) animate(
        sprite,
        pattern[position][2],
        pattern[position][3] || 0
    );

    // [{top:0,opacity:.5}, 500, 0, 0],
    // Update Mover
    move(
        sprite,
        pattern[position][0],
        pattern[position][1],
        function() {
            movie( sprite, pattern, loop, callback, position + 1 );
        }
    );
}

/**
 * move sprite from one place to another.
 */
function move( sprite, properties, duration, callback ) {
    var start_time = now();

    stop_all(sprite);

    each( properties, function( property, value ) {
        var current_time = start_time
        ,   end_time     = start_time + duration
        ,   start_prop   = sprite[property] || 0
        ,   distance     = value - start_prop
        ,   update       = {}
        ,   ikey         = property + value;

        stop_move( sprite, ikey );
        sprite.intervals.move[ikey] = setInterval( function() {
            current_time = now();

            sprite[property] = (
                end_time <= current_time
                ? value
                : ( distance * (current_time - start_time)
                    / duration + start_prop )
            );

            update[property] = sprite[property];
            css( sprite.node, update );

            if ( end_time <= current_time && sprite.intervals.move ) {
                stop_all( sprite, ikey );
                callback && callback();
            }

        }, Math.ceil(1000 / sprite.framerate) );
    } );
}

/**
 * Stop movie
 */
function stop_all(sprite) {
    clearTimeout(sprite.intervals.animate);
    each( sprite.intervals.move, function( ikey ) {
        clearInterval(sprite.intervals.move[ikey]);
    } );
}

/**
 * Stop move.
 */
function stop_move( sprite, ikey ) {
    clearInterval(sprite.intervals.move[ikey]);
}

/**
 * Stop animate.
 */
function stop_animate(sprite) {
    clearTimeout(sprite.intervals.animate);
}





// ---------------
// Environment and Variables
// ---------------

var $       = PUB.$
,   css     = PUB.css
,   sprite  = {
    'painter'      : painterr,
    'create'       : create,
    'setframe'     : setframe,
    'animate'      : animate,
    'move'         : move,
    'movie'        : movie,
    'stop_all'     : stop_all,
    'stop_move'    : stop_move,
    'stop_animate' : stop_animate
}
,   player  = {
    'players'        : players,
    'current_player' : current_player
}
,   create  = PUB.create
,   publish = PUB.publish
,   points  = {}               // Tracking of all Pointers by UUID
,   painter = $('painter')
,   channel = 'pubnub-multi-touch'
,   wait    = 100
,   last    = 0                // Last sent touch/mouse event count.
,   master  = { joined : now(), is : 0 }
,   stage   = { width : 320, height : 480 };

// Set Relative Painter Node
sprite.painter(painter);

// Ping Pong (Send/Publish Message)
function ping_multi_touch(message) {
    publish({
        'channel' : channel,
        'message' : message
    });
}


// ---------------
// Current Player
// ---------------

var current_player = { ready : 0 };

// Create New Player
player.current_player(function(self){
    current_player.info  = self;
    current_player.ready = 1;
    // console.log('CURRENT_PLAYER: ', current_player);

    // Call Ready Function
    multi_touch_ready();
});

/*
*/

// Update Mouse Pointer (could be multiple pointers)
function update_pointer(e) {
    var pointers    = current_player.pointers = mouse(e)
    ,   offset_top  = offset( painter, 'Top' )
    ,   offset_left = offset( painter, 'Left' );
    // console.log(pointers);
    // console.log(offset_top, offset_left);

    each( pointers, function(pointer) {
        pointer[0] -= offset_left + 10;
        pointer[1] -= offset_top + 40;
        // Test for Collision Here
        // TODO
        /*
            -if collision, send publish event.
            -Set Position for each Pointer
        */
    } );

    // Draw Self Locally
    update_player({
        'pointers' : current_player.pointers,
        'uuid'     : '',
        'now'      : now()
    });

    // Send Latest Information (to draw on connected screens) (rate limited)
    publish_updater();

    // TODO (do i need this return?)
    return false;
}



// ---------------
// Events and Networking
// ---------------

// Called when Mouse Moves
var publish_updater = updater( function() {
    // This information is required before sending.
    if (!current_player.ready) return;

    // Send Player State
    ping_multi_touch({
        'action'   : 'player_state',
        'pointers' : current_player.pointers,
        'uuid'     : current_player.info.uuid,
        'last'     : last++
    });
}, wait );

// Called when new Player State ARIVES
function update_player(message) {
    var uuid     = message['uuid'] || 'self'
    ,   last     = message['last']
    ,   pointers = message['pointers']
    ,   i        = 0;

    // Don't draw if self.
    if (!current_player['info']) return
    if (uuid == current_player.info.uuid) return;
    /*
        -check if player uuid hash exsists,
            -if not then add player to players obj
            -check if player touch entry exists
                -if not then add touch entry.
        -draw each touch.
    */

    // Check if hash entry exists
    if (!points[uuid]) {
        points[uuid] = { last : last, touches : [] };
    }

    each( pointers, function(point) {

        // Create Sprite for the Pointer
        if (!points[uuid].touches[i]) {
            points[uuid].touches[i] = {
                xy     : point,
                sprite : sprite.create({
                    image : {
                        url    : '',
                        width  : 20,
                        height : 7,
                        offset : {
                            top  : 0,
                            left : 0
                        }
                    },
                    cell : {
                        count : 1
                    },
                    left : point[0],
                    top  : point[1],
                    framerate : 60
                })
            };

            // Temporary User Puck CSS
            css( points[uuid].touches[i].sprite.node, {
                'backgroundColor' : '#' + (
                    uuid == 'self' ?
                    ( current_player['info']['uuid'] || 'f0f') :
                    uuid
                ).slice(-3)
            } );
        }

        // Draw Pointer Locally
        if (uuid == 'self') {
            css( points[uuid].touches[i].sprite.node, {
                'left' : point[0],
                'top'  : point[1]
            } );
        }
        // Draw Remote Pointer
        else {
            sprite.move( points[uuid].touches[i].sprite, {
                'left' : point[0],
                'top'  : point[1]
            }, wait );
        }

        // Next Pointer
        i++;
    } );
}


// Listen for Game Messages
function multi_touch_ready() {
    PUB.subscribe( { 'channel' : channel }, function(message) {

        switch (message['action']) {
            case 'player_state' :
                update_player(message);
                break;

        }
    } );
}

// Set Browser to Gaming Mode
each(
    'mousedown,mousemove,touchmove,touchstart,touchend,selectstart'.split(','),
    function(ename) { bind( ename, document, update_pointer ) }
);

})();
