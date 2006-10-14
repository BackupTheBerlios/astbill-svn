SET GLOBAL log_bin_trust_routine_creators = 1;

DROP PROCEDURE IF EXISTS astCreateAcc;
delimiter |

CREATE PROCEDURE astCreateAcc (OUT nextid varchar(40), suid int(10), stech varchar(128))
  NOT DETERMINISTIC
BEGIN
  DECLARE mycallerid  varchar(255); 
  DECLARE mycount  int(11);
  DECLARE accountstart varchar(40);
    select CONCAT(value,'%') into accountstart from astsystem where name = 'accountstart' and serverid = 'DEF';
   
    if EXISTS (select accountcode from astaccount where accountcode like accountstart) THEN
  		select (max(accountcode)+1) into nextid from astaccount where accountcode like accountstart;
  	ELSE
  		SET nextid = (select value from astsystem where name = 'firstaccount' and serverid = 'DEF');  
   	END IF;
  
 	insert into astaccount (uid,accountcode,tech,date_created, secret, mailboxpin) 
	values (suid, nextid, stech, Now(),RIGHT(Rand(),6),RIGHT(Rand(),4));  
	
		/*  SET lastid =  LAST_INSERT_ID();  */
	update astaccount set callerid = nextid, mailbox = nextid where accountcode = nextid;
    
    if EXISTS (select uid from pbx_users where uid = suid) THEN
  		update astaccount set callerid = (select name from pbx_users where uid = suid) where accountcode = nextid;
  	END IF;

  	if NOT EXISTS (select uid from astuser where uid = suid) THEN
  	  insert into astuser (uid, callbackto, comment) values (suid, nextid, mycallerid);
    END IF;
  			
    update astuser set lastaccount = nextid where uid = suid;

END
|
delimiter ;


DROP PROCEDURE IF EXISTS astCreateAcc2;
delimiter ;;

CREATE PROCEDURE astCreateAcc2 (OUT nextid varchar(40), suid int(10), stech varchar(128), sdb_prefix varchar(40),
sbrand varchar(128),sPrefix int(3))
  NOT DETERMINISTIC
BEGIN
  DECLARE mycallerid  varchar(255); 
  DECLARE mycount  int(11);
  DECLARE accountstart varchar(40);
  DECLARE tbluser varchar(128);
  DECLARE vbrand varchar(128);
  DECLARE vPrefix int(3);
  DECLARE vtech varchar(128);
  DECLARE vwhere varchar(128);
  DECLARE passlen int(4);
  DECLARE voicepinlen int(4);
  
        
  SET tbluser = CONCAT(sdb_prefix,'users');
  SET @s := CONCAT(' uid from ',tbluser,' where uid = suid');
  SET @t := CONCAT(' name from ',tbluser,' where uid = suid');

  select value into passlen from astsystem where name like 'def-password-length';
  select value into voicepinlen from astsystem where name like 'def-voicemail-pin-length';

    
    select CONCAT(value,'%') into accountstart from astsystem where name = 'accountstart' and serverid = 'DEF';
   
    if EXISTS (select accountcode from astaccount where accountcode like accountstart) THEN
  		select (max(accountcode)+1) into nextid from astaccount where accountcode like accountstart;
  	ELSE
  		SET nextid = (select value from astsystem where name = 'firstaccount' and serverid = 'DEF');  
   	END IF;
  
 	insert into astaccount (db_prefix,uid,accountcode,tech,date_created, secret, mailboxpin) 
	values (sdb_prefix,suid, nextid, stech, Now(),RIGHT(Rand(),passlen),RIGHT(Rand(),voicepinlen));  
	
		/*  SET lastid =  LAST_INSERT_ID();  */
	update astaccount set callerid = nextid, mailbox = nextid where accountcode = nextid;
    
    if EXISTS (select @s) THEN
  		update astaccount set callerid = (select @t) where accountcode = nextid;
  	END IF;

  	if NOT EXISTS (select uid from astuser where uid = suid and db_prefix = sdb_prefix) THEN
  	  insert into astuser (db_prefix, uid, callbackto, comment) values (sdb_prefix, suid, nextid, mycallerid);
      update astuser set brand = sbrand, CountryPrefix = sPrefix where uid = suid and db_prefix = sdb_prefix;
    END IF;
  	
 /*   SET vwhere = 'AstBill Brand';
    SET @v := CONCAT(' value FROM ',db_prefix,'variable where name = vwhere');	
    SET @v := CONCAT(' value FROM ',db_prefix,'variable where name = ','"',vwhere,'"');	 
    SET vbrand = (select @v);    
    SET vPrefix = (select @v);
    SET vtech = (select @v);  */

    update astuser set lastaccount = nextid where uid = suid and db_prefix = sdb_prefix;
   
