(function(){

// bind click handler on #publish button
$("#publish").click(function(){
  $.PUBNUB.publish({
    channel:   'content-commander',
    message:   {"element" : $("#pub-element").val()} 
  });
});

$("#youtube").data("name", "youtube");
$("#flickr").data("name", "flickr");
$("#soundcloud").data("name", "soundcloud");
$("#vimeo").data("name", "vimeo");

$(".media-option").data('toggled',false);

$(".media-option").click(function(){
    $(this).toggleClass("active");
    var state = $(this).data('toggled');   
    $(this).data('toggled', !state); 
    console.log($(this).data("name")+":"+$(this).data("toggled"));
});

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
