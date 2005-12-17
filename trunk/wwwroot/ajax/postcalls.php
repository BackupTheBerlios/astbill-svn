<?

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


$pass = 1;
$accountcode = arg(0); // Number to call
$uid = arg(1); // User doing the calling


$callbackto = mysql_fetch_object(mysql_query("SELECT callbackto FROM astuser WHERE uid = '".$uid."'"));
$tech = mysql_fetch_object(mysql_query("SELECT tech FROM astaccount WHERE accountcode = '".$callbackto->callbackto."'"));
$callid = mysql_fetch_object(mysql_query("SELECT callerid FROM astaccount WHERE accountcode = '".$callbackto->callbackto."'"));


if (empty($tech->tech)) {print "ERROR: The Callback Number configured is Not Valid!"; $pass = 0;}
if ($tech->tech == "FOR") { print "ERROR: Callback to Virtual Number Not Supported!"; $pass = 0;}
if ($tech->tech == "VIR") { print "ERROR: Callback to Virtual Number Not Supported!"; $pass = 0;}


if ($pass == 1) {

	
if (empty($callid->callerid)){
	$callid->callerid = 'Unknown';
}
	
$channel = $tech->tech.'/'.$callbackto->callbackto;
$callerid = $callid->callerid;
$maxretries = '5';
$retrytime = '300';
$waittime = '45';
$context = 'default';
$extension = '00'.$accountcode;
$priority = '1';



$timecreated = date('Y-m-d H-i-s');
$filename = 'outgoing.'.rand(1, 65535).'.call';
$tmppath = '/var/spool/asterisk/tmp';
$callpath = '/var/spool/asterisk/outgoing';
$content = "# Generated by postcall.php
# Created: ".$timecreated."
#          ".$tmppath."/".$filename."
Channel: ".$channel."
Callerid: ".$callerid."
MaxRetries: ".$maxretries."
RetryTime: ".$retrytime."
WaitTime: ".$waittime."
Context: ".$context."
Extension: ".$extension."
Priority: ".$priority."
";


   if (!$handle = fopen($tmppath."/".$filename, 'x')) {
         echo "Duplicate call file, unable to continue (".$tmppath."/".$filename.")";
         exit;
   }

   if (fwrite($handle, $content) === FALSE) {
       echo "Permission denied on file ".$tmppath."/".$filename;
       exit;
   } else {
  
  // echo "Success, wrote ($content) to file ($filename)";
  echo "Calling ".$accountcode;
  rename ($tmppath."/".$filename, $callpath.'/'.$filename);
  //unlink ($tmppath."/".$filename);

   }



fclose($handle);
//mysql_free_result($result);
mysql_close();

} 


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
