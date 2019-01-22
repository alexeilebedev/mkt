#!/usr/local/binperl
use Date::Parse;

sub gettokens($) {
    my @ret;
    foreach my $token(split(/,/,$_[0])) {
	$token =~ s/^\s+//; # trim whitespace
	$token =~ s/\s+$//;
	push(@ret,$token);
    }
    return @ret;
}

#-------------------------------------------------------------------------------

# fetch European Central Bank quotes
# they come in a csv file
# All prices are relative to EUR
sub ecb_fetch() {
    my $url="https://www.ecb.europa.eu/stats/eurofxref/eurofxref.zip";
    open my $R, "curl -s $url | unzip -p - | ";
    # output is just 2 lines.
    # first line is
    # Date, USD, JPY, BGN, CZK, DKK, GBP, HUF, PLN, RON, SEK, CHF, ISK, NOK, HRK, RUB ...
    # second line is
    # 14 December 2018, 1.1285, 128.13, 1.9558, 25.794, 7.4656, 0.89835, 323.93, 4.2974, 4.6558, 10.2610, 1.1254, 140.40, 9.7235,...
    my @headers=gettokens(<$R>);
    my @data=gettokens(<$R>);
    my $timestr;
    if ($headers[0] eq "Date") {
	$timestr = strftime("%Y-%m-%dT%H:%M:%S",gmtime(str2time($data[0])));
    }
    for (my $i=1; $i<scalar(@headers); $i++){
	my $symbol=$headers[$i];
	my $price=$data[$i];
	if ($symbol) {
	    def_exchange("EUR/$symbol",$price,$timestr,"");
	}
    }
}

#-------------------------------------------------------------------------------

my $fetched;
sub ecb_fetch_quote {
    if (!$fetched) {
	ecb_fetch();
	$fetched=1;
    }
}

1;
