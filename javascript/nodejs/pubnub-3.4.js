/**
* UTILITIES
*/
function unique() { 
	var NOW = 1;
	return'x'+ ++NOW+''+(+new Date);
}

function rnow()   { return+new Date }

/**
* timeout
* =======
* timeout( function(){}, 100 );
*/
function timeout( fun, wait ) {
    return setTimeout( fun, wait );
}

/**
* NEXTORIGIN
* ==========
* var next_origin = nextorigin();
*/
var nextorigin = (function() {
    var max = 20
    ,   ori = Math.floor(Math.random() * max);
    return function(origin) {
        return origin.indexOf('pubsub') > 0
        && origin.replace(
           'pubsub', 'ps' + (++ori < max? ori : ori=1)
           ) || origin;
    }
})();

/**
* UPDATER
* =======
* var timestamp = unique();
*/
function updater( fun, rate ) {
    var timeout
    ,   last   = 0
    ,   runnit = function() {
        if (last + rate > rnow()) {
            clearTimeout(timeout);
            timeout = setTimeout( runnit, rate );
        }
        else {
            last = rnow();
            fun();
        }
    };

    return runnit;
}

/**
* EACH
* ====
* each( [1,2,3], function(item) { } )
*/
function each( o, f ) {
    if ( !o || !f ) return;

    if ( typeof o[0] != 'undefined' ) {
        for ( var i = 0, l = o.length; i < l; ) {
            f.call( o[i], o[i], i++ );
        }   
    } else {
        for ( var i in o )
            o.hasOwnProperty    &&
        o.hasOwnProperty(i) &&
        f.call( o[i], i, o[i] );
    }
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
* EVENTS
* ======
* PUBNUB.events.bind( 'you-stepped-on-flower', function(message) {
*     // Do Stuff with message
* } );
*
* PUBNUB.events.fire( 'you-stepped-on-flower', "message-data" );
* PUBNUB.events.fire( 'you-stepped-on-flower', {message:"data"} );
* PUBNUB.events.fire( 'you-stepped-on-flower', [1,2,3] );
*
*/
var events = {
    'list'   : {},
    'unbind' : function( name ) { events.list[name] = [] },
    'bind'   : function( name, fun ) {
        (events.list[name] = events.list[name] || []).push(fun);
    },
    'fire' : function( name, data ) {
        each(
            events.list[name] || [],
            function(fun) { fun(data) }
            );
    }
};

/**
* SUPPLANT
* ========
* var text = supplant( 'Hello {name}!', { name : 'John' } )
*/
function supplant( str, values ) {
 	var REPL = /{([\w\-]+)}/g;
    return str.replace( REPL, function( _, match ) {
        return values[match] || _
    } );
}

/**
* NEXTORIGIN
* ==========
* var next_origin = nextorigin();
*/
var nextorigin = (function() {
    var max = 20
    ,   ori = Math.floor(Math.random() * max);
    return function(origin) {
        return origin.indexOf('pubsub') > 0
        && origin.replace(
           'pubsub', 'ps' + (++ori < max? ori : ori=1)
           ) || origin;
    }
})();

/**
* ENCODE
* ======
* var encoded_path = encode('path');
*/
function encode(path) {
    return map( (encodeURIComponent(path)).split(''), function(chr) {
        return "-_.!~*'()".indexOf(chr) < 0 ? chr :
        "%"+chr.charCodeAt(0).toString(16).toUpperCase()
    } ).join('');
}

/**
* Generate Subscription Channel List
* ==================================
*  generate_channel_list(channels_object);
*/
function generate_channel_list(channels) {
    var list = [];
    each( channels, function( channel, status ) {
        if (status.subscribed) list.push(channel);
    } );
    return list.sort();
}

SECOND = 1000;

function PN_API(setup) {
    var CHANNELS      = {}
    ,   READY_BUFFER  = [] 
    ,   READY         = 0 
    ,   PRESENCE_SUFFIX = '-pnpres'
    ,   SUB_TIMEOUT   = 310000
    ,   SUB_CALLBACK  = 0
    ,   SUB_CHANNEL   = 0
    ,   SUB_RECEIVER  = 0
    ,   SUB_RESTORE   = 0
    ,   SUB_BUFF_WAIT = 0
    ,   TIMETOKEN     = 0
    ,   PUBLISH_KEY   = setup['publish_key']   || ''
    ,   SUBSCRIBE_KEY = setup['subscribe_key'] || ''
    ,   SSL           = setup['ssl'] ? 's' : ''
    ,   db            = setup['db'] || {'set' : function(){}, 'get': function(){}}
    ,   jsonp_cb      = setup['jsonp_cb'] || function(){ return 0;}
    ,   bind_leave    = setup['bind_leave'] || function() {}
    ,   xdr           = setup['xdr']
    ,   UUID          = setup['uuid'] || db['get'](SUBSCRIBE_KEY+'uuid') || ''
    ,   ORIGIN        = 'http'+SSL+'://'+(setup['origin']||'pubsub.pubnub.com')
    ,   LEAVE         = function(){}
    ,   CONNECT       = function(){}
    ,   SELF          = {

        /*
            PUBNUB.history({
                channel  : 'my_chat_channel',
                limit    : 100,
                callback : function(history) { }
            });
        */
        'history' : function( args, callback ) {
            var callback = args['callback'] || callback 
            ,   count    = args['count']    || args['limit'] || 100
            ,   reverse  = args['reverse']  || "false"
            ,   err      = args['error']    || function(){}
            ,   channel  = args['channel']
            ,   start    = args['start']
            ,   end      = args['end']
            ,   params   = {}
            ,   jsonp    = jsonp_cb();

            // Make sure we have a Channel
            if (!channel)       return error('Missing Channel');
            if (!callback)      return error('Missing Callback');
            if (!SUBSCRIBE_KEY) return error('Missing Subscribe Key');

            params["count"]   = count;
            params["reverse"] = reverse;

            if (start) params["start"] = start;
            if (end)   params["end"]   = end;

            // Send Message
            xdr({
                callback : jsonp,
                data     : params,
                success  : function(response) { callback(response) },
                fail     : err,
                url      : [
                ORIGIN, 'v2', 'history', 'sub-key',
                SUBSCRIBE_KEY, 'channel', encode(channel)
                ]
            });
        },

        /*
            PUBNUB.replay({
                source      : 'my_channel',
                destination : 'new_channel'
            });
        */
        'replay' : function(args) {
            var callback    = callback || args['callback'] || function(){}
            ,   source      = args['source']
            ,   destination = args['destination']
            ,   stop        = args['stop']
            ,   start       = args['start']
            ,   end         = args['end']
            ,   reverse     = args['reverse']
            ,   limit       = args['limit']
            ,   jsonp       = jsonp_cb()
            ,   data        = {}
            ,   url;

            // Check User Input
            if (!source)        return error('Missing Source Channel');
            if (!destination)   return error('Missing Destination Channel');
            if (!PUBLISH_KEY)   return error('Missing Publish Key');
            if (!SUBSCRIBE_KEY) return error('Missing Subscribe Key');

            // Setup URL Params
            if (jsonp != '0') data['callback'] = jsonp;
            if (stop)         data['stop']     = 'all';
            if (reverse)      data['reverse']  = 'true';
            if (start)        data['start']    = start;
            if (end)          data['end']      = end;
            if (limit)        data['count']    = limit;

            // Compose URL Parts
            url = [
            ORIGIN, 'v1', 'replay',
            PUBLISH_KEY, SUBSCRIBE_KEY,
            source, destination
            ];

            // Start (or Stop) Replay!
            xdr({
                callback : jsonp,
                success  : function(response) { callback(response) },
                fail     : function() { callback([ 0, 'Disconnected' ]) },
                url      : url,
                data     : data
            });
        },

        /*
            PUBNUB.time(function(time){ });
        */
        'time' : function(callback) {
            var jsonp  = jsonp_cb()
            ,   origin = nextorigin(ORIGIN);

            xdr({
                callback : jsonp,
                url      : [origin, 'time', jsonp],
                success  : function(response) { callback(response[0]) },
                fail     : function() { callback(0) }
            });
        },

        /*
            PUBNUB.uuid(function(uuid) { });
        */
        'uuid' : function(callback) {
            var u = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g,
                function(c) {
                    var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
                    return v.toString(16);
                });
            if (callback) callback(u);
            return u;
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
            ,   jsonp    = jsonp_cb()
            ,   url;

            if (!message)       return error('Missing Message');
            if (!channel)       return error('Missing Channel');
            if (!PUBLISH_KEY)   return error('Missing Publish Key');
            if (!SUBSCRIBE_KEY) return error('Missing Subscribe Key');

            // If trying to send Object
            message = JSON['stringify'](message);

            // Create URL
            url = [
            ORIGIN, 'publish',
            PUBLISH_KEY, SUBSCRIBE_KEY,
            0, encode(channel),
            jsonp, encode(message)
            ];

            // Send Message
            xdr({
                callback : jsonp,
                success  : function(response) { callback(response) },
                fail     : function() { callback([ 0, 'Disconnected' ]) },
                url      : url,
                data     : { 'uuid' : UUID }
            });
        },

        /*
            PUBNUB.unsubscribe({ channel : 'my_chat' });
        */
        'unsubscribe' : function(args) {
            var channel = args['channel'];

            TIMETOKEN   = 0;
            SUB_RESTORE = 1;

            // Prepare Channel(s)
            channel = map( (
                channel.join ? channel.join(',') : ''+channel
                ).split(','), function(channel) {
                return channel + ',' + channel + PRESENCE_SUFFIX;
            } ).join(',');

            // Iterate over Channels
            each( channel.split(','), function(channel) {
                if (READY) LEAVE( channel, 0 );
                CHANNELS[channel] = 0;
            } );

            // ReOpen Connection if Any Channels Left
            if (READY) CONNECT();
        },

        /*
            PUBNUB.subscribe({
                channel  : 'my_chat'
                callback : function(message) { }
            });
        */
        'subscribe' : function( args, callback ) {
            var channel       = args['channel']
            ,   callback      = callback              || args['callback']
            ,   callback      = callback              || args['message']
            ,   err           = args['error']         || function(){}
            ,   connect       = args['connect']       || function(){}
            ,   reconnect     = args['reconnect']     || function(){}
            ,   disconnect    = args['disconnect']    || function(){}
            ,   presence      = args['presence']      || 0
            ,   noheresync    = args['noheresync']    || 0
            ,   sub_timeout   = args['timeout']       || SUB_TIMEOUT
            ,   restore       = args['restore']
            ,   origin        = nextorigin(ORIGIN);

            // Restore Enabled?
            if (restore) SUB_RESTORE = 1;

            // Make sure we have a Channel
            if (!channel)       return error('Missing Channel');
            if (!callback)      return error('Missing Callback');
            if (!SUBSCRIBE_KEY) return error('Missing Subscribe Key');

            // Setup Channel(s)
            each( (channel.join ? channel.join(',') : ''+channel).split(','),
                function(channel) {
                    var settings = CHANNELS[channel] || {};

                // Store Channel State
                CHANNELS[SUB_CHANNEL = channel] = {
                    name         : channel,
                    connected    : settings.connected,
                    disconnected : settings.disconnected,
                    subscribed   : 1,
                    callback     : SUB_CALLBACK = callback,
                    connect      : connect,
                    error        : err,
                    disconnect   : disconnect,
                    reconnect    : reconnect
                };

                // Presence Enabled?
                if (!presence) return;

                // Subscribe Presence Channel
                SELF['subscribe']({
                    'channel'  : channel + PRESENCE_SUFFIX,
                    'callback' : presence
                });

                // Presence Subscribed?
                if (settings.subscribed) return;

                // See Who's Here Now?
                if (noheresync) return;
                SELF['here_now']({
                    'channel'  : channel,
                    'callback' : function(here) {
                        each( 'uuids' in here ? here['uuids'] : [],
                            function(uuid) { presence( {
                                'action'    : 'join',
                                'uuid'      : uuid,
                                'timestamp' : rnow(),
                                'occupancy' : here['occupancy'] || 1
                            }, here, channel ); } );
                    }
                });
            } );

            // Evented Subscribe
            function _connect() {
                var jsonp    = jsonp_cb()
                ,   channels = generate_channel_list(CHANNELS).join(',');

                // Stop Connection
                if (!channels) return;

                // Connect to PubNub Subscribe Servers
                SUB_RECEIVER = xdr({
                    timeout  : sub_timeout,
                    callback : jsonp,
                    data     : { 'uuid' : UUID },
                    url      : [
                    origin, 'subscribe',
                    SUBSCRIBE_KEY, encode(channels),
                    jsonp, TIMETOKEN
                    ],
                    fail : function() {
                        // Disconnect
                        each_channel(function(channel){
                            if (channel.disconnected) return;
                            channel.disconnected = 1;
                            channel.disconnect(channel.name);
                        });

                        // New Origin on Failed Connection
                        origin = nextorigin(ORIGIN);

                        // Reconnect
                        timeout( _connect, SECOND );
                        SELF['time'](function(success){
                            each_channel(function(channel){
                                if (success && channel.disconnected){
                                    channel.disconnected = 0;
                                    channel.reconnect(channel.name);
                                }
                                else channel.error();
                            });
                        });
                    },
                    success : function(messages) {
                        if (!messages) return timeout( _connect, 10 );
                        
                        // Connect
                        each_channel(function(channel){
                            if (channel.connected) return;
                            channel.connected = 1;
                            channel.connect(channel.name);
                        });

                        // Restore Previous Connection Point if Needed
                        TIMETOKEN = !TIMETOKEN               &&
                        SUB_RESTORE              &&
                        db['get'](SUBSCRIBE_KEY) || messages[1];

                        // Update Saved Timetoken
                        db['set']( SUBSCRIBE_KEY, messages[1] );

                        // Route Channel <---> Callback for Message
                        var next_callback = (function() {
                            var channels = (messages.length>2?messages[2]:'')
                            ,   list     = channels.split(',');

                            return function() {
                                var channel = list.shift()||'';
                                return [
                                (CHANNELS[channel]||{})
                                .callback||SUB_CALLBACK,
                                (channel||SUB_CHANNEL)
                                .split(PRESENCE_SUFFIX)[0]
                                ];
                            };
                        })();

                        each( messages[0], function(msg) {
                            var next = next_callback();
                            if (!CHANNELS[next[1]].subscribed) return;
                            next[0]( msg, messages, next[1] );
                        } );

                        timeout( _connect, 10 );
                    }
                });
            }

            CONNECT = function() {
                // Close Previous Subscribe Connection
                SUB_RECEIVER && SUB_RECEIVER();
                // Begin Recursive Subscribe
                clearTimeout(SUB_BUFF_WAIT);
                SUB_BUFF_WAIT = timeout( _connect, 100 );
            };
            // Reduce Status Flicker
            if (!READY) return READY_BUFFER.push(CONNECT);
            // Connect Now
            CONNECT();
        },

        'here_now' : function( args, callback ) {
            var callback = args['callback'] || callback 
            ,   err      = args['error']    || function(){}
            ,   channel  = args['channel']
            ,   jsonp    = jsonp_cb()
            ,   data     = {};

            // Make sure we have a Channel
            if (!channel)       return error('Missing Channel');
            if (!callback)      return error('Missing Callback');
            if (!SUBSCRIBE_KEY) return error('Missing Subscribe Key');

            if (jsonp != '0') data['callback'] = jsonp;

            xdr({
                callback : jsonp,
                data     : data,
                success  : function(response) { callback(response) },
                fail     : err,
                url      : [
                ORIGIN, 'v2', 'presence',
                'sub_key', SUBSCRIBE_KEY, 
                'channel', encode(channel)
                ]
            });
        },
        // PUBNUB READY TO CONNECT
        'ready' : function () { SELF['time'](rnow);
            SELF['time'](function(t){ 
                timeout( function() {
                    if (READY) return;
                        READY = 1;
                    each( READY_BUFFER, function(connect) { connect(); } );
                }, SECOND ); 
            }); 
        }
    }

    function each_channel(callback) {
        each( generate_channel_list(CHANNELS), function(channel) {
            var chan = CHANNELS[channel];
            if (!chan) return;
            callback(chan);
        } );
    }

    // Announce Leave Event
    LEAVE = function( channel, blocking ) {
        var data   = { 'uuid' : UUID }
        ,   origin = nextorigin(ORIGIN)
        ,   jsonp  = jsonp_cb();

        // Prevent Leaving a Presence Channel
        if (channel.indexOf(PRESENCE_SUFFIX) > 0) return;

        if (jsonp != '0') data['callback'] = jsonp;

        xdr({
            blocking : blocking || SSL,
            timeout  : 2000,
            callback : jsonp,
            data     : data,
            url      : [
            origin, 'v2', 'presence', 'sub_key',
            SUBSCRIBE_KEY, 'channel', encode(channel), 'leave'
            ]
        });
    };

    if (!UUID) UUID = SELF['uuid']();
    db['set']( SUBSCRIBE_KEY + 'uuid', UUID );

    bind_leave();

    return SELF;
}
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
 * LOG
 * ===
 * log('message');
 */
function log(message) { console['log'](message) }


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
    //setup.url.unshift('');
    var url     = setup.url.join(URLBIT)
    ,   success = setup.success
    ,   origin  = setup.origin || 'pubsub.pubnub.com'
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
    //console.log(url);
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
    var PN = {};
    setup['xdr'] = xdr;
    setup['timeout'] = 1000;
    PN.__proto__ = PN_API(setup);    
    PN.ready();
    return PN;
}
exports.unique = unique
