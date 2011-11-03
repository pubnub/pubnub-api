var placed = false;

var large_circle = new Path.Circle([676, 433], 100);
large_circle.fillColor = 'black';
large_circle.strokeColor = 'black';
large_circle.strokeWidth = 8;

var text = new PointText(view.center);
text.fillColor = 'white';
text.characterStyle.fontSize = 35;
text.paragraphStyle.justification = 'center';
text.content = 'PubNub';
text.position = large_circle.center;

var group = new Group([large_circle, text]);
group.visible = false;


function onMouseMove(event) {
  if (placed === false) {
    group.children[0].position = event.point;
    group.position = large_circle.bounds.center;  
  }
}

function onFrame(event) {
  if (placed === false) {
    group.children[0].rotate(1);
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
    group.opacity = 1;
    group.position = event.point;
    group.dashArray = [14, 0];
  }
}


$("#place").click( function(e) {
  e.preventDefault();

  placed = false;

  group.children[1].content = $("#bubble_text").val();
  group.children[1].position = group.position;
  group.visible = true;
  group.children[0].dashArray = [14, 4];
  group.opacity = .5;
});

