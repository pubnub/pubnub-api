#!/bin/bash

## ------------------------------------------------
## PubNub 3.3 Real-time Cloud Push API - JAVASCRIPT
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

browsers='firefox/3.6'
browsers=$browsers',firefox/9.0'
browsers=$browsers',firefox/10.0'
browsers=$browsers',chrome/16.0'
browsers=$browsers',chrome/17.0'
browsers=$browsers',iexplore/9.0'
browsers=$browsers',safari/5.1'

echo -e "Testing: $browsers"

noinstrument='pubnub-3.3.js'

tar -cf- test.js ../pubnub-3.3.js | \
    curl -u $1 -sSNT- \
    "testling.com/?noinstrument=$noinstrument&browsers=$browsers"

