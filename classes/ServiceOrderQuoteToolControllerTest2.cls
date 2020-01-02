//Anju
@IsTest(SeeAllData=true)
private class ServiceOrderQuoteToolControllerTest2 {      
    
    
    static testMethod void testMethod4() {
        test.startTest();

        
        BigMachines__Quote__c currentQuote = [Select id from BigMachines__Quote__c where BigMachines__Is_Primary__c = true and PureSuccess__c != null and offering_type__c = 'Business Edition' and BigMachines__Status__c = 'Quote In Progress' and BigMachines__Line_Items__c > 0 limit 1];
        
        PageReference pageRef = Page.ServiceOrderQuoteToolBE;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('id', currentQuote.id);
        ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.save();
        
        Map<String, List<ServiceOrderQuoteToolController.wrapperQuoteProducts>> mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated = new Map<String, List<ServiceOrderQuoteToolController.wrapperQuoteProducts>>();
        
        List<ServiceOrderQuoteToolController.wrapperQuoteProducts> tempWrapper = new List<ServiceOrderQuoteToolController.wrapperQuoteProducts>();
        for(BigMachines__Quote_Product__c bmqp : [Select id,BigMachines__Product__r.Calculate_List_Price_From__c , Net_Unit_Price__c ,Discount__c , BigMachines__Quote__c, BigMachines__Product__c, BigMachines__Quantity__c, List_Price__c, Installation_Fees__c  from BigMachines__Quote_Product__c where BigMachines__Quote__c = :currentQuote.id])
        {
            ServiceOrderQuoteToolController.wrapperQuoteProducts temp = new ServiceOrderQuoteToolController.wrapperQuoteProducts();
            temp.record = bmqp;
            temp.selected = true;
            temp.index = 0;
            tempWrapper.add(temp);
            
            if(bmqp.BigMachines__Product__r.Calculate_List_Price_From__c != null)
            {              
                if(mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated.get(bmqp.BigMachines__Product__r.Calculate_List_Price_From__c) == null)
                {
                    List<ServiceOrderQuoteToolController.wrapperQuoteProducts> newList = new List<ServiceOrderQuoteToolController.wrapperQuoteProducts>();
                    newList.add(temp);    
                    mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated.put(bmqp.BigMachines__Product__r.Calculate_List_Price_From__c, newList);
                }
                else
                    mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated.get(bmqp.BigMachines__Product__r.Calculate_List_Price_From__c).add(temp); 
            }
        }
        ServiceOrderQuoteToolHelper.getProductIdVsPricingTable(tempWrapper);
        ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(tempWrapper, 12);
        //ServiceOrderQuoteToolHelper.bulkUpdate(tempWrapper,tempWrapper);
        //ServiceOrderQuoteToolHelper.doCalculationForSupportAndCS(tempWrapper,100,true,12);
        ServiceOrderQuoteToolHelper.caculateMininumFeesPeriod(tempWrapper);
        ServiceOrderQuoteToolHelper.addMoreProduct(tempWrapper,0,1);
        ServiceOrderQuoteToolHelper.calculatePercentListPrice(mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated,tempWrapper);
        
        Set<String> nonselectedprods = new Set<String>();
        Set<String> selectedprods = new Set<String>();
        for(Product2 prod : [Select id, name,Auto_Select_This_Product_If__c,Calculate_List_Price_From__c  from Product2  where Auto_Select_This_Product_If__c != null and isactive = true])
        {
            nonselectedprods.add(prod.id);
            selectedprods.add(prod.Auto_Select_This_Product_If__c);
            
        }
        ServiceOrderQuoteToolHelper.autoSelectDependingProducts(tempWrapper,selectedprods,nonselectedprods);
        
        
        test.stopTest();

        /*
        Map<String, List<SelectOption>> mapProductVsProductDevices;
        mapProductVsProductDevices = ServiceOrderQuoteToolHelper.getProductVsProductDevicesMap('USD'); 
        system.debug(list_NewQuotes[0].id);
        ServiceOrderQuoteToolHelper.populateQuoteProducts(list_NewQuotes[0],'Business Edition',null,'true',mapProductVsProductDevices);
        */
        
        
    }
    
    static testMethod void testMethod5() {
        test.startTest();

        BigMachines__Quote__c currentQuote = [Select id from BigMachines__Quote__c where offering_type__c = 'Outbound Engagement' and BigMachines__Status__c = 'Quote In Progress' and BigMachines__Line_Items__c > 0 and Period__c = 'Annually' limit 1];
        PageReference pageRef = Page.ServiceOrderQuoteTool;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('id', currentQuote.id);
        ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.save();
        
        ServiceOrderQuoteToolHelper.recallApprovalProcess(currentQuote.id);
        test.stopTest();

    }
    
