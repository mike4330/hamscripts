#!/usr/bin/perl

#create individual graphs for callsign trends

$prefix = '/home/mike/scripts/ham';

open (R,"$prefix/ranks") || die "cannot open ranks";

while (<R>) {

	($call,$foo)=split;

	#print "$call\n";

	open (Q,"$prefix/ranksh.csv") || die "cannot open historical $!";

	open (T,">$prefix/datafiles/$call.tcsv");

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

open (R,"$prefix/ranks") || die "cannot open ranks";

while (<R>) {

	($call,$foo)=split;

	$infile=$prefix . '/datafiles/' . $call . '.tcsv';
	$outfile=$call . '.png';

	$fn=$cs . '.png';

	print "plot $call\n";

	system("gnuplot -e \"filename='$infile';fname='/var/www/testimg/$outfile';tname='$call'\" $prefix/plotcs"); 


}


