#!/usr/bin/perl
#
# copyright Martin Pot 2003
# http://martybugs.net/linux/hddtemp.cgi
#
# rrd_hddtemp.pl

use RRDs;

# define location of rrdtool databases
my $rrd = '/var/www/localhost/htdocs/rrdtool_hddtemp';
# define location of images
my $img = '/var/www/localhost/htdocs/rrdtool_hddtemp';

# process data for each specified HDD (add/delete as required)
&ProcessHDD("sda", "1.5TB Drive #1");
&ProcessHDD("sdb", "1.5TB Drive #2");
&ProcessHDD("sdc", "1.5TB Drive #3");
&ProcessHDD("sdd", "1.5TB Drive #4");

sub ProcessHDD
{
# process HDD
# inputs: $_[0]: hdd (ie, hda, etc)
#         $_[1]: hdd description

	# get hdd temp for master drive on secondary IDE channel
	my $temp=`/usr/sbin/hddtemp -n /dev/$_[0]`;
	# remove eol chars and white space
	$temp =~ s/[\n ]//g;
	
	print "$_[1] (/dev/$_[0]) temp: $temp degrees C\n";

	# if rrdtool database doesn't exist, create it
	if (! -e "$rrd/$_[0].rrd")
	{
		print "creating rrd database for /dev/$_[0]...\n";
		RRDs::create "$rrd/$_[0].rrd",
			"-s 300",
			"DS:temp:GAUGE:600:0:100",
			"RRA:AVERAGE:0.5:1:576",
			"RRA:AVERAGE:0.5:6:672",
			"RRA:AVERAGE:0.5:24:732",
			"RRA:AVERAGE:0.5:144:1460";
	}

	# insert value into rrd
	RRDs::update "$rrd/$_[0].rrd",
		"-t", "temp",
		"N:$temp";

	# create graphs
	&CreateGraph($_[0], "day", $_[1]);
	&CreateGraph($_[0], "week", $_[1]);
	&CreateGraph($_[0], "month", $_[1]);
	&CreateGraph($_[0], "year", $_[1]);
}

sub CreateGraph
{
# creates graph
# inputs: $_[0]: hdd name (ie, hda, etc)
#         $_[1]: interval (ie, day, week, month, year)
#         $_[2]: hdd description

	RRDs::graph "$img/$_[0]-$_[1].png",
		"--lazy",
		"-s -1$_[1]",
		"-t hdd temperature :: $_[2] (/dev/$_[0])",
		"-h", "80", "-w", "600",
		"-a", "PNG",
		"-v degrees C",
		"DEF:temp=$rrd/$_[0].rrd:temp:AVERAGE",
		"LINE2:temp#0000FF:$_[2] (/dev/$_[0])",
		"GPRINT:temp:MIN:  Min\\: %2.lf",
		"GPRINT:temp:MAX: Max\\: %2.lf",
		"GPRINT:temp:AVERAGE: Avg\\: %4.1lf",
		"GPRINT:temp:LAST: Current\\: %2.lf degrees C\\n";
	if ($ERROR = RRDs::error) { print "$0: unable to generate $_[0] graph: $ERROR\n"; }
}
