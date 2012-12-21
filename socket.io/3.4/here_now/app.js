(function () {

// -----------------------------------------------------------------------
// PUBNUB SETUP
// -----------------------------------------------------------------------
    var my_user_data = { name:"John" };
    var pubnub_setup = {
        user:my_user_data,
        channel:'bootstrap-app',
        publish_key:'demo',
        subscribe_key:'demo',
        custom_presence:false
    };

// -----------------------------------------------------------------------
// CREATE CONNECTION FOR USER EVENTS
// -----------------------------------------------------------------------
    var socket = io.connect('http://pubsub.pubnub.com/herenow', pubnub_setup);


// -----------------------------------------------------------------------
// WAIT FOR A CONNECTION, then get here_now data
// -----------------------------------------------------------------------
    socket.on('connect', function () {
        console.log('connected!!!');
        getHereNow();
    });

    var getHereNow = function() {
        socket.here_now(function (response) {
            console.log(response);
        });
    }

    textDiv = document.getElementById('text');
    textDiv.onclick = getHereNow;

})();
