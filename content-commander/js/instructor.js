(function(){

// bind click handler on #publish button
$("#publish").click(function(){
  $.PUBNUB.publish({
    channel:   'content-commander',
    message:   {"element" : $("#pub-element").val()} 
  });
});

$(".media-option").click(function(){
    $(this).addClass("active");
    $(this).click(function(){
        $(this).removeClass("active");
    });
});



})();
