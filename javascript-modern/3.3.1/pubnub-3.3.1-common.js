
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
 * EACH
 * ====
 * each( [1,2,3], function(item) { console.log(item) } )
 */
function each( o, f ) {
    if ( !o || !f ) return;

    if ( typeof o[0] != 'undefined' )
        for ( var i = 0, l = o.length; i < l; )
            f.call( o[i], o[i], i++ );
    else
        for ( var i in o )
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
 * timeout
 * =======
 * timeout( function(){}, 100 );
 */
function timeout( fun, wait ) {
    return setTimeout( fun, wait );
}

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


function PN_API(setup) {
    var CHANNELS      = {}
    ,   PUBLISH_KEY   = setup['publish_key']   || ''
    ,   SUBSCRIBE_KEY = setup['subscribe_key'] || ''
    ,   ORIGIN        = setup['origin'] || 'pubsub.pubnub.com'
    ,   db            = setup['db'] || {'set' : function(){}, 'get': function(){}}
    ,   jsonp_cb      = setup['jsonp_cb'] || function(){}
    ,   UUID          = setup['uuid'] || db.get(SUBSCRIBE_KEY+'uuid') || ''
    ,   xdr           = setup['xdr']
    ,   ssl           = setup['ssl']
    ,   timeout_sec   = setup['timeout'] || 1000
    ,   log           = setup['log'] || function(){}
    ,   LEAVE         = function(){}
    ,   PRESENCE_SUFFIX = '-pnpres'



    SELF = {
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
            ,   channel  = args['channel'];

            // Make sure we have a Channel
            if (!channel)  return log('Missing Channel');
            if (!callback) return log('Missing Callback');

            // Send Message
            xdr({
                ssl      : ssl,
                origin   : ORIGIN,
                url      : [
                    'history', SUBSCRIBE_KEY, encode(channel),
                    0, limit
                ],
                success  : function(response) { callback(response) },
                fail     : function(response) { callback(response) }
            });
        },
        /*
        PUBNUB.detailedHistory({
            channel  : 'my_chat_channel',
            count : 100,
            callback : function(messages) { console.log(messages) }
        });
        */
        'detailedHistory' : function( args, callback ) {
            var callback    = args['callback'] || callback
            ,   count       = args['count'] || 100
            ,   channel     = args['channel']
            ,   reverse     = args['reverse'] || "false"
            ,   start       = args['start']
            ,   end         = args['end']
            ,   jsonp       = jsonp_cb();

            // Make sure we have a Channel
            if (!channel)  return log('Missing Channel');
            if (!callback) return log('Missing Callback');

            var params = {};
            params["count"] = count;
            params["reverse"] = reverse;
            if (start) params["start"] = start;
            if (end) params["end"] = end;

            // Send Message
            xdr({
                callback : jsonp,
                ssl      : ssl,
                origin   : ORIGIN,
                url      : [
                    'v2', 'history',
                    'sub-key', SUBSCRIBE_KEY, 'channel', encode(channel)
                ],
                data : params,
                success  : function(response) { callback(response) },
                fail     : function(response) { log(response) }
            });
        },

        /*
         PUBNUB.time(function(time){ console.log(time) });
         */
        'time' : function(callback) {
            xdr({
                ssl      : ssl,
                origin   : ORIGIN,
                url      : ['time', 0],
                success  : function(response) { callback(response[0]) },
                fail     : function() { callback(0) }
            });
        },

        /*
         PUBNUB.uuid(function(uuid) { console.log(uuid) });
         */
        'uuid' : function(callback) {
            var u = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
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
            ,   url;

            if (!message)     return log('Missing Message');
            if (!channel)     return log('Missing Channel');
            if (!PUBLISH_KEY) return log('Missing Publish Key');

            // If trying to send Object
            message = JSON['stringify'](message);

            // Create URL
            url = [
                'publish',
                PUBLISH_KEY, SUBSCRIBE_KEY,
                0, encode(channel),
                0, encode(message)
            ];

            // Send Message
            xdr({
                success  : function(response) { callback(response) },
                fail     : function() { callback([ 0, 'Disconnected' ]) },
                ssl      : ssl,
                origin   : ORIGIN,
                url      : url
            });
        },

        /*
        PUBNUB.unsubscribe({ channel : 'my_chat' });
        */
        'unsubscribe' : function(args) {
            unsubscribe(args['channel']);
            unsubscribe(args['channel']) + PRESENCE_SUFFIX;

            // Announce Leave
            LEAVE(args['channel']);

            function unsubscribe(channel) {
                // Leave if there never was a channel.
                if (!(channel in CHANNELS)) return;

                // Disable Channel
                CHANNELS[channel].connected = 0;

                // Abort and Remove Script
                CHANNELS[channel].done && 
                CHANNELS[channel].done(0);
            }

        },
        'here_now' : function( args, callback ) {
            var callback = args['callback'] || callback
            ,   channel  = args['channel']
            ,   jsonp    = jsonp_cb()
            ,   origin   = nextorigin(ORIGIN)
            ,   data     = {};

            // Make sure we have a Channel
            if (!channel)  return log('Missing Channel');
            if (!callback) return log('Missing Callback');

            if (jsonp != '0') { data['callback']=jsonp; }

            // Send Message
            xdr({
                callback : jsonp,
                ssl      : ssl,
                origin   : origin,
                url      : [
                    'v2', 'presence',
                    'sub_key', SUBSCRIBE_KEY,
                    'channel', encode(channel)
                ],
                data: data,
                success  : function(response) { callback(response) },
                fail     : function(response) { log(response) }
            });
        },
        'subscribe' : function( args, callback ) {
            var channel      = args['channel']
            ,   callback     = callback || args['callback']
            ,   subscribe_key= args['subscribe_key'] || SUBSCRIBE_KEY
            ,   restore      = args['restore']
            ,   timetoken    = 0
            ,   error        = args['error'] || function(){}
            ,   connect      = args['connect'] || function(){}
            ,   reconnect    = args['reconnect'] || function(){}
            ,   disconnect   = args['disconnect'] || function(){}
            ,   presence     = args['presence'] || function(){}
            ,   disconnected = 0
            ,   connected    = 0
            ,   bindleave    = args['bindleave'] || function() {}
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
            function _connect() {
                var jsonp = jsonp_cb();

                // Stop Connection
                if (!CHANNELS[channel].connected) return;
                // Connect to PubNub Subscribe Servers
                CHANNELS[channel].done = xdr({
                    callback : jsonp,
                    ssl      : ssl,
                    origin   : origin,
                    url      : [
                        'subscribe',
                        subscribe_key, encode(channel),
                        jsonp, timetoken
                    ],
                    data     : { uuid: UUID },
                    fail : function() {
                        // Disconnect
                        if (!disconnected) {
                            disconnected = 1;
                            disconnect();
                            leave();
                        }
                        timeout( _connect, timeout_sec);
                        SELF['time'](function(success){
                            // Reconnect
                            if (success && disconnected) {
                                disconnected = 0;
                                reconnect();
                            }
                            else {
                                error();
                            }
                        });
                    },
                    success : function(messages) {
                        if (!CHANNELS[channel].connected) return;

                        // Connect
                        if (!connected) {
                            connected = 1;
                            connect();
                        }

                        // Reconnect
                        if (disconnected) {
                            disconnected = 0;
                            reconnect();
                        }

                        // Restore Previous Connection Point if Needed
                        // Also Update Timetoken
                        restore = db.set(
                            SUBSCRIBE_KEY + channel,
                            timetoken = restore && db.get(
                                subscribe_key + channel
                            ) || messages[1]
                        );
                        each( messages[0], function(msg) {
                            callback( msg, messages );
                        } );

                        timeout( _connect, 10 );
                    }
                });
            }

                        // Announce Leave Event
            function leave(chan) {
                var data  = { uuid : UUID }
                ,   jsonp = jsonp_cb()
                ,   chann = chan || channel;

                if (jsonp != '0') data['callback'] = jsonp;

                xdr({
                    blocking : 1,
                    callback : jsonp,
                    data     : data,
                    url      : [
                        origin, 'v2', 'presence',
                        'sub_key', SUBSCRIBE_KEY, 
                        'channel', encode(channel),
                        'leave'
                    ]
                });

                return true;
            }

            LEAVE = leave;


            bindleave();
            
            // onBeforeUnload
            //bind( 'beforeunload', window, leave );

            // Presence Subscribe
            if (args['presence']) SELF.subscribe({
                channel  : args['channel'] + PRESENCE_SUFFIX,
                callback : presence,
                restore  : args['restore']
            });

            // Begin Recursive Subscribe
            _connect();
        },
        /*
        *PUBNUB.time(function(time){ console.log(time) });
        */
        'time' : function(callback) {
            var jsonp = jsonp_cb();
            xdr({
                callback : jsonp,
                origin   : ORIGIN,
                url      : ['time', jsonp],
                success  : function(response) { callback(response[0]) },
                fail     : function() { callback(0) }
            });
        },
        /*
        *PUBNUB.presence({
        *   channel  : 'my_chat'
        *   callback : function(message) { console.log(message) }
        *});
        */
        'presence' : function( args, callback ) {
            args['channel'] = args['channel'] + '-pnpres';
            SELF.subscribe(args,callback );
        },
    };

    if(!xdr) return log('Missing xdr function');


    if (UUID == '') UUID = SELF.uuid();
    db.set(SUBSCRIBE_KEY+'uuid', UUID);
 
    return SELF;
};
