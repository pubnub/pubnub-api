(function(){
//TODO: show code snippet

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
});

})();
