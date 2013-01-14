(function(){

function inject(msg){
      $(".sub-display").append(msg["element"]);
}

PUBNUB.subscribe({
  channel      : 'content-commander',
  callback     : inject 
});

})();
