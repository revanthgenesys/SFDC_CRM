@isTest (seeAllData= true)
private class Test_DownloadsControllers {
	
	static testMethod void testDownloadsCD() {
		
		 Util.Bypass_Trigger_Chk = true;

        Support_Product__c prod = new Support_Product__c(Product_Type__c = 'Product',Customer_Available__c = true,Active__c = true); 
        insert prod;
        Support_Product__c comp = new Support_Product__c(Product_Type__c = 'Component',Customer_Available__c = true,Active__c = true);
        insert comp;
    
        Software_Download__c swDet = new Software_Download__c(name='sw');
        swDet.File_Type__c ='CD';
        swDet.Major_Release__c = '8.1.3';
        swDet.Product__c = prod.Id;
        swDet.Localization__c = 'ENU';
        swDet.Version__c = '8.1.0';
        swDet.Operating_Systam__c = 'Windows';
		insert swDet;
		
        Account acc = TestUtil.createAccounts(1, true)[0];
        Contact cont = TestUtil.createContacts(1, acc, true)[0];
        
        //Support_Access__c supaccs = TestUtil.createSupportAccess(1, true, cont)[0];
        
        Back_Office_Account__c boa = new Back_Office_Account__c(Sold_To_Account__c = acc.Id, Platform__c = 'PureEngage on Premise',Contract_Status__c = 'Active',
                                                             End_User_Account__c = acc.Id);
        insert boa;
        
        Support_Access__c supaccs = new Support_Access__c (Contact__c = cont.Id, Back_Office_Account__c = boa.Id, Status__c ='Active', SR_Access_Level__c = 'Read/Write');
        insert supaccs;   
 
        Profile prof = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    		
        User testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prof.id, false);    	
		testUser.ContactId = cont.id;
		testUser.isactive = true;
		testUser.Bypass_Triggers__c = true;
		testUser.BypassValidationRules__c = true;
		testUser.BypassWorkflows__c = true;
		insert testUser;
		
