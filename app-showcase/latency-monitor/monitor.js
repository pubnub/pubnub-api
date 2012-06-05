(function(){

    var p = PUBNUB.init({
        origin        : PUBNUB.$('origin').value,
        publish_key   : 'demo',
        subscribe_key : 'demo'
    }), channel                 = 'latency-' + Math.random()
    ,   avg                     = 1
    ,   median                  = 1
    ,   latest                  = 1
    ,   max                     = 1
    ,   start_time              = 0
    ,   monitor_button          = p.$('start')
    ,   delay                   = p.$('delay')
    ,   blink                   = p.$('latency-bar')
    ,   latency_last            = p.$('latency-last')
    ,   latency_average         = p.$('latency-avg')
    ,   latency_max             = p.$('latency-max')
    ,   latency_results         = []
    ,   latency_results_med     = []
    ,   latency_matrix          = p.$('latency-matrix')
    ,   latency_matrix_template = p.$('latency-matrix-template').innerHTML;

    function range(val) { return Array(val).join(',').split(',') }
    function add_result(ms) {
        latency_results.unshift(ms);
        ms > 10 && latency_results_med.unshift(ms);
        display_latency();
    }
    var display_latency = p.updater( function() {
        calc_median();

        latency_average.innerHTML = median+'ms'
        latency_max.innerHTML     = max+'ms'
        latency_last.innerHTML    = Math.ceil(
            latency_results.length /
            ((+new Date - start_time) / 1000)
        );

        latency_matrix.innerHTML = range(200).map(function( _, n ) {
            var lat   = +(latency_results[n] || 1)
            ,   size  = lat > 1000 ? 99 : lat / 9
            ,   color = Math.floor((size/100) * 10+6);

            return p.supplant( latency_matrix_template, {
                ms    : lat,
                size  : size < 2 ? 2 : size,
                color : color.toString(16) + (16 - color).toString(16) + '0'
            } );
        } ).join('');
    }, 250 );

    var calc_median = p.updater( function() {
        latency_results_med.sort();
        median = latency_results_med[
            Math.floor(latency_results_med.length/2)
        ];
    }, 1000 );

    function set_class( elm, name ) {
        elm.className = name;
        p.attr( elm, 'class', name );
    }

    // Start and Finish Latency Loop
    function finish() {
        var latency = Math.floor((+new Date) - check.start);
        check.start = +new Date;

        avg    = Math.floor((avg + latency) / 2);
        latest = latency;
        max    = latency > max ? latency : max;
        avg    = avg ? avg : 100;

        add_result(latency);

        check.used = 0;
        clearTimeout(check.ival);
        p.css( delay, { opacity : '1' } )
        p.css( blink, { width : '0' } )
    }
    function check() {
        if (check.used) {
            check.start = +new Date;
            clearTimeout(check.ival);
            check.ival = setTimeout( function() {
                if (!monitor_button.running) return;
                p.css( blink, { width : '100%' } );
                p.css( delay, { opacity : '0.1' } )
            }, 25 );
        }
        check.used = 1;
        p.publish({ channel : channel, message : 1, callback : check });
    }

    p.bind( 'click', monitor_button, function() {
        if (monitor_button.running) {
            location.reload();
        } else {
            monitor_button.running = 1;
            set_class( monitor_button, 'btn btn-danger' );

            p = PUBNUB.init({
                origin        : PUBNUB.$('origin').value,
                publish_key   : 'demo',
                subscribe_key : 'demo'
            });

            p.subscribe({
                channel  : channel,
                connect  : check,
                callback : finish
            });

            monitor_button.innerHTML = 'Stop Monitor';
            clearTimeout(check.ival);
            p.css( blink, { width : '0' } )
            check.used = 0;
            start_time = +new Date;
        }
    } );
    
})();
