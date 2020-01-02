@isTest(seeAllData=true)
private class PartnerApplicationControllerTest {
    static testMethod void preparePartnerApplcationDate(){
        String uniqueUserName = preparedRandomuserName();
        String orgId = UserInfo.getOrganizationId();
        List<String> userdisableList = new List<String>();
        PartnerApplicationControllerHelper pachelper = new PartnerApplicationControllerHelper();
        Test.startTest();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal Potential Partner' LIMIT 1];       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
        Test.stopTest();
        testUser = TestCommon.createUser('testU', uniqueUserName + '@test' + orgId + '.com', 'Test', 'Test', partnerProfile.id, false);     
        testUser.ContactId = testContact.id;
        insert testUser;
        userdisableList.add(testUser.id);
        
        // Country__c countryObj = new Country__c(name='test country',CurrencyIsoCode = 'USD- U.S. Dollar',Country__c='test country');
        // insert countryObj;
        Country__c countryObj = [select id, name from country__c limit 1];
        
        
        Partner_Application__c paObj = new Partner_Application__c();
        paObj.X10_Ownership__c = true;
        paObj.Account__C = testAccount.id;
        paObj.X10_Ownership_Comments__c = 'this is test..';
        paObj.Anything_else_to_know_about_your_company__c = 'this is test';
        
        paObj.Applicant_s_organization__c = 'Test applicaiton ORganization';
        paObj.Appoint_Dismiss_Comments__c = ' Test Applicaiton dismiss comments.';
        paOBj.Approval_Status__c = 'In Review';
        paObj.Business_Consideration__c  = 'this is test business consideration';
        paObj.Business_Terms_and_Conditions__c = 'this is test business terms and condition.';
        paObj.Comments__c = 'this is test comments.';
        paObj.common_customers_with_Genesys__c = 'commong customers test..';
        paObj.Company_Core_Strength__c = 'test company core strength';
        paObj.Company_Lab_Locations__c = 'test company lab locations.';
        paObj.Company_Name__c = 'test Company Name';
        paObj.Company_Product_Overview__c  ='this is test product overview';
        paObj.Conflict_of_Interest__c = false;
        paObj.Conflict_of_Interest_Comments__c = null;
        paObj.Contact__c = testContact.id;
        paObj.Convicted_Executive__c =false;
        paObj.Convicted_Executive_Comments__c = null;
        paObj.Current_Genesys_Partner_Tier__c  = 'Silver';
        paObj.Current_Genesys_Partner_Type__c = 'Strategic';
        paObj.Current_or_Former_Genesys_Employee__c = true;
        paObj.Current_or_Former_Genesys_Employee_Comme__c = 'this is test employee comment';
        paObj.Date_Completed__c  = DateTime.Now();
        paObj.Do_you_want_to_integrate_to_Genesys_prod__c = false;
        paObj.formal_partnership_with_any_other_CTI__c ='yes';
        paObj.For_User__c = testUser.ID; //look up to user.
        paObj.Functioning_Genesys_Lab_Environment__c = 'Yes';
        paObj.Genesys_PS_benefit_from_a_partnership__c = 'this is test benfiet from partner';
        paObj.Genesys_Related_Services_Other__c = 'test services';
        paObj.Gensys_Sponsor__c = 'test sponser';
        paObj.Government_Dismiss__c = false;
        paObj.Government_Dismiss_Comments__c = null;
        paObj.If_yes_please_list_their_names_CTI__c = 'test cti name';
        paObj.Is_Legal_Rejected__c = false;
        paObj.Is_PS_Rejected__c = false;
        paObj.List_Common_Customer__c = 'test common customer';
        paObj.List_Industries_and_Vertical_Markets__c = 'test Industries and vertical marets.';
        paObj.List_Of_Comany_s_references__c = 'test company referece';
        paObj.List_other_Contact_Center__c = 'this is test contact center';
        paObj.List_Other_Partner_Programs__c= 'test partner programs';
        paObj.NDA_Approver_Name__c = 'test NDA';
        paObj.Partner_Description__c ='test description';
        paObj.Primary_Contact__c = testContact.id;
        
        paObj.AnnualSalesRevenue_PL__c = 'No';
        paObj.Ownership_PL__c = 'No';
        paObj.RightToAppointOrDismiss_PL__c = 'No';
        paObj.AppointOrDismissMD_PL__c = 'No';
        paObj.Government_Veto_PL__c = 'No';
        paObj.PublicInternationalOrg_PL__c = 'No';
        paObj.Convicted_Executive_PL__c = 'No';
        paObj.BannedEmployee_PL__c = 'No';
        paObj.ExportEnforcementActivity_PL__c = 'No';
        paObj.CountryCurrentlyUnderUS_PL__c = 'No';
        paObj.Conflict_of_Interest_PL__c = 'No';
        paObj.Current_or_Former_Genesys_Employee_PL__c = 'No';
        
        paObj.Status__c = 'In Progress';
        insert paObj;
        
        
        //to increase the code coverage.
        String queryString= PartnerApplicationControllerHelper.prepareQuery(paObj.id);
        Executive_Management_Team__c emt = new Executive_Management_Team__c();
        emt.name = 'test management 1';
        emt.Position__c = 'test Positon';
        emt.Partner_Application__c = paObj.id;
        emt.Email__c = 'testemail@executive.com';
        insert emt;
        
        Executive_Management_Team__c emt2 = new Executive_Management_Team__c();
        emt2.name = 'test management 2';
        emt2.Position__c = 'test Positon';
        emt2.Partner_Application__c = paObj.id;
        emt2.Email__c = 'testemail2@executive.com';
        insert emt2;
        
        
        Company_Ownership__c cowshp = new Company_Ownership__c();
        cowshp.Name = 'test Ownership';
        cowshp.Ownership__c= 10.0;
        cowshp.Partner_Application__c = paObj.id;
        cowshp.Person_Firm__c = 'test firm';
        insert cowshp;
        
        Company_Ownership__c cowshp2 = new Company_Ownership__c();
        cowshp2.Name = 'test Ownership 2';
        cowshp2.Ownership__c= 10.0;
        cowshp2.Partner_Application__c = paObj.id;
        cowshp2.Person_Firm__c = 'test firm';
        insert cowshp2;
        
        Partner_Application_Summary_Rate__c  pasr= new Partner_Application_Summary_Rate__c();
        pasr.Name= 'test summary rats';
        pasr.Comments__c = 'test comments';
        pasr.Currency_Type__c = 'USD';
        pasr.Partner_Application__c = paObj.id;
        pasr.Rate_or_Rate_Range__c = 'test rrange';
        pasr.Resource_or_Skill_Type__c = 'test resource skill tppe';
        insert pasr;
        
        Partner_Application_Summary_Rate__c  pasr2 = new Partner_Application_Summary_Rate__c();
        pasr2.Name= 'test summary rats 2';
        pasr2.Comments__c = 'test comments';
        pasr2.Currency_Type__c = 'USD';
        pasr2.Partner_Application__c = paObj.id;
        pasr2.Rate_or_Rate_Range__c = 'test rrange';
        pasr2.Resource_or_Skill_Type__c = 'test resource skill tppe';
        insert pasr2;
        
        
        Partner_Application_Head_Count__c pahc = new Partner_Application_Head_Count__c();
        pahc.Name = 'test head count';
        pahc.Development_Team__c = 10;
        pahc.Partner_Application__c =  paObj.id;
        pahc.Professional_Services__c =10;
        pahc.Project_Management__c = 10;
        pahc.Technical_Support_Team__c =100;
        pahc.Total_Headcount__c = 110;
        
        insert pahc;
        
        Partner_Application_Head_Count__c pahc2 = new Partner_Application_Head_Count__c();
        pahc2.Name = 'test head count 2';
        pahc2.Development_Team__c = 10;
        pahc2.Partner_Application__c =  paObj.id;
        pahc2.Professional_Services__c =10;
        pahc2.Project_Management__c = 10;
        pahc2.Technical_Support_Team__c =100;
        pahc2.Total_Headcount__c = 110;
        
        insert pahc2;
        
        
        Partner_Application_Employee_Info__c paei =new Partner_Application_Employee_Info__c();
        paei.Certification_Name__c = 'sfdc admin';
        paei.Employee_Name__c = 'test employee';
        paei.Partner_Application__c =  paObj.id;
        paei.Resource_Country_of_Residence__c = 'USA';
        paei.Year_Aheived__c = system.today()-100;
        insert paei;
        
        
        Partner_Application_Employee_Info__c paei2 =new Partner_Application_Employee_Info__c();
        paei2.Certification_Name__c = 'sfdc admin';
        paei2.Employee_Name__c = 'test employee 2';
        paei2.Partner_Application__c =  paObj.id;
        paei2.Resource_Country_of_Residence__c = 'USA';
        paei2.Year_Aheived__c = system.today()-100;
        insert paei2;
        
        List<PartnerApplicationController.wrapperExecMgmtList> execMgmtTeam = new List<PartnerApplicationController.wrapperExecMgmtList>();
        
        PartnerApplicationController.wrapperExecMgmtList wrapperExecMgmt = new PartnerApplicationController.wrapperExecMgmtList();
        wrapperExecMgmt.index = 1;          
        wrapperExecMgmt.record = emt;
        execMgmtTeam.add(wrapperExecMgmt);
        wrapperExecMgmt.index = 2;          
        wrapperExecMgmt.record = emt2;
        execMgmtTeam.add(wrapperExecMgmt);
        
        List<PartnerApplicationController.wrapperCompanyOwnershipList> companyOwnershipList =new List<PartnerApplicationController.wrapperCompanyOwnershipList>();
        PartnerApplicationController.wrapperCompanyOwnershipList pcos = new PartnerApplicationController.wrapperCompanyOwnershipList();
        pcos.record = cowshp;
        pcos.index = 1;  
        companyOwnershipList.add(pcos);
        pcos.record = cowshp2;
        pcos.index = 2;  
        companyOwnershipList.add(pcos);
        
        List<PartnerApplicationController.WrapperpaSummaryRatesList> appsummaryRateList =new List<PartnerApplicationController.WrapperpaSummaryRatesList>();
        PartnerApplicationController.WrapperpaSummaryRatesList appsum = new PartnerApplicationController.WrapperpaSummaryRatesList();
        appsum.record = pasr;
        appsum.index = 1;  
        appsummaryRateList.add(appsum);
        appsum.record = pasr2;
        appsum.index = 2;  
        appsummaryRateList.add(appsum);
        
        
        List<Partner_Application_Head_Count__c> list_PAHeadCount =new List<Partner_Application_Head_Count__c>();
        list_PAHeadCount.add(pahc) ;
        list_PAHeadCount.add(pahc2) ;
        
        
        List<PartnerApplicationController.WrapperpaEmployeeList> paEmployeeList =new List<PartnerApplicationController.WrapperpaEmployeeList>();
        PartnerApplicationController.WrapperpaEmployeeList paEmployee = new PartnerApplicationController.WrapperpaEmployeeList();
        paEmployee.record = paei;
        appsum.index = 1;  
        paEmployeeList.add(paEmployee);
        paEmployee.record = paei2;
        appsum.index = 2;  
        paEmployeeList.add(paEmployee);
        
        List<Partner_Application_Category_and_Country__c> paccList = new List<Partner_Application_Category_and_Country__c>();
        Partner_Application_Category_and_Country__c pacObj1 = new Partner_Application_Category_and_Country__c();
        
        pacObj1.Approval_Status__c = 'TEST';
        pacObj1.Category__c = 'Cloud Reseller';
        pacObj1.Comments__c = 'this is test comments.';
        pacObj1.Country__c = countryObj.id; // lookup to country;
        pacObj1.Partner_Application__c = paObj.id;
        pacObj1.PlatformType__c = 'PureConnect';
        pacObj1.RC__c = testUser.id;
        
        Partner_Application_Category_and_Country__c pacObj2 = new Partner_Application_Category_and_Country__c();
        
        pacObj2.Approval_Status__c = 'TEST';
        pacObj2.Category__c = 'Specialized Reseller';
        pacObj2.Comments__c = 'this is test comments.';
        pacObj2.Country__c = countryObj.id;// lookup to country;
        pacObj2.Partner_Application__c = paObj.id;
        pacObj2.RC__c = testUser.id;
        
        paccList.add(pacObj1);          
        paccList.add(pacObj2);
        
        insert paccList;
        
        
        List<PartnerApplicationController.wrapperCategoryAndCountryList> categoryAndCountry= new List<PartnerApplicationController.wrapperCategoryAndCountryList>();

        Partner_Application_Category_and_Country__c pacObj3 = new Partner_Application_Category_and_Country__c();
        pacObj3.Category__c = 'Cloud Reseller';
        pacObj3.Country__c = countryObj.id; // lookup to country;
        
        Partner_Application_Category_and_Country__c pacObj4 = new Partner_Application_Category_and_Country__c();
        pacObj4.Category__c = 'Specialized Reseller';
        
        PartnerApplicationController.wrapperCategoryAndCountryList testWAC1 = new PartnerApplicationController.wrapperCategoryAndCountryList();
        testWAC1.record = pacObj3;
        testWAC1.list_SelectedCountries.add(new SelectOption(countryObj.Id,countryObj.Name) );
        categoryAndCountry.add(testWAC1);

        PartnerApplicationController.wrapperCategoryAndCountryList testWAC2 = new PartnerApplicationController.wrapperCategoryAndCountryList();
        testWAC2.record = pacObj4;
        testWAC2.list_SelectedCountries.add(new SelectOption(countryObj.Id,countryObj.Name) );
        categoryAndCountry.add(testWAC2);

        PartnerApplicationController.wrapperCategoryAndCountryList testWAC3 = new PartnerApplicationController.wrapperCategoryAndCountryList();
        testWAC3.record = pacObj4;
        testWAC3.list_SelectedCountries.add(new SelectOption(countryObj.Id,countryObj.Name) );
        categoryAndCountry.add(testWAC3);
        
        PartnerApplicationControllerHelper.save(paObj,testAccount,testContact,execMgmtTeam,companyOwnershipList,categoryAndCountry,appsummaryRateList,list_PAHeadCount,paEmployeeList);
        PartnerPortalUtil.blnIgnoreDeleteTrigger = true;
        System.runAs(testUser){
            PartnerApplicationController obj = new PartnerApplicationController();
            obj.save();
            obj.next();
            obj.actionYes();
            // obj.step = 3;
            obj.next();
            
            
            obj.calculateHeadCount();
            obj.addSummaryRatesRows();
            obj.partnerChagne();
        }
    }
    
