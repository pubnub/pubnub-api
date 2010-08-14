(function(){

/*

    IMPORTANT!!!
    Copy this div into your HTML just above the script.

    <div id="facebook-meh-button"></div>

*/


var PUB      = PUBNUB
,   $        = PUB.$
,   bind     = PUB.bind
,   attr     = PUB.attr
,   css      = PUB.css
,   each     = PUB.each
,   create   = PUB.create
,   head     = PUB.head()
,   db       = window['localStorage']
,   cookie   = {
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
},  highlgt
,   highed   = 0
,   mehcount = 0
,   clicked  = 0
// ,   fbcss    = create('link')
,   fbhtml   = '<div id="facebook-meh-button-relative" style="position:relative;cursor:default;padding:0;margin:0;height:34px;z-index:1">' +
               '<div id="facebook-meh-button-box" style="position:absolute;cursor:pointer;padding:0;margin:0;top:5px;left:5px;border-radius:3px;-moz-border-radius:3px;-webkit-border-radius:3px;border:1px solid #cad4e7;background:#eceef5;width:54px;height:22px;z-index:1">' +
                   '<div id="facebook-meh-button-text" style="position:absolute;padding:0;margin:0;padding:0;margin:0;top:5px;left:28px;color:#3b5998;font-family:\'lucida grande\',tahoma,verdana,arial,sans-serif;font-size:11px;line-height:11px;z-index:3">Meh</div>' +
                   '<div id="facebook-meh-button-img" style="position:absolute;padding:0;margin:0;top:5px;left:6px;background:transparent url(http://cdn.pubnub.com/facebook/meh.gif) no-repeat;width:17px;height:12px;z-index:2"></div>' +
               '</div>' +
               '<div id="facebook-meh-button-fb-img" style="position:absolute;padding:0;margin:0;top:11px;left:68px;background:transparent url(http://cdn.pubnub.com/facebook/meh.gif) no-repeat -18px 0;width:14px;height:14px;z-index:2"></div>' +
               '<div id="facebook-meh-button-count-text" style="position:absolute;padding:0;margin:0;top:11px;left:86px;color:#333;font-family:\'lucida grande\',tahoma,verdana,arial,sans-serif;font-size:11px;line-height:11px;z-index:3">{count} {people} care.</div>' +
               '</div>'
,   fbbutton = $('facebook-meh-button')
,   oneclick = attr( fbbutton, 'one-click-per-person' ) == 'on'
// ,   allpages = attr( fbbutton, 'different-count-per-page' ) == 'on'
,   channel  = location.href.replace( /\W/g, '' ).replace( /www/, '' )
               .split('').reverse().join('').slice( 0, 100 )
,   hasclick = cookie.get('hasclick:' + channel);

// Build FB "Meh" Button
function build_fb() {
    fbbutton.innerHTML = PUB.supplant( fbhtml, {
        'count'  : mehcount,
        'people' : mehcount == 1 ? "person doesn't" : "people don't"
    } );
}

// FBButton CSS
attr( fbbutton, 'style', '-webkit-user-select:none;-webkit-touch-callout:none;-webkit-tap-highlight-color:rgba(0,0,0,0);-webkit-text-size-adjust:none;border-radius:6px;-moz-border-radius:6px;-webkit-border-radius:6px;' );

// Mouse Over and Out
bind( 'mouseover', fbbutton, function() {
    highlight_button( '#9dacce', 1 );
} );
bind( 'mouseout', fbbutton, function() {
    highlight_button( 'transparent', 1 );
} );

// Build FB "Meh" Button
PUB.history( { 'channel' : channel }, function(messages) {
    each( messages, function(message) {
        var count = message['c'] || 0;
        if (count > mehcount) mehcount = count;
    } );
    build_fb();
} );

// Highlight FBButton
function highlight_button( color, stay ) {
    // Don't Re-hightlight
    if (highed) return;
        highed = 1;

    css( fbbutton, { 'background' : color } );

    clearTimeout(highlgt);
    if (!stay) {
        highlgt = setTimeout( function() {
            css( fbbutton, { 'background' : 'transparent' } );
            highed = 0;
        }, 1000 );
    }
    else {
        highed = 0;
    }
}

// Click FB "Meh" Button
function fb_click(e) {
    // Prevent Multiple Events
    if (clicked) return false;
        clicked = 1;

    // Just in case
    setTimeout( function() { clicked = 0 }, 1000 );

    // Find Target Click
    var target = attr( e.target || e.srcElement, 'id' )
    ,   message;

    // If hit the button
    if (!(
        target.indexOf('button-text') > 0 ||
        target.indexOf('button-img')  > 0 ||
        target.indexOf('button-box')  > 0
    )) return false;

    // Figure "Meh" Message
    if (oneclick && hasclick) {
        message = {'c' : mehcount, 'h' : '1'};
        highlight_button('#eca');
    }
    else {
        mehcount++;
        build_fb();
        message = {'c' : mehcount};
        highlight_button('#f90');
    }

    // Send "Meh" Click
    PUB.publish({'channel' : channel, 'message' : message });

    // Save Has Clicked
    cookie.set( 'hasclick:' + channel, '1' );
    hasclick = 1;

    return false;
}

// Caputre Click Early + Prevent Highlight of Button
each(
    'mousedown,mouseup,click,touchmove,touchstart,touchend,selectstart'.split(','),
    function(en) { bind( en, fbbutton, fb_click ) }
);

// When ready to start listening for clicks
bind( 'load', window, function() { setTimeout(function() {
    // Listen for Clicks
    PUB.subscribe( { 'channel' : channel }, function(message) {
        // Increment
        if (!message['h'] && mehcount != message['c']) {
            mehcount++;
            build_fb();
            highlight_button('#f90');
        }
        else {
            highlight_button('#eca');
        }
    } );
}, 100 ) } );


})();
