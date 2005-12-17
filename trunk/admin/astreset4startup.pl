#!/usr/bin/perl -w
#
# WARNING - Don't RUN this program when Asterisk is running.
#
# This files is used to reset all database counters
# It is to be used everytime asterisk starts to ensure trunk and account usage is 0
# It will also reset the credit reservation table.
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
# * 2005.09.26 Version 0.9.0.9    
# * 
# */


use DBI;
################### BEGIN OF CONFIGURATION ####################

$config = &load_config();
print "config.conf loaded. dbhost = $config{dbhost}\n";

my $runtime = localtime(time);
my $jobstr = "";


sub trimwhitespace($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

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

#### ###########################################################################################################################
my $result = "";
$result = $dbh->do("update astaccount set usagecount = 0 where usagecount <> 0");
$result = $dbh->do("update asttrunk set usagecount = 0 where usagecount <> 0");
$result = $dbh->do("delete from astcdr where dialstatus is null");
# $result = $dbh->do("update aststatus set asterisk_started = Now() where serverid = '$config{HostedOn}'");
$result = $dbh->do("delete from astcreditres");

# + Update asterisk Version to aststatus

print "DONE: usagecounts = 0!\n";

exit 0;

