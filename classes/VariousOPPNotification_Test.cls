@isTest(SeeAllData = true)
public class VariousOPPNotification_Test {
    static testmethod void test1()
    {
        try
        {
            //Util.Bypass_Trigger_Chk = true;
            
            Test.StartTest();
            List<User> objU = testUtil.createUsers(1, false);
            objU[0].Region__c = 'EMEA';
            insert objU;
            
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'Brazil' LIMIT 1].Id;
            insert objTestAccount;
            
            Opportunity objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
            objTestOppty.CloseDate = Date.today().addMonths(1);
            objTestOppty.StageName = '1.Recognize Needs';     
            objTestOppty.CurrencyIsoCode = 'BRL';
            objTestOppty.Previous_Maintenance_Rate__c = 0;
            objTestOppty.BusinessPartner__c = objTestAccount.Id;
            objTestOppty.Gene_Care_Specialist__c = UserInfo.getUserId();
            objTestOppty.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' 
                                        AND DeveloperName = 'Genesys_Renewal'].Id;
            objTestOppty.RFP_Proposal__c = 'Short Listed';  
            objTestOppty.ownerid = objU[0].id;                          
            insert objTestOppty;
            
            
            
            RFP_Support_Request__c objRFP = new RFP_Support_Request__c();
            objRFP.Proposal_Status__c = 'Request For Support';
            objRFP.Opportunity__c = objTestOppty.id;
            objRFP.Override_Proposal_Outcome__c = 'Short Listed';
             
            insert objRFP;
            
            objTestOppty.StageName = '6.Closed';
            objTestOppty.Win_Loss_Status__c = 'Merged/Dup Opp';
            update objTestOppty;
            
            //VariousOPPNotification.RFPNotifications();
            
           
            Test.stopTest();
            
        }
        catch(CalloutException ex)
        {}
    }
    static testmethod void test2()
    {
        try
        {
            //Util.Bypass_Trigger_Chk = true;
            
            Test.StartTest();
            List<User> objU = testUtil.createUsers(1, false);
            objU[0].Region__c = 'EMEA';
            insert objU;
            
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'Brazil' LIMIT 1].Id;
            insert objTestAccount;
            
            Opportunity objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
            objTestOppty.CloseDate = Date.today().addMonths(1);
            objTestOppty.StageName = '1.Recognize Needs';     
            objTestOppty.CurrencyIsoCode = 'BRL';
            objTestOppty.Previous_Maintenance_Rate__c = 0;
            objTestOppty.BusinessPartner__c = objTestAccount.Id;
            objTestOppty.Gene_Care_Specialist__c = UserInfo.getUserId();
            objTestOppty.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' 
                                        AND DeveloperName = 'Genesys_Renewal'].Id;
            objTestOppty.RFP_Proposal__c = 'Short Listed';  
            objTestOppty.ownerid = objU[0].id;                          
            insert objTestOppty;
            
            RFP_Support_Request__c objRFP = new RFP_Support_Request__c();
            objRFP.Proposal_Status__c = 'Request For Support';
            objRFP.Opportunity__c = objTestOppty.id;
            objRFP.Override_Proposal_Outcome__c = 'Short Listed';
            insert objRFP;

            DSR_SCEngagement__c objSCE = new DSR_SCEngagement__c();
            objSCE.Account_ID__c = objTestAccount.id;
            objSCE.Opportunity_ID__c = objTestOppty.id;
            objSCE.SC_Engagement_Status__c = 'Open and Not Assigned';
            objSCE.Design_Start_Date__c = Date.Today().addDays(-10);
            objSCE.Design_End_Date__c = Date.Today().addDays(10);
            insert objSCE;
            
            objTestOppty.StageName = '4.Build Consensus';
            objTestOppty.Win_Loss_Status__c = 'Merged/Dup Opp';
            update objTestOppty;
            
           
            Test.stopTest();
            
        }
        catch(CalloutException ex)
        {}
    }
    
    
    static testmethod void test3()
    {
        try
        {
            //Util.Bypass_Trigger_Chk = true;
            
            Test.StartTest();
            List<User> objU = testUtil.createUsers(1, false);
            objU[0].Region__c = 'AMERICAS';
            insert objU;
            
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'Brazil' LIMIT 1].Id;
            insert objTestAccount;
            
            Opportunity objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
            objTestOppty.CloseDate = Date.today();
            objTestOppty.StageName = '1.Recognize Needs';     
            objTestOppty.CurrencyIsoCode = 'BRL';
            objTestOppty.Previous_Maintenance_Rate__c = 0;
            objTestOppty.BusinessPartner__c = objTestAccount.Id;
            objTestOppty.Gene_Care_Specialist__c = UserInfo.getUserId();
            objTestOppty.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' 
                                        AND DeveloperName = 'Genesys_Renewal'].Id;
            objTestOppty.RFP_Proposal__c = 'Short Listed';  
            objTestOppty.ownerid = objU[0].id;
            
            
            objTestOppty.Type  = 'New logo';
            objTestOppty.Direct_Indirect_Sale__c  = 'Direct';
            
            
            insert objTestOppty;
            
            RFP_Support_Request__c objRFP = new RFP_Support_Request__c();
            objRFP.Proposal_Status__c = 'Request For Support';
            objRFP.Opportunity__c = objTestOppty.id;
            objRFP.Override_Proposal_Outcome__c = 'Short Listed';
            insert objRFP;

            DSR_SCEngagement__c objSCE = new DSR_SCEngagement__c();
            objSCE.Account_ID__c = objTestAccount.id;
            objSCE.Opportunity_ID__c = objTestOppty.id;
            objSCE.SC_Engagement_Status__c = 'Open and Not Assigned';
            objSCE.Design_Start_Date__c = Date.Today().addDays(-10);
            objSCE.Design_End_Date__c = Date.Today().addDays(10);
            
            //objSCE.Has_Designs__c = false;
            objSCE.Smart_Opportunity_Intent_Use__c  = 'Yes';
            
            insert objSCE;
            
            objTestOppty.ForecastStatus__c  = '0.Booked';
            objTestOppty.StageName = '4.Build Consensus';
            objTestOppty.Win_Loss_Status__c = 'Merged/Dup Opp';
            update objTestOppty;
            
           
            Test.stopTest();
            
        }
        catch(CalloutException ex)
        {}
    }
   
}