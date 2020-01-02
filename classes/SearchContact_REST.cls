//Ravi V    10/31/2013
//Naresh Kumar      08/09/2013
global without sharing class SearchContact_REST 
{

       webService static String searchContact(String email) 
       {
        List<String> contactURLs = new List<String>();
        List<String> leadURLs = new List<String>();
        List<Contact> resContacts = [SELECT id FROM Contact WHERE email =: email];
        List<Lead> resLeads = [SELECT id FROM Lead WHERE email =: email];
        //Common
        //11082013 Suman hard code, don't use base url as it is returning site url
        String baseURL = 'https://genesys.my.salesforce.com'; //URL.getSalesforceBaseUrl().toExternalForm();
         
        String jsonItems = ''; 
        String jsonLeads = '';
        String stleads='';
        String stcontacts='';
        String jsonSTR='';
       for(Contact eachContact : resContacts)
        {
            String url = baseURL+'/'+eachContact.id;
            jsonItems +=   '{ "-value": "'+ url +'" },';  
                      
        }
        for(Lead eachLead : resLeads)
        {
            String url = baseURL+'/'+eachLead.id;
            jsonLeads +=   '{ "-value": "'+ url +'" },';           
        }
        
        if(jsonItems != '' || jsonLeads != '')
        {
         if(jsonLeads != '')
        {
         jsonLeads = jsonLeads.substring(0, jsonLeads.length() - 1);    
          stleads= '\"leadurls\": {'
                                + '\"url\": [' +
                                jsonLeads
                              + ']'
                                + '}';
        }
        if(jsonItems != '')
        {
         jsonItems = jsonItems.substring(0, jsonItems.length() - 1);
         
         stcontacts= '{\"contacturls\": {'
                                + '\"url\": [' +
                                jsonItems
                              + ']'
                                + '}';
         
         }
         if(jsonLeads != '' && jsonItems != '')
         {
          jsonSTR = '{'+ '"JSON": '
                        + stcontacts+','+stleads +'}}';
         }
            if(jsonItems != '' && jsonLeads=='')
            {
             jsonSTR = '{'
                        + '"JSON":'+ stcontacts+ '}}';
            }        
          if(jsonLeads != '' && jsonItems=='')
            {
             jsonSTR = '{'
                        + '"JSON":{'+ stleads+ '}}' ;
            }  
       
        
         }     
        return jsonSTR;
       }  
       
       
     public static testMethod void testRunAs() 
     {   
      Config__c  mycs1 = new  Config__c(Name= 'CORE_OPP_STAGE_CLOSED_WON',Value__c = '8-Closed Won');
       insert mycs1; 
       Config__c  mycs2 = new  Config__c(Name= 'USER_PARTNER',Value__c = 'PowerPartner');
       insert mycs2; 
       Config__c  mycs3 = new  Config__c(Name= 'USER_STANDARD',Value__c = 'Standard');
       insert mycs3; 
       Config__c  mycs4 = new  Config__c(Name= 'CORE_OPP_BP_STATUS_ALLOCATED',Value__c = 'Allocated');
       insert mycs4;
             
        Config__c  mycs5 = new  Config__c(Name= 'ALE_TEAM_MEMBER_ROLE',Value__c = 'Sales Manager');
       insert mycs5; 
        
        Config__c  mycs6 = new  Config__c(Name= 'CORE_OPP_BP_STATUS_REJECTED',Value__c = 'Sales Manager');
       insert mycs6;
       
       Config__c  mycs7 = new  Config__c(Name= 'CORE_OPP_BP_STATUS_REJECTED',Value__c = 'Rejected');
       insert mycs7;
       
       Config__c  mycs8 = new  Config__c(Name= 'BP_TEAM_MEMBER_ROLE',Value__c = 'Channel Manager');
       insert mycs8; 
       
       Config__c  mycs9 = new  Config__c(Name= 'CORE_OPP_BP_STATUS_NOT_ALLOCATED',Value__c = 'Not Allocated');
       insert mycs9;  
       
       Config__c  mycs10 = new  Config__c(Name= 'CORE_OPP_BP_STATUS_APPROVED',Value__c = 'Accepted');
       insert mycs10;
       
       Config__c  mycs12 = new  Config__c(Name= 'TM_MONITOR_AD_EMAIL2',Value__c = 'fabien.jonot@kerensen.com');
       insert mycs12;
       
       Config__c  mycs11 = new  Config__c(Name= 'TM_MONITOR_AD_EMAIL1',Value__c = 'michael.legrand@kerensen.com');
       insert mycs11;
       
       Config__c  mycs13 = new  Config__c(Name= 'TM_MONITOR_AD_EMAIL3',Value__c = 'didier.comte@alcatel-lucent.fr');
       insert mycs13; 
        
        Config__c  mycs14 = new  Config__c(Name= 'TM_VALUE_SEPARATOR',Value__c = ';');
       insert mycs14;
       
       Config__c  mycs15 = new  Config__c(Name= 'TM_USER_NAME_TEST1',Value__c = 'Sébastien AGATHON');
       insert mycs15;
       
       Config__c  mycs16 = new  Config__c(Name= 'TM_USER_NAME_TEST2',Value__c = 'Bernhard Hoefling RSM');
       insert mycs16; 
       
        
        Config__c  mycs17 = new  Config__c(Name= 'ASSET_DEFAULT_MANUFACTURER',Value__c = 'ALCATEL-LUCENT');
       insert mycs17;
       
       Config__c  mycs18 = new  Config__c(Name= 'CORE_OpportunityApprovalProcess',Value__c = '012U0000000LdbB');
       insert mycs18;
       
       Config__c  mycs19 = new  Config__c(Name= 'EMGBusinessPartnerRecordType',Value__c = '012U0000000Le3f');
       insert mycs19;
       
       Config__c  mycs20 = new  Config__c(Name= 'EMGBusinessPartnerOwner',Value__c = 'Business Partner Owner');
       insert mycs20;
       
       Config__c  mycS21 = new  Config__c(Name= 'EMGStatusGetRejected',Value__c = 'Rejected');
       insert mycs21;
       
       Config__c  mycs22 = new  Config__c(Name= 'RT_RFP_Refused',Value__c = '012U0000000Ldii');
       insert mycs22;
       Config__c  mycs23 = new  Config__c(Name= 'RT_RFP_Accepted',Value__c = '012U0000000Ldih');
       insert mycs23;
       Config__c  mycs24 = new  Config__c(Name= 'RT_RFP_PROPOSAL_ACCEPTED',Value__c = 'RFP_Form_Proposal_Accepted_Record_Type');
       insert mycs24;
       
       Config__c  mycs25 = new  Config__c(Name= 'RT_RFP_PROPOSAL_REFUSED',Value__c = 'RFP_Form_Proposal_Refused_Record_Type');
       insert mycs25;
       Config__c  mycs26 = new  Config__c(Name= 'ACCEPTED_RFP_FORM_TEMPLATE',Value__c = 'Accepted_RFP_Form');
       insert mycs26;
       
       Config__c  mycs27 = new  Config__c(Name= 'REJECTED_RFP_FORM_TEMPLATE',Value__c = 'Rejected_RFP_Form');
       insert mycs27;
       
       Config__c  mycs28 = new  Config__c(Name= 'SUBMIT_RFP_FORM_TEMPLATE',Value__c = 'Submit_RFP_Form');
       insert mycs28;
       Config__c  mycs29 = new  Config__c(Name= 'PENDING_RFP_FORM_TEMPLATE',Value__c = 'Pending_RFP_Form');
       insert mycs29;
       
       Config__c  mycs30 = new  Config__c(Name= 'INACTIVE_OFFER',Value__c = 'Inactive');
       insert mycs30;
       
       Config__c  mycs31 = new  Config__c(Name= 'ACTIVE_OFFER',Value__c = 'Active');
       insert mycs31;
       
       Config__c  mycs32 = new  Config__c(Name= 'REGION_EMEA',Value__c = 'EMEA');
       insert mycs32;
       
       Config__c  mycs33 = new  Config__c(Name= 'BID_PROPOSAL_CONTACT_EMEA',Value__c = 'Bid And Proposal EMEA');
       insert mycs33;
       
       Config__c  mycs34 = new  Config__c(Name= 'BID_PROPOSAL_CONTACT_NA',Value__c = 'Bid And Proposal NA');
       insert mycs34;
       Config__c  mycs35 = new  Config__c(Name= 'RFP_QUEUE',Value__c = 'GEN-RFP-NA');
       insert mycs35;
       
       Config__c  mycs36 = new  Config__c(Name= 'RFP_MAIL',Value__c = 'Submit_RFP_Form');
       insert mycs36;
       
       Config__c  mycs37 = new  Config__c(Name= 'RT_OQM_Submission',Value__c = 'OQMRefused');
       insert mycs37;
       
       Config__c  mycs38 = new  Config__c(Name= 'RT_RFP_Submission',Value__c = '012U0000000Ldij');
       insert mycs38;
       
       Config__c  mycs39 = new  Config__c(Name= 'RT_OQM_PROPOSAL_ACCEPTED',Value__c = 'OQM_Form_Proposal_Accepted_Record_Type');
       insert mycs39;
       
       Config__c  mycs40 = new  Config__c(Name= 'RT_OQM_PROPOSAL_REFUSED',Value__c = 'OQM_Form_Proposal_Refused_Record_Type');
       insert mycs40;
       
       Config__c  mycs41 = new  Config__c(Name= 'OQM_STATUS_PENDING',Value__c = 'Pending_OQM_Form');
       insert mycs41;
       
       Config__c  mycs42 = new  Config__c(Name= 'OQM_STATUS_SUBMIT',Value__c = 'Submit_OQM_Form');
       insert mycs42;
       
       Config__c  mycs43 = new  Config__c(Name= 'OQM_STATUS_REJECTED',Value__c = 'Rejected_OQM_Form');
       insert mycs43;
       Config__c  mycs44 = new  Config__c(Name= 'OQM_STATUS_ACCEPTED',Value__c = 'Accepted_OQM_Form');
       insert mycs44;
       Config__c  mycs45 = new  Config__c(Name= 'OPP_STAGE4',Value__c = '4-Offer Made');
       insert mycs45;
       
       Config__c  mycs46 = new  Config__c(Name= 'OPP_STAGE5',Value__c = '5-Short List');
       insert mycs46;
       
       Config__c  mycs47 = new  Config__c(Name= 'OPP_STAGE6',Value__c = '6-Price Negotiation');
       insert mycs47;
       
       Config__c  mycs48 = new  Config__c(Name= 'OPP_STAGE7',Value__c = '7-ALU Selected');
       insert mycs48;
       
       Config__c  mycs49 = new  Config__c(Name= 'OPP_STAGE81',Value__c = '8-Closed Lost');
       insert mycs49;
       
       Config__c  mycs50 = new  Config__c(Name= 'OPP_STAGE82',Value__c = '8-Closed Won');
       insert mycs50;
       
       Config__c  mycs51 = new  Config__c(Name= 'OPP_STAGE9',Value__c = '9-Closed Cancelled');
       insert mycs51;
       
       Config__c  mycs52 = new  Config__c(Name= 'OPP_STAGE10',Value__c = '9-Closed Cancelled');
       insert mycs52;
       
        Config__c  mycs53 = new  Config__c(Name= 'BP_ROLE',Value__c = 'Business Partner Owner');
       insert mycs53;
       
       Config__c  mycs54 = new  Config__c(Name= 'PROFIL_ADMIN_ID',Value__c = '00eU0000000pPrr');
       insert mycs54;
       Config__c  mycs55 = new  Config__c(Name= 'COREOpportunityRecordType',Value__c = '012U0000000Ldb8');
       insert mycs55;
       
               
      RecordType rType = [SELECT id, Name FROM RecordType WHERE Name = 'Group Account - Customer' LIMIT 1];
        List<Account> testAccounts = TestUtil.createAccounts(2, false);
        testAccounts[0].RecordTypeId = rType.id;
        testAccounts[0].Status__c = 'Active';
        testAccounts[0].Name = 'Test Group Account 1';
        testAccounts[1].Name = 'Holding Account';
        insert testAccounts;
        List<Contact> testContacts = TestUtil.createContacts(2, testAccounts[0], false);
        testContacts[1].AccountId = testAccounts[1].id;
        insert testContacts;
        testContacts[1].AddToEmailDomain__c = true;
        testContacts[1].AccountId = testAccounts[0].id;
        update testContacts;
        String sts= SearchContact_REST.searchContact('ravikiranreddyv@gmail.com');

        }
     
}