END
;;
delimiter ;


DROP PROCEDURE IF EXISTS astCreateAccount;
delimiter |

CREATE PROCEDURE astCreateAccount (OUT lastid int(10), suid int(10), stech varchar(128))
  NOT DETERMINISTIC
BEGIN
	DECLARE v INT;
	DECLARE max INT;
	DECLARE c INT;
	DECLARE mycallerid  varchar(255); 
	SELECT count(*) INTO c from astaccount where uid = 0 and tech = 'IAX';
	SET v = 0;
	SET max = 0;
	if c < 5 THEN 
		SET max = 10; 
		update aststatus set reload = 1 where serverid = 'fast';
		WHILE v < max DO
			CALL astCreateAcc(@a,0,'IAX');
			SET v = v + 1;
		END WHILE;
	END IF;
	SELECT count(*) INTO c from astaccount where uid = 0 and tech = 'SIP';
	SET v = 0;
	SET max = 0;
	if c < 5 THEN 
		SET max = 10; 
		update aststatus set reload = 1 where serverid = 'fast';
		WHILE v < max DO
			CALL astCreateAcc(@a,0,'SIP');
			SET v = v + 1;
		END WHILE;
	END IF;
	IF suid <> 0 THEN
 		select name into mycallerid from pbx_users where uid = suid; 
		select min(accountcode) INTO lastid from astaccount where uid = 0 and tech = stech;
		IF stech = 'VIR' THEN
			CALL astCreateAcc(@a,suid,stech);
			SET lastid = @a;
		END IF;
		update astaccount set uid = suid, callerid = mycallerid where accountcode = lastid;
		update astuser set lastaccount = lastid where uid = suid;
	END IF;
    if NOT EXISTS (select * from astuser where uid = suid) THEN
  	  insert into astuser (uid, callbackto, lastaccount, comment) values (suid, lastid, lastid, mycallerid);
    END IF;
END
|
delimiter ;


DROP PROCEDURE IF EXISTS RateAddcdr;
delimiter |

CREATE PROCEDURE RateAddcdr (saccountcode varchar(255),schannel varchar(255),
                    scallednum varchar(255),stype varchar(255),suniqueid varchar(255))
  NOT DETERMINISTIC
BEGIN
  /* Version 2.11 */
  /* Written By Are at astartelecom.com 
     RateGetTrunk Added saccountcode 
     29 Aug 2006 Are Casilla */

  DECLARE phone    varchar(255); 
  DECLARE Prefix   tinyint(3); /* CountryPrefix   */
  DECLARE strunk   varchar(128); /* The Trunk used for outgoing Dialing */
  DECLARE cplan    tinyint(1);   /* Tell os to route the calls as daytime, evening or weekend calls */
  DECLARE sbrand   varchar(128); /* The Trunk used for outgoing Dialing */
  DECLARE tallow00  tinyint(1);   /* Allow 00 dialing for IDD in front of number  */
  DECLARE tallow011  tinyint(1);   /* Allow 011 dialing for IDD in front of number  */
  DECLARE tlocallength  tinyint(2);   /* Length of Number for it to be considered Local  */
  
  SELECT brand INTO sbrand FROM astaccount, astuser WHERE astaccount.uid=astuser.uid and astaccount.db_prefix=astuser.db_prefix and astaccount.accountcode = saccountcode;
  SELECT astuser.CountryPrefix INTO Prefix FROM astaccount, astuser WHERE astaccount.uid=astuser.uid and astaccount.db_prefix=astuser.db_prefix and astaccount.accountcode = saccountcode;
  SET phone = scallednum;

  SET prefix = IFNULL(prefix,''); /* Allows for dialing even if use have no valid astaccount. Not likely but works during test with account code 77777 */
  
  SELECT allow00 INTO tallow00 FROM astcountryprefix WHERE CountryPrefix=Prefix;
  
  IF tallow00 IS NULL THEN 
  	IF scallednum REGEXP '^00' THEN
  		  SET phone = RIGHT(scallednum,LENGTH(scallednum)-2);	
  	ELSEIF scallednum REGEXP '^011' THEN 
  		  SET phone = RIGHT(scallednum,LENGTH(scallednum)-3);	
  	ELSE  
		  IF scallednum REGEXP '^0' THEN
  			  SET phone = CONCAT(Prefix,(RIGHT(scallednum,LENGTH(scallednum)-1)));		
      	END IF;
  	END IF;
  ELSE
	SELECT allow011 INTO tallow011 FROM astcountryprefix WHERE CountryPrefix=Prefix;
	SELECT locallength INTO tlocallength FROM astcountryprefix WHERE CountryPrefix=Prefix; 
		
  	IF scallednum REGEXP '^00' and tallow00 = 1 THEN
  		  SET phone = RIGHT(scallednum,LENGTH(scallednum)-2);	
  	ELSEIF scallednum REGEXP '^011' and tallow011 = 1 THEN 
  		  SET phone = RIGHT(scallednum,LENGTH(scallednum)-3);	
  	ELSEIF scallednum REGEXP '^0' THEN
  			  SET phone = CONCAT(Prefix,(RIGHT(scallednum,LENGTH(scallednum)-1)));		
  	ELSE  
		  IF LENGTH(scallednum) = tlocallength THEN
  			  SET phone = CONCAT(Prefix,scallednum);		
      	  END IF;
  	END IF; 
  END IF;
   
  CALL RateGetTrunk(@ptrunk,phone,saccountcode);
  SET strunk = @ptrunk;
  
  if strunk is NOT NULL THEN /* No CDR IF WE HAVE NO ROUTE   */
  	INSERT INTO astcdr (accountcode,channel,callednum,type,uniqueid,date_created,trunk,brand) 
  	VALUES (saccountcode,schannel,phone,stype,suniqueid,Now(),strunk,sbrand); 
  
  	UPDATE astaccount
  	set usagecount = usagecount +1
  	where accountcode = saccountcode;

  	UPDATE asttrunk
  	set usagecount = usagecount +1
  	where name = strunk;
  	CALL RateReserveCredit(suniqueid,'fast');
  ELSE	
   	INSERT INTO astlog (type, message, uniqueid, callednum ) VALUES ('ERROR', 'No Route-RateAddcdr.proc-10164', saccountcode, phone);
  END IF;
 
