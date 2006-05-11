-- MySQL dump 10.10
--
-- Host: localhost    Database: astbill
-- ------------------------------------------------------
-- Server version	5.0.19-Debian_2bpo1-log

delimiter ;

--
-- View structure for view `asv_friend`
--

/*!50001 DROP VIEW IF EXISTS `asv_friend`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asv_friend` AS select `astaccount`.`uid` AS `uid`,`astaccount`.`db_prefix` AS `db_prefix`,`astaccount`.`serverid` AS `serverid`,`astaccount`.`accountcode` AS `accountcode`,`astaccount`.`username` AS `username`,`astaccount`.`accountname` AS `publicnumber`,`astaccount`.`tech` AS `tech`,`astaccount`.`type` AS `type`,`astaccount`.`secret` AS `secret`,`astaccount`.`forwardto` AS `forwardto`,`astaccount`.`fromuser` AS `fromuser`,`astaccount`.`authuser` AS `authuser`,`astaccount`.`fromdomain` AS `fromdomain`,`astaccount`.`nat` AS `nat`,`astaccount`.`qualify` AS `qualify`,`astaccount`.`host` AS `host`,`astaccount`.`port` AS `port`,`astaccount`.`callerid` AS `callerid`,`astaccount`.`context` AS `context`,`astaccount`.`dtmfmode` AS `dtmfmode`,`astaccount`.`insecure` AS `insecure`,`astaccount`.`canreinvite` AS `canreinvite`,`astaccount`.`disallow` AS `disallow`,`astaccount`.`allow` AS `allow`,`astaccount`.`restrictid` AS `restrictid`,`astaccount`.`comment` AS `comment`,`astaccount`.`active` AS `active`,`astaccount`.`date_created` AS `date_created`,`astaccount`.`timestamp` AS `timestamp` from `astaccount` where (`astaccount`.`tech` like _utf8'IN%') */;

--
-- View structure for view `asv_iax`
--

/*!50001 DROP VIEW IF EXISTS `asv_iax`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asv_iax` AS select `astaccount`.`accountcode` AS `name`,`astaccount`.`accountcode` AS `username`,`astaccount`.`type` AS `type`,`astaccount`.`secret` AS `secret`,`astaccount`.`notransfer` AS `notransfer`,`astaccount`.`inkeys` AS `inkeys`,`astaccount`.`auth` AS `auth`,`astaccount`.`accountcode` AS `accountcode`,`astaccount`.`amaflags` AS `amaflags`,`astaccount`.`callerid` AS `callerid`,`astaccount`.`context` AS `context`,`astaccount`.`defaultip` AS `defaultip`,`astaccount`.`host` AS `host`,`astaccount`.`language` AS `language`,`astaccount`.`dtmfmode` AS `dtmfmode`,`astaccount`.`mailbox` AS `mailbox`,`astaccount`.`deny` AS `deny`,`astaccount`.`permit` AS `permit`,`astaccount`.`qualify` AS `qualify`,`astaccount`.`disallow` AS `disallow`,`astaccount`.`allow` AS `allow`,`astaccount`.`ipaddr` AS `ipaddr`,`astaccount`.`port` AS `port`,`astaccount`.`regseconds` AS `regseconds` from `astaccount` where (((`astaccount`.`tech` = _utf8'IAX') or (`astaccount`.`tech` = _utf8'IN-IAX')) and (`astaccount`.`active` = 1)) */;

--
-- View structure for view `asv_peers`
--

/*!50001 DROP VIEW IF EXISTS `asv_peers`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asv_peers` AS select `a`.`accountcode` AS `accountcode`,`a`.`tech` AS `tech`,`a`.`reg_changed` AS `changed`,from_unixtime(`a`.`regseconds`) AS `regexpire`,`p`.`name` AS `name`,`a`.`callerid` AS `callerid`,concat(`a`.`ipaddr`,_utf8':',`a`.`port`) AS `ip` from (`astaccount` `a` join `pbx_users` `p`) where ((`a`.`uid` = `p`.`uid`) and ((`a`.`tech` = _utf8'IAX') or (`a`.`tech` = _utf8'SIP')) and (`a`.`uid` <> 0) and (`a`.`active` = _utf8'1') and (`a`.`regseconds` <> 0)) order by `a`.`reg_changed` desc */;

