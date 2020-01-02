@isTest
private class dqSubApprovalStatusTest {
    
    @isTest
    private static void createDQWrapperRectest(){

    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User u = new User(Alias = 'newUser', Email='test@genesys.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='test@genesysdev.com');
        System.runAs(u) {         
       
         Deal_Qualification__c testRec = new Deal_Qualification__c();
         testRec.Order_Mgmt_Billing_approval__c='Pending';
         testRec.Req_Order_Mgmt_Billing_approval__c=true;
         testRec.Status__c = 'Approval Pending';
         testRec.Req_Legal_approval__c = true;
         testRec.Legal_approval__c = 'Pending';
         testRec.Req_Credit_Collections_approval__c= true;
         testRec.Credit_and_Collections_approval__c='Pending';
         testRec.Req_Revenue_Approval__c=true;
         testRec.Revenue_approval__c = 'Pending';
         insert testRec;
        
        Quote_Approval__c testQtApp = new Quote_Approval__c();
        testQtApp.Deal_Qualification__c = testRec.id;
        testQtApp.status__c = 'Pending';
        testQtApp.Reason_Name__c='Special,Offer';
       
        insert testQtApp;
        
        DQ_Special_Offers__c dqOff1= new DQ_Special_Offers__c(Name='Revenue_North America',Additional_Email_Addresses__c='test@genesys.com',Back_Up_Contact_Email__c='test@genesys.com',Finance_Function__c='Revenue',Primary_Contact_Email__c='test@genesys.com',Region__c='North America');
        insert dqOff1;

        
        
        dqSubApprovalStatus dqStatus = new dqSubApprovalStatus();
        dqSubApprovalStatus.DQSubAppWrapperClass prepDQ = new dqSubApprovalStatus.DQSubAppWrapperClass();
        Test.startTest();        
        prepDQ =   dqStatus.createDQWrapperRec(testQtApp, 'TestUser');
        Test.stopTest();
        
        }

    }
    

}