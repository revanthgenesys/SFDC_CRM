/* OpportunityApprovalMain Trigger
Description: 
Primary IT Contact: Nik Mills
Code Coverage: OpportunityApproval_Test
Created: 09-Nov-2018

*/

trigger OpportunityApprovalMain on Opportunity_Approval__c (before insert, before update) 
{
    if (Util.Bypass_Trigger_Chk) return;

    for (Opportunity_Approval__c OppAppr : Trigger.new)
    {
        // Actions on insert/create
        if (Trigger.isinsert && Trigger.isbefore)
        {
            list<Oppty_Approval_Regional_SLAs__c> OpptyApprovalSLAs;
            
            // Need to get the SLA details and set them on the record now, depending on the date that the record was created
            OpptyApprovalSLAs = [SELECT Standard_SLA_Hours__c, Quarter_End_SLA_Hours__c, Quarter_End_SLA_Duration_Days__c FROM Oppty_Approval_Regional_SLAs__c WHERE Region__c =: OppAppr.Opportunity_PS_Region__c AND Type__c =: OppAppr.Approval_Type__c ];
            boolean isInQuarterEnd = false;
            date quarterEnd = [Select EndDate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].EndDate;
            date checkDate = system.today();

            if (!OpptyApprovalSLAs.isEmpty())
            {
                if (OpptyApprovalSLAs[0].Standard_SLA_Hours__c != null)
                {
                    // Determine if we are in the quarter end duration
                    
                    // if the number of days between the dateNow and the quarterEnd is equal or less than the quarter end duration, we are in that period
                    if (checkDate.daysBetween(quarterEnd) <= OpptyApprovalSLAs[0].Quarter_End_SLA_Duration_Days__c)
                    {
                        isInQuarterEnd = true;
                    }
                    
                    if (isInQuarterEnd)
                    {
                    OppAppr.SLA_Applicable_Hours__c = String.valueOf(OpptyApprovalSLAs[0].Quarter_End_SLA_Hours__c);
                    }
                    else
                    {
                    // Not within the quarter end duration period, so use the standard hours value               
                    OppAppr.SLA_Applicable_Hours__c = String.valueOf(OpptyApprovalSLAs[0].Standard_SLA_Hours__c);
                    }
                }
            }
            else
            {
            // If no record was returned, set the SLA period to 48 hours
                OppAppr.SLA_Applicable_Hours__c = '48';
            }
        }

        // actions on update
        if (Trigger.isupdate && Trigger.isbefore)
        {
            Opportunity_Approval__c oldOppAppr = Trigger.oldMap.get(OppAppr.ID);

            // If the approval state has changed and is approved or rejected, clear the sent for review date
            if (oldOppAppr.Finance_Approval_Status__c != OppAppr.Finance_Approval_Status__c)
            {
                // Check if this is now approved, and if the approver was not set, update it now. if the approval date was null, set it to the current date.
                if (OppAppr.Finance_Approval_Status__c == 'Approved')
                {
                    if (OppAppr.Approved_By__c == null)
                    {
                        OppAppr.Approved_By__c = userInfo.GetUserId();
                    }
                    if (OppAppr.Approval_Date__c == null)
                    {
                        OppAppr.Approval_Date__c = system.now();
                    }
                }
                else // status other than approved, so reset the approval date and approver name
                {
                    OppAppr.Approval_Date__c = null;
                    OppAppr.Approved_By__c = null;
                }

                if ((OppAppr.Finance_Approval_Status__c == 'Approved' || OppAppr.Finance_Approval_Status__c == 'Rejected' || OppAppr.Finance_Approval_Status__c == 'Cancelled') && OppAppr.Finance_Review_Request_Sent__c != null)
                {
                    OppAppr.Finance_Review_Request_Sent__c = null;
                }
                
                // If an approval was rejected and there are any associated pending orders (linked to the opportunity), if they are not processed, auto-reject them
                if (OppAppr.Finance_Approval_Status__c == 'Rejected')
                {
                    // Get a list of the orders linked via the PS Opportunity which are open and not processed now
                    String[] orderStates = new String[]{'Order Submitted', 'In Progress', 'Approved', 'Re-Submitted'};
                    list<order__c> psOrdersToCheck;
                    psOrdersToCheck = [SELECT Id, Name, status__c, Reject_Reasons__c, Reject_Details__c FROM order__c WHERE Order__c.Opportunity__c =: OppAppr.Opportunity__c AND order__c.Status__c IN :orderStates];
                    
                    if (!psOrdersToCheck.IsEmpty()) 
                    {
                        System.Debug('NikM: Orders found for automated rejection');
                        for(Order__c objOrder : psOrdersToCheck)
                        {
                            System.Debug('NikM: Found Order ' + objOrder.Name + ' to change to rejected');
                            objOrder.Status__c = 'Rejected';
                            objOrder.Reject_Reasons__c = 'Other';
                            objOrder.Reject_Details__c = 'Rejected due to PS Opportunity Approval rejection. Please review related opportunity and update before resubmitting';
                        }
                        update psOrdersToCheck;
                    }
                }
            }
        }

          // Need to update the approval status on the linked opportunity
        if (OppAppr.Opportunity__c != null)
        {
            Opportunity Opp = [SELECT Id, Finance_Oppty_Approval_Status__c, RecordTypeId FROM Opportunity WHERE Id =: OppAppr.Opportunity__c];
            
            // Only do the update currently if the Opportunity is a Professional Services record type.
            Opp.Finance_Oppty_Approval_Status__c = OppAppr.Finance_Approval_Status__c;
            // Dont need to call other triggers recursively here, so bypass for now
            Util.Bypass_Trigger_Chk = true;
            Update Opp;
            Util.Bypass_Trigger_Chk = false;
        }
    }
}