--
-- View structure for view `asv_sip`
--

/*!50001 DROP VIEW IF EXISTS `asv_sip`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asv_sip` AS select `astaccount`.`accountcode` AS `name`,`astaccount`.`accountcode` AS `username`,`astaccount`.`type` AS `type`,`astaccount`.`secret` AS `secret`,`astaccount`.`host` AS `host`,`astaccount`.`callerid` AS `callerid`,`astaccount`.`context` AS `context`,`astaccount`.`dtmfmode` AS `dtmfmode`,`astaccount`.`mailbox` AS `mailbox`,`astaccount`.`nat` AS `nat`,`astaccount`.`qualify` AS `qualify`,`astaccount`.`fromuser` AS `fromuser`,`astaccount`.`authuser` AS `authuser`,`astaccount`.`fromdomain` AS `fromdomain`,`astaccount`.`fullcontact` AS `fullcontact`,`astaccount`.`insecure` AS `insecure`,`astaccount`.`canreinvite` AS `canreinvite`,`astaccount`.`disallow` AS `disallow`,`astaccount`.`allow` AS `allow`,`astaccount`.`restrictid` AS `restrictid`,`astaccount`.`ipaddr` AS `ipaddr`,`astaccount`.`port` AS `port`,`astaccount`.`regseconds` AS `regseconds`,`astaccount`.`call-limit` AS `call-limit`,`astaccount`.`trustrpid` AS `trustrpid`,`astaccount`.`sendrpid` AS `sendrpid`,`astaccount`.`setvar` AS `setvar`,`astaccount`.`notifyringing` AS `notifyringing` from `astaccount` where (((`astaccount`.`tech` = _utf8'SIP') or (`astaccount`.`tech` = _utf8'IN-SIP')) and (`astaccount`.`active` = 1)) */;

--
-- View structure for view `asv_trunk_dialplan`
--

