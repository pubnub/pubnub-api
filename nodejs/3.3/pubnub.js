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
    setup.url.unshift('');
    //console.log(setup.url);
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
    //console.log(origin);
    //console.log(ssl);
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
    setup['db'] = {'set': function(){}, 'get': function(){}};
    setup['timeout'] = 1000;
    setup['jsonp_cb'] = function(){return '0'};
    PN.__proto__ = PN_API(setup);    
   
    return PN;
}
exports.unique = unique
