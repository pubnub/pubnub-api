(function(){
    'PUBNUB' in window || console.error("Missing PubNub JS Include!");

    var p          = PUBNUB
    ,   uuid       = p.uuid(function(id){ uuid = id })
    ,   now        = function(){return+new Date}
    ,   namespaces = {}
    ,   users      = {}
    ,   io         = window['io'] = {
        'connected' : false,
        'connect'   : function( host, setup ) {

            // PARSE SETUP and HOST
            var urlbits   = (host+'////').split('/')
            ,   origin    = urlbits[2]
            ,   namespace = urlbits[3] || 'default'
            ,   socket    = create_socket(namespace);

            // PUBNUB ALREADY SETUP?
            if (io['connected']) return socket;
            io['connected'] = true;

            // SETUP PUBNUB
            setup.origin   = origin;
            p              = p.init(setup);
            p.disconnected = 0;
            p.channel      = setup.channel;

            // SETUP USERS
            socket.users      = users[namespace] = {};
            socket.user_count = 0;

            // ESTABLISH CONNECTION
            p.subscribe({
                channel  : p.channel,
                error    : function() {
                    if (p.disconnected) return;
                    p.disconnected = 1;
                    p.each( namespaces, function(ns) {
                        p.events.fire( ns + 'disconnect', {} ) 
                    } );
                },
                connect  : function() {
                    p.disconnected = 0;
                    p.each( namespaces, function(ns) {
                        p.events.fire( ns + 'connect', {} ) 
                    } );
                },
                callback : function(evt) {
                    if (p.disconnected) p.each( namespaces, function(ns) {
                        p.events.fire( ns + 'reconnect', {} ) 
                    } );
 
                    p.disconnected = 0;

                    // USER EVENTS
                    if (evt.uuid && evt.uuid !== uuid)
                        users[namespace][evt.uuid] =
                        users[namespace][evt.uuid] || (function() {
                            socket.emit( 'join', evt.uuid );
                            return {
                                uuid      : evt.uuid,
                                last      : now(),
                                socket    : socket,
                                namespace : namespace,
                                connected : true,
                                slot      : socket.user_count++
                            };
                        })();

                    if (evt.name === 'user-disconnect')
                        disconnect(users[namespace][evt.uuid]);

                    if (namespace in namespaces)
                        p.events.fire( evt.name, evt.data )
                }
            });

            // TCP KEEP ALIVE
            p.tcpKeepAlive = setInterval( function() { send('ping') }, 1500 );

            // RETURN SOCKET
            return socket;
        }
    };

    // =====================================================================
    // Advanced User Presence
    // =====================================================================
    setInterval( function() {
        if (p.disconnected) return;

        p.each( users, function(namespace) {
            p.each( users[namespace], function(user) {
                if (now() - user.last < 3000) return;

                disconnect(user);
            } );
        } );
    }, 1000 );

    function disconnect(user) {
        if (!user.connected) return;

        user.connected = false;
        user.socket.user_count--;
        p.events.fire( user.namespace + 'leave', user ) 
    }

    typeof window !== 'undefined' &&
    p.bind( 'beforeunload', window, function() {
        send( 'user-disconnect', uuid );
    } );

    // =====================================================================
    // PUBLISH A MESSAGE + Retry if Failed with fallback
    // =====================================================================
    function send( event, data, wait ) {
        p.publish({
            channel  : p.channel,
            message  : {
                name : event,
                data : data || {},
                uuid : uuid
            },
            callback : function(info) {
                if (info[0]) return;
                var retry = (wait || 500) * 2;
                setTimeout( event, data, retry > 10000 && 10000 || retry );
            }
        });
    }

    // =====================================================================
    // CREATE SOCKET
    // =====================================================================
    function create_socket(namespace) {
        namespaces[namespace] = namespace;
        return {
            'emit' : function( event, data ) {
                send( namespace + event, data );
            },
            'send' : function(data) {
                console.log(  namespace + 'message', data );
                send( namespace + 'message', data );
            },
            'on' : function( event, fn ) {
                p.events.bind( namespace + event, fn );
            },
            'disconnect' : function() {
                // TODO
                // TODO
                // TODO
                delete namespaces[namespace];
            }
        };
    }
})();
