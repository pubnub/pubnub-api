(function(){

// -----------------------------------------------------------------------
// PAGE ELEMENTS
// -----------------------------------------------------------------------
var p          = PUBNUB
,   button     = p.$('button')
,   stages     = p.$('stages')
,   notify     = p.$('notify')
,   indicators = stages.getElementsByTagName('div')
,   light      = p.$('button-light');

// -----------------------------------------------------------------------
// PUBNUB SETUP
// -----------------------------------------------------------------------
var pubnub_setup = {
    channel       : 'sample-button-app',
    publish_key   : 'demo',
    subscribe_key : 'demo'
};

// -----------------------------------------------------------------------
// CREATE CONNECTION FOR USER EVENTS
// -----------------------------------------------------------------------
var user_event = io.connect( 'http://pubsub.pubnub.com/events', pubnub_setup );

// -----------------------------------------------------------------------
// WAIT FOR A CONNECTION
// -----------------------------------------------------------------------
user_event.on( 'connect', function() {
    advance();
    button.removeAttribute('disabled');
    button.innerHTML = 'Touch';
} );

// -----------------------------------------------------------------------
// LISTEN FOR A USER EVENT
// -----------------------------------------------------------------------
user_event.on( 'buttontouch', function(color) {

    notify.play();
    p.css( light, { background : color } );

    clearTimeout(button.timer);
    button.timer = setTimeout( function() {
        p.css( light, { background : '#fff' } );
    }, 200 );

} );

// -----------------------------------------------------------------------
// BUTTON CLICK
// -----------------------------------------------------------------------
p.bind( 'mousedown,touchstart', button, function() {
    user_event.emit( 'buttontouch', rnd_color() );
} );

// -----------------------------------------------------------------------
// RANDOM COLOR
// -----------------------------------------------------------------------
function rnd_hex() { return Math.ceil(Math.random()*9) }
function rnd_color() {
    return '#' + p.map(
        Array(3).join().split(','), rnd_hex
    ).join('');
}

// -----------------------------------------------------------------------
// ADVANCE STAGE INDICATORS
// -----------------------------------------------------------------------
indicators.stage = 0;
function advance() {
    var stage = indicators.stage++;
    setTimeout( function() {
        p.css( indicators[stage], { background : '#4a3' } );
    }, 400 * (stage === 2 ? (function(){ 
        p.css( stages, { background : '#7d6' } );
        setTimeout( function() {
            p.css( stages, { background : '#eeeee3' } );
        }, 300 );
        return 0;
    })() : stage) );
}

// -----------------------------------------------------------------------
// BEGIN INDICATOR LIGHT ADVANCEMENTS
// -----------------------------------------------------------------------
advance();
p.bind( 'load', window, advance );


})();
