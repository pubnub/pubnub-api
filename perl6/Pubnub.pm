class Pubnub {
    method publish(%args) {
        return 1;
    }
}

my $pubnub = Pubnub.new();
my %prr = {{
    test => {
        10
    }
}}();

say %prr<test>();
say $pubnub.publish({});
