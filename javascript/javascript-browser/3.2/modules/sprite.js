(function(){


var PUB     = PUBNUB
,   bind    = PUB.bind
,   css     = PUB.css
,   each    = PUB.each
,   utility = PUB.utility
,   now     = utility.now
,   ground  = PUB.search('body')[0];

function painter(node) {
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
        backgroundRepeat : 'no-repeat',
        backgroundImage  : 'url(' + sprite.image.url + ')'
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
                stop_move( sprite, ikey );
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

// Expose Global 'sprite' to PUBNUB
PUB['sprite'] = {
    'painter'      : painter,
    'create'       : create,
    'setframe'     : setframe,
    'animate'      : animate,
    'move'         : move,
    'movie'        : movie,
    'stop_all'     : stop_all,
    'stop_move'    : stop_move,
    'stop_animate' : stop_animate
};


})();
