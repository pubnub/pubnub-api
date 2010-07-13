(function(){

/* ======================================================================== */
/* ================================ UTILITY =============================== */
/* ======================================================================== */

var db     = this['localStorage']
,   cookie = {
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
},  updater = function( fun, rate ) {
    
    var timeout
    ,   now     = function(){return+new Date}
    ,   last    = now()
    ,   runnit  = function() {
        var right_now = now();

        // Don't continue if too soon (but check back)
        if (last + rate > right_now) {
            // Come back and check after waiting.
            clearTimeout(timeout);
            timeout = setTimeout( runnit, rate );

            return 1;
        }

        fun();
    };

    // Provide Rate Limited Function Call
    return runnit;
};

/* ======================================================================== */
/* ============================== GAME LOBBY ============================== */
/* ======================================================================== */


/* --------
    Step 1: Provide a Player Creation/Management Interface.
   -------- */

var lobby  = 'lobby'
,   player = (function(){
    var players = {};
    return {
        add : function(user) {
            players[user['uuid']] = user;
            return user;
        },
        get : function(uuid) {
            return players[uuid];
        },
        all : function() {
            return players;
        }
    };
})();


/* --------
    Step 2: Capture Current User's Information.
   -------- */

var current_user = player.add({
    // User's UUID (Uniquely Identify Each Player).
    uuid : cookie.get('uuid') || PUBNUB.uuid(function(uuid){
        current_user.uuid = uuid;
        cookie.set( 'uuid', uuid );
    }),

    // Get or Set User's Name
    name : cookie.get('name') || (function(){
        var name = prompt('Player Name:') || 'Fluff';
        cookie.set( 'name', name );
    })(),

    // Set user's location to Home
    room : 'home'
});


/* --------
    Step 3: Subscribe to Lobby Channel.
   -------- */

PUBNUB.subscribe({ 'channel' : lobby }, function(message) {
    // Lobby Room Actions
    switch (message['action']) {

        // All Users, Send Your Info!
        case 'ping' :
            PUBNUB.publish({
                'channel' : lobby,
                'message' : {
                    'action' : 'update',
                    'user'   : current_user 
                }
            });
            break;

        // Receive User Info from 'ping'
        case 'update' :
            user_update_lobby(message['user']);
            break;
    }
});


/* --------
    Step 4: Curren User Joins Lobby!
   -------- */

PUBNUB.publish({
    'channel' : lobby,
    'message' : { 'action' : 'ping' }
});


/* --------
    Step 5: Update Function (user joined lobby)
   -------- */

function user_update_lobby(user) {
    // User Joins or Updates
    player.add(user);
    update_interface();
}


/* --------
    Step 6: Provide UI Update (with re-draw rate limit)
   -------- */

var update_interface = updater( function() {
    // Update UI.

    // Debug
    console.log(JSON.stringify(player.all()));
}, 200 );


})()
