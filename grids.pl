#!/usr/bin/perl
#
# generate statistics  for grids callign cq
use Time::HiRes;

use POSIX qw(strftime);

$datestring = strftime "%a %b %e %H:%M:%S %Y %Z", localtime;

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval);

$infile='/home/mike/.local/share/WSJT-X/ALL.TXT';
#$infile = "ALL.TXT";
$outfile= "/var/www/html/K5ROE/reportgrids.txt";
$tmpfile = "/tmp/grids.tmp";
$lookupfile="/home/mike/scripts/ham/lookup.txt";
$samplesize = 200000;
$cutoff = .03;
$sep='---------------------------------------------------------------------------------';

$t0 = [gettimeofday];


open (L,"$lookupfile") || die "cannot open lookup $!";

while (<L>) {
	chomp();
	($lgrid,$ldesc)=split(/,/);
	$desc{$lgrid}=$ldesc;
	}

close (L);

system ("tail -n $samplesize $infile > $tmpfile");

open (T,"$tmpfile") || die "cannot open tempfile $!";

while (<T>) {
	if (/K5ROE/) {next;}
	if (/[A-Z][A-Z][0-9][0-9]/ && /CQ [A-Z][A-Z] /) {
	@field=split;
	$grid=$field[8];
	$count{$grid}++;
	if (length($grid) != 4) {print "bad grid $grid\n";}
	$total++;
	next;
	}

	elsif (/CQ/) {
		@field=split;
        	$grid=$field[7];
		if (length($grid) != 4) {next;}
		if ($grid =~ /-/ || /\+/) {next;}
        	$count{$grid}++;
		$total++;
		}

}

close(T);

open (OF,">$outfile") || die "cannot open $outfile $!";

$lt=localtime(time);

print OF "Top FT8 grids sending CQ. Generated at $datestring\n";
print OF "$total messages analyzed\n$sep\n";

print OF "\n";

#table header
print OF "RANK\tGRID\tCOUNT\tPCT\tDESC\n$sep\n";

foreach my $name (sort { $count{$b} <=> $count{$a} } keys %count) {

$ix++;

$pct=100*($count{$name} / $total); 

$rpct=sprintf("%.2f", $pct);

#if ($count{$name} < 2) {last;}

if ($rpct < $cutoff) {last;}


print OF "$ix\t$name\t$count{$name}\t$rpct %\t$desc{$name}\n";


}

$elapsed = tv_interval ($t0, [gettimeofday]);

#print "elapsed $elapsed\n";

print OF "$sep\ngenerated in $elapsed seconds\n";