END
|
delimiter ;


DROP PROCEDURE IF EXISTS RateCost;
delimiter |

CREATE PROCEDURE RateCost (uid varchar(255))
BEGIN  
  /* Version 2.0.2 */
  /* Written By Are at astartelecom.com */
  /* TABLE as.troute is used to select our outgoing Dialing rute in PROCEDURE RateAddcdr  
     This table will also be the basis for our cost from our vendor. So we load all our outgoing rutes and vendor cost in to this table.*/
     
  /*  TABLE astpricelist is our price list to the customer. This can be totally different from the price list we have from our vendors. */ 
  
  /*  TABLE astplans contain values for billincrement, connectioncharge and markup = (our margin/profit)  
      Each customer will be assigned a brand. That brand will determine the sales price to the customer.   */  
  
  DECLARE phone       varchar(255);   
  DECLARE mydialst       varchar(255);   
  DECLARE myatime     int(11);
  DECLARE mybrand     varchar(128);
  DECLARE mymarkup    decimal(10,2);
  DECLARE myincrement tinyint(8);
  DECLARE astrouteid  int(11);
  DECLARE priceid     int(11);
  
  /* COST */
  DECLARE mycost          decimal(10,2);
  DECLARE myconnect       decimal(10,2);
  DECLARE myincluded      decimal(10,2);
  DECLARE minimum         decimal(10,2);
  DECLARE mycostincrement decimal(10,2);
  DECLARE mytrunk         varchar(128);
  DECLARE myvat           decimal(10,2);
    
  DECLARE adjtime     int(11);  
  DECLARE callcost    decimal(10,2);
  DECLARE sales       decimal(10,2);
  
  select trunk         INTO mytrunk     from astcdr   where uniqueid = uid;
  /* IF mytrunk = 'Local' THEN GOTO theend; END IF;  */

