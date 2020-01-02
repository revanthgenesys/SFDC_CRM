@isTest
private class ContentRatingTest{

    static Config__c configData(String name,String value){
        
        Config__c config = new Config__c();
        config.Name = name;
        config.Value__c = value;
        return config;
    }
    
    static testmethod void TestContentRating(){
        
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
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1]; 
        
        Account acc1 = new Account (Name = 'Holding Account',RecordTypeId='012U0000000Le3f',Status__c='Active');  
        insert acc1;
        
        Contact contt = new Contact (AccountId = acc1.id,FirstName='TestContact',LastName = 'Foss',Designated_Partner_Contact__c=true);
        insert contt;
        
        User usr = new User(profileId = partnerProfile.id,username = 'newUser211@salesforce.com',email = 'pb211@ff.com',
                                    emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                    timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',contactId = contt.id);
        insert usr;
        
        ContentVersion content = new ContentVersion(Title='Test Content',ContentModifiedDate = Date.today(),
                                                        ContentUrl='https://genesys--sbgenfull.cs21.my.salesforce.com');
        insert content;
        
        content.Description = 'Test Description';
        update content;
        
        List<Favorite_Content__c> favoriteContentList = new List<Favorite_Content__c>();  
        Favorite_Content__c favoriteContent = new Favorite_Content__c(Content_Version_Id__c=content.Id,User_Id__c=usr.Id,
                                                                        RatingCount__c='Positive Rating Count');
        favoriteContentList.add(favoriteContent);
        insert favoriteContentList;
    }
}