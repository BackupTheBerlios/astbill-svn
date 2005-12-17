-- AstBill 0.9.0.9
-- This file is for upgrade from AstBill 0.9.0.7

CREATE TABLE `astlanguage` (
  `language` varchar(5) NOT NULL,
  `languagename` varchar(40) NOT NULL,
  `active` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`language`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO `astlanguage` VALUES ('us', 'English USA', 1);
INSERT INTO `astlanguage` VALUES ('enbr', 'English British', 1);
INSERT INTO `astlanguage` VALUES ('no', 'Norwegian', 1);
INSERT INTO `astlanguage` VALUES ('sv', 'Swedish', 1);
INSERT INTO `astlanguage` VALUES ('fr', 'French', 1);
INSERT INTO `astlanguage` VALUES ('it', 'Italian', 1);
INSERT INTO `astlanguage` VALUES ('es', 'Spanish', 1);
INSERT INTO `astlanguage` VALUES ('da', 'Danish', 1);
INSERT INTO `astlanguage` VALUES ('de', 'German', 1);

INSERT INTO `astemailtext` VALUES ('ASTARREG', 'You VOIP Telephone Account is Activated', 'Thank you for registering at AstarTelecom.com. You may now use your soft phone to make calls.\r\n\r\nYour Astar VOIP Number is: %username%.\r\n\r\nYou can call your friends using Astar for free. Just dial their Astar Telephone number.\r\n\r\nPlease configure your soft phone using the following information:\r\n\r\nNetwork Name: Astar\r\nNetwork Type: IAX\r\nPlease select external network when the soft phone wizard ask for network.\r\n\r\nServer: iax.astartelecom.com\r\nUsername: %username%\r\nPassword: %password%\r\n\r\nAfter configuring the soft phone you may wish to dial the following to test the system.\r\n\r\n	500 Speaking Clock\r\n	502 Echo Test\r\n	501 Monkey Test\r\n\r\nHappy Talking ...\r\n\r\n\r\nBarbara\r\n\r\nAstBill.com \r\nCustomer support', NULL, 'noreply@astbill.com', '', NULL, NULL, NULL, NULL);
INSERT INTO `astemailtext` VALUES ('ASTARSIP', 'You SIP VOIP Telephone Account information', 'Thank you for registering at AstarTelecom.com. You may now use your SIP device or soft phone to make calls.\r\n\r\nYour Astar VOIP Number is: %username%.\r\n\r\nYou can call your friends using Astar for free. Just dial their Astar Telephone number.\r\n\r\nPlease configure your soft phone using the following information:\r\n\r\nNetwork Type: SIP\r\nServer: sip.astartelecom.com\r\nUsername: %username%\r\nPassword: %password%\r\n\r\nAfter configuring you may wish to dial the following to test the system.\r\n\r\n	500 Speaking Clock\r\n	502 Echo Test\r\n	501 Monkey Test\r\n\r\nHappy Talking ...\r\n\r\n\r\nBarbara\r\n\r\nAstBill.com \r\nCustomer support', NULL, 'noreply@astbill.com', '', NULL, NULL, NULL, NULL);
INSERT INTO `astemailtext` VALUES ('ASTARIAX', 'You IAX VOIP Telephone Account information', 'Thank you for registering at AstarTelecom.com. You may now use your soft phone to make calls.\r\n\r\nYour Astar VOIP Number is: %username%.\r\n\r\nYou can call your friends using Astar for free. Just dial their Astar Telephone number.\r\n\r\nPlease configure your soft phone using the following information:\r\n\r\nNetwork Name: Astar\r\nNetwork Type: IAX\r\nPlease select external network when the soft phone wizard ask for network.\r\n\r\nServer: iax.astartelecom.com\r\nUsername: %username%\r\nPassword: %password%\r\n\r\nAfter configuring the soft phone you may wish to dial the following to test the system.\r\n\r\n	500 Speaking Clock\r\n	502 Echo Test\r\n	501 Monkey Test\r\n\r\nHappy Talking ...\r\n\r\n\r\nBarbara\r\n\r\nAstBill.com \r\nCustomer support', NULL, 'noreply@astbill.com', '', NULL, NULL, NULL, NULL);

ALTER TABLE `astaccount` ADD `cccardvalue` DECIMAL( 10, 4 ) DEFAULT '0' NOT NULL AFTER `lowbalanceemail` ,
ADD `ccfirstused` DATETIME DEFAULT '0000-00-00 00:00:00' AFTER `cccardvalue` ,
ADD `cclastused` DATETIME DEFAULT '0000-00-00 00:00:00' AFTER `ccfirstused` ,
ADD `ccexpiredate` DATETIME DEFAULT '0000-00-00 00:00:00' AFTER `cclastused` ,
ADD `ccexpiredays` INT( 4 ) DEFAULT '0' NOT NULL AFTER `ccexpiredate` ,
ADD `ccbatchno` VARCHAR( 128 ) DEFAULT NULL AFTER `ccexpiredays` ,
ADD `ccserialno` VARCHAR( 128 ) DEFAULT NULL AFTER `ccbatchno` ;

ALTER TABLE `astroute` ADD `countrycode` INT( 6 ) DEFAULT '0' NOT NULL AFTER `id` ;
ALTER TABLE `astroute` CHANGE `comment` `routename` VARCHAR( 128 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL;
ALTER TABLE `astpricelist` ADD `countrycode` INT( 6 ) DEFAULT '0' NOT NULL AFTER `id` ;

DROP VIEW IF EXISTS asvpricecountry;
create view asvpricecountry as
SELECT DISTINCT MIN(astpricelist.pattern) AS countrycode, astpricelist.name
FROM astpricelist GROUP BY astpricelist.name order by astpricelist.name;

DROP VIEW IF EXISTS asvpricecountry2;
create view asvpricecountry2 as
SELECT DISTINCT MIN(astpricelist.pattern) AS countrycode
FROM astpricelist GROUP BY astpricelist.name order by astpricelist.name;

update astpricelist, asvpricecountry set astpricelist.countrycode = left(asvpricecountry.countrycode,3)
where astpricelist.name = asvpricecountry.name;

delete from astcountrycode;

INSERT INTO astcountrycode (countrycode,country)
SELECT distinct astpricelist.countrycode, MAX(asvpricecountry.name) FROM asvpricecountry, astpricelist
where astpricelist.countrycode = asvpricecountry.countrycode
GROUP BY countrycode;

delete from astroute where trunk <> 'Local';

INSERT INTO astroute ( countrycode, pattern, routename, cost, trunk )
SELECT astpricelist.countrycode, astpricelist.pattern, astpricelist.name, astpricelist.price, 'DEF' AS Expr1
FROM astpricelist where brand = 'default';

delete from pbx_cache;

INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `timestamp` )
VALUES ('DEF', 'TopUpURL', '/topup', 'The URL used to topup AstBill VOIP Software' , NOW( ));

CREATE TABLE astsyslog (
lid int(10) unsigned NOT NULL auto_increment,
logpath varchar(255) NOT NULL default '' ,
linecount varchar(255) NOT NULL default '' ,
active tinyint(1) NOT NULL default 1 ,
comment longtext,
PRIMARY KEY (`lid`)
) AUTO_INCREMENT=1;


INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `timestamp` )
VALUES ('DEF', 'LOGMessages', '2000', 'This is the numbers of chars visible from the Asterisk Messages Log File', NOW() );

