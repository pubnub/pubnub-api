var bubbles = [];
var placed  = false;
var now     = function(){return+new Date};

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
      bubbles[i].scale(.99); 
  }
}

function onMouseDown(event) {
  if (onMouseDown.last + 100 > now()) return;
  onMouseDown.last = now();

  for (var i = 0; i < bubbles.length; i++) {
      hit_result = bubbles[i].hitTest(event.point);
      if ((hit_result !== null) && (hit_result !== undefined)) {
        bubbles[i].scale(1.5);
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

  bubbles.push(new_bubble);

});


function generateRandomLocation() {
  return new Point(Math.random() * view.size.width, Math.random() * view.size.height); 
}
