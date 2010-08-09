(function(){


var PUB      = PUBNUB
,   $        = PUB.$
,   bind     = PUB.bind
,   attr     = PUB.attr
,   css      = PUB.css
,   each     = PUB.each
,   create   = PUB.create
,   head     = PUB.head()
,   highlgt
,   mehcount = 0
,   fbcss    = create('link')
,   fbhtml   = '<a id="facebook-meh-button-box"><div id="facebook-meh-button-text">Meh</div><div id="facebook-meh-button-img"></div></a><div id="facebook-meh-button-fb-img"></div><div id="facebook-meh-button-count-text">{count} {people} care.</div>'
,   fbbutton = $('facebook-meh-button')
,   channel  = location.href.replace( /\W/g, '' ).replace( /www/, '' )
               .split('').reverse().join('').slice( 0, 100 );

// Build FB "Meh" Button
function build_fb() {
    fbbutton.innerHTML = PUB.supplant( fbhtml, {
        'count'  : mehcount,
        'people' : mehcount == 1 ? "person doesn't" : "people don't"
    } );
}

// Add Styles
fbcss.href = 'http://cdn.pubnub.com/facebook/facebook-meh-button-style.css';
attr( fbcss, 'rel',  'stylesheet' );
attr( fbcss, 'type', 'text/css' );
head.appendChild(fbcss);

// Build FB "Meh" Button
PUB.history( { 'channel' : channel }, function(messages) {
    each( messages, function(message) {
        var count = message['c'] || 0;
        if (count > mehcount) mehcount = count;
    } );
    build_fb();
} );

// Click FB "Meh" Button
bind( 'mousedown', fbbutton, function (e) {
    var target = attr( e.target || e.srcElement, 'id' );

    // If hit the button
    if (!(
        target.indexOf('button-text') > 0 ||
        target.indexOf('button-img')  > 0 ||
        target.indexOf('button-box')  > 0
    )) return false;

    // Send "Meh" Click
    PUB.publish({ 'channel' : channel, 'message' : { 'c' : mehcount + 1 } });
    return false;
} );



// Prevent Highlight of Button
each(
    'touchmove,touchstart,touchend,selectstart'.split(','),
    function(en) { bind( en, fbbutton, function(){return false} ) }
);

// When ready to start listening for clicks
bind( 'load', window, function() {
    // Listen for Clicks
    PUB.subscribe( { 'channel' : channel }, function(message) {
        css( fbbutton, { 'background' : '#f90' } );
        clearTimeout(highlgt);

        highlgt = setTimeout( function() {
            css( fbbutton, { 'background' : 'transparent' } );
        }, 1000 );

        mehcount++;
        build_fb();
    } );
} );


})();
