(function(){

    function test( t, msg ) {
        if (!test.run) return;


        t ? test.pass++ : test.fail++;
        test.done++;

        console.log( t, msg );

        status_area.innerHTML = p.supplant( status_tpl, {
            pass  : test.pass+'',
            fail  : test.fail+'',
            total : test.done+''
        } );

        if (test.done === test.plan) {
            stop_test();
        }
    }

    var p            = PUBNUB
    ,   many_con_tst = 'opera' in window ? -1 : 10
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
        test.plan = 19 + many_con_tst*3; // # of tests
        test.done = 0;  // 0 tests done so far
        test.pass = 0;  // 0 passes so far
        test.fail = 0;  // 0 failes so far
        test.run  = 1;  // continue running?

        p.css( stop_button, { display : 'inline-block' } );
        p.css( start_button, { display : 'none' } );
        p.css( p.$('finished-fail'), { display : 'none' } );
        p.css( p.$('finished-success'), { display : 'none' } );

        test( 1, 'Ready to Test' );
        test( PUBNUB, 'PubNub Lib Exists' );

        p.time(function(time){
            test( time, 'TimeToken' );
            test( time > 0, 'Time Value' );
        });

        p.uuid(function(uuid){
            test( uuid, 'UUID Response');
            test( uuid.length > 10, 'UUID Long Enough');
        });

        function publish_test(con) {
            con || test( 1, 'Connection Established' );

            p.publish({
                channel  : channel,
                message  : { test : "test" },
                callback : function(response) {
                    test( response[0], 'Successful Publish' );
                    test( response[1] === 'D', 'Success With Demo' );
                    history_test();
                }
            });
        }

        publish_test(1);

        function history_test() {
            p.history({
                limit    : 1,
                channel  : channel,
                callback : function(messages) {
                    test( messages, 'History Response' );
                    test( messages[0].test === "test", 'History Content' );
                }
            });
        }

        p.subscribe({
            channel  : channel,
            connect  : publish_test,
            callback : function( message, stack ) {
                p.unsubscribe({ channel : channel });
                test( message, 'Subscribe Message' );
                test( message.test === "test", 'Subscribe Message Data' );
                test( stack[1], 'TimeToken Returned: ' + stack[1] );
            }
        });

        /* ------------------------------------------------------------------
        --- MANY CONNECTIONS TESTS
        ------------------------------------------------------------------ */
        p.map( Array(many_con_tst).join('-').split('-'), function( _, conn ) {
            var chan = 'many-conn-test-' + conn;
            test( chan, 'Many Connections: ' + conn + ' Connecting...' );

            p.subscribe({
                channel  : chan,
                connect  : function() {
                    test( chan, 'Many Connections: ' + conn + ' Connected!' );
                    p.publish({ channel : chan, message : chan });
                },
                callback : function(message) {
                    test(
                        chan === message,
                        'Many Connections: ' + conn + ' Received'
                    );
                    setTimeout(
                        function() { p.unsubscribe({ channel : chan }) },
                        5000
                    );
                }
            });
        } );

        /* ------------------------------------------------------------------
        --- TESTING NEW CONNECTION RESTORE FEATURE
        ------------------------------------------------------------------ */
        var restore_channel = 'restore-channel'+Math.random();
        p.subscribe({
            restore  : true,
            channel  : restore_channel,
            callback : function(){},
            connect  : function() {
                p.unsubscribe({ channel : restore_channel });

                // Send Message While Not Connected
                p.publish({
                    channel  : restore_channel,
                    message  : 'test',
                    callback : function() {
                        p.subscribe({
                            restore  : true,
                            channel  : restore_channel,
                            callback : function( message, stack ) {
                                p.unsubscribe({ channel : restore_channel });
                                test(
                                    message === "test",
                                    'Subscribe Restore'
                                );
                            }
                        });
                    }
                });
            }
        });

    }
    start_test();

})();
