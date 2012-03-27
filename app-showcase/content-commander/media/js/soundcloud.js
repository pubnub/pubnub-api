PUBNUB.events.bind("soundcloud_link", function(data) {
  $("#content").remove();
  $("#viewer_box").append("<div id='content'></div>");
  var new_iframe = '<iframe width="100%" height="166" scrolling="no" frameborder="no" src="http://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F' + data.song_id + '&amp;auto_play=true&amp;show_artwork=true&amp;color=ff7700"></iframe>'
  $("#content").append(new_iframe);
});

