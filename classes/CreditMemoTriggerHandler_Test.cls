@isTest(seeAllData=true)
private class CreditMemoTriggerHandler_Test{
    static testMethod void testCreditMemo(){
        List<Account> accounts = TestUtil.createAccounts(1, true);
        Country__c objCountry = setupCountry();
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.Country__c = objCountry.Id;        
        insert opportunities;
        
        ID BaseItemRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();  
        ID CoreProductRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('CORE - Product Record Type').getRecordTypeId();          
        List<Product2> list_ProductsToInsert = new List<Product2>();
        
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'test1';
        list_ProductsToInsert.add(objTestProd1);        
        insert list_ProductsToInsert;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'PureSuccess';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;

        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Lab';
        insert prdgrpItm;
            
        BigMachines__Quote__c objTestQuote = new BigMachines__Quote__c();
        objTestQuote.BigMachines__Opportunity__c = opportunities.Id;
        objTestQuote.Quote_Created_Date__c = System.today();
        objTestQuote.BigMachines__Status__c = 'Quote In Progress';
        objTestQuote.BigMachines__Is_Primary__c = true;
        objTestQuote.Service_Level__c = 'Business';
        objTestQuote.Pricing_Model__c = 'Enabled';
        objTestQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objTestQuote.Duration_Unit__c = 'Months';
        objTestQuote.Order_Numb_of_Maint_Months__c = 12;
        objTestQuote.Order_Type__c = 'Revenue';
        objTestQuote.End_User_ID__c = accounts[0].id;
        objTestQuote.BigMachines__Account__c = accounts[0].id;
        objTestQuote.Sold_To_Name__c = accounts[0].id; 
        objTestQuote.New_Price_Book__c = 'NG5_NA_USD';
        objTestQuote.Support_Owner__c = accounts[0].id;
        objTestQuote.System_Integrator__c = accounts[0].id;
        objTestQuote.CurrencyISOCode = 'USD';
        objTestQuote.Quote_Business_Type__c = 'On Premise';
        objTestQuote.Expiration_Date__c = Date.today().addDays(90);
        objTestQuote.Approval_Submission_Date__c = Date.today();
        insert objTestQuote;
            
        List<BigMachines__Quote_Product__c> list_QPInsert = new List<BigMachines__Quote_Product__c>();
           
           
        list_QPInsert.add(new BigMachines__Quote_Product__c(BigMachines__Product__c = objTestProd1.Id,BigMachines__Sales_Price__c = 2,
                        BigMachines__Quote__c = objTestQuote.Id,BigMachines__Quantity__c = 1));
        insert list_QPInsert;
        
        Test.startTest();
        Order__c ord_1 = new Order__c();
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Opportunity__c = opportunities.id;
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.End_User_Name__c = accounts[0].id;
        ord_1.Bill_To_Name__c = accounts[0].id;
        ord_1.Sold_To_Name__c = accounts[0].id;
        ord_1.Ship_To_Name__c  = accounts[0].id;
        ord_1.CurrencyIsoCode = 'USD';
        ord_1.Quote__c = objTestQuote.id;
        ord_1.Status__c = 'Approved';
        insert ord_1; 
        
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Order__c = ord_1.Id;
        oli.CurrencyISOCode = 'USD';
        oli.Name = 'test';
        insert oli;
        
        Credit_Memo__c crd = new Credit_Memo__c();
        crd.Credit_Full_Invoice__c = true;
        crd.SFDC_Sales_Order1__c = ord_1.Id;
        crd.Customer_Name_Sold_To__c = accounts[0].id;
        crd.Credit_Type__c = 'Credit/Debook';
        crd.Status__c = 'Approved - Pending Debooking';
        insert crd;
       
        crd.Status__c = 'Approved - Pending CreditMemo';
        crd.NS_Debook_Number__c ='12134';
        update crd;
        
        crd.Status__c = 'Awaiting Rebill';
        update crd;
        
        crd.Status__c = 'Completed';
        crd.NS_CM_Number__c = '2123456';
        update crd;
        
        crd.Rebill_Invoice__c = '123';
        update crd;
        
        crd.Credit_Full_Invoice__c = false;
        try{
            update crd;
        }catch(Exception e){
            system.debug(e);
        }
        
        Test.stopTest();
    }
    
    public static Country__c setupCountry(){
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        return objCountry;
    }
}