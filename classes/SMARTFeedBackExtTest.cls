@IsTest
public with sharing class SMARTFeedBackExtTest {

    static testMethod void myUnitTestForCase() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

        Account objAccount = new Account( Name='Test Account12345678', Status__c = 'Active' );
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        insert objAccount;

        FeedBack_GovernanceTeam__C  ff1 = new FeedBack_GovernanceTeam__C();
        ff1.Solution_Target_Aliases__c ='chaitanya38@gmail.com';
        ff1.name='Default';
        ff1.Prime__c ='Cameron Smith';
        insert ff1;

        SMARTFeedBackExt sf = new SMARTFeedBackExt();
        sf.strAssignedTo    = UserInfo.getName();

        SMART_Feedback__c sobj4 = new SMART_Feedback__c(
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

        sf.objFeedbackloop = sobj4;
        sf.IsNewRecord=true;
        sf.submit();
    }

    static testMethod void myUnitTestForCase5() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

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

        SMART_Feedback__c sobj4 = new SMART_Feedback__c(
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

        sf.objFeedbackloop = sobj4;
        sf.IsNewRecord=true;
        sf.submit();
    }

    static testMethod void myUnitTestForCase2() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

        Account objAccount = new Account( Name='Test Account12345678', Status__c = 'Active' );
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        insert objAccount;

        FeedBack_GovernanceTeam__C  ff1 = new FeedBack_GovernanceTeam__C();
        ff1.Solution_Target_Aliases__c ='chaitanya38@gmail.com';
        ff1.name='Default';
        ff1.Prime__c ='Cameron Smith';
        insert ff1;

        SMARTFeedBackExt sf = new SMARTFeedBackExt();
        sf.strAssignedTo    = UserInfo.getName();

        SMART_Feedback__c sobj4 = new SMART_Feedback__c(
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

        sf.objFeedbackloop = sobj4;
        sf.IsNewRecord=false;
        sf.submit();
    }

    static testMethod void myUnitTestForCase3() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

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

        SMART_Feedback__c sobj4 = new SMART_Feedback__c(
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

        
        insert sobj4;
        sf.objFeedbackloop = sobj4;
        sf.submit();
    }


    static testMethod void myUnitTestForCase6() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

        Account objAccount = new Account( Name='Test Account12345678', Status__c = 'Active' );
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        insert objAccount;

        FeedBack_GovernanceTeam__C  ff1 = new FeedBack_GovernanceTeam__C();
        ff1.Solution_Target_Aliases__c ='chaitanya38@gmail.com';
        ff1.name='Default';
        ff1.Prime__c ='Cameron Smith';
        insert ff1;

        SMARTFeedBackExt sf = new SMARTFeedBackExt();
        sf.strAssignedTo    = UserInfo.getName();

        SMART_Feedback__c sobj4 = new SMART_Feedback__c(
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

        
        insert sobj4;
        sf.objFeedbackloop = sobj4;
        sf.submit();
    }

    static testMethod void myUnitAssignEmail() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

        Account objAccount = new Account( Name='Test Account12345678', Status__c = 'Active' );
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        insert objAccount;

        FeedBack_GovernanceTeam__C  ff1 = new FeedBack_GovernanceTeam__C();
        ff1.Solution_Target_Aliases__c ='chaitanya38@gmail.com';
        ff1.name='Default';
        ff1.Prime__c ='Cameron Smith';
        insert ff1;

        SMARTFeedBackExt sf = new SMARTFeedBackExt();
        sf.strAssignedTo    = UserInfo.getName();

        SMART_Feedback__c sobj4 = new SMART_Feedback__c(
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

        sf.objFeedbackloop = sobj4;
        sf.IsNewRecord=true;
        sf.AssignEmail(sobj4);
    }


    static testMethod void myUnitAssignEmailProduct() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

        Account objAccount = new Account( Name='Test Account12345678', Status__c = 'Active' );
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        insert objAccount;

        FeedBack_GovernanceTeam__C  ff = new FeedBack_GovernanceTeam__C();
        ff.Solution_Target_Aliases__c ='a1@gmail.com';
        ff.name='Customer Engagement,Other';
        ff.Prime__c ='Cameron Smith';
        insert ff;

        FeedBack_GovernanceTeam__C  ff1 = new FeedBack_GovernanceTeam__C();
        ff1.Solution_Target_Aliases__c ='a1@gmail.com';
        ff1.name='Customer Engagement,Other';
        ff1.Prime__c ='Cameron Smith';
        insert ff1;

        SMARTFeedBackExt sf = new SMARTFeedBackExt();
        sf.strAssignedTo = UserInfo.getName();

        SMART_Feedback__c sobj4 = new SMART_Feedback__c(
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
                                  recordtypeid = RecordTypeIdContact                                                            
                                );

        sf.objFeedbackloop = sobj4;
        sf.IsNewRecord=true;
        sf.AssignEmail(sobj4);
    }


    static testMethod void myUnitAssignEmailDefaProduct() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

        Account objAccount = new Account( Name='Test Account12345678', Status__c = 'Active' );
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        insert objAccount;

        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        cas.Sold_To_Account__c = objAccount.Id;
        insert cas;

        FeedBack_GovernanceTeam__C  ff = new FeedBack_GovernanceTeam__C();
        ff.Solution_Target_Aliases__c ='a1@gmail.com';
        ff.name='Default';
        ff.Prime__c ='Cameron Smith';
        insert ff;

        SMARTFeedBackExt sf = new SMARTFeedBackExt();
        sf.strAssignedTo = UserInfo.getName();

        SMART_Feedback__c sobj4 = new SMART_Feedback__c(
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
                                  recordtypeid = RecordTypeIdContact                                                            
                                );

        sf.objFeedbackloop = sobj4;
        sf.IsNewRecord=true;
        sf.AssignEmail(sobj4);

        sf.getRelcase();
        sf.getSelected();
        sf.save();
    }

    static testMethod void myUnitTestForProduct() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

        Account objAccount = new Account( Name='Test Account12345678', Status__c = 'Active' );
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        insert objAccount;

        FeedBack_GovernanceTeam__C  ff = new FeedBack_GovernanceTeam__C();
        ff.Solution_Target_Aliases__c ='a1@gmail.com';
        ff.name='Customer Engagement,Other';
        ff.Prime__c ='Cameron Smith';
        insert ff;

        FeedBack_GovernanceTeam__C  ff1 = new FeedBack_GovernanceTeam__C();
        ff1.Solution_Target_Aliases__c ='a1@gmail.com';
        ff1.name='Customer Engagement,Other';
        ff1.Prime__c ='Cameron Smith';
        insert ff1;

        SMARTFeedBackExt sf = new SMARTFeedBackExt();
        sf.strAssignedTo = UserInfo.getName();

        SMART_Feedback__c sobj4 = new SMART_Feedback__c(
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
                                  recordtypeid = RecordTypeIdContact                                                            
                                );

        sf.objFeedbackloop = sobj4;
        sf.IsNewRecord=true;
        sf.submit();
    }
    

    static testMethod void myUnitTestForDefaultProduct() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

        Account objAccount = new Account( Name='Test Account12345678', Status__c = 'Active' );
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        insert objAccount;

        FeedBack_GovernanceTeam__C  ff = new FeedBack_GovernanceTeam__C();
        ff.Solution_Target_Aliases__c ='a1@gmail.com';
        ff.name='Customer Engagement,Other';
        ff.Prime__c ='Cameron Smith';
        insert ff;

        FeedBack_GovernanceTeam__C  ff1 = new FeedBack_GovernanceTeam__C();
        ff1.Solution_Target_Aliases__c ='a1@gmail.com';
        ff1.name='Default';
        ff1.Prime__c ='Cameron Smith';
        insert ff1;

        SMARTFeedBackExt sf = new SMARTFeedBackExt();
        sf.strAssignedTo = UserInfo.getName();

        SMART_Feedback__c sobj4 = new SMART_Feedback__c(
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
                                  recordtypeid = RecordTypeIdContact                                                            
                                );

        sf.objFeedbackloop = sobj4;
        sf.IsNewRecord=true;
        sf.submit();
        sf.blnIsSubmitted = false;
        sf.Cases='Case';
        sf.strFocusValue='focusValue';
        sf.inputflag = true;
        sf.solutionCat='value';
        sf.IsEdit=true;
        sf.IsSubmitterOnEdit=true;
        sf.scontrolCaching='true';
    }


    static testMethod void myUnitTestForDefaultProduct1() {

        Id RecordTypeIdContact = Schema.SObjectType.SMART_Feedback__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();

        Account objAccount = new Account( Name='Test Account12345678', Status__c = 'Active' );
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        insert objAccount;

        FeedBack_GovernanceTeam__C  ff = new FeedBack_GovernanceTeam__C();
        ff.Solution_Target_Aliases__c ='a1@gmail.com';
        ff.name='Customer Engagement,Other';
        ff.Prime__c ='Cameron Smith';
        insert ff;

        FeedBack_GovernanceTeam__C  ff1 = new FeedBack_GovernanceTeam__C();
        ff1.Solution_Target_Aliases__c ='a1@gmail.com';
        ff1.name='Default';
        ff1.Prime__c ='Cameron Smith';
        insert ff1;
        
        SMARTFeedBackExt sf = new SMARTFeedBackExt();
        sf.strAssignedTo   = UserInfo.getName();

        SMART_Feedback__c sobj4 = new SMART_Feedback__c(
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
                                  recordtypeid = RecordTypeIdContact                                                            
                                );

        insert sobj4;
        
        Attachment attach=new Attachment();       
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=sobj4.id;
        insert attach;
        
        sf.getSolution();
        sf.getrefs();
        sf.getusecases();
        sf.GetAttachments();
        sf.UploadFile();
        sf.fileBody  = attach.body;
        sf.fileName  = 'fileName';
        

        sf.sAttachmentId = String.valueOf(attach.Id);
        sf.DeleteAttachment();
        sf.CancelPSDSR();
        sf.strAccVa='Test Account12345678';
        sf.dummyMethod();
        sf.objFeedbackloop = sobj4;
        sf.submit();
        sf.strRequestor='New Use Case Idea';
        sf.queryRequestorInfo();
        sf.feedbackInfo();
        sf.solutionFeedbackType ='Best Practice (Something we should promote, model, and repeat)';
        sf.solutionFeedbackTypeInfo();
        sf.solutionchange ='Test';
        sf.productchange ='Hello';
        sf.strCommVa  ='Date';
        sf.strIdeaTitle = 'Idea';
        sf.strIdeaComments ='Idea Comments';
        sf.strIdeaAntiBenefits ='Test';
        sf.strDispositionComment ='Comments';
        sf.strDispositionDate =System.Today();
        sf.strDispositionStatus ='Status';
        sf.strFeedbackCategory  ='cc';
        sf.strupdatedrootComments ='Root';
        sf.strupdaterootComments = 'RootComments';
        sf.Sol();
        sf.Pro();
        sf.getAnticipatedValues();
        sf.UpdateCommmentsPopulated();
        sf.UpdateIdeaTitle();
        sf.UpdateIdeaComments();
        sf.UpdateBenefits();
        sf.UpdateDispositionComment();
        sf.UpdateDispositionDate();
        sf.UpdateDispositionStatus();
        sf.FeedbkCategory();
        sf.UpdatedRtCause();
        sf.UpdateSuggestionforImp();
        sf.OpportunityPopulated();
        sf.AccountPopulated();
        sf.CommonMethod();
        sf.UpdateAssignedTo();
    }
}