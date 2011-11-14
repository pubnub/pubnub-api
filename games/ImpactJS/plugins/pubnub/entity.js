ig.module( 
	'plugins.pubnub.entity'
)
.requires(
	'impact.entity',	
	'plugins.pubnub.game'
)
.defines(function(){

var p = PUBNUB;
ig.PubNubEntity = ig.Entity.extend({
  counter: 0, 
  update_every: 30,
  belongs_to_me: false,
  last_broadcasted: undefined, 

  update: function() {
    this.parent();
    this.counter += 1;  
    
    var curr = { "pos": this.pos, "vel": this.vel }
    if (this.checkIfUpdateNeeded(this.last_broadcasted, curr )) { 
      console.log("broadcasting update");
      this.broadcastUpdate();
    }
  },
  
  checkIfUpdateNeeded: function(prev, curr) {
    // if it's not time for a new update, return false
    if (this.counter % this.update_every != 0)  
      return false;

    // if this entity isn't under our control, return false
    if (this.belongs_to_me === false) 
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
    p.events.fire("send_to_server", to_send);
    this.last_broadcasted = { "pos": this.pos, "vel": this.vel } 

  },

  keepUpdated: function() {
    var ent_obj = this;

    p.events.bind("ent_update_" + ent_obj.id, function(message) {
      console.log("ent_update_" + ent_obj.id);
      if (ent_obj.belongs_to_me === false) {
        ent_obj.pos = message.pos;
        ent_obj.vel = message.vel;
        //todo later: update more than just pos and vel?
      }
    });

    p.events.bind("ent_now_yours_" + ent_obj.id, function(message) {
      ent_obj.belongs_to_me = true;
      ent_obj.pos = message.pos;
    });

    p.events.bind("ent_not_yours_" + ent_obj.id, function(message) {
      ent_obj.belongs_to_me = false;
    });
  },

  stopUpdating: function() {
    var ent_obj = this;

    p.events.unbind("ent_update_" + ent_obj.id);
    p.events.unbind("ent_not_yours_" + ent_obj.id);
    p.events.unbind("ent_now_yours_" + ent_obj.id);
  }

});


});
