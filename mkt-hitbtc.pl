#!/usr/local/bin/perl

#-------------------------------------------------------------------------------
# fetch HITBTC quote for specified symbol

sub hitbtc_fetch_quote(@) {
    foreach my $x (@_) {
	my $symbol = $x; # do not modify array element
	if ($symbol !~ m!/!) {
	    $symbol .= "/USD";
	}
	if (!get_quote($symbol)) {
	    my $querysym = $symbol;
	    $querysym =~ s!/!!;	# BTC/USD -> BTCUSD
	    my $obj=fetch_json("https://api.hitbtc.com/api/2/public/ticker/$querysym");
	    def_exchange($symbol, $obj->{last}, $obj->{timestamp}, $obj->{comment});
	}
    }
}

1;
