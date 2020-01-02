@isTest
private class GenericPartnerPortalUserPwdUpdTest {
    static testMethod void testGenericPartnerPortalUserPwdUpdScheduler(){
        insertConfig();
        Partner_Portal_Settings__c pps = new Partner_Portal_Settings__c(Name = 'GenericPartnerPortalUserPassword', Id_Value__c = 'genesys2016');
        insert pps;
        
        LIST<User> portalUsers = [SELECT Id, Generic_Portal_User__c, Generic_Portal_Password_Set__c 
                                    FROM User WHERE IsActive=true AND Username like 'gen%genesys%' AND 
                                    UserType='PowerPartner' AND Generic_Portal_User__c=true 
                                    LIMIT 2];
        
        for(User u : portalUsers){
            u.Generic_Portal_Password_Set__c = false;
        }
        Update portalUsers;
        
        String cronExp = '0 0 0 3 9 ? 2022';
        /*
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('GenericPortalUserPasswordUpdtest', cronExp, new GenericPartnerPortalUserPasswordUpd());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
		*/
    }
    static testMethod void testGenericPartnerPortalUserPwdUpdMethods(){
        Test.startTest();
        // Test other methods ...
        //String schedulableString = GenericPartnerPortalUserPasswordUpd.scheduleIt();
        Test.stopTest();
    }
    
    static Config__c configData(String name,String value){
        return new Config__c(Name = name, Value__c = value);
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