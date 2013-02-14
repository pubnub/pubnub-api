/* ---------------------------------------------------------------------------
WAIT! - This file depends on instructions from the PUBNUB Cloud.
http://www.pubnub.com/account-javascript-api-include
--------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------
PubNub Real-time Cloud-Hosted Push API and Push Notification Client Frameworks
Copyright (c) 2011 PubNub Inc.
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

/* =-====================================================================-= */
/* =-====================================================================-= */
/* =-=========================     UTIL     =============================-= */
/* =-====================================================================-= */
/* =-====================================================================-= */

window['PUBNUB'] || (function() {

/**
 * UTIL LOCALS
 */
var NOW             = 1
,   SWF             = 'https://pubnub.a.ssl.fastly.net/pubnub.swf'
,   REPL            = /{([\w\-]+)}/g
,   ASYNC           = 'async'
,   URLBIT          = '/'
,   PARAMSBIT       = '&'
,   DEF_WINDOWING   = 10     // MILLISECONDS.
,   DEF_TIMEOUT     = 10000  // MILLISECONDS.
,   DEF_SUB_TIMEOUT = 310    // SECONDS.
,   DEF_KEEPALIVE   = 60     // SECONDS.
,   SECOND          = 1000   // A THOUSAND MILLISECONDS.
,   PRESENCE_SUFFIX = '-pnpres'
,   UA              = navigator.userAgent
,   XORIGN          = UA.indexOf('MSIE 6') == -1;

/**
 * CONSOLE COMPATIBILITY
 */
window.console || (window.console=window.console||{});
console.log    || (
    console.log   = 
    console.error =
    ((window.opera||{}).postError||function(){})
);

/**
 * UTILITIES
 */
function unique() { return'x'+ ++NOW+''+(+new Date) }
function rnow()   { return+new Date }

/**
 * LOCAL STORAGE OR COOKIE
 */
var db = (function(){
    var ls = window['localStorage'];
    return {
        'get' : function(key) {
            try {
                if (ls) return ls.getItem(key);
                if (document.cookie.indexOf(key) == -1) return null;
                return ((document.cookie||'').match(
                    RegExp(key+'=([^;]+)')
                )||[])[1] || null;
            } catch(e) { return }
        },
        'set' : function( key, value ) {
            try {
                if (ls) return ls.setItem( key, value ) && 0;
                document.cookie = key + '=' + value +
                    '; expires=Thu, 1 Aug 2030 20:00:00 UTC; path=/';
            } catch(e) { return }
        }
    };
})();

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
 * $
 * =
 * var div = $('divid');
 */
function $(id) { return document.getElementById(id) }

/**
 * ERROR
 * =====
 * error('message');
 */
function error(message) { console['error'](message) }

/**
 * SEARCH
 * ======
 * var elements = search('a div span');
 */
function search( elements, start ) {
    var list = [];
    each( elements.split(/\s+/), function(el) {
        each( (start || document).getElementsByTagName(el), function(node) {
            list.push(node);
        } );
    } );
    return list;
}

/**
 * EACH
 * ====
 * each( [1,2,3], function(item) { } )
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
 * SUPPLANT
 * ========
 * var text = supplant( 'Hello {name}!', { name : 'John' } )
 */
function supplant( str, values ) {
    return str.replace( REPL, function( _, match ) {
        return values[match] || _
    } );
}

/**
 * BIND
 * ====
 * bind( 'keydown', search('a')[0], function(element) {
 *     ...
 * } );
 */
function bind( type, el, fun ) {
    each( type.split(','), function(etype) {
        var rapfun = function(e) {
            if (!e) e = window.event;
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
function timeout( fun, wait ) {
    return setTimeout( fun, wait );
}

/**
 * jsonp_cb
 * ========
 * var callback = jsonp_cb();
 */
function jsonp_cb() { return XORIGN || FDomainRequest() ? 0 : unique() }

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
 * XDR Cross Domain Request
 * ========================
 *  xdr({
 *     url     : ['http://www.blah.com/url'],
 *     success : function(response) {},
 *     fail    : function() {}
 *  });
 */
function xdr( setup ) {
    if (XORIGN || FDomainRequest()) return ajax(setup);

    var script    = create('script')
    ,   callback  = setup.callback
    ,   id        = unique()
    ,   finished  = 0
    ,   xhrtme    = setup.timeout || DEF_TIMEOUT
    ,   timer     = timeout( function(){done(1)}, xhrtme )
    ,   fail      = setup.fail    || function(){}
    ,   success   = setup.success || function(){}

    ,   append = function() {
            head().appendChild(script);
        }

    ,   done = function( failed, response ) {
            if (finished) return;
                finished = 1;

            failed || success(response);
            script.onerror = null;
            clearTimeout(timer);

            timeout( function() {
                failed && fail();
                var s = $(id)
                ,   p = s && s.parentNode;
                p && p.removeChild(s);
            }, SECOND );
        };

    window[callback] = function(response) {
        done( 0, response );
    };

    if (!setup.blocking) script[ASYNC] = ASYNC;

    script.onerror = function() { done(1) };
    script.src     = setup.url.join(URLBIT);

    if (setup.data) {
        var params = [];
        script.src += "?";
        for (var key in setup.data) {
             params.push(key+"="+setup.data[key]);
        }
        script.src += params.join(PARAMSBIT);
    }
    attr( script, 'id', id );

    append();
    return done;
}

/**
 * CORS XHR Request
 * ================
 *  xdr({
 *     url     : ['http://www.blah.com/url'],
 *     success : function(response) {},
 *     fail    : function() {}
 *  });
 */
function ajax( setup ) {
    var xhr, response
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
    ,   xhrtme   = setup.timeout || DEF_TIMEOUT
    ,   timer    = timeout( function(){done(1)}, xhrtme )
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
        xhr = FDomainRequest()      ||
              window.XDomainRequest &&
              new XDomainRequest()  ||
              new XMLHttpRequest();

        xhr.onerror = xhr.onabort   = function(){ done(1) };
        xhr.onload  = xhr.onloadend = finished;
        xhr.timeout = xhrtme;

        var url = setup.url.join(URLBIT);
        if (setup.data) {
            var params = [];
            var key;
            url += "?";
            for (key in setup.data) params.push(key+"="+setup.data[key]);
            url += params.join(PARAMSBIT);
        }

        xhr.open( 'GET', url, (typeof(setup.blocking === 'undefined')) );
        xhr.send();
    }
    catch(eee) {
        done(0);
        XORIGN = 0;
        return xdr(setup);
    }

    // Return 'done'
    return done;
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

/* =-====================================================================-= */
/* =-====================================================================-= */
/* =-=========================     PUBNUB     ===========================-= */
/* =-====================================================================-= */
/* =-====================================================================-= */

var PDIV          = $('pubnub') || {}
,   READY         = 0
,   READY_BUFFER  = []
,   CREATE_PUBNUB = function(setup) {
    var CHANNELS      = {}
    ,   SUB_CALLBACK  = 0
    ,   SUB_CHANNEL   = 0
    ,   SUB_RECEIVER  = 0
    ,   SUB_RESTORE   = 0
    ,   SUB_BUFF_WAIT = 0
    ,   TIMETOKEN     = 0
    ,   SUB_WINDOWING =  +setup['windowing']   || DEF_WINDOWING
    ,   SUB_TIMEOUT   = (+setup['timeout']     || DEF_SUB_TIMEOUT) * SECOND
    ,   KEEPALIVE     = (+setup['keepalive']   || DEF_KEEPALIVE)   * SECOND
    ,   PUBLISH_KEY   = setup['publish_key']   || ''
    ,   SUBSCRIBE_KEY = setup['subscribe_key'] || ''
    ,   SSL           = setup['ssl'] ? 's' : ''
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

            params['stringtoken'] = 'true';
            params['count']       = count;
            params['reverse']     = reverse;

            if (start) params['start'] = start;
            if (end)   params['end']   = end;

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
            var jsonp = jsonp_cb();
            xdr({
                callback : jsonp,
                timeout  : SECOND*5,
                url      : [ORIGIN, 'time', jsonp],
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
            ,   connect       = args['connect']       || function(){}
            ,   reconnect     = args['reconnect']     || function(){}
            ,   disconnect    = args['disconnect']    || function(){}
            ,   presence      = args['presence']      || 0
            ,   noheresync    = args['noheresync']    || 0
            ,   sub_timeout   = args['timeout']       || SUB_TIMEOUT
            ,   windowing     = args['windowing']     || SUB_WINDOWING
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

            // Test Network Connection
            function _test_connection(success) {
                if (success) {
                    // Begin Next Socket Connection
                    timeout( _connect, SECOND );
                }
                else {
                    // New Origin on Failed Connection
                    origin = nextorigin(ORIGIN);

                    // Re-test Connection
                    timeout( function() {
                        SELF['time'](_test_connection);
                    }, SECOND );
                }

                // Disconnect & Reconnect
                each_channel(function(channel){
                    // Reconnect
                    if (success && channel.disconnected) {
                        channel.disconnected = 0;
                        return channel.reconnect(channel.name);
                    }

                    // Disconnect
                    if (!success && !channel.disconnected) {
                        channel.disconnected = 1;
                        channel.disconnect(channel.name);
                    }
                });
            }

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
                    fail     : function() { SELF['time'](_test_connection) },
                    data     : { 'uuid' : UUID },
                    url      : [
                        origin, 'subscribe',
                        SUBSCRIBE_KEY, encode(channels),
                        jsonp, TIMETOKEN
                    ],
                    success : function(messages) {
                        if (!messages) return timeout( _connect, windowing );

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

                        timeout( _connect, windowing );
                    }
                });
            }

            CONNECT = function() {
                // Close Previous Subscribe Connection
                _reset_offline();

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

        // Expose PUBNUB Functions
        'xdr'      : xdr,
        'ready'    : ready,
        'db'       : db,
        'each'     : each,
        'map'      : map,
        'grep'     : grep,
        'css'      : css,
        '$'        : $,
        'create'   : create,
        'bind'     : bind,
        'supplant' : supplant,
        'head'     : head,
        'search'   : search,
        'attr'     : attr,
        'now'      : rnow,
        'unique'   : unique,
        'events'   : events,
        'updater'  : updater,
        'init'     : CREATE_PUBNUB
    };

    function each_channel(callback) {
        each( generate_channel_list(CHANNELS), function(channel) {
            var chan = CHANNELS[channel];
            if (!chan) return;
            callback(chan);
        } );
    }

    if (!UUID) UUID = SELF['uuid']();
    db['set']( SUBSCRIBE_KEY + 'uuid', UUID );

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

    // Add Leave Functions
    bind( 'beforeunload', window, function() {
        each_channel(function(ch){ LEAVE( ch.name, 1 ) });
        return true;
    } );

    // Test Connection State
    function _is_online() {
        if (!('onLine' in navigator)) return 1;
        return navigator['onLine'];
    }
    function _poll_online() {
        _is_online() || _reset_offline();
        timeout( _poll_online, SECOND );
    }
    function _poll_online2() {
        SELF['time'](function(success){
            success || _reset_offline();
            timeout( _poll_online2, KEEPALIVE );
        });
    }
    function _reset_offline() {
        SUB_RECEIVER && SUB_RECEIVER(1);
    }
    timeout( _poll_online,  SECOND    );
    timeout( _poll_online2, KEEPALIVE );

    bind( 'offline', window,        _reset_offline );
    bind( 'offline', document,      _reset_offline );
    bind( 'offline', document.body, _reset_offline );

    // Return PUBNUB Socket Object
    return SELF;
};

// CREATE A PUBNUB GLOBAL OBJECT
PUBNUB = CREATE_PUBNUB({
    'publish_key'   : attr( PDIV, 'pub-key' ),
    'subscribe_key' : attr( PDIV, 'sub-key' ),
    'ssl'           : !document.location.href.indexOf('https') ||
                      attr( PDIV, 'ssl' ) == 'on',
    'origin'        : attr( PDIV, 'origin' ),
    'uuid'          : attr( PDIV, 'uuid' )
});

// PUBNUB Flash Socket
css( PDIV, { 'position' : 'absolute', 'top' : -SECOND } );

if ('opera' in window || attr( PDIV, 'flash' )) PDIV['innerHTML'] =
    '<object id=pubnubs data='  + SWF +
    '><param name=movie value=' + SWF +
    '><param name=allowscriptaccess value=always></object>';

var pubnubs = $('pubnubs') || {};

// PUBNUB READY TO CONNECT
function ready() { PUBNUB['time'](rnow);
PUBNUB['time'](function(t){ timeout( function() {
    if (READY) return;
    READY = 1;
    each( READY_BUFFER, function(connect) { connect() } );
}, SECOND ); }); }

// Bind for PUBNUB Readiness to Subscribe
bind( 'load', window, function(){ timeout( ready, 0 ) } );

// Create Interface for Opera Flash
PUBNUB['rdx'] = function( id, data ) {
    if (!data) return FDomainRequest[id]['onerror']();
    FDomainRequest[id]['responseText'] = unescape(data);
    FDomainRequest[id]['onload']();
};

function FDomainRequest() {
    if (!pubnubs['get']) return 0;

    var fdomainrequest = {
        'id'    : FDomainRequest['id']++,
        'send'  : function() {},
        'abort' : function() { fdomainrequest['id'] = {} },
        'open'  : function( method, url ) {
            FDomainRequest[fdomainrequest['id']] = fdomainrequest;
            pubnubs['get']( fdomainrequest['id'], url );
        }
    };

    return fdomainrequest;
}
FDomainRequest['id'] = SECOND;

// jQuery Interface
window['jQuery'] && (window['jQuery']['PUBNUB'] = PUBNUB);

// For Modern JS + Testling.js - http://testling.com/
typeof(module) !== 'undefined' && (module['exports'] = PUBNUB) && ready();

})();
