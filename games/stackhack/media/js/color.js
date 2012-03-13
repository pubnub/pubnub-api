function colorChosen(color) {
  $("#color_display").css('background', color);
  var int_color = parseInt("0x" + color.substr(1));
  //$(document).data('color', int_color);
  PUBNUB.events.fire("color_changed", int_color);
};

$(document).ready(function() {
  $('#color_picker').farbtastic({ callback: colorChosen, width: 150});
  $('#color_display').click( function(e) { 
    $("#color_picker").slideToggle('fast');
  });
});

