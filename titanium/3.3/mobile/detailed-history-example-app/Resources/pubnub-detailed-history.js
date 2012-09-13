// ----------------------------------
// Detect Platform
// ----------------------------------
var isAndroid = Ti.Platform.osname === 'android';

// ----------------------------------
// INIT PUBNUB
// ----------------------------------
var pubnub = require('pubnub').init({
    publish_key   : 'demo',
    subscribe_key : 'demo',
    ssl           : false,
    origin        : 'pubsub.pubnub.com'
});

// ----------------------------------
// RANDOM COLOR
// ----------------------------------
function rnd_hex(light) { return Math.ceil(Math.random()*9) }
function rnd_color() {
    return '#'+pubnub.map(
        Array(3).join().split(','), rnd_hex
    ).join('');
}

Ti.App.DetailedHistory = function(setup) {

    // ----------------------------------
    // CREATE BASE UI TAB AND ROOT WINDOW
    // ----------------------------------
    var data_window = Ti.UI.createWindow(setup['window']);


    function append_data( message, color ) {
        var row = Ti.UI.createTableViewRow({
            className          : "pubnub_data",
            backgroundGradient : {
                type          : 'linear',
                colors        : [ "#fff", '#eeeeed' ],
                startPoint    : { x : 0, y : 0 },
                endPoint      : { x : 0, y : 70 },
                backFillStart : false
            }
        });

        var label = Ti.UI.createLabel({
            text   : message || "no-message",
            height : (isAndroid) ? '50dp' : 'auto',
            width  : 'auto',
            color  : color || "#111",
            left   : 10,
            font   : { 
                fontSize : (isAndroid) ? '19dp' : 14,
                fontWeight: (isAndroid) ? 'bold' : 'normal'
            }
        });

        row.add(label);
        table.insertRowBefore( 0, row );
    }

    // Detailed history reverse false Button
    var detailed_history_button = Ti.UI.createButton({
        title         : 'Get Detailed History',
        top           : 4,
        right         : 80,
        width         : (isAndroid) ? '180dp' : 180,
        height        : (isAndroid) ? '50dp' : 30,
        borderRadius  : 6,
        shadowColor   : "#001",
        shadowOffset  : { x : 1, y : 1 },
        style         : Ti.UI.iPhone.SystemButtonStyle.PLAIN,
        font          : {
            fontSize   : (isAndroid) ? '18dp' : 16,
            fontWeight : 'bold'
        },
        backgroundGradient : {
            type          : 'linear',
            colors        : [ '#058cf5', '#015fe6' ],
            startPoint    : { x : 0, y : 0 },
            endPoint      : { x : 2, y : 50 },
            backFillStart : false
        }
    }); 
    // Detailed history reverse true Button
    var detailed_history_reverse_button = Ti.UI.createButton({
        title         : 'Get Detailed History Reverse',
        top           : 40,
        right         : 60,
        width         : (isAndroid) ? '230dp' : 230,
        height        : (isAndroid) ? '50dp' : 30,
        borderRadius  : 6,
        shadowColor   : "#001",
        shadowOffset  : { x : 1, y : 1 },
        style         : Ti.UI.iPhone.SystemButtonStyle.PLAIN,
        font          : {
            fontSize   : (isAndroid) ? '18dp' : 16,
            fontWeight : 'bold'
        },
        backgroundGradient : {
            type          : 'linear',
            colors        : [ '#058cf5', '#015fe6' ],
            startPoint    : { x : 0, y : 0 },
            endPoint      : { x : 2, y : 50 },
            backFillStart : false
        }
    }); 
    var channel = Ti.UI.createTextField({
        width       : (isAndroid) ? '75%' : 247,
        height      : (isAndroid) ? '50dp' : 30,
        left        : 4,
        top         : 80,
        color       : "#111",
        clearOnEdit : true,
        value       : setup['channel'],
        border      : 1,
        borderStyle : Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        borderRadius : 4,
        font        : {
            fontSize   : (isAndroid) ? '18dp' : 14,
            fontWeight : 'bold'
        }
    });
    var count   = Ti.UI.createTextField({
        width       : (isAndroid) ? '75%' : 247,
        height      : (isAndroid) ? '50dp' : 30,
        left        : 4,
        top         : 120,
        color       : "#111",
        clearOnEdit : true,
        value       : "Count",
        border      : 1,
        borderStyle : Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        borderRadius : 4,
        font        : {
            fontSize   : (isAndroid) ? '18dp' : 14,
            fontWeight : 'bold'
        }
    });
    var start   = Ti.UI.createTextField({
        width       : (isAndroid) ? '75%' : 247,
        height      : (isAndroid) ? '50dp' : 30,
        left        : 4,
        clearOnEdit : true,
        top         : 160,
        color       : "#111",
        value       : "Start Timestamp",
        border      : 1,
        borderStyle : Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        borderRadius : 4,
        font        : {
            fontSize   : (isAndroid) ? '18dp' : 14,
            fontWeight : 'bold'
        }
    });
    var end = Ti.UI.createTextField({
        width       : (isAndroid) ? '75%' : 247,
        height      : (isAndroid) ? '50dp' : 30,
        left        : 4,
        top         : 200,
        clearOnEdit : true,
        color       : "#111",
        value       : "End Timestamp",
        border      : 1,
        borderStyle : Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        borderRadius : 4,
        font        : {
            fontSize   : (isAndroid) ? '18dp' : 14,
            fontWeight : 'bold'
        }
    });
    var table = Ti.UI.createTableView({
        separatorColor : (isAndroid) ? '#000' : '#fff',
        top            : (isAndroid) ? '240dp' : 240,
        height         : '50%'
    });

    // Append First Row (Blank)
    table.appendRow(Ti.UI.createTableViewRow({
        className : "pubnub_data"
    }));

    // detailed history button Touch
    detailed_history_button.addEventListener( 'touchstart', function(e) {
        var paramobj = {};
        paramobj['channel'] = channel.value;
        paramobj['callback'] = function(message) {
            append_data( JSON.stringify(message), message.color );
        }	
        paramobj.error = function() {
            append_data("Lost connection ... ","#f00");
        }
        if (start.value != "Start Timestamp" && start.value != "") 
            paramobj['start'] = start.value;
        if (end.value != "End Timestamp" && end.value != "") 
            paramobj['end'] = end.value;
        if (count.value != "Count" && count.value != "") 
            paramobj['count'] = count.value;
        else
            paramobj['count'] = 100;
        pubnub.detailedHistory(paramobj);
    });

    // detailed history button reverse  Touch
    detailed_history_reverse_button.addEventListener( 'touchstart', function(e) {
        var paramobj = {};
        paramobj['channel'] = channel.value;
        paramobj['callback'] = function(message) {
            append_data( JSON.stringify(message), message.color );
        }	
        paramobj.error = function() {
            append_data("Lost connection ... ","#f00");
        }
        if (start.value != "Start Timestamp" && start.value != "") 
            paramobj['start'] = start.value;
        if (end.value != "End Timestamp" && end.value != "") 
            paramobj['end'] = end.value;
        if (count.value != "Count" && count.value != "") 
            paramobj['count'] = count.value;
        else
            paramobj['count'] = 100;
        paramobj["reverse"] = "true";
        pubnub.detailedHistory(paramobj);
    });

    data_window.add(channel);
    data_window.add(count);
    data_window.add(start);
    data_window.add(end);
    data_window.add(detailed_history_button);
    data_window.add(detailed_history_reverse_button);
    data_window.add(table);

    this.data_window = data_window;
    this.my_color    = rnd_color();
    this.pubnub      = pubnub;

    return this;
};

