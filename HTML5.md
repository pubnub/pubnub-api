# PubNub HTML5 Guide

CSS and DOM rendering is the slowest part of a website 900-5000ms depending on speed of system.
And then consider a High DB Access pages,
which take 1-5 seconds to complete on the server side.
That's around 10+ seconds in the worst case.  Eeeek.
You must reduce DOM/CSS parse time to < 1 second.

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

Here are some examples.

### GOOD (fastest to slowest):

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

### Updated requirements regarding PubNub HTML5 requirements:

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

 - Example:  `<div class="expandable-button">Real-time Button</div>`
 - Example: `<ul class="main-navigation"> <li>Real-time Economy</li> </ul>`
 - Example: `<a href="http://pubnub.com/">PubNub</a>`

## Use PEP-8 for coding conventions.

The important conventions are listed here:

 - Code is read more frequently than it is written,
   and therefore needs to be well built.
 - **Use 4 spaces for indentation.**
 - Use Hyphens in CSS Class Names and Element Tags
     - Example: `<div id="my-id-for-a-div"class="top-navigation-thingy"></div>`
 - Use Underscores in Form Element Names.
     - Example: `<input type="text" id="first-and-last" name="first_and_last">`
 - Do no use Tabs Anywhere.
 - Avoid trailing forward slashes for self closing html elements.
 - Do not exceed 79 Characters per Row of Text.
 - 79 char columns max.
