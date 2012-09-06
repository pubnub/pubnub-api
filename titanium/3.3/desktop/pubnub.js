/*
    WAIT! - This file depends on instructions from the PUBNUB Cloud.

    http://www.pubnub.com/account
*/

/*
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

/* =-=====================================================================-= */
/* =-=====================================================================-= */
/* =-========================     DOM UTIL     ===========================-= */
/* =-=====================================================================-= */
/* =-=====================================================================-= */

window['PUBNUB'] || (function() {

/**
 * CONSOLE COMPATIBILITY
 */
window.console||(window.console=window.console||{});
console.log||(console.log=((window.opera||{}).postError||function(){}));

/**
 * UTIL LOCALS
 */
var NOW    = 1
,   MAGIC  = /\$?{([\w\-]+)}/g
,   ASYNC  = 'async'
,   URLBIT = '/'
,   XHRTME = 140000
,   XORIGN = 1;

/**
 * UNIQUE
 * ======
 * var timestamp = unique();
 */
function unique() { return'x'+ ++NOW+''+(+new Date) }

/**
 * $
 * =
 * var div = $('divid');
 */
function $(id) { return document.getElementById(id) }

/**
 * LOG
 * ===
 * log('message');
 */
function log(message) { console['log'](message) }

/**
 * SEARCH
 * ======
 * var elements = search('a div span');
 */
function search(elements) {
    var list = [];
    each( elements.split(/\s+/), function(el) {
        each( document.getElementsByTagName(el), function(node) {
            list.push(node);
        } );
    } );
    return list;
}

/**
 * EACH
 * ====
 * each( [1,2,3], function(item) { console.log(item) } )
 */
function each( o, f ) {
    if ( !o || !f ) return;

    if ( typeof o[0] != 'undefined' ) for ( var i = 0, l = o.length; i < l; )
        f.call( o[i], o[i], i++ );
    else for ( var i in o )
        o.hasOwnProperty    &&
        o.hasOwnProperty(i) &&
        f.call( o[i], i, o[i] );
}

/**
 * MAP
 * ===
 * var list = map( [1,2,3], function(item) { return item + 1 } )
 */
function map( list, fun ) {
    var fin = [];
    each( list || [], function( k, v ) { fin.push(fun( k, v )) } );
    return fin;
}

/**
 * GREP
 * ====
 * var list = grep( [1,2,3], function(item) { return item % 2 } )
 */
function grep( list, fun ) {
    var fin = [];
    each( list || [], function(l) { fun(l) && fin.push(l) } );
    return fin
}

/**
 * SUPPLANT
 * ========
 * var text = supplant( 'Hello {name}!', { name : 'John' } )
 */
function supplant( str, values ) {
    return str.replace( MAGIC, function( _, match ) {
        return ''+values[match] || ''
    } );
}

/**
 * BIND
 * ====
 * bind( 'keydown', search('a')[0], function(element) {
 *     console.log( element, '1st anchor' )
 * } );
 */
function bind( type, el, fun ) {
    each( type.split(','), function(etype) {
        var rapfun = function(e) {
            if (!e) var e = window.event;
            if (!fun(e)) {
                e.cancelBubble = true;
                e.returnValue  = false;
                e.preventDefault && e.preventDefault();
                e.stopPropagation && e.stopPropagation();
            }
        };

        if ( el.addEventListener ) el.addEventListener( etype, rapfun, false );
        else if ( el.attachEvent ) el.attachEvent( 'on' + etype, rapfun );
        else  el[ 'on' + etype ] = rapfun;
    } );
}

/**
 * UNBIND
 * ======
 * unbind( 'keydown', search('a')[0] );
 */
function unbind( type, el, fun ) {
    if ( el.removeEventListener ) el.removeEventListener( type, false );
    else if ( el.detachEvent ) el.detachEvent( 'on' + type, false );
    else  el[ 'on' + type ] = null;
}

/**
 * HEAD
 * ====
 * head().appendChild(elm);
 */
function head() { return search('head')[0] }

/**
 * ATTR
 * ====
 * var attribute = attr( node, 'attribute' );
 */
function attr( node, attribute, value ) {
    if (value) node.setAttribute( attribute, value );
    else return node && node.getAttribute && node.getAttribute(attribute);
}

/**
 * CSS
 * ===
 * var obj = create('div');
 */
function css( element, styles ) {
    for (var style in styles) if (styles.hasOwnProperty(style))
        try {element.style[style] = styles[style] + (
            '|width|height|top|left|'.indexOf(style) > 0 &&
            typeof styles[style] == 'number'
            ? 'px' : ''
        )}catch(e){}
}

/**
 * CREATE
 * ======
 * var obj = create('div');
 */
function create(element) { return document.createElement(element) }

/**
 * timeout
 * =======
 * timeout( function(){}, 100 );
 */
function timeout( fun, wait ) { return setTimeout( fun, wait ) }

/**
 * jsonp_cb
 * ========
 * var callback = jsonp_cb();
 */
function jsonp_cb() { return XORIGN ? 0 : unique() }

/**
 * ENCODE
 * ======
 * var encoded_path = encode('path');
 */
function encode(path) {
    return map( (''+path).split(''), function(chr) {
        return " ~`!@#$%^&*()+=[]\\{}|;':\",./<>?".indexOf(chr) > -1 ?
               "%"+chr.charCodeAt(0).toString(16).toUpperCase()      : chr
    } ).join('');
}

/**
 * Titanium XHR Request
 * ====================
 *  xdr({
 *     url     : ['http://www.blah.com/url'],
 *     success : function(response) {},
 *     fail    : function() {}
 *  });
 */
function xdr( setup ) {
    var xhr
    ,   finished = function() {
            if (loaded) return;
                loaded = 1;

            clearTimeout(timer);

            try       { response = JSON['parse'](xhr.responseText); }
            catch (r) { return done(1); }

            success(response);
        }
    ,   complete = 0
    ,   loaded   = 0
    ,   timer    = timeout( function(){done(1)}, XHRTME )
    ,   fail     = setup.fail    || function(){}
    ,   success  = setup.success || function(){}
    ,   done     = function(failed) {
            if (complete) return;
                complete = 1;

            clearTimeout(timer);

            if (xhr) {
                xhr.onerror = xhr.onload = null;
                xhr.abort && xhr.abort();
                xhr = null;
            }

            failed && fail();
        };

    // Send
    try {
        xhr         = Titanium.Network.createHTTPClient();
        xhr.onerror = function(){ done(1) };
        xhr.onload  = finished;
        xhr.timeout = XHRTME;

        xhr.open( 'GET', setup.url.join(URLBIT), true );
        xhr.send();
    }
    catch(eee) {
        done(0);
        return xdr(setup);
    }

    // Return 'done'
    return done;
}


/* =-=====================================================================-= */
/* =-=====================================================================-= */
/* =-=========================     PUBNUB     ============================-= */
/* =-=====================================================================-= */
/* =-=====================================================================-= */

var PN            = $('pubnub')
,   DEMO          = 'demo'
,   PUBLISH_KEY   = attr( PN, 'pub-key' ) || DEMO
,   SUBSCRIBE_KEY = attr( PN, 'sub-key' ) || DEMO
,   SSL           = attr( PN, 'ssl' ) == 'on' ? 's' : ''
,   ORIGIN        = 'http'+SSL+'://'+(attr(PN,'origin')||'pubsub.pubnub.com')
,   LIMIT         = 1800
,   READY_BUFFER  = []
,   CHANNELS      = {}
,   PUBNUB        = {
    /*
        PUBNUB.history({
            channel  : 'my_chat_channel',
            limit    : 100,
            callback : function(messages) { console.log(messages) }
        });
    */
    'history' : function( args, callback ) {
        var callback = args['callback'] || callback 
        ,   limit    = args['limit'] || 100
        ,   channel  = args['channel']
        ,   jsonp    = jsonp_cb();

        // Make sure we have a Channel
        if (!channel)  return log('Missing Channel');
        if (!callback) return log('Missing Callback');

        // Send Message
        xdr({
            callback : jsonp,
            url      : [
                ORIGIN, 'history',
                SUBSCRIBE_KEY, encode(channel),
                jsonp, limit
            ],
            success  : function(response) { callback(response) },
            fail     : function(response) { log(response) }
        });
    },

    /*
        PUBNUB.time(function(time){ console.log(time) });
    */
    'time' : function(callback) {
        var jsonp = jsonp_cb();
        xdr({
            callback : jsonp,
            url      : [ORIGIN, 'time', jsonp],
            success  : function(response) { callback(response[0]) },
            fail     : function() { callback(0) }
        });
    },

    /*
        PUBNUB.uuid(function(uuid) { console.log(uuid) });
    */
    'uuid' : function(callback) {
        var jsonp = jsonp_cb();
        xdr({
            callback : jsonp,
            url      : [
                'http' + SSL +
                '://pubnub-prod.appspot.com/uuid?callback=' + jsonp
            ],
            success  : function(response) { callback(response[0]) },
            fail     : function() { callback(0) }
        });
    },

    /*
        PUBNUB.publish({
            channel : 'my_chat_channel',
            message : 'hello!'
        });
    */
    'publish' : function( args, callback ) {
        var callback = callback || args['callback'] || function(){}
        ,   message  = args['message']
        ,   channel  = args['channel']
        ,   jsonp    = jsonp_cb();

        if (!message)     return log('Missing Message');
        if (!channel)     return log('Missing Channel');
        if (!PUBLISH_KEY) return log('Missing Publish Key');

        // If trying to send Object
        message = JSON['stringify'](message);

        // Make sure message is small enough.
        if (message.length > LIMIT) return log('Message Too Big');

        // Send Message
        xdr({
            callback : jsonp,
            success  : function(response) { callback(response) },
            fail     : function() { callback([ 0, 'Disconnected' ]) },
            url      : [
                ORIGIN, 'publish',
                PUBLISH_KEY, SUBSCRIBE_KEY,
                0, encode(channel),
                jsonp, encode(message)
            ]
        });
    },

    /*
        PUBNUB.unsubscribe({ channel : 'my_chat' });
    */
    'unsubscribe' : function(args) {
        var channel = args['channel'];

        // Leave if there never was a channel.
        if (!(channel in CHANNELS)) return;

        // Disable Channel
        CHANNELS[channel].connected = 0;

        // Abort and Remove Script
        CHANNELS[channel].done && 
        CHANNELS[channel].done(0);
    },

    /*
        PUBNUB.subscribe({
            channel  : 'my_chat'
            callback : function(message) { console.log(message) }
        });
    */
    'subscribe' : function( args, callback ) {
        var channel   = args['channel']
        ,   callback  = callback || args['callback']
        ,   timetoken = 0
        ,   error     = args['error'] || function(){};

        // Make sure we have a Channel
        if (!channel)       return log('Missing Channel');
        if (!callback)      return log('Missing Callback');
        if (!SUBSCRIBE_KEY) return log('Missing Subscribe Key');

        if (!(channel in CHANNELS)) CHANNELS[channel] = {};

        // Make sure we have a Channel
        if (CHANNELS[channel].connected) return log('Already Connected');
            CHANNELS[channel].connected = 1;

        // Recurse Subscribe
        function pubnub() {
            var jsonp = jsonp_cb();

            // Stop Connection
            if (!CHANNELS[channel].connected) return;

            // Connect to PubNub Subscribe Servers
            CHANNELS[channel].done = xdr({
                callback : jsonp,
                url      : [
                    ORIGIN, 'subscribe',
                    SUBSCRIBE_KEY, encode(channel),
                    jsonp, timetoken
                ],
                fail     : function() { timeout( pubnub, 1000 ); error()  },
                success  : function(message) {
                    if (!CHANNELS[channel].connected) return;
                    timetoken = message[1];
                    timeout( pubnub, 10 );
                    each( message[0], function(msg) { callback(msg) } );
                }
            });
        }

        // Begin Recursive Subscribe
        pubnub();
    },

    // Expose PUBNUB Functions
    'xdr'      : xdr,
    'each'     : each,
    'map'      : map,
    'css'      : css,
    '$'        : $,
    'create'   : create,
    'bind'     : bind,
    'supplant' : supplant,
    'head'     : head,
    'search'   : search,
    'attr'     : attr,
    'now'      : unique
};

// Provide Global Interfaces
window['jQuery'] && (window['jQuery']['PUBNUB'] = PUBNUB);
window['PUBNUB'] = PUBNUB;

})();
