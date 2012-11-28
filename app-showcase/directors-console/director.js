(function(){

    var p       = PUBNUB.init({ publish_key: 'demo', subscribe_key : 'demo' })
    ,   channel = 'my_channel'
    ,   btn     = {
        image : p.$('image'),
        video : p.$('video'),
        html  : p.$('html')
    };

    function bind(button) {
        p.bind( 'mousedown,touchstart', button, function() {
            send(p.attr( button, 'source' ));
        } );
    }

    bind(btn.image);
    bind(btn.video);
    bind(btn.html);

    function send(data) {
        p.publish({
            channel : channel,
            message : data
        });
    }

    p.subscribe({
        channel  : channel,
        callback : function(message) {
            output.innerHTML = message;
            animate();
        }
    });

    function animate() {
        p.css( output, { background: "#eef66c" } );
        setTimeout( function() {
            p.css( output, { background: "#fff" } );
        }, 500 );
    }

})();
