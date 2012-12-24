(function(){

    var p       = PUBNUB.init({ publish_key: 'demo', subscribe_key : 'demo' })
    ,   channel = 'my_directors_channel';

    p.bind( 'mousedown,touchstart', p.$('buttons'), function(e) {
        var target = e.target || e.srcElement;
        send(
            p.attr( target, 'source' ) ||
            p.attr( target.parentNode, 'source' )
        );
    } );

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