/*!50001 DROP VIEW IF EXISTS `asv_trunk_dialplan`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asv_trunk_dialplan` AS select 0 AS `day`,`asttrunk`.`name` AS `name`,`asttrunk`.`trunkcost` AS `trunkcost`,`asttrunk`.`usagecount` AS `usagecount`,`asttrunk`.`maxusage` AS `maxusage`,NULL AS `dialplan`,_utf8'00:00:00' AS `starttime`,_utf8'23:59:59' AS `endtime` from (`asttrunk` left join `astdialplan` on((`astdialplan`.`accountcode` = concat(_utf8'trunk',`asttrunk`.`tid`)))) where isnull(`astdialplan`.`did`) union all select 1 AS `day`,`asttrunk`.`name` AS `name`,`asttrunk`.`trunkcost` AS `trunkcost`,`asttrunk`.`usagecount` AS `usagecount`,`asttrunk`.`maxusage` AS `maxusage`,`astdialplan`.`accountcode` AS `accountcode`,concat(`astdialplan`.`start_time_hr`,_utf8':',`astdialplan`.`start_time_min`,_utf8':00') AS `starttime`,concat(`astdialplan`.`end_time_hr`,_utf8':',`astdialplan`.`end_time_min`,_utf8':59') AS `endtime` from (`astdialplan` join `asttrunk`) where ((`astdialplan`.`sun` = 1) and (`astdialplan`.`accountcode` = concat(_utf8'trunk',`asttrunk`.`tid`))) union all select 2 AS `day`,`asttrunk`.`name` AS `name`,`asttrunk`.`trunkcost` AS `trunkcost`,`asttrunk`.`usagecount` AS `usagecount`,`asttrunk`.`maxusage` AS `maxusage`,`astdialplan`.`accountcode` AS `accountcode`,concat(`astdialplan`.`start_time_hr`,_utf8':',`astdialplan`.`start_time_min`,_utf8':00') AS `starttime`,concat(`astdialplan`.`end_time_hr`,_utf8':',`astdialplan`.`end_time_min`,_utf8':59') AS `endtime` from (`astdialplan` join `asttrunk`) where ((`astdialplan`.`mon` = 1) and (`astdialplan`.`accountcode` = concat(_utf8'trunk',`asttrunk`.`tid`))) union all select 3 AS `day`,`asttrunk`.`name` AS `name`,`asttrunk`.`trunkcost` AS `trunkcost`,`asttrunk`.`usagecount` AS `usagecount`,`asttrunk`.`maxusage` AS `maxusage`,`astdialplan`.`accountcode` AS `accountcode`,concat(`astdialplan`.`start_time_hr`,_utf8':',`astdialplan`.`start_time_min`,_utf8':00') AS `starttime`,concat(`astdialplan`.`end_time_hr`,_utf8':',`astdialplan`.`end_time_min`,_utf8':59') AS `endtime` from (`astdialplan` join `asttrunk`) where ((`astdialplan`.`tue` = 1) and (`astdialplan`.`accountcode` = concat(_utf8'trunk',`asttrunk`.`tid`))) union all select 4 AS `day`,`asttrunk`.`name` AS `name`,`asttrunk`.`trunkcost` AS `trunkcost`,`asttrunk`.`usagecount` AS `usagecount`,`asttrunk`.`maxusage` AS `maxusage`,`astdialplan`.`accountcode` AS `accountcode`,concat(`astdialplan`.`start_time_hr`,_utf8':',`astdialplan`.`start_time_min`,_utf8':00') AS `starttime`,concat(`astdialplan`.`end_time_hr`,_utf8':',`astdialplan`.`end_time_min`,_utf8':59') AS `endtime` from (`astdialplan` join `asttrunk`) where ((`astdialplan`.`wed` = 1) and (`astdialplan`.`accountcode` = concat(_utf8'trunk',`asttrunk`.`tid`))) union all select 5 AS `day`,`asttrunk`.`name` AS `name`,`asttrunk`.`trunkcost` AS `trunkcost`,`asttrunk`.`usagecount` AS `usagecount`,`asttrunk`.`maxusage` AS `maxusage`,`astdialplan`.`accountcode` AS `accountcode`,concat(`astdialplan`.`start_time_hr`,_utf8':',`astdialplan`.`start_time_min`,_utf8':00') AS `starttime`,concat(`astdialplan`.`end_time_hr`,_utf8':',`astdialplan`.`end_time_min`,_utf8':59') AS `endtime` from (`astdialplan` join `asttrunk`) where ((`astdialplan`.`thu` = 1) and (`astdialplan`.`accountcode` = concat(_utf8'trunk',`asttrunk`.`tid`))) union all select 6 AS `day`,`asttrunk`.`name` AS `name`,`asttrunk`.`trunkcost` AS `trunkcost`,`asttrunk`.`usagecount` AS `usagecount`,`asttrunk`.`maxusage` AS `maxusage`,`astdialplan`.`accountcode` AS `accountcode`,concat(`astdialplan`.`start_time_hr`,_utf8':',`astdialplan`.`start_time_min`,_utf8':00') AS `starttime`,concat(`astdialplan`.`end_time_hr`,_utf8':',`astdialplan`.`end_time_min`,_utf8':59') AS `endtime` from (`astdialplan` join `asttrunk`) where ((`astdialplan`.`fri` = 1) and (`astdialplan`.`accountcode` = concat(_utf8'trunk',`asttrunk`.`tid`))) union all select 7 AS `day`,`asttrunk`.`name` AS `name`,`asttrunk`.`trunkcost` AS `trunkcost`,`asttrunk`.`usagecount` AS `usagecount`,`asttrunk`.`maxusage` AS `maxusage`,`astdialplan`.`accountcode` AS `accountcode`,concat(`astdialplan`.`start_time_hr`,_utf8':',`astdialplan`.`start_time_min`,_utf8':00') AS `starttime`,concat(`astdialplan`.`end_time_hr`,_utf8':',`astdialplan`.`end_time_min`,_utf8':59') AS `endtime` from (`astdialplan` join `asttrunk`) where ((`astdialplan`.`sat` = 1) and (`astdialplan`.`accountcode` = concat(_utf8'trunk',`asttrunk`.`tid`))) */;

--
-- View structure for view `asv_trunk_dialplan2`
--

