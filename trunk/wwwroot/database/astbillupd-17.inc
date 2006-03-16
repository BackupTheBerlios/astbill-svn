<?php

/* $Id: updates.inc,v 1.100.2.5 2005/05/07 08:36:24 dries Exp $ */

/* First Modified By Are Casilla for AstBill 6 Nov 2005
   12 Nov 2005
   AstBill-0.9.0.12    www.astbill.com
   Andreas Mikkelborg <adoroar [Guess What?] astartelecom.com>
   Are Casilla        <areast  [Guess What?] astartelecom.com>
*/

/**
 * How to run: http://yoursite.com/astbillupdate.php
 *
 * All incremental database updates performed between AstBill releases.
 */

// Define the various updates in an array("date : comment" => "function");
$sql_updates = array(
  "2005-11-09: first update since AstBill-0.9.0.12 release" => "astbill_update_011",
  "2005-11-10" => "astbill_update_012",
  "2005-11-17a" => "astbill_update_013",
  "2005-11-17b" => "astbill_update_014",
  "2005-11-17c" => "astbill_update_015",
  "2005-11-17d" => "astbill_update_016",
  "2005-11-30" => "astbill_update_017",
  "2005-11-30b" => "astbill_update_018",
  "2005-11-30d" => "astbill_update_019",
  "2005-11-30e" => "astbill_update_020",
  "2005-11-30f" => "astbill_update_021",
  "2005-12-01" => "astbill_update_022",
  "2005-12-01b" => "astbill_update_023",
  "2005-12-09: first update since AstBill-0.9.0.14 release" => "astbill_update_024",
  "2005-12-15" => "astbill_update_025",
  "2005-12-16" => "astbill_update_026",
  "2005-12-17" => "astbill_update_027",
  "2005-12-18" => "astbill_update_028",
  "2005-12-19" => "astbill_update_029",
  "2005-12-31" => "astbill_update_030",
  "2006-01-02" => "astbill_update_031",
  "2006-01-03" => "astbill_update_032",
  "2006-01-06" => "astbill_update_033",
  "2006-01-07" => "astbill_update_034",
  "2006-02-14" => "astbill_update_035",
  "2006-03-04" => "astbill_update_036",
  "2006-03-12" => "astbill_update_037",
  "2006-03-14" => "astbill_update_038",
  "2006-03-15" => "astbill_update_039",
);

function update_sql($sql) {
  $edit = $_POST["edit"];
  $result = db_query($sql);
  if ($result) {
    return array('1', nl2br(htmlentities($sql)) ." ", "<div style=\"color: green;\">OK</div>\n");
  }
  else {
    return array('0', nl2br(htmlentities($sql)) ." ", "<div style=\"color: red;\">FAILED</div>\n");
  }
}

function astbill_update_011() {
  $ret = array();
  $ret[] = update_sql("DROP TABLE IF EXISTS astreseller");
  $ret[] = update_sql("CREATE TABLE `astcompany` (
  `accountcode` int(10) NOT NULL,
  `company` varchar(128) NOT NULL default '',
  `contactname` varchar(128) NOT NULL default '',
  `address1` varchar(128) NOT NULL default '',
  `address2` varchar(128) NOT NULL default '',
  `zip` varchar(64) NOT NULL default '',
  `city` varchar(128) NOT NULL default '',
  `state` varchar(128) default NULL,
  `country` varchar(128) NOT NULL,
  `phone` varchar(128) NOT NULL default '',
  `phone2` varchar(128) NOT NULL default '',
  `fax` varchar(128) NOT NULL default '',
  `status` tinyint(1) NOT NULL default '1',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`accountcode`),
  KEY `company` (`company`),
  KEY `contactname` (`contactname`)
)");
  return $ret;
}

function astbill_update_012() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astaccount` ADD `master` VARCHAR( 40 ) AFTER `accountcode` ,
ADD `submaster` VARCHAR( 40 ) AFTER `master`");
  return $ret;
}

function astbill_update_013() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astaccount` ADD `fullcontact` VARCHAR( 80 ) AFTER `canreinvite`");
  return $ret;
}

