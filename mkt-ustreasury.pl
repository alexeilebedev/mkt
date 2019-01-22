#!/usr/local/binperl
use Date::Parse;
use POSIX qw(strftime);

#-------------------------------------------------------------------------------

# fetch US Treasury Bill rates
# lynx output looks like this:
#
# Daily Treasury Bill Rates Data
# ...
#                         4 WEEKS                         8 WEEKS                        52 WEEKS
#      DATE   BANK DISCOUNT COUPON EQUIVALENT BANK DISCOUNT COUPON EQUIVALENT BANK DISCOUNT COUPON EQUIVALENT
#    12/03/18 2.25          2.28              2.29          2.33              2.62          2.71
#    ...
#    12/31/18 2.40          2.44              2.41          2.45              2.54          2.63
#       Monday Dec 31, 2018
#       ^----need to end parsing here
# coupon equivalent is the bond equivalent, based on 365-day year
# bank discount column is based on a 360-day year.
# I don't bother parsing the entire table, I know the last column is the 52-week quote.

sub ustreasury_fetch() {
    my $url="https://www.treasury.gov/resource-center/data-chart-center/interest-rates/Pages/TextView.aspx?data=billrates";
    open my $R, "lynx -nonumbers -dump $url | ";
    my $have_hdr=0;
    my $have_data=0;
    my $have_end=0;
    my $nquote=0;
    while (<$R>) {
	if (/Daily Treasury Bill Rates Data/) {
	    $have_hdr=1;
	    next;
	}
	if ($have_hdr && /DATE .*BANK DISCOUNT/) {
	    $have_data=1;
	    next;
	}
	if ($have_data && !$have_end) {
	    s/\s+$//;
	    s/^\s+//;
	    # the first word is the date
	    # the last number on the line is the 52 weeks quote
	    if (m!^\d+/\d+/\d+\s!) {
		my @words=split(/\s+/);
		my $timestr = strftime("%Y-%m-%dT%H:%M:%S",gmtime(str2time($words[0])));
		my $price = $words[scalar(@words)-1];
		def_exchange("TB52/1",$price,$timestr,"");
		$nquote++;
	    } else {
		if ($nquote>0) {
		    $have_end=1;
		}
	    }
	}
    }
}

#-------------------------------------------------------------------------------

my $fetched;
sub ustreasury_fetch_quote {
    if (!$fetched) {
	ustreasury_fetch();
	$fetched=1;
    }
}

1;
