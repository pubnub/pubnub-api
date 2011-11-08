var bubbles = [];
var bubble_index = {};
var now     = function(){return+new Date};
var channel = 'pubnub-demo-channel';
var timeframe = 500;

// ---------------------------------------------------------------------------
// Starter Objects (Circle and Text)
// ---------------------------------------------------------------------------
var large_circle = new Path.Circle([676, 433], 100);
large_circle.fillColor = '#29C9FF';
large_circle.strokeColor = '#000';
large_circle.strokeWidth = 5;
var default_hue = large_circle.fillColor.hue;

var text = new PointText(view.center);
text.fillColor = '#000';
text.characterStyle.fontSize = 35;
text.paragraphStyle.justification = 'center';
text.content = 'PubNub';
text.position = large_circle.center;

var group = new Group([large_circle, text]);
group.visible = false;


function sigmoid(t) {
  return 1/(1+Math.pow(Math.E, -t));
}


// ---------------------------------------------------------------------------
// Paper.JS Events: Mouse Move
// ---------------------------------------------------------------------------
function onMouseMove(event) {}



// ---------------------------------------------------------------------------
// Paper.JS Events: Frame Render
// ---------------------------------------------------------------------------
onFrame.last_frame = now();
function onFrame(event) {
  // Calculate last time since previous frame.
  onFrame.elapsed_time = now() - onFrame.last_frame
  onFrame.modifier     = onFrame.elapsed_time / timeframe;

  onFrame.last_frame = now();

  // For Each Bubble: Fire Action.
  PUBNUB.each( bubbles, function( bubble, position ) {
    if (!bubble) return;
    PUBNUB.events.fire( bubble.action, {
      bubble   : bubble,
      position : position,
      frame    : onFrame,
      time     : now()
    } );
  } );
}

// ---------------------------------------------------------------------------
// Paper.JS Events: Mouse Down
// ---------------------------------------------------------------------------
function onMouseDown(event) {
  var uuid = 'uuid' in event && event.uuid;
  //if (onMouseDown.last + 800 > now()) return;

  //uuid && console.log('NETWORK EVETNT!!!',uuid);
  uuid && !(uuid in bubble_index) && add_new_bubble(event);

  // (Remote Click) UUID Bubble Pump
  if (uuid) return pump_bubble_up(bubble_index[uuid].bubble);

  // (Local Click) X,Y Hit?
  for (var i = 0; i < bubbles.length; i++) {
      hit_result = bubbles[i].hitTest(event.point);
      if (bubbles[i].hitTest(event.point)) {

        // Create Bubble Click Event.
        event.uuid = bubbles[i].uuid;
        send_bubble_click(event);
        onMouseDown.last = now();

      }
  }
}
onMouseDown.last = now();

// ---------------------------------------------------------------------------
// Animate Bubble (Constantly Shrinking)
// ---------------------------------------------------------------------------
PUBNUB.events.bind( "animate", function(data) {
  var bubble        = data.bubble
  ,   elapsed_time  = data.frame.elapsed_time
  ///,   time          = data.time - bubble.birth
  ,   current_scale = bubble.bounds.width / bubble.birth_width
  ,   desired_scale = sigmoid(bubble.weight);

  console.log('current_scale',current_scale, 'desired_scale',desired_scale, bubble.bounds.width, large_circle.bounds.width, 'scalefoactor',desired_scale / current_scale, 'current_width',bubble.bounds.width ) ;

/*
  
*/
  // Shrink Weight
  bubble.weight -= elapsed_time / 1000;
  //bubble.bounds.height  = 100*sigmoid(bubble.weight);
  //bubble.bounds.width =  100*sigmoid(bubble.weight);
  //console.log(1 - .4 * modifier, sigmoid(bubble.weight));
  bubble.scale((desired_scale / current_scale) / .4);
  /*
  bubble.children[0].strokeWidth *= (
    1 - .4 * modifier * sigmoid(time)
  );
  console.log(bubble.size,bubble.size.width)
  */

/*
  if (bubble.children[0].bounds.width <= 50) {
    bubble.action = "popping";   
  }
  */
} );

