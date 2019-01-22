#!/usr/local/binperl

#-------------------------------------------------------------------------------
# convert IEX timestamp to ISO 8601 form
sub iex_timestamp_str($){
    my @ltime=gmtime($_[0]/1000);
    my $str= strftime("%Y-%m-%dT%H:%M:%S",@ltime);
    $str .= "." . ($_[0]%1000) . "Z";
    return $str;
}

#-------------------------------------------------------------------------------

my @iexsyms;
sub iex_begin_fetch($) {
    push(@iexsyms,$_[0]);
}

#-------------------------------------------------------------------------------

sub iex_end_fetch {
    if (scalar(@iexsyms)>0){
	my $symbol = join(",",@iexsyms);
	my $obj=fetch_json("https://ws-api.iextrading.com/1.0/stock/market/batch?symbols=$symbol&types=quote&range=1m");
	foreach my $symbol(sort keys %$obj){
	    if ($obj->{$symbol}){
		my $quote=$obj->{$symbol}->{quote};
		def_exchange("$symbol/USD", $quote->{latestPrice}, iex_timestamp_str($quote->{latestUpdate}), $obj->{comment});
	    }
	}
    }
}

1;