    static testMethod void testApprove() {
        String uniqueUserName = preparedRandomuserName();
        String orgId = UserInfo.getOrganizationId();
        Test.startTest();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1]; 
        //Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];      
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
        Test.stopTest();
        testUser = TestCommon.createUser('testU', uniqueUserName + '@test' + orgId + '.com', 'Test', 'Test', partnerProfile.id, false);
       
        testUser.Allow_Potential_Partner_to_Reapply__c = true;
        testUser.ContactId = testContact.id;
        insert testUser;
        System.runAs(testUser){
            ApexPages.currentPage().getParameters().put('new','true');
            PartnerApplicationController obj = new PartnerApplicationController();
            obj.newApplication.Services_Partner_as_Subcontractor__c = true;
            obj.newApplication.Company_Name__c = 'Test Company';            
            obj.redirectToDetailPage();
            obj.save();
            obj.actionYes();
            obj.actionNo();
            obj.next();
            obj.previous();
            obj.submit();
            //obj.approve();
            //obj.reject();
            obj.cancel();
            obj.addNewRowToExecMgmtTeamList();
            obj.addNewRowToCompanyOwnershipList();
            obj.addNewRowToCategoryAndCountryList();
            obj.addNewRowToCategoryAndCountryList();
            
            obj.rowToRemove = 1;
            
            obj.removeRowFromCategoryAndCountryList();
            obj.actionCreate();
            obj.cancelApplication();
            
            
            obj.removeRowFromExecMgmstTeamList();
            obj.removeRowFromCompanyOwnershipList();
            obj.addNewRowToEmployeeList();
            obj.addNewRowToEmployeeList();
            
            obj.removeRowFromEmployeeList();
            
            obj.addNewRowToSummaryRatesList();
            obj.addNewRowToSummaryRatesList();
            obj.removeRowFromAppsumaryList();
            obj.approve();
        }
    }
    
    static testMethod void testReject() {
        String uniqueUserName = preparedRandomuserName();
        String orgId = UserInfo.getOrganizationId();
        Test.startTest();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1]; 
        //Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];      
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
        Test.stopTest();
        testUser = TestCommon.createUser('testU', uniqueUserName + '@test' + orgId + '.com', 'Test', 'Test', partnerProfile.id, false);
       
        testUser.Allow_Potential_Partner_to_Reapply__c = true;
        testUser.ContactId = testContact.id;
        insert testUser;
        System.runAs(testUser){
            ApexPages.currentPage().getParameters().put('new','true');
            PartnerApplicationController obj = new PartnerApplicationController();
            obj.newApplication.Services_Partner_as_Subcontractor__c = true;
            obj.newApplication.Company_Name__c = 'Test Company';            
            obj.redirectToDetailPage();
            obj.save();
            obj.actionYes();
            obj.actionNo();
            obj.next();
            obj.previous();
            obj.submit();
            obj.cancel();
            obj.reject();
        }
    }
    
    public static  String preparedRandomuserName(){
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        return uniqueName;
        
    }
}