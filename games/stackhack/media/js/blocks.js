/****
The MIT License

Copyright (c) 2010-2012 three.js Authors. All rights reserved.
Copyright (c) 2012 PubNub. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
***/

var container, stats, camera, scene, renderer,
projector, plane, mouse2D, mouse3D, ray,
rollOveredFace, theta = 45, 
isRightDown = false, isLeftDown = false,
target = new THREE.Vector3( 0, 200, 0 ),
cursor, remove_cursor, color, block_index = {},
pending_blocks = {}, mode = 'create',
intersects;

init();
animate();

$("#remove_mode").click( function() {
  mode = 'remove';
  scene.remove(cursor);
  cursor = undefined;
});

$("#create_mode").click( function() {
  mode = 'create';
});


function hashBlock(x, y, z) {
  return x + "_" + y + "_" + z;
}

PUBNUB.events.bind("color_changed", function(c) {
  color = c;
  delete cursor;
});

function init() {

  camera = new THREE.PerspectiveCamera( 40, window.innerWidth / window.innerHeight, 1, 10000 );
  camera.position.y = 800;

  scene = new THREE.Scene();

  // Grid
  var grid_geometry = new THREE.Geometry();
  grid_geometry.vertices.push( new THREE.Vertex( new THREE.Vector3( - 500, 0, 0 ) ) );
  grid_geometry.vertices.push( new THREE.Vertex( new THREE.Vector3( 500, 0, 0 ) ) );

  var material = new THREE.LineBasicMaterial( { color: 0x000000, opacity: 0.2 } );

  for ( var i = 0; i <= 20; i ++ ) {
    var line = new THREE.Line( grid_geometry, material );
    line.position.z = ( i * 50 ) - 500;
    scene.add( line );

    var line = new THREE.Line( grid_geometry, material );
    line.position.x = ( i * 50 ) - 500;
    line.rotation.y = 90 * Math.PI / 180;
    scene.add( line );
  }

  projector = new THREE.Projector();

  plane = new THREE.Mesh( new THREE.PlaneGeometry( 1000, 1000, 20, 20 ), new THREE.MeshFaceMaterial() );
  plane.rotation.x = - 90 * Math.PI / 180;
  scene.add( plane );

  mouse2D = new THREE.Vector3( 0, 10000, 0.5 );
  ray = new THREE.Ray( camera.position, null );

  // Lights

  var ambientLight = new THREE.AmbientLight( 0x606060 );
  scene.add( ambientLight );

  var directionalLight = new THREE.DirectionalLight( 0xffffff );
  directionalLight.position.x = 0.5;
  directionalLight.position.y = 0.5;
  directionalLight.position.z = -0.5;
  directionalLight.position.normalize();
  scene.add( directionalLight );

  var directionalLight = new THREE.DirectionalLight( 0x808080 );
  directionalLight.position.x = -0.5;
  directionalLight.position.y = 0.5;
  directionalLight.position.z = -0.1;
  directionalLight.position.normalize();
  scene.add( directionalLight );

  container = document.getElementById('container');

  renderer = new THREE.CanvasRenderer();
  renderer.setSize( window.innerWidth, window.innerHeight );

  container.appendChild(renderer.domElement);

  document.addEventListener( 'mousemove', onDocumentMouseMove, false );
  document.addEventListener( 'mousedown', onDocumentMouseDown, false );
  document.addEventListener( 'keydown', onDocumentKeyDown, false );
  document.addEventListener( 'keyup', onDocumentKeyUp, false );

  scene.add(camera);
}

