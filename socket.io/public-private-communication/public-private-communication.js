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

            if (test.fail) return p.css(
                p.$('finished-fail'),
                { display : 'inline-block' }
            );

            p.css( p.$('finished-success'), { display : 'inline-block' } );
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
        test.plan = 8; // # of tests
        test.pass = 0;  // 0 passes so far
        test.fail = 0;  // 0 failes so far
        test.done = 0;  // 0 tests done so far
        test.run  = 1;  // continue running?

        p.css( stop_button, { display : 'inline-block' } );
        p.css( start_button, { display : 'none' } );
        p.css( p.$('finished-fail'), { display : 'none' } );
        p.css( p.$('finished-success'), { display : 'none' } );

        test( 1, 'Ready to Test' );

        test( 'PUBNUB' in window, 'PubNub Lib Exists' );
        test( 'io' in window, 'Socket.IO Lib Exists' );
        test( 'sjcl' in window, 'Stanford Crypto Lib Exists' );

        var my_user_data = { name : 'John' };
        var public_setup = {
            user          : my_user_data,
            channel       : 'public-channel',
            publish_key   : 'demo',
            subscribe_key : 'demo',
            presence      : false
        };

        var private_setup = {
            user          : my_user_data,
            channel       : 'jIyNTc3X2JIV1U2M2I2ZkR0NzkK',
            publish_key   : 'demo',
            subscribe_key : 'demo',
            presence      : false
        };

        var private_socket = io.connect(
            'http://pubsub.pubnub.com/private',
            private_setup
        );
        var public_socket = io.connect(
            'http://pubsub.pubnub.com/public',
            public_setup
        );

        var public2 = io.connect(
            'http://pubsub.pubnub.com/public2',
            public_setup
        );

        var public3 = io.connect(
            'http://pubsub.pubnub.com/public3',
            public_setup
        );
        var public4 = io.connect(
            'http://pubsub.pubnub.com/public4',
            public_setup
        );

        public_socket.on( 'connect', function() {
            test( 1, 'Public Socket Connected (SOCKET 1)' );
            public_socket.send('public');
        } );

        private_socket.on( 'connect', function() {
            test( 1, 'Private Socket Connected (SOCKET 2)' );
            private_socket.send('private');
        } );

        public_socket.on( 'message', function(message) {
           test( message == 'public', 'Public Message Received (SOCKET 1)' );
        } );

        private_socket.on( 'message', function(message) {
           test( message == 'private', 'Private Message Received (SOCKET 2)' );
        } );

    }
    start_test();

})();
