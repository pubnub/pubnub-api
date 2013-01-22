(function(){

var output = PUBNUB.$('output')
,   pubnub = PUBNUB.init({ subscribe_key : 'demo' });

pubnub.subscribe({
    channel  : 'my_browser_channel',
    callback : function(message) {
        output.innerHTML = [
            message, '<br>', output.innerHTML
        ].join('');
    }
});

})();
