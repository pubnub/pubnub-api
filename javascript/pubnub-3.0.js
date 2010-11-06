/*
    WAIT! - This file depends on instructions from the PUBNUB Server.
    It is recommended that you load this file from a <script> include tag.

    Get your JS Include <script> include tag here:
    http://www.pubnub.com/account-javascript-api-include

    Make sure to use that link if you want to use PubNub Comet.
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
/* =-==========================     JSON     =============================-= */
/* =-=====================================================================-= */
/* =-=====================================================================-= */

(window['JSON'] && window['JSON']['stringify']) || (function () {
    window['JSON'] || (window['JSON'] = {});

    function f(n) {
        return n < 10 ? '0' + n : n;
    }

    if (typeof Date.prototype.toJSON !== 'function') {

        Date.prototype.toJSON = function (key) {

            return isFinite(this.valueOf()) ?
                   this.getUTCFullYear()   + '-' +
                 f(this.getUTCMonth() + 1) + '-' +
                 f(this.getUTCDate())      + 'T' +
                 f(this.getUTCHours())     + ':' +
                 f(this.getUTCMinutes())   + ':' +
                 f(this.getUTCSeconds())   + 'Z' : null;
        };

        String.prototype.toJSON =
        Number.prototype.toJSON =
        Boolean.prototype.toJSON = function (key) {
            return this.valueOf();
        };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        gap,
        indent,
        meta = {    // table of character substitutions
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        rep;


    function quote(string) {
        escapable.lastIndex = 0;
        return escapable.test(string) ?
            '"' + string.replace(escapable, function (a) {
                var c = meta[a];
                return typeof c === 'string' ? c :
                    '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
            }) + '"' :
            '"' + string + '"';
    }


    function str(key, holder) {
        var i,          // The loop counter.
            k,          // The member key.
            v,          // The member value.
            length,
            mind = gap,
            partial,
            value = holder[key];

        if (value && typeof value === 'object' &&
                typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':
            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':
            return String(value);

        case 'object':

            if (!value) {
                return 'null';
            }

            gap += indent;
            partial = [];

            if (Object.prototype.toString.apply(value) === '[object Array]') {

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }

                v = partial.length === 0 ? '[]' :
                    gap ? '[\n' + gap +
                            partial.join(',\n' + gap) + '\n' +
                                mind + ']' :
                          '[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }
            if (rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    k = rep[i];
                    if (typeof k === 'string') {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            } else {
                for (k in value) {
                    if (Object.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }

            v = partial.length === 0 ? '{}' :
                gap ? '{\n' + gap + partial.join(',\n' + gap) + '\n' +
                        mind + '}' : '{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }

    if (typeof JSON['stringify'] !== 'function') {
        JSON['stringify'] = function (value, replacer, space) {
            var i;
            gap = '';
            indent = '';

            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }
            } else if (typeof space === 'string') {
                indent = space;
            }
            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                     typeof replacer.length !== 'number')) {
                throw new Error('JSON.stringify');
            }
            return str('', {'': value});
        };
    }

    if (typeof JSON['parse'] !== 'function') {
        // JSON is parsed on the server for security.
        JSON['parse'] = function (text) {return eval('('+text+')')};
    }
}());

/* =-=====================================================================-= */
/* =-=====================================================================-= */
/* =-========================     DOM UTIL     ===========================-= */
/* =-=====================================================================-= */
/* =-=====================================================================-= */

window['PUBNUB'] || (function() {

// ============================================================================
// CONSOLE COMPATIBILITY
// ============================================================================
window.console||(window.console=window.console||{});
console.log||(console.log=((window.opera||{}).postError||function(){}));

// ============================================================================
// DOM UTIL LOCALS
// ============================================================================
var NOW    = 1
,   MAGIC  = /\$?{([\w\-]+)}/g
,   ASYNC  = 'async'
,   URLBIT = '/'
,   XORIGN = 1;

/**
 * UNIQUE
 * ======
 * var timestamp = unique();
 */
function unique() { return++NOW+''+(+new Date) }

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
            '|width|height|top|left|'.indexOf(style) > 0 ? 'px' : ''
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
function jsonp_cb() { return XORIGN ? 0 : 'x'+unique() }

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
    // XHR if possible.
    if (XORIGN) return ajax(setup);

    var script    = create('script')
    ,   callback  = setup.callback
    ,   waitlimit = 25
    ,   timer     = timeout(function(){done(1)},setup.timeout||200000)
    ,   fail      = setup.fail    || function(){}
    ,   success   = setup.success || function(){}

    ,   append = function() { timeout( function() { 
            try {
                var myhead  = head()
                ,   myfirst = myhead.firstChild;

                if (myfirst) myhead.insertBefore( script, myfirst );
                else myhead.appendChild(script);
            }
            catch(err) { append(); }
         }, waitlimit *= 2 ) }

    ,   done = function(failed) {
            clearTimeout(timer);
            if (!script) return;
            failed && fail.call( failed, script, unescape(script.src) );
            script.onerror = null;
            try {head().removeChild(script);} catch(error) {}
        };

    script[ASYNC] = ASYNC;

    window[callback] = function(response) {
        if ( !response ) return done(1);
        success.call( script, response );
        window[callback] = null;
        done(0);
    };

    bind( 'error', script, function() { done(1) } );

    script.src = setup.url.join(URLBIT);

    append();
    return done;
}

/**
 * XDR Cross XHR Request
 * =====================
 *  xdr({
 *     url     : ['http://www.blah.com/url'],
 *     success : function(response) {},
 *     fail    : function() {}
 *  });
 */
function ajax( setup ) {
    var xhr
    ,   rsc = function() {
            if ( xhr && xhr.readyState == 4 && !done ) {
                var status = xhr.status;
                done = 1;

                if (ival) {
                    clearInterval(ival);
                    ival = null;
                }

                // Invoke Success Or Failure
                if (
                    ((status >= 200 && status < 300) ||
                    status == 304 || status == 1223) &&
                    xhr.responseText
                ) {
                    try { response = JSON['parse'](xhr.responseText); }
                    catch(ee) {response = 0; fail(xhr); }
                    response && success(response);
                }
                else fail(xhr);

                // Done with XHR
                xhr = null;
            }
        }
    ,   fail     = setup.fail    || function(){}
    ,   success  = setup.success || function(){}
    ,   response
    ,   done     = 0
    ,   ival     = setInterval( rsc, 20 );

    // Send
    try {
        xhr = new XMLHttpRequest();
        xhr.open( 'GET', setup.url.join(URLBIT), true );
        xhr.send();
    }
    catch(eee) {
        XORIGN = 0;
        ival && clearInterval(ival);
        return xdr(setup);
    }

    // Return 'done'
    return function() {
        done = 1;
        if (xhr) xhr.abort && xhr.abort();
    };
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
,   ORIGIN        = 'http'+SSL+'://pubsub.pubnub.com'
,   LIMIT         = 1800
,   READY         = 0
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
                SUBSCRIBE_KEY, escape(channel),
                jsonp, limit
            ],
            success  : function(response) { callback(response['messages']) },
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
            success  : function(response) { callback(response['time'][0]) },
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
            url      : ['http'+SSL+'://www.pubnub.com/uuid?callback='+jsonp],
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
        ,   jsonp    = jsonp_cb()
        ,   respond  = function(response) { callback(response[0]) };

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
            url      : [
                ORIGIN, 'publish',
                PUBLISH_KEY, SUBSCRIBE_KEY,
                0, escape(channel),
                jsonp, escape(message)
            ],
            success  : respond,
            fail     : respond
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

        // Reduce Status Flicker
        if (!READY) return READY_BUFFER.push([ args, callback ]);

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
            xdr({
                callback : jsonp,
                url      : [
                    ORIGIN, 'subscribe',
                    SUBSCRIBE_KEY, escape(channel),
                    jsonp, timetoken
                ],
                fail     : function() { timeout( pubnub, 1000 ); error()  },
                success  : function(message) {
                    timetoken = message[1];
                    pubnub();
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

// Bind for PUBNUB.ready
bind( 'load', window, function() { timeout( function() {
    READY = 1;
    each( READY_BUFFER, function(sub) {
        PUBNUB['subscribe']( sub[0], sub[1] );
    } );
}, 200 ); } );

// Provide Global Interfaces
window['jQuery'] && (window['jQuery']['PUBNUB'] = PUBNUB);
window['PUBNUB'] = PUBNUB;

})();
