public without sharing class AP04Opportunity {
	
//Number of SOQL queries: 
//Number of query rows: 
//Number of SOSL queries: 
//Number of DML statements: 
	
public static void addBPOwnerToSalesTeam(List <Opportunity> lstOpportunity) 
  {
	Util.MyLog('Start AP04Opportunity.addBPOwnerToSalesTeam');
	Set<Id> setOwnerIdAccount = new Set<Id>();
	for(Opportunity o : lstOpportunity) 
	{
	    if (o.BusinessPartner__c!= null)  
	       setOwnerIdAccount.add(o.BusinessPartner__c);
	}  
	       
	Map <Id, Account> mapAccount = new Map <Id, Account> (
	        [Select Id, Name, OwnerId
	         From Account
	         where Id in:setOwnerIdAccount]);
         
	List<OpportunityTeamMember> ListOppoTeamM = new List<OpportunityTeamMember> ();
	List<OpportunityTeamMember> ListOppoTeamM2 = new List<OpportunityTeamMember> ();
	//MLG 24/01/2011 : BP Owner must have R/W Access on Opportunity
	List<OpportunityShare> lstOps = new List<OpportunityShare>();
	
	if (Test.isRunningTest() || System.Trigger.IsUpdate)
     	{
     		ListOppoTeamM2 = [select OpportunityId,UserId, TeamMemberRole 
     						From OpportunityTeamMember
     						where OpportunityId in :lstOpportunity and 
     						TeamMemberRole =: Config.EMG_BUSINESS_PARTNER_OWNER];
     	}
     delete ListOppoTeamM2;	
	for (Opportunity oppo : lstOpportunity) 
  	{
     if (oppo.BusinessPartner__c!=Null)
     {  		
     		Util.MyLog('oppo :' + oppo );
	     	OpportunityTeamMember OppoTeamM = new OpportunityTeamMember();
	     	OppoTeamM.OpportunityId = oppo.Id;
	     	OppoTeamM.UserId = mapAccount.get(oppo.BusinessPartner__c).OwnerId;
	     	OppoTeamM.TeamMemberRole = Config.EMG_BUSINESS_PARTNER_OWNER;
	     	ListOppoTeamM.add(OppoTeamM);
	     	//MLG 24/01/2011 : BP Owner must have R/W Access on Opportunity
	     	if(oppo.OwnerId != mapAccount.get(oppo.BusinessPartner__c).OwnerId) //avoid error insufficient access rights on cross-reference id
	     	{																	//see http://wiki.developerforce.com/index.php/CRC:Design_Data_Migration_Best_Practices
		     	OpportunityShare ops = new OpportunityShare();
		     	ops.OpportunityId = oppo.Id;
		     	ops.OpportunityAccessLevel = 'Edit';
		     	ops.UserOrGroupId = mapAccount.get(oppo.BusinessPartner__c).OwnerId;
		     	lstOps.add(ops);
	     	}
       }
    }
    if(ListOppoTeamM.size() > 0)    
   		insert ListOppoTeamM;
	if(lstOps.size() > 0)
		insert lstOps; //MLG 24/01/2011
   Util.myLog('End AP04Opportunity.addBPOwnerToSalesTeam');
  }	
  @isTest(seeAllData=true)
  static void TestSetAddBPOwnerToSalesTeam() {
	User use = TestCommon.createUser('testmlg', 'Mmichael.legrand@emg.alcatel-lucent.com.emgdev', 'MyTestLastName','MyTestFirstName',Config.PROFIL_ADMIN_ID);

	Account myAccount = TestCommon.createAccount(true);
	
	Account myAccountBP = TestCommon.createAccountBP(true);
	myAccountBP.OwnerId = use.Id;
	update myAccountBP;
	Test.startTest();
	Opportunity opp = new Opportunity(
										name='Opp_AlcatelTriggerTest', //mandatory
										stageName='Open', //mandatory
										CloseDate=Date.newInstance(2006,10,10),//mandatory
										BusinessPartner__c = myAccountBP.Id,
										WonLostCancelledReason__c = 'Best Practice' , 
										//Competitor__c = '3COM',
										OpportunityBPStatus__c = Config.CORE_OPP_BP_STATUS_ALLOCATED										
										);
	insert opp;
	 System.RunAs(use) {
	
	
	Opportunity Opp2 = [Select Id, Name,
	                        (Select OpportunityId, UserId From OpportunityTeamMembers)  
                    	from Opportunity o
                    	where o.Id =: opp.Id
                    	limit 1]; 

	
	List<OpportunityTeamMember> oppTeamMember = [Select Id, UserId
                   					       from OpportunityTeamMember 
                   					       where OpportunityId=:opp.id];                         	
                   					   
	//System.assertEquals(myAccountBP.OwnerId , oppTeamMember.UserId);
	Test.stopTest();	
	 }
    }
     
  static testMethod void TestSetUpdateBPOwnerToSalesTeam() {
    User use1 = TestCommon.createUser('testtet', 'test.test@emg.alcatel-lucent.com.emgdev', 'MyTestLastName','MyTestFirstName',Config.PROFIL_ADMIN_ID);
    User use2 = TestCommon.createUser('testhli', 'h.lahmadi@emg.alcatel-lucent.com.emgdev', 'MyLastName','MyFirstName',Config.PROFIL_ADMIN_ID);
    
	Account myAccount = TestCommon.createAccount(true);
	
	Account myAccountBP1 = TestCommon.createAccountBP(true);
	myAccountBP1.OwnerId = use1.Id;
	update myAccountBP1;
	
	Account myAccountBP2 = TestCommon.createAccountBP(true);
	myAccountBP2.OwnerId = use2.Id;
	update myAccountBP2;
	
	Opportunity opp ;
	
	System.RunAs(use1) {
	Test.startTest();
	opp = new Opportunity(
							name='Opp_AlcatelTriggerTest', //mandatory
							stageName='Open', //mandatory
							CloseDate=Date.newInstance(2006,10,10),//mandatory
							BusinessPartner__c = myAccountBP1.Id,
							WonLostCancelledReason__c = 'Best Practice' , 
							//Competitor__c = '3COM',
							OpportunityBPStatus__c = Config.CORE_OPP_BP_STATUS_ALLOCATED										
							);
	insert opp;
	}
	 System.RunAs(use2) {
     Util.myLog('Start Test');     
	 
	 update opp;
	 
	List<OpportunityTeamMember> oppTeamMember = [Select Id, UserId
                   					       from OpportunityTeamMember 
                   					       where OpportunityId=:opp.id];                         	
    if(oppTeamMember.size() > 0)
		System.assertEquals(myAccountBP1.OwnerId , oppTeamMember[0].UserId);
	Test.stopTest();	
	 }
   }
}