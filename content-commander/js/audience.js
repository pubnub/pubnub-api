(function(){

function inject(msg){
      console.log("msg arrived!")
      $(".sub-display").append(msg["element"]);
}

PUBNUB.subscribe({
  channel      : 'content-commander',
  callback     : inject 
});

})();
