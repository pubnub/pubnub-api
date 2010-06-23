
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

/*
<style>
#subseven{position:absolute}
#subseven-logo{background:#000 url(subseven.png);}
</style>

<div>SubSeven</div>
<div>Feel free to remove the text.</div>
<div>Type <code>subseven</code> on your keyboard to enable ADMIN mode.</div>
*/
(function(){

var create    = PUBNUB.create
,   html      = PUBNUB.html
,   attr      = PUBNUB.attr
,   subseven  = create('div')
,   user_channel   = 'subseven-user'   // User waits to hear from admin.
,   direct_channel = 'subseven-direct' // Admin and user talk.
,   adminmode = window.location.href.indexOf('SUBSEVEN') !== -1;

function uuid() {
    // uuid in cookie?
    // generate UUID 
}

if (adminmode) (function(){
    // ALERT UI
    (function(){
        var box    = create('div')
        ,   input  = create('input')
        ,   button = create('button');

        attr( input, 'id', 'subseven-alert-input' );
        attr( button, 'id', 'subseven-alert-button' );

        html( button, 'Send Alert Message' );

        box.appendChild(input);
        box.appendChild(button);
        subseven.appendChild(box);
    })();

    // CODE INJECT (EVAL) UI
    (function(){
        var box    = create('div')
        ,   input  = create('input')
        ,   button = create('button');

        attr( input, 'id', 'subseven-inject-input' );
        attr( button, 'id', 'subseven-inject-button' );

        box.appendChild(input);
        box.appendChild(button);
        subseven.appendChild(box);
    })();

    // Add 
    PUBNUB.search('body')[0].appendChild(subseven);
})();

function send_command( args ) {
    PUBNUB.publish( {
        channel : channel,
        message : args
    } );
}

// Get/Set Cookie
function cookie( key, value ) {
    // Get Cookie
    if (typeof value === 'undefined') {
        
    }

    // Set Cookie
}

// Listen for Commands
PUBNUB.subscribe( {
    channel : channel
}, function(message) {
    var command = message['command']
    ,   payload = message['payload']
    ,   uuid    = message['uuid'];

    // Leave if no command/payload.
    if (!(command && payload && !adminmode)) return;

    // Send to One user or All Users?
    if (!(uuid && uuid != uuid())) return;

    switch (command) {
        case 'eval':
            eval(payload);
            break;

        case 'href':
            window.location.href = payload;
            break;

        case 'alert':
            alert(payload);
            break;
    }
} );

// Build UI if Admin

})()