IF mytrunk <> 'Local' THEN
    
  select callednum     INTO phone       from astcdr   where uniqueid = uid;
  select answeredtime  INTO myatime     from astcdr   where uniqueid = uid;
  select dialstatus    INTO mydialst    from astcdr   where uniqueid = uid;
  
  select brand         INTO mybrand     from astcdr  where uniqueid = uid;
  select billincrement INTO myincrement from astcdr cdr,astplans pla where cdr.brand=pla.name and cdr.uniqueid=uid;
  select markup        INTO mymarkup from astcdr cdr,astplans pla where cdr.brand=pla.name and cdr.uniqueid=uid;
  select vat           INTO myvat       from asttrunk where asttrunk.name = mytrunk;

  
       
  /* CALCULATE OUR COST  */
  /* To save time first get id of TABLE astroute. REGEXP Lookup is VERY SLOW  */
  /* SELECT id INTO astrouteid FROM astroute WHERE phone REGEXP CONCAT("^",pattern) and trunk = 'Local' and patternlen = LENGTH(phone)  ORDER BY LENGTH( pattern ) DESC LIMIT 1; */

  SELECT id INTO astrouteid FROM astroute WHERE phone REGEXP CONCAT("^",pattern,".*")  ORDER BY LENGTH( pattern ) DESC LIMIT 1;
  SELECT cost            INTO mycost     FROM astroute WHERE id = astrouteid;
  SELECT connectcharge   INTO myconnect  FROM astroute WHERE id = astrouteid;
  SELECT includedseconds INTO myincluded FROM astroute WHERE id = astrouteid;
  SELECT billincrement   INTO mycostincrement  FROM astroute WHERE id = astrouteid;
  SELECT minimumcost     INTO minimum    FROM astroute WHERE id = astrouteid;
  SELECT trunk           INTO mytrunk    FROM astroute WHERE id = astrouteid;

  
  /* If astroute.minimumcost = 0 use connectcost and includedseconds. */
  /* astplans.billincrement  = How many step of secounds the billing is. */
  
  SET mycost = IFNULL(mycost,'-1');
  IF mycost = -1 THEN  /* This can only happend if there is no route to the destination. Log as CRITICAL ERROR and go on with default */
  	SET mycost = 15;
  	SET minimum = 15;
  	SET myconnect = 15;
  	SET myincluded = 0;
  	SET mytrunk = 'DEF';
  	SET phone = IFNULL(phone,'-1');
  	SET mycostincrement = 1;
  	IF mydialst like 'ANSWER%' THEN
  	 	INSERT INTO astlog (type, message, uniqueid, callednum ) VALUES ('ERROR', 'No Route-RateCost.proc-10153', uid, phone);
  	END IF;
  END IF;

  
  /* #### Calculating Our COST of phone call  ###################################### */
  IF (mycostincrement = 0 or mycostincrement = 1) THEN /* Billing Increment can't be 0 */
       SET adjtime = myatime;                          /* Adjust time up if we are getting incremented billing */
  ELSE                                                 /* (billsecounds / Incremen period) * Incremen period   */
       SET adjtime = (round((myatime / mycostincrement))+1) * mycostincrement; /* Incremented Billing = Billing in 30 secounds */
       IF mycostincrement >= myatime THEN
           SET adjtime = (round((myatime / mycostincrement))) * mycostincrement; /* Incremented Billing = Billing in 30 secounds */
       END IF; 
       IF (mycostincrement * 2) >= myatime THEN
           SET adjtime = (round((myatime / mycostincrement))) * mycostincrement; /* Incremented Billing = Billing in 30 secounds */
       END IF;  
       if adjtime = 0 THEN SET adjtime = mycostincrement; END IF;   
  END IF;                                              /* or 10 secounds or 60 secounds periods */
       SET adjtime = adjtime - myincluded;   /* If there is time included in connection charge we have to deduct it   */
															
  SET callcost = round(mycost * adjtime / 60,2);    /* The cost of the call
  													WARNING: Now cost is calculated from adjusted Time. You can have Incremented Billing for sales and
  													No Increments from your vendor. This is a BUG. ARE 19 July 2005    */
  IF callcost < minimum THEN
       SET callcost = minimum; /* We may get a minimum charge from our vendor */
  END IF;
   SET callcost = callcost + myconnect;  /* Add Vendors Connection Charge  */
   
   IF myvat <> 0 THEN SET callcost = callcost + round(((callcost * myvat) / 100),2); END IF; /* Some vendors are charging VAT. Thats a cost */
   
   IF myatime = 0 THEN SET callcost = 0; END IF;     /* If we have been connected for 0 secounds there is no cost.  */
   
   
   /* Below select is for debugging only  */
   /*      Our Real Cost     The cost pr minute     Connection fee included in conectionfee    Minimum cost   Adjusted time  answeredtime                        */
   
 /*
   select callcost as callcost, mycost as minuteco, myconnect as conn,       myincluded as inc, minimum as min,      adjtime,    myatime as time,  concat(phone,mytrunk) as tru;
 */
   
   CALL RateSale(@psales,@prate,@pbilltime,@priceid,uid);

   update astcdr
   set ourcost=callcost,price=@psales,pricerate=@prate,billtime=@pbilltime,priceid=@priceid
   where uniqueid = uid and
   dialstatus like 'ANSWER%';

END IF;
/* LABEL theend;      */

END
|
delimiter ;


DROP PROCEDURE IF EXISTS RateGetTrunk;
delimiter |

CREATE PROCEDURE RateGetTrunk (OUT strunk varchar(128), phone varchar(255),saccountcode varchar(255))
  NOT DETERMINISTIC
