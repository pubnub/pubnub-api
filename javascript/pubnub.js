
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


(window['JSON'] && window['JSON']['stringify']) || (function () {
    window['JSON'] || (window['JSON'] = {});

    function f(n) {
        // Format integers to have at least two digits.
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

// If the string contains no control characters, no quote characters, and no
// backslash characters, then we can safely slap some quotes around it.
// Otherwise we must also replace the offending characters with safe escape
// sequences.

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

// Produce a string from holder[key].

        var i,          // The loop counter.
            k,          // The member key.
            v,          // The member value.
            length,
            mind = gap,
            partial,
            value = holder[key];

// If the value has a toJSON method, call it to obtain a replacement value.

        if (value && typeof value === 'object' &&
                typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }

// If we were called with a replacer function, then call the replacer to
// obtain a replacement value.

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

// What happens next depends on the value's type.

        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':

// JSON numbers must be finite. Encode non-finite numbers as null.

            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':

// If the value is a boolean or null, convert it to a string. Note:
// typeof null does not produce 'null'. The case is included here in
// the remote chance that this gets fixed someday.

            return String(value);

// If the type is 'object', we might be dealing with an object or an array or
// null.

        case 'object':

// Due to a specification blunder in ECMAScript, typeof null is 'object',
// so watch out for that case.

            if (!value) {
                return 'null';
            }

// Make an array to hold the partial results of stringifying this object value.

            gap += indent;
            partial = [];

// Is the value an array?

            if (Object.prototype.toString.apply(value) === '[object Array]') {

// The value is an array. Stringify every element. Use null as a placeholder
// for non-JSON values.

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }

// Join all of the elements together, separated with commas, and wrap them in
// brackets.

                v = partial.length === 0 ? '[]' :
                    gap ? '[\n' + gap +
                            partial.join(',\n' + gap) + '\n' +
                                mind + ']' :
                          '[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }

// If the replacer is an array, use it to select the members to be stringified.

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

// Otherwise, iterate through all of the keys in the object.

                for (k in value) {
                    if (Object.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }

// Join all of the member texts together, separated with commas,
// and wrap them in braces.

            v = partial.length === 0 ? '{}' :
                gap ? '{\n' + gap + partial.join(',\n' + gap) + '\n' +
                        mind + '}' : '{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }

// If the JSON object does not yet have a stringify method, give it one.

    if (typeof JSON['stringify'] !== 'function') {
        JSON['stringify'] = function (value, replacer, space) {

// The stringify method takes a value and an optional replacer, and an optional
// space parameter, and returns a JSON text. The replacer can be a function
// that can replace values, or an array of strings that will select the keys.
// A default replacer method can be provided. Use of the space parameter can
// produce text that is more easily readable.

            var i;
            gap = '';
            indent = '';

// If the space parameter is a number, make an indent string containing that
// many spaces.

            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }

// If the space parameter is a string, it will be used as the indent string.

            } else if (typeof space === 'string') {
                indent = space;
            }

// If there is a replacer, it must be a function or an array.
// Otherwise, throw an error.

            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                     typeof replacer.length !== 'number')) {
                throw new Error('JSON.stringify');
            }

// Make a fake root object containing our value under the key of ''.
// Return the result of stringifying the value.

            return str('', {'': value});
        };
    }


// If the JSON object does not yet have a parse method, give it one.

    if (typeof JSON['parse'] !== 'function') {
        // JSON is parsed on the server for security purposes.
        JSON['parse'] = function (text, reviver) {return eval('('+text+')')};

        // JSON is parsed on the server for security purposes.
        // No need for extra client code.
        /*JSON['parse'] = function (text, reviver) {

// The parse method takes a text and an optional reviver function, and returns
// a JavaScript value if the text is a valid JSON text.

            var j;

            function walk(holder, key) {

// The walk method is used to recursively walk the resulting structure so
// that modifications can be made.

                var k, v, value = holder[key];
                if (value && typeof value === 'object') {
                    for (k in value) {
                        if (Object.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if (v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }


// Parsing happens in four stages. In the first stage, we replace certain
// Unicode characters with escape sequences. JavaScript handles many characters
// incorrectly, either silently deleting them, or treating them as line endings.

            text = String(text);
            cx.lastIndex = 0;
            if (cx.test(text)) {
                text = text.replace(cx, function (a) {
                    return '\\u' +
                        ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                });
            }

// In the second stage, we run the text against regular expressions that look
// for non-JSON patterns. We are especially concerned with '()' and 'new'
// because they can cause invocation, and '=' because it can cause mutation.
// But just to be safe, we want to reject all unexpected forms.

// We split the second stage into 4 regexp operations in order to work around
// crippling inefficiencies in IE's and Safari's regexp engines. First we
// replace the JSON backslash pairs with '@' (a non-JSON character). Second, we
// replace all simple value tokens with ']' characters. Third, we delete all
// open brackets that follow a colon or comma or that begin the text. Finally,
// we look to see that the remaining characters are only whitespace or ']' or
// ',' or ':' or '{' or '}'. If that is so, then the text is safe for eval.

            if (/^[\],:{}\s]*$/.
test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@').
replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

// In the third stage we use the eval function to compile the text into a
// JavaScript structure. The '{' operator is subject to a syntactic ambiguity
// in JavaScript: it can begin a block or an object literal. We wrap the text
// in parens to eliminate the ambiguity.

                j = eval('(' + text + ')');

// In the optional fourth stage, we recursively walk the new structure, passing
// each name/value pair to a reviver function for possible transformation.

                return typeof reviver === 'function' ?
                    walk({'': j}, '') : j;
            }

// If the text is not JSON parseable, then a SyntaxError is thrown.

            throw new SyntaxError('JSON.parse');
        };*/
    }
}());


