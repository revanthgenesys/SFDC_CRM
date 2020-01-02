@isTest
public class CustomerCarePortalUserRouting_Test {
	
	static testMethod void routingTst() {
		
		Util.Bypass_Trigger_Chk = true;
     	
     	Profile prof = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
	    Account accnt = TestUtil.createAccounts(1, true)[0];
	    Contact testContact = TestUtil.createContacts(1, accnt, true)[0];
	    testContact.Has_Ldap_Login__c = true;
        update testContact;
         
	    User testUser;	
	    testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prof.id, false);    	
		testUser.ContactId = testContact.id;
		insert testUser;

	    Cloud_Deployment__c cldDep = new Cloud_Deployment__c(Name = 'Test2', Account__c = accnt.id, Status__c = 'Production',
	                                                          Cloud_Platform__c = 'PureCloud', Support_Status__c = 'Active');
	    insert cldDep;
	        
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContact.id, Cloud_Deployment__c = cldDep.Id,
                                          Access_Status__c = 'Active', Access_Level__c = 'Read/Write');
        insert sa;
        
        Cloud_Deployment__c cldDep2 = new Cloud_Deployment__c(Name = 'Test2', Account__c = accnt.id, Status__c = 'Production',
	                                                          Cloud_Platform__c = 'PureConnect Cloud', Support_Status__c = 'Active');
	    insert cldDep2;
	        
        Support_Access_Cloud__c sacl = new Support_Access_Cloud__c (Contact__c = testContact.id, Cloud_Deployment__c = cldDep2.Id,
                                          Access_Status__c = 'Active', Access_Level__c = 'Read Only');
        insert sacl;
        
        Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', 
                                            	OfferingType__c = 'PureEngage On Premise', IsActive = true);
         insert prod;
            
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            
            ServiceContract servCon = new ServiceContract();
            servCon.Name = 'Test Service Contract';
            servCon.Sold_To_Name__c = accnt.Id;
            servCon.End_User_Name__c = accnt.Id;
            servCon.Agreement_Status__c = 'Active';
            servCon.pricebook2id = pricebookId;     
            insert servCon; 
            
            ContractLineItem cli = new ContractLineItem( ServiceContractId = servCon.Id,
                                                         Quantity = 10, UnitPrice = 100,
                                                         PricebookEntryId = standardPrice.Id,
                                                         Upgraded_Product__c = prod.Id
                                                        );
            insert cli;
            
            Support_Product__c supportProduct = new Support_Product__c(name='Support Prod', 
                                                                        Product_Type__c ='Component',
                                                                        Customer_Available__c = true);
            insert supportProduct;
            
            Back_Office_Account__c testBOA = new Back_Office_Account__c();
            testBOA.End_User_Account__c = accnt.id;
            testBOA.Sold_To_Account__c = accnt.id;
            testBOA.Platform__c = 'PureEngage On Premise';
            insert testBOA;
        
            Back_Office_Account__c testBOA2 = new Back_Office_Account__c();
            testBOA2.End_User_Account__c = accnt.id;
            testBOA2.Sold_To_Account__c = accnt.id;
            testBOA2.Platform__c = 'PureConnect On Premise';
            testBOA2.Support_Package__c = 'Managed Services';
            
            insert testBOA2;

        Support_Access__c sa2 = new Support_Access__c(Back_Office_Account__c = testBOA.Id,
			                                             Contact__c = testContact.id,
			                                 Status__c = 'Active', SR_Access_Level__c = 'Read/Write');		                                             
		insert sa2;  
		
		Support_Access__c sa3 = new Support_Access__c(Back_Office_Account__c = testBOA2.Id,
			                                             Contact__c = testContact.id,
			                                 Status__c = 'Active', SR_Access_Level__c = 'Read Only');		                                             
		insert sa3;   

	    Test.startTest();       
	      System.runAs(testUser) {
	      	
	         CustomerCarePortalUserRouting rt = new CustomerCarePortalUserRouting();
	         
	         rt.redirectByUserPerms();
	         
	         rt.getPremSupportType();
	         rt.getPremFRType();
	         rt.getCloudSupportType();
	         rt.getCloudServiceType();
	         rt.getCloudFRType();
	         rt.getAdminType();
             rt.getPremServiceType();
             rt.getCloudServiceType();
	         rt.getViewSupportType();
	         rt.getViewCloudTypes();
	         rt.getViewAdmin();
	         rt.getViewPremFRType();
	         rt.getViewCloudFRType();
	         rt.articleSearchPEng();
	         rt.articleSearchPCld();
	         rt.articleSearchPCnct();
	         rt.caseSearch();
	      
	      }
	    Test.stopTest();
	}
	
	static testMethod void routingTst2() {
		
		CustomerCarePortalUserRouting rt = new CustomerCarePortalUserRouting();
		
		rt.pureEngPrem = 'Read/Write';
		   rt.redirectByUserPerms();
		   
        rt.pureEngCld='Read/Write';      
          rt.redirectByUserPerms();
                  
        rt.pureCnctPrem='Read/Write';
          rt.redirectByUserPerms(); 
               
        rt.pureCnctCld='Read/Write';
           rt.redirectByUserPerms();
           
        rt.pureCld='Read/Write';
           rt.redirectByUserPerms();
             
      /*** Read Only ***/     
        rt.pureEngPrem='Read Only';
           rt.redirectByUserPerms(); 
           
        rt.pureEngCld='Read Only';       
           rt.redirectByUserPerms();
                  
        rt.pureCnctPrem='Read Only';
           rt.redirectByUserPerms();
               
        rt.pureCnctCld='Read Only';
           rt.redirectByUserPerms();
           
        rt.pureCld='Read Only';
           rt.redirectByUserPerms();
    
    /*** Basic Access ***/
        rt.pureEngPrem='Basic';
           rt.redirectByUserPerms();
        
        rt.pureEngPrem='None';   
        rt.pureEngCld='Basic';       
           rt.redirectByUserPerms();
        
         rt.pureEngCld='None';            
        rt.pureCnctPrem='Basic';
           rt.redirectByUserPerms();
        
        rt.pureCnctPrem='None';       
        rt.pureCnctCld='Basic';
           rt.redirectByUserPerms(); 
        
        rt.pureCnctCld='None';   
        rt.pureCld='Basic';
           rt.redirectByUserPerms(); 
           
            /**** Partner ****/
        rt.pureCld='None';
        rt.isPartner = true;
           rt.redirectByUserPerms();          
	}
    
}