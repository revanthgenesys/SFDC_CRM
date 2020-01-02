@isTest
private class GuManageNewContactsTest {

    	
    static  testmethod void testGuManageNewContacts() {
		creatConfigData();
        
        Account acc = new Account (Name = 'Holding Account',RecordTypeId='012U0000000Le3f',Status__c='Active', SAP_Account_Code__c = '12345');  
        insert acc;
        
        Contact cont = new Contact (AccountId = acc.id,FirstName='TestContact',LastName = 'Foss',Designated_Partner_Contact__c = true, email = 'test0000@test.com');
        insert cont;
        
        List<GU_New_Contact__c> guNewContactsList = new List<GU_New_Contact__c>();

        // Add unprocessed existing contact
        guNewContactsList.add(new GU_New_Contact__c(Email__c = 'test0000@test.com', FirstName__c = 'FN 0000', LastName__c = 'LN 0000', 
                                                    GARN__c = '12345', Processed__c = false, ViewCentral_ID__c = '12345', Account__c = acc.Id));

		// Add unprocessed non existing contacts for matching account        
        for(Integer i=1; i <= 100; i++){
            guNewContactsList.add(new GU_New_Contact__c(Email__c = 'test'+i+'@test.com', FirstName__c = 'FN '+i, LastName__c = 'LN ' +i,
														GARN__c = '12345', Processed__c = false, ViewCentral_ID__c = '12345', Account__c = acc.Id));
            
        }        
        //  Add Processed contacts
        for(Integer i=101; i <= 200; i++){
            guNewContactsList.add(new GU_New_Contact__c(Email__c = 'test'+i+'@test.com', FirstName__c = 'FN '+i, LastName__c = 'LN ' +i,
														GARN__c = '12345', Processed__c = true, ViewCentral_ID__c = '12345', Account__c = acc.Id));
            
        }        
        
        insert guNewContactsList;
        
        Test.startTest();
        Test.setCurrentPage(Page.GUManageNewContacts);
        GuManageNewContactsController controller  = new GuManageNewContactsController();
    	
        
        // *** Unprocessed GU Contacts Pagination tests
        // Get the flags for the first that is when you are on first page
        controller.getDisableUnproPrevious();
        controller.getDisableUnproNext();
		controller.getDisableUnproFirst();
        controller.getDisableUnproLast();
		
        // Click on next page button 
		controller.unproNextBtnClick();

        // Get the flags for the first that is when you are on first page
        controller.getDisableUnproPrevious();
        controller.getDisableUnproNext();
		controller.getDisableUnproFirst();
        controller.getDisableUnproLast();

        // Click on last page button 
        controller.unproLastBtnClick();

        // Get the flags for the first that is when you are on first page
        controller.getDisableUnproPrevious();
        controller.getDisableUnproNext();
		controller.getDisableUnproFirst();
        controller.getDisableUnproLast();

        // Click on previous button and then first button        
		controller.unproPreviousBtnClick();
        controller.unproFirstBtnClick();
            
        
        // Test Business Logic Methods for Create new contact and update existing contact
        System.currentPageReference().getParameters().put('selectedGU', guNewContactsList[0].id);
		System.currentPageReference().getParameters().put('selectedAccount', '');
		System.currentPageReference().getParameters().put('selectedContact', cont.Id);
        
        controller.getSelected();
        controller.updateContact();

        System.currentPageReference().getParameters().put('selectedGU', guNewContactsList[1].id);
		System.currentPageReference().getParameters().put('selectedAccount', acc.Id);
		System.currentPageReference().getParameters().put('selectedContact', '');

        controller.getSelected();
        controller.createContact();
        
        controller.back();
        
		// *** Processed GU Contacts Pagination tests
       	// Get the flags for the first that is when you are on first page
        controller.getDisableProPrevious();
        controller.getDisableProNext();
		controller.getDisableProFirst();
        controller.getDisableProLast();
		
        // Click on next page button 
		controller.proNextBtnClick();

        // Get the flags for the first that is when you are on first page
        controller.getDisableProPrevious();
        controller.getDisableProNext();
		controller.getDisableProFirst();
        controller.getDisableProLast();

        // Click on last page button 
        controller.proLastBtnClick();

        // Get the flags for the first that is when you are on first page
        controller.getDisableProPrevious();
        controller.getDisableProNext();
		controller.getDisableProFirst();
        controller.getDisableProLast();

        // Click on previous button and then first button        
		controller.proPreviousBtnClick();
        controller.proFirstBtnClick();		 
		
        Test.stopTest();
    }
    
	static Config__c configData(String name,String value){
        
        Config__c config = new Config__c();
        config.Name = name;
        config.Value__c = value;
        return config;
    }
    
    static void creatConfigData(){
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