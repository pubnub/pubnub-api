(function(){
    'PUBNUB' in window || console.error("Missing PubNub JS Include!");

    var p          = PUBNUB
    ,   standard   = 'standard'
    ,   uuid       = p['uuid'](function(id){ uuid = id })
    ,   now        = function(){return+new Date}
    ,   namespaces = {}
    ,   users      = {}
    ,   io         = window['io'] = {
        'connected' : false,
        'connect'   : function( host, setup ) {

            // PARSE SETUP and HOST
            var urlbits   = (host+'////').split('/')
            ,   setup     = setup || {}
            ,   origin    = urlbits[2]
            ,   namespace = urlbits[3] || standard
            ,   socket    = create_socket(namespace);

            // PASSWORD ENCRYPTION
            socket['password'] = 'sjcl' in window && setup['password'];

            // PUBNUB ALREADY SETUP?
            if (io['connected']) return socket;
            io['connected'] = true;

            // GEO LOCATION
            if (setup['geo']) setInterval( locate, 15000 ) && locate();

            // SETUP PUBNUB
            setup['origin'] = origin;
            p               = p['init'](setup);

            p.disconnected  = 0;
            p.channel       = setup['channel'] || standard;

            // ESTABLISH CONNECTION
            p['subscribe']({
                'channel'  : p.channel,
                'error'    : function() {
                    if (p.disconnected) return;
                    p.disconnected = 1;
                    p['each']( namespaces, function(ns) {
                        p['events']['fire']( ns + 'disconnect', {} ) 
                    } );
                },
                'connect'  : function() {
                    p.disconnected = 0;
                    p['each']( namespaces, function(ns) {
                        p['events']['fire']( ns + 'connect', {} ) 
                    } );
                },
                'callback' : function(evt) {
                    if (p.disconnected) p['each']( evt['ns'], function(ns) {
                        p['events']['fire']( ns + 'reconnect', {} ) 
                    } );
 
                    p.disconnected = 0;

                    // USER EVENTS
                    if (evt['uuid'] && evt['uuid'] !== uuid)
                        users[evt['ns']] = users[evt['ns']] || {};
                        users[evt['ns']][evt['uuid']] =
                        users[evt['ns']][evt['uuid']] || (function() {

                            setTimeout( function() { socket['emit']( 'join', {
                                'geo'       : evt['geo'] || [0,0],
                                'uuid'      : evt['uuid'],
                                'last'      : now(),
                                'namespace' : evt['ns'],
                                'connected' : true,
                                'slot'      : socket['user_count']++
                            } ) }, 10 );

                            return {
                                'geo'       : evt['geo'] || [0,0],
                                'uuid'      : evt['uuid'],
                                'last'      : now(),
                                'socket'    : socket,
                                'namespace' : evt['ns'],
                                'connected' : true,
                                'slot'      : socket['user_count']++
                            };
                        })();

                    if (evt['name'] === 'user-disconnect')
                        disconnect(users[evt['ns']][evt['uuid']]);

                    if (evt['name'] === 'ping')
                        users[evt['ns']][evt['uuid']].last = now();

                    if (evt['ns'] in namespaces) {
                        var data = decrypt( evt['ns'], evt['data'] );
                        data && p['events']['fire'](
                            evt['ns'] + evt['name'], data
                        );
                    }
                }
            });

            // TCP KEEP ALIVE
            p.tcpKeepAlive = setInterval( function() { send('ping') }, 2500 );

            // RETURN SOCKET
            return socket;
        }
    };

    // =====================================================================
    // Advanced User Presence
    // =====================================================================
    setInterval( function() {
        if (p.disconnected) return;

        p['each']( users, function(namespace) {
            p['each']( users[namespace], function(uid) {
                var user = users[namespace][uid];
                if (now() - user.last < 5000 || uid === uuid) return;
                disconnect(user);
            } );
        } );
    }, 1000 );

    function disconnect(user) {
        if (!user.connected) return;

        user.connected = false;
        user.socket['user_count']--;
        p['events']['fire']( user.namespace + 'leave', user ) 
    }

    typeof window !== 'undefined' &&
    p['bind']( 'beforeunload', window, function() {
        send( 'user-disconnect', '', uuid );
        return true;
    } );

    // =====================================================================
    // Stanford Crypto Library with AES Encryption
    // =====================================================================
    function encrypt( namespace, data ) {
        var namespace = namespace || standard
        ,   socket    = namespaces[namespace];

        return 'password' in socket && socket['password'] && sjcl['encrypt'](
           socket['password'], JSON['stringify'](data)+''
        ) || data;
    }

    function decrypt( namespace, data ) {
        var namespace = namespace || standard
        ,   socket    = namespaces[namespace];

        if (!socket['password']) return data;
        try { return JSON['parse'](
            sjcl['decrypt']( socket['password'], data )
        ); }
        catch(e) { return null; }
    }

    // =====================================================================
    // PUBLISH A MESSAGE + Retry if Failed with fallback
    // =====================================================================
    function send( event, namespace, data, wait, cb ) {
        p['publish']({
            'channel' : p.channel,
            'message' : {
                'name' : event,
                'ns'   : namespace || standard,
                'data' : encrypt( namespace, data || {} ),
                'uuid' : uuid,
                'geo'  : p.location || [ 0, 0 ]
            },
            'callback' : function(info) {
                if (info[0]) return (cb||function(){})(info);
                var retry = (wait || 500) * 2;
                setTimeout( event, data, retry > 10000 && 10000 || retry );
            }
        });
    }

    // =====================================================================
    // GEO LOCATION DATA (LATITUDE AND LONGITUDE)
    // =====================================================================
    function locate(callback) {
        var callback = callback || function(){};
        navigator && navigator.geolocation &&
        navigator.geolocation.getCurrentPosition(function(position) {  
            p.location = [
                position.coords.latitude,
                position.coords.longitude
            ];
            callback(p.location);
        }) || callback([ 0, 0 ]); 
    }

    // =====================================================================
    // CREATE SOCKET
    // =====================================================================
    function create_socket(namespace) {
        if ( namespace !== standard &&
             !(standard in namespaces)
        ) create_socket(standard);

        return namespaces[namespace] = {
            'users'          : users[namespace] = {},
            'user_count'     : 1,
            'get_user_list'  : function(){
                return namespaces[namespace]['users']
            },
            'get_user_count' : function(){
                return namespaces[namespace]['user_count']
            },
            'emit' : function( event, data, receipt ) {
                send( event, namespace, data, 0, receipt );
            },
            'send' : function( data, receipt ) {
                send( 'message', namespace, data, 0, receipt );
            },
            'on' : function( event, fn ) {
                p['events']['bind']( namespace + event, fn );
            },
            'disconnect' : function() {
                delete namespaces[namespace];
            }
        };
    }
})();
