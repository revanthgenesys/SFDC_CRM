/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class MarketplaceApplicationController_Test {
	
	static testMethod void preparePartnerApplcationDate(){
       String uniqueUserName = preparedRandomuserName();
         String orgId = UserInfo.getOrganizationId();
         List<String> userdisableList = new List<String>();
        MarketPlaceApplicationControllerHelper pachelper = new MarketPlaceApplicationControllerHelper();
        Test.startTest();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
        Test.stopTest();
        testUser = TestCommon.createUser('testU', uniqueUserName + '@test' + orgId + '.com', 'Test', 'Test', partnerProfile.id, false);     
        testUser.ContactId = testContact.id;
        insert testUser;
        userdisableList.add(testUser.id);
        
       Technology_Market_place_Application__c mpObj = new Technology_Market_place_Application__c();
      	mpObj.Are_any_deals_pending_execution__c = true;
      	mpObj.Average_deal_size__c = 12000;
      	mpObj.average_sales_cycle_to_close_a_deal__c = '1 Month';
      	mpObj.Describe_planned_end_user_pricing__c	= 'Test';
      	mpObj.Describe_the_point_of_Integration__c = 'test';
      	mpObj.Elevator_Pitch__c = 'test';
      	mpObj.Howmany_custmers_are_currently_piloting__c = 1;
      	Date todayDate = date.newInstance(2015,10,30);
      	mpObj.If_not_what_is_the_expected_GA_Date__c = todayDate;
      	//mpObj.If_not_what_is_the_expected_GA_Date__c = todayDate;
      	mpObj.Is_App_already_built_available_in_Prod__c = true;
      	mpObj.Is_your_sol_aimed_at_a_part_verticals__c = true;
      	mpObj.List_of_your_Top_prospects_deal_value__c = 'test';
      	mpObj.Partner_Account__c = testAccount.id;
      	mpObj.Please_Describe__c = 'test';
      	mpObj.Problem_Statement__c = 'test';
      	mpObj.Solution_Name__c = 'test';
      	mpObj.Status__c = 'In Progress';
      	mpObj.What_s_your_target_customer_company_size__c = 'Smb';
      	mpObj.What_currency_does_your_company_transact__c = 'USD';
      	insert mpObj;
        
        String queryString= MarketPlaceApplicationControllerHelper.prepareQuery(mpObj.id);
        MarketPlace_Competitor__c mpc = new MarketPlace_Competitor__c();
        mpc.Comments__c = 'test';
        mpc.Competitor__c = 'test';
        mpc.Technology_Market_place_Application__c = mpObj.Id;
        insert mpc;
        
        Licensed_User_Detail__c lu = new Licensed_User_Detail__c();
        lu.Describe_user_experience__c = 'test';
        lu.User_Profile__c = 'test'; 
        lu.Technology_Market_place_Application__c = mpObj.Id;
        insert lu;
        
        Genesys_Customer_Solution__c gcs = new Genesys_Customer_Solution__c();
        gcs.Customer_Name__c = 'test';
        gcs.Implementation__c = 'test';
        gcs.Time_in_Service__c = 12;
        gcs.Technology_Market_place_Application__c = mpObj.Id;
        insert gcs;
         
        
          List<MarketplaceApplicationController.wrapperCustomerSolution> customSolutions = new List<MarketplaceApplicationController.wrapperCustomerSolution>();
          MarketplaceApplicationController.wrapperCustomerSolution customSolution = new MarketplaceApplicationController.wrapperCustomerSolution();
          customSolution.index = 1;          
          customSolution.record = gcs;
          customSolutions.add(customSolution);
          
          List<MarketplaceApplicationController.wrapperCompetitors> competitors = new List<MarketplaceApplicationController.wrapperCompetitors>();
          MarketplaceApplicationController.wrapperCompetitors competitor = new MarketplaceApplicationController.wrapperCompetitors();
          competitor.index = 1;          
          competitor.record = mpc;
          competitors.add(competitor);
          
          
          List<MarketplaceApplicationController.wrapperLicensedUsers> licensedUsers = new List<MarketplaceApplicationController.wrapperLicensedUsers>();
          MarketplaceApplicationController.wrapperLicensedUsers licensedUser = new MarketplaceApplicationController.wrapperLicensedUsers();
          licensedUser.index = 1;          
          licensedUser.record = lu;
          licensedUsers.add(licensedUser);
          
          attachment att = new attachment();
          
          
          MarketPlaceApplicationControllerHelper.save(mpObj,testAccount,testContact,customSolutions,competitors,licensedUsers,0,att,false);
        	
    }
	   
   static testMethod void myUnitTest() {
        String uniqueUserName = preparedRandomuserName();
         String orgId = UserInfo.getOrganizationId();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1]; 
        //Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];      
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        System.debug('testContact-->'+testContact);
        User testUser;
        testUser = TestCommon.createUser('testU', uniqueUserName + '@test' + orgId + '.com', 'Test', 'Test', partnerProfile.id, false);     
        testUser.ContactId = testContact.Id;
        insert testUser;
        system.debug('test use---r'+[select Id, ContactId, Contact.AccountId from User where Id =: testUser.id]);
         system.debug('test use---r'+[select AccountId from Contact where Id =: testContact.id]);
        
        System.runAs(testUser){
         system.debug('test use---r'+[select AccountId from Contact where Id =: testContact.id]);	
         system.debug('user record --->'+[select ContactId,AccountId from User where Id =: testUser.id]);
      
      
        	
            ApexPages.currentPage().getParameters().put('new','true');
            MarketplaceApplicationController mpObj = new MarketplaceApplicationController();
            mpObj.newApplication.Are_any_deals_pending_execution__c = true;
	      	mpObj.newApplication.Average_deal_size__c = 12000;
	      	mpObj.newApplication.average_sales_cycle_to_close_a_deal__c = '1 Month';
	      	mpObj.newApplication.Describe_planned_end_user_pricing__c	= 'Test';
	      	mpObj.newApplication.Describe_the_point_of_Integration__c = 'test';
	      	mpObj.newApplication.Elevator_Pitch__c = 'test';
	      	mpObj.newApplication.Howmany_custmers_are_currently_piloting__c = 1;
	      	Date todayDate = date.newInstance(2015,10,30);
	      	mpObj.newApplication.If_not_what_is_the_expected_GA_Date__c = todayDate;
	      	//mpObj.If_not_what_is_the_expected_GA_Date__c = todayDate;
	      	mpObj.newApplication.Is_App_already_built_available_in_Prod__c = true;
	      	mpObj.newApplication.Is_your_sol_aimed_at_a_part_verticals__c = true;
	      	mpObj.newApplication.List_of_your_Top_prospects_deal_value__c = 'test';
	      	mpObj.newApplication.Partner_Account__c = testAccount.id;
	      	mpObj.newApplication.Please_Describe__c = 'test';
	      	mpObj.newApplication.Problem_Statement__c = 'test';
	      	mpObj.newApplication.Solution_Name__c = 'test';
	      	mpObj.newApplication.Status__c = 'In Progress';
	      	mpObj.newApplication.What_s_your_target_customer_company_size__c = 'Smb';
	      	mpObj.newApplication.What_currency_does_your_company_transact__c = 'USD'; 
	      	
	      	mpObj.licensedUsers[0].record.User_Profile__c = 'test';
	      	mpObj.licensedUsers[0].record.Describe_user_experience__c = 'test';
	      	
	      	mpObj.competitors[0].record.Comments__c = 'test';
	      	mpObj.competitors[0].record.Competitor__c = 'test';
	      	
	      	mpObj.customerSolution[0].record.Customer_Name__c = 'test';
	      	mpObj.customerSolution[0].record.Implementation__c = 'test';
	      	mpObj.customerSolution[0].record.Time_in_Service__c = 12;
	      	
	      	mpObj.addNewRowToLicensedUserList();
	      	mpObj.addNewRowToCompetitorList();
	      	mpObj.addNewRowTocustomerSolutionList();
	      	
	      	mpObj.rowToRemove = 0;
	      	mpObj.removeRowFromcustomerSolutionList();
	      	mpObj.removeRowFromCompetitorList();
	      	mpObj.removeRowFromLicensedUserList();
	      	
	      	//adding attachment
	      	Blob b = Blob.valueOf('Test Data');  
			mpObj.appFoundryAttachment[0].Name = 'Testing';  
			mpObj.appFoundryAttachment[0].Body = b;  
			mpObj.appFoundryAttachment[0].Description='Test';
			mpObj.step = 1;
			
	      	mpObj.save();
	      	mpobj.next();
	      	mpobj.submit();
            mpObj.cancelAction();
            mpObj.isApplicationAlreadySubmitted();
	      	mpObj.redirectToDetailPage();
            
            // Call methods from MarketPlaceApplicationControllerHelper for more Test coverage
            MarketPlaceApplicationControllerHelper.prepareQuery();
            MarketPlaceApplicationControllerHelper.prepareQuery(mpObj.newApplication.Id);
            MarketPlaceApplicationControllerHelper.deleteAttachment(mpObj.newApplication.Id);
            String cuProfile = MarketPlaceApplicationControllerHelper.getCurrentUserProfile();
            
            // Test the method from AppFoundryApplications
            AppFoundryApplicationsController afaController = new AppFoundryApplicationsController();
            afaController.displayDecision();
            afaController.getIsApplicationPending();
            afaController.newApplication();
			afaController.viewApplication();
			afaController.editApplication();
            
	    }
    }
    
    public static String preparedRandomuserName(){
        
         String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        return uniqueName;
        
    }
    
    
}