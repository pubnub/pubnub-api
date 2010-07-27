(function(){

/* ======================================================================== */
/* ================================ UTILITY =============================== */
/* ======================================================================== */

var db     = this['localStorage']
,   now    = function(){return+new Date}
,   cookie = {
    get : function(key) {
        if (db) return db.getItem(key);
        if (document.cookie.indexOf(key) == -1) return null;
        return ((document.cookie||'').match(
            RegExp(key+'=([^;]+)')
        )||[])[1] || null;
    },
    set : function( key, value ) {
        if (db) return db.setItem( key, value );
        document.cookie = key + '=' + value +
            '; expires=Thu, 1 Aug 2030 20:00:00 UTC; path=/';
    }
},  updater = function( fun, rate ) {
    var timeout
    ,   last    = 0
    ,   runnit  = function() {
        var right_now = now();

        if (last + rate > right_now) {
            clearTimeout(timeout);
            timeout = setTimeout( runnit, rate );
        }
        else {
            last = now();
            fun();
        }
    };

    // Provide Rate Limited Function Call
    return runnit;
};


/* ======================================================================== */
/* ============================= TRAFFIC BEAT ============================= */
/* ======================================================================== */

var PUB              = PUBNUB
,   $                = PUB['$']
,   attr             = PUB['attr']
,   css              = PUB['css']
,   each             = PUB['each']
,   map              = PUB['each']
,   bind             = PUB['bind']
,   create           = PUB['create']
,   supplant         = PUB['supplant']
,   publish          = PUB['publish']
,   subscribe        = PUB['subscribe']
,   history          = PUB['history']
,   interval         = setInterval
,   timeout          = setTimeout
,   href             = this.location.href.slice(-400)
,   config           = $('traffic-beat-2')
,   clear_div        = '<div class="traffic-beat-clear"></div>'
,   sep_div          = '<div class="traffic-beat-sep"></div>'
,   traffic_ui_on    = attr( config, 'interface' ) == 'on'
,   traffic_channel  = attr( config, 'channel' )
,   traffic_interval = +attr( config, 'interval' )
,   traffic_demo     = attr( config, 'demo' )
,   url_limit        = +attr( config, 'url-display-limit' ) || 5
,   ticker_lines     = []  // Array of
,   all_traffic      = {}  // Keyed by URL
,   rpm_traffic      = {}  // Keyed by Timestamp
,   total_traffic    = 0   // ????????
,   new_traffic      = 0;  // ??????

(function(){
    // Page Hit by Real Human.
    function hit(uri) { publish({
        'channel' : traffic_channel,
        'message' : { page : uri }
    }) }

    // Hit the page.
    hit(href);

    // Draw Traffic Beat II User Interface?
    if (!traffic_ui_on) return;


    // TICKER BOX
    (function(){
        var ticker_box   = create('div')
        ,   ticker_count = 68
        ,   ticker_gap   = 6
        ,   ticker_speed = 2
        ,   ticker_on    = 'traffic-beat-ticker-line-on'
        ,   ticker_off   = 'traffic-beat-ticker-line-off'
        ,   box_on       = 'traffic-beat-ticker-line-box-highlight'
        ,   box_off      = 'traffic-beat-ticker-line-box';

        // Init Ticker Array
        attr( ticker_box, 'class', box_off );
        config.appendChild(ticker_box);
        for (var i = 0; i < ticker_count; i++) {
            var div = create('div');
            div.left = i * ticker_gap;
            attr( div, 'class', ticker_off );
            css( div, { 'left' : div.left } );
            ticker_lines.push(div);
            ticker_box.appendChild(div);
        };

        // Draw Ticker
        interval( function() {
            for (var n = 0, tick; n < ticker_count; n++) {
                tick = ticker_lines[n];

                // Update Tick Position Var
                tick.left -= ticker_speed;

                // Tick has reached the end, put back at beggining
                if (tick.left < -ticker_gap) {
                    tick.left = ticker_gap * ticker_count -
                              (ticker_gap + ticker_speed);

                    // Darken Ticker Box
                    if (ticker_box.highlight) {
                        ticker_box.highlight = 0;
                        attr( ticker_box, 'class', box_off );
                    }

                    // Was there Traffic?
                    if (new_traffic > 0) {
                        // Highlight Ticker Box
                        ticker_box.highlight = 1;
                        attr( ticker_box, 'class', box_on );

                        // Reduce New Tick Count
                        new_traffic--;

                        // Activate a Ticker
                        attr( tick, 'class', ticker_on );
                        tick.on = 1;
                    }
                    else if (tick.on) {
                        // De-activate a Ticker
                        attr( tick, 'class', ticker_off );
                        tick.on = 0;
                    }
                }

                css( tick, { 'left' : tick.left } );
            }
        }, traffic_interval );
    })();


    // LONG GRAPH
    (function(){
        var todo;

        // Init Long Graph

        // Draw Long Graph
        interval( function() {
            
        }, 10000 );
    })();


    // RPMs
    var rpm_updater;
    (function(){
        // Init RPMs
        var rpm_div_instant = create('div')
        ,   rpm_div_10_min  = create('div')
        ,   rpm_div_60_min  = create('div')
        ,   rpm_box_class   = 'traffic-beat-bar-box'
        ,   rx_text         = /></
        ,   rpm_text_speed  = '<div class="traffic-beat-bar-text-rpm"></div>'
        ,   rpm_text_title  = '<div class="traffic-beat-bar-text"></div>'
        ,   rpm_bar = '<div class="traffic-beat-bar">' +
                      '<div class="traffic-beat-bar-shine"></div></div>';

        // Add Class to each box
        attr( rpm_div_instant, 'class', rpm_box_class );
        attr( rpm_div_10_min, 'class', rpm_box_class );
        attr( rpm_div_60_min, 'class', rpm_box_class );

        // Add RPM Trackers To Display
        config.appendChild(rpm_div_instant);
        config.appendChild(rpm_div_10_min);
        config.appendChild(rpm_div_60_min);

        // Function is called to update
        function update_rpm_box( div, rpm, title ) {
            // Draw
            div.innerHTML = [
                rpm_text_speed.replace( rx_text, ">"+rpm+"<" ),
                rpm_text_title.replace( rx_text, ">"+title+"<" ),
                (new Array(1+Math.ceil(rpm))).join(rpm_bar) || rpm_bar,
                clear_div
            ].join('');
        }

        // Draw RPMs
        rpm_updater = updater( function() {
            var rpm_instant = 0
            ,   rpm_10_min  = 0
            ,   rpm_60_min  = 0
            ,   right_now   = now()
            ,   max_history = 3610;

            // Calculate hits over last
            for (var timestamp in rpm_traffic) {
                var time_diff = (right_now - timestamp) / 1000;

                // Remove Old Data from Memory.
                if (max_history < time_diff ) {
                    delete rpm_traffic[timestamp];
                    continue;
                }

                // Increment Counter for last minute.
                if (61 > time_diff ) rpm_instant++;

                // Increment Counter for last 10 minutes.
                if (601 > time_diff ) rpm_10_min++;

                // Increment Counter for last 10 minutes.
                if (3601 > time_diff ) rpm_60_min++;
            }

            // Update RPMs Over 1 Minute
            rpm_10_min /= 10;
            rpm_60_min /= 60;

            // Run RPM Update on each Box
            update_rpm_box( rpm_div_instant, rpm_instant, "RPM Instant" );
            update_rpm_box( rpm_div_10_min, rpm_10_min, "10 Minute Average" );
            update_rpm_box( rpm_div_60_min, rpm_60_min, "60 Minute Average" );
        }, 500 );

        interval( rpm_updater, 2000 );
    })();


    // DEMO Enabled?
    if (traffic_demo) {
        interval( function() {
            timeout( function() {
                hit(href+"#"+Math.ceil(Math.random()*url_limit));
            }, Math.ceil(Math.random()*6000+600) );
        }, 1000 );
    }


    // PERCENT URL BARS
    var url_percent_updater;
    (function(){
        var url_bars_div    = create('div')
        ,   url_bars_buffer = []
        ,   url_meter       = '<div class="traffic-beat-percent' +
                              '-bar-meter" style="width:{percent}%"></div>'
        ,   url_shine       = '<div class="traffic-beat-percent' +
                              '-bar-shine"></div>'
        ,   url_text        = '<div class="traffic-beat-percent' +
                              '-bar-text-url">{text}</div>'
        ,   url_percent     = '<div class="traffic-beat-percent' +
                              '-bar-text-percent">{count} ({percent}%)</div>';

        // Append Div for URL Update Reference
        config.appendChild(url_bars_div);

        // Add URL Bar
        function buffer_url_percent_bars( url, percent, count ) {
            // Percentage
            percent = Math.ceil(percent * 100);
            percent = percent > 90 ? 90 : percent;
            percent = percent < 6  ? 6  : percent;

            url_bars_buffer.push(
                '<div class="traffic-beat-percent-bar" ',
                'onmouseup="location.href=\'',url,'\'">',
                url_shine,
                supplant( url_text, {
                    'text' : '/' + url.split('/').slice(3)
                                   .join('/').substr( 0, 60 )
                } ),
                supplant( url_percent, {
                    'percent' : percent,
                    'count'   : count
                } ),
                supplant( url_meter, { 'percent' : percent } ),
                clear_div,
                '</div>'
            );
        }

        // Create Updater Interface (Rate Limit Updates)
        url_percent_updater = updater( function() {
            var url_pos     = 0
            ,   the_traffic = [];

            // Clear Old URL Listing
            url_bars_buffer = [];

            // Append Sep
            url_bars_buffer.push(sep_div);

            // Capture as Array for Sorting
            each( all_traffic, function( page, info ) {
                the_traffic.push({
                    page : page,
                    count : info.count,
                    time : info.time
                });
            } );

            // Sort Most Recent Updated Page
            the_traffic.sort(function( a, b ) {
                var diff = b.time - a.time;
                if (!diff) return b.count - a.count;
                return diff;
            });

            // Buffer Draw Percentage Bars
            for (var i = 0, len = the_traffic.length; i < len; i++) {
                // Limit Displayed URLS
                if (url_pos++ > url_limit) continue;

                // Buffer Display HTML
                buffer_url_percent_bars(
                    the_traffic[i].page,
                    the_traffic[i].count / total_traffic,
                    the_traffic[i].count
                );
            }

            // Render Buffered HTML
            url_bars_div.innerHTML = url_bars_buffer.join('');

        }, 1000 );
    })();

    // Listen for Page Hits
    subscribe( { 'channel' : traffic_channel }, function(message) {
        // Update Counters
        new_traffic++;
        total_traffic++;

        // Track Individual Page Counters
        if (!all_traffic[message.page])
            all_traffic[message.page] = { url : message.page, count : 0 };

        all_traffic[message.page].count++
        all_traffic[message.page].time = now();

        // RPM Tracking
        rpm_traffic[now()] = 1;

        // Update URL Posts
        url_percent_updater();

        // Update RPMs
        rpm_updater();
    } );

    history( { 'channel' : traffic_channel, 'limit' : 100 },
    function(messages) { each( messages, function(message) {
        // Update Counters
        total_traffic++;

        // Track Individual Page Counters
        if (!all_traffic[message.page])
            all_traffic[message.page] = { url : message.page, count : 0 };

        all_traffic[message.page].count++
        all_traffic[message.page].time = now();

        // RPM Tracking
        rpm_traffic[now()] = 1;

        // Update URL Posts
        url_percent_updater();

        // Update RPMs
        rpm_updater();
    }) } );

})();


})()
