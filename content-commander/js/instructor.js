(function(){
//TODO: show code snippet
//TODO: add font icon for media option  

// bind click handler on #publish button
$("#publish").click(function(){
  $.PUBNUB.publish({
    channel:   'content-commander',
    message:   {"element" : $("#pub-element").val()} 
  });
});

// add name data on media-option button
$("#youtube").data("name", "youtube");
$("#flickr").data("name", "flickr");
$("#soundcloud").data("name", "soundcloud");
$("#vimeo").data("name", "vimeo");

// initialize media-option buttion with toggled false
$(".media-option").data('toggled',false);

// bind click handler on #toggle button  
// change appearence and update data
$(".media-option").click(function(){
    $(this).toggleClass("active");
    var state = $(this).data('toggled');   
    $(this).data('toggled', !state); 
    console.log($(this).data("name")+":"+$(this).data("toggled"));
});

// bind click handler on #search button
$("#search").click(function(){
    var selected = [];
    $(".media-option").each(function(){
        console.log($(this).data("name"));
        if($(this).data("toggled")){
            selected.push($(this).data("name"));    
        }
    });
    console.log("selected is；"+selected);
    searchYoutube();
});

// search_youtube
function searchYoutube(){
    var query = "test";
    query = encodeURIComponent(query);
    var jsonpURL = "http://gdata.youtube.com/feeds/videos?vq="+ query + 
        "&max-results=50&alt=json-in-script&callback=listYoutube";
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src = jsonpURL;
    var head = document.getElementsByTagName("head")[0];
    head.appendChild(script);
}  


})();
function listYoutube(data){
    console.log(data);
} 
