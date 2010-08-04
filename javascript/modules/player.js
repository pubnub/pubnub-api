var PUB     = PUBNUB
,   utility = PUB.utility
,   cookie  = utility.cookie

/* --------
   Provide a Player Creation/Management Interface.
   -------- */

,   players = (function(){
    var players_obj = {};
    return {
        add : function(player) {
            players_obj[player['uuid']] = player;
            return player;
        },
        get : function(uuid) {
            return players_obj[uuid];
        },
        all : function() {
            return players_obj;
        }
    };
})();

/* --------
   Capture Current User's Information.
   -------- */

function current_player() {
    return players.add({
        // User's UUID (Uniquely Identify Each Player).
        uuid : cookie.get('uuid') || PUB.uuid(function(uuid){
            cookie.set( 'uuid', uuid );
        })
    });
}

PUB['player'] = {
    'players'        : players,
    'current_player' : current_player
};

