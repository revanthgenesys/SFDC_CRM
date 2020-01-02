@isTest (seeAllData = true)
private class QuoteRevenueController_Test {
    static testMethod void testMethod1() {
    	Test.startTest();
        Account testAcc = TestUtil.createAccounts(1, false)[0];
        testAcc.Name='AccNameTest';
        Insert testAcc;
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, false)[0];
        
        Opportunity testOpp = TestUtil.createOpportunities(1,false)[0];
        testOpp.closeDate = Date.Today();
        testOpp.Country__c='a06U0000000ugIiIAI';
        testOpp.name='TestName';
        testOpp.Subscription_Term__c='TestTerm';
        testOpp.Monthly_Commitment__c =10;
        //testOpp.PS_Amount_On_Premise__c=100;
        //testOpp.Go_Live_Text__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        insert testOpp;   
        
        Opportunity testChildOpp = TestUtil.createOpportunities(1,false)[0];
        testChildOpp.closeDate = Date.Today();
        testChildOpp.ParentOpportunity__c=testOpp.id;
        insert testChildOpp;
        
        
        List<Product2> productTemp = TestUtil.createProducts(1,true);
        List<PricebookEntry> pbTemp =TestUtil.CreatePriceBookEntries(  productTemp, true);
        TestUtil.createOlis( pbTemp, testChildOpp.id, true);
        
        Test.stopTest();
        
        testQuote.Split_Status__c = false;
        testQuote.BigMachines__Is_Primary__c  = true;
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        insert testQuote;
        
        
        
        List<BigMachines__Quote_Product__c> quoteProducts = TestUtil.createQuoteProducts(1, false, testQuote.id);
        quoteProducts[0].Contract_Line_Update_Status__c = 'Split';
        quoteProducts[0].Original_Qty__c = 100;
        quoteProducts[0].Current_Qty__c = 40;
        insert quoteProducts;
        
        
        
        //BigMachines__Pricebook_Id__c
       // ApexPages.StandardController stdController = new ApexPages.StandardController(testopp.id);
        Cloud_Billing_Information__c cloudBilling = QuoteRevenueForecastControllerHelper.createCloudBillingRecord(testOpp.id);
        
        //System.debug('cc' + cloudBilling);
        //QuoteRevenueForecastControllerHelper.populatePhases(cloudBilling.id, null);
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('oppId', testOpp.id);
        System.currentPageReference().getParameters().put('mode', 'edit');
        QuoteRevenueForecastController objController = new  QuoteRevenueForecastController();
        objcontroller.opp = testOpp;
        
        Cloud_Billing_Phase__c tempPhase = new Cloud_Billing_Phase__c();
        tempPhase.End_date__c = Date.Today();
        tempPhase.Cloud_Billing_Information__c = cloudBilling.id;
        insert tempPhase;
        
         objController.newPhase = tempPhase;
        objController.newPhase.End_date__c = Date.Today(); 
        
        objController.init();
        objController.populateCloudBillingRecord();
        QuoteRevenueForecastControllerHelper.populatePhaseDates(objController.newPhase ,testOpp.closeDate);
        objController.selectedPhase = tempPhase.id;
        
        cloudBilling.SOW_Execution_Date__c = Date.Today()+15; 
        update cloudBilling;
        System.debug('ccio' + cloudBilling);
        System.debug('cc' + cloudBilling.Opportunity_Close_Date__c);
       
        QuoteRevenueForecastControllerHelper.populateLines(testOpp.id, '', null);
              
        cloudBilling = [SELECT id, Project_Health__c, Actual_Go_Live_Date__c, SOW_Execution_Date__c, Forecasted_Go_Live_Date_At_SOW_Signatu__c, 
            Forecasted_Go_Live_Date_Projected__c,  Professional_Services_PM__c, Discovery_Phase_Complete__c, Technical_Requirements_Completion_Date__c, 
            SOW_Fully_Delivered_Date_Actual__c, SOW_Fully_Delivered_Date_Forecasted__c, Design_Phase_Completed__c, Close_Date__c, PM_Assigned__c,
            Opportunity_Close_Date__c,Opportunity__r.Name,Time_to_Revenue__c,Original__c ,Forecasted_Time_to_Revenue__c,
            Opportunity__c FROM Cloud_Billing_Information__c where id =:cloudBilling.id];
                        
