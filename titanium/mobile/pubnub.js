/* ---------------------------------------------------------------------------
WAIT! - This file depends on instructions from the PUBNUB Cloud.
http://www.pubnub.com/account
--------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------
PubNub Real-time Cloud-Hosted Push API and Push Notification Client Frameworks
Copyright (c) 2011 TopMambo Inc.
http://www.pubnub.com/
http://www.pubnub.com/terms
--------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
--------------------------------------------------------------------------- */

(function() {

/**
 * UTIL LOCALS
 */
var NOW    = 1
,   MAGIC  = /\$?{([\w\-]+)}/g
,   URLBIT = '/'
,   XHRTME = 140000;

/**
 * UNIQUE
 * ======
 * var timestamp = unique();
 */
function unique() { return'x'+ ++NOW+''+(+new Date) }

/**
 * LOG
 * ===
 * log('message');
 */
function log(message) { console['log'](message) }

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
function jsonp_cb() { return '0' }

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


/* =-====================================================================-= */
/* =-====================================================================-= */
/* =-=========================     PUBNUB     ===========================-= */
/* =-====================================================================-= */
/* =-====================================================================-= */

var DEMO          = 'demo'
,   LIMIT         = 1800
,   CREATE_PUBNUB = function(setup) {
    var CHANNELS      = {}
    ,   PUBLISH_KEY   = setup['publish_key']   || DEMO
    ,   SUBSCRIBE_KEY = setup['subscribe_key'] || DEMO
    ,   SSL           = setup['ssl'] ? 's' : ''
    ,   ORIGIN        = 'http'+SSL+'://'+(setup['origin']||'pubsub.pubnub.com')
    ,   SELF          = {
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
                    fail : function() { timeout( pubnub, 1000 ); error()  },
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
        'now'      : unique,
        'init'     : CREATE_PUBNUB
    };

    return SELF;
};

PUBNUB = CREATE_PUBNUB({
    'publish_key'   : DEMO,
    'subscribe_key' : DEMO,
    'ssl'           : false,
    'origin'        : 'pubsub.pubnub.com'
});

})();
