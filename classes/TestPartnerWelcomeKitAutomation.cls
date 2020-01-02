@isTest
private class TestPartnerWelcomeKitAutomation {
	@isTest
    static void testAccountTriggers(){
        
        setupData();
        // Create custom settings

        // Create Partner Account
        // Create Contact
        // Create Partner User
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile p = [Select Id from Profile where name = 'Genesys Portal End User'];
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];

        //Create account
        Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', Type = 'Prospective Partner', PartnerType__c='Cloud Partner;Cloud Solution Provider;Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ', Channel_Manager__c = UserInfo.getUserId()); 
        insert a1;
        
        //Create contact
        Contact c1 = new Contact(FirstName = 'Rao', Lastname = 'Tumma', AccountId = a1.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
        						MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
		            			Designated_Partner_Contact__c=true,  Email='raotest1@test.com');
        insert c1;
        
        Contact c2 = new Contact(FirstName = 'Narasimha', Lastname = 'Tumma', AccountId = a1.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
        						MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
		            			Designated_Partner_Contact__c=true,  Email='raotest2@test.com');
        insert c2;

        User u1 = new User( ProfileId = p.Id, Username = 'raotest1@test.com', Alias = 'Test1', Email='raotest1@test.com', EmailEncodingKey='UTF-8', Firstname='Rao', Lastname='Tumma', 
                			LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = c1.id );
        insert u1;
        
        User u2 = new User( ProfileId = p.Id, Username = 'raotest2@test.com', Alias = 'Test2', Email='raotest2@test.com', EmailEncodingKey='UTF-8', Firstname='Narasimha', Lastname='Tumma', 
                			LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = c2.id );
        insert u2;
        
        a1.Type = 'Partner';
        Update a1;
        
    }
    
    static void setupData(){
        List<Partner_WelcomeKit_Internal_Email_Distro__c> emailsDistro = new List<Partner_WelcomeKit_Internal_Email_Distro__c>();
		emailsDistro.add(new Partner_WelcomeKit_Internal_Email_Distro__c(Name = 'jessica.doucette@genesys.com')); 
		emailsDistro.add(new Partner_WelcomeKit_Internal_Email_Distro__c(Name = 'cindy.cover@genesys.com')); 
        insert emailsDistro;
        
        List<Partner_Rebate_Regional_Channel_Lead__c> regionalChannelLeads = new List<Partner_Rebate_Regional_Channel_Lead__c>();
        regionalChannelLeads.add(new Partner_Rebate_Regional_Channel_Lead__c(Name='APAC', User_Name__c = UserInfo.getUserName()));
        regionalChannelLeads.add(new Partner_Rebate_Regional_Channel_Lead__c(Name='EMEA', User_Name__c = UserInfo.getUserName()));
        regionalChannelLeads.add(new Partner_Rebate_Regional_Channel_Lead__c(Name='LATAM', User_Name__c = UserInfo.getUserName()));
        regionalChannelLeads.add(new Partner_Rebate_Regional_Channel_Lead__c(Name='North America', User_Name__c = UserInfo.getUserName()));
        insert regionalChannelLeads;
        
        List<Config__c> conList = new List<Config__c>();
        conList.add(new Config__c(Name = 'CORE_OPP_STAGE_CLOSED_WON',Value__c = 'User Contract'));
        conList.add(new Config__c(Name = 'USER_PARTNER',Value__c = 'PowerPartner'));
        conList.add(new Config__c(Name = 'USER_STANDARD',Value__c = ''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_ALLOCATED',Value__c = ''));
        conList.add(new Config__c(Name = 'ALE_TEAM_MEMBER_ROLE',Value__c = ''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_REJECTED',Value__c = ''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_NOT_ALLOCATED',Value__c = ''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_APPROVED',Value__c = ''));
        conList.add(new Config__c(Name = 'BP_TEAM_MEMBER_ROLE',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_MONITOR_AD_EMAIL1',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_MONITOR_AD_EMAIL2',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_MONITOR_AD_EMAIL3',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_VALUE_SEPARATOR',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_USER_NAME_TEST1',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_USER_NAME_TEST2',Value__c = ''));
        conList.add(new Config__c(Name = 'ASSET_DEFAULT_MANUFACTURER',Value__c = ''));
        conList.add(new Config__c(Name = 'CORE_OpportunityApprovalProcess',Value__c = ''));
        conList.add(new Config__c(Name = 'COREOpportunityRecordType',Value__c = '012U0000000Ldb8'));
        conList.add(new Config__c(Name = 'EMGBusinessPartnerRecordType',Value__c = ''));
        conList.add(new Config__c(Name = 'EMGBusinessPartnerOwner',Value__c = ''));
        conList.add(new Config__c(Name = 'EMGStatusGetRejected',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_RFP_Refused',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_RFP_Accepted',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_RFP_PROPOSAL_ACCEPTED',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_RFP_PROPOSAL_REFUSED',Value__c = ''));
        conList.add(new Config__c(Name = 'ACCEPTED_RFP_FORM_TEMPLATE',Value__c = ''));
        conList.add(new Config__c(Name = 'REJECTED_RFP_FORM_TEMPLATE',Value__c = ''));
        conList.add(new Config__c(Name = 'SUBMIT_RFP_FORM_TEMPLATE',Value__c = ''));
        conList.add(new Config__c(Name = 'PENDING_RFP_FORM_TEMPLATE',Value__c = ''));
        conList.add(new Config__c(Name = 'INACTIVE_OFFER',Value__c = ''));
        conList.add(new Config__c(Name = 'ACTIVE_OFFER',Value__c = ''));
        conList.add(new Config__c(Name = 'REGION_EMEA',Value__c = ''));
        conList.add(new Config__c(Name = 'BID_PROPOSAL_CONTACT_EMEA',Value__c = ''));
        conList.add(new Config__c(Name = 'BID_PROPOSAL_CONTACT_NA',Value__c = ''));
        conList.add(new Config__c(Name = 'RFP_QUEUE',Value__c = ''));
        conList.add(new Config__c(Name = 'RFP_MAIL',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_OQM_Submission',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_RFP_Submission',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_OQM_PROPOSAL_ACCEPTED',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_OQM_PROPOSAL_REFUSED',Value__c = ''));
        conList.add(new Config__c(Name = 'OQM_STATUS_PENDING',Value__c = ''));
        conList.add(new Config__c(Name = 'OQM_STATUS_SUBMIT',Value__c = ''));
        conList.add(new Config__c(Name = 'OQM_STATUS_REJECTED',Value__c = ''));
        conList.add(new Config__c(Name = 'OQM_STATUS_ACCEPTED',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE4',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE5',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE6',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE7',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE81',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE82',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE9',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE10',Value__c = ''));
        conList.add(new Config__c(Name = 'BP_ROLE',Value__c = ''));
        conList.add(new Config__c(Name = 'PROFIL_ADMIN_ID',Value__c = ''));
        insert conList;
    }
}