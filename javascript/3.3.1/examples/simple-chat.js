(function(){

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

<!--
    Simple Chat
    ===========

    View source code on GitHub:
    http://github.com/pubnub/pubnub-api/blob/master/javascript/examples/simple-chat.js

    <STYLE> inside <head>
    <DIV> where Simple Chat will appear.
    <SCRIPT> at BOTTOM of Page

    To change the conversation channel,
    change the channel attribute inside the div.
-->

<style>
    #simple-chat {padding:0;background-color:#c41952}
    #simple-chat-chatbox {height:60px;overflow:scroll;overflow-x:hidden;border:1px solid #ccc;padding:10px;background-color:#fff}
    #simple-chat-textbox {width:320px;margin:9px;font-size:18px}
    #simple-chat-button {width:70px;cursor:pointer;margin:9px;font-size:18px}
</style>

<div id="simple-chat" channel="mychannel">Loading Simple Chat</div>

*/
var P    = PUBNUB
,   chat = {
    init : function( node_name ) {
        var node = P.$(node_name);

        chat.node_name = node_name;

        // Create Nodes
        chat.textbox = P.create('input');
        chat.chatbox = P.create('div');
        chat.button  = P.create('button');

        // Button Text
        chat.button.innerHTML = 'Send';
        
        // Capture Channel
        var channel = P.attr( node, 'channel' );

        // Add Styles
        P.attr( chat.chatbox, 'id', 'simple-chat-chatbox' );
        P.attr( chat.textbox, 'id', 'simple-chat-textbox' );
        P.attr( chat.button, 'id', 'simple-chat-button' );

        // Display Nodes
        node.innerHTML = '';
        node.appendChild(chat.chatbox);
        node.appendChild(chat.textbox);
        node.appendChild(chat.button);

        // Send Sign-on Message
        P.publish({
            channel : channel,
            message : 'Someone Joined the Chat.'
        });

        function send(e) {
            var key     = e.keyCode || e.charCode || 0
            ,   message = chat.textbox.value;

            // Wait for Enter Key
            if (key != 13 && e.type == 'keydown' || !message) return true;

            // Reset Value
            chat.textbox.value = '';

            // Send Message
            P.publish({
                channel : node_name,
                message : message
            });
        }

        // Bind Events
        P.bind( 'keydown', chat.textbox, send );
        P.bind( 'blur', chat.textbox, send );

        // Register Listener
        P.subscribe({ channel : node_name }, chat.subscribe );
    },

    subscribe : function(message) {
        var br       = '<br/>';
        chat.chatbox.innerHTML = message + br + chat.chatbox.innerHTML;
    }

};

// Startup Simple Chat
chat.init('simple-chat');

})()
