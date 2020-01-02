/**
 * @Author      	: Narasimha Rao Tumma
 * @Created Date	: Dec 14, 2015
 * @Org. Release	: Dec 2015
 * @Description 	: Common Test Class for the classes related to Partner Earned Rebate.
 * @Classes Tested 	: RebateAwardLetterController, RebateRequestController, RebateStatementController
 * @Modifications	: 
*/
@isTest
private class EarnedRebateClassesTest {
    
	static Config__c configData(String name,String value){
        return new Config__c(Name = name, Value__c = value);
    }

    @isTest
    static void TestRebateAwardLetterController(){
		insertConfig();
        
 		User currentUser = new User(Id = UserInfo.getUserId(), Bypass_Triggers__c = true, BypassWorkflows__c = true, BypassValidationRules__c = true);
        update currentUser;
        
        List<Partner_Revenue_Mapping__c> partnerRevenueMappingCS = new List<Partner_Revenue_Mapping__c>();
        partnerRevenueMappingCS.add(new Partner_Revenue_Mapping__c(Name = 'License', Revenue_Type__c = 'Revenue - License'));
        partnerRevenueMappingCS.add(new Partner_Revenue_Mapping__c(Name = 'Maintenance', Revenue_Type__c = 'Revenue - Maintenance'));
        partnerRevenueMappingCS.add(new Partner_Revenue_Mapping__c(Name = 'SaaS', Revenue_Type__c = 'Revenue - Soundbite,Revenue - PPU,Revenue - Angel,Revenue - Managed Hosted,Revenue - Platform on Demand,Revenue – Echopass'));
        insert partnerRevenueMappingCS;
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile p = [Select Id from Profile where name = 'Genesys Portal End User'];
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];

        //Create account
        Account a = new Account (Name = 'Holding Account',RecordTypeId=rc.id,Status__c='Active'); 
        insert a;
        
        //Create contact
        Contact c = new Contact(FirstName = 'Rao', Lastname = 'Tumma', AccountId = a.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
        						MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
		            			Designated_Partner_Contact__c=true,  Email='raotest@test.com');
        insert c;
        
        User u = new User( ProfileId = p.Id, Username = 'raotest@test.com', Alias = 'Test1', Email='raotest@test.com', EmailEncodingKey='UTF-8', Firstname='Rao', Lastname='Tumma', 
                			LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = c.id );
        insert u;
        
        Date today = Date.today();
        Integer currentYear =  today.year();
        Integer lastYear = currentYear - 1;
        
		Partner_Rebate__c lastYearRebate = new Partner_Rebate__c(Partner_Name__c= a.Id, Rebate_Name__c='Last Year Rebate', Rebate_Year__c= String.valueOf(lastYear), 
                                                          		Start_Date__c = Date.newinstance(lastYear, 1, 1), End_Date__c= Date.newinstance(lastYear, 12, 31), 
                                                                Status__c = 'Active', Agree_Disagree_Flag__c =true, Agree_Disagree_By__c = u.Lastname, Date_Agree_Disagree__c = Date.newinstance(lastYear, 1, 1), 
                                                                Amount__c=100000, License_Amount__c=100000, SaaS_Amount__c=1000000, Published_to_Partner_Portal__c = true, Publish_Date__c = Date.newinstance(lastYear, 2, 28),
                                                                Earned_Genesys_Care_Amount__c=10000, Earned_License_Amount__c=20000, Earned_SaaS_Amount__c=10000, 
                                                                Earned_Rebate_Publish_Date__c = Date.newinstance(lastYear, 6, 30), Publish_Earned_Amounts_to_Partner_Portal__c = true
                                                            	);
        insert lastYearRebate;
        
