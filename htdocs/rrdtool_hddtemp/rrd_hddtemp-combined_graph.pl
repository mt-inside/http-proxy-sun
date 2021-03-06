#!/usr/bin/perl
#
# copyright Martin Pot 2003
# http://martybugs.net/linux/hddtemp.cgi
#
# rrd_hddtemp.pl

use RRD::Simple;

# define location of rrdtool databases
my $rrd = '/var/www/localhost/htdocs/rrdtool_hddtemp';
# define location of images
my $img = '/var/www/localhost/htdocs/rrdtool_hddtemp';

# process data for each specified HDD (add/delete as required)
&ProcessHDD("sda", "6TB Drive #1");
&ProcessHDD("sdb", "6TB Drive #2");
&ProcessHDD("sdc", "6TB Drive #3");
&ProcessHDD("sdd", "System SSD");

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
                RRD::Simple::create "$rrd/$_[0].rrd",
			"-s 300",
			"DS:temp:GAUGE:600:0:100",
			"RRA:AVERAGE:0.5:1:576",
			"RRA:AVERAGE:0.5:6:672",
			"RRA:AVERAGE:0.5:24:732",
			"RRA:AVERAGE:0.5:144:1460";
	}

	# insert value into rrd
        RRD::Simple::update "$rrd/$_[0].rrd",
		"-t", "temp",
		"N:$temp";
}

&CreateGraph("", "day");
&CreateGraph("", "week");
&CreateGraph("", "month");
&CreateGraph("", "year");

sub CreateGraph
{
# creates graph
# inputs: $_[0]: not used
#         $_[1]: interval (ie, day, week, month, year)

    RRD::Simple::graph "$img/hddtemp-$_[1].png",
		"--lazy",
		"-s -1$_[1]",
		"-t hdd temperature :: all drives",
		"-h", "80", "-w", "600",
		"-a", "PNG",
		"-v degrees C",

		"DEF:sda=$rrd/sda.rrd:temp:AVERAGE",
		"DEF:sdb=$rrd/sdb.rrd:temp:AVERAGE",
		"DEF:sdc=$rrd/sdc.rrd:temp:AVERAGE",
		"DEF:sdd=$rrd/sdd.rrd:temp:AVERAGE",
		"DEF:sde=$rrd/sde.rrd:temp:AVERAGE",

		"LINE2:sda#0000FF:1.5TB #1 (/dev/sda)",
		"GPRINT:sda:MIN:  Min\\: %2.lf",
		"GPRINT:sda:MAX: Max\\: %2.lf",
		"GPRINT:sda:AVERAGE: Avg\\: %4.1lf",
		"GPRINT:sda:LAST: Current\\: %2.lf degrees C\\n",

		"LINE2:sdb#000000:System SSD (/dev/sdb)",
		"GPRINT:sdb:MIN:  Min\\: %2.lf",
		"GPRINT:sdb:MAX: Max\\: %2.lf",
		"GPRINT:sdb:AVERAGE: Avg\\: %4.1lf",
		"GPRINT:sdb:LAST: Current\\: %2.lf degrees C\\n",

		"LINE2:sdc#00FF00:1.5TB #2 (/dev/sdc)",
		"GPRINT:sdc:MIN:  Min\\: %2.lf",
		"GPRINT:sdc:MAX: Max\\: %2.lf",
		"GPRINT:sdc:AVERAGE: Avg\\: %4.1lf",
		"GPRINT:sdc:LAST: Current\\: %2.lf degrees C\\n",

		"LINE2:sdd#FF0000:1.5TB #3 (/dev/sdd)",
		"GPRINT:sdd:MIN:  Min\\: %2.lf",
		"GPRINT:sdd:MAX: Max\\: %2.lf",
		"GPRINT:sdd:AVERAGE: Avg\\: %4.1lf",
		"GPRINT:sdd:LAST: Current\\: %2.lf degrees C\\n",

		"LINE2:sde#FFFF00:1.5TB #4 (/dev/sde)",
		"GPRINT:sde:MIN:  Min\\: %2.lf",
		"GPRINT:sde:MAX: Max\\: %2.lf",
		"GPRINT:sde:AVERAGE: Avg\\: %4.1lf",
		"GPRINT:sde:LAST: Current\\: %2.lf degrees C\\n";
	if ($ERROR = RRD::Simple::error) { print "$0: unable to generate $_[1] graph: $ERROR\n"; }
}
