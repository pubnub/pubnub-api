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
        custom_presence:false,
        presence:false
    };

// -----------------------------------------------------------------------
// CREATE CONNECTION FOR USER EVENTS
// -----------------------------------------------------------------------
    var socket = io.connect('http://pubsub.pubnub.com/history', pubnub_setup);


// -----------------------------------------------------------------------
// WAIT FOR A CONNECTION, then publish and get history
// -----------------------------------------------------------------------

    socket.on('connect', function () {
        console.log('connected!!!');
        seedHistory();
    });


    function seedHistory() {

        for (a = 0; a < 9; a++) {
            socket.send('test data ' + a, function (message) { console.log("Seeding history data: " + message)} );
        }

        getHistory(socket);
    }

    var getHistory = function() {
        socket.history({'count':10}, function (response) {
            console.log(response);
        });
    }

    textDiv = document.getElementById('text');
    textDiv.onclick = getHistory;


})();
