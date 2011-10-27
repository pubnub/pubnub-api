#!/bin/bash

## ------------------------------------------------
## PubNub 3.1 Real-time Cloud Push API - JAVASCRIPT
## ------------------------------------------------

## ----------------------------------------------------
##
## TESTLING.JS - PubNub JavaScript API for Web Browsers
##               uses Testling.JS Cloud Service
##               for QA and Deployment.
##
## http://www.testling.com/ - You need it.
##
## ----------------------------------------------------

if [ -z "$1" ]
then
    echo -e "\n\tPassword Required: http://testling.com/\n"
    exit
fi

browsers='iexplore/8.0,iexplore/9.0,chrome/13.0,firefox/3.6'
noinstrument='pubnub-3.1.js'

tar -cf- test.js pubnub-3.1.js | \
    curl -u stephen@pubnub.com:$1 -sSNT- \
    "testling.com/?noinstrument=$noinstrument&browsers=$browsers"

