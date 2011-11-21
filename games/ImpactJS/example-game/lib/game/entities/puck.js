ig.module(
	'game.entities.puck'
)
.requires(
	'plugins.pubnub.entity'
)
.defines(function(){

EntityPuck = ig.PubNubEntity.extend({
	
	size: {x:48, y:48},
	collides: ig.Entity.COLLIDES.ACTIVE,
	
	animSheet: new ig.AnimationSheet( 'media/puck.png', 48, 48 ),
	bounciness: 1,
  belongs_to: 'player_2',
	
	init: function( x, y, settings ) {
		this.parent( x, y, settings );
		
		this.addAnim( 'idle', 0.1, [0,1,2,3,4,4,4,4,3,2,1] );

		this.vel.x = 0;
		this.vel.y = 0;
    this.accel.x = 0;
    this.accel.y = 0;
		this.maxVel.x = 400;
		this.maxVel.y = 400;
	},

	startMoving: function() {
		this.vel.x = 200;
		this.vel.y = 100;
  },

	stopMoving: function() {
		this.vel.x = 0;
		this.vel.y = 0;
  },

  update: function() {
    this.parent(); 

    if ((this.pos.x > 1000) || (this.pos.x < -1000)) {
      this.vel.x = 0;
      this.vel.y = 0;
      this.accel.x = 0;
      this.accel.y = 0;
    }
  }

});

});
