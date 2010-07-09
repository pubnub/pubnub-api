(function(){

/* ======================================================================== */
/* ================================ UTILITY =============================== */
/* ======================================================================== */

var cookie = {
    get : function(key) {
        if (document.cookie.indexOf(key) == -1) return null;
        return ((document.cookie||'').match(
            RegExp(key+'=([^;]+)')
        )||[])[1] || null;
    },
    set : function( key, value ) {
        document.cookie = key + '=' + value +
            '; expires=Thu, 1 Aug 2030 20:00:00 UTC; path=/';
    }
};

/* ======================================================================== */
/* ============================== GAME LOBBY ============================== */
/* ======================================================================== */


/* --------
    Step 1: Capture Current User's Information.
   -------- */

var current_user = {
    // User's UUID (Uniquely Identify Each Player).
    uuid : cookie.get('uuid') || PUBNUB.uuid(function(uuid){
        current_user.uuid = uuid;
        cookie.set( 'uuid', uuid );
    }),

    // Get or Set User's Name
    name : cookie.get('name') || (function(){
        var name = prompt('Player Name:') || 'Fluff';
        cookie.set( 'name', name );
    })()
};


/* --------
    Step 2: Provide a Player Creation Interface.
   -------- */

var player = (function(){
    return {
        add : function(user) {
            var uuid = user['uuid'];
            if (uuid.indexOf('-') < 2) return;
            player[uuid] = user;
        },
        get : function(uuid) {
            return player[uuid];
        }
    };
})();


/* --------
    Step 3: Subscribe to Lobby Channel.
   -------- */

var lobby = 'lobby';
PUBNUB.subscribe({ 'channel' : lobby }, function(message) {
    // Lobby Room Actions
    switch (message['action']) {

        // All Users, Send Your Info!
        case 'ping' :
            PUBNUB.publish({
                'channel' : lobby,
                'message' : {
                    'action' : 'update',
                    'player' : player.get(current_user.uuid) 
                }
            });
            break;
    }
});


/* --------
    Step 4: Curren User Joins Lobby!
   -------- */

PUBNUB.publish({
    'channel' : 'lobby',
    'message' : { 'action' : 'ping' }
});


})()
