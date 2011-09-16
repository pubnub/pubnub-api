#!/usr/bin/perl

##
## PubNub - http://www.pubnub.com/
##

## ===========================================================================
## USAGE
## ===========================================================================
##
## bash <(curl http://............) my_channel
## perl <(cat monitor.pl) my_channel
##

use strict;
use warnings;

use LWP::Simple;
use URI::Escape;
use JSON::XS;
use Digest::MD5 qw(md5_hex);

## Load User-specified Namespace
my $namespace = $ARGV[0] || 'demo';
print("Providing Stats on Channel: '$namespace'.\n");

##
## PUBLISH - Publish an update to PubNub
##
## publish( 'my_channel', { data => 'value' } );
##
sub publish {
    my $channel = shift;
    my $message = shift;
    my $json    = uri_escape(JSON::XS->new->encode($message));
    my $req_url = 'http://pubsub.pubnub.com' .
        "/publish/demo/demo/0/$channel/0/$json";

    print("$req_url\n");

    return JSON::XS->new->decode(get($req_url));
}

## ===========================================================================
## System Status Functions
## ===========================================================================
sub proc    {  split( "\n", qx{ cat /proc/stat } )                }
sub mems    { (split( /\s+/, qx{ free -m -o | grep Mem } ))[2..3] }
sub loadavg { (split( /\s+/, qx{ cat /proc/loadavg } ))[0..2]     }


## ===========================================================================
## Prepare Data
## ===========================================================================
my $ip_address = get('http://automation.whatismyip.com/n09230945.asp');
my $os_version = qx{ cat /proc/version };
my $os_sig     = ''.md5_hex($os_version . time());
my @cpu_usage  = proc();
my @mem_usage  = mems();
my @load_avg   = loadavg();


#use Data::Dumper;            ## Dump 
##print(Dumper(@cpu_usage));
#print(Dumper(@load_avg));
#print(Dumper(@mem_usage));
#
#exit(1);

## ============
## Monitor Loop
## ============
while (1) {
    ## Refresh Data
    #@cpu_usage = proc();
    @mem_usage = mems();
    @load_avg  = loadavg();

    ## Send Data to Phone/Browser
    publish( $namespace, {
        ip   => $ip_address,
        sig  => $os_sig,
        load => [0+$load_avg[0], 0+$load_avg[1], 0+$load_avg[2]],
        mem  => [0+$mem_usage[0], 0+$mem_usage[1] ],
    } );

    ## Wait
    sleep(1);
}
