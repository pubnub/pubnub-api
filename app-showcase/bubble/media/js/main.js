var largeCircle = new Path.Circle([676, 433], 100);

largeCircle.fillColor = 'black';
largeCircle.strokeColor = 'black';
largeCircle.strokeWidth = 8;
largeCircle.visible = false;

var placed = false;

var text = new PointText(view.center);
text.fillColor = 'white';
text.characterStyle.fontSize = 35;
text.paragraphStyle.justification = 'center';
text.content = 'PubNub';

var group = new Group([largeCircle, text]);


function onMouseMove(event) {
  if (placed === false) {
    largeCircle.position = event.point;
    text.position = largeCircle.bounds.center;  
  }
}

function onFrame(event) {
  if (placed === false) {
    largeCircle.rotate(1);
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
    largeCircle.opacity = 1;
    largeCircle.position = event.point;
    largeCircle.dashArray = [14, 0];
    text.position = event.point;
  }
}


$("#place").click( function(e) {
  e.preventDefault();
  placed = false;
  text.content = $("#bubble_text").val();
  largeCircle.visible = true;
  largeCircle.dashArray = [14, 4];
  largeCircle.opacity = .5;
});