function astbill_update_014() {
  $ret = array();
  $ret[] = update_sql("DROP VIEW IF EXISTS asv_sip");
  $ret[] = update_sql("create view asv_sip as SELECT accountcode name,accountcode username,type,secret,host,callerid,context,dtmfmode,mailbox,nat,qualify,fromuser,authuser,fromdomain,fullcontact,insecure,canreinvite,disallow,allow,restrictid,ipaddr,port,regseconds FROM astaccount where (tech = 'SIP' or tech = 'IN-SIP') and active = 1");
  return $ret;
}

function astbill_update_015() {
  $ret = array();
  $ret[] = update_sql("DROP VIEW IF EXISTS asv_iax");
  $ret[] = update_sql("create view asv_iax as SELECT accountcode name,accountcode username,type,
secret,notransfer,inkeys,auth,accountcode,amaflags,callerid,context,defaultip,
host,language,dtmfmode,mailbox,deny,permit,qualify,disallow,allow,ipaddr,port,
regseconds FROM astaccount where (tech = 'IAX' or tech = 'IN-IAX' ) and active = 1
  ");
  return $ret;
}

function astbill_update_016() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astcdr` ADD `callerid` VARCHAR( 80 ) AFTER `callednum`");
  return $ret;
}

function astbill_update_017() {
  $ret = array();
  $ret[] = update_sql("CREATE TABLE `astcountryprefix` (`CountryPrefix` int(3) NOT NULL,`allow00` tinyint(1) 
  unsigned NOT NULL default '1',`allow011` tinyint(1) unsigned NOT NULL default '1',`locallength` tinyint(2) 
  unsigned NOT NULL default '0',`timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP, PRIMARY KEY  (`CountryPrefix`))");
  $ret[] = update_sql("INSERT INTO `astcountryprefix` (`CountryPrefix`, `allow00`, `allow011`, `locallength`, `timestamp`) VALUES (44, 1, 0, 0, '2005-11-30 10:40:34')");
  $ret[] = update_sql("INSERT INTO `astcountryprefix` (`CountryPrefix`, `allow00`, `allow011`, `locallength`, `timestamp`) VALUES (47, 1, 1, 8, '2005-11-30 10:41:02')");
  return $ret;
}

function astbill_update_018() {
  $ret = array();
  $ret[] = update_sql("UPDATE `astroute` SET `trunk` = 'DEF' WHERE `id` =129 and trunk = 'BUZZBUD' LIMIT 1");
  return $ret;
}

function astbill_update_019() {
  $ret = array();
  $ret[] = update_sql("select count(*) from astaccount");
  return $ret;
}

