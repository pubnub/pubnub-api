(function(){

var output = PUBNUB.$('output');

PUBNUB.subscribe({
    channel  : 'my_browser_channel',
    callback : function(message) {
        output.innerHTML = [
            message, '<br>', output.innerHTML
        ].join('');
    }
});

})();
