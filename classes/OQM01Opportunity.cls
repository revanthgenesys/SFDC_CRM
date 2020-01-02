public with sharing class OQM01Opportunity {

/*
- Author : Olivier Spehner (Kerensen Consulting)
- Description : 
    Component : Trigger OQM01 "OQM date stage fields are updated when Opportunity stage field is updated" 
                (Opportunity After Update / Opportunity Before Insert)
    Object (s):  Opportunity / OQM_Form__c
    What : 
        if Opportunity[Old].StageName <> Opportunity[New].StageName
        && Opportunity[New].StageName IN (5-Short List
                                          6-Price Negotiation
                                          7-ALU Selected
                                          8-Closed Won
                                          8-Closed Lost
                                          9-Postponed
                                          10-Closed Cancelled)
- Delivery Date : 29/04/2010
- Governor informations :
    Single :                SOQL queries : 2 / 20
                            Query rows : 0 / 1000
                            DML Statments : 1 / 20
                            DML rows :   / 100
    With others triggers  :
                            SOQL queries :  / 20
                            Query rows :   / 1000
                            DML Statments :  / 20
                            DML rows :   / 100
*/

public static void SetOQMStageDate (Map<Id,String> MapID) {
    System.Debug('### OQM01Opportunity.SetOQMStageDate Start'); 
    
    // Set of ESD Opportunity RecordType Id to sort
	Set<Id> lstESDRecordTypeId = new Set<Id>();
	lstESDRecordTypeId = Util.ESDOpptyRecordTypeId();
	
    List<Opportunity> ListOpptyToUpdate = new List<Opportunity>();
    List<Opportunity> ListOpportunity = [SELECT id
                                            FROM Opportunity
                                            WHERE id IN : MapID.keySet()
                                            AND RecordtypeId IN : lstESDRecordTypeId];
    
    For (Opportunity Opp : ListOpportunity){
    	// OPP_STAGE5 = 5-Short List
        if (MapID.get(Opp.id) == Config.OPP_STAGE5)
        {
            Opp.Short_List_Date__c = date.today();
            ListOpptyToUpdate.add(Opp);
        }
        	// OPP_STAGE6 = 6-Price Negotiation
            else if (MapID.get(Opp.id) == Config.OPP_STAGE6)
            {
                Opp.Price_Negociation_Date__c = date.today();
                ListOpptyToUpdate.add(Opp);
            }
            	// OPP_STAGE7 = 7-ALU Selected
                else if (MapID.get(Opp.id) == Config.OPP_STAGE7)
                {
                    Opp.ALU_Selected_Date__c = date.today();
                    ListOpptyToUpdate.add(Opp);
                }
                	// OPP_STAGE82 = 8-Closed Won
                    else if (MapID.get(Opp.id) == Config.OPP_STAGE82)
                    {
                        Opp.Closed_Won_Date__c = date.today();
                        ListOpptyToUpdate.add(Opp);
                    }
                    	// OPP_STAGE81 = 8-Closed Lost
                        else if (MapID.get(Opp.id) == Config.OPP_STAGE81)
                        {
                            Opp.Closed_Lost_Date__c = date.today();
                            ListOpptyToUpdate.add(Opp);
                        }
                        	// OPP_STAGE9 = 9-Closed Cancelled
                            else if (MapID.get(Opp.id) == Config.OPP_STAGE9)
                            {
                                //Opp.Postponed_Date__c = date.today();
                                Opp.Closed_Cancelled_Date__c = date.today();
                                ListOpptyToUpdate.add(Opp);
                            }
                            /*
                            	// OPP_STAGE10 = 10-Closed Cancelled
                                else if (MapID.get(Opp.id) == Config.OPP_STAGE10)
                                {
                                    Opp.Closed_Cancelled_Date__c = date.today();
                                    ListOpptyToUpdate.add(Opp);
                                }
                        */
    }
    if(!ListOpptyToUpdate.isEmpty())
        update ListOpptyToUpdate;                                     
    System.Debug('### OQM01Opportunity.SetOQMStageDate End');   
} 

}