trigger dsrOrgCancellation on Subscription__c (before update,after update) {
 
    List<Subscription__c> subsc = [SELECT 
                                   Account__c, 
                                   Id,
                                   Account__r.Owner_Id__c, 
                                   Account__r.Owner.Employee_Region__c,
                                   Offering_Type__c,
                                   Org_ID__c, 
                                   Subscription_End_Date__c,
                                   Name,                                   
                                   Account__r.Advisor__r.Email,
                                   Account__r.Advisor__r.Manager.Email,
                                   Opportunity_LookUp__r.Name 
                                   FROM Subscription__c 
                                   WHERE Account__c NOT IN (SELECT Account__c FROM Deal_Support__c WHERE Requested_Action__c = 'Inactivate Line of Business' AND Support_Area__c = 'Sales Ops')
                                   AND Offering_Type__c = 'PureCloud' 
                                   AND Status__c = 'Cancelled' 
                                   AND Offering_Detail__c = 'Free Trial'
                                   AND Org_Id__c != null];
                                   // AND Account__c = 'INPUT TEST ACCOUNT ID FOR PROD'];
    
    Set<Deal_Support__c> NewSetDSRs   = new  Set<Deal_Support__c>();
    List<Deal_Support__c> NewListDSRs = new List<Deal_Support__c>();

    For(Subscription__c subscription: trigger.new){      
        If(subsc.size() == 0){continue;}
        For(Subscription__c s : subsc){
                String Region;
                If(s.Account__r.Owner.Employee_Region__c == 'North America'){Region = 'NA';}
                    ELSE Region = s.Account__r.Owner.Employee_Region__c;
                Deal_Support__c dsrCreation = new Deal_Support__c();
                    dsrCreation.Requester__c = s.Account__r.Owner_Id__c;
                    dsrCreation.ccdb_Id_dsr__c = s.Id;                   
                    dsrCreation.Status__c = 'In Progress';
                    dsrCreation.Assigned_To__c = '005U0000001ucWtIAI'; // Kira Tirsky's ID - because she's the 'final approver'
                    dsrCreation.Description__c = 'System generated free trial cancellation for CCDB/Subscription: ' + s.Name + '. The free trial ended on ' + s.Subscription_End_Date__c.Month() + '/' + s.Subscription_End_Date__c.Day() + '/' + s.Subscription_End_Date__c.Year() ;                    
                    dsrCreation.RecordTypeId = '012U0000000t4xtIAA';
                    dsrCreation.Region__c = Region;                    
                    dsrCreation.Account__c = s.Account__c;                    
                    dsrCreation.Org_ID__c = s.Org_ID__c;
                    dsrCreation.Cancellation_Status__c = 'Pending cancellation – With Product';
                    dsrCreation.CCDB_Cancelled__c = 'Yes';
                    dsrCreation.Genesys_Advisor_Account_Email__c = s.Account__r.Advisor__r.Email;
                    dsrCreation.Genesys_Advisors_manager_email__c = s.Account__r.Advisor__r.Manager.Email;
                    dsrCreation.Owner_Approval__c = 'Final Approval';
                    dsrCreation.Primary_Churn_Reason__c = 'Free Trial';
                    dsrCreation.Offering_Type__c = s.Offering_Type__c;                
                    dsrCreation.Request_Type__c = 'Data Management';
                    dsrCreation.Support_Area__c = 'Sales Ops';
                    dsrCreation.Focus_Area__c = 'Account';
                    dsrCreation.Requested_Action__c = 'Inactivate Line of Business';
                    dsrCreation.Priority__c = 'Medium';
                    dsrCreation.Notification_Date__c = s.Subscription_End_Date__c;
                    dsrCreation.Official_Cancelation_Date__c = s.Subscription_End_Date__c;
                    dsrCreation.Product_Cancellation_Date__c = s.Subscription_End_Date__c;
                    dsrCreation.Trial_Evaluation__c = 'Yes';
                    dsrCreation.Subject__c = 'Trial Cancellation - ' + s.Opportunity_LookUp__r.Name;
                    NewSetDSRs.add(dsrCreation); // Sets, by definition, contain no duplicates.  So, the add() in our loop causes any dupes to overwrite themselves when going into the set. 
                    }
                    }        

        NewListDSRs.addAll(NewSetDSRs);
        try {
                 insert NewListDSRs;
             }   catch (system.Dmlexception e) {
                     system.debug (e);    
                 }

        }