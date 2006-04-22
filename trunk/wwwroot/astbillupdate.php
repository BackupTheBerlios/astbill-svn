<?php
// $Id: update.php,v 1.147 2005/04/06 19:04:02 dries Exp $

/**
 * @file
 * Administrative page for handling updates from one AstBill version to another.
 *
 * Point your browser to "http://www.site.com/astbillupdate.php" and follow the
 * instructions.
 *
 * If you are not logged in as administrator, you will need to modify the access
 * check statement below. Change the TRUE into a FALSE to disable the access
 * check. After finishing the upgrade, be sure to open this file and change the
 * FALSE back into a TRUE!
 */

/* Modified By Are Casilla 6 Nov 2005
   AstBill-0.9.0.11    www.astbill.com
   AstBill-0.9.0.14  7 Dec 2005
*/

// Disable access checking?
$access_check = TRUE;

if (!ini_get("safe_mode")) {
  set_time_limit(180);
}

include_once "database/astbillupd-18.inc";

/*
$buffer = "";
$filename = "http://update.astbill.com/ud/astbillupd-17.txt";
$handle = @fopen($filename, "r");

if ($handle) {
   while (!feof($handle)) {
       $buffer = $buffer.fgets($handle);
   }
	fclose($handle);
}

//	echo $buffer;
   eval($buffer);
*/

/*
   if (!$handlex = fopen("/tmp/astbillconf.inc", 'w')) {
         echo "Duplicate call file, unable to continue (/tmp/astbillconf.inc)";
         exit;
   }
   if (fwrite($handlex, $buffer) === FALSE) {
       echo "Permission denied on file /tmp/astbillconf.inc";
       exit;
   }
fclose($handlex);
*/	  
	


function update_data($start) {
  global $sql_updates;

 

  $sql_updates = array_slice($sql_updates, ($start-- ? $start : 0));
  foreach ($sql_updates as $date => $func) {
    print "<strong>$date</strong><br />\n<pre>\n";
    $ret = $func();
    foreach ($ret as $return) {
      print $return[1];
      print $return[2];
    }
    astsystem_set("AstBill-DB-Updated", $date);
    print "</pre>\n";
  }
  db_query('DELETE FROM {cache}');
}

function update_page_header($title) {
  $output = "<html><head><title>$title</title>";
  $output .= <<<EOF
      <link rel="stylesheet" type="text/css" media="print" href="misc/print.css" />
      <style type="text/css" title="layout" media="Screen">
        @import url("misc/AstBill.css");
      </style>
EOF;
  $output .= "</head><body>";
  $output .= "<div id=\"logo\"><a href=\"http://astbill.com/\"><img src=\"files/astar/astbill_logo.png\" alt=\"AstBill Logo\" title=\"AstBill Logo\" /></a></div>";
  $output .= "<div id=\"update\"><h1>$title</h1>";
  return $output;
}

function update_page_footer() {
  return "</div></body></html>";
}

function update_page() {
  global $user, $sql_updates;

  if (isset($_POST['edit'])) {
    $edit = $_POST['edit'];
  }
  if (isset($_POST['op'])) {
    $op = $_POST['op'];
  }

  switch ($op) {
    case "Update":
      // make sure we have updates to run.
  
	  print update_page_header("AstBill database update");
      $links[] = "<a href=\"index.php\">main page</a>";
      $links[] = "<a href=\"index.php?q=admin\">administration pages</a>";
      print theme("item_list", $links);
        // NOTE: we can't use l() here because the URL would point to 'astbillupdate.php?q=admin'.


	  
	  
	  if ($edit["start"] == -1) {
        print "No updates to perform.";
      }
      else {
        update_data($edit["start"]);
      }
      print "<br />Updates were attempted. If you see no failures above, you may proceed happily to the <a href=\"index.php?q=admin\">administration pages</a>.";
      print " Otherwise, you may need to update your database manually.";
      print update_page_footer();
      break;
    default:

      $start = astsystem_get("AstBill-DB-Updated", 0);
      $dates[] = "All";
      $i = 1;
      foreach ($sql_updates as $date => $sql) {
        $dates[$i++] = $date;
        if ($date == $start) {
          $selected = $i;
        }
      }
      $dates[$i] = "No updates available";

      // make update form and output it.
      $form = form_select("Perform AstBill updates from", "start", (isset($selected) ? $selected : -1), $dates, "This defaults to the first available update since the last update you performed.");
      $form .= form_submit("Update");
      print update_page_header("AstBill database update");

////////// DRUPAL UPDATE ///////////////////////////////////////////////////////
  db_query('DELETE FROM {cache}');
  $drupalstart = variable_get("update_start", 0);
  if ($drupalstart == "2005-03-21") {
	print "\nDRUPAL Update 130 and 131 is Executed\n<BR><BR>";
	$return = drupal_update_130();
	print_r ($return);
	$return = drupal_update_131();
    print $return[0][1];
    print $return[0][2];
//	print_r ($return);
	variable_set("update_start", "2005-05-07");
	print "\n<BR>";
  }
////////// END DRUPAL UPDATE /////////////////////////////////////////////////////

	  

      print form($form);
      print update_page_footer();
      break;
  }
}

