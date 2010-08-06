(function(){

/*
    - TODO -
    -make sprite ball
        -have it bounce around the stage.
        -
    -make players
        -some puck graphic
        -can hit ball
        -
    -pretty
        -player bump particles (when player's touch)
        -ball bump particles (when player hits ball)
        -score (snazzy sparkles and animated characters)
        -ball squash stretch.
        -cool background
*/

// ---------------
// Environment and Variables
// ---------------


var PUB     = PUBNUB
,   $       = PUB.$
,   bind    = PUB.bind
,   css     = PUB.css
,   each    = PUB.each
,   create  = PUB.create
,   sprite  = PUB.sprite
,   publish = PUB.publish
,   utility = PUB.utility
,   now     = utility.now
,   updater = utility.updater
,   player  = PUB.player
,   players = player.players
,   mouse   = utility.mouse
,   painter = $('painter')
,   channel = 'pong'
,   wait    = 100
,   master  = { joined : now(), count : 0, reset : 60 }
,   stage   = { width : 320, height : 480 };

// Set Relative Painter Node
sprite.painter(painter);

// Ping Pong (Send/Publish Message)
function ping_pong(message) {
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
    console.log('CURRENT_PLAYER: ', current_player);

    // Call Ready Function
    pong_ready();
});

// Setup Current Player
current_player.sprite = sprite.create({
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
    left : 0,
    top  : 0,
    framerate : 60
});

// Temporary User Puck CSS
css( current_player.sprite.node, { 'backgroundColor' : '#00f' } );

// Called when Mouse Movies
var publish_updater = updater( function() {
    // This information is required before sending.
    if (!current_player.ready) return;

    // Send Player State
    ping_pong({
        'action'   : 'player_state',
        'pointers' : current_player.pointers,
        'uuid'     : current_player.info.uuid,
        'now'      : now()
    });
}, wait );

// Update Mouse Pointer (could be multiple pointers)
function update_pointer(e) {
    var pointers = current_player.pointers = mouse(e);
    //console.log(pointers);

    each( pointers, function(pointer) {
        // Test for Collision Here
        // TODO
        /*
            -if collision, send publish event.
            -Set Position for each Pointer
        */
    } );

    // Send Latest Information (rate limited)
    publish_updater();

    // TODO (do i need this return?)
    return false;
}


// ---------------
// Ball
// ---------------


var ball = sprite.create({
        image : {
            url    : '',
            width  : 10,
            height : 10,
            offset : {
                top  : 0,
                left : 0
            }
        },
        cell : {
            count : 1
        },
        left : stage.width  / 2,
        top  : stage.height / 2,
        framerate : 60
});
css( ball.node, { 'backgroundColor' : '#f00' } );
ball.phys = {
    x_vel     : 10,
    y_vel     : 10,
    min_x_vel : 10,
    min_y_vel : 10,
    max_x_vel : 15,
    max_y_vel : 15,
    duration  : wait * 2
};

// Ball Animation Loop
function animate_ball() {
    // Reduce to Min Speed Slowly
    if (ball.phys.x_vel > ball.phys.min_x_vel) ball.phys.x_vel--;
    if (ball.phys.y_vel > ball.phys.min_y_vel) ball.phys.y_vel--;

    // Reduce speed if Over Max
    if (ball.phys.x_vel > ball.phys.max_x_vel)
        ball.phys.x_vel = ball.phys.max_x_vel;
    if (ball.phys.y_vel > ball.phys.min_y_vel)
        ball.phys.y_vel = ball.phys.max_y_vel;

    // Stage Bounding
    if (ball.top + 10 > stage.height || ball.top < 10) {
        // TODO (this will prevent the ball from getting stuck!!!
        // if (ball.phys.x_vel > 0) css({
        ball.phys.y_vel *= -1.5;
    }
    if (ball.left + 10 > stage.width || ball.left < 10) {
        // TODO (this will prevent the ball from getting stuck!!!
        // if (ball.phys.x_vel > 0) css({
        ball.phys.x_vel *= -1.5;
    }

    // Animate for ball.phys.duration duration.
    sprite.move( ball, {
        top  : ball.top  + ball.phys.y_vel,
        left : ball.left + ball.phys.x_vel
    }, ball.phys.duration, animate_ball );
}

// Beggin Ball Bouncing!
animate_ball();


// ---------------
// Events and Networking
// ---------------


// Called with new Game/Ball State
function update_game(message) {

    console.log('JOINED: ' + current_player.info.joined);
    console.log('MSGJOINED: ' + message['joined']);

    // Don't update if Self or from a new player.
    if (current_player.info.joined <= message['joined']) return;

    // Capture Oldest
    if (master.joined >= message['joined']) {
        master.joined = message['joined'];
        if (master.count++ > master.reset) {
            master.count  = 0;
            master.joined = now();
        }
    }
    else return;

    ball.phys.x_vel = message['ball']['x_vel'];
    ball.phys.y_vel = message['ball']['y_vel'];

    // Animate for ball.phys.duration duration.
    sprite.move( ball, {
        top  : message['ball']['top'],
        left : message['ball']['left']
    }, ball.phys.duration / 2, animate_ball );

    /*
        -am i older than this message?
            -then ignore it cuz I'm boss
        -else
            -update ball physics and position.
    */
}

// Called when new Player State ARIVES
function update_player(message) {
    /*
        -check if player exsists,
            -if not then add player to players obj
        -draw
    */
}

// Called when we need to send game state
function send_game_state(message) {
    // Don't send game state if not init'ed.
    if (!current_player.ready) return;

    // Don't send if Self or if not game master.
    if (current_player.info.joined >= message['joined']) return;

    ping_pong({
        'action' : 'game_state',
        'uuid'   : current_player.info.uuid,
        'joined' : current_player.info.joined,
        'ball'   : {
            'x_vel' : ball.phys.x_vel,
            'y_vel' : ball.phys.y_vel,
            'top'   : ball.top,
            'left'  : ball.left
        }
    });
}


// Request Latest Game State
function request_game_state() {
    ping_pong({
        'action' : 'request_game_state',
        'joined' : current_player.info.joined
    });
}

// Listen for Game Messages
function pong_ready() {
    PUB.subscribe( { 'channel' : channel }, function(message) {
        console.log('message: ' + JSON.stringify(message));

        switch (message['action']) {
            case 'player_state' :
                update_player(message);
                break;

            case 'game_state' :
                update_game(message)
                break;

            case 'request_game_state' :
                send_game_state(message);
                break;
        }
    } );

    // Keep Game State Up-to- Date
    request_game_state();
    setInterval( function() { setTimeout( function() {
        request_game_state()
    }, Math.ceil(Math.random() * 400 + 100) ) }, 400 );
}

// Set Browser to Gaming Mode
each(
    'mousedown,mousemove,touchmove,touchstart,touchend,selectstart'.split(','),
    function(ename) { bind( ename, document, update_pointer ) }
);

})();
