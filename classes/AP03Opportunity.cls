/*
- Author : Michael Le Grand (Kerensen Consulting)
- Description : 
	Component : Trigger AP03 "New Owner to AccountTeam with Read Only Access" (Opportunity Before Update)
	Object (s):  Opportunity / AccountTeam / AccountShare
	What : New Owner is added to AccountTeam with Read Only Access  when Opportunity's ownersip change
- Delivery Date : 30/03/2009
- Governor informations :
	Single : 				SOQL queries : 0 / 20
							Query rows :  / 1000
							DML Statments : 1 / 20
							DML rows : 	1 / 100
	With others triggers :
							SOQL queries : 3 / 20
							Query rows :  2 / 1000
							DML Statments : 1 / 1000
							DML rows : 	1 / 20
*/

public class AP03Opportunity {

	//MLG 01/10/2010
	public static List<AccountShare> lstAccShareToTreat= new List<AccountShare>();
    public static List<AccountShare> lstAccShareToInsert= new List<AccountShare>();
	public static List<AccountShare> lstAccShareToUpdate= new List<AccountShare>();
	//Add User  in AccountTeam with Read Access
	//Important : When you add a user in an AccountTeam Member, automatically a record is
	//inserted in AccountShare Table with ReadOnly for Account and Private for Other objets
	public static void setUserInAccountTeamReadAccess(Opportunity[] Opportunities)
	{
		System.Debug('## >>> Starting AP03Opportunity.setUserBPInAccountTeamReadAccess <<<');
		List<AccountTeamMember> lstAccTMember= new List<AccountTeamMember>();
		
		for(Opportunity opp : Opportunities) 
		{
			System.debug('## UserId:'+opp.OwnerId);
			System.debug('## OpportunityId:'+opp.Id);
			AccountTeamMember accTMember = new AccountTeamMember();
			accTMember.UserId = opp.OwnerId;
			accTMember.AccountId = opp.AccountId;
			accTMember.TeamMemberRole = Config.BP_TEAM_MEMBER_ROLE;
			lstAccTMember.add(accTMember);
			//MLG  01/10/2010
			//lstAccShareToTreat.add(Util.manualShareAcc(opp.AccountId,opp.OwnerId,'Read','Read','None','None')); 
		} 
		//insert AccountTeamMember list
		Util.insertAccTMember(lstAccTMember);
		/*MLG  01/10/2010 */
		List<AccountShare> lstAccountShare = [Select Id,UserOrGroupId,AccountId from AccountShare where UserOrGroupId IN:Util.getSetFromFieldName(Opportunities,'OwnerId') AND AccountId IN:Util.getSetFromFieldName(Opportunities,'AccountId')];
		System.debug('lstAccountShare:'+lstAccountShare);
		for(AccountShare ash : lstAccountShare)
		{
			//ash.AccountAccessLevel = 'Read';
	       	//MLG 01/10/2010
	      	ash.ContactAccessLevel = 'Read';
	      	//ash.OpportunityAccessLevel = opportunityAccessLevel;
	      	//ash.CaseAccessLevel = caseAccessLevel;  
		}
		update lstAccountShare;
		
		System.Debug('## >>> Ending AP03Opportunity.setUserBPInAccountTeamReadAccess <<<');
	}

/*****************************************************************/
/**************** TEST METHODS ***********************************/
/*****************************************************************/	

//Scenario
//1. Change Owner of an Opportunity
//2. Verify that User is in AccountTeam with Read Access
	
static  testMethod void TestSetUserBPInAccountTeamWithReadAccess()
{
	List<ErrorLogItem > lstErrorLogItem = new List<ErrorLogItem >();
	Map<String,Integer> mapObjectNbSuccessDML = new Map<String,Integer>();
	Map<String,Integer> mapObjectNbErrorDML = new Map<String,Integer>();
	User userOldOwner =TestCommon.createUser('testmlg', 'MyTestUserName@test.test', 'MyTestLastName','MyTestFirstName',null); 
	User userNewOwner = TestCommon.createUser('testmlg2', 'MyTestUserName2@test.test', 'MyTestLastName2','MyTestFirstName2',null);
	//User userPartner = [select Id from User where UserType =: Config.USER_PARTNER and IsActive=:true limit 1];  
	
	Account acc1 = new Account(Name ='myCompany1');
	Account acc2 = new Account(Name ='myCompany2');
	List<Account> LstAcc = new List<Account>(); 
	
	Set<Id> SetRTID = Util.ESDOpptyRecordTypeId();
	
	Product2 p = TestCommon.createProduct('Nom', 'CodeProduit', true);
	
	PricebookEntry pe = TestCommon.createPricebookEntry(p);
	
	Account myAccount = TestCommon.createAccount(true);
	Account myAccountBP = TestCommon.createAccountBP(true);

	
	Contact c = TestCommon.createContact(myAccount.id);
	
	Opportunity opp = TestCommon.createOpportunity(myAccount.Id);
	
	opp.OwnerId = userNewOwner.Id;
	opp.BusinessPartner__c = myAccountBP.id;
	update opp; 
	
	Set<id> SetOppty = new Set<Id>();
	SetOppty.add(opp.id);
	Map<Id,Account> MapAccTemp = Util.getAccountMapFromOpportunities(SetOppty);

	
	List<Opportunity> lstOpp = new List<Opportunity>();
	lstOpp.add(opp);
	Set<id> SetAccTemp = Util.getAccountIds(lstOpp);
	Set<Id> SetId = Util.getIds(lstOpp);
	Set<Id> SetOpptyId = Util.getOwnerIds(lstOpp);
	Set<String> setTemp = Util.getSetFromFieldName(lstOpp, 'id');
	Map<String,String> MapTemp = Util.mapBuildFromList(lstOpp, 'Id', 'Name');
	String str = Util.getListIdForDynamicSoql(setTemp);

	lstAcc.add(acc1);
	lstAcc.add(acc2);
	Util.dataBaseActionLstSobjects(lstAcc,'Insert',lstErrorLogItem,mapObjectNbSuccessDML,mapObjectNbErrorDML); 
	Util.dataBaseActionLstSobjects(lstAcc,'Delete',lstErrorLogItem,mapObjectNbSuccessDML,mapObjectNbErrorDML); 
	
	String StrRT = acc1.RecordType.Name;
	String RTName = Util.getRtypeId('EMG - Customer Record Type');
	
	AP03Opportunity.setUserInAccountTeamReadAccess(lstOpp);
	
	AccountShare myAccountShare  = [select Id,AccountAccessLevel from AccountShare where UserOrGroupId = :userNewOwner.Id  and AccountId =: opp.AccountId limit 1];
	System.assertNotEquals(null, myAccountShare);
	if(myAccountShare != null)
		System.assertEquals('Read', myAccountShare.AccountAccessLevel);
	System.assertEquals(1, [select count() from AccountTeamMember where UserId = :userNewOwner.Id  and AccountId =: opp.AccountId and TeamMemberRole =: Config.BP_TEAM_MEMBER_ROLE]);
}

}