// ---------------------------------------------------------------------------
// Flash The Bubble
// ---------------------------------------------------------------------------
PUBNUB.events.bind( "flashing", function(data) {
  var bubble   = data.bubble
  ,   modifier = data.frame.modifier;

  bubble.children[0].fillColor.hue += 10;// * modifier;
  if (bubble.children[0].fillColor.hue >= default_hue) {
    bubble.action = "animate";
  }
} );

// ---------------------------------------------------------------------------
// POP The Bubble
// ---------------------------------------------------------------------------
PUBNUB.events.bind( "popping", function(data) {
  var bubble   = data.bubble
  ,   modifier = data.frame.modifier;

  bubble.scale(1 + 1.8 * modifier); 
  bubble.children[0].strokeWidth *= 1 + 1.8 * modifier; 
  bubble.opacity *= 1 - 9.0 * modifier; 

  // Is the bubble still in popping animation?
  if (bubble.opacity >= .02) return;

  // The bubble has finished popping, remove it.
  bubble.remove();
  bubbles.splice( data.position, 1 );
} );

// ---------------------------------------------------------------------------
// Send Click Event (Click Sharing)
// ---------------------------------------------------------------------------
function send_bubble_click(event) {
  PUBNUB.publish({
     channel  : channel,
     callback : function(i){0&&console.log(i)},
     message  : {
       name  : 'bubble-click',
       point : event.point,
       text  : event.text,
       uuid  : event.uuid
     }
  });
}

// ---------------------------------------------------------------------------
// Bubble Insta Expand (usually when clicked)
// ---------------------------------------------------------------------------
function pump_bubble_up(bubble) {
  if (bubble.action === 'popping') return;

  bubble.action = 'flashing';
  bubble.children[0].fillColor.hue -= 50;
  bubble.scale(1.5);
  bubble.children[0].strokeWidth *= 1.5; 
}

// ---------------------------------------------------------------------------
// Make New Bubble
// ---------------------------------------------------------------------------
function add_new_bubble(event) {
  var new_bubble = group.clone(); 
  var uuid = event.uuid;

  new_bubble.weight = 0;
  new_bubble.birth = now();
  new_bubble.birth_width  = 300;//large_circle.bounds.width;
  new_bubble.birth_height = 200;//large_circle.bounds.hight;
  new_bubble.children[1].content = event.text;
  new_bubble.visible = true;
  var bubble_pos = event.point;
  new_bubble.children[0].position = bubble_pos;
  new_bubble.children[1].position = bubble_pos;
  new_bubble.position = bubble_pos;
  new_bubble.action = 'animate';

  var bubble_pos = event.point;
  bubbles.push(new_bubble);

  // Create New Bubble Entity Lookup
  new_bubble.uuid = uuid;
  bubble_index[uuid] = { bubble : new_bubble, uuid : uuid };

  uuid || PUBNUB.uuid(function(uuid) {
    new_bubble.uuid = uuid;
    bubble_index[uuid] = { bubble : new_bubble, uuid : uuid };
  } );
}


// ---------------------------------------------------------------------------
// Make New Bubble (User Event)
// ---------------------------------------------------------------------------
$("#place").bind( 'mousedown', function(e) {
  e.preventDefault();

  PUBNUB.uuid(function(uuid) {
    send_bubble_click({
      point : generateRandomLocation(),
      uuid  : uuid,
      text  : $("#bubble_text").val()
    });
  } );

});


// ---------------------------------------------------------------------------
// PubNub Networking
// ---------------------------------------------------------------------------
PUBNUB.subscribe({
  channel  : channel,
  connect  : function() {},
  callback : function(event) {
    //console.log(event);
    PUBNUB.events.fire( event.name, event );
  }
});

// ---------------------------------------------------------------------------
// PubNub Events
// ---------------------------------------------------------------------------
PUBNUB.events.bind( 'bubble-click', function(event) {
  onMouseDown(event);
} );

// ---------------------------------------------------------------------------
// Generate Randomized Point
// ---------------------------------------------------------------------------
function generateRandomLocation() {
  c_width = large_circle.bounds.width;
  c_height = large_circle.bounds.height;
  return new Point(Math.random() * (view.size.width - c_width ) + (c_width / 2) , 
                   Math.random() * (view.size.height - c_height ) + (c_height / 2)); 
}

