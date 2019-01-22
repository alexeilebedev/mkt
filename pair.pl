#!/usr/local/bin/perl
use strict;
use Time::HiRes;

my $def_ccy = "USD";
my $pairdb;

# define default display currency
sub set_def_ccy($) {
    $def_ccy=$_[0];
}

# query default display currency
sub get_def_ccy() {
    return $def_ccy;
}

# if pair $_[0] is base currency, add it
sub with_def_ccy($) {
    my $pair = $_[0];
    if ($pair !~ m!/!) {
	$pair = "$pair/$def_ccy";
    }
    return $pair;
}

# if pair $_[0] uses default currency as base currency, strip it
sub without_def_ccy($) {
    my $pair = $_[0];
    $pair  =~ s!/$def_ccy$!!;
    return $pair;
}

# extract A,B from an exchange pair in the form "A/B"
sub getpair($) {
    my $idx=index($_[0],'/');
    if ($idx == -1) {
	return undef;
    }
    return substr($_[0],0,$idx), substr($_[0],$idx+1);
}

#-------------------------------------------------------------------------------

# define exchange rate for pair $_[0]
# to be $_[1] at time $_[2]
# time is just a string
sub def_exchange($$$$) {
    my ($a,$b) = getpair($_[0]);
    my $price=$_[1];
    my $time=$_[2];
    my $comment=$_[3];
    #print "$a/$b -> $price\n";
    if ($a && $b && $price != 0.0) {
	$pairdb->{"$a/$b"} = {
	    time => $time
		, price => $price
		, comment => $comment
	};
	if ($a ne $b) {
	    $pairdb->{"$b/$a"} = { time => $time, price => 1.0 / $price };
	}
	if (!$pairdb->{"$a/$a"}) {
	    $pairdb->{"$a/$a"} = { time => $time, price => 1.0 };
	}	    
	if (!$pairdb->{"$b/$b"}) {
	    $pairdb->{"$b/$b"} = { time => $time, price => 1.0 };
	}	    
    }
}

#-------------------------------------------------------------------------------

# retrieve exchange rate for $_[0]
# result is ($price,$time,$comment) or undef
sub get_quote($) {
    my $rec = $pairdb->{$_[0]};
    #print "getquote $_[0]  $rec->{price}  $rec->{time}\n";
    if (!$rec) {
	return undef;
    }
    return ($rec->{price},$rec->{time},$rec->{comment});
}

#-------------------------------------------------------------------------------

sub build_implied() {
    # given a pair such as A/B, find all instruments C/A
    # and define C/B as (A/B) * (C/A). this defines B/C as well 
    my $start_time = [Time::HiRes::gettimeofday()];
    my $nums;
    foreach my $pair(keys %$pairdb) {
	my ($a,$b)=getpair($pair);
	$nums->{$b}->{$a}=1;
    }	
    foreach my $b(keys %$nums) {
	my $numsb=$nums->{$b};
	foreach my $a(keys %$numsb) {
	    my $numsa=$nums->{$a};
	    foreach my $c(keys %$numsa) {
		if (($c ne $b) && !$pairdb->{"$c/$b"}) {
		    my $p1 = $pairdb->{"$a/$b"};
		    my $p2 = $pairdb->{"$c/$a"};
		    if ($p1 && $p2) {
			def_exchange("$c/$b", $p1->{price}*$p2->{price}, $p1->{time}, "via $a");
		    }
		}
	    }
	}
    }
    #print "pairdb: ".scalar(%$pairdb)." entries\n";
    my $diff = Time::HiRes::tv_interval($start_time);
    # takes milliseconds
    #print "implied calculation: $diff\n";
}

1;