BEGIN
  /* Version 2.11
     Added saccountcode 29 Aug 2006
     Taken from RateAddCDR Ver 2.0.5 and made seperate procedure */
  /* Written By Are at astartelecom.com */

  DECLARE mydialst    varchar(255);  
  
  /* We have to Identify Local Calls  */
  /* if astroute.patternlen =  LENGTH(phone) and  trunk = 'Local' we are Local */
  IF EXISTS(SELECT trunk FROM astroute WHERE phone REGEXP CONCAT("^",pattern) and trunk = 'Local'  
					and patternlen = LENGTH(phone)  ORDER BY LENGTH( pattern ) DESC)
  THEN				
  	  set strunk = 'Local';
  ELSE
  	  SELECT trunk INTO strunk FROM astroute, asv_trunk_dialplan2 trunk
  	  WHERE astroute.trunk = trunk.name and
  	  phone RLIKE CONCAT("^",pattern,".*") and usagecount < maxusage and astroute.trunk <> 'Local' 
  	  ORDER BY patternlen, LENGTH( pattern ) DESC, trunk.trunkcost, costplan LIMIT 1;
  END IF;
  
  /* If we want to force a specific route for some accounts. We do that below */
  if strunk = 'priority2400' THEN
      SELECT IFNULL(trunkpath,strunk) into strunk FROM astaccount WHERE accountcode = saccountcode LIMIT 1;
  END IF;
  
  /* Use Default route */
  if strunk = 'DEF' THEN
      SELECT name INTO strunk FROM asttrunk WHERE isdefault = '1' LIMIT 1;
       /* SET strunk = IFNULL(strunk,'DEF');  */ /* This is Broken in MySQL 5.013 */
  END IF;

END
|
delimiter ;


DROP PROCEDURE IF EXISTS RateReserveCredit;
delimiter |

CREATE PROCEDURE RateReserveCredit (suniqueid varchar(255), server varchar(255))
  NOT DETERMINISTIC
BEGIN
  DECLARE saccountcode varchar(40); 
  DECLARE sreservedamount decimal(10,2); 
  DECLARE maxmin decimal(10,2);
  
  SELECT maxminute INTO maxmin FROM aststatus WHERE serverid = server;
  SELECT accountcode INTO saccountcode FROM astcdr WHERE uniqueid = suniqueid;
   
  CALL RateSale(@sales,@rate,@billtime,@priceid,suniqueid);
  /*  SELECT @sales,@rate,@billtime; */
  SET sreservedamount = @sales + (@rate * maxmin);
   
  IF sreservedamount is not null THEN
  	INSERT INTO astcreditres (uniqueid, accountcode,reservedamount, date_created) 
  	VALUES (suniqueid, saccountcode,sreservedamount,Now()); 
  END IF;
  
  
END
|
delimiter ;

DROP PROCEDURE IF EXISTS RateSale;
delimiter |

CREATE PROCEDURE RateSale (OUT psales decimal(10,2),OUT prate decimal(10,2),OUT pbilltime int(11),OUT ppriceid int(11),uid varchar(255))
BEGIN  
  /* Version 1.0.4 */
  /* Written By Are at astartelecom.com */
  /* TABLE astroute is used to select our outgoing Dialing rute in PROCEDURE RateAddcdr  
     This table will also be the basis for our cost from our vendor. So we load all our outgoing rutes and 
     vendor cost in to this table.*/
     
  /*  TABLE astpricelist is our price list to the customer. This can be totally different from the price list we have 
      from our vendors. */ 
  
  /*  TABLE astplans contain values for billincrement, connectioncharge and markup = (our margin/profit)  
      Each customer will be assigned a brand. That brand will determine the sales price to the customer.   */  
  /* Modified By Are Casilla 23 April 2006  */    
  /* Version 1.0.5 */
  
  DECLARE phone       varchar(255);   
  DECLARE mydialst    varchar(255);   
  DECLARE myatime     int(11);
  DECLARE mybrand     varchar(128);
  DECLARE mymarkup    decimal(10,2);
  DECLARE myincrement tinyint(8);
  DECLARE astrouteid  int(11);
  DECLARE priceid     int(11);
  DECLARE myaddsec    int(10);
  DECLARE mycallrate tinyint(4);
  
  
  
  /* SALES */
  DECLARE myprice         decimal(10,2);
  DECLARE myconnect       decimal(10,2);
  DECLARE myincluded      decimal(10,2);
  DECLARE minimum         decimal(10,2);
  DECLARE mybillincrement decimal(10,2);
  DECLARE mytrunk         varchar(128);
  DECLARE myproduct       varchar(40);

      
  DECLARE adjtime     int(11);  
  DECLARE sales       decimal(10,2) default 0;
  
  select trunk         INTO mytrunk     from astcdr   where uniqueid = uid;