/*!50001 DROP VIEW IF EXISTS `asv_trunk_dialplan2`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asv_trunk_dialplan2` AS select sql_no_cache `asv_trunk_dialplan`.`day` AS `day`,`asv_trunk_dialplan`.`name` AS `name`,`asv_trunk_dialplan`.`trunkcost` AS `trunkcost`,`asv_trunk_dialplan`.`usagecount` AS `usagecount`,`asv_trunk_dialplan`.`maxusage` AS `maxusage`,`asv_trunk_dialplan`.`dialplan` AS `dialplan`,`asv_trunk_dialplan`.`starttime` AS `starttime`,`asv_trunk_dialplan`.`endtime` AS `endtime` from `asv_trunk_dialplan` where (((`asv_trunk_dialplan`.`day` = (date_format(curdate(),_utf8'%w') + 1)) or (`asv_trunk_dialplan`.`day` = 0)) and (curtime() >= cast(`asv_trunk_dialplan`.`starttime` as time)) and (curtime() <= cast(`asv_trunk_dialplan`.`endtime` as time))) */;

--
-- View structure for view `asv_voicemail`
--

/*!50001 DROP VIEW IF EXISTS `asv_voicemail`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asv_voicemail` AS select `a`.`accountcode` AS `uniqueid`,`a`.`accountcode` AS `customer_id`,`a`.`context` AS `context`,`a`.`mailbox` AS `mailbox`,`a`.`mailboxpin` AS `password`,`p`.`name` AS `fullname`,ifnull(`a`.`mailboxemail`,`p`.`mail`) AS `email`,`a`.`pager` AS `pager`,`a`.`stamp` AS `stamp`,`a`.`attach` AS `attach`,`a`.`saycid` AS `saycid`,`a`.`hidefromdir` AS `hidefromdir` from (`astaccount` `a` join `pbx_users` `p`) where ((`a`.`uid` = `p`.`uid`) and ((`a`.`tech` = _utf8'IAX') or (`a`.`tech` = _utf8'SIP') or (`a`.`tech` = _utf8'VIR')) and (`a`.`uid` <> 0) and (`a`.`active` = _utf8'1')) order by `a`.`accountcode` */;

--
-- View structure for view `asvaccountcalls`
--

/*!50001 DROP VIEW IF EXISTS `asvaccountcalls`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvaccountcalls` AS select `astcdr`.`accountcode` AS `accountcode`,count(0) AS `countcalls` from `astcdr` where ((`astcdr`.`dialstatus` like _utf8'ANSWER%') and (`astcdr`.`answeredtime` <> 0) and (`astcdr`.`trunk` <> _utf8'Local')) group by `astcdr`.`accountcode` */;

--
-- View structure for view `asvaccountpaid`
--

/*!50001 DROP VIEW IF EXISTS `asvaccountpaid`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvaccountpaid` AS select `astpayment`.`accountcode` AS `accountcode`,sum(`astpayment`.`paidamount`) AS `sumpaid` from `astpayment` group by `astpayment`.`accountcode` */;

--
-- View structure for view `asvaccountprice`
--

/*!50001 DROP VIEW IF EXISTS `asvaccountprice`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvaccountprice` AS select `astcdr`.`accountcode` AS `accountcode`,sum(`astcdr`.`price`) AS `sumprice` from `astcdr` where ((`astcdr`.`dialstatus` like _utf8'ANSWER%') and (`astcdr`.`answeredtime` <> 0) and (`astcdr`.`trunk` <> _utf8'Local')) group by `astcdr`.`accountcode` */;

--
-- View structure for view `asvaccuser`
--

/*!50001 DROP VIEW IF EXISTS `asvaccuser`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvaccuser` AS select `astaccount`.`accountcode` AS `accountcode` from `astaccount` where `tech` in (select `astactype`.`actype` AS `actype` from `astactype`) */;

--
-- View structure for view `asvaccount`
--

/*!50001 DROP VIEW IF EXISTS `asvaccount`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvaccount` AS select `asvaccuser`.`accountcode` AS `accountcode`,ifnull(`asvaccountpaid`.`sumpaid`,0) AS `sumpaid`,ifnull(`asvaccountprice`.`sumprice`,0) AS `sumprice`,(ifnull(`asvaccountpaid`.`sumpaid`,0) - ifnull(`asvaccountprice`.`sumprice`,0)) AS `balance`,ifnull(`asvaccountcalls`.`countcalls`,0) AS `countcalls` from (((`asvaccuser` left join `asvaccountcalls` on((`asvaccuser`.`accountcode` = `asvaccountcalls`.`accountcode`))) left join `asvaccountpaid` on((`asvaccuser`.`accountcode` = `asvaccountpaid`.`accountcode`))) left join `asvaccountprice` on((`asvaccuser`.`accountcode` = `asvaccountprice`.`accountcode`))) */;

