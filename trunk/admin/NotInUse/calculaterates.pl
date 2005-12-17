#!/usr/bin/perl -w
#
# This files is used to calculate cost
# if you have records in your astcdr table that have no cost/sales calculated this script will execute the 
# stored procedures for each record without cost
#
#/*
# * AstBill  -- Billing, Routing and Management software for Asterisk and MySQL using Drupal
# *
# * www.astbill.com
# *
# * Asterisk -- A telephony toolkit for Linux.
# * Drupal   -- An Open source content management platform.
# *
# * 
# * Copyright (C) 2005, AOFFICE NOMINEE SECRETARIES LIMITED, UNITED KINGDOM.
# *
# * Andreas Mikkelborg <adoroar [Guess What?] astartelecom.com>
# * Are Casilla        <areast  [Guess What?] astartelecom.com>
# *
# *
# * This program is free software, distributed under the terms of
# * the GNU General Public License
# *
# * 2005.09.26 Version 0.9.0.2    
# * 
# */

use DBI;
################### BEGIN OF CONFIGURATION ####################
if ($#ARGV==-1) { print "Vallid (Argument) missing\nUse argument astlog or all or missing\n"; exit 0;	} 

$cmdline = $ARGV[0];
if ($cmdline eq "help") {
print "Use argument astlog or all or missing to execute!\n"; exit 0; }
print "Executing: $cmdline\n";

my $statement = "SELECT uniqueid from astcdr where dialstatus like 'ANSWER%' 
and answeredtime <> 0 and trunk <> 'Local' and price = 0;";

if ($cmdline eq "astlog") {
$statement = "select distinct uniqueid from astlog;"; }

if ($cmdline eq "all") {
$statement = "SELECT uniqueid from astcdr where dialstatus like 'ANSWER%' 
and answeredtime <> 0 and trunk <> 'Local'" }


$config = &load_config();
print "config.conf loaded. dbhost = $config{dbhost}\n";

my $runtime;
my $jobstr;

# WARNING: this file will be substituted by the output of this program
# $bind_conf = "/etc/bind/named.conf.local";
# $cache_bind = "/var/cache/bind/";     # Where the DNS Zone files is to be saved.

$runtime = localtime(time);

################### END OF CONFIGURATION #######################



my $strName = '@';    # Dont work with @ directly in SQL

# Connect to MSSQL
# $dbh = DBI->connect("dbi:Sybase:dbname=$database;server=$hostname", "$username", "$password");

#connect to MySQL database
if ($config{odbc} eq "YES") {
	$dbh= DBI->connect("DBI:ODBC:$config{dbdsn}",$config{dbuser},$config{dbpass}) ||   die "Got error $DBI::errstr when connecting to $config{dbdsn}\n";
}
else {
    $dbh   = DBI->connect ("DBI:mysql:database=$config{dbname}:host=$config{dbhost}", 
			$config{dbuser},$config{dbpass}) or die "Can't connect to database: $DBI::errstr\n";
}


	my $result = $dbh->selectall_arrayref($statement);
	unless ($result) {
		# check for errors after every single database call
		print "dbh->selectall_arrayref($statement) failed!\n";
		print "DBI::err=[$DBI::err]\n";
		print "DBI::errstr=[$DBI::errstr]\n";
		exit;
	}

	my @resSet = @{$result};
	if ( $#resSet == -1 ) {          
		print "no results\n";
		exit;
	}

	foreach my $row ( @{ $result } ) {
		my @result = @{ $row };
		# print "$result[0]\n";
		my $result =  $dbh->do("CALL RateCost('$result[0]');");
		unless ($result) {
		    # check for errors after every single database call
		    print "dbh->selectall_arrayref($statement) failed!\n";
		    print "DBI::err=[$DBI::err]\n";
		    print "DBI::errstr=[$DBI::errstr]\n";
			print "$result[0]\n";
		    exit;
	}


		if ($cmdline eq "astlog") {
		$result =  $dbh->do("update astlog set active = 0 where uniqueid = $result[0];"); }
	}                                         	
   

exit 0;

#############################################################################
sub load_config() {
		$runtime = localtime(time);
		if (-e "conf-astbill.conf"){
			open(CFG, "<conf-astbill.conf");
			
		} else {
			open(CFG, "</home/astbill/conf-astbill.conf");
		}
		# chdir ('../newdir') || die ("Could not set new directory");
        while(<CFG>) {
                chomp;
                my ($var, $val) = split(/\s*\=\s*/);
                $config{$var} = $val;
        }
        close(CFG);
		if ($config{odbc} eq "YES") {$jobstr = "XP";} # $ENV{"_"};
        else {$jobstr = $ENV{"_"};}
		print "Executing: $jobstr    $runtime\n";
		return $config;
}
