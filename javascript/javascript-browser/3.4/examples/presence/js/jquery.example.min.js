/*
 * jQuery Form Example Plugin 1.6.0
 * Populate form inputs with example text that disappears on focus.
 *
 * e.g.
 *    $('input#name').example('Bob Smith');
 *    $('input[@title]').example(function () {
 *        return $(this).attr('title');
 *    });
 *    $('textarea#message').example('Type your message here', {
 *        className: 'example_text'
 *    });
 *
 * Copyright (c) Paul Mucur (http://mudge.name), 2007-2012.
 * Dual-licensed under the BSD (BSD-LICENSE.txt) and GPL (GPL-LICENSE.txt)
 * licenses.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.    See the
 * GNU General Public License for more details.
 */(function(a){"use strict";var b;a.fn.on?b=function(b,c,d){a("body").on(c,b,d)}:a.fn.delegate?b=function(b,c,d){a("body").delegate(b,c,d)}:a.fn.live?b=function(b,c,d){a(b).live(c,d)}:b=function(b,c,d){a(b).bind(c,d)},a.fn.example=function(c,d){var e=a.isFunction(c),f=a.extend({},d,{example:c});return this.each(function(){var c,d=a(this);a.metadata?c=a.extend({},a.fn.example.defaults,d.metadata(),f):c=a.extend({},a.fn.example.defaults,f),a.fn.example.boundClassNames[c.className]||(a(window).bind("unload.example",function(){a("."+c.className).val("").removeClass(c.className)}),b("form","submit.example example:resetForm",function(){a(this).find("."+c.className).val("").removeClass(c.className)}),a.fn.example.boundClassNames[c.className]=!0),d.val()!==this.defaultValue&&(e||d.val()===c.example)&&d.val(this.defaultValue),d.val()===""&&!d.is(":focus")&&d.addClass(c.className).val(e?c.example.call(this):c.example),d.bind("focus.example",function(){a(this).is("."+c.className)&&a(this).val("").removeClass(c.className)}).bind("change.example",function(){a(this).is("."+c.className)&&a(this).removeClass(c.className)}).bind("blur.example",function(){a(this).val()===""&&a(this).addClass(c.className).val(e?c.example.call(this):c.example)})})},a.fn.example.defaults={className:"example"},a.fn.example.boundClassNames=[]})(jQuery);