--
-- View structure for view `asvaccount2`
--

/*!50001 DROP VIEW IF EXISTS `asvaccount2`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvaccount2` AS select `asvaccount`.`accountcode` AS `accountcode`,`astaccount`.`db_prefix` AS `db_prefix`,`astaccount`.`uid` AS `uid`,`astaccount`.`tech` AS `tech`,`astaccount`.`forcecallerid` AS `forcecallerid`,`astaccount`.`secret` AS `secret`,`astaccount`.`active` AS `active`,`astaccount`.`usagecount` AS `usagecount`,left(`astaccount`.`accountname`,15) AS `accountname`,round((`asvaccount`.`sumprice` / 100),2) AS `sumprice`,`asvaccount`.`sumpaid` AS `sumpaid`,(`asvaccount`.`sumpaid` - round((`asvaccount`.`sumprice` / 100),2)) AS `balance`,`astaccount`.`creditlimit` AS `creditlimit`,`astaccount`.`startingcredit` AS `startingcredit`,`asvaccount`.`countcalls` AS `countcalls` from (`asvaccount` join `astaccount`) where (`asvaccount`.`accountcode` = `astaccount`.`accountcode`) */;


--
-- View structure for view `asvbill`
--

/*!50001 DROP VIEW IF EXISTS `asvbill`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvbill` AS select `astcdr`.`accountcode` AS `accountcode`,`astcdr`.`date_created` AS `date_created`,date_format(`astcdr`.`date_created`,_utf8'%d %b %Y %H:%i:%S') AS `datec`,`astcdr`.`callednum` AS `callednum`,`astcdr`.`answeredtime` AS `answeredtime`,`astcdr`.`billtime` AS `billtime`,sec_to_time(`astcdr`.`billtime`) AS `billtime2`,`astcdr`.`pricerate` AS `pricerate`,`astcdr`.`price` AS `price` from `astcdr` where ((`astcdr`.`dialstatus` like _utf8'ANSWER%') and (`astcdr`.`answeredtime` <> 0) and (`astcdr`.`trunk` <> _utf8'Local')) order by `astcdr`.`date_created` desc */;

--
-- View structure for view `asvcall`
--

/*!50001 DROP VIEW IF EXISTS `asvcall`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvcall` AS select `astcdr`.`uniqueid` AS `uniqueid`,`astcdr`.`accountcode` AS `accountcode`,`astcdr`.`callednum` AS `callednum`,`astuser`.`uid` AS `uid`,`astuser`.`brand` AS `brand`,`astuser`.`CountryPrefix` AS `CountryPrefix`,`astplans`.`markup` AS `markup`,`astplans`.`billincrement` AS `billincrement` from (((`astcdr` join `astaccount`) join `astuser`) join `astplans`) where ((`astcdr`.`accountcode` = `astaccount`.`accountcode`) and (`astaccount`.`uid` = `astuser`.`uid`) and (`astuser`.`brand` = `astplans`.`name`)) */;

--
-- View structure for view `asvprice`
--

/*!50001 DROP VIEW IF EXISTS `asvprice`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvprice` AS select `astpricelist`.`pattern` AS `pattern`,`astpricelist`.`name` AS `name`,round((`astpricelist`.`price` / 100),4) AS `price`,concat(`astcurrency`.`currencysymbol`,round((`astpricelist`.`price` / 100),4)) AS `pricecur`,`astplans`.`name` AS `brand`,`astcurrency`.`currencysymbol` AS `cur`,`astcurrency`.`currency` AS `cur2` from ((`astplans` join `astpricelist` on((`astplans`.`name` = `astpricelist`.`brand`))) join `astcurrency` on((`astplans`.`currency` = `astcurrency`.`currency`))) order by `astplans`.`name`,`astpricelist`.`pattern` */;

--
-- View structure for view `asvprice_group`
--

