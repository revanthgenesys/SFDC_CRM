/*
- Author : Michael Le Grand (Kerensen Consulting)
- Description : 
    Component : Trigger Business Partner Owner change (Account Before Update, Before Insert)
    Object (s):   Account / OpportunityTeamMember
    What :  When an Business Partner Account Owner is changed 
                then Ex-Owner is deleted from SalesTeam
                and New-Owner is added from SalesTeam
- Delivery Date : 19/11/2010
- Governor informations : TO Update
    Single :                SOQL queries : ? / 20
                            Query rows : ? / 1000
                            DML Statments : ? / 20
                            DML rows :  ? / 100
    With others triggers :
                            SOQL queries : ? / 20
                            Query rows :  ? / 1000
                            DML Statments : ? / 20
                            DML rows :  ? / 100
- Modification
	MLG 01/02/2011: For Each Business Partner checked insert/delete BP Owner in Opportunity Sales Teams
					Désormais Traitement en Mode "ANNULE ET REMPLACE" au lieu de "REMPLACE"
*/

global class  BA01BusinessPartnerOwnerChanged implements Database.Batchable<sObject>, Database.Stateful{

public String query;
global final Map<Id,Account> mapAccount = new Map<Id,Account>();
global final String batchObjectName;
global Set<String> setObjectsTreated = new Set<String>();
global List<ErrorLogItem > lstErrorLogItem = new List<ErrorLogItem >();
global Map<String,Integer> mapObjectNbSuccessDML = new Map<String,Integer>();
global Map<String,Integer> mapObjectNbErrorDML = new Map<String,Integer>();

/*
=============================================================================================
  CONSTRUCTOR
===============================================================================================
*/

global BA01BusinessPartnerOwnerChanged(String batchObjectName, Account[] Accounts){
    Util.myLog('START BA01BusinessPartnerOwnerChanged.BA01BusinessPartnerOwnerChanged()'); 
    System.Debug('###### Util.getSET = ' + Util.getSetFromFieldName(Accounts, 'Id'));
    mapAccount.putall(Accounts);
    /*
    this.query = 'SELECT o.id, o.OpportunityId,o.Opportunity.OwnerId, o.Opportunity.AccountId,o.Opportunity.BusinessPartner__c,o.TeamMemberRole,o.Opportunity.BusinessPartner__r.OwnerId FROM OpportunityTeamMember o WHERE o.TeamMemberRole = \'' + Config.BP_ROLE + '\' AND o.Opportunity.BusinessPartner__c ';
    this.query += 'IN ('+Util.getSoqlListIdFromSet(MapAccount.keyset()) + ')';
    */
   // this.query = 'SELECT Id, OwnerId, AccountId, BusinessPartner__c, BusinessPartner__r.OwnerId From Opportunity Where IsClosed = false AND IsWon = false';
    this.query = System.Label.BA01_OPTY_SOQL_QUERY;
    if(System.Label.BA01_OPTY_SOQL_QUERY.toUpperCase().contains('WHERE')) this.query += ' AND ';
    else this.query += ' WHERE ';
    this.query += ' BusinessPartner__c  IN ('+Util.getSoqlListIdFromSet(MapAccount.keyset()) + ')';
    Util.mylog(query);
    this.batchObjectName = batchObjectName;
    
    //VERIFY IF THERE IS NO INACTIVE OWNER
	verifyInactiveUsers(Accounts);
	
    Util.myLog('END BA01BusinessPartnerOwnerChanged.BA01BusinessPartnerOwnerChanged()'); 
}

/*
=============================================================================================
  QUERYLOCATOR
===============================================================================================
*/

global Database.QueryLocator start(Database.BatchableContext BC){
    Util.myLog('START BA01BusinessPartnerOwnerChanged.Start()'); 
    Util.myLog('############################################');
    Util.myLog('batchObjectName:'+batchObjectName);
    Util.myLog('############################################');
    Util.myLog('query:'+query);
    return Database.getQueryLocator(query);                                    
}

/*
=============================================================================================
  EXECUTE
===============================================================================================
*/

global void execute(Database.BatchableContext BC, List<sObject> scope)
{
    Util.myLog('START BA01BusinessPartnerOwnerChanged.execute()');
    ///////////////////////   STEPS //////////////////////////
    //Pour chaque Opportunité
    	//Récupérer les enregistrements SalesTeam dont le Role = "BP Owner"
    	//Supprimer ces enregistrements
    	//créer les nouveaux nouveaux enregistrements SalesTeam pour chaque Opportunité
    /////////////////////////////////////////
    //Initialize Batch Report Maps
    setObjectsTreated = new Set<String>{'Account','OpportunityTeamMember','OpportunityShare'};
    for(String obj : setObjectsTreated)
    {
        mapObjectNbSuccessDML.put(obj,0);
        mapObjectNbErrorDML.put(obj,0);
    }
    Map<Id,Account> mapAccountToUnckeck = new Map<Id,Account>();
    Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>();
    mapOpportunities.putAll((List<Opportunity>)scope);
    List<OpportunityTeamMember> lstOptmToInsert = new List<OpportunityTeamMember>();
     //MLG 24/01/2011 : BP Owner must have R/W Access on Opportunity
    List<OpportunityShare> lstOps = new List<OpportunityShare>();
    List<OpportunityTeamMember> lstOptmToDelete = [Select Id From OpportunityTeamMember Where OpportunityId IN:mapOpportunities.keySet() AND TeamMemberRole =: Config.BP_ROLE ];
    if(lstOptmToDelete.size() > 0)
    {
    	System.debug('###lstOptmToDelete:' + lstOptmToDelete);
    	//DML Action : DELETE existing OpportunityTeamMembers
        Database.delete(lstOptmToDelete,false);
    }
    //prepare list of OptyTeamMember and OptyShare to insert
    for(Opportunity op : mapOpportunities.Values())
    {
    	System.debug('###opty en cours:' + op);
    	OpportunityTeamMember newOTM = new OpportunityTeamMember();
        newOTM.OpportunityId = op.Id;
        newOTM.UserId = op.BusinessPartner__r.OwnerID;
        newOTM.TeamMemberRole = Config.BP_ROLE;
        lstOptmToInsert.add(newOTM);
        
       if(op.OwnerId !=  op.BusinessPartner__r.OwnerID) //avoid error insufficient access rights on cross-reference id
	   {																	//see http://wiki.developerforce.com/index.php/CRC:Design_Data_Migration_Best_Practices
            OpportunityShare ops = new OpportunityShare();
            ops.OpportunityId = op.Id;
	     	ops.OpportunityAccessLevel = 'Edit';
	     	ops.UserOrGroupId = op.BusinessPartner__r.OwnerID;
	     	lstOps.add(ops);
	   }
    }

    //DML Action : INSERT OpportunityTeamMember / OpportunityShare
    if(lstOptmToInsert.size() > 0)
    {
        //Insert OpportunityTeamMember
        Util.dataBaseActionLstSobjects(lstOptmToInsert,'Insert',lstErrorLogItem,mapObjectNbSuccessDML,mapObjectNbErrorDML);
        //Insert OpportunityShare (To Authorize Read/Write Access on Opportunity)
        if(lstOps.size() > 0)
        	  Util.dataBaseActionLstSobjects(lstOps,'Insert',lstErrorLogItem,mapObjectNbSuccessDML,mapObjectNbErrorDML);
    }
     //DML Action : UPDATE To Uncheck Business Partner Account
   // if(mapAccount.Values().size() > 0 &&  !(lstErrorLogItem.size() > 0))
   if(mapAccount.Values().size() > 0) 
    {
      
 		//Prepare to uncheck Accounts
    	for(Account a : mapAccount.Values()){
    			a.ToBeTreatedByBA001__c = false;
    	}
    	Util.dataBaseActionLstSobjects(mapAccount.Values(),'Update',lstErrorLogItem,mapObjectNbSuccessDML,mapObjectNbErrorDML);
   }
}

/*
=============================================================================================
 VERIFY INACTIVE OWNERS OF BP AND OPTYS
===============================================================================================
*/
public static void verifyInactiveUsers(List<Account> BA01Accounts)
{
   		Util.myLog('START Schedule_BA01BusinessPartnerOwnerChanged.verifyInactiveUsers()');
   		Set<Id> setAccountIds = new Set<Id>();
   		boolean sendEmail = false;
   		for(Account a : BA01Accounts)setAccountIds.add(a.Id);
   		List<Account> lstBP = [Select Id, Name,Owner.Name, OwnerId from Account where Type ='Partner' And ToBeTreatedByBA001__c = true AND Owner.IsActive = false];
   		List<Opportunity> lstOpty =  [Select Id, Name,Owner.Name, OwnerId from Opportunity Where Owner.IsActive = false AND BusinessPartner__r.ToBeTreatedByBA001__c = true];
   		String emailMessage = '<br /> BATCH APEX BA001 - VERIFICATION';
   		emailMessage += '<br />';
   		emailMessage += '<br /> List of Inactive Owner of Business Partners and/or Opportunies that could generate errors during BA001 treatment :';
   		emailMessage += '<br />';
   		if(lstBP.size() > 0)
   		{
   			sendEmail = true;
   			Map<Id,String> mapUser = new Map<Id,String>();
   			emailMessage += '<br /> # List of Inactive Owner of Business Partners :';
   			for(Account a: lstBP) mapUser.put(a.OwnerId, a.Owner.Name);
			for(Id i : mapUser.keySet()) emailMessage += '<br />  - ' + mapUser.get(i) + ' / ' + i;
   		}
   		
   		
   		if(lstOpty.size() > 0)
   		{
   			sendEmail = true;
   			Map<Id,String> mapUser2 = new Map<Id,String>();
   			emailMessage += '<br />';
   			emailMessage += '<br /> # List of Inactive Owner of Opportunities :';
   			for(Opportunity o: lstOpty) mapUser2.put(o.OwnerId, o.Owner.Name);
			for(Id j : mapUser2.keySet()) emailMessage += '<br />  - ' + mapUser2.get(j) + ' / ' + j;
   		}
   		System.debug('emailMessage:'+emailMessage);
   		if(sendEmail == true)
   		{
   			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			User currentUser = [Select Id, Email from User where Id =: UserInfo.getUserId() limit 1];
			String[] toAddresses = new String[] {currentUser.Email};
		    if(System.Label.BA01_EmailDest != '' && System.Label.BA01_EmailDest != null)
		     	toAddresses.add(System.Label.BA01_EmailDest);
			mail.setToAddresses(toAddresses);
			mail.setReplyTo('noreply@salesforce.com');
			mail.setBccSender(false);
			mail.setUseSignature(false);
   			mail.setSenderDisplayName('Batch Apex');
			mail.setSubject('BA01BusinessPartnerOwnerChanged : Verify Inactive Owner of Business Partners & Opportunities');
			mail.setPlainTextBody(emailMessage);
			mail.setHtmlBody(emailMessage.replace('\\n', '<br />'));
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		Util.myLog('END Schedule_BA01BusinessPartnerOwnerChanged.verifyInactiveUsers()');
}
/*
=============================================================================================
  FINISH
===============================================================================================
*/
global void finish(Database.BatchableContext BC){
    Util.myLog('START BA01BusinessPartnerOwnerChanged.finish()');
    Util.batchApexFinishReport(BC, 'BA01BusinessPartnerOwnerChanged',batchObjectName, setObjectsTreated, lstErrorLogItem, mapObjectNbSuccessDML, mapObjectNbErrorDML);
    Util.myLog('END BA01BusinessPartnerOwnerChanged.finish()');
 }
 
}