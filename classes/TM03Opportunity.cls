public class TM03Opportunity {
/*
- Author : BALINK (Kerensen Consulting Technology Center)
- Description : 
	Component : Trigger TM03 "Update Opportunity Territory when Owner is changed" 
				(Opportunity After Insert / After Update / After Delete)
	Object (s):  Opportunity / OpportunityCompetitor 
	What : Copy Competitors (Multi-picklist) to Standard Competitors Related List
- Delivery Date : 15/05/2010
- Governor informations :
	Single : 				SOQL queries :  / 20
							Query rows :  / 1000
							DML Statments :  / 20
							DML rows : 	 / 100
	With others triggers  :
							SOQL queries :  / 20
							Query rows :   / 1000
							DML Statments :  / 20
							DML rows : 	 / 100
*/

public static void copyCompetitors(Opportunity[] Opportunities)
{
	System.Debug('## >>> Starting TM03Opportunity.copyCompetitors<<<');
	List<OpportunityCompetitor> oppCompToInsert = new List<OpportunityCompetitor>();
	List<OpportunityCompetitor> oppCompToDel = new List<OpportunityCompetitor>();
	Map <id,Map<string,OpportunityCompetitor>> allOpportunityCompetitor;
	
	Set<Id> OpportunityIds = new Set<Id>();
	for(Integer i =0; i< Opportunities.size();i++) 
	{
     	OpportunityIds.add(Opportunities[i].id);
	}
	// set all OpportunityCompetitor in a map by Opportunity id key
	allOpportunityCompetitor = getAllOpportunityCompetitor(OpportunityIds);
	
	for(Integer i =0; i< Opportunities.size();i++) 
	{
		// compare each Opportunity and compare it's OpportunityCompetitors and it's Competitor__c multipicklist field 
		checkOpportunityCompetitorPickList(Opportunities[i],oppCompToInsert,oppCompToDel,allOpportunityCompetitor.get(Opportunities[i].id));
	}

	insert oppCompToInsert; 
	delete oppCompToDel;
	System.Debug('## >>> Ending TM03Opportunity.copyCompetitors <<<');
}

public static Map<id,Map<string,OpportunityCompetitor>> getAllOpportunityCompetitor(Set<Id> OpportunityIds)
{
	 Map <id,Map<string,OpportunityCompetitor>> OpportunityCompetitorsMap= new Map <id,Map<string,OpportunityCompetitor>>();
	 // get all OpportunityCompetitor
	 List<OpportunityCompetitor> OpportunityCompetitors = [Select o.Weaknesses,o.SystemModstamp,o.Strengths,o.OpportunityId,o.Id,o.CompetitorName 
	 													   From OpportunityCompetitor o
	 													   where o.OpportunityId in : OpportunityIds];
	 // set into map by Opportunity id key													   
	 for (OpportunityCompetitor oc: OpportunityCompetitors){
	 	if (OpportunityCompetitorsMap.containsKey(oc.OpportunityId)){
	 		OpportunityCompetitorsMap.get(oc.OpportunityId).put(oc.CompetitorName,oc);
	 	}
	 	else{
	 		OpportunityCompetitorsMap.put(oc.OpportunityId,new Map<string,OpportunityCompetitor>());
	 		OpportunityCompetitorsMap.get(oc.OpportunityId).put(oc.CompetitorName,oc);
	 	}
	 }	 
	 return OpportunityCompetitorsMap;
}

public static void checkOpportunityCompetitorPickList(Opportunity opp, List<OpportunityCompetitor> oppCompToInsert,List<OpportunityCompetitor> oppCompToDel,Map<string,OpportunityCompetitor> OpportunityCompetitors)
{
	if (opp.Competitor__c != null && opp.Competitor__c != ''){
		// get Opportunity Competitor__c field values 
		List<string> oppCompetitorNames = opp.Competitor__c.split(';',-1);
		for (string sCompetitorName : oppCompetitorNames){
			if (OpportunityCompetitors != null && OpportunityCompetitors.containsKey(sCompetitorName)){
				OpportunityCompetitors.remove(sCompetitorName);
			}
			else {
				oppCompToInsert.add(new OpportunityCompetitor(OpportunityId=opp.id,CompetitorName=sCompetitorName));
			}
		}
	}
	// remove/delete all OpportunityCompetitors that are not in the Competitor__c field  
	if (OpportunityCompetitors != null){
		for (OpportunityCompetitor oc : OpportunityCompetitors.values()){
			oppCompToDel.add(oc);
		}
	}
}

/*****************************************************************/
/**************** TEST METHODS ***********************************/
/*****************************************************************/	
static testmethod void test()
{
	Opportunity opp1 = new Opportunity(Competitor__c = 'a;b;c',Name='Test',StageName='Test',CloseDate=Date.today());
	insert opp1;
	
	opp1.Competitor__c = 'a;b;d';
	update opp1;

}

}