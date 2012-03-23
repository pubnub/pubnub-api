PUBNUB.events.bind('arb_html', function(data) {
  $("#content").remove();
  $("#viewer_box").append("<div id='content'>"+ data.html + "</div>");
});
