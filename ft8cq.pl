#!/usr/bin/perl
use Net::FTP;

#count unique FT8 callsigns calling CQ

$mode='FT8';
$samplesize=110000;
$prefix='/home/mike/scripts/ham';
$tempfile='/tmp/ft8all.tmp';
$outfile=$prefix . '/ft8cqers.csv';
$rankfile = $prefix . '/ft8ranks';

open (CR,"$prefix/creds") || die "cannot open creds $!";

while (<CR>){($fuser,$fpwd)=split;}

#load previous positions
open (PI,"$rankfile") ;

while (<PI>) {
	($c,$pp)=split;
#	print "c is $c pp is $pp\n";
	$previous_rank{$c}=$pp;
	}

close(PI);

system("tail -n $samplesize /home/mike/.local/share/WSJT-X/ALL.TXT > $tempfile");
#system("tail -n $samplesize '/home/mike/.local/share/WSJT-X - ig'/ALL.TXT >> $tempfile");


open (F,"$tempfile") || die "cannot open input $!";

while (<F>) {

if (/\~/ && /CQ [A-Z0-9]{4,6}/) {
		@field=split;
		$callsign=$field[6];
		$db=$field[2];
		$cqcount{$callsign}++;
		}
}

close (F);

$size = keys %cqcount;

$lz=gmtime(time);

$ut=time;

open (H,'>/var/www/html/K5ROE/ft8cqers.html') ;

print H '<html><head>
<link rel="stylesheet" type="text/css" href="table.css">
<title>FT8 statistics page</title>';


open(Q,"$prefix/ga") || die "cannot open ga file $!";
while (<Q>) {print H;} 
close (Q);

print H '</head><body>';

print H "<h1>$mode CQ messages observed at locator FM18gt</h1>";
print H "<h2>last $samplesize signals ending at $lz UTC</h2>";

print H "$size unique callsigns calling CQ<br>";

print H '<img src="ft8cq.png">';
print H "<h3>top 100 callsigns calling CQ</h3>";
print H "<table><tr><th>Country</th><th>rank</th><th>callsign</th><th>CQ count</th><th>previous rank</th>";

open (P,"> $prefix/ft8ranks");

#historical ranking file
open (RF,">>$prefix/ft8ranksh.csv");

