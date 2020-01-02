@IsTest
public with sharing class FeedBackCommunicationTest { 
    
    static testMethod void myUnitTestForCase() {
      
      Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

        Account objAccount = TestUtil.createAccounts(1, false)[0];
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        insert objAccount;

        SMART_Feedback__c sobj = new SMART_Feedback__c(
                                  Product_or_Use_Case__c = 'Product',                                                         // Product or Use Case
                                  Feedback_Sent_To__c = 'nik.mills@genesys.com',                                                // Feedback Sent To
                                  User_Comments__c = 'Test',                                                                    // User Comments
                                  Product_Category__c = 'Customer Engagement,Other',                                            // Product Category
                                  Product_Details__c = 'Analytics',                                                             // Product Details
                                  Product_Feedback_Type__c = 'Best Practice (Something we should promote, model, and repeat)',  // Product Feedback Type
                                  Product_Feedback_Category__c = 'Customer Business Readiness',                                 // Product Feedback Category
                                  Disposition_Status__c = 'Open',                                                               // Disposition Status
                                  isEmailSent__c = false,                                                                        // isEmailSent
                                  Submitted__c = false,                                                                          // Submitted
                                  Attachment__c = false,
                                  Sold_To_Account__c =objAccount.Id,
                                  recordtypeid = RecordTypeIdContact                                                            // Attachment
                                );
        insert sobj;
        
        Attachment attach=new Attachment();       
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=sobj.id;
        insert attach;
        
        PageReference tpageRef = Page.FeedBackCommunication;
       Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('Id', sobj.Id);
      
       FeedBackCommunication hh = new FeedBackCommunication();
       hh.sUsersIds='chaitanya38@gmial.com, plapala.varma@gmail.com';
       hh.SendEmail();
       hh.fileBody =attach.body;
       hh.fileName=attach.Name;
       hh.BindAttachment();
       hh.UploadFile();
   }
   
   static testMethod void myUnitTestForCase6() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Use Case').getRecordTypeId();

        Account objAccount = new Account( Name='Test Account12345678', Status__c = 'Active' );
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        insert objAccount;

        FeedBack_GovernanceTeam__C  ff1 = new FeedBack_GovernanceTeam__C();
        ff1.Solution_Target_Aliases__c ='chaitanya38@gmail.com';
        ff1.Use_Case_Target_Aliases__c ='chaitanya38@gmail.com';
        ff1.name='Customer Engagement,Other';
        ff1.Prime__c ='Cameron Smith';
        insert ff1;

        SMARTFeedBackExt sf = new SMARTFeedBackExt();
        sf.strAssignedTo    = UserInfo.getName();

        SMART_Feedback__c sobj = new SMART_Feedback__c(
                                  Product_or_Use_Case__c = 'Use Case',  
                                  Use_Case_Feedback_Type__c ='Use Case Gap',   
                                  Group_owner__c='Graeme Provan',                                               // Product or Use Case
                                  Feedback_Sent_To__c = 'nik.mills@genesys.com',                                                // Feedback Sent To
                                  User_Comments__c = 'Test',                                                                    // User Comments
                                  Product_Categories__c = 'Customer Engagement,Other',                                   // Product Category
                                  Use_Case_Id__c = 'BO02',                                                                   // Product Details
                                  Use_Case_Name__c = 'Genesys Task Distribution',                                            // Product Feedback Type
                                  Product_Feedback_Category__c = 'Customer Business Readiness',                                 // Product Feedback Category
                                  Disposition_Status__c = 'Open',                                                               // Disposition Status
                                  isEmailSent__c = false,                                                                        // isEmailSent
                                  Submitted__c = false,                                                                          // Submitted
                                  Attachment__c = false,
                                    Sold_To_Account__c =objAccount.Id,
                                  recordtypeid = RecordTypeIdContact                                                            
                                );
        
        insert sobj;
        PageReference tpageRef = Page.FeedBackCommunication;
       Test.setCurrentPage(tpageRef);
       ApexPages.currentPage().getParameters().put('Id', sobj.Id);
        
        Attachment attach=new Attachment();       
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=sobj.id;
        insert attach;
        
       FeedBackCommunication hh = new FeedBackCommunication();
       hh.sUsersIds='chaitanya38@gmial.com, plapala.varma@gmail.com';
       hh.sContactsIds='chaitanya38@gmial.com, plapala.varma@gmail.com';
       hh.SendEmail();
       hh.fileBody =attach.body;
       hh.fileName=attach.Name;
       hh.BindAttachment();
       hh.UploadFile();
    }
}