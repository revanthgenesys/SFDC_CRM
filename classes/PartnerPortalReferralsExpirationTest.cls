@isTest(seeAllData=true)
private class PartnerPortalReferralsExpirationTest {
    
    static testMethod void testPartnerPortalLeadReferralExpiration() {
        setupData();
        Test.startTest();
        PartnerPortalLeadReferralExpiration batchClass =  new PartnerPortalLeadReferralExpiration();       
        ID batchprocessid = Database.executeBatch(batchClass);
        Test.stopTest();
    }
    
    static testMethod void testPartnerPortalOpportunityExpiration() {
        setupData();
        setupDealRegData();
        Test.startTest();
        PartnerPortalOpportunityExpiration batchClass =  new PartnerPortalOpportunityExpiration();       
        ID batchprocessid = Database.executeBatch(batchClass);
        Test.stopTest();
    }
    
    static testMethod void testPartnerPortalLeadRefExpirationScheduler(){
        setupData();
        String cronExp = '0 0 0 3 9 ? 2022';
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('testScheduler', cronExp, new PartnerPortalLeadRefExpirationScheduler());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
    
    static testMethod void testPartnerPortalOppExpirationScheduler(){
        setupData();
        setupDealRegData();
        String cronExp = '0 0 0 3 9 ? 2022';
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('testScheduler', cronExp, new PartnerPortalOppExpirationScheduler());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
    
    static testMethod void testPartnerPortalDealRegistrationTriggers(){
    	User currUser = [Select Id, Name, Bypass_Triggers__c from User where ID=:userinfo.getuserid()];
        currUser.Bypass_Triggers__c = true; 
        
        System.runAs(currUser){
            RecordType accountRT = [SELECT id from RecordType where developername = 'EMGBusinessPartnerRecordType' limit 1];

            Account a1 = new Account (Name = 'Holding Account', RecordTypeId = accountRT.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR', 
                                      Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
            insert a1;

            RecordType opportunityRT = [SELECT Id from RecordType where Name = 'GEN - Opportunity Record Type' limit 1];
            
            Opportunity testOpportunity1 = new Opportunity(Name = 'Test Opp 1', AccountId = a1.Id);
            testOpportunity1.CloseDate = Date.today().addMonths(1);
            testOpportunity1.StageName = '1.Understand Needs';
            testOpportunity1.BusinessPartner__c = a1.id;
            testOpportunity1.Primary_Line_of_Business__c = 'Cloud';
            testOpportunity1.Lines_of_Businesses__c = 'PureCloud'; 
            testOpportunity1.Win_Loss_Status__c = 'Loss';
            testOpportunity1.ForecastStatus__c = '0.Booked';
            testOpportunity1.RecordTypeId = opportunityRT.Id;
            insert testOpportunity1;

            Opportunity testOpportunity2 = new Opportunity(Name = 'Test Opp 2', AccountId = a1.Id);
            testOpportunity2.CloseDate = Date.today().addMonths(1);
            testOpportunity2.StageName = '1.Understand Needs';
            testOpportunity2.BusinessPartner__c = a1.id;
            testOpportunity2.Primary_Line_of_Business__c = 'Cloud';
            testOpportunity2.Lines_of_Businesses__c = 'PureCloud'; 
            testOpportunity2.Win_Loss_Status__c = 'Loss';
            testOpportunity2.ForecastStatus__c = '0.Booked';
            testOpportunity2.RecordTypeId = opportunityRT.Id;
            insert testOpportunity2;

            partner_portal_prospect__c ppp1 = new partner_portal_prospect__c();
            ppp1.Name = 'TestRec';
            ppp1.Status__c = 'Approved';
            ppp1.End_User_Account__c = a1.Id;
            ppp1.Account__c = a1.Id;
            ppp1.What_is_the_Expected_Close_Date__c = Date.Today() + 30;
            ppp1.Opportunity_Channel_Manager__c = currUser.Id;
            ppp1.End_Date__c=Date.Today().addDays(30);
            insert ppp1;
            
            partner_portal_prospect__c ppp2 = new partner_portal_prospect__c();
            ppp2.Name = 'TestRec';
            ppp2.Status__c = 'Approved';
            ppp2.End_User_Account__c = a1.Id;
            ppp2.Account__c = a1.Id;
            ppp2.What_is_the_Expected_Close_Date__c = Date.Today() + 30;
            ppp2.Opportunity_Channel_Manager__c = currUser.Id;
            ppp2.End_Date__c=Date.Today().addDays(30);
            insert ppp2;
            
            ppp1.Opportunity__c = testOpportunity1.Id;
            update ppp1;
            testOpportunity1.Partner_Opportunity_Registration__c = ppp1.id;
            update testOpportunity1;

			ppp2.Opportunity__c = testOpportunity2.Id;
            update ppp2;
            testOpportunity2.Partner_Opportunity_Registration__c = ppp2.id;
            update testOpportunity2;

            try{
                ppp1.Opportunity__c = testOpportunity2.Id;
                update ppp1;
            } catch(Exception e){
	            ppp1.Opportunity__c = testOpportunity1.Id;
            }
            
            try{
                testOpportunity1.Partner_Opportunity_Registration__c = ppp2.id;
                update testOpportunity1;
            } catch(Exception e){
	            testOpportunity1.Partner_Opportunity_Registration__c = ppp1.id;
            }

            ppp1.Status__c = 'Rejected';
            update ppp1;
            ppp1.Status__c = 'Expired';
			update ppp1;
        }
        currUser.Bypass_Triggers__c = false;
    }
    
    static void setupData(){
        PartnerPortalReferralsExpirationConfig__c configCS = PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig');
        
        Integer noOfDaysToNotifyBefore = 1;
        if(configCS != NULL){
            noOfDaysToNotifyBefore = (Integer)configCS.No_of_Days_to_Notify_Before_Expire__c;        
        } else {
            configCS = new PartnerPortalReferralsExpirationConfig__c(Name='ReferralsExpirationConfig', 
                                                                     No_of_Days_To_Expire__c=2, 
                                                                     No_of_Days_to_Notify_Before_Expire__c = 1);
            insert configCS;
        }
        
        Date cutoffDate = Date.Today().addDays(noOfDaysToNotifyBefore);
        List<partner_portal_prospect__c> partnerOpps = [SELECT id, Name, End_Date__c, Status__c, Account__c FROM partner_portal_prospect__c WHERE Account__c != NULL AND Opportunity__c = NULL LIMIT 5];
        for(partner_portal_prospect__c ppp: partnerOpps){
            ppp.End_Date__c = cutoffDate;
            ppp.Status__c = 'Awaiting Approval';
        }
        Database.update(partnerOpps, false);

        List<Lead_Referral_Registration__c > partnerLeads = [SELECT id, Name, End_Date__c, Status__c, Account__c FROM Lead_Referral_Registration__c  WHERE Account__c != NULL AND Opportunity__c = NULL LIMIT 5];
        for(Lead_Referral_Registration__c lrr: partnerLeads){
            lrr.End_Date__c = cutoffDate;
            lrr.Status__c = 'Request Pending';
        }
        Database.update(partnerLeads, false);
        
    }
    
    static void setupDealRegData(){
    
        User currUser = [Select Id, Name, Bypass_Triggers__c from User where ID=:userinfo.getuserid()];
        currUser.Bypass_Triggers__c = true; 
        
        System.runAs(currUser){
            recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
            
            Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
            insert a1;

            List<string>list_Rec = new List<string>();
            list_Rec.add('GEN - Opportunity Record Type');
            Map<id,RecordType>map_rec = new Map<id,RecordType>([select id,name from RecordType where name IN : list_Rec]);

            Opportunity objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = a1.Id);
            objTestOppty.CloseDate = Date.today().addMonths(1);
            objTestOppty.StageName = '1.Understand Needs';
            objTestOppty.BusinessPartner__c = a1.id;
            objTestOppty.Primary_Line_of_Business__c = 'Cloud';
            objTestOppty.Lines_of_Businesses__c = 'PureCloud'; 
            objTestOppty.Win_Loss_Status__c = 'Loss';
            objTestOppty.ForecastStatus__c = '0.Booked';
            
            for(string s: map_rec.keySet())
            {
              if(map_rec.get(s).name == 'GEN - Opportunity Record Type')
               objTestOppty.RecordTypeId = s;
            }
            insert objTestOppty;

            partner_portal_prospect__c ppp = new partner_portal_prospect__c();
            ppp.Name = 'TestRec';
            ppp.Status__c = 'Approved';
            ppp.End_User_Account__c = a1.Id;
            ppp.Account__c = a1.Id;
            ppp.What_is_the_Expected_Close_Date__c = Date.Today() + 30;
            ppp.Opportunity_Channel_Manager__c = currUser.Id;
            ppp.End_Date__c=Date.Today().addDays(30);
            insert ppp;
        }
        
    }
}