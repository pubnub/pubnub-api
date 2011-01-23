#!/usr/bin/env perl

use threads;
use threads::shared;
use Pubnub;

my $channel = 'some_unique_channel_perhaps';
my $p = Pubnub->new({
    pubkey => 'demo',
    subkey => 'demo',
}); # defaults to 'demo' channel

# call these on thread, since subscribe() will block
my $th = threads->create('subscribe');
my $th2 = threads->create('publish');
my $th3 = threads->create('history');
$th->join();
$th2->join();
$th3->join();


# called by threads:
sub publish {
    sleep(1); # give subscribe() a head start
    print 'publish(): ',
        $p->publish( { 
            channel=> $channel, 
            message=> 'He said, "helowrld"' 
        }), 
        "\n";
}

sub subscribe {
    print "Started subscribe thread...\n";
    $p->subscribe( {
            channel => $channel, 
            callback => 
                sub { 
                    my $msg = shift; 
                    print "subscribe(): $msg\n"; 
                    return 0; # stop after one message...
                }
        } );
}

sub history {
    sleep(3);
    print 'history(): ',
        $p->history( {
            channel => $channel
        } ), 
        "\n";
}
