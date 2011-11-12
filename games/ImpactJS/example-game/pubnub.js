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

/**
 * UTIL LOCALS
 */
var NOW    = 1
,   http   = require('http')
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
 * LOG
 * ===
 * log('message');
 */
function log(message) { console['log'](message) }

/**
 * timeout
 * =======
 * timeout( function(){}, 100 );
 */
function timeout( fun, wait ) { return setTimeout( fun, wait ) }

/**
 * ENCODE
 * ======
 * var encoded_path = encode('path');
 */
function encode(path) {
    return (''+path).split('').map(function(chr) {
        return " ~`!@#$%^&*()+=[]\\{}|;':\",./<>?".indexOf(chr) > -1 ?
               "%"+chr.charCodeAt(0).toString(16).toUpperCase()      : chr
    }).join('');
}

/**
 * Request
 * =======
 *  xdr({
 *     url     : ['http://www.blah.com/url'],
 *     success : function(response) {},
 *     fail    : function() {}
 *  });
 */
function xdr( setup ) {
    setup.url.unshift('');

    var url     = setup.url.join(URLBIT)
    ,   success = setup.success
    ,   fail    = setup.fail
    ,   origin  = setup.origin
    ,   ssl     = setup.ssl
    ,   body    = ''
    ,   google  = http.createClient( 80, origin, ssl )
    ,   request = google.request( 'GET', url, { 'host': origin });

    request.end();
    request.on( 'response', function (response) {
        response.setEncoding('utf8');

        response.on( 'data', function (chunk) {
            if (chunk) body += chunk;
        } );
        response.on( 'end', function () {
            if (body) return success(JSON.parse(body));
            else      fail();
        } );
    } );
}



/* =-=====================================================================-= */
/* =-=====================================================================-= */
/* =-=========================     PUBNUB     ============================-= */
/* =-=====================================================================-= */
/* =-=====================================================================-= */

exports.init = function(setup) {
    var DEMO          = 'demo'
    ,   PUBLISH_KEY   = setup.publish_key   || DEMO
    ,   SUBSCRIBE_KEY = setup.subscribe_key || DEMO
    ,   SECRET_KEY    = setup.secret_key    || false
    ,   SSL           = setup.ssl
    ,   ORIGIN        = setup.origin || 'pubsub.pubnub.com'
    ,   LIMIT         = 1800
    ,   CHANNELS      = {};

    return {
        /*
            PUBNUB.history({
                channel  : 'my_chat_channel',
                limit    : 100,
                callback : function(messages) { console.log(messages) }
            });
        */
        history : function( args, callback ) {
            var callback = args['callback']
            ,   limit    = args['limit'] || 10
            ,   channel  = args['channel'];

            // Make sure we have a Channel
            if (!channel)  return log('Missing Channel');
            if (!callback) return log('Missing Callback');

            // Send Message
            xdr({
                ssl : SSL,
                url : [
                    'history',
                    SUBSCRIBE_KEY, encode(channel),
                    '0', limit
                ],
                origin  : ORIGIN,
                success : callback,
                fail    : function(response) { log(response) }
            });
        },

        /*
            PUBNUB.time(function(time){ console.log(time) });
        */
        time : function(callback) {
            xdr({
                ssl     : SSL,
                url     : ['time', '0'],
                origin  : ORIGIN,
                success : function(response) { callback(response[0]) },
                fail    : function() { callback(0) }
            });
        },

        /*
            PUBNUB.publish({
                channel : 'my_chat_channel',
                message : 'hello!'
            });
        */
        publish : function( args, callback ) {
            var callback = callback || args['callback'] || function(){}
            ,   message  = args['message']
            ,   channel  = args['channel'];

            if (!message)     return log('Missing Message');
            if (!channel)     return log('Missing Channel');
            if (!PUBLISH_KEY) return log('Missing Publish Key');

            // If trying to send Object
            message = JSON['stringify'](message);

            // Make sure message is small enough.
            if (message.length > LIMIT) return log('Message Too Big');

            // Send Message
            xdr({
                ssl      : SSL,
                origin   : ORIGIN,
                success  : function(response) { callback(response) },
                fail     : function() { callback([ 0, 'Disconnected' ]) },
                url      : [
                    'publish',
                    PUBLISH_KEY, SUBSCRIBE_KEY,
                    0, encode(channel),
                    '0', encode(message)
                ]
            });
        },

        /*
            PUBNUB.unsubscribe({ channel : 'my_chat' });
        */
        unsubscribe : function(args) {
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
        subscribe : function( args, callback ) {
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
                // Stop Connection
                if (!CHANNELS[channel].connected) return;

                // Connect to PubNub Subscribe Servers
                CHANNELS[channel].done = xdr({
                    ssl : SSL,
                    url : [
                        'subscribe',
                        SUBSCRIBE_KEY, encode(channel),
                        '0', timetoken
                    ],
                    origin  : ORIGIN,
                    fail    : function() { timeout( pubnub, 1000 ); error() },
                    success : function(message) {
                        if (!CHANNELS[channel].connected) return;
                        timetoken = message[1];
                        timeout( pubnub, 10 );
                        message[0].forEach(function(msg) { callback(msg) });
                    }
                });
            }

            // Begin Recursive Subscribe
            pubnub();
        }
    };
}
