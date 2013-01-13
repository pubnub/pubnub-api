(function(){

$("#pub-content").click(function(){
  $.PUBNUB.publish({
    channel:   'content-commander',
    message:   {"element" : $("#pub-element").val()} 
  });
});


})();
