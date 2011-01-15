package Pubnub;

use Modern::Perl;
use LWP::Simple;
use URI::Escape;
use JSON;
use Digest::MD5 qw(md5_hex);

our $origin = 'pubsub.pubnub.com';
our $limit = 1800;
our $TRACE = 0;

sub new {

    my $class = shift;
    my $self = {};
    
    $self->{'pubkey'} = shift;
    $self->{'subkey'} = shift;
    $self->{'secret'} = 0;
    $self->{'ssl'} = shift;

    # default to 'demo'
    $self->{'pubkey'} = $self->{'pubkey'} ? $self->{'pubkey'} : 'demo';
    $self->{'subkey'} = $self->{'subkey'} ? $self->{'subkey'} : 'demo';
    
    $self->{'protocol'} = $self->{'ssl'} ? 'https' : 'http';

    bless($self, $class);
    return $self;
        
} # new


sub publish {
    
    my $self = shift;
    my $h = shift;

    die "Required params: \$channel, \$message\n" if 
        !$h->{'channel'} || !$h->{'message'};

    # handle double-quotes in message
    my $esc_msg = $h->{'message'};
    $esc_msg =~ s/"/\\"/g;

    my $url = $self->{'protocol'} . '://' . $origin .
        '/publish' . 
        '/' . $self->{'pubkey'} .
        '/' . $self->{'subkey'} .
        '/0' .                  # TODO sig
        '/' . $h->{'channel'} .
        '/0' .                  # TODO callback 
        '/' . uri_escape('"' . $esc_msg . '"' );

    if (length($h->{'message'}) > $limit) {
        return "[0, 'Message too long.']";
    }

    print "\n\n$url\n\n" if $TRACE;

    return get($url);
    
} # publish


# This is blocking
sub subscribe {
    my $self = shift;
    my $args = shift;

    die "Required params: \$channel, \$callback\n" if 
        !$args->{'channel'} || !$args->{'callback'};
    
    # shorteners
    my $channel   = $args->{'channel'};
    my $callback  = $args->{'callback'};
    my $timetoken = $args->{'timetoken'} ? $args->{'timetoken'} : '0';

    # build URL from params
    my $url = $self->{'protocol'} . '://' . $origin .
        '/subscribe' . 
        '/' . $self->{'subkey'} .
        '/' . $channel .
        '/0' .                  # TODO callback 
        '/' . $timetoken;
   
    my $resp = decode_json(get($url));
    my $messages = $$resp[0];

    $args->{'timetoken'} = $$resp[1] || 0;

    # timeout
    if (!@$messages) { return $self->subscribe($args); }
   
    foreach my $msg (@$messages) {
        return if !&$callback($msg); # user cancels
    }
    
    return $self->subscribe($args);

} # subscribe


sub history {
    my $self = shift;
    my $h = shift;

    die "Required params: \$channel\n" if !$h->{'channel'};

    my $total = $h->{'limit'} ? $h->{'limit'} : 10;

    my $url = $self->{'protocol'} . '://' . $origin .
        '/history' .
        '/' . $self->{'subkey'} .
        '/' . $h->{'channel'} .
        '/0' .                  # TODO callback
        '/' . $total;

    return get($url);

} # history

1;

__END__
Copyright (c) 2010 CompletelyPrivateFiles.com, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