      System.runAs(testUser)  {
            //Pagereference pg = Page.DowloadsTabInternal;  
            //Test.setCurrentPageReference(pg);
              
            ApexPages.currentPage().getParameters().put('isDloadTypeCD', 'true');
                
            DownloadsController dc = new DownloadsController();		
            dc.currentCase.Sold_To_Account__c = acc.Id;
            dc.currentCase.End_User_Account__c = acc.Id;
            
            dc.conId = cont.Id;
            dc.setContact();
            dc.isDloadTypeCD = true;
            dc.selectedProduct = prod.Id;
            dc.selectedComponent = comp.Id;
            dc.selectedMajorRelease ='8.1.3';
            dc.selectedLanguage = 'ENU';
            dc.selectedOSVersion = 'All';
            dc.selectedProductVersion = 'All';
            dc.version='8.0';
            dc.lang ='ENU';
            dc.mjrRlease = '8.0';
            dc.acceptTnc = true;            
            dc.populateFields();
            
            dc.selectedProduct = null;
            dc.populateAllOnProdChange();
            
            dc.closeTNC();
            dc.closeNTNC();
            dc.next();
            dc.previous();
            
            String q = dc.query2;
            String f = dc.fields;
            
            DownloadsControllerExtension dext = new DownloadsControllerExtension(dc);		
         
           MockHttpResponseSwDownloads testMock = new MockHttpResponseSwDownloads();              
	        Test.setMock(HttpCalloutMock.class, testMock);
            
            dext.swdLoadId = swDet.Id;
            dext.gtDload();
            
            DownloadController dlc = new DownloadController();
            dlc.isPremiseUser = true;
            dlc.dltype = 'CD';
            
            dc.endUserName = '';
            dc.setContact();
		}
	}
    
    static testMethod void testDownloadsIP() {
    	
    	 Util.Bypass_Trigger_Chk = true;
		
        Support_Product__c prod = new Support_Product__c(Product_Type__c = 'Product',Customer_Available__c = true,Active__c = true); 
        insert prod;
        Support_Product__c comp = new Support_Product__c(Product_Type__c = 'Component',Customer_Available__c = true,Active__c = true);
        insert comp;
    
        Software_Download__c swDet = new Software_Download__c(name='sw');
        swDet.File_Type__c ='IP';
        swDet.Major_Release__c = '8.1.3';
        swDet.Product__c = prod.Id;
        swDet.Localization__c = 'ENU';
        swDet.Version__c = '8.1.0';
        swDet.Operating_Systam__c = 'Windows';
		insert swDet;
              
        Account acc = TestUtil.createAccounts(1, true)[0];
        Country__c country = new Country__c(name='United States', SW_Download_Site__c = 'USA', Country__c='United States');
        insert country;
        Subsidary__c subs = new Subsidary__c(name='Subsidary');
    	insert subs; 
        acc.Country__c = country.Id;
        acc.Subsidary__c = subs.Id;
        update acc;
        
        Id profileId = [Select Id from profile where name LIKE 'Genesys Portal End User%' LIMIT 1].Id;      
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	User usr = TestCommon.createUser('testU', 'testUser55@test55.com.test', 'Test1', 'Test1', profileId, false);    	
    	usr.ContactId = testContact.Id;
    	usr.Bypass_Triggers__c = true;
		usr.BypassValidationRules__c = true;
		usr.BypassWorkflows__c = true;
    	insert usr;
    	
    	 Back_Office_Account__c boa = new Back_Office_Account__c(Sold_To_Account__c = acc.Id, Platform__c ='PureEngage on Premise',Contract_Status__c = 'Active',
                                                             End_User_Account__c = acc.Id);
        insert boa;
        
        Support_Access__c supaccs = new Support_Access__c (Contact__c = testContact.Id, Back_Office_Account__c = boa.Id, Status__c ='Active', SR_Access_Level__c = 'Read/Write');
        insert supaccs;   
    	
        supaccs.End_User_Account__c = acc.Id;
        supaccs.Sold_To_Account__c = acc.Id;
        update supaccs;
        
      
       System.runAs(usr){
				
            Pagereference pg = Page.DownloadsTab;  
            Test.setCurrentPageReference(pg);  
                
            DownloadsController dc = new DownloadsController();	
            
            dc.endUserAccName = 'Test'	;
            dc.soldToAccName = 'Test';
            dc.currentCase.Sold_To_Account__c = acc.Id;
            dc.currentCase.End_User_Account__c = acc.Id;
            
            dc.conId = testContact.Id;
            dc.setContact();
            dc.isDloadTypeCD = false;
            dc.selectedProduct = null;
            dc.selectedComponent = null;
            dc.selectedMajorRelease = null;
            dc.selectedLanguage = null;
            dc.selectedOSVersion = null;
            dc.isEndSoldToSelected = true;
            dc.queryFilter();
           
            dc.showNTNC();
            dc.showTNC();
            dc.acceptTnc = true;
            
            dc.isDloadTypeCD = false;
            dc.populateSoftwares();
            dc.selectedProduct = prod.Id;
            dc.selectedComponent = comp.Id;
            dc.selectedMajorRelease ='8.1.3';
            dc.selectedLanguage = 'ENU';
            dc.selectedOSVersion = 'All';
            dc.query2 = null;
            dc.acceptTnc = true;
            dc.populateFields();
            dc.populatesProds();
                            
            dc.populateAllOnProdChange();
            dc.isProductNotFound = true;
            dc.populateAllOnProdChange();
            List<SelectOption> ft = dc.getFlType();
            List<SelectOption> dt = dc.getDtype();  
            List<SelectOption> sft = dc.sortListByValue(ft, 'disc', null);
            List<selectOption> sdt = dc.sortListByLabel(ft);       
         
           DownloadsControllerExtension dext = new DownloadsControllerExtension(dc);	

           MockHttpResponseSwDownloads testMock = new MockHttpResponseSwDownloads();                     
	       Test.setMock(HttpCalloutMock.class, testMock);
          	
            dext.swdLoadId = swDet.Id;
            dext.gtDload();
            dext.logHistory();
            
        }
	}

    static testMethod void testDownloadExt() {

        List<Customer_SW_Download_History__c> dlst = [SELECT User__c, User__r.ContactId, User__r.Contact.AccountId,SWDL_Id__c FROM Customer_SW_Download_History__c
                                                      WHERE User__r.isActive = true 
                                                      AND User__r.Profile.Name LIKE '%Portal%'
                                                      AND CreatedDate = LAST_N_DAYS:6 LIMIT 1];

        List<User> us = [SELECT id FROM User WHERE id = :dlst[0].User__c];

        System.runAs(us[0]) {

            PageReference pg= new PageReference('DownloadsTab');         
           Test.setCurrentPage(pg);  
            DownloadsController dc = new DownloadsController();
            dc.conId = dlst[0].User__r.ContactId;
            dc.sdLoadId = dlst[0].SWDL_Id__c;
            dc.endUserAccId = dlst[0].User__r.Contact.AccountId;
            String q = dc.query2;
            String f = dc.fields;

           MockHttpResponseSwDownloads testMock = new MockHttpResponseSwDownloads();            
	       Test.setMock(HttpCalloutMock.class, testMock);
    
            DownloadsControllerExtension dext = new DownloadsControllerExtension(dc);	
            dext.swdLoadId = dlst[0].SWDL_Id__c;
 
            dc.endUserAccId = dlst[0].User__r.Contact.AccountId;         
            dext.sdSite();
            dext.gtDload();
        }
    }
    
}