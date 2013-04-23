# PubNub HTML5 Guide

CSS and DOM rendering is the slowest part of a
website 900-5000ms depending on speed of system.
And then consider a High DB Access pages,
which take 1-5 seconds to complete on the server side.
That's around 10+ seconds in the worst case.  Eeeek.
You must reduce DOM/CSS parse time to < 1 second.

## Responsive Design:

Required to auto changing to screen size and mobile devices.
So for example, Mobile devices will show the content
that is best for the smaller screens.
While larger screens will show the full experience.

## Forbidden

jQuery and other JavaScript frameworks are **FORBIDDEN**.
Prohibited.  You man not use JavaScript frameworks other than `PUBNUB`.

## New CSS/HTML5 Requirement Additions:

 1. All Selectors must use `.class-name` or `#id-name`.
 2. Keep number of `.class-name` references to a minimum.
 3. No other selectors allowed unless there is no choice.
 4. This means to exclude div, em, span, etc. except
    for reseting default fonts and global controls.
 5. *No cascading* selectors are allowed unless a large amount
    of computed inheritance will reduce repeated text significantly.
 6. Keep DOM Node count to a minimum.
 7. A single DOM node is considered `<div></div>` and also `<a></a>`.
 8. No more than 1000 nodes per page is the goal.
 9. Unique style nodes such as `blockquote`, `strong`, `em`, `textarea`,
    `h1`, `h2`, etc. are okay to use as selectors without classes.
 10. Other nodes which do no appear frequently
    are also okay to use as selectors.

Follow these examples. Use only the GOOD CSS Selectors:

### GOOD (Fastest to slowest):

 - `#status-area {}`
 - `#user-actions {}`
 - `textarea {}`
 - `blockquote {}`
 - `h1 {}`
 - `h2 {}`
 - `.star-pubnub {}`
 - `.pubnub-link {}`
 - `.pubnub-link:hover {}`

### BAD:

 - `a.footer-links {}`
 - `#left-column div em {}`
 - `input.competitor {}`
 - `blockquote.fluffed-muffed {}`
 - `.star-ratings .star-enabled {}`
 - `div.client-sent-events {}`
 - `li div em a tr td {}`
 - `html body div em {}`
 - `h1.lame {}`

### More Requirements for PubNub HTML5 Guide:

 - 100% A-Grade Browser Compliant
 - 100% Mobile Compliant.
 - Do not use CSS `<!-- Flow Control -->` Comments.
 - NO Tags such as `<!--[if IE 5]><![endif]-->` must not be used.
 - NO Conditional CSS.
 - All A-Grade Browsers must be supported.
 - Fully Liquid HTML5
 - Use Blocks (display: block;) for layout and
 - Lists are for single dimensional data.
 - Tables only for two dimensional data such as message inbox.
 - All buttons and links must be resizable to support multiple languages.
 - Ensure HMTL5 is used.
 - Here is an example of the appropriate document header:
     - `<!doctype html>`
 - UTF-8 Charset with Unix Linebreaks
 - Image Maps (CSS Sprites)
 - All page design assets must fit inside exactly 1-2 PNG Image files.
 - Use PNG-24.
 - Use Choose Either Interlaced or
 - Progressive based on smallest file size.
 - If there is little difference in size, prefer Interlaced.
 - No Images with embedded binary (like pre-rendered text).
 - No design assets may contain text, ever (not images with text).

## Fluid Buttons

Keeping in the spirits of a fully fluid page design,
all buttons and expandable assets must be able
to fit variable amounts of browser rendered text.
Use `display:inline-block` CSS for Buttons.

 - Example: `<div class="expandable-button">Real-time Button</div>`
 - Example: `<ul class="main-navigation"> <li>Real-time Economy</li> </ul>`
 - Example: `<a href="http://pubnub.com/">PubNub</a>`

## Use PEP-8 Coding Conventions

The important conventions are listed here:

 - Code is read more frequently than it is written,
   and therefore needs to be well built.
 - **Use 4 spaces for indentation.**
 - **NO TABS**
 - Use Hyphens in CSS Class Names and Element Tags
     - Example: `<div id="my-div" class="top-nav"></div>`
 - Use Underscores in Form Element Names.
     - Example: `<input type="text" id="first-last" name="first_last">`
 - Do no use Tabs Anywhere.
 - Avoid trailing forward slashes for self closing html elements.
 - Do not exceed 79 Characters per Row of Text.
 - 79 char columns max.

# PubNub HTML5 Modern JavaScript Library

For a faster PubNub load, use the PubNub HTML5 Modern JavaScript
Library which is `CommonJS` and HTML5 `WebWorker` Ready.

DOWNLOAD: [PubNub Modern JavaScript Lib
](https://github.com/pubnub/pubnub-api/tree/master/javascript-modern)

#### Supported Browsers:

 - firefox/3.6'
 - firefox/9.0'
 - firefox/10.0'
 - chrome/16.0'
 - chrome/17.0'
 - iexplore/9.0'
 - safari/5.1'

```html
<script src=pubnub-3.1.js></script>
<script>(function(){
    // ----------------------------------
    // INIT PUBNUB
    // ----------------------------------
    var pubnub = PUBNUB.init({
        publish_key   : 'PUBLISH_KEY_HERE',
        subscribe_key : 'SUBSCRIBE_KEY_HERE',
        ssl           : false,
        origin        : 'pubsub.pubnub.com'
    });

    // ----------------------------------
    // LISTEN FOR MESSAGES
    // ----------------------------------
    pubnub.subscribe({
        restore  : true,
        connect  : send_hello,
        channel  : 'my_channel',
        callback : function(message) {
            console.log(JSON.stringify(message));
        },
        disconnect : function() {
            console.log("Connection Lost");
        }
    });

    // ----------------------------------
    // SEND MESSAGE
    // ----------------------------------
    function send_hello() {
        pubnub.publish({
            channel  : 'my_channel',
            message  : { example : "Hello World!" },
            callback : function(info) {
                console.log(JSON.stringify(info));
            }
        });
    }
})();</script>

```
