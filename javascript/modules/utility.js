(function(){

/* ======================================================================== */
/* ================================ UTILITY =============================== */
/* ======================================================================== */

var db     = this['localStorage']
,   PUB    = PUBNUB
,   now    = function(){return+new Date}
,   cookie = {
    get : function(key) {
        if (db) return db.getItem(key);
        if ((document.cookie||'').indexOf(key) == -1) return null;
        return ((document.cookie||'').match(
            RegExp(key+'=([^;]+)')
        )||[])[1] || null;
    },
    set : function( key, value ) {
        if (db) return db.setItem( key, value );
        document.cookie = key + '=' + value +
            '; expires=Thu, 1 Aug 2030 20:00:00 UTC; path=/';
    }
};

function updater( fun, rate ) {
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
}

function mouse(e) {
    if (!e) return [[0,0]];

    var tch  = e.touches && e.touches[0]
    ,   mpos = [];

    if (tch) {
        PUB.each( e.touches, function(touch) {
            mpos.push([ touch.pageX, touch.pageY ]);
        } );
    }
    else if (e.pageX) {
        mpos.push([ e.pageX, e.pageY ]);
    }
    else {try{
        mpos.push([
            e.clientX + body.scrollLeft + doc.scrollLeft,
            e.clientY + body.scrollTop  + doc.scrollTop
        ]);
    }catch(e){}}

    return mpos;
}


/**
 * OFFSET
 * ======
 * offset( search('div')[0], 'Width' );
 * offset( search('div')[0], 'Height' );
 * offset( search('div')[0], 'Top' );
 * offset( search('div')[0], 'Left' );
 */
function offset( node, what ) {
    var pos  = 0
    ,   what = what || 'Top';

    while (node) {
        pos += node['offset'+what];
        node = node.offsetParent;
    }

    return pos
}

/**
 * WINFO
 * =====
 * var window_info = winfot();
 * log(window_info.height);
 */
function winfo() {
    return {
        height    : this.innerHeight ||
                    document.documentElement.clientHeight ||
                    document.body.clientHeight,
        scrollTop : document.documentElement.scrollTop ||
                    document.body.scrollTop,
        size      : offset(search('body')[0], 'Height')
    }
}




// Expose Utility to PUBNUB.
PUB['utility'] = {
    'mouse'   : mouse,
    'winfo'   : winfo,
    'offset'  : offset,
    'now'     : now,
    'cookie'  : cookie,
    'updater' : updater
};


})();
