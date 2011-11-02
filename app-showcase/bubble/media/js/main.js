var placed = false;

var large_circle = new Path.Circle([676, 433], 100);
large_circle.fillColor = 'black';
large_circle.strokeColor = 'black';
large_circle.strokeWidth = 8;
large_circle.visible = false;

var text = new PointText(view.center);
text.fillColor = 'white';
text.characterStyle.fontSize = 35;
text.paragraphStyle.justification = 'center';
text.content = 'PubNub';

var group = new Group([large_circle, text]);



function onMouseMove(event) {
  if (placed === false) {
    large_circle.position = event.point;
    text.position = large_circle.bounds.center;  
  }
}

function onFrame(event) {
  if (placed === false) {
    large_circle.rotate(1);
  }
  else {
    group.scale(.99); 
  }
}

function onMouseDown(event) {
  
  if (placed === true) {
    hit_result = group.hitTest(event.point);
    if ((hit_result !== null) && (hit_result !== undefined)) {
      group.scale(1.5);
    }
  } 

  if (placed === false) {
    placed = true;
    large_circle.opacity = 1;
    large_circle.position = event.point;
    large_circle.dashArray = [14, 0];
    text.position = event.point;
  }
}


$("#place").click( function(e) {
  e.preventDefault();

  placed = false;

  text.content = $("#bubble_text").val();
  large_circle.visible = true;
  large_circle.dashArray = [14, 4];
  large_circle.opacity = .5;
});

