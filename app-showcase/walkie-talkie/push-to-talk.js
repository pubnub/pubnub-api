var push_to_talk = function(settings) {

    // -----------------------------------------------------------------------
    // PubNub and Internal Variables and PubNub
    // -----------------------------------------------------------------------
    var p = PUBNUB.init({
        publish_key   : 'ea1afbc1-70a3-43c1-990c-ede5cf65a542',
        subscribe_key : 'e19f2bb0-623a-11df-98a1-fbd39d75aa3f'
    })
    ,   signature     = p.uuid()
    ,   channel       = settings.channel || 'speak'
    ,   voice_streams = {}
    ,   packet        = 1
    ,   transmitting  = false
    ,   intervals     = 40
    ,   sample_rate   = 0
    ,   buffer_delay  = 500
    ,   rec
    ,   transmitting_ival
    ,   stop_transmission  = function(){}
    ,   start_transmission = function(){};

    // -----------------------------------------------------------------------
    // Cross Platform Get Media Device (Microphone Access).
    // -----------------------------------------------------------------------
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

    // -----------------------------------------------------------------------
    // Cross Platform Audio Context
    // -----------------------------------------------------------------------
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

        rec = new Recorder( mediaStreamSource, {
            buffer_size : 1024,
            sample_rate : sample_rate || mediaStreamSource.context.sampleRate,
            channels    : settings.setup.channels || 1,
            bits        : settings.setup.bits     || 16
        } );

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
                        if (data.length < 120) return;

                        send_audio(data);
                        console.log( data.length );
                    };

                    reader.readAsDataURL(blob);
                });
            }, intervals );
        };

    }, function(err) {
        //alert("You Need To Setup Your Browser! (about:flags)",err);
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
                    last = voice.packet;
                    setTimeout( function() {
                        sound.play( signature, voice.data, intervals*4 );
                    }, (intervals*.9) * delay++ );
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
        var push_button = p.$(setup.button)
        ,   button_text = push_button.innerHTML;;

        settings.setup = setup;

        if ('buffer' in setup) buffer_delay = setup.buffer;
        if ('chunk'  in setup) intervals    = setup.chunk;
        if ('sample' in setup) sample_rate  = setup.sample;

        p.bind( 'mousedown,touchstart', push_button, function() {
            start_transmission();
            push_button.innerHTML = 'TRANSMITTING... &#9728;';
        } );

        p.bind( 'mouseup,touchend', push_button, function() {
            stop_transmission();
            push_button.innerHTML = button_text;
        } );

        // Return Standard Controls.
        return {
            stop : function() {
                stop_transmission();
                p.unsubscribe({ channel : channel });
            }
        };
    }

};
