(function(){

PUBNUB.subscribe({
  channel      : 'content-commander',
  callback     : function(msg){$(".sub-display").append("<h1>"+msg["nihao"]+"</h1>");}
});

})();
