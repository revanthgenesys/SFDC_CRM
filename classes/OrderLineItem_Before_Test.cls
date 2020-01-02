@isTest
private class OrderLineItem_Before_Test{
    
    static testMethod void DeleteScenario() {
    	
        Util.Bypass_Trigger_Chk = true;
        
        Auto_number__c myCS1 = new Auto_number__c();
        myCS1.Name = 'Start';
        myCS1.values__c = 1;
        insert myCS1;
        
        Profile prof = [select id from profile where name LIKE '%Data Administrator%'];
        
        User user = new User(LastName = 'Test',
                           FirstName='Test',
                           Alias = 'Test',
                           Email = 'Test@test.com',
                           Username = 'te567fdtyu3678fdst@test.com',
                           ProfileId = prof.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );    
        
            Opportunity testOpp = TestUtil.createOpportunities(1, false)[0];
            testOpp.Gainsight_Relationship_Type__c = 'test it';
            insert testOpp;
            
            BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];  
                
            Order__c ord_1 = new Order__c();
            ord_1.Maintenance_Start__c = Date.today();
            ord_1.Maintenance_End__c = Date.today().addYears(1);
            ord_1.Numb_of_Maint_Months__c = 12;
            ord_1.status__c = 'In Progress';
            ord_1.Opportunity__c = testOpp.id;
            ord_1.Quote__c = testQuote.id;
        	
            insert ord_1;
            
            List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
            
            Product2 objTestProd1 = new Product2();
            objTestProd1.Name='Test Prod1';
            objTestProd1.recordTypeId = rtypes[0].Id;
            objTestProd1.Type__c = 'Token';
            objTestProd1.End_of_Support__c = String.valueOf(Date.today());
            objTestProd1.IsActive = true;
            objTestProd1.Description = 'test 1';
            objTestProd1.OfferingType__c = 'PureSuccess';
            objTestProd1.APN_Number__c = 'Tokens1';
            objTestProd1.zqu__SKU__c = 'testAshosh'; 
        	objTestProd1.New_Category__c = 'Pass Through';
            insert objTestProd1;
        
        	BigMachines__Quote_Product__c objQuoteProduct = new BigMachines__Quote_Product__c();
            objQuoteProduct.BigMachines__Product__c = objTestProd1.Id;
            objQuoteProduct.BigMachines__Quote__c = testQuote.Id;
            objQuoteProduct.BigMachines__Quantity__c = 1;
            objQuoteProduct.BigMachines__Sales_Price__c = 100;
        	objQuoteProduct.Service_Contract_Line_ID__c = 'New';
            insert objQuoteProduct; 
        
        	Util.Bypass_Trigger_Chk = false;
        
            Order_Line_Item__c oline =  new Order_Line_Item__c();
            oline.Order__c = ord_1.Id;
            oline.Product__c = objTestProd1.Id;
            oline.Contract_Line_Update_Status__c = '';
            oline.BigMachines_Quantity__c = 1;
            oline.Sales_Price__c = 10;
        	//oline.Support_Type_Formula__c = 'New';
        	oline.POB_Type__c = 'Training';
            oline.Quote_Product__c = objTestProd1.Id;
            insert oline;
            
            system.runAs(user){
                Test.StartTest();
                    Delete oline;
                Test.StopTest();
            Util.Bypass_Trigger_Chk = true;
            }
    }
}