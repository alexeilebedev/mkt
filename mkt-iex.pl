#!/usr/local/binperl
my $iextoken;

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

sub iex_load_token() {
    if (!-f "data/iextoken") {
        print STDERR "file data/iextoken doesn't seem to exist. please register for an IEX cloud account\n"
            ."(it should be free) and place the secret token (starting with sk_) into this file.\n"
            ."Re-run mkt as 'VERBOSE=1 mkt' to see if the token correctly appears in the curl request\n";
    } else {
        open my $R, "<data/iextoken";
        $iextoken=<$R>;
        chomp $iextoken;
    }
}

#-------------------------------------------------------------------------------

sub iex_end_fetch {
    if (!$iextoken) {
        iex_load_token();
    }
    if (scalar(@iexsyms)>0){
	my $symbol = join(",",@iexsyms);
	my $obj=fetch_json("https://cloud.iexapis.com/v1/stock/market/batch?symbols=$symbol&types=quote&range=15m&token=$iextoken");
	foreach my $symbol(sort keys %$obj){
	    if ($obj->{$symbol}){
		my $quote=$obj->{$symbol}->{quote};
		def_exchange("$symbol/USD", $quote->{latestPrice}, iex_timestamp_str($quote->{latestUpdate}), $obj->{comment});
	    }
	}
    }
}

1;
