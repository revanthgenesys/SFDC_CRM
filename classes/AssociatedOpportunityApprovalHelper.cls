//Nik Mills - 10-Nov-2018
//For use in creating or updating an OpportunityApproval record associated to an Opportunity
//Primary IT Contact: Nik Mills
//Code Coverage: AssociatedOpportunityApprovalHelper_Test

public class AssociatedOpportunityApprovalHelper {

    @InvocableMethod(label='Set Opportunity Approval' description='Creates or Updates an Opportunity Approval associated to the main Opportunity.')        
    public static void SetOpportunityApproval(list<ID> oppIDs)
    {
        System.Debug('NikM Debug:: Set Opportunity Approval invocable called');
        list<Opportunity> opps = [SELECT Id, Name, RecordTypeId, PS_Region__c, PSA_Closed_OM_Oppty_Submit_Status__c FROM Opportunity WHERE Id IN :oppIDs];
        list<Opportunity_Approval__c> oppApprs = [SELECT Id, Name, OwnerId FROM Opportunity_Approval__c WHERE Opportunity__c IN :oppIDs];
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: 'Professional_Services'];
        List<Group> Queues;
        List<Group> DefaultQueues;
  
        for (Opportunity Opp : opps)
        {     
            System.Debug('NikM Debug:: Opportunity ' + Opp.Name + ' with ID ' + Opp.Id + ' passed to AssocOppApprHelper - ');
            // Check if this is a PS Opportunity and if so, then proceed
            if (Opp.RecordTypeId == rtypes[0].Id)
            {            
                list<Oppty_Approval_Regional_SLAs__c> OpptyApprovalSLAs;
                // Need to get the SLA details and set them on the record now, depending on the date that the record was created
                OpptyApprovalSLAs = [SELECT Opportunity_Approval_Queue_Association__c FROM Oppty_Approval_Regional_SLAs__c WHERE Region__c =: Opp.PS_Region__c AND Type__c = 'Professional Services' ];
    
                // If there is no associated opportunity approval record and the PSA Close Submit status is submitted, then we need to create a new record
                if (oppApprs.isEmpty())
                {
                    if (Opp.PSA_Closed_OM_Oppty_Submit_Status__c == 'Submitted')
                    {
                        Opportunity_Approval__c newOpptyApproval = new Opportunity_Approval__c();
                        newOpptyApproval.Approval_Type__c = 'Professional Services';
                        newOpptyApproval.Finance_Approval_Status__c = 'Submitted';
                        newOpptyApproval.Opportunity__c = Opp.Id;
                        newOpptyApproval.Finance_Review_Request_Sent__c = system.now();
                        
                        Queues = [SELECT Id FROM group WHERE Type = 'Queue' AND NAME =: OpptyApprovalSLAs[0].Opportunity_Approval_Queue_Association__c];
                        DefaultQueues = [SELECT Id FROM group WHERE Type = 'Queue' AND NAME ='WW Order Management Oppty Approvals'];
                        
                        if (!Queues.isEmpty())
                        {
                            If (Queues[0].Id != null)
                            {
                                newOpptyApproval.OwnerId = Queues[0].Id;
                            }
                            else
                            {
                                newOpptyApproval.OwnerId = DefaultQueues[0].Id;
                            }
                        }
                        else
                        {
                            // Unable to get the queue name, so assign as default
                            newOpptyApproval.OwnerId = DefaultQueues[0].Id;
                        }
                        
                        insert newOpptyApproval;
                    }
                }
                else
                {
                    // There is an existing record, so check if the PSA Closed Submit Status is resubmitted, in which case we need to update the associated Opportunity Approval
                    for (Opportunity_Approval__c OA : OppApprs)
                    {
                        if (Opp.PSA_Closed_OM_Oppty_Submit_Status__c == 'Resubmitted')
                        {
                            OA.Finance_Approval_Status__c = 'Resubmitted';
                            OA.Finance_Review_Request_Sent__c = system.now();
                            update OA;
                        }
                        
                        if (Opp.PSA_Closed_OM_Oppty_Submit_Status__c == 'Cancelled')
                        {
                            // Opportunity approval was cancelled, so update to mark the object as cancelled
                            OA.Finance_Approval_Status__c = 'Cancelled';
                            update OA;
                        }
                    }
                }
            }
  
        }
    }    
}