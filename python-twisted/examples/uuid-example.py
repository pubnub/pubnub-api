## www.pubnub.com - PubNub Real-time push service in the cloud. 
# coding=utf8

## PubNub Real-time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.1 Real-time Push Cloud API
## -----------------------------------

import sys
from twisted.internet import reactor
sys.path.append('../')
from Pubnub import Pubnub

## -----------------------------------------------------------------------
## Initiate Pubnub State
## -----------------------------------------------------------------------
pubnub = Pubnub( "", "", "", False )

## -----------------------------------------------------------------------
## UUID Example
## -----------------------------------------------------------------------

uuid = pubnub.uuid()
print "UUID: "
print uuid
