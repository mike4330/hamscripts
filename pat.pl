#!/usr/bin/perl
 use Net::FTP;

$prefix='/home/mike/scripts/ham';

$tempfile='/tmp/all.tmp';

$outfile=$prefix . '/cqers.csv';

$rankfile = $prefix . '/ranks';

open (CR,"$prefix/creds") || die "cannot open creds $!";

while (<CR>){($fuser,$fpwd)=split;}

#load previous positions
open (PI,"$rankfile") || die "cannot open $rankfile $!\n";

while (<PI>) {
	($c,$pp)=split;
#	print "c is $c pp is $pp\n";
	$previous_rank{$c}=$pp;
	}

close(PI);

system("tail -n 100000 /home/mike/.local/share/WSJT-X/ALL.TXT > $tempfile");
system("tail -n 100000 '/home/mike/.local/share/WSJT-X - ig'/ALL.TXT >> $tempfile");


open (F,"$tempfile") || die "cannot open input $!";

while (<F>) {

if (/\#/ && /CQ [A-Z0-9]{4,6}/) {
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

open (H,'>/var/www/K5ROE/cqers.html') ;

print H '<html><head>
<link rel="stylesheet" type="text/css" href="table.css">
<title>JT65 statistics page</title>
</head><body>';

print H "<h1>JT65 CQ messages observed at locator FM18gt</h1>";
print H "<h2>last 100,000 signals ending at $lz UTC</h2>";

print H "$size unique callsigns calling CQ<br>";

print H '<img src="cqers.png">';

print H "<h3>top 100 callsigns calling CQ</h3>";

print H "<table><tr><th>rank</th><th>callsign</th><th>CQ count</th><th>previous rank</th>";

open (P,"> $prefix/ranks");

#historical ranking file
open (RF,">>$prefix/ranksh.csv");


foreach my $name (sort { $cqcount{$b} <=> $cqcount{$a} } keys %cqcount) {
 #   printf "%-8s %s\n", $name, $cqcount{$name};

	$ix++;

	print P "$name $ix\n";

	$ct=time;
	
	print RF "$ct,$name,$ix\n";

	if ($ix == 101) {last;}
	$rank_delta = ($previous_rank{$name} - $ix);
	if ($rank_delta > 2 ) {$icon='<td align=center><font size=8>&#8657;</font></td>';}
	elsif ($rank_delta > 1) {$icon='<td align=center><font size=5>&#8657;</font></td>';}
	elsif ($rank_delta < 0) {$icon='<td align=center><font size=5>&#8659;</font></td>';}

                else {$icon='<td></td>';}

	print H "<tr><td>$ix</td><td><a href=\"$name.png\">$name</a></td> 

	<td>$cqcount{$name}</td><td>$previous_rank{$name}$icon</td></tr>\n";
	
}

print H '</table></body></html>';

close (H);

open(O,">>$outfile");

print O "$ut,$size\n";

close (O);

#plot main graph


$starttime=time;
system ("$prefix/plot1");
$endtime=(time);
$exectime=($endtime-$starttime);
system("logger cq plot time $exectime");

#upload to web
print "starting web upload\n";
$ftp = Net::FTP->new("ftp.roetto.org", Debug => 0)
	or die "Cannot connect to some.host.name: $@";

$ftp->login($fuser,$fpwd)
	or die "Cannot login ", $ftp->message;

   $ftp->cwd("/www/K5ROE")
      or die "Cannot change working directory ", $ftp->message;

$ftp->binary();

    $ftp->put("/var/www/K5ROE/cqers.html")
      or die "get failed ", $ftp->message;

        $ftp->put("/var/www/K5ROE/cqers.png")
      or die "get failed ", $ftp->message;

@upfilez=</var/www/testimg/*.png>;

foreach $f (@upfilez) { $ftp->put("$f")
      or die "put failed ", $ftp->message; }


    $ftp->quit;