function onDocumentMouseMove( event ) {
  event.preventDefault();

  mouse2D.x = ( event.clientX / window.innerWidth ) * 2 - 1;
  mouse2D.y = - ( event.clientY / window.innerHeight ) * 2 + 1;

  intersects = ray.intersectScene( scene );
  if (intersects.length == 0) {
    if (cursor) {
      scene.remove(cursor);
      cursor = undefined;
    }
    if (remove_cursor) {
      remove_cursor.material.opacity = 1;
      remove_cursor = undefined;
    }
    return;
  }

  if (mode === "remove") { 
    if ((intersects.length == 1) && (intersects[0].object == plane)) { 
      if (remove_cursor) {
        remove_cursor.material.opacity = 1;
        remove_cursor = undefined;
      }
      return;
    }

    if (intersects[0].object != cursor) {
      if (remove_cursor != undefined) {
        remove_cursor.material.opacity = 1;
      }
      remove_cursor = intersects[0].object;
      remove_cursor.material.opacity = .5;
      return;
    }
  }
  else if (mode === "create") {
    if (intersects[0].object != cursor) {
      var position = new THREE.Vector3().add(intersects[0].point, intersects[0].object.matrixRotationWorld.multiplyVector3( intersects[0].face.normal.clone())),
          intersect_x = Math.floor( position.x / 50 ) * 50 + 25, 
          intersect_y = Math.floor( position.y / 50 ) * 50 + 25, 
          intersect_z = Math.floor( position.z / 50 ) * 50 + 25; 

      if (isBlockValid(intersect_x, intersect_y, intersect_z)) {
        if (cursor == undefined) {
            cursor = addBlockToScene(intersect_x, intersect_y, intersect_z, color, .5);
        }
        else if ((intersect_x != cursor.position.x) || 
                 (intersect_y != cursor.position.y) || 
                 (intersect_z != cursor.position.z)) {
          scene.remove(cursor);
          delete cursor;
          cursor = addBlockToScene(intersect_x, intersect_y, intersect_z, color, .5);
        }    
      }
    }
  }
}

function requestNewBlock(x, y, z, c) {
  PUBNUB.events.fire("send_message", {
    "name": "create",
    "data": { "x":     x, 
              "y":     y, 
              "z":     z,
              "color": c }
  });
}

function requestRemoveBlock(x, y, z) {
  PUBNUB.events.fire("send_message", {
    "name": "remove",
    "data": { "x":     x, 
              "y":     y, 
              "z":     z }
  });
}

function isBlockValid(x, y, z) {
  var hash = hashBlock(x, y, z); 
  if (block_index[hash] != undefined) {
    return false;
  }
  if ((z > 475)  || (z < -475) || 
      (x > 475)  || (x < -475) ||
      (y > 875)  || (y < 0)) {
    return false;  
  }
  if ((((x - 25) % 50) != 0 ) ||
      (((y - 25) % 50) != 0 ) ||
      (((z - 25) % 50) != 0 )) {
    return false;  
  }
  return true;
}

function onDocumentMouseDown( event ) {
  event.preventDefault();
  if ((mode === "create") && (cursor)) { 
    place = hashBlock(cursor.position.x, cursor.position.y, cursor.position.z);
    requestNewBlock(cursor.position.x, cursor.position.y, cursor.position.z, color);
    scene.remove(cursor);
    cursor = undefined;
  } 
  else if ((mode === "remove") && (remove_cursor)) {
    requestRemoveBlock( remove_cursor.position.x, remove_cursor.position.y, remove_cursor.position.z); 
    remove_cursor = undefined;
  }
}


// update blocks
var status_interval = setInterval( function() { 
  if ($(document).data('last_status_timestamp') == undefined) {
    PUBNUB.events.fire("send_message", { "name": "status" });
    clearInterval(status_interval);
    return;
  }
}, 60 * 1000 * 5); 


PUBNUB.events.bind("got_from_server_message_status", function(message) {
  if ($(document).data('last_status_timestamp') !== message.data.timestamp) {   
    $(document).data('last_status_timestamp', message.data.timestamp); 
    removeAllBlocks();
  }
  for (var i = 0; i < message.data.blocks.length; i++) {
    var block = message.data.blocks[i];
    createBlock(block.x, block.y, block.z, block.color, 1);
  } 
});

