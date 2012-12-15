(function(){

    // =====================================================================
    // PubNub Socket.IO
    // =====================================================================
    var p          = PUBNUB
    ,   has_setup  = 0
    ,   uuid       = PUBNUB.db.get('uuid') || p.uuid(function(id){
            PUBNUB.db.set( 'uuid', uuid = id )
        })
    ,   now        = function(){return+new Date}
    ,   namespaces = {}
    ,   users      = {}
    ,   io         = window.io = {
        connected : {},
        connect   : function( host, setup ) {

            // PARSE SETUP and HOST
            var urlbits   = (host+'////').split('/')
            ,   setup     = setup         || {}
            ,   cuser     = setup['user'] || {}
            ,   presence  = 'presence' in setup ? setup['presence'] : true
            ,   origin    = urlbits[2]
            ,   namespace = (urlbits[3] || 'standard') + '-' + setup.channel
            ,   channel   = setup.channel
            ,   socket    = get_socket(namespace);

            // STORE CHANNEL
            socket.channel = channel;

            // PASSWORD ENCRYPTION
            socket.password = 'sjcl' in window && setup.password;

            // PUBNUB ALREADY CONNECTED?
            if (channel in io.connected) return socket;

            // GEO LOCATION
            if (setup.geo) setInterval( locate, 15000 ) && locate();

            // SETUP PUBNUB
            setup.uuid   = uuid;
            setup.origin = origin;

            p                     =
            io.connected[channel] =
            has_setup ? p : PUBNUB.init(setup);
            has_setup = 1;

            // DISCONNECTED
            function dropped() {
                if (socket.disconnected) return;
                socket.disconnected = 1;
                p.each( namespaces, function(ns) {
                    p.events.fire( ns + 'disconnect', {} ) 
                } );
            }
            socket.disconnected = 0;

            // ESTABLISH CONNECTION
            p.subscribe({
                channel    : socket.channel,
                disconnect : dropped,
                reconnect  : function() {p.disconnected = 0;},
                connect    : function(a,b,c) {
                    socket.disconnected = 0;
                    p.each( namespaces, function(ns) {
                        var socket = get_socket(ns);
                        if (socket.connected) return;
                        socket.connected = true;
                        p.events.fire( ns + 'connect', {} );
                    } );
                    send_details();
                },
                presence : presence && function(evt) {
                    if (evt.action === 'leave')   disconnect(evt.uuid);
                    if (evt.action === 'timeout') disconnect(evt.uuid);
                    if (evt.action === 'join')    send_details();
                },
                callback : function(evt) {
                    if (socket.disconnected) p.each( namespaces, function(ns) {
                        p.events.fire( ns + 'reconnect', {} ) 
                    } );
 
                    socket.disconnected = 0;

                    var data = decrypt( evt.ns, evt.data );

                    if (evt.ns in namespaces)
                        data && p.events.fire( evt.ns + evt.name, data );

                    // USER EVENTS
                    if (!evt.uuid || evt.uuid === uuid) return;

                    evt.name === 'ping' && p.each( data.nss, function(ns) {
                        users[ns] = users[ns] || {};

                        var user = users[ns][evt.uuid] =
                        users[ns][evt.uuid] || (function() { return {
                            geo       : evt.geo || [ 0, 0 ],
                            uuid      : evt.uuid,
                            last      : now(),
                            socket    : socket,
                            namespace : ns,
                            connected : false,
                            slot      : socket.user_count++
                        } })();

                        user.last = now();
                        user.data = data.cuser;

                        if (user.connected) return;
                        p.events.fire( ns + 'join', user );

                        user.connected = true;
                    } );
                }
            });

            function send_details() {
                var nss = p.map( namespaces, function(ns) { return ns } );
                send( 'ping', namespace, { nss : nss, cuser : cuser } );
            }

            // PRESENCE
            if (presence) {
                setInterval( send_details, 30000 );
                send_details();
            }

            // RETURN SOCKET
            return socket;
        }
    };

    function disconnect(uid) {
        p.each( namespaces, function(ns) {
            if (!(ns in users && uid in users[ns])) return;
            var user = users[ns][uid];
            if (!user.connected) return;

            user.connected = false;
            user.socket.user_count--;
            p.events.fire( ns + 'leave', user ) 
        } );
    }

    // =====================================================================
    // Stanford Crypto Library with AES Encryption
    // =====================================================================
    function encrypt( namespace, data ) {
        var namespace = namespace
        ,   socket    = get_socket(namespace);

        return 'password' in socket && socket.password && sjcl.encrypt(
           socket.password, JSON.stringify(data)+''
        ) || data;
    }

    function decrypt( namespace, data ) {
        var namespace = namespace
        ,   socket    = get_socket(namespace);

        if (!socket.password) return data;
        try { return JSON.parse(
            sjcl.decrypt( socket.password, data )
        ); }
        catch(e) { return null; }
    }

    // =====================================================================
    // PUBLISH A MESSAGE + Retry if Failed with fallback
    // =====================================================================
    function send( event, namespace, data, wait, cb ) {
        var socket = get_socket(namespace);
        p.publish({
            channel : socket.channel,
            message : {
                name : event,
                ns   : namespace,
                data : encrypt( namespace, data || {} ),
                uuid : uuid,
                geo  : socket.location || [ 0, 0 ]
            },
            callback : function(info) {
                if (info[0]) return (cb||function(){})(info);
                var retry = (wait || 500) * 2;
                setTimeout( function() {
                    send( event, namespace, data, retry, cb );
                }, retry > 5500 ? 5500 : retry );
            }
        });
    }

    // =====================================================================
    // FILTER
    // =====================================================================
    function filter( list, fun ) {
        var fin = [];
        PUBNUB.each( list || [], function(l) { fun(l) && fin.push(l) } );
        return fin
    }

    // =====================================================================
    // Get Detailed History for published messages
    // =====================================================================
    function history( namespace, args, callback ) {
        var socket = get_socket(namespace);
        args.channel = socket.channel;
        p.history( args, function(response) {
            response[0] = filter( response[0], function(msg) {
                return msg.name == "message" && msg.ns == namespace;
            } );
            callback(response);
        } );
    }

    // =====================================================================
    // Get Here Now data for present users 
    // =====================================================================
    function here_now( namespace, callback ) {
        var socket = get_socket(namespace);
        p.here_now( { channel : socket.channel }, callback );
    }

    // =====================================================================
    // GEO LOCATION DATA (LATITUDE AND LONGITUDE)
    // =====================================================================
    function locate(callback) {
        var callback = callback || function(){};
        navigator && navigator.geolocation &&
        navigator.geolocation.getCurrentPosition(function(position) {  
            socket.location = [
                position.coords.latitude,
                position.coords.longitude
            ];
            callback(socket.location);
        }) || callback([ 0, 0 ]); 
    }

    // =====================================================================
    // CREATE SOCKET
    // =====================================================================
    function get_socket(namespace) {
        var namespace = namespace
        ,   socket    = namespaces[namespace] || (function(){
                return namespaces[namespace] = {
                    namespace      : namespace,
                    connected      : false,
                    users          : users[namespace] = {},
                    user_count     : 1,
                    get_user_list  : function(){
                        return namespaces[namespace].users;
                    },
                    get_user_count : function(){
                        return namespaces[namespace].user_count;
                    },
                    emit : function( event, data, receipt ) {
                        send( event, namespace, data, 0, receipt );
                    },
                    send : function( data, receipt ) {
                        send( 'message', namespace, data, 0, receipt );
                    },
                    on : function( event, fn ) {
                        if (typeof event === 'string')
                            p.events.bind( namespace + event, fn );
                        else if (typeof event === 'object')
                            p.each( event, function(evt) {
                                p.events.bind( namespace + evt, fn );
                            } );
                    },
                    disconnect : function() {
                        p.unsubscribe({ channel : socket.channel });
                    },
                    history : function( args, callback ) {
                        history( namespace, args, callback );
                    },
                    here_now : function( callback ) {
                        here_now( namespace, callback );
                    }
                };
            })();

        return socket;
    }
})();
