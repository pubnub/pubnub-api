var push_to_talk = (function(){

    var p = PUBNUB.init({
        publish_key   : 'ea1afbc1-70a3-43c1-990c-ede5cf65a542',
        subscribe_key : 'e19f2bb0-623a-11df-98a1-fbd39d75aa3f'
    })
    ,   signature     = p.uuid()
    ,   channel       = 'speak'
    ,   voice_streams = {}
    ,   packet        = 1
    ,   transmitting  = false
    ,   intervals     = 47
    ,   buffer_delay  = 500
    ,   rec
    ,   transmitting_ival
    ,   stop_transmission
    ,   start_transmission;

    function myGetUserMedia( settings, callback, error ) {
        'webkitGetUserMedia' in navigator && navigator.webkitGetUserMedia(
            settings, callback, error
        ) ||
        'mozGetUserMedia'    in navigator && navigator.mozGetUserMedia(
            settings, callback, error
        ) ||
        'msGetUserMedia'     in navigator && navigator.msGetUserMedia(
            settings, callback, error
        ) ||
        'oGetUserMedia'      in navigator && navigator.oGetUserMedia(
            settings, callback, error
        ) ||
        'GetUserMedia'       in navigator && navigator.GetUserMedia(
            settings, callback, error
        ) ||
        'getUserMedia'       in navigator && navigator.getUserMedia(
            settings, callback, error
        );
    }
    window.G = myGetUserMedia;

    function myGetAudioContext() {
        return 'webkitAudioContext' in window && new webkitAudioContext() ||
               'mozAudioContext'    in window && new mozAudioContext()    ||
               'msAudioContext'     in window && new msAudioContext()     ||
               'oAudioContext'      in window && new oAudioContext()      ||
               'AudioContext'       in window && new AudioContext();
    }

    myGetUserMedia( { audio: true }, function(stream) {
        var context = myGetAudioContext();
        var mediaStreamSource = context.createMediaStreamSource(stream);

        rec = new Recorder( mediaStreamSource, { bufferLen : 2048 } );

        function send_audio(data) {
            p.publish({
                channel : channel,
                message : {
                    data      : data,
                    packet    : packet++,
                    signature : signature
                }
            });
        }

        // Stop Sending Voice Data
        stop_transmission = function () {
            transmitting = false;
            clearInterval(transmitting_ival);
            rec.stop();
        };

        // Start Sending Voice Data
        start_transmission = function () {
            if (transmitting) return;

            transmitting = true;
            rec.record();

            transmitting_ival = setInterval( function() {
                rec.exportWAV(function(blob) {
                    rec.clear();

                    var reader = new FileReader();

                    reader.onload = function(e){
                        if (e.target.readyState != FileReader.DONE) return;
                        var data = e.target.result;
                        send_audio(data);
                    };

                    reader.readAsDataURL(blob);
                });
            }, intervals );
        };

    }, function(err) {
        alert("You Need To Setup Your Browser! (about:flags)",err);
    } );

    function now() {return+new Date}

    // Listen for Incoming Audio
    p.subscribe({
        channel  : channel,
        callback : function( voice, envelope ) {
            if (signature == voice.signature) return;

            if (!(voice.signature in voice_streams))
                voice_streams[voice.signature] = [];

            var buffer = voice_streams[voice.signature];

            if (!buffer.length) buffer.first_received = now();
            buffer.push(voice);
            buffer.last_received = now();
        }
    });

    // Play Factory
    setInterval( function() {
        p.each( voice_streams, function( signature, voice_buffers ) {
            if (now() - voice_buffers.first_received < buffer_delay) return;

            var delay = 1
            ,   last  = 0;

            p.each(
                voice_buffers.sort(function(a,b){return a.packet-b.packet}),
                function(voice) {
                    if (voice.packet <= last) return;
                    setTimeout( function() {
                        sound.play( signature, voice.data, intervals );
                    }, (intervals-2) * delay++ );
                }
            );

            delete voice_streams[signature];
        } );
    }, buffer_delay );

    function encode(path) {
        return PUBNUB.map( (encodeURIComponent(path)).split(''),
        function(chr) {
            return "-_.!~*'()".indexOf(chr) < 0 ? chr :
                   "%"+chr.charCodeAt(0).toString(16).toUpperCase()
        } ).join('');
    }

    return function(setup) {
        var push_button = p.$(setup.button);

        if ('buffer' in setup) buffer_delay = setup.buffer;

        p.bind( 'mousedown,touchstart', push_button, function() {
            start_transmission();
        } );

        p.bind( 'mouseup,touchend', push_button, function() {
            stop_transmission();
        } );
    }

})();
