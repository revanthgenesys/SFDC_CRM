//
// Description: Called from within the Order_Before trigger before insert and before update
//   This will check the Order is a PS CAS 1st year item, and for the presence of a PS Opportunity linked to the CAS Opportunity
//   If present, the code will update some of the PS CAS Order fields so that it can be processed correctly through for RevPro
//   and associated to the master PS Opportunity / Revenue Contract
//
// Test Class : ProfessionalServicesCASOrderHandler_Test
//
// Revisions:
//   April 2019 - Created by Nik Mills
//   September 2019 - Updated to include handling of PS Expert Apps Subscription items in the same way as CAS is processed


Public without sharing Class ProfessionalServicesCASOrderHandler
{
    public static Boolean PSCAS_ORDERBEFORE_TRIGGER_PROCESS = true;

    public static void CheckAndUpdatePSCASOrderForRevPro(List<Order__c> newOrders, List<Order__c> oldOrders)
    {
        if (Util.Bypass_Trigger_Chk) return;
        
        boolean isPSCASFirstYear;
        boolean isOrderLineItem1stYearCAS;
        boolean isPSEASubscription;
        boolean isOrderLinePSEASubscription;
        String linkedPSOpptyID;
        String linkedPSOpptyNumber;
        String linkedPSOpptyPSLoB;
        String ordRecName;
        String opptyRecName;
        
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Order__c.getRecordTypeInfosByID();
        
        for (Order__c ord: newOrders)
        {
            ordRecName = rtMap.get(ord.RecordTypeId).getName();
            System.Debug('NikM: DEBUG>>>>> Checking for PS CAS or EA Subscription Order (Order Name: ' + ord.Name + ', Record Type Name: ' + ordRecName + ', Status: ' + ord.Status__c + ')');

            isPSCASFirstYear = false;
            isOrderLineItem1stYearCAS = false;
            isPSEASubscription = false;
            isOrderLinePSEASubscription = false;
            linkedPSOpptyID = '';
            linkedPSOpptyNumber = '';
            linkedPSOpptyPSLoB = '';
            
            if (ordRecName == 'General Orders')
            {
                // Check status of the Order is OK to do the update
                if (ord.Status__c == 'Send to ERP' || ord.Status__c == 'Processed in ERP' || ord.Status__c == 'Completed' || ord.Status__c == 'Cancelled' || 
                    ord.Status__c == 'Credit' || ord.Status__c == 'Rejected')
                {
                        System.Debug('NikM: DEBUG>>>>> Exit CAS or EA Subscription Order check for General order as exempt due to Status');
                        return;
                }
                else
                {
                    if (ord.Opportunity__c == null)
                    {
                        System.Debug('NikM: DEBUG>>>>> Exit CAS or EA Subscription check for General order as linked opportunity is null');
                        return;
                    }
                    List<Opportunity> linkedOpp = [SELECT Id, RecordType.Name, Master_Opportunity__c, Master_Opportunity__r.OpportunityNumber__c, Master_Opportunity__r.PS_Line_Of_Business__c
                                 FROM Opportunity WHERE Id =: ord.Opportunity__c];
                    opptyRecName = linkedOpp[0].RecordType.Name;
                    linkedPSOpptyID = linkedOpp[0].Master_Opportunity__c;
                    
                    System.Debug('>>>>>>Debug: NikM: Handling checks for PS CAS 1st Year or EA Subscription Orders. Related Opportunity Master Opp link is: '+ linkedPSOpptyID);

                    if (linkedPSOpptyID != null)
                    {
                        System.Debug('>>>>>>Debug: NikM: Setting Linked PS Opportunity details for 1st Year CAS item');

                        linkedPSOpptyNumber = linkedOpp[0].Master_Opportunity__r.OpportunityNumber__c;
                        linkedPSOpptyPSLoB = linkedOpp[0].Master_Opportunity__r.PS_Line_of_Business__c;
                    }

                    System.Debug('NikM: DEBUG>>>>> Associated Opportunity Record Name : ' + opptyRecName);
                    // Check if this is a CAS 1st Year or EA Subscription order
                    if (opptyRecName == 'Genesys Renewal')
                    {
                        List<Order_Line_Item__c> orderLineItems = [SELECT Id, Order__c, Support_Type_Formula__c, Description__c, POB_Type__c, Material_Description__c, isPSContractOrSubscriptionProduct__c
                                                                    FROM Order_Line_Item__c WHERE Order__c = :ord.Id];
                                                                    
                        for (Order_Line_Item__c oli: OrderLineItems)
                        {
                            if (oli.Support_Type_Formula__c == 'New' && (oli.POB_Type__c == 'PS - CAS' || (oli.Material_Description__c.Contains('Custom App Support') || 
                                                                                                           oli.Material_Description__c.Contains('Subscription Service for PS Expert Apps' ) ) ) )
                            {
                                isOrderLineItem1stYearCAS = true;
                            }
                            if (oli.Support_Type_Formula__c == 'New' && (oli.POB_Type__c == 'PS - Fixed Fee on Date' && oli.isPSContractOrSubscriptionProduct__c))
                            {
                                isOrderLinePSEASubscription = true;
                            }
                        }
                        
                        if (!isOrderLineItem1stYearCAS && !isOrderLinePSEASubscription)
                        {
                            System.Debug('NikM: DEBUG>>>>> Exit CAS or EA Subscription check for General order as not 1st Year CAS (POB != PS - CAS or No CAS product) or EA Subscription (PS Contract == false && POB Type == PS - Fixed Fee on Date');
                            return;
                        }
                    }

                    // If this is a first year PS CAS order, set some of the required fields 
                    // NOTE: if there is no linked master PS opportunity, the PS line of business and master order would be set to blanks)
                    if (isOrderLineItem1stYearCAS)
                    {
                        System.Debug('>>>>>>Debug: NikM: Updating CAS Order details for PS 1st Year CAS processing');
                        ord.License_FYM_detail__c = 'PS Orders';
                        ord.PS_CAS_Order__c = true;
                        ord.PS_CAS_Related_Oppty_Line_of_Business__c = linkedPSOpptyPSLoB;

                        // Check if the Master Order number needs to be updated
                        if ((ord.Master_Order_Number__c == '' || ord.Master_Order_Number__c == null) && linkedPSOpptyID != '') // Master Order Ref is blank so set to the linked PS Oppty value
                        {
                            ord.Master_Order_Number__c= linkedPSOpptyNumber;
                        }
                        
                        if (ord.Master_Order_Number__c == ord.Name && linkedPSOpptyID != '') // Master Order Ref is same as Order, so override with linked PS Oppty value
                        {
                            ord.Master_Order_Number__c = linkedPSOpptyNumber;
                        }
                        PSCAS_ORDERBEFORE_TRIGGER_PROCESS = false;
                    }
                    if (isOrderLinePSEASubscription)
                    {
                        System.Debug('>>>>>>Debug: NikM: Updating EA Subscription Order details for  processing');
                        ord.License_FYM_detail__c = 'PS Orders';
                        ord.PS_Subscription_GC_Order__c = true;
                        ord.PS_CAS_Related_Oppty_Line_of_Business__c = linkedPSOpptyPSLoB;

                        // Check if the Master Order number needs to be updated
                        if ((ord.Master_Order_Number__c == '' || ord.Master_Order_Number__c == null) && linkedPSOpptyID != '') // Master Order Ref is blank so set to the linked PS Oppty value
                        {
                            ord.Master_Order_Number__c= linkedPSOpptyNumber;
                        }
                        
                        if (ord.Master_Order_Number__c == ord.Name && linkedPSOpptyID != '') // Master Order Ref is same as Order, so override with linked PS Oppty value
                        {
                            ord.Master_Order_Number__c = linkedPSOpptyNumber;
                        }
                        PSCAS_ORDERBEFORE_TRIGGER_PROCESS = false;
                    }
                }
            }
        }
    }
}