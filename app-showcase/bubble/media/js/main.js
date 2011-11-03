var bubbles = [];
var bubble_index = {};
var now     = function(){return+new Date};
var channel = 'pubnub-demo-channel';

var large_circle = new Path.Circle([676, 433], 100);
large_circle.fillColor = '#29C9FF';
large_circle.strokeColor = '#000';
large_circle.strokeWidth = 8;

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
    //console.log("aoeuaueo");
    if (bubbles[i].popping === false) {
      bubbles[i].scale(.99); 
      bubbles[i].children[0].strokeWidth *= .99; 
      //console.log(bubbles[i].children[0].bounds);

      if (bubbles[i].children[0].bounds.width <= 50) {
        bubbles[i].popping = true;   
      }
    }
    else {
      bubbles[i].scale(1.2); 
      bubbles[i].children[0].strokeWidth *= 1.2; 
      bubbles[i].opacity = bubbles[i].opacity *.7; 
      if (bubbles[i].opacity < .02) {
        bubbles[i].remove();
        bubbles.splice(i,1);
      }
    }
  }
}

function onMouseDown(event) {
  var uuid = 'uuid' in event && event.uuid;
  //if (onMouseDown.last + 800 > now()) return;

  // Publish Fun For All
  /*
  uuid || PUBNUB.publish({
     channel  : channel,
     callback : function(i){console.log(i)},
     message  : {
       name  : 'bubble-click',
       point : event.point,
     }
  });
  */

  uuid || console.log('NETWORK EVETNT!!!');

  //console.log(event.point);

  for (var i = 0; i < bubbles.length; i++) {
      hit_result = bubbles[i].hitTest(event.point);
      if ((hit_result !== null) && (hit_result !== undefined)) {
        bubbles[i].scale(1.5);
        onMouseDown.last = now();
      }
  }
}
onMouseDown.last = now();

$("#place").click( function(e) {
  e.preventDefault();

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
  PUBNUB.uuid(function(uuid) {
    new_bubble.uuid = uuid;
    bubble_index[uuid] = { bubble : new_bubble, uuid : uuid };
  } );

});


// ---------------------------------------------------------------------------
// PubNub Networking
// ---------------------------------------------------------------------------
PUBNUB.subscribe({
  channel  : channel,
  connect  : function() {},
  callback : function(event) {
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
