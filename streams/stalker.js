(function(){
    /*
        TODO s
        - detect drop when stalking person
        - show "being stalked" indicator.
        - show "stalking" indicator.
        - make pretty
        - chat
        - name field
        - k
        - 
        - 
    */
    // =======================================================================
    // COMMON VARS
    // =======================================================================
    var p = PUBNUB;

    // =====================================================================
    // EVENTS
    // =====================================================================
    (function(){
        var event = p.event = {
            list : {},
            bind : function( name, fun ) {
                //console.log( 'bind', name );
                (event.list[name] = event.list[name] || []).push(fun);
            },
            fire : function( name, data ) {
                //console.log( 'fire', name );
                p.each(
                    event.list[name] || [],
                    function(fun) { fun(data) }
                );
            },
            deligate : function( element, namespace ) {
                p.bind( 'mousedown,touchstart', element, function(e) {
                    var target  = e.target || e.srcElement || {}
                    ,   parent  = target.parentNode
                    ,   parent2 = parent.parentNode
                    ,   action  = p.attr( target,  'action' ) ||
                                  p.attr( parent,  'action' ) ||
                                  p.attr( parent2, 'action' );

                    if (!action) return true;

                    p.event.fire( namespace + '.' + action, {
                        action : action,
                        e      : e,
                        target : target
                    } );
                } );
            }
        };
    })();

    // =====================================================================
    // LOCAL STORAGE
    // =====================================================================
    (function(){
        var db = window['localStorage'];
        p.db = {
            get : function(key) {
                if (db) return db.getItem(key);
                if (document.cookie.indexOf(key) == -1) return null;
                return ((document.cookie||'').match(
                    RegExp(key+'=([^;]+)')
                )||[])[1] || null;
            },
            set : function( key, value ) {
                if (db) return db.setItem( key, value );
                document.cookie = key + '=' + value +
                    '; expires=Thu, 1 Aug 2030 20:00:00 UTC; path=/';
            }
        };
    })();

    // =====================================================================
    // MOUSE POSITION
    // =====================================================================
    (function(){
        var mouse = p.mouse = function(e) {
            if (!e) return [[0, 0]];

            var tch  = e.touches && e.touches[0]
            ,   mpos = []
            ,   body = p.search('body')[0]
            ,   doc  = document.documentElement;

            if (tch) {
                p.each( e.touches, function (touch) {
                    mpos.push([ touch.pageX, touch.pageY ]);
                } );
            }
            else if (e.pageX) {
                mpos.push([ e.pageX, e.pageY ]);
            }
            else {
                try {
                    mpos.push([
                        e.clientX + body.scrollLeft + doc.scrollLeft,
                        e.clientY + body.scrollTop  + doc.scrollTop
                    ]);
                }
                catch (e) {
                    mpos.push([0, 0]);
                }
            }

            return mpos;
        }
    })();

    // =====================================================================
    // SCROLL POSITION
    // =====================================================================
    (function(){
        p.scroll = function() {
            return [
                document.body.scrollLeft ||
                document.documentElement.scrollLeft,
                document.body.scrollTop ||
                document.documentElement.scrollTop
            ];
        };
    })();

    // =====================================================================
    // UPDATER && Smooth Scrolling
    // =====================================================================
    (function(){
        function now(){return+new Date}

        p.updater = function( fun, rate ) {
            var timeout
            ,   last   = 0
            ,   runnit = function() {
                if (last + rate > now()) {
                    clearTimeout(timeout);
                    timeout = setTimeout( runnit, rate );
                }
                else {
                    last = now();
                    fun();
                }
            };

            return runnit;
        };

        p.scrollTo = function( end_y, duration, callback ) {
            var start_time   = now()
            ,   current_time = start_time
            ,   callback     = callback || function(){}
            ,   end_time     = start_time + duration
            ,   start_y      = p.scroll()[1]
            ,   distance     = end_y - start_y;

            p.scrollTo.interval && clearInterval(p.scrollTo.interval);
            p.scrollTo.interval = setInterval( function() {

                current_time = now();
                current_y    = (
                    end_time <= current_time
                    ? end_y
                    : ( distance * (current_time - start_time)
                        / duration + start_y )
                );

                window.scroll( 0, current_y );

                if ( end_time <= current_time && p.scrollTo.interval ) {
                    clearInterval(p.scrollTo.interval);
                    callback();
                }
            }, 14 );
        };
    })();

    // =======================================================================
    // MAIN
    // =======================================================================
    var users        = {}
    ,   mouse_cursor = p.create('div')
    ,   stalk_btns   = {}
    ,   stalker_div  = p.$('pubnub-stalker')
    ,   web_channel  = 'stalker-' + location.href.split('/')[2]
    ,   stalked_by   = JSON.parse(p.db.get('stalked_by') || '{}')
    ,   following    = JSON.parse(p.db.get('following') || '{}')
    ,   transmit     = p.db.get('transmit') // Transmitting?
    ,   transdelay   = 200                  // Update Frequency
    ,   user         = {
            mouse  : [[0, 0]],
            last   : p.db.get('last') || 0,
            name   : '',
            scroll : [0, 0],
            page   : location.href,
            uuid   : p.db.get('uuid') || p.uuid(function(uuid){
                user.uuid = uuid;
                p.db.set( 'uuid', uuid );
                stalking_ready();
            })
        };

    if (user.uuid) stalking_ready();

    // =======================================================================
    // NETWORKING
    // =======================================================================
    function message_router(message) {
        p.event.fire( message.event, message );
    }
    function stalking_ready() {
        p.subscribe({
            channel  : web_channel,
            callback : message_router,
            connect  : function() {

                // Transmit Presence
                transmit_presence();

                // Append Mouse Cursor
                p.search('body')[0].appendChild(mouse_cursor);

                // Request Other Users Presence
                p.publish({
                    channel : web_channel,
                    message : {
                        event : 'user-present-request',
                        user  : user
                    }
                });
            }
        });
    }

    // =======================================================================
    // TRANSMIT PRESENCE
    // =======================================================================
    function transmit_presence(uuid) {
        p.db.set( 'last', ++user.last );
        p.publish({
            channel : web_channel + (uuid && '-' + uuid || ''),
            message : {
                event : 'user-present',
                user  : user
            }
        });
    }

    // =======================================================================
    // TRANSMIT SHUTOFF
    // =======================================================================
    var transmit_shutoff_timeout   = -1
    ,   transmit_shutoff_countdown = 3;

    (function(){
        setInterval( function() {
            if (transmit !== 'yes') return;

            console.log("ASKING IF BEING STALKED");

            p.publish({
                channel  : web_channel + '-' + user.uuid,
                callback : function(info) {
                    if (!info[0]) return;

                    transmit_shutoff_timeout = setTimeout( function() {
                        console.log(
                            "TRANSMISSION COUNTDONW: ",
                            transmit_shutoff_countdown
                        );

                        if (--transmit_shutoff_countdown > 0) return;

                        console.log("TERMINATING TRANSMISSION");
                        transmit = 'no';
                        p.db.set( 'transmit', 'no' );
                        transmit_shutoff_countdown = 3;
                    }, 5000 );
                },
                message  : {
                    event : 'are-you-still-there?',
                    user  : user
                }
            });
        }, 6000 );

        p.event.bind( 'are-you-still-there?', function(message) {

            if (message.user.uuid === user.uuid) return;

            console.log("YES, IM HERE");

            p.publish({
                channel  : web_channel,
                message  : {
                    event : 'yes-i-am-still-here',
                    user  : user
                }
            });
        } );

        p.event.bind( 'yes-i-am-still-here', function(message) {
            console.log("RECEIVED REPLY: YES, IM HERE");
            if (!(message.user.uuid in stalked_by)) return;
            console.log("CONTINUING TO TRANSMIT");
            clearTimeout(transmit_shutoff_timeout);
            transmit_shutoff_countdown = 3;
        } );
    })();

    // =======================================================================
    // VENDOR CSS3
    // =======================================================================
    function vendor_css( elm, list ) {
        try {
            p.attr( elm, 'style', list.join(';') );
        }
        catch (e) {}
    }

    // =======================================================================
    // EVENTS
    // =======================================================================
    p.event.bind( 'user-present-request', function() {
        transmit_presence();
    } );

    // User Joins or Transmits Coordinates
    p.event.bind( 'user-present', function(message) {

        // Ignore Self
        if (message.user.uuid === user.uuid) return;

        // UPDATE STALKER UI AREA AND SAVE NEW USER
        if (!(message.user.uuid in users)) {
            users[message.user.uuid] = message.user;
            add_stalkable_user(users[message.user.uuid]);
        }

        // PREVENT CROSS TALK AND OLD UPDATES
        if (following.uuid !== message.user.uuid) return;
        if (following.last > message.user.last) return;
        following.last = message.user.last;

        // UPDATE SCROLL TOP
        p.scrollTo( message.user.scroll[1], transdelay, function() {
            scrollTo.apply( window, message.user.scroll );
        } );

        // MOUSE CURSOR
        p.css( mouse_cursor, {
            top  : message.user.mouse[0][1],
            left : message.user.mouse[0][0]
        } );

        // PAGE LOCATION
        if (location.href !== message.user.page) {
            location.href = message.user.page;
        }
    } );


    // =======================================================================
    // BROADCASTING YOUR LOCATION DETAILS
    // =======================================================================
    var broadcast = p.updater( function(){
        user.scroll = p.scroll();
        user.page   = location.href;

        // Only Transmit Updates if Someone is Following
        if (transmit === 'yes') transmit_presence(user.uuid);
    }, transdelay );

    p.bind( 'mousemove,touchmove', document, function(e) {
        user.mouse = p.mouse(e);
        broadcast();
        return true;
    } );

    p.bind( 'scroll', document, function(e) {
        broadcast();
        return true;
    } );

    (function(){
        var last_hash = location.hash;
        ('onhashchange' in window) &&
        p.bind( 'hashchange', window, function(e) {
            broadcast();
            return true;
        } ) ||
        setInterval( function() {
            if (last_hash === location.hash) return;
            last_hash = location.hash;
            broadcast();
        }, transdelay/2 );
    })();

    // =======================================================================
    // STALK UI CONTROLS
    // =======================================================================
    p.event.deligate( stalker_div, 'stalker-ui-controls' );

    // =======================================================================
    // CONNECT TO USER AND BEGIN STALKING
    // =======================================================================
    p.event.bind( 'stalker-ui-controls.connect', function(message) {

        // DON'T FOLLOW SELF
        if (p.attr( message.target, 'user' ) === user.uuid) return;

        following = users[p.attr( message.target, 'user' )];
        p.db.set( 'following', JSON.stringify(following) );

        // UPDATE FOLLOW UI
        p.css( stop_button, { display : 'block' } );
        p.css( people_to_stalk_list, { display : 'none' } );

        p.publish({
            channel : web_channel,
            message : {
                event     : 'user-stalking-user',
                user      : user,
                following : following
            }
        });

        p.subscribe({
            channel  : web_channel + '-' + following.uuid,
            callback : message_router
        });
    } );

    // =======================================================================
    // BEGIN TRASMITTING AND UPDATE UI
    // =======================================================================
    p.event.bind( 'user-stalking-user', function(message) {
        if (message.following.uuid !== user.uuid) return;

        transmit = 'yes';
        p.db.set( 'transmit', 'yes' );

        clearTimeout(transmit_shutoff_timeout);
        transmit_shutoff_countdown = 3;

        stalked_by[message.user.uuid] = message.user;
        p.db.set( 'stalked_by', JSON.stringify(stalked_by) );
    } );

    // =======================================================================
    // MOUSE CURSOR
    // =======================================================================
    vendor_css( mouse_cursor, [
        '-webkit-transition:all ' + (transdelay/500) + 's',
        '-moz-transition:all ' + (transdelay/500) + 's',
        '-ms-transition:all ' + (transdelay/500) + 's',
        '-o-transition:all ' + (transdelay/500) + 's',
        'transition:all ' + (transdelay/500) + 's'
    ] );
    p.css( mouse_cursor, {
        position   : 'absolute',
        top        : -100,
        left       : -100,
        width      : 36,
        height     : 36,
        background : 'transparent url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACQAAAAkCAYAAADhAJiYAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAauSURBVHja7Fd7TFNXGP/ubYuFvnhYYVKgQsFZK5mymamZr7mh8TE1UCFuyxLZsk3ihiZmGh0g07mo/yxLNhH+EBcNwlSUSdAZXZziA2QTW6Y8BKYOpAi0FMS29+w7h7ayTbdwl2z7gy85veeee+49v/P7fY9TUKkUoFQqinmeIwBAWxp4jeM4bAArzWZwEOJrEl//8NViiMyA4Y3DYRBsYzlP1Us8wZuRNggJ0azPyMggV65cIdevXycpKSkUlGkIzxAgap/lRcBA1zLaOHq99oOBjedtNsDNM9G+JqVXBAQICMQAko6P1O1JTk4Gg8EAarUaCgoKIDQ0tC4/P58yVexj66OPO2DAMw1SU1O5kpIS8sn2b9n42Y6V8NaEZyBwaJqbMRvkAgi6AaIsKSmJVFRUkIGBAeLxeAi1/v5+smjRol5kyIIMWXCahfbpfJ1Ox6SUyiTs/flrNkLX4x1y/t0O3hfFEI8XePToESCgIQ3RAgMDITMzU52Wlma8efOW8datW8aysjKjXq8nvb29JD4+nkSER9DJ0cP2xjOZ38ffHuAgQCuKIAlwgkk7VmsMCQ2FsLAwkEgkwPM8xMTEQE9PDxQXF8OsWbMgMTERECAEBATApzt2wGvLl8O9e/eSPapxF1OXvWJDyaQUFNe+V5grPM8jVEqhMGJEuLg6JCS4AhchdXV1BEEQt9vNpHO5XExOs9lMrFYrcTqdpLW1lVAfotbU1EReXrj47uatmzWk4YCMSVb7HJD7TDqJqCijNFNWpDKpJTcnh9TU1JDu7m6/P1ErKioieXl5xOHoY2A9bg8RBIE9a2xsJKgPsZRtAovFAhTQr9c7RfkPA4RRQ7WX8hIeIiLCSzZt2kRqa2uJ3W73M4U+xph70NXrvXczwBQUDYa3MzYQ9PNUmiI+f3c2rDPvFA8InZRfuHAhzTYyKh9axfqsLIK7ZaB8TFCjzD3JqIy+FBEPSyggKpmoxMgXFhYKlZWVkRjK8ZitdX19jlX5BXutB4qK4M6dOzA4OOj3t+Dg4Cf6IY1KrVarwa7GAFoYbB+U2Ovs4qLs9OnTk/UxMWVLli7NmTZt6lqbrTO+z+mc29TcaJKPkRtNpikgl8tZ5BEB/Jl7uCkUClCrxhqCTnpqj8FG6xeqAxJVtNIzeepkEBFlnPn11atJVVUViyTM0CQgQGZRKOS/rFyxnDQ3NzM/YdIJ5KlWevgM0fNGs4mPBaVMLtON14lLjHTL1AHQgUEqlQJmaGhoaDSuy/xAFx0Vzcb8xj19Y/oJkZC04tliV7yMyJTy8l5Xh0aUZLQE9HR3z4mJjhmni4pifkIleGH6dJg9Zw4W3xB/suS4JyPCUoP1TwmxsbGQlZWFmX8wTvli60/p87JGXNB4zCmW1rY2C8oFHR0dNOoYW9RRlUrlkO8MS1pPM/pOFG4IpYVgTTCcG98uiGFI6l1o1b6CAnNkZCRbGGsVqFQq/5nItyA1+tw3JpVIodfuwHvCaqEPvNvtgj6bS1SUSYc5Ru6FCxey1RoN+yitZVS+oKCg38nlu9I5/c5+ePjwIfYFVqDpMywvUF9fD3wpztsiCpDfcs6eO2fHxffQxTATs2JLWaMLjRkz5k9+RH2HzqNSU0ZpzmppaYHy8vJTmMhPiXJq5cSxEBAWBHHhE6Cjvb2qqblZTdyuGTZbF/MHKhXdPWMEAVAG+vr6WOvs7MSIbGC+RufQ00HhvnyYNGn6iRPl144/JY/+NUMzzq9hnaPanbA+NxecABsObdvmuFpzbXJ1dXXKTDx66JAlFv5edvAUAFhW2FEkISEBHA4HA/9zvRXKjpfBtuyDG71JgvwTyeCd7Gxox8ibnpqa86HJpK6uqcluaGyw8DwNe86fiGJj9TB//gIwxMWBBn2OgmlpuQ1F+/ejhEGJP9add6U//q8gHpDTe+qbYjTC2l2L7VC3xfrl1zM5TNJecoYA9fR07dHH6Ndj/QIPgul+8ACOHPnGHhameHNSQlidsvcuCG1WzJZG0YA4G4LZjp03sC3G+1N8Jx8u/V5Im2YgB6sb/vjehqNHSx1tba3ZVMrLly/nYlWxHDy447h57gP+xrxdQv97ZXgSJyMHdDG9kHU6v9spYFiQVd4HyaZXOeF8CZeoUxNN/3j4qv4eG18QlQzbZ+xmUXnmTmXJ1ksbcFXOOuybRKz/MEDO2zZ40suKwFC305sMtXKZf7y05aS/PxGM1pr0S+RYaenQwO59AIdCwJSQBGKN+7uS8G8bD/8zGwU0CmgU0Cig/9p+E2AAcJrXgtOgE7gAAAAASUVORK5CYII=")'
    } );

    // =======================================================================
    // STALKER MAIN UI - ADD PUBNUB LINK
    // =======================================================================
    (function(){
        var pnlnk = p.create('div');
        pnlnk.innerHTML =
            '<a href=http://www.pubnub.com/ ' + 
            'style=color:#fdfdfd;font-weight:700;line-height:22px>' + 
            'Powered by PubNub</a>';

        stalker_div.appendChild(pnlnk);
    })();

    // =======================================================================
    // STOP STALKING SOMEONE
    // =======================================================================
    function stop_stalking() {
        p.unsubscribe({
            channel : web_channel + '-' + following.uuid,
        });
        following = {};
        p.db.set( 'following', '{}' );

        // UPDATE FOLLOW UI
        p.css( stop_button, { display : 'none' } );
        p.css( people_to_stalk_list, { display : 'block' } );
    }

    // =======================================================================
    // STALKER MAIN UI - ADD STOP FOLLOW BUTTON
    // =======================================================================
    var stop_button = p.create('div');
    (function(){
        stop_button.innerHTML = '<a href=# action=disconnect ' +
                                'style=color:#fdfdfd>' + 
                                'Stop Following</a>';

        p.css( stop_button, { display : 'none' } );
        stalker_div.appendChild(stop_button);
    })();
    p.event.bind( 'stalker-ui-controls.disconnect', stop_stalking );

    // =======================================================================
    // STALKER MAIN UI - ADD STALK PERSON BUTTON
    // =======================================================================
    var people_to_stalk_list = p.create('div')
    ,   stlk_btn_tpl         = '<a href=# action=connect user={uuid} ' +
                               'style=color:#fdfdfd>' + 
                               'Follow {name}</a>';

    stalker_div.appendChild(people_to_stalk_list);

    function add_stalkable_user(stalkable_user) {
        var suuid = stalkable_user.uuid
        ,   btn   = stalk_btns[suuid] = p.create('div');

        btn.innerHTML = p.supplant( stlk_btn_tpl, {
            uuid : suuid,
            name : users[suuid].name || suuid.slice( 0, 5 )
        } );
        people_to_stalk_list.appendChild(btn);
    }

    // =======================================================================
    // APPEND BETA INFO
    // =======================================================================
    (function(){
        var beta_message = p.create('div');
        beta_message.innerHTML =
            '<div style="font-size:12px;margin:10px;">' +
            'This is a BETA product under development by the PubNub team. ' +
            'Click the "Follow" Link above. ' +
            'If you do not see a Follow Link, get a friend to visit ' +
            'the same page where you pasted the Embed Code.' +
            '' +
            '</div>';
        stalker_div.appendChild(beta_message);
    })();


    // =======================================================================
    // RESUME STALKING ON PAGE CHANGE
    // =======================================================================
    if (following.uuid) {

        // UPDATE FOLLOW UI
        p.css( stop_button, { display : 'block' } );
        p.css( people_to_stalk_list, { display : 'none' } );

        p.subscribe({
            channel  : web_channel + '-' + following.uuid,
            callback : message_router
        });
    }

    // =======================================================================
    // MAKE PRETTY
    // =======================================================================
    vendor_css( stalker_div, [
        '-webkit-border-radius:5px',
        '-moz-border-radius:5px',
        '-ms-border-radius:5px',
        '-o-border-radius:5px',
        'border-radius:5px'
    ] );

    p.css( stalker_div, {
        position   : 'fixed',
        top        : 0,
        right      : 0,
        width      : 300,
        background : '#ed0d07',
        fontFamily : 'Arial,Helvetica',
        fontSize   : '15px',
        lineHieght : '20px',
        color      : '#fdfdfd',
        padding    : '10px',
        margin     : '10px'
    } );

})();
