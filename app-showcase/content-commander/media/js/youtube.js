
var tag = document.createElement('script');
tag.src = "http://www.youtube.com/player_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

var player;

function onPlayerReady(event) {
  event.target.playVideo();
}

PUBNUB.events.bind("youtube_link", function(data) {
  $("#content").remove();
  $("#viewer_box").append("<div id='content'></div>");

  player = new YT.Player('content', {
    height: '390',
    width: '640',
    videoId: data.video_id,
    events: {
      'onReady': onPlayerReady
    }
  });
});
