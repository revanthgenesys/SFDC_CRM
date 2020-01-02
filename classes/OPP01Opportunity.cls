public without sharing class OPP01Opportunity {
	
//Number of SOQL queries: 
//Number of query rows: 
//Number of SOSL queries: 
//Number of DML statements: 
	
public static void modifyOpportunityOwnerOnOpportunity(List <Opportunity> lstOpportunity) 
  {
	Util.MyLog('Start OPP01Opportunity.modifyOpportunityOwnerOnOpportunity');

	for (Opportunity oppo : lstOpportunity) 
  	{
		//oppo.OwnerId = oppo.FirstOwnerId__c;
		//oppo.OwnerId = oppo.X1stOwnerId__c;
		oppo.OwnerId = '005U0000000dnCY';
		Util.MyLog('oppo.OwnerId : ' +oppo.OwnerId);

  	}
   Util.myLog('End OPP01Opportunity.modifyOpportunityOwnerOnOpportunity');
  }	
}