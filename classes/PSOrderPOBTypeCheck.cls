//
// Description: Called from within the Order_Before trigger before insert and before update
//   This will check the Order is a PS Order, and for the presence of a PS Opportunity linked to it, and that the POB Types on the order lines
//   exist on the linked PS opportunity (required for RevPro to function correctly)
//
// Test Class : PSOrderPOBTypeCheck_Test
//
// Revisions:
//   September 2019 - Created by Nik Mills


Public without sharing Class PSOrderPOBTypeCheck
{
    public static Boolean PSPOBCHECK_ORDERBEFORE_TRIGGER_PROCESS = true;

    public static void CheckPSOrderPOBTypeMatchesForRevPro(List<Order__c> newOrders, List<Order__c> oldOrders)
    {
        if (Util.Bypass_Trigger_Chk) return;
        
        boolean hasPOBMismatch;
        String ordRecName;
        String opptyRecName;
        String oppPOBTypesString;
        
        Map<ID, Schema.RecordTypeInfo> rtMapOrders = Schema.SObjectType.Order__c.getRecordTypeInfosByID();
        Map<ID, Schema.RecordTypeInfo> rtMapOpps = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        
        for (Order__c ord: newOrders)
        {
            ordRecName = rtMapOrders.get(ord.RecordTypeId).getName();
            System.Debug('NikM: DEBUG>>>>> Checking for PS Order POB Type Mismatch (Order Name: ' + ord.Name + ', Record Type Name: ' + ordRecName + ', Status: ' + ord.Status__c + ')');

            hasPOBMismatch = false;
            oppPOBTypesString = '';
            
            if (ordRecName == 'PS Orders')
            {
                // Check status of the Order is OK to do the update
                if (ord.Status__c == 'Send to ERP' || ord.Status__c == 'Processed in ERP' || ord.Status__c == 'Completed' || ord.Status__c == 'Cancelled' || 
                    ord.Status__c == 'Credit' || ord.Status__c == 'Rejected')
                {
                        System.Debug('NikM: DEBUG>>>>> Exit PS POB Type check for PS order as exempt due to Status');
                        continue;
                }
                else
                {
                    if (ord.Opportunity__c == null)
                    {
                        System.Debug('NikM: DEBUG>>>>> Exit PS POB check as linked opportunity is null');
                        continue;
                    }
                    List<OpportunityLineItem> OpptyProducts = [SELECT Id, OpportunityId, POB_Type__c, Opportunity.recordTypeID
                                 FROM OpportunityLineItem WHERE OpportunityId =: ord.Opportunity__c];

                    opptyRecName = rtMapOpps.get(OpptyProducts[0].Opportunity.recordTypeID).getName();
                    // Build the distinct list of POB Types now
                    for (OpportunityLineItem OPs : OpptyProducts)
                    {
                        if (oppPOBTypesString.indexOf(OPs.POB_Type__c) == -1)
                        {
                            oppPOBTypesString = oppPOBTypesString + OPs.POB_Type__c + ':';
                        }
                    }

                    System.Debug('NikM: DEBUG>>>>> Opportunity POB Types list is --> ' + oppPOBTypesString);

                    // Check if this is a CAS 1st Year order
                    if (opptyRecName == 'Professional Services')
                    {
                        List<Order_Line_Item__c> orderLineItems = [SELECT Id, POB_Type__c
                                                                    FROM Order_Line_Item__c WHERE Order__c = :ord.Id];
                                                                    
                        for (Order_Line_Item__c oli: OrderLineItems)
                        {
                            if (oli.POB_Type__c == 'Not Applicable' || oli.POB_Type__c == null)
                            {
                                // skip these as Not Applicable will not get sent to RevPro, and null values/blank values will be handled by another validation rule
                            }
                            else
                            {
                                // Check if the Order Line POB type is in the related opportunity POB Type list
                                if (oppPOBTypesString.indexOf(oli.POB_Type__c) != -1)
                                {
                                    System.Debug('NikM: DEBUG>>>>> PS POB matched OK for Order Line '+ oli.Id);
                                }
                                else
                                {
                                    System.Debug('NikM: DEBUG>>>>> PS POB ' + oli.POB_Type__c + ' for Order Line '+ oli.Id + ' not found on related opportunity.');
                                    hasPOBMismatch = true;
                                }
                            }
                        }
                    }

                    // NOTE: if there is a POB Type Mismatch, update the Order checkbox to indicate this now
                    if (hasPOBMismatch)
                    {
                        System.Debug('NikM: DEBUG>>>>> PS POB mismatches found');
                        ord.Order_Lines_with_POB_Mismatch__c = true;
                    }
                    else
                    {
                        // if no mismatches, set the field to false in case it was true before and this is now resovled with a fix to the data or a resubmission, to allow processing.
                        ord.Order_Lines_with_POB_Mismatch__c = false;
                    }
                    PSPOBCHECK_ORDERBEFORE_TRIGGER_PROCESS = false;
                }
            }
        }
    }
}