PUBNUB.events.bind( "got_from_server_message_wipe", function(message) {
  removeAllBlocks();
});

function removeAllBlocks() {
  for (block in block_index) {
    scene.remove(block_index[block]);
    delete block_index[block];
  }
}

PUBNUB.events.bind( "got_from_server_remove", function(message) {
  place = hashBlock(message.data.x, message.data.y, message.data.z);
  if (block_index[place] != undefined) {
    scene.remove(block_index[place]);
    delete block_index[place];
  }
});

var cube_geometry  = new THREE.CubeGeometry( 50, 50, 50);
function addBlockToScene(x, y, z, c, o) {
  var material = new THREE.MeshLambertMaterial( { color: c, opacity: o, shading: THREE.FlatShading } );
  var block = new THREE.Mesh(cube_geometry, material );
  block.material = material;
  block.position.x = x;
  block.position.y = y;
  block.position.z = z;
  block.matrixAutoUpdate = false;
  block.updateMatrix();
  block.overdraw = true;
  scene.add( block );
  return block;
}

function createBlock(x, y, z, c, o) {
  var place = hashBlock(x, y, z);
  if (!block_index[place]) {
    var block = addBlockToScene(x, y, z, c, o);
    block_index[place] = block;
  }
}

PUBNUB.events.bind("got_message_create", function(message) {
  if (isBlockValid(message.data.x, message.data.y, message.data.z)) {
    createBlock(message.data.x, message.data.y, message.data.z, message.data.color, 1);
  }
});

PUBNUB.events.bind("got_message_remove", function(message) {
  place = hashBlock(message.data.x, message.data.y, message.data.z);
  if (block_index[place] != undefined) {
    scene.remove(block_index[place]);
    delete block_index[place];
  }
});

function onDocumentKeyDown( event ) {
  switch( event.keyCode ) {
    case 37: isLeftDown = true; break;
    case 39: isRightDown = true; break;
  }
}

function onDocumentKeyUp( event ) {
  switch( event.keyCode ) {
    case 37: isLeftDown = false; break;
    case 39: isRightDown = false; break;
  }
}

$("#spin_left").
  mousedown( function() {
    isLeftDown = true;
    isRightDown = false; 
  })
  .mouseup( function() {
    isLeftDown = false; 
  });

$("#spin_right").
  mousedown( function() {
    isRightDown = true;
    isLeftDown = false; 
  })
  .mouseup( function() {
    isRightDown = false; 
  });

function animate() {
  requestAnimationFrame( animate );
  render();
}

function render() {

  if ( isLeftDown ) {
    theta += 3;
  }
  if ( isRightDown ) {
    theta -= 3;
  }

  camera.position.x = 1400 * Math.sin( theta * Math.PI / 360 );
  camera.position.z = 1400 * Math.cos( theta * Math.PI / 360 );
  camera.lookAt( target );

  mouse3D = projector.unprojectVector( mouse2D.clone(), camera );
  ray.direction = mouse3D.subSelf( camera.position ).normalize();
  
  intersects = ray.intersectScene( scene );

  if ( intersects.length > 0 ) {
    if ( intersects[ 0 ].face != rollOveredFace ) {
      if ( rollOveredFace ) rollOveredFace.materials = [];
      rollOveredFace = intersects[ 0 ].face;
      rollOveredFace.materials = [ new THREE.MeshBasicMaterial( { color: 0xff0000, opacity: 0.5 } ) ];
    }
  } 
  else if ( rollOveredFace ) {
     rollOveredFace.materials = [];
     rollOveredFace = null;
  }
  renderer.render( scene, camera );
}

for (i in $(document).data("initial_blocks")) {
  var block_to_add = $(document).data("initial_blocks")[i];  
  createBlock(block_to_add.x, block_to_add.y, block_to_add.z, block_to_add.c, 1);   
}
