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
,   https  = require('https')
,   URLBIT = '/'
,   PARAMSBIT = '&'
,   XHRTME = 310000
,   XORIGN = 1;

/**
 * UNIQUE
 * ======
 * var timestamp = unique();
 */
function unique() { return'x'+ ++NOW+''+(+new Date) }


/**
 * NEXTORIGIN
 * ==========
 * var next_origin = nextorigin();
 */
var nextorigin = (function() {
    var ori = Math.floor(Math.random() * 9) + 1;
    return function(origin) {
        return origin.indexOf('pubsub') > 0
            && origin.replace(
             'pubsub', 'ps' + (++ori < 10 ? ori : ori=1)
            ) || origin;
    }
})();

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
    ,   origin  = setup.origin
    ,   ssl     = setup.ssl
    ,   failed  = 0
    ,   body    = ''
    ,   fail    = function(e) {
            if (failed) return;
            failed = 1;
            (setup.fail||function(){})(e);
        };
    if (setup.data) {
        var params = [];
        url += "?";
        for (key in setup.data) {
             params.push(key+"="+setup.data[key]);
        }
        url += params.join(PARAMSBIT);
    }
    try {
        (ssl ? https : http).get( {
            host : origin,
            port : ssl ? 443 : 80,
            path : url
        }, function(response) {
            response.setEncoding('utf8');
            response.on( 'error', fail );
            response.on( 'data', function (chunk) {
                if (chunk) body += chunk;
            } );
            response.on( 'end', function () {
                try {
                    if (body) return success(JSON.parse(body));
                    else      fail();
                } catch(e) { fail(); }
            } );
        }).on( 'error', fail );
    } catch(e) { fail(); }
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
    ,   CHANNELS      = {}
    ,   UUID =   'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                    var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
                    return v.toString(16);
                })
    ,   PN            = {
        

        uuid : uuid = function(callback) {
            if (callback)
                callback(UUID);
            return UUID;
        },
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
            PUBNUB.detailedHistory({
                channel  : 'my_chat_channel',
                count : 100,
                callback : function(messages) { console.log(messages) }
            });
        */
        detailedHistory : function( args, callback ) {
            var callback = args['callback']
            ,   channel  = args['channel'];

            // Make sure we have a Channel
            if (!channel)  return log('Missing Channel');
            if (!callback) return log('Missing Callback');

            var params = {};
            params["count"] = args['count'] || 100;
            params["reverse"] = args['reverse'] || 'false';
            if (args['start']) 
                params["start"] = args['start'];
            if (args['end'])
                params["end"] = args['end'];
            
            // Send Message
            xdr({
                ssl : SSL,
                url : [
                    'v2', 'history',
                    'sub-key', SUBSCRIBE_KEY, 
                    'channel', encode(channel),
                ],
                data : params,
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
        'subscribe' : subscribe = function( args, callback ) {

            var channel      = args['channel']
            ,   callback     = callback || args['callback']
            ,   timetoken    = 0
            ,   error        = args['error'] || function(){}
            ,   connect      = args['connect'] || function(){}
            ,   reconnect    = args['reconnect'] || function(){}
            ,   disconnect   = args['disconnect'] || function(){}
            ,   disconnected = 0
            ,   connected    = 0
            ,   origin       = nextorigin(ORIGIN);

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
                    ssl    : SSL,
                    origin : origin,
                    url    : [
                        'subscribe',
                        SUBSCRIBE_KEY,
                        encode(channel),
                        '0', timetoken
                    ],
                    data : { 'uuid': encode(uuid()) },
                    fail : function() {
                        // Disconnect
                        if (!disconnected) {
                            disconnected = 1;
                            disconnect();
                        }
                        timeout( pubnub, 1000 );
                        PN['time'](function(success){
                            success || error();
                        });
                    },
                    success : function(messages) {
                        // var ret = {stop: false}; // Uncomment for NodeUnit
                        if (!CHANNELS[channel].connected) return;

                        // Connect
                        if (!connected) {
                            connected = 1;
                            // ret = connect(); // Uncomment for NodeUnit
                            connect();
                        }

                        // Reconnect
                        if (disconnected) {
                            disconnected = 0;
                            // ret = reconnect(); // Uncomment for NodeUnit
                            reconnect();
                        }

                        messages[0].forEach(function(msg) {
                            // ret = callback( msg, messages ); // Uncomment for NodeUnit
                            callback( msg, messages );
                        });

                        timetoken = messages[1];
                        // if(!ret.stop) // callback( msg, messages );
                            timeout( pubnub, 10 );
                    }
                });
            }

            // Begin Recursive Subscribe
            pubnub();
        },
        /*
            PUBNUB.presence({
                channel  : 'my_chat'
                callback : function(message) { console.log(message) }
            });
        */
        'presence' : function( args, callback ) {
            args['channel'] = args['channel'] + '-pnpres';
            subscribe(args,callback );
        },
        /*
            PUBNUB.here_now({
                channel  : 'my_chat_channel',
                callback : function(messages) { console.log(messages) }
            });
        */
        'here_now' : function( args, callback ) {
            var callback = args['callback']
            ,   channel  = args['channel'];

            // Make sure we have a Channel
            if (!channel)  return log('Missing Channel');
            if (!callback) return log('Missing Callback');

            // Send Message
            xdr({
                ssl : SSL,
                url : [
                    'v2',
                    'presence',
                    'sub-key', SUBSCRIBE_KEY, 
                    'channel', encode(channel)
                ],
                origin  : ORIGIN,
                success : callback,
                fail    : function(response) { log(response) }
            });
        }
    };
    return PN;
}
exports.unique = unique
