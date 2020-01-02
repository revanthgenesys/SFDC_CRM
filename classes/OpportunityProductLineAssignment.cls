//
// Description: Called from within the OpportunityProductMain trigger before insert and before update
//   This will assign the opportunity product line number for PS Opportunity Products for use with RevPro SO line creations and association of
//   Revenue Events and PS Order Line Items downstream in RevPro (used by the Boomi integration in conjunction with the opportunity product IDs to get these line numbers)
//
// Test Class : OpportunityProductLineAssignment_Test
//
// Revisions:
//   April 2019 - Created by Nik Mills

Public without sharing Class OpportunityProductLineAssignment
{
    public static void AssignProductLineNumbers(List<OpportunityLineItem> newOpptyProds, List<OpportunityLineItem> oldOpptyProds)
    {
        if (Util.Bypass_Trigger_Chk) return;
        
        Id psRecordTypeID;
        //List < RecordType > psRecordType = [SELECT id FROM RecordType WHERE SObjectType = 'Opportunity'
        //    AND DeveloperName = 'Professional_Services'
        //];
        //psRecordTypeID = psRecordType[0].id;
        psRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Professional_Services').getRecordTypeId();
        
        Integer nextLineNumber = null;
        Integer numOpptyProdsInTrigger = newOpptyProds.size();
        List <Opportunity> parentOpps = [SELECT Id, Max_Oppty_Prod_Line_Number__c, RecordTypeId FROM Opportunity WHERE Id IN (SELECT OpportunityId FROM OpportunityLineItem WHERE Id IN :newOpptyProds)];
        Map <Id, Integer> opptyNextNums = new Map <Id, Integer>();
        Map <ID, ID> oppRecTypeIds = new Map<Id, ID>();
        for (Opportunity opps: parentOpps)
        {
            if (opps.Max_Oppty_Prod_Line_Number__c == null)
            {
                opptyNextNums.put(opps.Id, 0);
            }
            else
            {
                opptyNextNums.put(opps.Id, opps.Max_Oppty_Prod_Line_Number__c.intValue());
            }
            oppRecTypeIds.put(opps.Id, opps.RecordTypeId);
        }

        System.Debug('>>>>NikM: DEBUG: Number of Oppty Products in Trigger: ' + numOpptyProdsInTrigger );
                
        for (OpportunityLineItem eachOpptyProd: newOpptyProds) 
        {
            if (oppRecTypeIds.get(eachOpptyProd.OpportunityId) == psRecordTypeID) 
            {
                if (eachOpptyProd.Line_Number__c == null)
                {
                    nextLineNumber = opptyNextNums.get(eachOpptyProd.OpportunityId);
                    nextLineNumber++;    
                    eachOpptyProd.Line_Number__c = nextLineNumber;
                    System.Debug('>>>>NikM: DEBUG: Setting Line Number for Opportunity ' + eachOpptyProd.OpportunityId + ', product ' + eachOpptyProd.Product_Name_Formula__c + ' to ' + nextLineNumber);
                    opptyNextNums.put(eachOpptyProd.OpportunityId, nextLineNumber);
                }
            }
            else
            {
                return;
            }
        }
    }
}