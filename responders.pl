#!/usr/bin/perl

#$tempfile='/tmp/all.tmp';
$prefix='/home/mike/scripts/ham';
$tempfile='/tmp/all2.tmp';
$outfile="$prefix/cqresp.csv";
$rankfile = "$prefix/respranks";

system("tail -n 100000 /home/mike/.local/share/WSJT-X/ALL.TXT > $tempfile");
system("tail -n 100000 '/home/mike/.local/share/WSJT-X - ig'/ALL.TXT >> $tempfile");

#load previous positions
open (PI,"$rankfile") || die "cannot open $rankfile $!\n";

while (<PI>) {
	($c,$pp)=split;
#	print "c is $c pp is $pp\n";
	$previous_rank{$c}=$pp;
	}

open (F,"$tempfile") || die "cannot open input $!";

while (<F>) {

if (/RR73/) {next;}

if (/\#/ && /[A-Z0-9]{4,6} [A-Z0-9]{4,6} [A-Z]{2}[0-9]{2}/) {
#		print;
                @field=split;
                $rcallsign=$field[6];
                $db=$field[2];
                $cqcount{$rcallsign}++;
		#print "$rcallsign\n";

                }
}

close (F);

$size = keys %cqcount;

print "$size unique responders\n";

$size = keys %cqcount;

$lz=gmtime(time);

$ut=time;

open (H,'>/var/www/K5ROE/cqresponders.html') ;

print H '<html><head>
<link rel="stylesheet" type="text/css" href="table.css">
<title>JT65 statistics page</title>
</head><body>';

print H "<h1>JT65 CQ response messages observed at locator FM18gt</h1>";
print H "<h2>last 100,000 signals ending at $lz UTC</h2>";

print H "$size unique callsigns responding to CQ<br>";

print H '<img src="cqresp.png">';

print H "<h3>top 100 callsigns responding to CQ</h3>";

print H "<table><tr><th>rank</th><th>callsign</th><th>Response count</th><th>previous rank</th>";

open (P,"> $prefix/respranks");

#historical ranking file
open (RF,">>$prefix/respranksh.csv");


foreach my $name (sort { $cqcount{$b} <=> $cqcount{$a} } keys %cqcount) {
 #   printf "%-8s %s\n", $name, $cqcount{$name};

	$ix++;

	print P "$name $ix\n";

	$ct=time;
	
	print RF "$ct,$name,$ix\n";

	if ($ix == 251) {last;}
	$rank_delta = ($previous_rank{$name} - $ix);
	if ($rank_delta > 2 ) {$icon='<td align=center><font size=8>&#8657;</font></td>';}
	elsif ($rank_delta > 1) {$icon='<td align=center><font size=5>&#8657;</font></td>';}
	elsif ($rank_delta < 0) {$icon='<td align=center><font size=5>&#8659;</font></td>';}

                else {$icon='<td></td>';}

	if ($name =~ /^A[A-L]|^K|^N|^W/) {$flag='<img src="US.png"><br><font size=1>United States</font>';} 
		elsif ($name =~ /^CO/) {$flag='<img src="CU.png"><br><font size=1>Cuba</font>';}
		elsif ($name =~ /^C[Q-U]/) {$flag='<img src="CT.png"><br><font size=1>Portugal</font>';}					
		elsif ($name =~ /^D[A-R]/) {$flag='<img src="DE.png"><br><font size=1>Germany</font>';}
		elsif ($name =~ /^E[A-H]/) {$flag='<img src="ES.png"><br><font size=1>Spain</font>';}
		elsif ($name =~ /^F/) {$flag='<img src="FR.png"><br><font size=1>France</font>';}
		elsif ($name =~ /^G|^M[A-Z]|^Z[B-J]/) {$flag='<img src="GB.png"><br><font size=1>Great Britain</font>';}
		elsif ($name =~ /^HA/) {$flag='<img src="HU.png"><br><font size=1>Hungary</font>';}
		elsif ($name =~ /^HB/) {$flag='<img src="CH.png"><br><font size=1>Switzerland</font>';}
		elsif ($name =~ /^H[C-D]/) {$flag='<img src="EC.png"><br><font size=1>Equador</font>';}
		elsif ($name =~ /^HI/) {$flag='<img src="DO.png"><br><font size=1>Dominican Republic</font>';}
		elsif ($name =~ /^H[J-K]/) {$flag='<img src="CO.png"><br><font size=1>Columbia</font>';}
		elsif ($name =~ /^I/) {$flag='<img src="IT.png"><br><font size=1>Italy</font>';}
		elsif ($name =~ /^L[O-W]/) {$flag='<img src="AR.png"><br><font size=1>Argentina</font>';}
		elsif ($name =~ /^LY/) {$flag='<img src="LT.png"><br><font size=1>Lithuania</font>';}
		elsif ($name =~ /^O[N-T]/) {$flag='<img src="BE.png"><br><font size=1>Belgium</font>';}
		elsif ($name =~ /^O[K-L]/) {$flag='<img src="CZ.png"><br><font size=1>Czech Republic</font>';}
		elsif ($name =~ /^P[A-I]/) {$flag='<img src="NL.png"><br><font size=1>Netherlands</font>';}
		elsif ($name =~ /^P[P-Y]/) {$flag='<img src="BR.png"><br><font size=1>Brazil</font>';}
		elsif ($name =~ /^S[N-R]/) {$flag='<img src="PL.png"><br><font size=1>Poland</font>';}
		elsif ($name =~ /^S[V-Z]/) {$flag='<img src="GR.png"><br><font size=1>Greece</font>';}

		elsif ($name =~ /^TI/) {$flag='<img src="CR.png"><br><font size=1>Costa Rica</font>';}
		elsif ($name =~ /^V[A-G]|^VO/) {$flag='<img src="CA.png"><br><font size=1>Canada</font>';}
		elsif ($name =~ /^X[E-I]/) {$flag='<img src="CA.png"><br><font size=1>Mexico</font>';}	
		elsif ($name =~ /^Y[V-Y]/) {$flag='<img src="MX.png"><br><font size=1>Venezuela</font>';}
		elsif ($name =~ /^Z[R-U]/) {$flag='<img src="ZA.png"><br><font size=1>South Africa</font>';}

		else {$flag="no icon";}

	print H "<tr><td>$ix</td><td>$flag</td><td><a href=\"\/testimg\/$name-resp.png\">$name</a></td> 

	<td>$cqcount{$name}</td><td>$previous_rank{$name}$icon</td></tr>\n";
	
}

print H '</table></body></html>';

close (H);

open(O,">>$outfile");

print O "$ut,$size\n";

close (O);

#plot main graph
system ("$prefix/plotresp");

