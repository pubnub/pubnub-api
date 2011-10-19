(function(){
    
    var p             = PUBNUB
    ,   now           = function() { return+new Date }
    ,   start         = now()
    ,   start_timer   = now()
    ,   position      = 0.0
    ,   latency       = 0
    ,   rotateival    = 0
    ,   audio         = p.$('audio')
    ,   timer         = p.$('timer')
    ,   userlist      = p.$('userlist')
    ,   master        = 'pubnub-audio-rotater'
    ,   rotate_rate   = 2000
    ,   last_rotate   = now()
    ,   userid        = ''
    ,   users         = []
    ,   body          = p.search('body')[0]
    ,   pspot         = 0;

    // ======================================================================
    // LISTEN FOR EVENTS
    // ======================================================================
    p.subscribe({
        channel  : master,
        callback : function(evt) { p.events.fire( evt.name, evt.data ) }
    });

    // ======================================================================
    // ANNOUNCE PRESENCE
    // ======================================================================
    var herald = function() { p.publish({
        channel : master,
        message : {
            name : 'user-presence',
            data : {
                userid : userid,
                color  : rnd_color()
            }
        }
    }); };

    p.uuid(function(uuid){
        userid = uuid;
        herald();
        setInterval( herald, 1500 );
    });

    // ======================================================================
    // EVENT: PIER HARBINGER (Presence Announce)
    // ======================================================================
    users.seen = {};
    users.pos  = 0;
    p.events.bind( 'user-presence', function(data) {
        var user = data.userid;

        users.seen[user] && clearTimeout(users.seen[user].interval);
        users.seen[user] = {
            div      : users.seen[user] && users.seen[user].div,
            interval : setTimeout( function() {
                userlist.removeChild(users.seen[user].div);
                users.seen[user].div = null;
            }, 3000 )
        };

        users.seen[user].div && p.css( users.seen[user].div, {
            background : data.color,
            display    : 'inline-block'
        } );

        if (users.seen[user].div) return;

        var user_div = users.seen[user].div = p.create('div');

        user_div.innerHTML = user === userid ? 'YOU' : user.slice( 0, 2 );

        p.attr( user_div, 'class', 'user' );
        p.attr( user_div, 'userid', user );

        userlist.appendChild(user_div);

        users.push(user);
    } );

    // ======================================================================
    // BIND KEYBOARD TO ROTATE AUDIO
    // ======================================================================
    p.events.bind( 'start-music', function(data) {
        console.log(JSON.stringify(data));
        var user = data.user;

        if (data.rotate && userid !== user) { setTimeout( function() {
            audio.pause();
            body.stop_interval && body.stop_interval();
        }, 300 ); }

        if (user !== userid) return (last_rotate = now());

        // TODO -> auto-adjust latency
        // TODO -> auto-adjust latency
        // TODO -> auto-adjust latency
        // TODO -> auto-adjust latency
        var diff = last_rotate - now() + rotate_rate
        ,   time = (data.time && (data.time) || 0) / 1000;

        console.log(diff, '<---- DIFF');

        audio.currentTime = time || Math.random()*100;

        start_timer = data.clock;
        last_rotate = now();

        audio.play();

        body.stop_interval = function() {
            clearInterval(body.interval);
            p.css( body, {
                background : '#fff',
                color      : '#444'
            } );
        };

        body.stop_interval();
        body.interval = setInterval( function() {
            p.css( body, {
                background : rnd_color(1),
                color      : '#fff'
            } );
        }, 200 );
    } );

    p.events.bind( 'stop-music', function(user) {
        if (user !== userid) return;
        audio.pause();
        body.stop_interval();
    } );

    function get_random_user() {
        var usrs  = userlist.getElementsByTagName('div')
        ,   usr   = usrs[Math.floor(Math.random()*usrs.length)]
        ,   usrid = p.attr( usr, 'userid' );

        if (get_random_user.last === usrid) return get_random_user();

        return (get_random_user.last = usrid);
    }
    get_random_user.last = '';

    // ======================================================================
    // BIND KEYBOARD TO ROTATE AUDIO
    // ======================================================================
    p.bind( 'keyup', document, function(e) {
        var key    = e.keyCode || e.charCode
        ,   target = e.target  || e.srcElement;

        if (key !== 32) return true;
        if (rotateival) return clearInterval(rotateival);

        console.log('ROTATING');

        start_timer = start = now() + 100;

        function rotateit() {
            p.attr( target, 'userid', get_random_user() );
            start_music( target, (now() - start + latency), 1 );
        }

        rotateival = setInterval( rotateit, rotate_rate );
        rotateit();
    } );

    function get_user(e) {
        var target = e.target || e.srcElement;
        target = p.attr( target, 'class' ) === 'user' ? target :
                 target.parentNode;

        if ('user' !== p.attr( target, 'class' )) return;

        return target;
    }

    p.bind( 'touchstart,mousedown', userlist, function(e) {
        var target = get_user(e);
        if (!target) return;

        console.log( 'play-sound' );
        start_music(target);
    } );

    p.bind( 'touchend,mouseup', userlist, function(e) {
        var target = get_user(e);
        if (!target) return;

        console.log( 'stop-sound' );
        stop_music(target);
    } );

    // ======================================================================
    // SIGNLE ROTATE AUDIO
    // ======================================================================
    function signle_rotate_audio(user_to_play) {
        p.publish({
            channel : master,
            message : {
                name : 'rotate-audio',
                data : {
                    userid   : user_to_play,
                    position : position
                }
            }
        });
    }

    function rnd_hex(light) {
        return light ? String.fromCharCode(64+Math.ceil(Math.random()*6)) :
                       Math.ceil(Math.random()*9);
    }
    function rnd_color() {
        return '#'+p.map( Array(3).join().split(','), rnd_hex ).join('');
    }

    function stop_music(target) {
        p.publish({
            channel : master,
            message : {
                name : 'stop-music',
                data : p.attr( target, 'userid' )
            }
        });
    }

    function start_music( target, time, rotate ) {
        p.publish({
            channel : master,
            message : {
                name : 'start-music',
                data : {
                    user   : p.attr( target, 'userid' ),
                    time   : time   || 0,
                    clock  : start_timer + latency,
                    rotate : rotate || 0
                }
            }
        });
    }

    // ======================================================================
    // EVENT: ROTATE AUDIO 
    // ======================================================================
    p.events.bind( 'rotate-audio', function(data) {
        if (userid === data.userid) return audio.stop();
    } );

    // ======================================================================
    // CLOCK/TIMER
    // ======================================================================
    setInterval( function() {
        var current = now()
        ,   diff    = current - start_timer
        ,   mill    = (''+diff).split('').slice(-3).join('')
        ,   sec     = Math.floor(diff / 1000) % 60
        ,   min     = Math.floor(diff / 60000); 

        sec < 10 && (sec = "0" + sec);
        min < 10 && (min = "0" + min);

        timer.innerHTML = [min, sec, mill].join(":");
    }, 60 );

})();