foreach my $name (sort { $cqcount{$b} <=> $cqcount{$a} } keys %cqcount) {

	$ix++;

	print P "$name $ix\n";

	$ct=time;
	
	print RF "$ct,$name,$ix\n";

	if ($ix == 101) {last;}
	$rank_delta = ($previous_rank{$name} - $ix);
	if ($rank_delta > 3 ) {$icon='<td align=center><font size=8>&#8657;</font></td>';}
	elsif ($rank_delta > 2 ) {$icon='<td align=center><font size=5>&#8657;</font></td>';}
	elsif ($rank_delta < -1 ) {$icon='<td align=center><font size=5>&#8659;</font></td>';}

                else {$icon='<td></td>';}

	#flag/prefix lookup
	if ($name =~ /^A[A-L]|^K|^N|^W/) {$flag='<img src="US.png"><br><font size=1>United States</font>';} 
		elsif ($name =~ /^9A/) {$flag='<img src="HR.png"><br><font size=1>Croatia</font>';}
		elsif ($name =~ /^C[A-E]/) {$flag='<img src="CL.png"><br><font size=1>Chile</font>';}
		elsif ($name =~ /^CO/) {$flag='<img src="CU.png"><br><font size=1>Cuba</font>';}
		elsif ($name =~ /^C[Q-U]/) {$flag='<img src="CT.png"><br><font size=1>Portugal</font>';}
		elsif ($name =~ /^C[V-X]/) {$flag='<img src="UY.png"><br><font size=1>Uruguay</font>';}
		elsif ($name =~ /^D[A-R]/) {$flag='<img src="DE.png"><br><font size=1>Germany</font>';}
		elsif ($name =~ /^E7/) {$flag='<img src="BA.png"><br><font size=1>Bosnia</font>';}
		elsif ($name =~ /^E[A-H]/) {$flag='<img src="ES.png"><br><font size=1>Spain</font>';}
		elsif ($name =~ /^F/) {$flag='<img src="FR.png"><br><font size=1>France</font>';}
		elsif ($name =~ /^G|^M[0-9A-Z]|^Z[B-J]/) {$flag='<img src="GB.png"><br><font size=1>Great Britain</font>';}
		elsif ($name =~ /^HA/) {$flag='<img src="HU.png"><br><font size=1>Hungary</font>';}
		elsif ($name =~ /^HB/) {$flag='<img src="CH.png"><br><font size=1>Switzerland</font>';}
		elsif ($name =~ /^H[C-D]/) {$flag='<img src="EC.png"><br><font size=1>Equador</font>';}
		elsif ($name =~ /^HI/) {$flag='<img src="DO.png"><br><font size=1>Dominican Republic</font>';}
		elsif ($name =~ /^H[J-K]/) {$flag='<img src="CO.png"><br><font size=1>Columbia</font>';}
		elsif ($name =~ /^H[O-P]/) {$flag='<img src="PA.png"><br><font size=1>Panama</font>';}
		elsif ($name =~ /^I/) {$flag='<img src="IT.png"><br><font size=1>Italy</font>';}
		elsif ($name =~ /^L[O-W]/) {$flag='<img src="AR.png"><br><font size=1>Argentina</font>';}
		elsif ($name =~ /^LY/) {$flag='<img src="LT.png"><br><font size=1>Lithuania</font>';}
		elsif ($name =~ /^OE/) {$flag='<img src="AT.png"><br><font size=1>Austria</font>';}
		elsif ($name =~ /^OM/) {$flag='<img src="SK.png"><br><font size=1>Slovakia</font>';}
		elsif ($name =~ /^O[N-T]/) {$flag='<img src="BE.png"><br><font size=1>Belgium</font>';}

		elsif ($name =~ /^O[U-Z]/) {$flag='<img src="DK.png"><br><font size=1>Denmark</font>';}

		elsif ($name =~ /^O[K-L]/) {$flag='<img src="CZ.png"><br><font size=1>Czech Republic</font>';}

		elsif ($name =~ /^P[A-I]/) {$flag='<img src="NL.png"><br><font size=1>Netherlands</font>';}
		elsif ($name =~ /^P[P-Y]/) {$flag='<img src="BR.png"><br><font size=1>Brazil</font>';}
		elsif ($name =~ /^S[N-R]/) {$flag='<img src="PL.png"><br><font size=1>Poland</font>';}
		elsif ($name =~ /^S[V-Z]/) {$flag='<img src="GR.png"><br><font size=1>Greece</font>';}
		elsif ($name =~ /^S5/) {$flag='<img src="SI.png"><br><font size=1>Slovenia</font>';}
		elsif ($name =~ /^R/) {$flag='<img src="RU.png"><br><font size=1>Russia</font>';}
		elsif ($name =~ /^TI/) {$flag='<img src="CR.png"><br><font size=1>Costa Rica</font>';}
		elsif ($name =~ /^U[R-Z]/) {$flag='<img src="UA.png"><br><font size=1>Ukraine</font>';}
		elsif ($name =~ /^V[A-G]|^VO|^V[X-Y]/) {$flag='<img src="CA.png"><br><font size=1>Canada</font>';}
		elsif ($name =~ /^X[E-I]/) {$flag='<img src="MX.png"><br><font size=1>Mexico</font>';}	
		elsif ($name =~ /^Y[V-Y]/) {$flag='<img src="VE.png"><br><font size=1>Venezuela</font>';}
		elsif ($name =~ /^Z3/) {$flag='<img src="MK.png"><br><font size=1>Macedonia</font>';}
		elsif ($name =~ /^Z[R-U]/) {$flag='<img src="ZA.png"><br><font size=1>South Africa</font>';}

		else {$flag="no icon";}

	print H "<tr><td>$flag</td><td>$ix</td><td>$name</td> 

	<td>$cqcount{$name}</td><td>$previous_rank{$name}$icon</td></tr>\n";
	
}

print H '</table></body></html>';

close (H);

open(O,">>$outfile");

print O "$ut,$size\n";

close (O);

#plot main graph
#$starttime=time;
system ("$prefix/ft8cqplot");
#$endtime=(time);
#$exectime=($endtime-$starttime);
#system("logger $mode cq plot time $exectime");



