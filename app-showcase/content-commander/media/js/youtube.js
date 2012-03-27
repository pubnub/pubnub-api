PUBNUB.events.bind("youtube_link", function(data) {
  $("#content").remove();
  $("#viewer_box").append("<div id='content'></div>");
  var new_iframe = '<iframe id="youtube_player" width="300" height="168" src="http://www.youtube.com/embed/' + data.video_id + '?autoplay=1" frameborder="0"  allowfullscreen></iframe>';
  $("#content").append(new_iframe);
});



