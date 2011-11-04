var bubbles = [];
var bubble_index = {};
var placed  = false;
var now     = function(){return+new Date};
var channel = 'pubnub-demo-channel';

var large_circle = new Path.Circle([676, 433], 100);
large_circle.fillColor = '#000';
large_circle.strokeColor = '#000';
large_circle.strokeWidth = 8;

var text = new PointText(view.center);
text.fillColor = '#fff';
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
    //console.log("aoeuaueo");
    if (bubbles[i].popping === false) {
      bubbles[i].scale(.99); 
      //console.log(bubbles[i].children[0].bounds);

      if (bubbles[i].children[0].bounds.width <= 50) {
        bubbles[i].popping = true;   
      }
    }
    else {
      bubbles[i].scale(1.2); 
      bubbles[i].opacity = bubbles[i].opacity *.7; 
      if (bubbles[i].opacity < .02) {
        bubbles[i].remove();
        bubbles.splice(i,1);
      }
    }
  }
}

function send_bubble_click( uuid, event ) {
  PUBNUB.publish({
     channel  : channel,
     callback : function(i){console.log(i)},
     message  : {
       name  : 'bubble-click',
       point : event.point,
       uuid  : uuid
     }
  });
}

function onMouseDown(event) {
  var uuid = 'uuid' in event && event.uuid;
  //if (onMouseDown.last + 800 > now()) return;

  uuid && console.log('NETWORK EVETNT!!!',uuid);

  uuid && !(uuid in bubble_index) && add_new_bubble(uuid);

  for (var i = 0; i < bubbles.length; i++) {
      hit_result = bubbles[i].hitTest(event.point);
      if (hit_result) {
        if (uuid) {
          bubbles[i].scale(1.5);
          continue;
        }
        // Publish Fun For All
        send_bubble_click( bubbles[i].uuid, event );
        onMouseDown.last = now();
      }
  }
}
onMouseDown.last = now();


// ---------------------------------------------------------------------------
// Make New Bubble
// ---------------------------------------------------------------------------
function add_new_bubble(uuid) {
  var new_bubble = group.clone(); 
  
  new_bubble.children[1].content = $("#bubble_text").val();
  new_bubble.visible = true;
  var bubble_pos = generateRandomLocation();
  new_bubble.children[0].position = bubble_pos;
  new_bubble.children[1].position = bubble_pos;
  new_bubble.position = bubble_pos;
  new_bubble.popping = false;

  var bubble_pos = generateRandomLocation();
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
  add_new_bubble();
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
  return new Point(Math.random() * view.size.width, Math.random() * view.size.height); 
}