		Partner_Rebate__c currentYearRebate = new Partner_Rebate__c(Partner_Name__c= a.Id, Rebate_Name__c='Current Year Rebate', Rebate_Year__c= String.valueOf(currentYear), 
                                                          		Start_Date__c = Date.newinstance(currentYear, 1, 1), End_Date__c= Date.newinstance(currentYear, 12, 31), 
                                                                Status__c = 'Active', Agree_Disagree_Flag__c =true, Agree_Disagree_By__c = u.Lastname, Date_Agree_Disagree__c = Date.newinstance(currentYear, 1, 1), 
                                                                Amount__c=100, License_Amount__c=100, SaaS_Amount__c=100, Published_to_Partner_Portal__c = true, Publish_Date__c = Date.newinstance(lastYear, 2, 28),
                                                                Earned_Genesys_Care_Amount__c=100, Earned_License_Amount__c=200, Earned_SaaS_Amount__c=100, 
                                                                Earned_Rebate_Publish_Date__c = Date.newinstance(lastYear, 6, 30), Publish_Earned_Amounts_to_Partner_Portal__c = true
                                                            	);
        insert currentYearRebate;

        PageReference pageRef = Page.RebateAwardLetter;
        Test.setCurrentPageReference(pageRef);
		System.currentPageReference().getParameters().put('ry', String.valueOf(currentYear));
		System.currentPageReference().getParameters().put('lua', a.Id);
		RebateAwardLetterController controller = new RebateAwardLetterController();
    }
    
    @isTest
    static void TestRebateRequestController(){
        insertConfig();
 		User currentUser = new User(Id = UserInfo.getUserId(), Bypass_Triggers__c = true, BypassWorkflows__c = true, BypassValidationRules__c = true);
        update currentUser;
        
        List<Partner_Revenue_Mapping__c> partnerRevenueMappingCS = new List<Partner_Revenue_Mapping__c>();
        partnerRevenueMappingCS.add(new Partner_Revenue_Mapping__c(Name = 'License', Revenue_Type__c = 'Revenue - License'));
        partnerRevenueMappingCS.add(new Partner_Revenue_Mapping__c(Name = 'Maintenance', Revenue_Type__c = 'Revenue - Maintenance'));
        partnerRevenueMappingCS.add(new Partner_Revenue_Mapping__c(Name = 'SaaS', Revenue_Type__c = 'Revenue - Soundbite,Revenue - PPU,Revenue - Angel,Revenue - Managed Hosted,Revenue - Platform on Demand,Revenue – Echopass'));
        insert partnerRevenueMappingCS;
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile p = [Select Id from Profile where name = 'Genesys Portal End User'];
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];

        //Create account
        Account a = new Account (Name = 'Holding Account',RecordTypeId=rc.id,Status__c='Active'); 
        insert a;
        
        //Create contact
        Contact c = new Contact(FirstName = 'Rao', Lastname = 'Tumma', AccountId = a.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
        						MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
		            			Designated_Partner_Contact__c=true,  Email='raotest@test.com');
        insert c;
        
        User u = new User( ProfileId = p.Id, Username = 'raotest@test.com', Alias = 'Test1', Email='raotest@test.com', EmailEncodingKey='UTF-8', Firstname='Rao', Lastname='Tumma', 
                			LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = c.id );
        insert u;
        
        Date today = Date.today();
        Integer currentYear =  today.year();
        Integer lastYear = currentYear - 1;
        
		Partner_Rebate__c lastYearRebate = new Partner_Rebate__c(Partner_Name__c= a.Id, Rebate_Name__c='Last Year Rebate', Rebate_Year__c= String.valueOf(lastYear), 
                                                          		Start_Date__c = Date.newinstance(lastYear, 1, 1), End_Date__c= Date.newinstance(lastYear, 12, 31), 
                                                                Status__c = 'Active', Agree_Disagree_Flag__c =true, Agree_Disagree_By__c = u.Lastname, Date_Agree_Disagree__c = Date.newinstance(lastYear, 1, 1), 
                                                                Amount__c=100000, License_Amount__c=100000, SaaS_Amount__c=1000000, Published_to_Partner_Portal__c = true, Publish_Date__c = Date.newinstance(lastYear, 2, 28),
                                                                Earned_Genesys_Care_Amount__c=10000, Earned_License_Amount__c=20000, Earned_SaaS_Amount__c=10000, 
                                                                Earned_Rebate_Publish_Date__c = Date.newinstance(lastYear, 6, 30), Publish_Earned_Amounts_to_Partner_Portal__c = true
                                                            	);
        insert lastYearRebate;
        
		Partner_Rebate__c currentYearRebate = new Partner_Rebate__c(Partner_Name__c= a.Id, Rebate_Name__c='Current Year Rebate', Rebate_Year__c= String.valueOf(currentYear), 
                                                          		Start_Date__c = Date.newinstance(currentYear, 1, 1), End_Date__c= Date.newinstance(currentYear, 12, 31), 
                                                                Status__c = 'Active', Agree_Disagree_Flag__c =true, Agree_Disagree_By__c = u.Lastname, Date_Agree_Disagree__c = Date.newinstance(currentYear, 1, 1), 
                                                                Amount__c=100000, License_Amount__c=100000, SaaS_Amount__c=100000, Published_to_Partner_Portal__c = true, Publish_Date__c = Date.newinstance(lastYear, 2, 28),
                                                                Earned_Genesys_Care_Amount__c=100000, Earned_License_Amount__c=100000, Earned_SaaS_Amount__c=100000, 
                                                                Earned_Rebate_Publish_Date__c = Date.newinstance(lastYear, 6, 30), Publish_Earned_Amounts_to_Partner_Portal__c = true
                                                            	);
        insert currentYearRebate;
        
        List<Regional_Controllers__c> rcList = new List<Regional_Controllers__c>();
        rcList.add(new Regional_Controllers__c(Name = 'APAC', Region__c = 'APAC', User_Name__c = UserInfo.getUserName()));
        rcList.add(new Regional_Controllers__c(Name = 'EMEA', Region__c = 'EMEA', User_Name__c = UserInfo.getUserName()));
        rcList.add(new Regional_Controllers__c(Name = 'LATAM', Region__c = 'LATAM', User_Name__c = UserInfo.getUserName()));
        rcList.add(new Regional_Controllers__c(Name = 'North America', Region__c = 'North America', User_Name__c = UserInfo.getUserName()));
        insert rcList;

        List<Partner_Rebate_Regional_Channel_Lead__c> rclList = new List<Partner_Rebate_Regional_Channel_Lead__c>();
        rclList.add(new Partner_Rebate_Regional_Channel_Lead__c(Name = 'APAC', Region__c = 'APAC', User_Name__c = UserInfo.getUserName()));
        rclList.add(new Partner_Rebate_Regional_Channel_Lead__c(Name = 'EMEA', Region__c = 'EMEA', User_Name__c = UserInfo.getUserName()));
        rclList.add(new Partner_Rebate_Regional_Channel_Lead__c(Name = 'LATAM', Region__c = 'LATAM', User_Name__c = UserInfo.getUserName()));
        rclList.add(new Partner_Rebate_Regional_Channel_Lead__c(Name = 'North America', Region__c = 'North America', User_Name__c = UserInfo.getUserName()));
        insert rclList;

        
        PageReference pageRef = Page.RebateRequest;
        Test.setCurrentPageReference(pageRef);
        System.currentPageReference().getParameters().put('ry', String.valueOf(currentYear));
        System.currentPageReference().getParameters().put('lua', a.Id);
        
        RebateRequestController controller = new RebateRequestController();
        controller.rebateRequest.CurrencyIsoCode = 'USD';
        controller.rebateRequest.Requested_Rebate_Amount__c = 1000;
        controller.rebateRequest.Date__c = Date.today();
        controller.rebateRequest.Expense_Type__c = 'Marketing Expense';
        controller.rebateRequest.Marketing_Expense_Comments__c = 'Test Marketing Expense';
        controller.rebateRequest.Contact__c = u.ContactId;
        
        // controller.attachment = new Attachment(Name='Unit Test Attachment', body= Blob.valueOf('Unit Test Attachment Body'));
        controller.attachment.Name = 'Testing';
        controller.attachment.Body = Blob.valueOf('Unit Test Attachment Body');
        controller.saveRebateRequest();
        controller.redirectToPerformance();
    }
    
    @isTest
    static void TestRebateStatementController(){
        insertConfig();
 		User currentUser = new User(Id = UserInfo.getUserId(), Bypass_Triggers__c = true, BypassWorkflows__c = true, BypassValidationRules__c = true);
        update currentUser;        
        
        List<Partner_Revenue_Mapping__c> partnerRevenueMappingCS = new List<Partner_Revenue_Mapping__c>();
        partnerRevenueMappingCS.add(new Partner_Revenue_Mapping__c(Name = 'License', Revenue_Type__c = 'Revenue - License'));
        partnerRevenueMappingCS.add(new Partner_Revenue_Mapping__c(Name = 'Maintenance', Revenue_Type__c = 'Revenue - Maintenance'));
        partnerRevenueMappingCS.add(new Partner_Revenue_Mapping__c(Name = 'SaaS', Revenue_Type__c = 'Revenue - Soundbite,Revenue - PPU,Revenue - Angel,Revenue - Managed Hosted,Revenue - Platform on Demand,Revenue – Echopass'));
        insert partnerRevenueMappingCS;
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile p = [Select Id from Profile where name = 'Genesys Portal End User'];
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];

        //Create account
        Account a = new Account (Name = 'Holding Account',RecordTypeId=rc.id,Status__c='Active'); 
        insert a;
        
        //Create contact
        Contact c = new Contact(FirstName = 'Rao', Lastname = 'Tumma', AccountId = a.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
        						MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
		            			Designated_Partner_Contact__c=true,  Email='raotest@test.com');
        insert c;
        
        User u = new User( ProfileId = p.Id, Username = 'raotest@test.com', Alias = 'Test1', Email='raotest@test.com', EmailEncodingKey='UTF-8', Firstname='Rao', Lastname='Tumma', 
                			LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = c.id );
        insert u;
        
        Date today = Date.today();
        Integer currentYear =  today.year();
        Integer lastYear = currentYear - 1;
        
		Partner_Rebate__c lastYearRebate = new Partner_Rebate__c(Partner_Name__c= a.Id, Rebate_Name__c='Last Year Rebate', Rebate_Year__c= String.valueOf(lastYear), 
                                                          		Start_Date__c = Date.newinstance(lastYear, 1, 1), End_Date__c= Date.newinstance(lastYear, 12, 31), 
                                                                Status__c = 'Active', Agree_Disagree_Flag__c =true, Agree_Disagree_By__c = u.Lastname, Date_Agree_Disagree__c = Date.newinstance(lastYear, 1, 1), 
                                                                Amount__c=100000, License_Amount__c=100000, SaaS_Amount__c=1000000, Published_to_Partner_Portal__c = true, Publish_Date__c = Date.newinstance(lastYear, 2, 28),
                                                                Earned_Genesys_Care_Amount__c=10000, Earned_License_Amount__c=20000, Earned_SaaS_Amount__c=10000, 
                                                                Earned_Rebate_Publish_Date__c = Date.newinstance(lastYear, 6, 30), Publish_Earned_Amounts_to_Partner_Portal__c = true
                                                            	);
        insert lastYearRebate;
        
		Partner_Rebate__c currentYearRebate = new Partner_Rebate__c(Partner_Name__c= a.Id, Rebate_Name__c='Current Year Rebate', Rebate_Year__c= String.valueOf(currentYear), 
                                                          		Start_Date__c = Date.newinstance(currentYear, 1, 1), End_Date__c= Date.newinstance(currentYear, 12, 31), 
                                                                Status__c = 'Active', Agree_Disagree_Flag__c =true, Agree_Disagree_By__c = u.Lastname, Date_Agree_Disagree__c = Date.newinstance(currentYear, 1, 1), 
                                                                Amount__c=100000, License_Amount__c=100000, SaaS_Amount__c=100000, Published_to_Partner_Portal__c = true, Publish_Date__c = Date.newinstance(lastYear, 2, 28),
                                                                Earned_Genesys_Care_Amount__c=100000, Earned_License_Amount__c=100000, Earned_SaaS_Amount__c=100000, 
                                                                Earned_Rebate_Publish_Date__c = Date.newinstance(lastYear, 6, 30), Publish_Earned_Amounts_to_Partner_Portal__c = true
                                                            	);
        insert currentYearRebate;
        
        List<Regional_Controllers__c> rcList = new List<Regional_Controllers__c>();
        rcList.add(new Regional_Controllers__c(Name = 'APAC', Region__c = 'APAC', User_Name__c = UserInfo.getUserName()));
        rcList.add(new Regional_Controllers__c(Name = 'EMEA', Region__c = 'EMEA', User_Name__c = UserInfo.getUserName()));
        rcList.add(new Regional_Controllers__c(Name = 'LATAM', Region__c = 'LATAM', User_Name__c = UserInfo.getUserName()));
        rcList.add(new Regional_Controllers__c(Name = 'North America', Region__c = 'North America', User_Name__c = UserInfo.getUserName()));
        insert rcList;
        
		List<Partner_Rebate_Regional_Channel_Lead__c> rclList = new List<Partner_Rebate_Regional_Channel_Lead__c>();
        rclList.add(new Partner_Rebate_Regional_Channel_Lead__c(Name = 'APAC', Region__c = 'APAC', User_Name__c = UserInfo.getUserName()));
        rclList.add(new Partner_Rebate_Regional_Channel_Lead__c(Name = 'EMEA', Region__c = 'EMEA', User_Name__c = UserInfo.getUserName()));
        rclList.add(new Partner_Rebate_Regional_Channel_Lead__c(Name = 'LATAM', Region__c = 'LATAM', User_Name__c = UserInfo.getUserName()));
        rclList.add(new Partner_Rebate_Regional_Channel_Lead__c(Name = 'North America', Region__c = 'North America', User_Name__c = UserInfo.getUserName()));
        insert rclList;
        
        PageReference pageRef = Page.RebateRequest;
        Test.setCurrentPageReference(pageRef);
        System.currentPageReference().getParameters().put('ry', String.valueOf(currentYear));
        System.currentPageReference().getParameters().put('lua', a.Id);
        
        RebateRequestController controller = new RebateRequestController();
        controller.rebateRequest.CurrencyIsoCode = 'USD';
        controller.rebateRequest.Requested_Rebate_Amount__c = 1000;
        controller.rebateRequest.Date__c = Date.today();
        controller.rebateRequest.Expense_Type__c = 'Marketing Expense';
        controller.rebateRequest.Marketing_Expense_Comments__c = 'Test Marketing Expense';
        controller.rebateRequest.Contact__c = u.ContactId;
        
        // controller.attachment = new Attachment(Name='Unit Test Attachment', body= Blob.valueOf('Unit Test Attachment Body'));
        controller.attachment.Name = 'Testing';
        controller.attachment.Body = Blob.valueOf('Unit Test Attachment Body');
        controller.saveRebateRequest();
        controller.redirectToPerformance();
        
        Test.setCurrentPageReference(Page.RebateStatement);
        System.currentPageReference().getParameters().put('ry', String.valueOf(currentYear));
        System.currentPageReference().getParameters().put('lua', a.Id);
		RebateStatementController rsController = new RebateStatementController();
        rsController.redirectToPerformance();
        rsController.exportToExcel();
    }
    
    
    static void insertConfig(){
        List<Config__c> conList = new List<Config__c>();
        conList.add(configData('CORE_OPP_STAGE_CLOSED_WON','User Contract'));
        conList.add(configData('USER_PARTNER','PowerPartner'));
        conList.add(configData('USER_STANDARD',''));
        conList.add(configData('CORE_OPP_BP_STATUS_ALLOCATED',''));
        conList.add(configData('ALE_TEAM_MEMBER_ROLE',''));
        conList.add(configData('CORE_OPP_BP_STATUS_REJECTED',''));
        conList.add(configData('CORE_OPP_BP_STATUS_NOT_ALLOCATED',''));
        conList.add(configData('CORE_OPP_BP_STATUS_APPROVED',''));
        conList.add(configData('BP_TEAM_MEMBER_ROLE',''));
        conList.add(configData('TM_MONITOR_AD_EMAIL1',''));
        conList.add(configData('TM_MONITOR_AD_EMAIL2',''));
        conList.add(configData('TM_MONITOR_AD_EMAIL3',''));
        conList.add(configData('TM_VALUE_SEPARATOR',''));
        conList.add(configData('TM_USER_NAME_TEST1',''));
        conList.add(configData('TM_USER_NAME_TEST2',''));
        conList.add(configData('ASSET_DEFAULT_MANUFACTURER',''));
        conList.add(configData('CORE_OpportunityApprovalProcess',''));
        conList.add(configData('COREOpportunityRecordType','012U0000000Ldb8'));
        conList.add(configData('EMGBusinessPartnerRecordType',''));
        conList.add(configData('EMGBusinessPartnerOwner',''));
        conList.add(configData('EMGStatusGetRejected',''));
        conList.add(configData('RT_RFP_Refused',''));
        conList.add(configData('RT_RFP_Accepted',''));
        conList.add(configData('RT_RFP_PROPOSAL_ACCEPTED',''));
        conList.add(configData('RT_RFP_PROPOSAL_REFUSED',''));
        conList.add(configData('ACCEPTED_RFP_FORM_TEMPLATE',''));
        conList.add(configData('REJECTED_RFP_FORM_TEMPLATE',''));
        conList.add(configData('SUBMIT_RFP_FORM_TEMPLATE',''));
        conList.add(configData('PENDING_RFP_FORM_TEMPLATE',''));
        conList.add(configData('INACTIVE_OFFER',''));
        conList.add(configData('ACTIVE_OFFER',''));
        conList.add(configData('REGION_EMEA',''));
        conList.add(configData('BID_PROPOSAL_CONTACT_EMEA',''));
        conList.add(configData('BID_PROPOSAL_CONTACT_NA',''));
        conList.add(configData('RFP_QUEUE',''));
        conList.add(configData('RFP_MAIL',''));
        conList.add(configData('RT_OQM_Submission',''));
        conList.add(configData('RT_RFP_Submission',''));
        conList.add(configData('RT_OQM_PROPOSAL_ACCEPTED',''));
        conList.add(configData('RT_OQM_PROPOSAL_REFUSED',''));
        conList.add(configData('OQM_STATUS_PENDING',''));
        conList.add(configData('OQM_STATUS_SUBMIT',''));
        conList.add(configData('OQM_STATUS_REJECTED',''));
        conList.add(configData('OQM_STATUS_ACCEPTED',''));
        conList.add(configData('OPP_STAGE4',''));
        conList.add(configData('OPP_STAGE5',''));
        conList.add(configData('OPP_STAGE6',''));
        conList.add(configData('OPP_STAGE7',''));
        conList.add(configData('OPP_STAGE81',''));
        conList.add(configData('OPP_STAGE82',''));
        conList.add(configData('OPP_STAGE9',''));
        conList.add(configData('OPP_STAGE10',''));
        conList.add(configData('BP_ROLE',''));
        conList.add(configData('PROFIL_ADMIN_ID',''));
        insert conList;
    }
}