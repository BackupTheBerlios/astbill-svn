#!/usr/bin/perl -w
#
# This file have been replaced with the AstBill Asterisk / Manager Web Interface
# DONT USE
#
# If you are using Asterisk 1.09 and below you need to use the Perl Script
# astcreateaccount.pl to create your configuration files. This script will create 3 files.
#
# /etc/asterisk/sip_additional.conf
# /etc/asterisk/iax_additional.conf
# /etc/asterisk/voicemail_additional.conf
#
# The script will also reload asterisk if the correct username and password is in the file /etc/asterisk/manager.conf
# You have to update the end of this perl script with the right username for Asterisk Manager Interface.
#
#
#
# AstBill  -- Billing, Routing and Management software for Asterisk and MySQL using Drupal
#
# www.astbill.com
#
# Asterisk -- A telephony toolkit for Linux.
# Drupal   -- An Open source content management platform.
#
# 
# Copyright (C) 2005, AOFFICE NOMINEE SECRETARIES LIMITED, UNITED KINGDOM.
#
# Andreas Mikkelborg <adoroar [Guess What?] astartelecom.com>
# Are Casilla        <areast  [Guess What?] astartelecom.com>
#
#
# This program is free software, distributed under the terms of
# the GNU General Public License
#
# 2006.03.17 Version 0.9.18
# 
#  
# 
# 3.7 If you want to use Static configuration of Asterisk. This is needed for Asterisk 1.09 and below
# you need to install the Perl Module: Net-Telnet-3.03
# Net-Telnet-3.03 is included from AstBill-0.9.0.5 or you can download from
# http://search.cpan.org/CPAN/authors/id/J/JR/JROGERS/Net-Telnet-3.03.tar.gz
# 
# This Perl Module is only used with the AstBill Perl file 
# /admin/astcreateaccount.pl
# It is used to connect to the Asterisk Manager Interface and reload Asterisk configuration
# when new configuration files are written.
# 
# cd /home/astbill/astbill-0.9.x.x/Net-Telnet-3.03
# 
#         Create a makefile by running Makefile.PL using the perl
#         program into whose library you want to install and then run
#         make three times:
# 
#             perl Makefile.PL
#             make
#             make test
#             make install
# 
#

# use Net::Telnet ();
use DBI;

# Must Standard configurations for AstBill REALTIME will not use this program.
#
# $active = 5 if used with Asterisk REALTIME configuration. Only possible on Asterisk Version 1.2 Beta and above.
# $active = 1 if used with Static Asterisk configuration. Must be used for Asterisk Version 1.09 and below.
my $active = "5";

$config = &load_config();
print "config.conf loaded. dbhost = $config{dbhost}\n";

my $runtime = localtime(time);
my $jobstr = "";

# WARNING: this files will be substituted by the output of this program
my $astpath  = "/etc/asterisk/"; if ($config{odbc} eq "YES") { $astpath    = ""; }

#my $sip_conf       = $astpath . "sip_additional.conf";
#my $iax2_conf      = $astpath . "iax_additional.conf";
#my $voicemail_conf = $astpath . "voicemail_additional.conf";

#print STDERR "sip Output to: $sip_conf\n";
#print "sip Output to:       $sip_conf\n";
#print "iax Output to:       $iax2_conf\n";
#print "voicemail Output to: $voicemail_conf\n";


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



#### VOICEMAIL CONF ###########################################################################################################################

#[default]
#5000 => 5000,Andreas,andreas@aoffice.co.uk ,,
#5001 => 5001,Are,are@aoffice.co.uk ,,
#5002 => 5002,Are,are@aoffice.co.uk ,,
#5003 => 5003,bug phone,andreas@aoffice.co.uk ,,
#5006 => 5006,Josef,josef@turbosite.net ,,


#              0            1           2                                 3         4     5   
$SQL = "SELECT accountcode, mailboxpin, mailboxemail, IFNULL(callerid,'') callerid, mail, name 
  FROM astaccount a, pbx_users p 
  where a.uid = p.uid and tech in (select actype from astactype)";


	$result = $dbh->selectall_arrayref($SQL);
	unless ($result) {
		# check for errors after every single database call
		print "dbh->selectall_arrayref($SQL) failed!\n";
		print "DBI::err=[$DBI::err]\n";
		print "DBI::errstr=[$DBI::errstr]\n";
		exit;
	}

	@resSet = @{$result};
	if ( $#resSet == -1 ) {          
		print "VoiceMail no results\n";
		# We need to go on to Restart Asterisk
		# close EXTEN;
		# exit;
	}

	foreach my $row ( @{ $result } ) {
		my @result = @{ $row };
		$mailbox = trimwhitespace($result[0]);
		$callerid = trimwhitespace($result[3]);

		 if ( $callerid !~/</ ) {
			 $callerid = $callerid;
		 }
		 else { # If Caller id is like this "Are <70100>" dont append extension number
			 # {$callerid = $callerid . " <$result[0]>"; }; 

			# index($callerid, "<", POSITION) 
			$p = index($callerid, "<");
			$callerid = substr($callerid, 0, $p);
			$callerid = trimwhitespace($callerid);
		 }  
		$mailboxmail = trimwhitespace($result[2]);
		if (length($mailboxmail) <= 1) { $mailboxmail = trimwhitespace($result[4]) }
		# if (length($mailboxmail) <= 1) { $mailboxmail = trimwhitespace($result[4]) }
		
		# if (length($mailbox) == 0) { $mailbox = $result[0]; };
		if ($config{odbc} ne "YES") {system("mkdir -p /var/lib/asterisk/sounds/voicemail/default/$mailbox/");}
		if ($config{odbc} ne "YES") {system("mkdir -p /var/spool/asterisk/voicemail/default/$mailbox/");}
		print "$result[0] $result[1] $callerid\n";
	}          
close EXTEN;

#print "\nREMEMBER to reload Asterisk with the reload command from the CLI interface!\n";

# print "\nRELOADING Asterisk ...\n";
# reload_asterisk();
#print "\nAsterisk reloaded!\n";

exit 0;

sub load_config() {
		$runtime = localtime(time);
		if (-e "astbill.conf"){
			open(CFG, "<astbill.conf");
			
		} else {
			open(CFG, "</home/astbill/astbill.conf");
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

sub reload_asterisk{  #uses manager api to reload Asterisk
	#asterisk server manager interface information
#	$mgrUSERNAME='astbillman';
#	$mgrSECRET='ab87AstBtii3';
#	$server_ip='127.0.0.1';
	
#	$tn = new Net::Telnet (Port => 5038,
#				Prompt => '/.*[\$%#>] $/',
#				Output_record_separator => '',
#				Errmode    => 'return'
#				);
#	
#	#connect to manager and login			
#	$tn->open("$server_ip");
#	$tn->waitfor('/0\n$/');                  	
#	$tn->print("Action: Login\nUsername: $mgrUSERNAME\nSecret: $mgrSECRET\n\n");
#	$tn->waitfor('/Authentication accepted\n\n/');
#
#	#issue command
#	$tn->print("Action: command\nCommand: reload\n\n\n");
#	$tn->waitfor('/Response: Follows\n/');
#	#($schannels)=$tn->waitfor('/.*active SIP channel/') or die "Unable to get channels", $tn->lastline;    # wait for asterisk to process
#	$tn->print("Action: Logoff\n\n");
	# return $schannels;
}