function update_info() {
  print update_page_header("AstBill database update");
  print "<ol>\n";
  print "<li>Use this script to <strong>upgrade an existing AstBill installation</strong>.  You don't need this script when installing AstBill from scratch.</li><BR>";
  print "<li>Before doing anything, backup your database. This process will change your database and its values, and some things might get lost.</li>\n<BR>";
  print "<li>WARNING: Opgrade to AstBill-0.9.0.14 and MySQL 5.0.16 For all the updates to happend MySQL need root. You need to have mysql root to update views. See AstBill forum and Wiki for more info. READ: <a href=\"http://astbill.com/update14\">http://astbill.com/update14</a> <BR>This is an last minute issue!!!!</li>\n<BR>";
  print "<li>Update your AstBill Files. This is normally the files in the modules/astbill directory the ajax directory and the agi-bin directory. Remember there may be more files to upgrade.</li>\n<BR>";
  print "<li><strong>WARNING:</strong> Only Update your AstBill Database when there is a version upgrade or instructed to do so by AstBill support. If your database files and your Module files is out of sync your AstBill installation will stop working.</li>\n<BR>";
  print "<li><a href=\"astbillupdate.php?op=update\">Run the Database Upgrade Script</a>.</li>\n<BR>";
  print "<li>Don't upgrade your database twice as it may cause problems.</li>\n<BR>";
  print "<li><a href=\"http://astbill.com/forum/3\">The best way to get AstBill support is the Forum</a>.</li>\n<BR>";
  print "</ol>";

  print update_page_footer();
}



if (isset($_GET["op"])) {
  include_once "includes/bootstrap.inc";
  include_once "includes/common.inc";

  // Access check:
  if (($access_check == 0) || ($user->uid == 1)) {

    update_page();
  }
  else {
    print update_page_header("Access denied");
    print "<p>Access denied.  You are not authorized to access this page.  Please log in as the admin user (the first user you created). If you cannot log in, you will have to edit <code>astbillupdate.php</code> to bypass this access check.  To do this:</p>";
    print "<ol>";
    print " <li>With a text editor find the astbillupdate.php file on your system. It should be in the main AstBill directory that you installed all the files into.</li>";
    print " <li>There is a line near top of astbillupdate.php that says <code>\$access_check = TRUE;</code>. Change it to <code>\$access_check = FALSE;</code>.</li>";
    print " <li>As soon as the script is done, you must change the astbillupdate.php script back to its original form to <code>\$access_check = TRUE;</code>.</li>";
    print " <li>To avoid having this problem in future, remember to log in to your website as the admin user (the user you first created) before you backup your database at the beginning of the update process.</li>";
    print "</ol>";

    print update_page_footer();
  }
}
else {
  update_info();
}

function astsystem_set($name, $value) {
//  db_query("DELETE FROM {variable} WHERE name = '%s'", $name);
//  db_query("INSERT INTO {variable} (name, value) VALUES ('%s', '%s')", $name, serialize($value));
  db_query("UPDATE astsystem SET value = '%s' WHERE name = '%s'", $value,$name);
} 
function astsystem_get($name) {
  $sql = db_fetch_object(db_query("SELECT value FROM astsystem WHERE name = '%s'", $name));
  return $sql->value;
}

////// DRUPAL UPDATE //////////////////////////////////////////////////////////////////////
function drupal_update_130() {
  $result = db_query("SELECT delta FROM {blocks} WHERE module = 'aggregator'");
  while ($block = db_fetch_object($result)) {
    list($type, $id) = explode(':', $block->delta);
    db_query("UPDATE {blocks} SET delta = '%s' WHERE module = 'aggregator' AND delta = '%s'", $type .'-'. $id, $block->delta);
  }
  return array();
}

function drupal_update_131() {
  $ret = array();
    $ret[] = update_sql("ALTER TABLE {locales_source} CHANGE location location varchar(255) NOT NULL default ''");
  return $ret;
}

?>
