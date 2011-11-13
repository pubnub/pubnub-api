ig.module( 
	'plugins.pubnub.entity'
)
.requires(
	'impact.entity',	
	'plugins.pubnub.game'
)
.defines(function(){


ig.PubNubEntity = ig.Entity.extend({
  counter: 0, 
  update_every: 30,
  belongs_to: "",
  last_broadcasted: undefined, 

  update: function() {
    this.parent();
    this.counter += 1;  
    
    var curr = { "pos": this.pos, "vel": this.vel }
    if (this.checkIfUpdateNeeded(this.last_broadcasted, curr )) { 
      this.broadcastUpdate();
    }
  },
  
  checkIfUpdateNeeded: function(prev, curr) {
    // if we're not in a game, return false 
    if (ig.game.game_status != "in_game")
      return false;

    // if it's not time for a new update, return false
    if (this.counter % this.update_every != 0)  
      return false;

    // if this entity isn't under our control, return false
    if (this.belongs_to != ig.game.which_player) 
      return false;
  
    // update if we don't have a prev 
    if (!prev) 
      return true;

    // if anything is different, return true
    if (prev.pos.x != curr.pos.x) 
      return true;
    if (prev.pos.y != curr.pos.y) 
      return true;
    if (prev.vel.x != curr.vel.x) 
      return true;
    if (prev.vel.y != curr.vel.y) 
      return true;

    return false;
  },


  broadcastUpdate: function() {
    to_send = {'type': 'ent_update', 
               'pos': this.pos, 
               'vel': this.vel, 
               'id': this.id }
    PUBNUB.events.fire("send_to_server", to_send);
    this.last_broadcasted = { "pos": this.pos, "vel": this.vel } 

  },

  keepUpdated: function() {
    var ent_obj = this;
    PUBNUB.events.bind("got_from_server", function(message) {
      if (message.id == ent_obj.id) {
        switch (message.type) {
          case "ent_update":
            if (ent_obj.belongs_to != ig.game.which_player) {
              ent_obj.pos = message.pos;
              ent_obj.vel = message.vel;
            }
            break;

          case "ent_now_yours":
            ent_obj.belongs_to = ig.game.which_player;
            ent_obj.pos = message.pos;
            break;

          case "ent_not_yours":
            if (ig.game.which_player == "player_1") {
              ent_obj.belongs_to = "player_2";
            }
            else {
              ent_obj.belongs_to = "player_1"; 
            }
            ent_obj.pos = message.pos;
            break;
        }
      }  
    });
  }

});


});
