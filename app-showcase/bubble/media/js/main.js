var bubbles = [];
var bubble_index = {};
var now     = function(){return+new Date};
var channel = 'pubnub-demo-channel';
var my_id   = PUBNUB.uuid(function(uuid){ my_id = uuid });

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

function onMouseMove(event) {
}

function onFrame(event) {
  for (var i = 0; i < bubbles.length; i++) {

    switch (bubbles[i].action) {
      case "":
        bubbles[i].scale(.99); 
        bubbles[i].children[0].strokeWidth *= .99; 

        if (bubbles[i].children[0].bounds.width <= 50) {
          bubbles[i].action = "popping";   
        }
        break;

      case "flashing":
        bubbles[i].children[0].fillColor.hue += 10;
        if (bubbles[i].children[0].fillColor.hue >= default_hue) {
          bubbles[i].action = '';
        }
        break;

      case "popping": 
        bubbles[i].scale(1.2); 
        bubbles[i].children[0].strokeWidth *= 1.2; 
        bubbles[i].opacity = bubbles[i].opacity *.7; 
        if (bubbles[i].opacity < .02) {
          bubbles[i].remove();
          bubbles.splice(i,1);
        }
        break;
    }
  }
}

function send_bubble_click(event) {
  PUBNUB.publish({
     channel  : channel,
     callback : function(i){console.log(i)},
     message  : {
       name  : 'bubble-click',
       point : event.point,
       text  : event.text,
       uuid  : event.uuid,
       from  : my_id
     }
  });
}

function pump_bubble_up(bubble) {
  bubble.scale(1.5);
  bubble.children[0].strokeWidth *= 1.5; 
}

function onMouseDown(event) {
  var uuid = 'uuid' in event && event.uuid;
  //if (onMouseDown.last + 800 > now()) return;

  uuid && console.log('NETWORK EVETNT!!!',uuid);
  uuid && !(uuid in bubble_index) && add_new_bubble(event);

  // Prevent Local/Remote Double Click
  //if (uuid && event.from === my_id) return;

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

        bubbles[i].action = 'flashing';
        bubbles[i].children[0].fillColor.hue -= 50;
        bubbles[i].scale(1.5);
        bubbles[i].children[0].strokeWidth *= 1.5; 
      }
  }
}
onMouseDown.last = now();


// ---------------------------------------------------------------------------
// Make New Bubble
// ---------------------------------------------------------------------------
function add_new_bubble(event) {
  var new_bubble = group.clone(); 
  var uuid = event.uuid;
  
  new_bubble.children[1].content = event.text;
  new_bubble.visible = true;
  var bubble_pos = event.point;
  new_bubble.children[0].position = bubble_pos;
  new_bubble.children[1].position = bubble_pos;
  new_bubble.position = bubble_pos;
  new_bubble.action = '';

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


$("#place").click( function(e) {
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
    console.log(event);
    PUBNUB.events.fire( event.name, event );
  }
});

// ---------------------------------------------------------------------------
// PubNub Events
// ---------------------------------------------------------------------------
PUBNUB.events.bind( 'bubble-click', function(event) {
  onMouseDown(event);
} );

function generateRandomLocation() {
  c_width = large_circle.bounds.width;
  c_height = large_circle.bounds.height;
  return new Point(Math.random() * (view.size.width - (c_width /2 )) + (c_width / 4) , 
                   Math.random() * (view.size.height - (c_height /2 )) + (c_height / 4)); 
}