    static testMethod void testMethod6() {
        test.startTest();

        
        BigMachines__Quote__c currentQuote = [Select id from BigMachines__Quote__c where offering_type__c = 'Business Edition' and BigMachines__Status__c = 'Quote In Progress' and BigMachines__Line_Items__c > 0 and Pricing_Model__c != 'Concurrent' and CurrencyIsoCode = 'AUD'  limit 1];
        
        PageReference pageRef = Page.ServiceOrderQuoteToolBE;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('id', currentQuote.id);
        ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.save();
        ServiceOrderQuoteToolHelper.getIPeriodForSupport('test');
        test.stopTest();

        /*
        Map<String, List<SelectOption>> mapProductVsProductDevices;
        mapProductVsProductDevices = ServiceOrderQuoteToolHelper.getProductVsProductDevicesMap('USD'); 
        system.debug(list_NewQuotes[0].id);
        ServiceOrderQuoteToolHelper.populateQuoteProducts(list_NewQuotes[0],'Business Edition',null,'true',mapProductVsProductDevices);
        */
        
        
    }
    
    static testMethod void testMethod7() {
        test.startTest();

        BigMachines__Quote__c currentQuote = [Select id from BigMachines__Quote__c where offering_type__c = 'Premier Edition' and BigMachines__Status__c = 'Quote In Progress' and BigMachines__Line_Items__c > 0 and Period__c = 'Semi-Annually' limit 1];
        PageReference pageRef = Page.ServiceOrderQuoteToolPE;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('id', currentQuote.id);
        ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);        
        obj.save();
        //obj.addMoreProduct();
        obj.cancel();
        obj.cloneQuote();
        obj.recall();
        obj.viewContract();
        //ServiceOrderQuoteToolHelper.getallOptions('USD');
        test.stopTest();

    }
    
    static testMethod void testMethod8() {
        test.startTest();

        BigMachines__Quote__c currentQuote = [Select id from BigMachines__Quote__c where offering_type__c = 'Business Edition' and BigMachines__Status__c = 'Quote In Progress' and BigMachines__Line_Items__c > 0 order by lastmodifieddate desc limit 1];
        PageReference pageRef = Page.ServiceOrderQuoteToolPE;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('id', currentQuote.id);
        ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.save();
        obj.doCalculationOnPeriodChange();
        //obj.addMoreProduct();
        //ServiceOrderQuoteToolHelper.getallOptions('USD');
        test.stopTest();

    }
    
    static testMethod void testMethod9() {
        test.startTest();

        BigMachines__Quote__c currentQuote = [Select id from BigMachines__Quote__c where offering_type__c = 'Outbound Engagement' and BigMachines__Status__c = 'Quote In Progress' and BigMachines__Line_Items__c > 0 order by lastmodifieddate desc limit 1];
        PageReference pageRef = Page.ServiceOrderQuoteToolPE;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('id', currentQuote.id);
        ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.save();
        obj.doCalculationOnPeriodChange();
        obj.byPassApprovals();
        obj.submitOrderBtnHandler();
        obj.showReviseVisibility();
        obj.hideReviseVisibility();
        obj.getDQStatus();
        obj.synchAndGoToDQ();
        obj.doCalculationForLocalCommittedMinutes();
        //obj.doCalculation();
        //obj.addMoreProduct();
        //ServiceOrderQuoteToolHelper.getallOptions('USD');
        test.stopTest();

    }
    
    static testMethod void testMethod10 () {
        test.startTest();

        BigMachines__Quote__c currentQuote = [Select id from BigMachines__Quote__c where offering_type__c = 'Premier Edition' and BigMachines__Status__c = 'Quote In Progress' and BigMachines__Line_Items__c > 0 order by lastmodifieddate desc limit 1];
        PageReference pageRef = Page.ServiceOrderQuoteToolPE;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('id', currentQuote.id);
        ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.save();
        obj.doCalculationOnPeriodChange();
        //obj.addMoreProduct();
        //ServiceOrderQuoteToolHelper.getallOptions('USD');
        test.stopTest();

    }
    
    
    static testMethod void testMethod11(){
        Test.startTest();
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        // List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        
        BigMachines__Quote__c quote = new BigMachines__Quote__c();
        quote.BigMachines__Opportunity__c = list_NewOpps.get(0).Id;
        ServiceOrderQuoteHelper.saveQuote(quote, list_NewOpps.get(0));
        Test.stopTest();
    }
}