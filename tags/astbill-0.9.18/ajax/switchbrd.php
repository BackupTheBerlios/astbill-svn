<?
/*
 * AstBill  -- Billing, Routing and Management software for Asterisk and MySQL using Drupal
 *
 * www.astbill.com
 *
 * Asterisk -- A telephony toolkit for Linux.
 * Drupal   -- An Open source content management platform.
 *
 * 
 * Copyright (C) 2005, AOFFICE NOMINEE SECRETARIES LIMITED, UNITED KINGDOM.
 *
 * Andreas Mikkelborg <adoroar [Guess What?] astartelecom.com>
 * Are Casilla        <areast  [Guess What?] astartelecom.com>
 *
 *
 * This program is free software, distributed under the terms of
 * the GNU General Public License
 *
 * 2006.03.17 Version 0.9.18
 * 
 */

$filename = "/home/astbill/astbill.conf";
$handle = @fopen($filename, "r");

if ($handle) {
   while (!feof($handle)) {
       $buffer = fgets($handle);
       $split = split("=", $buffer);
       $var1 = trim($split['0']);
       $var2 = trim($split['1']);
       
       if ($var1 == 'dbhost') {
	       $dbhost = $var2;
       }
       
       if ($var1 == 'dbname') {
	       $dbname = $var2;
       }
       
       if ($var1 == 'dbuser') {
	       $dbuser = $var2;
       }
       
       if ($var1 == 'dbpass') {
	       $dbpass = $var2;
       }

   }
   fclose($handle);
}

mysql_connect($dbhost,$dbuser,$dbpass);
@mysql_select_db($dbname) or die("Unable to select database");

$result = mysql_query("SELECT DISTINCT channel, astcdr.accountcode, callednum, astcdr.date_created, astcdr.trunk from astcdr, astaccount WHERE astcdr.accountcode = astaccount.accountcode and astaccount.uid = '".arg(0)."' and dialstatus is null");
$pass = 0;

while ($sql = mysql_fetch_object($result)) {
echo $sql->accountcode.' '.$sql->callednum.' '.$sql->date_created.' '.$sql->channel.' '.$sql->trunk;
print "\n";
$pass = '1';
}

if ($pass == '0') {
	echo 'no Channels in use';
	print "\n";
}


mysql_free_result($result);
mysql_close();

function arg($index) {
  static $arguments, $q;

  if (empty($arguments) || $q != $_GET['q']) {
    $arguments = explode('/', $_GET['q']);
    $q = $_GET['q'];
  }

  if (isset($arguments[$index])) {
    return $arguments[$index];
  }
} 

?>