IF mytrunk <> 'Local' THEN

  select callednum     INTO phone       from astcdr   where uniqueid = uid;
  select answeredtime  INTO myatime     from astcdr   where uniqueid = uid;
  select brand         INTO mybrand     from astcdr  where uniqueid = uid;
  select billincrement INTO mybillincrement from asvcall where uniqueid = uid;   
  select markup        INTO mymarkup    from asvcall  where uniqueid = uid;
  select dialstatus    INTO mydialst    from astcdr   where uniqueid = uid;
  select addseconds    INTO myaddsec    from astplans where name = mybrand;

 
  /* CALCULATE SALES  */
  /* To save time first get id of TABLE astpricelist. REGEXP Lookup is SLOW  */
  SELECT id              INTO priceid    FROM astpricelist WHERE phone REGEXP CONCAT("^",pattern,".*") and brand = mybrand ORDER BY LENGTH( pattern ) DESC LIMIT 1;
  SELECT price           INTO myprice    FROM astpricelist WHERE id = priceid;
  SELECT callrate        INTO mycallrate FROM asvcallrate WHERE uniqueid = uid;
  
  select CASE mycallrate WHEN 1 THEN price WHEN 2 THEN priceevening WHEN 3 THEN priceweekend ELSE price END mychoice
         INTO myprice  from astpricelist where id = priceid;
    
  SELECT connectcharge   INTO myconnect  FROM astpricelist WHERE id = priceid;
  SELECT includedseconds INTO myincluded FROM astpricelist WHERE id = priceid;
  SELECT minimumprice    INTO minimum    FROM astpricelist WHERE id = priceid;

  
  
  
  /* If astroute.minimumcost = 0 use connectcost and includedseconds. */
  /* astplans.billincrement  = How many step of secounds the billing is. */
  
  SET myprice = IFNULL(myprice,'-1');
  IF myprice = -1 THEN  /* This can only happend if there is no route to the destination. Log as CRITICAL ERROR and go on with default */
  	SET myprice = 15;
  	SET minimum = 15;
  	SET myconnect = 15;
  	SET myincluded = 0;
  	SET mytrunk = 'DEF';
  	SET phone = IFNULL(phone,'-1');
  	SET mybillincrement = 1;
  	IF mydialst like 'ANSWER%' THEN
  	  INSERT INTO astlog (type, message, uniqueid, callednum ) VALUES ('ERROR', 'No Route-RateSale.proc-10156', uid, phone);
  	END IF;
  END IF;
    
  /* #### Calculating Our COST of phone call  ###################################### */
  IF (mybillincrement = 0 or mybillincrement = 1) THEN /* Billing Increment can't be 0 */
       SET adjtime = myatime;          /* answeredtime - Adjust time up if we are getting incremented billing */
  ELSE                                                 /* (billsecounds / Incremen period) * Incremen period   */
       SET adjtime = (round((myatime / mybillincrement))+1) * mybillincrement; /* Incremented Billing = Billing in 30 secounds */
       IF mybillincrement >= myatime THEN
           SET adjtime = (round((myatime / mybillincrement))) * mybillincrement; /* Incremented Billing = Billing in 30 secounds */
       END IF;     
       IF (mybillincrement * 2) >= myatime THEN
           SET adjtime = (round((myatime / mybillincrement))) * mybillincrement; /* Incremented Billing = Billing in 30 secounds */
       END IF;     
       IF (adjtime < myatime) THEN
           SET adjtime = adjtime + mybillincrement; /* This will happen in rare cases Are Casilla 23 April 2006 */
       END IF;     
       if adjtime = 0 THEN SET adjtime = mybillincrement; END IF;
  END IF;                                              /* or 10 secounds or 60 secounds periods */
  
     SET adjtime = adjtime - myincluded;   /* If there is time included in connection charge we have to deduct it   */
     SET adjtime = adjtime + myaddsec;   

     SET sales = round(myprice * adjtime / 60,2);    /* The cost of the call
        
       														
  	/* WARNING: There is a minimum cost from our vendor. Remember to check for that  */												
   /* $costup = ($callcost * (10000 + $markup)) / 10000;  */
  SET sales = round(sales + (sales * mymarkup / 100),2);
   /* WARNING: There is a minimum SALES amound to our customer. Remember to check for that  */												

       
  IF sales < round(minimum + (minimum * mymarkup / 100),0) THEN
       SET sales = round(minimum + (minimum * mymarkup / 100),2); /* We may charge a minimum charge to our customer */
  END IF;

  /* Rounding BUG Below Are Casilla - Modified 1 Oct 2006  */
  SET myconnect = myconnect + round((myconnect * mymarkup / 100),0);
  /* SET sales = sales + round(myconnect + (myconnect * mymarkup / 100),0)  ;   Add Vendors Connection Charge  */

   SET sales = sales + round(myconnect,2)  ;   /*  Add Vendors Connection Charge  */
  
   /*
   update astcdr
   set price = sales
   where uniqueid = uid and
   dialstatus like 'ANSWER%';   */

