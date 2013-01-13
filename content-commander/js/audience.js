(function(){

PUBNUB.subscribe({
  channel      : 'content-commander',
  callback     : function(msg){
      console.log(msg["element"]);
      $(".sub-display").append(msg["element"]);
          }
});

})();
