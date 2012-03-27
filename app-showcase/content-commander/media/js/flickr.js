PUBNUB.events.bind("flickr_link", function(data) {
  $("#content").remove();
  $("#viewer_box").append("<div id='content'></div>");
  var new_img = '<img src="http://farm' + data.farm +  '.staticflickr.com/' + data.server  + 
                '/' + data.id + '_' + data.secret + '.jpg" width="300" alt="' +
                data.title + '" />';
  $("#content").append(new_img);
});

