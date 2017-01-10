#!/usr/bin/perl

#create individual graphs for callsign responder trends

$prefix = '/home/mike/scripts/ham';

open (R,"$prefix/respranks") || die "cannot open ranks";

while (<R>) {

($call,$foo)=split;

#print "$call\n";

open (Q,"$prefix/respranksh.csv") || die "cannot open historical $!";

open (T,">$prefix/datafiles/$call.rcsv");

while (<Q>) {if ($_ =~ /$call/) {
	chomp();
	($ts,$call,$rank)=split(/,/);
	print T "$ts,$rank\n";
	}
	};

close (T);

close (Q);

}

close (R);

open (R,"$prefix/respranks") || die "cannot open ranks";

#@filez=<$prefix/*.tcsv>;

while (<R>) {

($call,$foo)=split;

$infile=$prefix . '/datafiles/' . $call . '.rcsv';
$outfile=$call . '-resp.png';


$fn=$cs . '.png';



#print "infile is $infile outfile is $outfile\n";

system("gnuplot -e \"filename='$infile';fname='/var/www/testimg/$outfile';tname='cq resp $call'\" $prefix/plotcs"); 


}


