var largeCircle = new Path.Circle([676, 433], 100);
largeCircle.fillColor = 'black';

var text = new PointText(view.center);
text.fillColor = 'white';
text.characterStyle.fontSize = 20;
text.content = 'PubNub';


function onMouseMove(event) {
  largeCircle.position = event.point;
  text.position = event.point;  
}

function onFrame(event) {
  largeCircle.scale(0.99);
  text.scale(0.99);
}

function onMouseDown(event) {
  largeCircle.scale(1.5);
  text.scale(1.5);
}


$("#bubble_text").change( function() {
  text.content = $(this).val();
});
