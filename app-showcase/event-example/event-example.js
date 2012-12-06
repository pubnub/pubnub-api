(function(){

    // -----------------------------------------------------------------------
    // PubNub Settings
    // -----------------------------------------------------------------------
    var channel = 'my-channel-name-here'
    ,   pubnub  = PUBNUB.init({
        publish_key   : 'demo',
        subscribe_key : 'demo'
    });

    // -----------------------------------------------------------------------
    // My-Example-Event Event
    // -----------------------------------------------------------------------
    pubnub.events.bind( 'My-Example-Event', function(message) {
        message
    } )

    // -----------------------------------------------------------------------
    // Presence Data Event
    // -----------------------------------------------------------------------
    pubnub.events.bind( 'presence', function(data) {
        // Show User Count, etc.
        data.occupancy
    } );

    // -----------------------------------------------------------------------
    // Open Receiving Socket Connection
    // -----------------------------------------------------------------------
    pubnub.subscribe({
        channel  : channel,
        presence : presence,
        callback : receive
    });

    // -----------------------------------------------------------------------
    // Presence Event
    // -----------------------------------------------------------------------
    function presence( data, envelope, source_channel ) {
        pubnub.events.fire( 'presence', {
            occupancy : data.occupancy,
            user_ids  : data.uuids,
            channel   : source_channel
        });
    }

    // -----------------------------------------------------------------------
    // Receive Data
    // -----------------------------------------------------------------------
    function receive( message, envelope, source_channel ) {
        pubnub.events.fire( message.type, {
            message : message,
            channel : source_channel
        });
    }

    // -----------------------------------------------------------------------
    // New channels -AUTO MULTIPLEXES FOR YOU. v3.4 only.
    // -----------------------------------------------------------------------
    pubnub.subscribe({ channel : 'friend_ID1', callback : receive });
    pubnub.subscribe({ channel : 'friend_ID2', callback : receive });

    // Adding More Channels Using Array
    pubnub.subscribe({
        channel  : ['friend_ID3','friend_ID4','friend_ID5','friend_ID6'],
        callback : receive
    });

    // Adding More Channels Using Comma List
    pubnub.subscribe({
        channel  : 'friend_ID7,friend_ID8,friend_ID9',
        callback : receive
    });

    // -----------------------------------------------------------------------
    // Send Data From Browser (only if publish_key key supplied)
    // -----------------------------------------------------------------------
    function send( type, data ) {
        pubnub.publish({
            channel : channel,
            message : { type : type, data : data }
        });
    }

})();