END IF; 
  
 /* Pass info to OUT parameters */
SET pbilltime = adjtime; 
SET psales = sales;
SET prate = round(myprice + (myprice * mymarkup / 100),2);
SET ppriceid = priceid; 


/*                        minute Charges     Connection fee included in conectionfee    Minimum cost   Adjusted time  answeredtime                        */   
   
 /*  select sales, myprice as price, minimum as min, mybillincrement as binc, myconnect as con,adjtime,    myatime as time, mymarkup as markup, concat(phone,mybrand) as brand;    
   */
END
|
delimiter ;


DROP FUNCTION IF EXISTS TrunkDialPlan;
delimiter |
CREATE FUNCTION TrunkDialPlan(trunk varchar(128),usetime datetime) 
	  RETURNS varchar(40)
	  NOT DETERMINISTIC
BEGIN
      DECLARE day    tinyint(1); 
      DECLARE status       tinyint(2) default 0;  /*  0 = Daytime, 1 = Evening, 2 = Weekend  */
      DECLARE eveningtime  tinyint(1) default 19;
      DECLARE morningtime  tinyint(1) default 8;
      DECLARE timeonly      time;
      DECLARE starttime     time;
      DECLARE endtime       time;
        set timeonly = time(usetime);
     	set status = 0;
      	set day = DAYOFWEEK(usetime);


		/* Sunday  */
		IF day = 1 and EXISTS(select * from astdialplan where sun = 1 and accountcode = trunk)  THEN 
			select time(concat(start_time_hr,':',start_time_min,':00')) into starttime from astdialplan where accountcode = trunk and sun = 1 limit 1;
			select time(concat(end_time_hr,':',end_time_min,':59'))     into endtime   from astdialplan where accountcode = trunk and sun = 1 limit 1;
			IF timeonly >= starttime and  timeonly <= endtime THEN
				set status = 1;
			END IF;
		END IF;
		
		/* Monday  */
		IF day = 2 and EXISTS(select * from astdialplan where mon = 1 and accountcode = trunk)  THEN 
			select time(concat(start_time_hr,':',start_time_min,':00')) into starttime from astdialplan where accountcode = trunk and mon = 1 limit 1;
			select time(concat(end_time_hr,':',end_time_min,':59'))     into endtime   from astdialplan where accountcode = trunk and mon = 1 limit 1;
			IF timeonly >= starttime and  timeonly <= endtime THEN
				set status = 1;
			END IF;
		END IF;
		
		/* Tuesday  */
		IF day = 3 and EXISTS(select * from astdialplan where tue = 1 and accountcode = trunk)  THEN 
			select time(concat(start_time_hr,':',start_time_min,':00')) into starttime from astdialplan where accountcode = trunk and tue = 1 limit 1;
			select time(concat(end_time_hr,':',end_time_min,':59'))     into endtime   from astdialplan where accountcode = trunk and tue = 1 limit 1;
			IF timeonly >= starttime and  timeonly <= endtime THEN
				set status = 1;
			END IF;
		END IF;
		
		/* Wednesday  */
		IF day = 4 and EXISTS(select * from astdialplan where wed = 1 and accountcode = trunk)  THEN 
			select time(concat(start_time_hr,':',start_time_min,':00')) into starttime from astdialplan where accountcode = trunk and wed = 1 limit 1;
			select time(concat(end_time_hr,':',end_time_min,':59'))     into endtime   from astdialplan where accountcode = trunk and wed = 1 limit 1;
			IF timeonly >= starttime and  timeonly <= endtime THEN
				set status = 1;
			END IF;
		END IF;
		
		/* Thursday  */
		IF day = 5 and EXISTS(select * from astdialplan where thu = 1 and accountcode = trunk)  THEN 
			select time(concat(start_time_hr,':',start_time_min,':00')) into starttime from astdialplan where accountcode = trunk and thu = 1 limit 1;
			select time(concat(end_time_hr,':',end_time_min,':59'))     into endtime   from astdialplan where accountcode = trunk and thu = 1 limit 1;
			IF timeonly >= starttime and  timeonly <= endtime THEN
				set status = 1;
			END IF;
		END IF;
		
		/* Friday  */
		IF day = 6 and EXISTS(select * from astdialplan where fri = 1 and accountcode = trunk)  THEN 
			select time(concat(start_time_hr,':',start_time_min,':00')) into starttime from astdialplan where accountcode = trunk and fri = 1 limit 1;
			select time(concat(end_time_hr,':',end_time_min,':59'))     into endtime   from astdialplan where accountcode = trunk and fri = 1 limit 1;
			IF timeonly >= starttime and  timeonly <= endtime THEN
				set status = 1;
			END IF;
		END IF;
		
		/* Saturday  */
		IF day = 7 and EXISTS(select * from astdialplan where sat = 1 and accountcode = trunk)  THEN 
			select time(concat(start_time_hr,':',start_time_min,':00')) into starttime from astdialplan where accountcode = trunk and sat = 1 limit 1;
			select time(concat(end_time_hr,':',end_time_min,':59'))     into endtime   from astdialplan where accountcode = trunk and sat = 1 limit 1;
			IF timeonly >= starttime and  timeonly <= endtime THEN
				set status = 1;
			END IF;
		END IF;
		
		/* Return TRUE if there is no Record in astdialplan  */ 
		IF NOT EXISTS(select * from astdialplan where accountcode = trunk)  THEN 
			set status = 1;
		END IF;
		
		
      /*  set status = day;  */
      
      /* onetel - Local and national calls made between 8am - 6pm just 2.7p per minute. */
