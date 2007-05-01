-- AstBill 0.9.0.10
-- This file is for upgrade from AstBill 0.9.0.8

DROP TABLE IF EXISTS astreseller;

CREATE TABLE `astreseller` (
  `rid` int(11) NOT NULL auto_increment,
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
  PRIMARY KEY  (`rid`)
) AUTO_INCREMENT=40000;

ALTER TABLE `asttenant` CHANGE `resellertid` `resellerid` INT( 11 ) NOT NULL DEFAULT '40000';

UPDATE `asttenant` SET `resellerid` = '40000' where `resellerid` = 0;

INSERT INTO `astreseller` VALUES (40000, 'Default Reseller', 'AstBill Manager', '', '', '', '', NULL, '', '', '', '', 1, '2005-11-02 19:16:21', '2005-11-02 19:16:21');

INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `timestamp` )
VALUES ('DEF', 'GlobalDialPrefix', '', 'It is common to Add 00 as Global Dial Prefix. This allows users to dial international numbers without 00 or 011 prefix', NOW( ));

ALTER TABLE `asttrunk` CHANGE `removeprefix` `removeprefix` TINYINT( 2 ) NOT NULL DEFAULT '0';

-- Hum

ALTER TABLE `asttrunk` DROP INDEX `name`; 

ALTER TABLE `astaccount` DROP `register`;
ALTER TABLE `astaccount` DROP `trunkpath`;

DROP VIEW IF EXISTS asv_friend;
create view asv_friend as SELECT uid,astaccount.serverid,astaccount.accountcode,astaccount.username,accountname publicnumber,
astaccount.tech,type,secret,forwardto,fromuser,authuser,fromdomain,nat,qualify,host,port,callerid,context,dtmfmode,
insecure,canreinvite,disallow,allow,restrictid,astaccount.comment,active,date_created,timestamp FROM astaccount where tech like 'IN%';

       
ALTER TABLE `astaccount` ADD `ccopeningbalance` DECIMAL( 10, 4 ) DEFAULT '0' NOT NULL AFTER `cccardvalue` ;

DROP VIEW IF EXISTS asvaccount2;
create view asvaccount2 as
SELECT asvaccount.accountcode, uid, tech, secret,active,usagecount, LEFT(accountname,15) as accountname,  round((sumprice/100),2) as sumprice, 
sumpaid, sumpaid - round((sumprice/100),2) as balance, creditlimit,ccopeningbalance, countcalls FROM asvaccount, astaccount
where asvaccount.accountcode = astaccount.accountcode;

INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `timestamp` )
VALUES ('DEF', 'MaxMinute', '60', 'This is the maximum alloved minutes for a call. If your call last longer than this you will be disconnected by the System.', NOW( ));

ALTER TABLE `asttrunk` ADD `usstyleprefix` TINYINT( 2 ) DEFAULT '0' NOT NULL AFTER `addprefix` ;

-- mansi-pbx only

INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `timestamp` )
VALUES ('DEF', 'AstBill-DB-Version', 'AstBill-0.9.0.10', 'This is the AstBill Database Version Number', NOW( )), 
( 'DEF', 'AstBill-DB-Updated', '2005-11-04', 'This is the date of the last Database patch applied to your system', NOW( ));

INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `timestamp` )
VALUES ( 'DEF', 'AstBill-Version', 'AstBill-0.9.0.10', 'The Official Version number of your AstBill Installation', NOW( )
), ( 'DEF', 'AstBill-GUI-Updated', '2005-11-05', 'The last date your Web GUI have been updated', NOW( ) );


-- sadiq - mansion only
ALTER TABLE `astaccount` CHANGE `ccopeningbalance` `startingcredit` DECIMAL( 10, 4 ) NOT NULL DEFAULT '0.0000';

DROP VIEW IF EXISTS asvaccount2;
create view asvaccount2 as
SELECT asvaccount.accountcode, uid, tech, secret,active,usagecount, LEFT(accountname,15) as accountname,  round((sumprice/100),2) as sumprice, 
sumpaid, sumpaid - round((sumprice/100),2) as balance, creditlimit,startingcredit, countcalls FROM asvaccount, astaccount
where asvaccount.accountcode = astaccount.accountcode;

ALTER TABLE `astcurrency` ADD `ratetabledesc` VARCHAR( 40 ) NOT NULL AFTER `currencyname` ;

-- This update is for the Currency text shown in the Rate Table
-- You have to fill in your own currency

UPDATE `astcurrency` SET `ratetabledesc` = 'US Cents',
`timestamp` = NOW( ) WHERE CONVERT( `currency` USING utf8 ) = 'USD' LIMIT 1 ;

UPDATE `astcurrency` SET `ratetabledesc` = 'UK Pence',
`timestamp` = NOW( ) WHERE CONVERT( `currency` USING utf8 ) = 'GBP' LIMIT 1 ;

UPDATE `astcurrency` SET `ratetabledesc` = 'Euro Cents',
`timestamp` = NOW( ) WHERE CONVERT( `currency` USING utf8 ) = 'EUR' LIMIT 1 ;

drop table if exists astpricelistghost;

INSERT INTO `astcurrency` VALUES ('AUD', 'Australian Dollars', 'AUD Cents', '$', '$', 'c', '0.0000', 0x323030352d31312d30362031393a33383a3334);
UPDATE `astcurrency` SET `ratetabledesc` = 'NOK ore',
`timestamp` = NOW( ) WHERE CONVERT( `currency` USING utf8 ) = 'NOK' LIMIT 1 ;
UPDATE `astcurrency` SET `ratetabledesc` = 'SEK ore',
`timestamp` = NOW( ) WHERE CONVERT( `currency` USING utf8 ) = 'SEK' LIMIT 1 ;

INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `timestamp`)
VALUES ( 'DEF', 'Log-Path', '/home/astbill/logs/', 'This is the Path to log files created by agi-bin scripts', NOW());
