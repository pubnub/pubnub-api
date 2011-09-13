ig.module(
	'game.entities.puck'
)
.requires(
	'impact.entity'
)
.defines(function(){

EntityPuck = ig.Entity.extend({
	
	size: {x:48, y:48},
	collides: ig.Entity.COLLIDES.ACTIVE,
	
	animSheet: new ig.AnimationSheet( 'media/puck.png', 48, 48 ),
	
	bounciness: 1,
	
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
		this.vel.y = 200;
  },

  update: function() {
    /*
    if (this.vel.x > 0) 
      this.accel.x = 10;
    else 
      this.accel.x = -10;

    if (this.vel.y > 0) 
      this.accel.y = 10;
    else 
      this.accel.y = -10;
    */

    this.parent(); 
  }

});

});
