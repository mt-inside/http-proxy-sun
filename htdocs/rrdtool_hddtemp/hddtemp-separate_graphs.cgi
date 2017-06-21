#!/usr/bin/perl
#
# copyright Martin Pot 2003
# http://martybugs.net/linux/hddtemp.cgi
#
# hddtemp.cgi

my @graphs;
my ($name, $descr);

# define hdds to display (add/remove as required)
push (@graphs, "sda");
push (@graphs, "sdb");
push (@graphs, "sdc");
push (@graphs, "sdd");

# get the server name (or you could hard code some description here)
my $svrname = $ENV{'SERVER_NAME'};

# get url parameters
my @values = split(/&/, $ENV{'QUERY_STRING'});
foreach my $i (@values) 
{
	($varname, $mydata) = split(/=/, $i);
	if ($varname eq 'trend')
	{
		$name = $mydata;
	}
}

if ($name eq '')
{ 
	$descr = "summary"; 
}
else
{ 
	$descr = "/dev/$name"; 
}

print "Content-type: text/html;\n\n";
print <<END
<html>
<head>
  <TITLE>$svrname HDD temps :: $descr</TITLE>
  <META HTTP-EQUIV="Refresh" CONTENT="300">
  <META HTTP-EQUIV="Cache-Control" content="no-cache">
  <META HTTP-EQUIV="Pragma" CONTENT="no-cache">
  <style>
    body { font-family: Verdana,Tahoma,Arial,Helvetica; font-size:9pt}
    .header { font-size: 16pt; font-weight: 900; }
  </style>
</head>
<body bgcolor="#ffffff" topMargin='5'>

<span class='header'>$svrname HDD temps :: $descr</span>
<br><br>
END
;

if ($name eq '')
{
	print "Daily Graphs (5 minute averages)";
	print "<br>";
	
	foreach $graph (@graphs)
	{
		print "<a href='?trend=$graph'><img src='$graph-day.png' border='1'></a>";
		print "<br>";
	}
}
else
{
	print <<END
Daily Graph (5 minute averages)
<br>
<img src='$name-day.png'>
<br>
Weekly Graph (30 minute averages)
<br>
<img src='$name-week.png'>
<br>
Monthly Graph (2 hour averages)
<br>
<img src='$name-month.png'>
<br>
Yearly Graph (12 hour averages)
<br>
<img src='$name-year.png'>
END
;
}

print <<END
<br><br>
<a href='http://ee-staff.ethz.ch/~oetiker/webtools/rrdtool/'>
 <img src='http://people.ee.ethz.ch/~oetiker/webtools/rrdtool/.pics/rrdtool.gif' border='0'></a>
</body>
</html>
END
;
