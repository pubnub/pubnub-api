(function(){

    function test( t, msg ) {
        if (!test.run) return;

        var entry = p.create('tr');

        entry.innerHTML = p.supplant( test_tpl, {
            result  : t ? 'success' : 'important',
            display : t ? 'pass'    : 'fail',
            message : msg
        } );

        t ? test.pass++ : test.fail++;
        test.done++;

        out.insertBefore( entry, out.firstChild );
        console.log( t, msg );

        status_area.innerHTML = p.supplant( status_tpl, {
            pass  : test.pass+'',
            fail  : test.fail+'',
            total : test.done+''
        } );

        if (test.done === test.plan) {
            stop_test();
            test.fail ||
            p.css( p.$('finished-success'), { display : 'inline-block' } ) &&
            p.css( p.$('finished-fail'), { display : 'inline-block' } );
        }
    }

    var p            = PUBNUB
    ,   channel      = 'pn-javascript-unit-test'
    ,   out          = p.$('unit-test-out')
    ,   test_tpl     = p.$('test_template').innerHTML
    ,   start_button = p.$('start-test')
    ,   stop_button  = p.$('stop-test')
    ,   status_area  = p.$('test-status')
    ,   status_tpl   = p.attr( status_area, 'template' );


    /* ======================================================================
    Stop Test
    ====================================================================== */
    p.bind( 'mousedown,touchstart', stop_button, stop_test );
    function stop_test() {
        p.css( start_button, { display : 'inline-block' } );
        p.css( stop_button, { display : 'none' } );
        test.run = 0;
    }

    /* ======================================================================
    Start Test
    ====================================================================== */
    p.bind( 'mousedown,touchstart', start_button, start_test );
    function start_test() {
        test.plan = 10; // # of tests
        test.pass = 0;  // 0 passes so far
        test.fail = 0;  // 0 failes so far
        test.done = 0;  // 0 tests done so far
        test.run  = 1;  // continue running?

        p.css( stop_button, { display : 'inline-block' } );
        p.css( start_button, { display : 'none' } );
        p.css( p.$('finished-fail'), { display : 'none' } );
        p.css( p.$('finished-success'), { display : 'none' } );

        test( 1, 'Ready to Test' );
        test( PUBNUB, 'PubNub Lib Exists' );
        test( io, 'Socket.IO Lib Exists' );

        var pubnub_setup = {
            channel       : 'my_mobile_app',
            publish_key   : 'demo',
            subscribe_key : 'demo',
            ssl           : false
        };

        // Multi-plexing Single Connection
        var feed = io.connect(
            'http://pubsub.pubnub.com/feed',
            pubnub_setup
        );
        var chat = io.connect(
            'http://pubsub.pubnub.com/chat',
            pubnub_setup
        );

        // Ordinary Socket
        var socket = io.connect( 'http://pubsub.pubnub.com', pubnub_setup );

        socket.on( 'connect', function() {
            test( feed, 'Socket Connection Estabilshed.' );
            socket.send('sock');
        } );

        socket.on( 'message', function(message) {
            test( message === 'sock', 'Received Socket Message' );
        } );

        // CONNECTION ESTABLISHED
        feed.on( 'connect', function() {
            test( feed, 'Feed Connection Estabilshed.' );
            feed.send({ title : 'Update', body : 'Text Body' });
            feed.emit( 'my-custom-event', 123456 );
        } );

        // MESSAGE SEND/RECEIVE
        feed.on( 'message', function(message) {
            test( message.title === "Update", 'Feed Message Received' );
        } );

        feed.on( 'my-custom-event', function(message) {
            test( message === 123456, 'Custom Feed Event Received' );
        } );

        chat.on( 'connect', function() {
            test( chat, 'Chat Connection Estabilshed.' );
            chat.send("Hi");
        } );

        // MESSAGE SEND/RECEIVE
        chat.on( 'message', function(message) {
            test( message === "Hi", 'Chat Message Received' );
        } );

        // CONNECTION LOST/RESTORED
        feed.on( 'disconnect', function() {
            console.log('Error, Lost Connection.');
        } );
        feed.on( 'reconnect', function() {
            console.log('Connection Restored.');
        } );

        // USER JOINS/PARTS CHAT
        chat.on( 'join', function(user) {
            
        } );
        chat.on( 'leave', function(user) {
            
        } );


/*
        socket.on('connect', function () {
            socket.send('hi');

            socket.on('message', function (msg) {
                // my msg
            });
        });

        socket.on( 'news', function (data) {
            console.log(data);
            socket.emit( 'my other event', { my: 'data' } );
        } );

        var socket = io.connect();
        socket.on('connect', function () {
            socket.emit('ferret', 'tobi', function (data) {
                console.log(data);
            });
        });
        */
    }
    start_test();

})();
