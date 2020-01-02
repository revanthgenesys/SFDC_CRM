public class TM02Opportunity {
/*
- Author : Michael Le Grand (Kerensen Consulting)
- Description : 
    Component : Trigger TM02 "TM Opportunities fields populate TM Accounts Fields" (Opportunity After Update / After Create)
    Object (s):  Opportunity / Account / Country__c / BusinessPartner__r
    What :  When Opportunities lookups fields "Country__c Or BusinessPartner__r"  are updated then all TM fields on Account Related to Triggered Opportunities are re-populates
- Delivery Date : 02/06/2009
- Governor informations :
    Single :                SOQL queries :  2 / 20 (Include : 1 child query)
                            Query rows :  / 1000
                            DML Statments : 1 / 20
                            DML rows :   / 100
    With others triggers :
                            SOQL queries :  / 20
                            Query rows :   / 1000
                            DML Statments :  / 1000
                            DML rows :   / 20
*/
//structure : Map<IdAccount, Map<TmAccountFieldName, List {IdOpty1Value1,IdOpty2Value2...impossible to add due to 255 length limit}>
public static Map<String,Map<String,List<String>>> mapfieldMonitor = new Map<String,Map<String,List<String>>>();
//Accounts to update with TM data
public static Map<Id,Account> mapAcc;

public static void addLstOptyFieldValuesOnAccount(Opportunity[] Opportunities)
{
	System.Debug('## <<< Starting TM02Opportunity.addLstOptyFieldValuesOnAccount <<<');
	
	List<string> TM_MONITOR_AD_EMAIL = new List<String>(); 
	TM_MONITOR_AD_EMAIL.add(Config.TM_MONITOR_AD_EMAIL1);
	TM_MONITOR_AD_EMAIL.add(Config.TM_MONITOR_AD_EMAIL2);
	TM_MONITOR_AD_EMAIL.add(Config.TM_MONITOR_AD_EMAIL3);
	
	//Select all AccountId concerned and Opportunities Related
	mapAcc = new Map<Id,Account> ([Select Id,Name,
	(Select Id,AccountId, 
	BusinessPartner__r.Name,BusinessPartner__r.AccountShortName__c, BusinessPartner__r.MasterDistributor__r.Name,
	Country__r.Name, Country__r.RU__c,Country__r.subRU__c,Country__r.Region__c 
	From Opportunities Order By Name)
	From Account where Id IN:Util.getSetFromFieldName(Opportunities,'AccountId')]);

	Map<Id,List<Opportunity>> mapAcIdLstOpp = new Map<Id,List<Opportunity>>();
	List<Opportunity> lstOpp = new List<Opportunity> ();
		
	//for(String accId : mapAcIdLstOpp.KeySet())
	for(Account a: mapAcc.Values())
	{		
		string lstTM_Opp_BP_Master_Name = '';
		string lstTM_Opp_BP_Name = '';
		string lstTM_Opp_Country_Name = '';
		string lstTM_Opp_Country_RU= '';
		string lstTM_Opp_Country_SubRU ='';
		string lstTM_Opp_Country_Region ='';
		for(Opportunity opp : a.Opportunities)
		{
			// Business Partner Fields
			if(opp.BusinessPartner__r != null)
			{
				if(opp.BusinessPartner__r.MasterDistributor__r != null)
					lstTM_Opp_BP_Master_Name = treatTMField(opp,'opp.BusinessPartner__r.MasterDistributor__r.Name',opp.BusinessPartner__r.MasterDistributor__r.Name, lstTM_Opp_BP_Master_Name,'TM_Opp_BP_Master_Name__c'); //add String to "lstTM_Opp_BP_Master_Name"
				
				lstTM_Opp_BP_Name = treatTMField(opp,'opp.BusinessPartner__r.AccountShortName__c',opp.BusinessPartner__r.AccountShortName__c,lstTM_Opp_BP_Name,'TM_Opp_BP_Name__c');
			}
			//Country Fields
			if(opp.Country__r != null)
			{
				lstTM_Opp_Country_Name = treatTMField(opp,'opp.Country__r.Name',opp.Country__r.Name,lstTM_Opp_Country_Name,'TM_Opp_Country_Name__c');
				lstTM_Opp_Country_RU = treatTMField(opp,'opp.Country__r.RU__c',opp.Country__r.RU__c,lstTM_Opp_Country_RU,'TM_Opp_Country_RU__c');
				lstTM_Opp_Country_SubRU = treatTMField(opp,'opp.Country__r.subRU__c',opp.Country__r.subRU__c,lstTM_Opp_Country_SubRU,'TM_Opp_Country_SubRU__c');
				lstTM_Opp_Country_Region = treatTMField(opp,'opp.Country__r.Region__c',opp.Country__r.Region__c,lstTM_Opp_Country_Region,'lstTM_Opp_Country_Region');
			}
		}
		a.TM_Opp_BP_Master_Name__c = lstTM_Opp_BP_Master_Name;
		a.TM_Opp_BP_Name__c = lstTM_Opp_BP_Name;
		a.TM_Opp_Country_Name__c = lstTM_Opp_Country_Name ;
		a.TM_Opp_Country_RU__c = lstTM_Opp_Country_RU;
		a.TM_Opp_Country_SubRU__c = lstTM_Opp_Country_SubRU;
		a.TM_Opp_Country_Region__c = lstTM_Opp_Country_Region;
		a.IsUpdatedByApexTrigger__c = true;
	}
	update mapAcc.Values();
	// Send Warning Email when TM Values from Opportunities could not be added to TM fields On Accounts
	if(mapfieldMonitor.size() > 0)		
		Util.sendEmail(TM_MONITOR_AD_EMAIL, getEmailBody(mapfieldMonitor));
		
		
	System.Debug('## >>> Ending TM02Opportunity.addLstOptyFieldValuesOnAccount <<<');
}

public static String treatTMField(Opportunity opp,String oppFieldTreated,String oppFieldValue, String TmpAccountTMFieldValue, String accountTMFieldName) 
{ 
	System.Debug('## >>> Starting TM02Opportunity.treatTMField <<<');
	if(oppFieldValue != null)
	{
		System.Debug('## >>> FIELD : '+oppFieldTreated + '<<<'); 
		System.debug('### String accountTMFieldName:'+ TmpAccountTMFieldValue);
		System.debug('### Size String accountTMFieldName:'+ TmpAccountTMFieldValue.length());
		System.debug('### String oppFieldName:'+ oppFieldValue);
		System.debug('### Size String oppFieldName:'+ oppFieldValue.length());
		//if Current String + New String > 255 (limit of text field then New String not taken into account)
		// And Opp value has not already been added
		//note : oppFieldValue.length()+1 because ";" will be append
		if(TmpAccountTMFieldValue.length()+ oppFieldValue.length()+1 < 256
			&& !TmpAccountTMFieldValue.contains(oppFieldValue))
		{
			TmpAccountTMFieldValue += oppFieldValue;
			//Manage Case there is not value -> avoid for instance following string "BPName;;;;;;;;"
			if(oppFieldValue!= null || !oppFieldValue.equals(''))
				TmpAccountTMFieldValue += Config.TM_VALUE_SEPARATOR;	 	
		}
		//Values that cannot be added to Account Field are save in a Map "mapfieldMonitor" then sent by Email
		//Structure mapfieldMonitor : Map<IdAccount, Map<TmAccountFieldName, List {IdOpty1Value1,IdOpty2Value2...impossible to add due to 255 length limit}>
		if(TmpAccountTMFieldValue.length()+ oppFieldValue.length()+1 >= 256
		&& !TmpAccountTMFieldValue.contains(oppFieldValue))
		{
			if(mapfieldMonitor.get(opp.AccountId) != null)
				if(mapfieldMonitor.get(opp.AccountId).get(accountTMFieldName) != null)
					mapfieldMonitor.get(opp.AccountId).get(accountTMFieldName).add(opp.Id + oppFieldValue);
				else
					mapfieldMonitor.get(opp.AccountId).put(accountTMFieldName,new String[]{ opp.Id + oppFieldValue});
			else
				mapfieldMonitor.put(opp.AccountId,new  Map<String,List<String>>{ accountTMFieldName => new String[]{opp.Id + oppFieldValue} });		
		}
	}
	System.Debug('## >>> Ending TM02Opportunity.treatTMField <<<');
	return TmpAccountTMFieldValue;
}

//Structure mapfieldMonitor : Map<IdAccount, Map<TmAccountFieldName, List {IdOpty1Value1,IdOpty2Value2...impossible to add due to 255 length limit}>
public static String getEmailBody(Map<String,Map<String,List<String>>> mapFieldValuesNotAdded)
{
	String body = '<b>Values not taken into account because of 255 caracters field size (TM Account Field : Opportunity values list) </b>';
	// Account 1
	//	'TM Account Field XXX' : Opty Value1 (Opp.Id :XXX), Opty Value2 (Opp.Id:XXX)
	//	'TM Account Field YYY' : Opty Value1 (Opp.Id :YYY), Opty Value2 (Opp.Id:YYY)
	for(String accId:mapFieldValuesNotAdded.keySet())
	{
		body += '<br /><br /><b> Account Id : '+ accId + '</b><hr />';
		for(String strTmAccountFieldName : mapFieldValuesNotAdded.get(accId).keySet())
		{
			body += '<u>TM Account Field Name "'+strTmAccountFieldName + '", missing values :</u> ';
			for(String IdOptyValue : mapFieldValuesNotAdded.get(accId).get(strTmAccountFieldName))
			{
				body += '<br />' + IdOptyValue.Substring(18,IdOptyValue.length()) + '(IdOpty:'+IdOptyValue.Substring(0,18) + ')';
			}
		}	
	} 
	return body;
}

/*****************************************************************/
/**************** TEST METHODS ***********************************/
/*****************************************************************/	

// THIS TEST METHOD VERIFY that every TM field related To BP from Opportunities are reported on Account
// TWO BP FIELDS TESTED : Opportunity.BusinessPartner__r.BPShortName__c & Opportunity.BusinessPartner__r.MasterDistributor__r.Name
static testMethod void testOptyTmBPFields()
{	
String strTM_Opp_BP_Name = '';
String strTM_Opp_BP_Master_Name = '';	
Account myAccount = TestCommon.createAccount(true);

Account bp1a = TestCommon.createAccountBP(true);

Account masterBp1 = TestCommon.createAccountBP(true);
masterBP1.MasterDistributor__c = bp1a.id;

Account masterBp2 = TestCommon.createAccountBP(true);

Opportunity opp1 = TestCommon.createOpportunity(myAccount.id);
opp1.BusinessPartner__c = masterBp1.Id;
update opp1;

Opportunity opp2 = TestCommon.createOpportunity(myAccount.id);
opp2.BusinessPartner__c = masterBp2.Id;
update opp2;

//verify update			  
opp1.BusinessPartner__c = null;
update opp1;

//verify delete
delete opp2;
strTM_Opp_BP_Name = [Select Id,TM_Opp_BP_Name__c From Account Where Id=:myAccount.Id].TM_Opp_BP_Name__c;
System.AssertEquals(null,strTM_Opp_BP_Name);
}

// THIS TEST METHOD VERIFY  : that every TM field related To Countrty from Opportunities are reported on Account
// FOUR BP FIELDS TESTED :
//Opportunity.Country__r.Name
//Opportunity.Country__r.RU__c
//Opportunity.Country__r.subRU__c
//Opportunity.Country__r.Region__c
static testMethod void testOptyTmCountryFields()
{	

Account myAccount = new Account(name='Acc_AlcatelTriggerTest '+datetime.newInstance(2008, 12, 1, 12, 30, 2));
insert myAccount;

Country__c c1 = new Country__c( Name = 'FranceBis',
								RU__c = 'RU France',
								SubRU__c = 'France Reg.',
								Region__c = 'EMEA Emerging Markets',
								Country__c = 'FranceBis'
								);
insert c1;

Country__c c2 = new Country__c( Name = 'ItalieBis',
								RU__c = 'RU Italie',
								SubRU__c = 'Italie Reg.',
								Region__c = 'APAC',
								Country__c = 'ItalieBis'
								);
insert c2;



Opportunity opp1 = new Opportunity(AccountId = myAccount.Id, //mapped with Asset
								  name='Opp_AlcatelTriggerTest 1', //mandatory
								  stageName='Open', //mandatory
								  CloseDate=Date.newInstance(2006,10,10),//mandatory
								  Country__c = c1.Id
								  );	
insert opp1;
Account accTmp = [Select Id,TM_Opp_Country_Name__c,TM_Opp_Country_RU__c,TM_Opp_Country_SubRU__c,TM_Opp_Country_Region__c From Account Where Id=:myAccount.Id];

Opportunity opp2 = new Opportunity(AccountId = myAccount.Id, //mapped with Asset
								  name='Opp_AlcatelTriggerTest 2', //mandatory
								  stageName='Open', //mandatory
								  CloseDate=Date.newInstance(2006,10,10),//mandatory
								  Country__c = c2.Id
								  );
insert opp2;
accTmp = [Select Id,TM_Opp_Country_Name__c,TM_Opp_Country_RU__c,TM_Opp_Country_SubRU__c,TM_Opp_Country_Region__c From Account Where Id=:myAccount.Id];

opp2.Country__c = null;
update opp2;
accTmp = [Select Id,TM_Opp_Country_Name__c,TM_Opp_Country_RU__c,TM_Opp_Country_SubRU__c,TM_Opp_Country_Region__c From Account Where Id=:myAccount.Id];

delete opp1;
accTmp = [Select Id,TM_Opp_Country_Name__c,TM_Opp_Country_RU__c,TM_Opp_Country_SubRU__c,TM_Opp_Country_Region__c From Account Where Id=:myAccount.Id];

}
/*
// THIS TEST METHOD VERIFY FOR ONE FIELD (Opportunity.BusinessPartner__r.BPShortName__c):
	 // -> Field size 255 limit
	 // -> Doubloon
static testMethod void testOneFieldLstOptyFieldValuesOnAccount()
{	
//1. Create Account
//2. Create Business Partners
// TEST ON "ACCOUNT.TM_Opp_BP_Name__c  = ACCOUNT.OPPORTUNITIES(BusinessPartner__r.BPShortName__c)
	 // 1st BP : name='aaaa...' (80  + ';' -> 81 characters)
	 // 2nd BP : name ='bbbb....' (80  + ';' -> 81 characters)
	 // 3rd BP : name ='cccc....' (80  + ';' -> 81 characters) -> 3 X 81 = 243 characters < 255 So it is OK
	 // 4nd BP : name = 'IsLimit255c' (11 + ';'  -> 12 characters ->  243 + 12 = 255 So it is OK
	 // 5nd BP : name = 'OutLimit256c' (12 + ';' -> 13 characters) -> 243 + 13 = 256 > 255 So Overlimit
		 
// TEST ON "ACCOUNT.TM_Opp_BP_Name__c  = ACCOUNT.OPPORTUNITIES(BusinessPartner__r.BPShortName__c)
	//DO TEST WITH 0 BP -> Verify that ACCOUNT.TM_Opp_BP_Name__c = ''
	//DO TEST WITH 1 BP (Name : 'aaa...') -> Verify that ACCOUNT.TM_Opp_BP_Name__c = 'aaa...';
	//DO TEST WITH 2 BP (Name : 'aaa...', 'bbb...') -> Verify that ACCOUNT.TM_Opp_BP_Name__c = 'aaa...' + ';' + 'bbb...';
	//DO TEST WITH 2 SIMILAR BP Name : (BP Names : 'aaa...', 'aaa...', 'ccc...') -> Verify that ACCOUNT.TM_Opp_BP_Name__c does not contain two times 'aaaa...'
	//DO TEST WITH 3BP, 240 characters (BP Names : 'aaa...', 'bbb...', 'ccc...') -> Verify OK
	//DO TEST WITH 255 characters (BP Names : 'aaa...', 'bbb...', 'ccc...', 'IsLimit255c') -> Verify OK
	//DO TEST UPDATE WITH IsLimit255c.BP = null (BP Names : 'aaa...', 'bbb...', 'ccc...', 'IsLimit255c') -> Verify OK
	//DO TEST WITH UPDATE OPTY : REPLACE 1 BP
	//DO TEST WITH 256 characters (BP Names : 'aaa...', 'bbb...', 'ccc...', 'OutLimit256c') -> Verify NOK + EMAIL specifying that value 'OutLimit256c' has not been added

	String strTM_Opp_BP_Name = '';
	Account myAccount = new Account(name='Acc_AlcatelTriggerTest '+datetime.newInstance(2008, 12, 1, 12, 30, 2));
	insert myAccount;
	BusinessPartner__c bpAAA80c = new BusinessPartner__c(
	Name = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
	BPShortName__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
	Street1__c ='street');
	insert bpAAA80c;
	BusinessPartner__c bpBBB80c = new BusinessPartner__c(
	Name = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', 
	BPShortName__c = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
	Street1__c ='street');
	insert bpBBB80c;
	BusinessPartner__c bpCCC80c = new BusinessPartner__c(
	Name = 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc', 
	BPShortName__c = 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc', 
	Street1__c ='street');
	insert bpCCC80c;
	BusinessPartner__c bpIsLimit255c = new BusinessPartner__c(
	Name = 'IsLimit255c', 
	BPShortName__c = 'IsLimit255c',
	Street1__c ='street');
	insert bpIsLimit255c;
	BusinessPartner__c OutLimit256c = new BusinessPartner__c(
	Name = 'OutLimit256c', 
	BPShortName__c = 'OutLimit256c',
	Street1__c ='street');
	insert OutLimit256c;
	
	System.AssertEquals(81, (bpAAA80c.BPShortName__c + Config.TM_VALUE_SEPARATOR).length());
	System.AssertEquals(81, (bpBBB80c.BPShortName__c + Config.TM_VALUE_SEPARATOR).length());
	System.AssertEquals(81, (bpCCC80c.BPShortName__c + Config.TM_VALUE_SEPARATOR).length());
	System.AssertEquals(12, (bpIsLimit255c.BPShortName__c + Config.TM_VALUE_SEPARATOR).length());
	System.AssertEquals(13, (OutLimit256c.BPShortName__c + Config.TM_VALUE_SEPARATOR).length());
	
	//DO TEST WITH 0 BP -> Verify that ACCOUNT.TM_Opp_BP_Name__c = ''
	Opportunity oppNoBp = new Opportunity(AccountId = myAccount.Id, //mapped with Asset
										name='Opp_AlcatelTriggerTest', //mandatory
										stageName='Open', //mandatory
										CloseDate=Date.newInstance(2006,10,10)//mandatory
										);
	insert oppNoBp;
	strTM_Opp_BP_Name = [Select Id,TM_Opp_BP_Name__c From Account Where Id=:myAccount.Id].TM_Opp_BP_Name__c;
	System.AssertEquals(null,strTM_Opp_BP_Name);
	
	//DO TEST WITH 1 BP (Name : 'aaa...') -> Verify that ACCOUNT.TM_Opp_BP_Name__c = 'aaa...';							
	Opportunity oppBpAAA80c = new Opportunity(AccountId = myAccount.Id, //mapped with Asset
										name='Opp_AlcatelTriggerTest', //mandatory
										stageName='Open', //mandatory
										CloseDate=Date.newInstance(2006,10,10),//mandatory
										BusinessPartner__c = bpAAA80c.Id
										);
	insert oppBpAAA80c;
	strTM_Opp_BP_Name = [Select Id,TM_Opp_BP_Name__c From Account Where Id=:myAccount.Id].TM_Opp_BP_Name__c;
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpAAA80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	
	//DO TEST WITH 2 BP (Name : 'aaa...', 'bbb...') -> Verify that ACCOUNT.TM_Opp_BP_Name__c = 'aaa...' + ';' + 'bbb...';
	Opportunity oppBBB80c = new Opportunity(AccountId = myAccount.Id, //mapped with Asset
										name='Opp_AlcatelTriggerTest 2', //mandatory
										stageName='Open', //mandatory
										CloseDate=Date.newInstance(2006,10,10),//mandatory
										BusinessPartner__c = bpBBB80c.Id
										);
	insert oppBBB80c;
	strTM_Opp_BP_Name = [Select Id,TM_Opp_BP_Name__c From Account Where Id=:myAccount.Id].TM_Opp_BP_Name__c;
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpAAA80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpBBB80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	
	//DO TEST WITH 2 SIMILAR BP Name : (BP Names : 'aaa...', 'aaa...', 'ccc...') -> Verify that ACCOUNT.TM_Opp_BP_Name__c does not contain two times 'aaaa...'
	Opportunity oppAAA80cBis = new Opportunity(AccountId = myAccount.Id, //mapped with Asset
										name='Opp_AlcatelTriggerTest 2', //mandatory
										stageName='Open', //mandatory
										CloseDate=Date.newInstance(2006,10,10),//mandatory
										BusinessPartner__c = bpAAA80c.Id
										);
	insert oppAAA80cBis;
	strTM_Opp_BP_Name = [Select Id,TM_Opp_BP_Name__c From Account Where Id=:myAccount.Id].TM_Opp_BP_Name__c;
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpAAA80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpBBB80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	System.AssertNotEquals(strTM_Opp_BP_Name.length(),(bpAAA80c.BPShortName__c + Config.TM_VALUE_SEPARATOR + bpAAA80c.BPShortName__c + Config.TM_VALUE_SEPARATOR + bpBBB80c.BPShortName__c + Config.TM_VALUE_SEPARATOR).length());
	System.AssertEquals(strTM_Opp_BP_Name.length(),(bpAAA80c.BPShortName__c + Config.TM_VALUE_SEPARATOR + bpBBB80c.BPShortName__c + Config.TM_VALUE_SEPARATOR).length());
	
	//DO TEST WITH 3BP, 240 characters (BP Names : 'aaa...', 'bbb...', 'ccc...') -> Verify OK						
	Opportunity oppBpCCC80c = new Opportunity(AccountId = myAccount.Id, //mapped with Asset
										name='Opp_AlcatelTriggerTest 4', //mandatory
										stageName='Open', //mandatory
										CloseDate=Date.newInstance(2006,10,10),//mandatory
										BusinessPartner__c = bpCCC80c.Id
										);
	insert oppBpCCC80c;
	strTM_Opp_BP_Name = [Select Id,TM_Opp_BP_Name__c From Account Where Id=:myAccount.Id].TM_Opp_BP_Name__c;
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpAAA80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpBBB80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpCCC80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	
	//DO TEST WITH 255 characters (BP Names : 'aaa...', 'bbb...', 'ccc...', 'IsLimit255c') -> Verify OK
	Opportunity oppBpIsLimit255c = new Opportunity(AccountId = myAccount.Id, //mapped with Asset
										name='Opp_AlcatelTriggerTest 5', //mandatory
										stageName='Open', //mandatory
										CloseDate=Date.newInstance(2006,10,10),//mandatory
										BusinessPartner__c = bpIsLimit255c.Id
										);
	insert oppBpIsLimit255c;
	strTM_Opp_BP_Name = [Select Id,TM_Opp_BP_Name__c From Account Where Id=:myAccount.Id].TM_Opp_BP_Name__c;
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpAAA80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpBBB80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpCCC80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));									
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpIsLimit255c.BPShortName__c + Config.TM_VALUE_SEPARATOR));	
	
	//DO TEST UPDATE WITH IsLimit255c.BP = null (BP Names : 'aaa...', 'bbb...', 'ccc...', 'IsLimit255c') -> Verify OK
	oppBpIsLimit255c.BusinessPartner__r = null;
	update oppBpIsLimit255c;
	strTM_Opp_BP_Name = [Select Id,TM_Opp_BP_Name__c From Account Where Id=:myAccount.Id].TM_Opp_BP_Name__c;
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpAAA80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpBBB80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpCCC80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));									
	
	//DO TEST WITH 256 characters (BP Names : 'aaa...', 'bbb...', 'ccc...', 'OutLimit256c') -> Verify NOK + EMAIL specifying that value 'OutLimit256c' has not been added
	Opportunity oppBpOutLimit256c = new Opportunity(AccountId = myAccount.Id, //mapped with Asset
										name='Opp_AlcatelTriggerTest 6', //mandatory
										stageName='Open', //mandatory
										CloseDate=Date.newInstance(2006,10,10),//mandatory
										BusinessPartner__c = OutLimit256c.Id
										);
	insert oppBpOutLimit256c;
	//verify that BP name has not been added
	strTM_Opp_BP_Name = [Select Id,TM_Opp_BP_Name__c From Account Where Id=:myAccount.Id].TM_Opp_BP_Name__c;
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpAAA80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpBBB80c.BPShortName__c + Config.TM_VALUE_SEPARATOR));
	System.AssertEquals(true,strTM_Opp_BP_Name.contains(bpCCC80c.BPShortName__c + Config.TM_VALUE_SEPARATOR)); //NOTE that Select Of Opportunities is order by Name (cf SOQL Query)		
}*/
}