function astbill_update_020() {
  $ret = array();
  $ret[] = update_sql("
CREATE TABLE astanicli (
`accountcode` varchar(40) NOT NULL,
`anicli` varchar(40) NOT NULL,
`comment` varchar(255) default NULL,
timestamp timestamp NOT NULL default CURRENT_TIMESTAMP,
PRIMARY KEY (`accountcode`,`anicli`)
)");
  return $ret;
}

function astbill_update_021() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astcdr` ADD `master` VARCHAR( 40 ) AFTER `accountcode` ,ADD `submaster` VARCHAR( 40 ) AFTER `master`");
  $ret[] = update_sql("ALTER TABLE `astcdr` ADD `amaflags` VARCHAR( 80 ) AFTER `callerid`");
  $ret[] = update_sql("ALTER TABLE `astcdr` ADD INDEX ( `accountcode` )");
  return $ret;
}

function astbill_update_022() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astsystem` ADD `viewstatus` VARCHAR( 2 ) DEFAULT 'N' NOT NULL AFTER `comment`");

  $ret[] = update_sql("INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `viewstatus` , `timestamp` )
VALUES ('DEF', 'default-tech', 'IAX', 'The default Channel type to use when creating new accounts', 'E', NOW( )
), ('DEF', 'default-brand', 'default', 'The default brand to use when creating new accounts', 'N', NOW( ))");

  $ret[] = update_sql("update astsystem set viewstatus = 'E'");
  $ret[] = update_sql("delete from astsystem WHERE `serverid`= 'DEF' AND `name` = 'AstBill-DB-Version' LIMIT 1 ");
  $ret[] = update_sql("UPDATE `astsystem` SET `value` = 'AstBill-0.9.0.14', `viewstatus` = 'D' WHERE `serverid` = 'DEF' and `name` = 'AstBill-Version' LIMIT 1 ");
  $ret[] = update_sql("UPDATE `astsystem` SET `viewstatus` = 'D' WHERE `serverid` = 'DEF' and `name` = 'AstBill-DB-Updated' LIMIT 1 ");
  $ret[] = update_sql("UPDATE `astsystem` SET `value` = Now(), `viewstatus` = 'D' WHERE `serverid` = 'DEF' and `name` = 'AstBill-GUI-Updated' LIMIT 1 ");
  $ret[] = update_sql("UPDATE `astsystem` SET `viewstatus` = 'N' WHERE `serverid` = 'DEF' and `name` = 'GlobalDialPrefix' LIMIT 1 ");
  return $ret;
}

function astbill_update_023() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astcdr` ADD `extension` VARCHAR( 80 ) AFTER `price`");
  return $ret;
}

function astbill_update_024() {
  $ret = array();
  $ret[] = update_sql("DROP VIEW IF EXISTS asvaccount2");
  $ret[] = update_sql("create view asvaccount2 as
SELECT asvaccount.accountcode, db_prefix, uid, tech, secret,active,usagecount, LEFT(accountname,15) as accountname,  round((sumprice/100),2) as sumprice, 
sumpaid, sumpaid - round((sumprice/100),2) as balance, creditlimit,startingcredit, countcalls FROM asvaccount, astaccount
where asvaccount.accountcode = astaccount.accountcode");

 $ret[] = update_sql("ALTER TABLE `astuser` ADD `db_prefix` VARCHAR( 40 ) NOT NULL default 'pbx_' FIRST");
 $ret[] = update_sql("ALTER TABLE `astuser` DROP PRIMARY KEY ,ADD PRIMARY KEY ( `db_prefix` , `uid` )");
 $ret[] = update_sql("DROP VIEW IF EXISTS asv_friend");

 $ret[] = update_sql("create view asv_friend as SELECT uid,db_prefix,astaccount.serverid,astaccount.accountcode,astaccount.username,accountname publicnumber,
astaccount.tech,type,secret,forwardto,fromuser,authuser,fromdomain,nat,qualify,host,port,callerid,context,dtmfmode,
insecure,canreinvite,disallow,allow,restrictid,astaccount.comment,active,date_created,
timestamp FROM astaccount where tech like 'IN%'");

  return $ret;
}

function astbill_update_025() {
  $ret = array();
  $ret[] = update_sql("delete from astsystem WHERE `serverid`= 'DEF' AND `name` = 'CountryPrefix' LIMIT 1 ");
  $ret[] = update_sql("delete from astsystem WHERE `serverid`= 'DEF' AND `name` = 'default-tech' LIMIT 1 ");
  $ret[] = update_sql("delete from astsystem WHERE `serverid`= 'DEF' AND `name` = 'default-brand' LIMIT 1 ");
  return $ret;
}

function astbill_update_026() {
  $ret = array();
  $ret[] = update_sql("CREATE TABLE `astplans` (`name` varchar(40) NOT NULL default '',`currency` varchar(3) NOT NULL default 'USD',
`language` varchar(10) default NULL,`publishednum` varchar(40) default NULL,`did` varchar(40) default NULL,
`markup` decimal(10,2) NOT NULL default '0.00',`billincrement` tinyint(8) NOT NULL default '1',`connectcharge` decimal(10,2) NOT NULL default '0.00',
`status` tinyint(1) NOT NULL default '1',PRIMARY KEY  (`name`))");

  $ret[] = update_sql("INSERT INTO `astplans` SELECT * from astbrand");
  $ret[] = update_sql("drop table astbrand");
  $ret[] = update_sql("delete from pbx_cache");
  return $ret;
}
function astbill_update_027() {
  $ret = array();
  $ret[] = update_sql("INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `viewstatus`)
VALUES ('DEF','def-password-length',6,'The Password Length to use when creating new accounts','E')");

  $ret[] = update_sql("INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `viewstatus`)
VALUES ('DEF','def-voicemail-pin-length',4,'The Voicemail PIN/Password Length to use when creating new accounts','E')");

 $ret[] = update_sql("INSERT INTO `astemailtext` (`EmailText`, `Subject`, `BodyText`, `BodyHTML`, `SenderEmail`, `bcc`, `Pic1`, `Pic2`, `Pic3`, `Date_Created`) VALUES ('pbx_ASTARREG', 'You VOIP Telephone Account is Activated', 'Thank you for registering at AstBill.com. You may now use your soft phone to make calls.\r\n\r\nYour AstBill VOIP Number is: %username%.\r\n\r\nYou can call your friends using AstBill for free. Just dial their AstBill Telephone number.\r\n\r\nPlease configure your soft phone using the following information:\r\n\r\nNetwork Name: AstBill\r\nNetwork Type: IAX\r\nPlease select external network when the soft phone wizard ask for network.\r\n\r\nServer: iax.astbill.com\r\nUsername: %username%\r\nPassword: %password%\r\n\r\nAfter configuring the soft phone you may wish to dial the following to test the system.\r\n\r\n	500 Speaking Clock\r\n	502 Echo Test\r\n	501 Monkey Test\r\n\r\nHappy Talking ...\r\n\r\n\r\nAstBill.com \r\nCustomer support', NULL, 'noreply@astbill.com', '', NULL, NULL, NULL, NULL)");

  return $ret;
}

function astbill_update_028() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astaccount` ADD `forcecallerid` VARCHAR(80) default NULL AFTER `callerid`");
  $ret[] = update_sql("ALTER TABLE `astaccount` ADD `hidecallerid` tinyint(1) NOT NULL default '1' AFTER `forcecallerid`");
  return $ret;
}

