#!/bin/bash

## ------------------------------------------------
## PubNub 3.1 Real-time Cloud Push API - JAVASCRIPT
## ------------------------------------------------

## ----------------------------------------------------
##
## TESTLING - PubNub JavaScript API for Web Browsers
##            uses Testling Cloud Service
##            for QA and Deployment.
##
## http://www.testling.com/
## You need this to run './test.sh' unit test.
##
## ----------------------------------------------------

if [ -z "$1" ]
then
    echo -e "\n\tUSER:PASSWD Required: http://testling.com/\n"
    exit
fi

browsers='chrome/13.0,firefox/3.6,iexplore/8.0,iexplore/9.0'
noinstrument='pubnub-3.1.js'

tar -cf- test.js pubnub-3.1.js | \
    curl -u $1 -sSNT- \
    "testling.com/?noinstrument=$noinstrument&browsers=$browsers"