        QuoteRevenueForecastControllerHelper.populateStatusMatrix(cloudBilling);
       
       
        cloudBilling.SOW_Execution_Date__c = Date.Today();
        cloudBilling.Forecasted_Go_Live_Date_At_SOW_Signatu__c = Date.Today() + 30;
        cloudBilling.Forecasted_Go_Live_Date_Projected__c = Date.Today() + 60;
        cloudBilling.Discovery_Phase_Complete__c = Date.Today() + 60;
        cloudBilling.Technical_Requirements_Completion_Date__c = Date.Today() + 60;
         cloudBilling.Design_Phase_Completed__c= Date.Today() + 90;
        cloudBilling.PM_Assigned__c = Date.Today() + 20;
        cloudBilling.Actual_Go_Live_Date__c =  Date.Today() + 30;
         cloudBilling.Discovery_Phase_Complete__c = Date.Today() + 30;
        update cloudBilling;
        
         cloudBilling = [SELECT id, Project_Health__c, Actual_Go_Live_Date__c, SOW_Execution_Date__c, Forecasted_Go_Live_Date_At_SOW_Signatu__c, 
            Forecasted_Go_Live_Date_Projected__c,  Professional_Services_PM__c, Discovery_Phase_Complete__c, Technical_Requirements_Completion_Date__c, 
            SOW_Fully_Delivered_Date_Actual__c, SOW_Fully_Delivered_Date_Forecasted__c, Design_Phase_Completed__c, Close_Date__c, PM_Assigned__c,
            Opportunity_Close_Date__c,Opportunity__r.Name,Time_to_Revenue__c,Original__c ,Forecasted_Time_to_Revenue__c,
            Opportunity__c FROM Cloud_Billing_Information__c where id =:cloudBilling.id];
        
         QuoteRevenueForecastControllerHelper.populateStatusMatrix(cloudBilling);
      
      
        cloudBilling.SOW_Execution_Date__c = Date.Today();
        cloudBilling.Forecasted_Go_Live_Date_At_SOW_Signatu__c = Date.Today() - 30;
        cloudBilling.Forecasted_Go_Live_Date_Projected__c = Date.Today() - 10;
        cloudBilling.Discovery_Phase_Complete__c = Date.Today() - 10;
        cloudBilling.Technical_Requirements_Completion_Date__c = Date.Today() - 10;
         cloudBilling.Design_Phase_Completed__c= Date.Today() -5;
        cloudBilling.PM_Assigned__c = Date.Today() -10;
        cloudBilling.Actual_Go_Live_Date__c =  Date.Today() - 1;
         cloudBilling.Discovery_Phase_Complete__c = Date.Today() - 2;
         cloudBilling.SOW_Fully_Delivered_Date_Actual__c = Date.Today() + 5;
         cloudBilling.SOW_Fully_Delivered_Date_Forecasted__c = Date.Today()+10;
        
        update cloudBilling;
        
         cloudBilling = [SELECT id, Project_Health__c, Actual_Go_Live_Date__c, SOW_Execution_Date__c, Forecasted_Go_Live_Date_At_SOW_Signatu__c, 
            Forecasted_Go_Live_Date_Projected__c,  Professional_Services_PM__c, Discovery_Phase_Complete__c, Technical_Requirements_Completion_Date__c, 
            SOW_Fully_Delivered_Date_Actual__c, SOW_Fully_Delivered_Date_Forecasted__c, Design_Phase_Completed__c, Close_Date__c, PM_Assigned__c,
            Opportunity_Close_Date__c,Opportunity__r.Name,Time_to_Revenue__c,Original__c ,Forecasted_Time_to_Revenue__c,
            Opportunity__c FROM Cloud_Billing_Information__c where id =:cloudBilling.id];
        
         QuoteRevenueForecastControllerHelper.populateStatusMatrix(cloudBilling);
      
              
         
       //tempPhase.End_date__c = Date.Today() + 15;
       update tempPhase;
       
       //QuoteRevenueForecastControllerHelper.informationHistoryUpdate();
 
        //objController.createPhase();
       //objController.populateAccountId();
        objController.showPopup();
        objController.editHeader();
        objController.saveHeader();
        objController.editCheck();
        //objController.updatePhase();
        objController.saveUpdate();
        objController.hidePopup();
        
        objController.loadPhaseLines();
        objController.getPhaseHistory();
        objController.loadRevenueDetails();
        objController.editPhase();
        objController.deletePhase();
       
       
       cloudRevenueController ct = new cloudRevenueController();
       cloudRevenueControllerAgent ct2 = new cloudRevenueControllerAgent();
       //Modified by Swastika
       //objController.SendEmail();
       //objController.createPhase();
       //objController.updatePhase();
       objController.cloneProductLine();
       objController.addProductLine();
       //objController.deleteProductLine();
        
       
      
        try{
            //stdController.submit();
        }
        catch(Exception ex){}
    }
}