function astbill_update_029() {
  $ret = array();
  $ret[] = update_sql("CREATE TABLE `astacgroup` (
  `gtype` varchar(40) NOT NULL,
  `gname` varchar(255) NOT NULL default '',
  `mastergroup` varchar(40) NOT NULL default 'DID',
  `active` tinyint(1) NOT NULL default '1',
  `comment` varchar(255) default NULL,
  PRIMARY KEY  (`gtype`)
);");

  $ret[] = update_sql("ALTER TABLE `astaccount` ADD `acgroup` VARCHAR(40) default NULL AFTER `tech`");
  $ret[] = update_sql("update astsystem set value = '/topup/'  where name = 'TopUpURL' and serverid = 'DEF'");

  return $ret;
}

function astbill_update_030() {
  $ret = array();
  $ret[] = update_sql("DROP VIEW IF EXISTS `asvcall`");
  $ret[] = update_sql("create view asvcall as
SELECT astcdr.uniqueid, astcdr.accountcode, astcdr.callednum, astuser.uid, astuser.brand, astuser.CountryPrefix, astplans.markup, astplans.billincrement
FROM astcdr, astaccount, astuser, astplans
WHERE astcdr.accountcode=astaccount.accountcode and astaccount.uid=astuser.uid and astuser.brand=astplans.name");

  $ret[] = update_sql("DROP VIEW IF EXISTS asvprice_uk");
  $ret[] = update_sql("create view asvprice_uk as
SELECT astpricelist.name, round((price / 100),4) as price, concat(astcurrency.currencysymbol,' ',
round((price / 100),4)) as pricecur, astplans.name brand, astcurrency.currencysymbol cur,astcurrency.currency cur2
FROM (astplans INNER JOIN astpricelist ON astplans.name = astpricelist.brand)
INNER JOIN astcurrency ON astplans.currency = astcurrency.currency
where pattern like '44%'
GROUP BY astpricelist.name, astplans.name, astcurrency.currencysymbol
ORDER BY weight, name");

  $ret[] = update_sql("DROP VIEW IF EXISTS `asvprice_uk_all`");
  $ret[] = update_sql("create view asvprice_uk_all as
SELECT pattern, astpricelist.name, round((price / 100),4) as price, concat(astcurrency.currencysymbol,
round((price / 100),4)) as pricecur, astplans.name brand, astcurrency.currencysymbol cur,astcurrency.currency cur2
FROM (astplans INNER JOIN astpricelist ON astplans.name = astpricelist.brand)
INNER JOIN astcurrency ON astplans.currency = astcurrency.currency
where pattern like '44%'
ORDER BY brand, pattern");

  $ret[] = update_sql("DROP VIEW IF EXISTS `asvprice_usa`");
  $ret[] = update_sql("create view asvprice_usa as
SELECT pattern, astpricelist.name, round((price / 100),4) as price, concat(astcurrency.currencysymbol,
round((price / 100),4)) as pricecur, astplans.name brand, astcurrency.currencysymbol cur,astcurrency.currency cur2
FROM (astplans INNER JOIN astpricelist ON astplans.name = astpricelist.brand)
INNER JOIN astcurrency ON astplans.currency = astcurrency.currency
where astpricelist.name like 'USA%'
ORDER BY weight, name");

  $ret[] = update_sql("DROP VIEW IF EXISTS asvprice");
  $ret[] = update_sql("create view asvprice as
SELECT pattern, astpricelist.name, round((price / 100),4) as price, concat(astcurrency.currencysymbol,
round((price / 100),4)) as pricecur, astplans.name brand, astcurrency.currencysymbol cur,astcurrency.currency cur2
FROM (astplans INNER JOIN astpricelist ON astplans.name = astpricelist.brand)
INNER JOIN astcurrency ON astplans.currency = astcurrency.currency
ORDER BY brand, pattern");

  $ret[] = update_sql("DROP VIEW IF EXISTS asvprice_group");
  $ret[] = update_sql("create view asvprice_group as
SELECT astpricelist.name, round((price / 100),4) as price, concat(astcurrency.currencysymbol,
round((price / 100),4)) as pricecur, astplans.name brand, astcurrency.currencysymbol cur,astcurrency.currency cur2
FROM (astplans INNER JOIN astpricelist ON astplans.name = astpricelist.brand)
INNER JOIN astcurrency ON astplans.currency = astcurrency.currency
where brand = 'default'
GROUP BY astpricelist.name, astplans.name, astcurrency.currencysymbol
ORDER BY brand, astpricelist.name;");

  
  $ret[] = update_sql("DROP VIEW IF EXISTS asvpricecountry");
  $ret[] = update_sql("create view asvpricecountry as
SELECT DISTINCT MIN(astpricelist.pattern) AS countrycode, astpricelist.name
FROM astpricelist GROUP BY astpricelist.name order by astpricelist.name");

  $ret[] = update_sql("DROP VIEW IF EXISTS asvpricecountry2");
  $ret[] = update_sql("create view asvpricecountry2 as
SELECT DISTINCT MIN(astpricelist.pattern) AS countrycode
FROM astpricelist GROUP BY astpricelist.name order by astpricelist.name");

  return $ret;
}

function astbill_update_031() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astcompany` ADD `firstname` VARCHAR(128) default NULL AFTER `company`");
  $ret[] = update_sql("ALTER TABLE `astcompany` CHANGE `contactname` `lastname` VARCHAR( 128 ) NULL");
  return $ret;
}
function astbill_update_032() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `company` varchar(128) NULL default NULL AFTER `lastaccount`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `firstname` varchar(128) default NULL AFTER `company`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `lastname` varchar(128) default NULL AFTER `firstname`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `address1` varchar(128) default NULL AFTER `lastname`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `address2` varchar(128) default NULL AFTER `address1`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `zip` varchar(64) NULL default NULL AFTER `address2`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `city` varchar(128) NULL default NULL AFTER `zip`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `state` varchar(128) NULL default NULL AFTER `city`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `country` varchar(128) NULL default NULL AFTER `state`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `phone` varchar(128) NULL default NULL AFTER `country`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `phone2` varchar(128) NULL default NULL AFTER `phone`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `mobile` varchar(128) NULL default NULL AFTER `phone2`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `fax` varchar(128) NULL default NULL AFTER `mobile`");

  $ret[] = update_sql("ALTER TABLE `astuser` ADD `birthdate` date NULL default NULL AFTER `fax`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `valuecode` varchar(128) NULL default NULL AFTER `birthdate`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `birthdate2` varchar(128) NULL default NULL AFTER `birthdate`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `ordercode` varchar(128) NULL default NULL AFTER `valuecode`");
  $ret[] = update_sql("ALTER TABLE `astuser` ADD `ipaddr` varchar(128) NULL default NULL AFTER `comment`");
  return $ret;
}

function astbill_update_033() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astaccount` CHANGE `restrictcid` `restrictcid` CHAR( 6 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL");

  $ret[] = update_sql("ALTER TABLE `asthardwareid` ADD `mac1` varchar(6) NULL default NULL AFTER `hardware`");
  $ret[] = update_sql("ALTER TABLE `asthardwareid` ADD `mac2` varchar(6) NULL default NULL AFTER `mac1`");
  $ret[] = update_sql("ALTER TABLE `asthardwareid` ADD `mac3` varchar(6) NULL default NULL AFTER `mac2`");

  $ret[] = update_sql("ALTER TABLE `asthardware` ADD `mac4` varchar(6) NULL default NULL AFTER `mac3`");
  $ret[] = update_sql("ALTER TABLE `asthardware` ADD `mac5` varchar(6) NULL default NULL AFTER `mac4`");
  $ret[] = update_sql("ALTER TABLE `asthardware` ADD `mac6` varchar(6) NULL default NULL AFTER `mac5`");

  $ret[] = update_sql("ALTER TABLE `asthardware` DROP `uid`");
  $ret[] = update_sql("ALTER TABLE `asthardware` DROP `name`");
  $ret[] = update_sql("ALTER TABLE `asthardware` DROP `mac_address`");
  $ret[] = update_sql("ALTER TABLE `asthardware` DROP `secret`");
  $ret[] = update_sql("ALTER TABLE `asthardware` DROP `hardwaretype`");

  return $ret;
}

function astbill_update_034() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astinvoice` CHANGE `invid` `invoiceno` INT( 11 ) UNSIGNED NOT NULL AUTO_INCREMENT");
  $ret[] = update_sql("ALTER TABLE `astinvoice` ADD `db_prefix` varchar(40) NOT NULL AFTER `invoiceno`");
  $ret[] = update_sql("ALTER TABLE `astinvoice` ADD `invoice_date` datetime NOT NULL AFTER `uid`");
  $ret[] = update_sql("ALTER TABLE `astinvoice` ADD `due_date` datetime NOT NULL AFTER `invoice_date`");
  $ret[] = update_sql("ALTER TABLE `astinvoice` ADD INDEX `inv_db_prefix` ( `db_prefix` , `uid` , `invoiceno` )");
  $ret[] = update_sql("ALTER TABLE `astinvoice` ADD `freight` decimal(10,2) NOT NULL default 0 AFTER `currency`");
  $ret[] = update_sql("ALTER TABLE `astinvoice` ADD `adminfee` decimal(10,2) NOT NULL default 0 AFTER `freight`");
  $ret[] = update_sql("ALTER TABLE `astinvoice` ADD `invoicefee` decimal(10,2) NOT NULL default 0 AFTER `adminfee`");

  $ret[] = update_sql("ALTER TABLE `astinvoiceline` ADD `phoneno` varchar(40) NULL AFTER `lineno`");
  $ret[] = update_sql("ALTER TABLE `astinvoiceline` ADD `ptype` varchar(40) NULL AFTER `phoneno`");
  $ret[] = update_sql("ALTER TABLE `astinvoiceline` ADD `productcode` varchar(40) NULL AFTER `ptype`");
  $ret[] = update_sql("ALTER TABLE `astinvoiceline` CHANGE `title` `product` varchar(256) NULL");

  $ret[] = update_sql("ALTER TABLE `astinvoiceline` CHANGE `invid` `invoiceno` INT( 11 ) UNSIGNED NOT NULL");
  $ret[] = update_sql("ALTER TABLE `astinvoiceline` CHANGE `price` `price` decimal(10,4) NOT NULL default 0");

  $ret[] = update_sql("ALTER TABLE `astinvoice` CHANGE `invoice_date` `invoice_date` date NOT NULL");
  $ret[] = update_sql("ALTER TABLE `astinvoice` CHANGE `due_date` `due_date` date NOT NULL");
  $ret[] = update_sql("ALTER TABLE `astinvoice` ADD `kid` varchar(128) NULL AFTER `due_date`");
  $ret[] = update_sql("ALTER TABLE `astinvoice` ADD `period` varchar(128) NULL AFTER `kid`");

  $ret[] = update_sql("ALTER TABLE `astinvoice` ADD `sumexvat` decimal(10,2) NOT NULL default 0 AFTER `workflow`");
  $ret[] = update_sql("ALTER TABLE `astinvoice` ADD `vat` decimal(10,2) NOT NULL default 0 AFTER `sumexvat`");
  $ret[] = update_sql("ALTER TABLE `astinvoiceline` ADD `fromdate` date NULL AFTER `phoneno`");
  $ret[] = update_sql("ALTER TABLE `astinvoiceline` ADD `todate` date NULL AFTER `fromdate`");
  $ret[] = update_sql("ALTER TABLE `astinvoiceline` ADD `minutes` decimal(10,4) NOT NULL default 0 AFTER `qty`");
  $ret[] = update_sql("ALTER TABLE `astinvoiceline` ADD `amount` decimal(10,2) NOT NULL default 0 AFTER `minutes`");

  $ret[] = update_sql("ALTER TABLE `astcountrycode` ADD `db_prefix` varchar(40) NOT NULL default 'pbx_' FIRST");
  $ret[] = update_sql("ALTER TABLE `astcountrycode` DROP PRIMARY KEY , ADD PRIMARY KEY ( `db_prefix` , `countrycode` )");
  $ret[] = update_sql("ALTER TABLE `astpricelist` ADD `ccn` varchar(40) NULL AFTER `pattern`");
  $ret[] = update_sql("ALTER TABLE `astpricelist` ADD `txtcomment` varchar(256) NULL");

  $ret[] = update_sql("ALTER TABLE `astuser` ADD `companyno` varchar(128) NULL AFTER `birthdate2`");

  return $ret;
}

function astbill_update_035() {
  $ret = array();

  $ret[] = update_sql("ALTER TABLE `asthardware` ADD `mac4` varchar(6) NULL default NULL AFTER `serialnumber`");
  $ret[] = update_sql("ALTER TABLE `asthardware` ADD `mac5` varchar(6) NULL default NULL AFTER `mac4`");
  $ret[] = update_sql("ALTER TABLE `asthardware` ADD `mac6` varchar(6) NULL default NULL AFTER `mac5`");

  return $ret;
}


function astbill_update_036() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `astpricelist` ADD `timeperiod` varchar(40) NULL default NULL AFTER `pattern`");
  $ret[] = update_sql("ALTER TABLE `astpricelist` ADD `netvendor` varchar(128) NULL default NULL AFTER `timeperiod`");

  $ret[] = update_sql("ALTER TABLE `astpricelist` ADD `priceevening` decimal(10,4) NOT NULL default 0 AFTER `price`");
  $ret[] = update_sql("ALTER TABLE `astpricelist` ADD `priceweekend` decimal(10,4) NOT NULL default 0 AFTER `priceevening`");
  $ret[] = update_sql("ALTER TABLE `astpricelist` ADD `pricereseller` decimal(10,4) NOT NULL default 0 AFTER `priceweekend`");

  $ret[] = update_sql("ALTER TABLE `astpricelist` ADD `pricemobile` decimal(10,4) NOT NULL default 0 AFTER `pricereseller`");
  $ret[] = update_sql("ALTER TABLE `astpricelist` ADD `ismobile` varchar(2) NULL default NULL AFTER `pricemobile`");
  return $ret;
}

function astbill_update_037() {
  $ret = array();
  $ret[] = update_sql("ALTER TABLE `aststatus` ADD `host` varchar(128) NULL default NULL AFTER `topup_url`");
  $ret[] = update_sql("ALTER TABLE `aststatus` ADD `iaxport` varchar(128) NULL default NULL AFTER `host`");
  $ret[] = update_sql("ALTER TABLE `aststatus` ADD `sshport` varchar(128) NULL default NULL AFTER `iaxport`");
  $ret[] = update_sql("ALTER TABLE `aststatus` ADD `lanhost` varchar(128) NULL default NULL AFTER `sshport`");
  $ret[] = update_sql("ALTER TABLE `aststatus` ADD `laniaxport` varchar(128) NULL default NULL AFTER `lanhost`");
  $ret[] = update_sql("ALTER TABLE `aststatus` ADD `lansshport` varchar(128) NULL default NULL AFTER `laniaxport`");
  $ret[] = update_sql("ALTER TABLE `aststatus` ADD `accountcode` varchar(128) NULL default NULL AFTER `lansshport`");
  return $ret;
}

function astbill_update_038() {
  $ret = array();
    $ret[] = update_sql("INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `viewstatus`)
VALUES ('DEF','Dial-Timeout-Parameter','|45|tTL(','The Dial Timeout and Dial Parameters','E')");
    $ret[] = update_sql("INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `viewstatus`)
VALUES ('DEF','DialLocal-Timeout-Parameter','|30|tTL(','The Dial Timeout and Dial Parameters','E')");

  
  return $ret;
}

function astbill_update_039() {
  $ret = array();
    $ret[] = update_sql("DROP VIEW IF EXISTS asvaccount2");
    $ret[] = update_sql("CREATE VIEW `asvaccount2` AS select `asvaccount`.`accountcode` AS `accountcode`,
`astaccount`.`db_prefix` AS `db_prefix`,`astaccount`.`uid` AS `uid`,`astaccount`.`tech` AS `tech`,
forcecallerid, `astaccount`.`secret` AS `secret`,`astaccount`.`active` AS `active`,`astaccount`.
`usagecount` AS `usagecount`,left(`astaccount`.`accountname`,15) AS `accountname`,
round((`asvaccount`.`sumprice` / 100),2) AS `sumprice`,`asvaccount`.`sumpaid` AS `sumpaid`,
(`asvaccount`.`sumpaid` - round((`asvaccount`.`sumprice` / 100),2)) AS `balance`,
`astaccount`.`creditlimit` AS `creditlimit`,`astaccount`.`startingcredit` AS `startingcredit`,
`asvaccount`.`countcalls` AS `countcalls` from (`asvaccount` join `astaccount`) 
where (`asvaccount`.`accountcode` = `astaccount`.`accountcode`)");
  
  return $ret;
}


/*
 CREATE TABLE `astplans` (`name` varchar(40) NOT NULL default '',
 `currency` varchar(3) NOT NULL default 'USD',
`language` varchar(10) default NULL,`publishednum` varchar(40) default NULL,
`did` varchar(40) default NULL,
`markup` decimal(10,2) NOT NULL default '0.00',`billincrement` tinyint(8) NOT NULL default '1',
`connectcharge` decimal(10,2) NOT NULL default '0.00',
`status` tinyint(1) NOT NULL default '1',PRIMARY KEY  (`name`))");


  $ret[] = update_sql("INSERT INTO `astplans` SELECT * from astbrand");
  $ret[] = update_sql("drop table astbrand");
  $ret[] = update_sql("delete from pbx_cache");
*/


?>
