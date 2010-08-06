(function(){

var PUB = PUBNUB

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

function current_player(ready) {
    function is_ready() {
        if (player['uuid'] && player['joined']) {
            players.add(player);
            ready(player)
        }
    }

    var player = {
        'uuid' : PUB.uuid(function(uuid){
            player['uuid'] = uuid;
            is_ready();
        }),
        'joined' : PUB.time(function(time){
            player['joined'] = time;
            is_ready();
        })
    };
}

PUB['player'] = {
    'players'        : players,
    'current_player' : current_player
};

})();
