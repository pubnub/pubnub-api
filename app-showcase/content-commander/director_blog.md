Zipping around little pieces of information is trivially easy with PubNub.  Here's a cool use case: a way to push out arbitrary content in real-time to anyone who wants to listen.  I'm calling it "Content Commander".  Youtube videos, Google Maps embeds, anything your heart desires.  Let's start with Youtube, a simple case I've baked right in.  It's only a few lines of code, and here they are.  

On the commander: 

    $("#youtube_submit").click( function(e) {
      e.preventDefault();

      var text = $("#youtube_link").val(),
          start_loc = text.indexOf('watch?v=') + 8,    
          end_loc = text.indexOf('&'),
          video_id;    

      if (start_loc == -1) { return; }
      if (end_loc == -1) { end_loc = (text.length - 1); }
    
      // parse out just the video_id
      video_id = text.substr(start_loc, (end_loc - start_loc));

      //send it with PubNub
      PUBNUB.publish({ 
        channel : "content_commander", 
        message : {
          "name"     : "new_video",
          "data"     : {
            "video_id" : video_id
          }
        }
      });
    });


On the viewer:
    // first let's catch all the messages and stick them in PubNub's simple js event system
    PUBNUB.subscribe({
      channel    : "content_commander", 
      callback   : function(message) {
        if (message.name) {
          PUBNUB.events.fire(message.name, message.data);
        }
      }
    });

    // now the youtube code, straight from their iframe (HTML5 video) documentation
    var tag = document.createElement('script');
    tag.src = "http://www.youtube.com/player_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

    var player;

    function onPlayerReady(event) {
      event.target.playVideo();
    }

    // this gets called anytime a message comes in with 
    // a property called "name" equal to "new_video"
    PUBNUB.events.bind("new_video", function(data) {
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

That's it.  Now just make sure you have a div called "content" containing another div called "viewer_box".


But we can go more interesting.  How about generic, arbitrary HTML?  Kinda dangerous maybe, but damn is it cool.   

On the commander: 
    $("#arb_html_submit").click( function(e) {
      e.preventDefault();

      var html = $("#arb_html").val();
      if ((html == undefined) && (html.length == 0)) { return; }

      PUBNUB.publish({ 
        channel : "content_commander", 
        message : {
          "name"   : "arb_html",
          "data"   : {
            "html"   : html
          }
        }
      });
    });

On the viewer:
    PUBNUB.events.bind('arb_html', function(data) {
      $("#content").remove();
      $("#viewer_box").append("<div id='content'>"+ data.html + "</div>");
    });

Now you can copy and paste any embed code and have it pushed out to your viewers in real time: Google Maps, SoundCloud, you name it!