window['PUBNUB'] || (function() {
window.console||(window.console=window.console||{});
console.log||(console.log=((window.opera||{}).postError||function(){}));

/**
 * NOW
 * ===
 * var timestamp = now();
 */
var now = function() {
    return++NOW+''+(+new Date)
    //return+new Date
},  NOW = 1


/**
 * $
 * =
 * var div = $('divid');
 */
,  $ = function(id) {
    return document.getElementById(id);


/**
 * LOG
 * ===
 * log('message');
 */
},  log = function(message) {
    console['log'](message);


/**
 * SEARCH
 * ======
 * var elements = search('a div span');
 */
},  search = function(elements) {
    var list = [];
    each( elements.split(/\s+/), function(el) {
        each( document.getElementsByTagName(el), function(node) {
            list.push(node);
        } );
    } );
    return list

/**
 * EACH
 * ====
 * each( [1,2,3], function(item) { console.log(item) } )
 */
},  each = function( o, f ) {
    if ( !o || !f ) return;

    if ( typeof o[0] != 'undefined' )
        for ( var i = 0, l = o.length; i < l; )
            f.call( o[i], o[i], i++ );
    else 
        for ( var i in o )
            o.hasOwnProperty    &&
            o.hasOwnProperty(i) &&
            f.call( o[i], i, o[i] );

/**
 * WALK
 * ====
 * walk( search('body')[0], function(node) { node.doSomething; } )
 */
},  walk = function( n, f ) {
    f.call( n, n );
    n = n.firstChild;
    while (n) {
        walk( n, f );
        n = n.nextSibling;
    }

/**
 * MAP
 * ===
 * var list = map( [1,2,3], function(item) { return item + 1 } )
 */
},  map = function( list, fun ) {
    var fin = [];
    each( list || [], function( k, v ) { fin.push(fun( k, v )) } );
    return fin

/**
 * GREP
 * ====
 * var list = grep( [1,2,3], function(item) { return item % 2 } )
 */
},  grep = function( list, fun ) {
    var fin = [];
    each( list || [], function(l) { fun(l) && fin.push(l) } );
    return fin

/**
 * PARAMS
 * ======
 * var params = grep( script )
},  params = function( script ) {
    if (!script) return;
    grep( search('script'), function(script) {
        return ((script||{}).src||'').indexOf('simple-chat') != -1;
    } )[0].src.split(/[&=]/).slice(-1);

 */



/**
 * SUPPLANT
 * ========
 * var text = supplant( 'Hello {name}!', { name : 'John' } )
 */
},  magic = /\$?{([\w\-]+)}/g
,   supplant = function( str, values ) {
    return str.replace( magic, function( _, match ) {
        return ''+values[match] || ''
    } );

/**
 * BIND
 * ====
 * bind( 'keydown', search('a')[0], function(element) {
 *     console.log( element, '1st anchor' )
 * } );
 */
},  bind = function( type, el, fun ) {
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


/**
 * UNBIND
 * ======
 * unbind( 'keydown', search('a')[0] );
 */
},  unbind = function( type, el, fun ) {
    if ( el.removeEventListener ) el.removeEventListener( type, false );
    else if ( el.detachEvent ) el.detachEvent( 'on' + type, false );
    else  el[ 'on' + type ] = null;


/**
 * HEAD
 * ====
 * head().appendChild(elm);
 */
},  head = function() { return search('head')[0] }


/**
 * URLIZE
 * ======
 * var query_string = urlize({key:'dat'});
 */
,   urlize = function( data, url ) {
    if (!data) return '';
    var params = [], key = '';
    for ( key in data ) params.push( escape(key) + '=' + escape(data[key]) );
    return (url.indexOf('?') === -1 ? '?' : '&') + params.join('&')

/**
 * ATTR
 * ====
 * var attribute = attr( node, 'attribute' );
 */
},  attr = function( node, attribute, value ) {
    if (value) node.setAttribute( attribute, value );
    else return node && node.getAttribute && node.getAttribute(attribute);


/**
 * CSS
 * ===
 * var obj = create('div');
 */
},  css = function( element, styles ) {
    for (var style in styles) if (styles.hasOwnProperty(style))
        try {element.style[style] = styles[style] + (
            '|width|height|top|left|'.indexOf(style) > 0 ? 'px' : ''
        )}catch(e){}

/**
 * CREATE
 * ======
 * var obj = create('div');
 */
},  create = function(element) {
    return document.createElement(element);


/**
 * BEGET
 * =====
 * var obj = beget(oldObject);
},  beget = function(o) {
    function F() {}
    F.prototype = o;
    return new F();
*/

/**
 * PARSE
 * =====
 * var obj = parse("{obj:'dat'}");
 */
},  parse = function(str) {
    return JSON['parse'](str)


/**
 * STRINGIFY
 * =========
 * var obj = parse("{obj:'dat'}");
 */
},  stringify = function(obj) {
    return JSON['stringify'](obj)


/**
 * XDR Cross Domain Request
 * ========================
 *  xdr({
 *     url  : 'url',  // required
 *     type : 'text', // [script, json, text]
 *     data : {
 *         'key' : 'value',
 *         'key' : 'value'
 *     },
 *     success : function(response) {
 *         // your code here
 *     },
 *     fail : function() {
 *         // your code here
 *     }
 * });
 */
},  ASYNC  = 'async'
,   XORIGN = 1
,   xdr    = function( setup ) {
    // Do XHR instead if possible.
    if (XORIGN) return ajax(setup);

    var script    = create('script')
    ,   unique    = 'x'+now()
    ,   waitlimit = 100
    ,   timeout   =setTimeout(function(){done('timeout')},setup.timeout||30000)
    ,   url       = setup.url
    ,   data      = setup.data    || {}
    ,   fail      = setup.fail    || function(){}
    ,   success   = setup.success || function(){}
    ,   append    = function() { setTimeout( function() { 
            waitlimit *= 2;
            try {
                var myhead  = head()
                ,   myfirst = myhead.firstChild;

                if (myfirst) myhead.insertBefore( script, myfirst );
                else myhead.appendChild(script);
            }
            catch(err) { append(); }
         }, waitlimit ) }

    ,   done = function(failed) {
            clearTimeout(timeout);
            if (!script) return;
            failed && fail.call( failed, script, unescape(script.src) );
            script.onerror = null;
            try {head().removeChild(script);} catch(error) {}
        };

    script[ASYNC] = ASYNC;

    window[unique] = function(response) {
        // Stop if there isn't a response.
        if ( !response ) return done('no data');

        // invoke user defined function
        success.call( script, response );

        // destroy
        window[unique] = null;
        done(0);
    };

    bind( 'error', script, function() { done('error') } );

    data['unique'] = unique;
    script.src     = url + urlize( data, url );

    // try to call xdr as soon as possible.
    append();

    return done;

},  jsonp_rx = /^[^\(]+\((.+?)\)$/
,   ajax     = function( setup ) {
    var xhr = window['ActiveXObject'] ?
              new window['ActiveXObject']("Microsoft.XMLHTTP") :
              new XMLHttpRequest()
    ,   rsc = function() {
            if (  // complete?
                xhr &&
                xhr.readyState == 4 &&
                !done
            ) {
                var status = xhr.status;
                done = 1;

                if (ival) {
                    clearInterval(ival);
                    ival = null;
                }

                // Invoke Success Or Failure
                if (
                    (status >= 200 && status < 300) ||
                    status == 304 || status == 1223
                ) {
                    success(JSON.parse(
                        xhr.responseText.replace( jsonp_rx, '$1' )
                    ));
                }
                else fail(xhr);

                // Done with XHR
                xhr = null;
            }
        }
    ,   fail    = setup.fail    || function(){}
    ,   success = setup.success || function(){}
    ,   done    = 0
    ,   data    = setup.data || {}
    ,   url     = setup.url
    ,   ival    = setInterval( rsc, 14 ); // polling method

    data['unique'] = 'x'+now();

    // Send
    try {
        xhr.open( 'GET', url + urlize( data, url ), true );
        xhr.send();
    }
    catch(eee) {
        XORIGN = 0;
        return xdr(setup);
    }

    // Return 'done'
    return function() {
        done = 1;
        if (xhr) {
            xhr.abort && xhr.abort();
        }
    };
};



/* =-=====================================================================-= */
/* =-=====================================================================-= */
/* =-=========================     PUBNUB     ============================-= */
/* =-=====================================================================-= */
/* =-=====================================================================-= */


// Build Interface
var ORIGIN     = 'http://{{ORIGIN}}/'
//,   WEBSOCKET  = window['WebSocket'] 
,   LIMIT      = 1700
,   PUBNUB     = {
    /*
        // History
        PUBNUB.history( {
            channel : 'my_chat_channel',
            limit   : 100
        }, function(messages) {
            console.log(messages);
        } );
    */
    'history' : function( args, callback ) {
        callback = callback || function(){};
        args['limit'] = args['limit'] || 100;

        // Make sure we have a Channel
        if (!args['channel']) return log('Must Specify a Channel');

        // Setup Data
        args['channel'] = PUBNUB.subscribe_key + '/' + args['channel'];

        // Send Message
        xdr({
            url     : ORIGIN + 'pubnub-history',
            data    : args,
            success : function(response) {
                callback(response['messages']);
            },
            fail : function(response) {
                log(response);
            }
        });
    },

    /*
        // Time API Call
        PUBNUB.time(function(time) {
            console.log(time);
        });
    */
    'time' : function(callback) {
        xdr({
            url     : ORIGIN + 'pubnub-time',
            success : function(response) {
                callback(response['time']);
            },
            fail : function() {
                callback(0);
            }
        });
    },

    /*
        // UUID API Call
        PUBNUB.uuid(function(uuid) {
            console.log(uuid);
        });
    */
    'uuid' : function(callback) {
        xdr({
            url     : ORIGIN + 'pubnub-uuid',
            success : function(response) {
                callback(response['uuid']);
            },
            fail : function() {
                callback(0);
            }
        });
    },

    /*
        // Publish to a Channel
        PUBNUB.publish({
            channel : 'my_chat_channel',
            message : 'hello!'
        });
    */
    'publish' : function( args, callback ) {
        callback = callback || function(){} || args['callback'];
        var message = args['message'];

        // Make sure we have a Message
        if (!message) return log('Must Specify a Message');

        // Make sure we have a Channel
        if (!args['channel']) return log('Must Specify a Channel');

        // If trying to send Object
        message = stringify(message);

        // Make sure message is small enough.
        if (message.length > LIMIT)
            return log('Message exceeded limit '+LIMIT);

        // We Require Publish Key
        if (!PUBNUB.publish_key)
            return log('Missing Publish Key');

        // Setup Data
        args['publish_key'] = PUBNUB.publish_key;
        args['channel']     = PUBNUB.subscribe_key + '/' + args['channel'];
        args['message']     = message;

        // Send Message
        xdr({
            url     : ORIGIN + 'pubnub-publish',
            data    : args,
            success : function(response) {
                callback(response);
            },
            fail : function(response) {
                callback(response);
            }
        });
    },

    /*
        // UN-Subscribe and remove Channel
        PUBNUB.subscribe({channel : 'my_chat'});
    */
    'unsubscribe' : function(args) {
        var channel = PUBNUB.subscribe_key + '/' + args['channel'];

        // Leave if there never was a channel.
        if (!(channel in PUBNUB.channels)) return;

        // Disable Channel
        PUBNUB.channels[channel].disabled = 1;
        PUBNUB.channels[channel].connected = 0;

        // Remove Script
        PUBNUB.channels[channel].done && 
        PUBNUB.channels[channel].done(0);

        // Unsubscribe WebSocket
        /*
        PUBNUB.channels[channel].pubnub_ws &&
        PUBNUB.channels[channel].pubnub_ws.close();
        */
    },

    /*
        // Subscribe to a Channel
        PUBNUB.subscribe( {
            channel : 'my_chat_channel'
        }, function(message) {
            console.log(message);
        } );
    */
    ready : 0,
    ready_buffer : [],
    'subscribe' : function( args, callback ) {
        // Reduce Status Flicker
        if (!PUBNUB.ready) {
            return PUBNUB.ready_buffer.push([ args, callback ]);
        }

        // Make sure we have a Channel
        if (!args['channel']) return log('Must Specify a Channel');

        // Make sure we have a Callback
        callback = callback || args['callback'];
        delete args['callback'];
        if (!callback) return log('Must Specify a Callback');

        // Make sure we have a Channel
        if (!PUBNUB.subscribe_key) return log('Missing Subscribe Key');

        var timetoken = 0
        ,   waitlimit = 50
        ,   error     = args['error'] || function(){}
        // ,   ready     = args['ready'] || function(){}
        ,   channel   = args['channel'] =
            PUBNUB.subscribe_key + '/' + args['channel'];

        if (!(channel in PUBNUB.channels))
            PUBNUB.channels[channel] = {};

        // Make sure we have a Channel
        if (PUBNUB.channels[channel].connected) return log(
            'Already Connected to this Channel: ' + channel
        );

        PUBNUB.channels[channel].disabled  = 0;
        PUBNUB.channels[channel].connected = 1;

        function find_PUBNUB_server() {waitlimit *= 2;setTimeout(function() { 
            xdr({
                url     : ORIGIN + 'pubnub-subscribe',
                data    : args,
                success : function(response) {
                    if (response && response['server']) {
                        /*
                        if (WEBSOCKET)
                            pubnub_ws(response['server']);
                        else
                        */
                            pubnub(response['server']);
                    }
                    else {
                        // console.log('NO SERVER???FAILED!!!!');
                        find_PUBNUB_server();
                    }
                },
                fail : function(response) {
                    // console.log('FAILED!!!!');
                    find_PUBNUB_server();
                    error(response);
                }
            });
        }, waitlimit )}

        // Locate Comet Server

        // console.log('Locate Comet Server (First Time)!!!!');
        find_PUBNUB_server();

        // Connect to Channel Recommended Server w/ WEBSOCKET
        /*
        function pubnub_ws(server) {
            if (channel in PUBNUB.channels &&
                PUBNUB.channels[channel].disabled) return;

            var host = server.split(':')
            ,   ws   = new WEBSOCKET(
                "ws://" + host[0] + ':881' + host[1].slice(-1)
            );

            ws['onopen'] = function() {
                console.log('OPENED WS!!!! ---> ' + channel);
                ws.send(channel);
            };

            ws['onmessage'] = function (ws_message) {
                callback(JSON.parse(ws_message.data));
            };

            // Did we close on accident or timeout?
            ws['onclose'] = function() {
                if (
                    channel in PUBNUB.channels &&
                    !PUBNUB.channels[channel].disabled
                ) {
                    waitlimit = 100;
                    console.log('CLOSED WS!!!!');
                    find_PUBNUB_server();
                }
            };

            // Save WS for Unsubscribing.
            PUBNUB.channels[channel].pubnub_ws = ws;
        }
        */


        // Connect To Channel Recommended Server
        function pubnub(server) {
            if (channel in PUBNUB.channels &&
                PUBNUB.channels[channel].disabled) return;

            PUBNUB.channels[channel].done = xdr({
                url     : 'http://' + server + '/',
                // timeout : 20000,
                data    : { 'channel' : channel, 'timetoken' : timetoken },
                success : function(response) {
                    timetoken = response['timetoken'];
                    pubnub(server);

                    if (response['messages'][0] != 'xdr.timeout')
                        each( response['messages'], function(msg) {
                            callback(msg);
                        } );
                },
                fail : function(response) {
                    if (response == 'timeout') pubnub(server);
                    else {
                        // console.log('32FAILED!!!!');
                        find_PUBNUB_server();
                        error(response);
                    }
                }
            });
        }

    },

    // Optional Key to Send Data to a Channel
    publish_key : '{{pub_key}}',

    // Optional Key to Listen for Data on a Channel
    subscribe_key : '{{sub_key}}',

    // Optional Key to Identify App
    application_key : '{{app_key}}',

    // Stored Information About Connected Channels
    channels : {},

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
    'now'      : now
};

// Test for XHR Cross Domain Origin Capable Browser
/*ajax({
    url : ORIGIN + 'pubnub-x-origin',
    success : function(message) { if (message['x-origin']) XORIGN = 1; }
});
*/

// Bind for PUBNUB.ready
bind( 'load', window, function() { setTimeout( function() {
    PUBNUB.ready = 1;
    each( PUBNUB.ready_buffer, function(sub) {
        PUBNUB['subscribe']( sub[0], sub[1] );
    } );
}, 100 ); } );

// Provide Global Interfaces
window['jQuery'] && (window['jQuery']['PUBNUB'] = PUBNUB);
window['PUBNUB'] = PUBNUB;

})();
