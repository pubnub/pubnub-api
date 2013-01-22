/* ---------------------------------------------------------------------------

    Init PubNub and Get your PubNub API Keys:
    http://www.pubnub.com/account#api-keys

--------------------------------------------------------------------------- */

var pubnub       = require('./../pubnub'); 
var createPubNub = function(config) { 
    var that    = {}; 
    var handler = pubnub.init({ 
        subscribe_key: 'demo' 
    }); 
    that.subscribe = function(options) { 
        handler.subscribe(options); 
    }; 
    return that; 
}; 

var messaging      = createPubNub(); 
var createListener = function(channel) { 
    messaging.subscribe({ 
        channel : channel, 
        callback : function(message) { 
            console.log(new Date(), channel, 'Got Message:', message); 
        }, 
        error : function() { 
            console.log(new Date(), channel, 'Connection Lost.'); 
        }, 
        connect : function() { 
            console.log(new Date(), channel, 'Connected.'); 
        }, 
        reconnect : function() { 
            console.log(new Date(), channel, 'Reconnected.'); 
        }, 
        disconnect : function() { 
            console.log(new Date(), channel, 'Disconnect.'); 
        } 
    }); 
}; 

for ( var i = 2; i < process.argv.length; i += 1) { 
    createListener(process.argv[i]); 
} 
