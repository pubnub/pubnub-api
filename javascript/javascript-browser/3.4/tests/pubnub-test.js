var REPL = /{([\w\-]+)}/g
,    p    = PUBNUB
,    each = p.each;

p.supplant = function supplant( str, values ) {
    return str.replace( REPL, function( _, match ) {
        return values[match] || _
    } );
}
p.$    = function $(id) { return document.getElementById(id) };
p.attr = function attr( node, attribute, value ) {
    if (value) node.setAttribute( attribute, value );
    else return node && node.getAttribute && node.getAttribute(attribute);
};
p.create = function create(element) {
    return document.createElement(element)
};
p.css = function css( element, styles ) {
    for (var style in styles) if (styles.hasOwnProperty(style))
        try {element.style[style] = styles[style] + (
            '|width|height|top|left|'.indexOf(style) > 0 &&
            typeof styles[style] == 'number'
            ? 'px' : ''
        )}catch(e){}
};

p.bind = function bind( type, el, fun ) {
    each( type.split(','), function(etype) {
        var rapfun = function(e) {
            if (!e) e = window.event;
            if (!fun(e)) {
                e.cancelBubble = true;
                e.returnValue  = false;
                e.preventDefault && e.preventDefault();
                e.stopPropagation && e.stopPropagation();
            }
        };

        if ( el.addEventListener ) el.addEventListener( etype, rapfun, false );
        else if ( el.attachEvent ) el.attachEvent( 'on' + etype, rapfun );
        else  el[ 'on' + etype ] = rapfun;
    } );
};

var many_con_tst = 'opera' in window ? -1 : 10
,   channel      = 'pn-javascript-unit-test'
,   out          = p.$('unit-test-out')
,   test_tpl     = p.$('test_template').innerHTML
,   start_button = p.$('start-test')
,   stop_button  = p.$('stop-test')
,   status_area  = p.$('test-status')
,   status_tpl   = p.attr( status_area, 'template' );

/* ======================================================================
Stop Test
====================================================================== */
p.bind( 'mousedown,touchstart', stop_button, stop_test );
function stop_test() {
    p.css( start_button, { display : 'inline-block' } );
    p.css( stop_button, { display : 'none' } );
    test.run = 0;
}

/* ======================================================================
Start Test
====================================================================== */
p.bind( 'mousedown,touchstart', start_button, start_test );
function start_test() {
    test.plan = 43 + many_con_tst*3; // # of tests
    test.done = 0;  // 0 tests done so far
    test.pass = 0;  // 0 passes so far
    test.fail = 0;  // 0 failes so far
    test.run  = 1;  // continue running?

    p.css( stop_button, { display : 'inline-block' } );
    p.css( start_button, { display : 'none' } );
    p.css( p.$('finished-fail'), { display : 'none' } );
    p.css( p.$('finished-success'), { display : 'none' } );

}
function test( t, msg ) {
    if (!test.run) return;

    var entry = p.create('tr');

    entry.innerHTML = p.supplant( test_tpl, {
        result  : t ? 'success' : 'important',
        display : t ? 'pass'    : 'fail',
        message : msg
    } );

    t ? test.pass++ : test.fail++;
    test.done++;

    out.insertBefore( entry, out.firstChild );
    console.log( t, msg );

    status_area.innerHTML = p.supplant( status_tpl, {
        pass  : test.pass+'',
        fail  : test.fail+'',
        total : test.done+''
    } );

    if (test.done === test.plan) {
        stop_test();
        test.fail ||
        p.css( p.$('finished-success'), { display : 'inline-block' } ) &&
        p.css( p.$('finished-fail'), { display : 'inline-block' } );
    }
}


