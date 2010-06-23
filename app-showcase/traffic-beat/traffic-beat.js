(function(){

/*
    PubNub Real Time Push APIs and Notifications Framework
    Copyright (c) 2010 Stephen Blum
    http://www.google.com/profiles/blum.stephen

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*

<!--
    WAIT! - This file depends on the PUBNUB API.
    Visit www.pubnub.com to get your API Key and integration.

    To add on your website, go here:
    http://www.pubnub.com/app-showcase/traffic-beat

    View source code by visiting:
    http://github.com/pubnub/PubNub-Traffic-Beat

    Traffic Beat is small widget which allows you to watch
    live human traffic on your website in real time.

    Traffic Beat
    ============
    PUT <STYLE> inside <HEAD>
    PUT <DIV> inside <BODY> 
    PUT <SCRIPT> at VERY BOTTOM

    Make sure to read the config below.
-->

<style>
#traffic-beat{display:none;background:#e3f3fe;-moz-border-radius:10px;-webkit-border-radius:10px;padding:10px}

#traffic-beat,
.traffic-beat-row-num,
.traffic-beat-row{text-shadow:1px 1px 1px #aaa;color:#444;font-weight:bold;line-height:20px;font-size:11px}

#traffic-beat-rpm{font-size:12px;color:#fff;font-weight:bold;float:left;padding-left:4px}
#traffic-beat-ticker{height:18px;width:1px;background:#ff9000}
#traffic-beat-striker{background:#fff;-moz-border-radius:5px;-webkit-border-radius:5px;padding:10px;margin:10px;height:30px}

.traffic-beat-clear{clear:both}
.traffic-beat-graph{height:12px;background:#ba7f32}
.traffic-beat-row{padding:4px}
.traffic-beat-row-num{padding:4px}

.traffic-beat-striker-tick{float:left;width:2px;height:30px;border-top:2px solid #fff}
.traffic-beat-striker-tick-on{background:#ff9000;width:7px;border-top:2px solid red}
.traffic-beat-striker-tick-off{background:#bbb;width:7px}
</style>

<!--
    CONFIG
    ======
    traffic-beat-interface="on"      ## Show Interface?
    traffic-beat-channel="default"   ## Which Channel?
    traffic-beat-max-pages="5"       ## Number of Pages
    traffic-beat-striker-width="9"   ## Width of Animated Graph
    traffic-beat-striker-speed="300" ## Animated Graph Speed
-->
<div id="traffic-beat"
traffic-beat-interface="on"
traffic-beat-channel="default1"
traffic-beat-max-pages="5"
traffic-beat-striker-width="30"
traffic-beat-striker-speed="120"
>
<div id="traffic-beat-info">
<a href="http://www.pubnub.com/">Traffic Beat (Live Human Traffic)</a></div>
<div id="traffic-beat-striker"></div>
<div class="traffic-beat-clear"></div>
<div id="traffic-beat-rpm"></div>
<div id="traffic-beat-ticker"></div>
<div class="traffic-beat-clear"></div>
<div id="traffic-beat-table"></div>
<div id="traffic-beat-total"></div>
<div id="traffic-beat-last"></div>
<div id="traffic-beat-start"></div>
</div>

*/


var PUB             = PUBNUB
,   $               = PUB['$']
,   attr            = PUB['attr']
,   each            = PUB['each']
,   map             = PUB['each']
,   bind            = PUB['bind']
,   publish         = PUB['publish']
,   subscribe       = PUB['subscribe']
,   history         = PUB['history']
,   traffic_beat    = 'traffic-beat'
,   href            = this.location.href.slice(-400)
,   config          = $(traffic_beat)
,   all_traffic     = {}
,   total_traffic   = 0
,   new_traffic     = 0
,   traffic_striker = []
,   striker_update  = 0
,   striker_speed   = config&&+attr(config,traffic_beat+'-striker-speed')||350
,   striker_width   = config && +attr(config,traffic_beat+'-striker-width')||25
,   traffic_channel = config && attr( config, traffic_beat + '-channel' )
,   traffic_ui_on   = config && attr(config,traffic_beat+'-interface') == 'on'
,   max_page_cnt    = config && +attr(config,traffic_beat+'-max-pages') || 5
,   html            = function( node, html ) {node && (node.innerHTML = html)}
,   now             = function() {return+new Date}
,   start_time      = now()
,   last_visitor    = start_time
,   jsdate          = function(date) {return (date+'').split(' ')[4]}
,   info            = $(traffic_beat + '-info')
,   ticker          = $(traffic_beat + '-ticker')
,   rpm             = $(traffic_beat + '-rpm')
,   start           = $(traffic_beat + '-start')
,   last            = $(traffic_beat + '-last')
,   table           = $(traffic_beat + '-table')
,   total           = $(traffic_beat + '-total')
,   rd              = '<tr><td class="traffic-beat-row">'
,   ed              = '</td><td class="traffic-beat-row-num">'
,   erd             = '</td></tr>'
,   gwidth          = 1.4
,   rwidth          = 20
,   TB              = {
    init : function() {
        // Inform of Page Hit by Real Human.
        publish({
            'channel' : traffic_channel,
            'message' : {
                'page' : href,
                'time' : now()
            }
        });

        // Setup Traffic Beat UI if Enabled.
        if (!(traffic_ui_on && config)) return;

        // Show UI
        config.style.display = 'block';

        // Listen for New Human Traffic
        subscribe( { 'channel' : traffic_channel },
        function(message) {
            TB.build([message]);
        } );

        // Load History
        history( { 'channel' : traffic_channel, 'limit' : 100 },
        function(messages) {
            TB.build(messages);
            striker_update = 2;
            new_traffic = 2;
        } );
    },

    // Update UI
    build : function(messages) {
        var trtd         = []
        ,   req_per_min  = 0
        ,   the_traffic  = []
        ,   tickwidth    = 0
        ,   elapsed_min  = 0
        ,   new_messages = messages.length
        ,   page_cnt     = 0;

        // Show Start and Last Visitor Times
        last_visitor = now();
        if (new_messages)
            html( last, 'Last Visitor: ' +  jsdate(new Date(last_visitor)) );

        // Count URLs and Store in Hash
        each( messages, function(message) {
            var page = message['page']
            ,   time = message['time'];

            if (!(page in all_traffic)) all_traffic[page] = { count : 0 };

            // Update Traffic Striker Tick
            striker_update++;

            // Increment Traffic Counts
            total_traffic++;
            new_traffic++;
            all_traffic[page].count++;
            all_traffic[page].time = time;

            // Capture Oldest Start Time
            //if (start_time > time) start_time = time;
        } );

        // Show Start Time
        // html( start, 'First Visitor: ' + jsdate(new Date(start_time)) );

        // Show Total Traffic
        html( total, 'Latest Visits: ' + total_traffic );

        // Calculate Requests Per Minute
        elapsed_min = (last_visitor - start_time) / 60000;
        //elapsed_min = elapsed_min > 60 ? 60 : elapsed_min;
        req_per_min = Math.ceil(new_traffic / (
            elapsed_min
        ) * 10000 ) / 10000;
        html( rpm, req_per_min + 'rpm' );

        // Update Ticker
        tickwidth = Math.ceil(req_per_min * rwidth);
        tickwidth = tickwidth > 300 ? 300 : tickwidth;
        ticker.style.width = tickwidth + 'px';

        // Leave if no new messages
        if (!new_messages) return;

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

        // Build URI Table
        each( the_traffic, function( hit ) {
            var page  = hit.page
            ,   count = hit.count;

            // Don't go over max page count
            if (++page_cnt > max_page_cnt) return;

            trtd.push(
                rd,
                '<div title="',page,'" alt="',page,'">',
                '<a href="',page,'">/',
                page.split('/').slice(3).join('/').slice( 0, 25 ),
                '</a></div>',
                ed,
                count,
                ed,
                Math.ceil((count / total_traffic) * 100),
                '%',
                ed,
                '<div class="traffic-beat-graph" style="width:',
                Math.ceil((count / total_traffic) * 100) * gwidth,
                'px">&nbsp;',
                '</div>',
                erd
            );
        } );

        // Update URI Table
        html( table, '<table>'+trtd.join('')+'</table>' );
    }
};

// Set Interval for Updating Striker Tick
traffic_ui_on && (function(){
    var sc          = 'traffic-beat-striker-tick'
    ,   scon        = 'traffic-beat-striker-tick-on'
    ,   scoff       = 'traffic-beat-striker-tick-off'
    ,   striker     = $(traffic_beat + '-striker')
    ,   striker_x   = '<div class="'+sc+'"></div>'
    ,   striker_on  = '<div class="'+sc+' '+scon+'"></div>'
    ,   striker_off = '<div class="'+sc+' '+scoff+'"></div>'
    ,   rnd         = function(){return Math.ceil(Math.random()*2000)};

    setInterval( function() {
        // Init Traffic Beat Striker (if needed)
        if (!traffic_striker.length) {
            for (var a=[];striker_width>0;striker_width--) a.push(1);
            each( a, function() {
                traffic_striker.push( '', '' );
            } );
        }

        // Remove Front Tail
        traffic_striker.shift();
        traffic_striker.shift();
        if (rnd() % 10) {
            traffic_striker.shift();
            traffic_striker.push(striker_x);
        }

        // Add New
        if (striker_update) {
            striker_update--;
            traffic_striker.push( striker_x, striker_on );
        }
        else {
            traffic_striker.push( striker_x, striker_off );
        }

        if (!(rnd() % 4)) TB.build([]);

        // Update Screen
        html( striker, traffic_striker.join('') );
    }, striker_speed );
})();

// Start Traffic Beat
TB.init();

})()
