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
  //largeCircle.scale(0.99);
  //text.scale(0.99);
}

function onMouseDown(event) {
  placed = true;
  largeCircle.opacity = 1;
  largeCircle.position = event.point;
  largeCircle.dashArray = [14, 0];
  text.position = event.point;

  //largeCircle.scale(1.5);
  //text.scale(1.5);
}


$("#place").click( function(e) {
  e.preventDefault();
  placed = false;
  text.content = $("#bubble_text").val();
  largeCircle.visible = true;
  largeCircle.dashArray = [14, 4];
  largeCircle.opacity = .5;
});