/*!50001 DROP VIEW IF EXISTS `asvprice_group`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvprice_group` AS select `astpricelist`.`name` AS `name`,round((`astpricelist`.`price` / 100),4) AS `price`,concat(`astcurrency`.`currencysymbol`,round((`astpricelist`.`price` / 100),4)) AS `pricecur`,`astplans`.`name` AS `brand`,`astcurrency`.`currencysymbol` AS `cur`,`astcurrency`.`currency` AS `cur2` from ((`astplans` join `astpricelist` on((`astplans`.`name` = `astpricelist`.`brand`))) join `astcurrency` on((`astplans`.`currency` = `astcurrency`.`currency`))) where (`astpricelist`.`brand` = _utf8'default') group by `astpricelist`.`name`,`astplans`.`name`,`astcurrency`.`currencysymbol` order by `astplans`.`name`,`astpricelist`.`name` */;

--
-- View structure for view `asvprice_uk`
--

/*!50001 DROP VIEW IF EXISTS `asvprice_uk`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvprice_uk` AS select `astpricelist`.`name` AS `name`,round((`astpricelist`.`price` / 100),4) AS `price`,concat(`astcurrency`.`currencysymbol`,_utf8' ',round((`astpricelist`.`price` / 100),4)) AS `pricecur`,`astplans`.`name` AS `brand`,`astcurrency`.`currencysymbol` AS `cur`,`astcurrency`.`currency` AS `cur2` from ((`astplans` join `astpricelist` on((`astplans`.`name` = `astpricelist`.`brand`))) join `astcurrency` on((`astplans`.`currency` = `astcurrency`.`currency`))) where (`astpricelist`.`pattern` like _utf8'44%') group by `astpricelist`.`name`,`astplans`.`name`,`astcurrency`.`currencysymbol` order by `astpricelist`.`weight`,`astpricelist`.`name` */;

--
-- View structure for view `asvprice_uk_all`
--

/*!50001 DROP VIEW IF EXISTS `asvprice_uk_all`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvprice_uk_all` AS select `astpricelist`.`pattern` AS `pattern`,`astpricelist`.`name` AS `name`,round((`astpricelist`.`price` / 100),4) AS `price`,concat(`astcurrency`.`currencysymbol`,round((`astpricelist`.`price` / 100),4)) AS `pricecur`,`astplans`.`name` AS `brand`,`astcurrency`.`currencysymbol` AS `cur`,`astcurrency`.`currency` AS `cur2` from ((`astplans` join `astpricelist` on((`astplans`.`name` = `astpricelist`.`brand`))) join `astcurrency` on((`astplans`.`currency` = `astcurrency`.`currency`))) where (`astpricelist`.`pattern` like _utf8'44%') order by `astplans`.`name`,`astpricelist`.`pattern` */;

--
-- View structure for view `asvprice_usa`
--

/*!50001 DROP VIEW IF EXISTS `asvprice_usa`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvprice_usa` AS select `astpricelist`.`pattern` AS `pattern`,`astpricelist`.`name` AS `name`,round((`astpricelist`.`price` / 100),4) AS `price`,concat(`astcurrency`.`currencysymbol`,round((`astpricelist`.`price` / 100),4)) AS `pricecur`,`astplans`.`name` AS `brand`,`astcurrency`.`currencysymbol` AS `cur`,`astcurrency`.`currency` AS `cur2` from ((`astplans` join `astpricelist` on((`astplans`.`name` = `astpricelist`.`brand`))) join `astcurrency` on((`astplans`.`currency` = `astcurrency`.`currency`))) where (`astpricelist`.`name` like _utf8'USA%') order by `astpricelist`.`weight`,`astpricelist`.`name` */;

--
-- View structure for view `asvpricecountry`
--

/*!50001 DROP VIEW IF EXISTS `asvpricecountry`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvpricecountry` AS select distinct min(`astpricelist`.`pattern`) AS `countrycode`,`astpricelist`.`name` AS `name` from `astpricelist` group by `astpricelist`.`name` order by `astpricelist`.`name` */;

--
-- View structure for view `asvpricecountry2`
--

/*!50001 DROP VIEW IF EXISTS `asvpricecountry2`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `asvpricecountry2` AS select distinct min(`astpricelist`.`pattern`) AS `countrycode` from `astpricelist` group by `astpricelist`.`name` order by `astpricelist`.`name` */;