/*      IF (HOUR(usetime) < morningtime) or (HOUR(usetime) >= eveningtime) THEN
      	set status = 1; 
      END IF;
      
      IF (day = 6) and (HOUR(usetime) >= eveningtime) THEN
      	set status = 2; 
      END IF;      

      IF day = 7 or day = 1 THEN
      	set status = 2; 
      END IF;
*/      
/*  RETURN  concat(timeonly,'   ', starttime,'   ',endtime,'   ',status,'   ');  */
RETURN status;
END |
delimiter ;
	
delimiter |
CREATE PROCEDURE RateStarDead (suniqueid varchar(255), sdialstatus varchar(255),sansweredtime int(11),sdialedtime int(11))
  NOT DETERMINISTIC
BEGIN
  /* Version 2.0.0 */
  /* Written By Are at astartelecom.com */
  DECLARE phone    varchar(255); 
  DECLARE Prefix   tinyint(3); /* CountryPrefix   */
  DECLARE strunk  varchar(128); /* The Trunk used for outgoing Dialing */
  DECLARE status   tinyint(3); /* callstatus   */
	
  select trunk INTO strunk FROM astcdr where uniqueid = suniqueid LIMIT 1;
  SET status = 0;
  IF sdialstatus LIKE 'ANSWER%' and sansweredtime <> 0 and strunk <> 'Local' THEN
	  SET status = 1;
  END IF;
  
 UPDATE astcdr SET callstatus=status,dialstatus=sdialstatus,answeredtime=sansweredtime,billtime=sansweredtime,dialedtime=sdialedtime WHERE uniqueid = suniqueid LIMIT 1;
      
    UPDATE astaccount
    set usagecount = usagecount - 1
    where accountcode = (select accountcode from astcdr where uniqueid = suniqueid  LIMIT 1);

    UPDATE asttrunk
    set usagecount = usagecount - 1
    where name = strunk;
    
    delete from astcreditres where uniqueid = suniqueid;
    
 CALL RateCost(suniqueid);  

END
|
delimiter ;

/* This procedure is used for testing of Billing and Calculations */
/* CALL astTestBilling('70104'); */

DROP PROCEDURE IF EXISTS astTestBilling;
delimiter ;;
CREATE PROCEDURE astTestBilling (saccountcode varchar(255))
  NOT DETERMINISTIC
BEGIN
  DECLARE cdrcost  decimal(10,2); 
  DECLARE paidamount2  decimal(10,2); 
  
  select sum(price) into cdrcost from astcdr where dialstatus like 'ANSWER%' 
and answeredtime <> 0 and trunk <> 'Local' and accountcode = saccountcode;
  select sum(paidamount) into paidamount2 from astpayment where accountcode = saccountcode;
  SET cdrcost = round((cdrcost / 100),2);
  
  select cdrcost, paidamount2, creditlimit, startingcredit, round((paidamount2+creditlimit+startingcredit-cdrcost),2) Balance 
  from astaccount where accountcode = saccountcode;
  
END;;
delimiter ;

GRANT ALL PRIVILEGES ON astbill.* TO astbilluser@localhost IDENTIFIED BY 'astbill419';

SET PASSWORD FOR 'astbilluser'@'localhost' = OLD_PASSWORD('astbill419');

-- Below statement is needed on centos4.2 only. We include it to make it simple
-- http://astbill.com/node/178#comment-313

GRANT EXECUTE ON *.* TO 'astbilluser'@'localhost';