INSERT INTO `astsystem` VALUES ('DEF', 'CountryPrefix', '44', 'This is the Default value for CountryPrefix. This is what will come up as Default when you create a new user.', '2005-10-18 10:00:00');

-- DROP TABLE IF EXISTS `astactype`;
-- To simplify The User Interface you can now disable the account types you are not using by setting active to 0
-- Not implemented in all modules yet. But soon to come.

CREATE TABLE `astactype` (
  `actype` varchar(40) NOT NULL default '',
  `acname` varchar(40) NOT NULL default '',
  `active` tinyint(1) NOT NULL default 1,
  `comment` varchar(255),
  PRIMARY KEY  (`actype`)
);
INSERT INTO `astactype` VALUES ('IAX','IAX2',1, '');
INSERT INTO `astactype` VALUES ('SIP','SIP',1, '');
INSERT INTO `astactype` VALUES ('VIR','Virtual Account',1, '');
INSERT INTO `astactype` VALUES ('H323','H323',1, '');

ALTER TABLE `asttrunk` ADD `currency` VARCHAR( 3 ) DEFAULT 'USD' NOT NULL AFTER `isdefault` ,
ADD `tenantid` INT( 11 ) DEFAULT '0' NOT NULL AFTER `currency` ;

ALTER TABLE `asttrunk` ADD `addprefix` VARCHAR( 10 ) AFTER `tenantid` ,
ADD `removeprefix` TINYINT( 2 ) AFTER `addprefix` ,
ADD `registerstring` VARCHAR( 255 ) AFTER `removeprefix` ;

ALTER TABLE `asttrunk` ADD `accountcode` VARCHAR( 40 ) AFTER `tech` ;
ALTER TABLE `asttrunk` ADD `username` VARCHAR( 40 ) AFTER `path` ;

--- There is some old dialplan records giving problems for some users.
delete from astdialplan;

DROP VIEW IF EXISTS asvaccuser;
create view asvaccuser as
SELECT astaccount.accountcode from astaccount WHERE tech in (select actype from astactype);

DROP VIEW IF EXISTS asvaccount;
create view asvaccount as
SELECT asvaccuser.accountcode, IFNULL(sumpaid,0) as sumpaid, IFNULL(sumprice,0) as sumprice, 
IFNULL(sumpaid,0)-IFNULL(sumprice,0) as balance, IFNULL(countcalls,0) as countcalls
FROM ((asvaccuser LEFT JOIN asvaccountcalls ON asvaccuser.accountcode = asvaccountcalls.accountcode) 
LEFT JOIN asvaccountpaid ON asvaccuser.accountcode = asvaccountpaid.accountcode) 
LEFT JOIN asvaccountprice ON asvaccuser.accountcode = asvaccountprice.accountcode;

DELETE FROM pbx_cache;

INSERT INTO `astsystem` ( `serverid` , `name` , `value` , `comment` , `timestamp` )
VALUES ('DEF', 'AccountDropDown', '1', 'If 1 We will use a Drop Down box to show Accountcode in Payment screen and other Screens. If 0 a text entry box will be used.', NOW( ));
ALTER TABLE `astsystem` CHANGE `value` `value` VARCHAR( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;
