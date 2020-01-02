//Naresh Kumar
@IsTest(SeeAllData=true)
private class ServiceOrderQuoteToolControllerTest {
    static testMethod void testMethod1() {
        test.startTest();
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, true)[0];
        PageReference pageRef = Page.ServiceOrderQuoteTool;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('offeringType','Premier Edition');      
        ApexPages.StandardController std = new ApexPages.StandardController(new BigMachines__Quote__c());
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.headerRow[0].record.BigMachines__Quantity__c = 1000;
        if(!obj.userSubscriptions.isEmpty() && obj.userSubscriptions.size() > 0){
            obj.userSubscriptions[0].selected = true;                                   
        }
        if(!obj.portSubscriptions.isEmpty() && obj.portSubscriptions.size() > 0){
            obj.portSubscriptions[0].selected = true;                                   
        }
        if(!obj.customerSubscriptions.isEmpty() && obj.customerSubscriptions.size() > 0){
            obj.customerSubscriptions[0].selected = true;                                   
        }
        if(!obj.rentedEquipmentSubscriptions.isEmpty() && obj.rentedEquipmentSubscriptions.size() > 0){
            obj.rentedEquipmentSubscriptions[0].selected = true;                                    
        }
        if(!obj.supportSubscriptions.isEmpty() && obj.supportSubscriptions.size() > 0){
            obj.supportSubscriptions[0].selected = true;                                    
        }
        if(!obj.timeBasedSubscriptions.isEmpty() && obj.timeBasedSubscriptions.size() > 0){
            obj.timeBasedSubscriptions[0].selected = true;                                  
        }
        if(!obj.transactionBasedSubscriptions.isEmpty() && obj.transactionBasedSubscriptions.size() > 0){
            obj.transactionBasedSubscriptions[0].selected = true;                                   
        }
        if(!obj.tierSubscriptions.isEmpty() && obj.tierSubscriptions.size() > 0){
            obj.tierSubscriptions[0].selected = true;                                   
        }
        if(!obj.configurationProfServicesSubscriptions.isEmpty() && obj.configurationProfServicesSubscriptions.size() > 0){
            obj.configurationProfServicesSubscriptions[0].selected = true;                                  
        }
        if(!obj.clientManagementSubscriptions.isEmpty() && obj.clientManagementSubscriptions.size() > 0){
            obj.clientManagementSubscriptions[0].selected = true;                                   
        }
        obj.bulkUpdate();                               
        obj.save();
        obj.submitForApproval();
        test.stopTest();
    }
    static testMethod void testMethod11() {
        test.startTest();
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, true)[0];
        PageReference pageRef = Page.ServiceOrderQuoteTool;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('offeringType','Business Edition');     
        ApexPages.StandardController std = new ApexPages.StandardController(new BigMachines__Quote__c());
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.headerRow[0].record.BigMachines__Quantity__c = 1000;
        if(!obj.IVRAndMediaPortOptions.isEmpty() && obj.IVRAndMediaPortOptions.size() > 0){
            obj.IVRAndMediaPortOptions[0].selected = true;                                  
        }
        if(!obj.IVRAndMediaPortAddOns.isEmpty() && obj.IVRAndMediaPortAddOns.size() > 0){
            obj.IVRAndMediaPortAddOns[0].selected = true;                                   
        }
        if(!obj.perSeatPricingBase.isEmpty() && obj.perSeatPricingBase.size() > 0){
            obj.perSeatPricingBase[0].selected = true;                                  
        }
        if(!obj.digitalChannelOptions.isEmpty() && obj.digitalChannelOptions.size() > 0){
            obj.digitalChannelOptions[0].selected = true;                                   
        }
        if(!obj.inboundSeatAddOnsQM.isEmpty() && obj.inboundSeatAddOnsQM.size() > 0){
            obj.inboundSeatAddOnsQM[0].selected = true;                                 
        }
        if(!obj.inboundSeatAddOnsWO.isEmpty() && obj.inboundSeatAddOnsWO.size() > 0){
            obj.inboundSeatAddOnsWO[0].selected = true;                                 
        }
        if(!obj.inboundSeatAddOnsOS.isEmpty() && obj.inboundSeatAddOnsOS.size() > 0){
            obj.inboundSeatAddOnsOS[0].selected = true;                                 
        }
        if(!obj.endUserEndPoints.isEmpty() && obj.endUserEndPoints.size() > 0){
            obj.endUserEndPoints[0].selected = true;                                    
        }
        if(!obj.cloudContactCenterAdapters.isEmpty() && obj.cloudContactCenterAdapters.size() > 0){
            obj.cloudContactCenterAdapters[0].selected = true;                                  
        }
        if(!obj.telcoITI.isEmpty() && obj.telcoITI.size() > 0){
            obj.telcoITI[0].selected = true;                                    
        }
        if(!obj.telcoBLT.isEmpty() && obj.telcoBLT.size() > 0){
            obj.telcoBLT[0].selected = true;                                    
        }
        if(!obj.telcoOP.isEmpty() && obj.telcoOP.size() > 0){
            obj.telcoOP[0].selected = true;                                 
        }        
        obj.bulkUpdate();      
        test.stopTest();                         
        //obj.save();
        //obj.submitForApproval();
    }
    static testMethod void testMethod2() {
        test.startTest();
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, true)[0];
        PageReference pageRef = Page.ServiceOrderQuoteTool;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('offeringType','Premier Edition');      
        ApexPages.StandardController std = new ApexPages.StandardController(new BigMachines__Quote__c());
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.headerRow[0].record.BigMachines__Quantity__c = 1000;
        if(!obj.userSubscriptions.isEmpty() && obj.userSubscriptions.size() > 0){
            obj.userSubscriptions[0].selected = true;    
            obj.index = obj.userSubscriptions[0].index;
            obj.sectionType = 'User Subscription';
            obj.doCalculation();                                
        }
        if(!obj.portSubscriptions.isEmpty() && obj.portSubscriptions.size() > 0){
            obj.portSubscriptions[0].selected = true;
            obj.index = obj.userSubscriptions[0].index;
            obj.sectionType = 'Port Subscription';
            obj.doCalculation();                                    
        }
        if(!obj.customerSubscriptions.isEmpty() && obj.customerSubscriptions.size() > 0){
            obj.customerSubscriptions[0].selected = true;  
            obj.index = obj.customerSubscriptions[0].index;
            obj.sectionType = 'Customer Subscription';
            obj.doCalculation();                                
        }
        if(!obj.rentedEquipmentSubscriptions.isEmpty() && obj.rentedEquipmentSubscriptions.size() > 0){
            obj.rentedEquipmentSubscriptions[0].selected = true;  
            obj.index = obj.rentedEquipmentSubscriptions[0].index;
            obj.sectionType = 'Rented Equipment';
            obj.doCalculation();                                
        }
        if(!obj.supportSubscriptions.isEmpty() && obj.supportSubscriptions.size() > 0){
            obj.supportSubscriptions[0].selected = true;     
            obj.index = obj.supportSubscriptions[0].index;
            obj.sectionType = 'support';
            obj.doCalculation();                            
        }
        if(!obj.timeBasedSubscriptions.isEmpty() && obj.timeBasedSubscriptions.size() > 0){
            obj.timeBasedSubscriptions[0].selected = true; 
            obj.index = obj.timeBasedSubscriptions[0].index;
            obj.sectionType = 'Time Based';
            obj.doCalculation();                                
        }
        if(!obj.transactionBasedSubscriptions.isEmpty() && obj.transactionBasedSubscriptions.size() > 0){
            obj.transactionBasedSubscriptions[0].selected = true;   
            obj.index = obj.transactionBasedSubscriptions[0].index;
            obj.sectionType = 'Transaction Based';
            obj.doCalculation();                                
        }
        if(!obj.tierSubscriptions.isEmpty() && obj.tierSubscriptions.size() > 0){
            obj.tierSubscriptions[0].selected = true;             
            obj.index = obj.tierSubscriptions[0].index;
            obj.sectionType = 'Tier Based';
            obj.doCalculation();                    
        }
        if(!obj.configurationProfServicesSubscriptions.isEmpty() && obj.configurationProfServicesSubscriptions.size() > 0){
            obj.configurationProfServicesSubscriptions[0].selected = true;
            obj.index = obj.configurationProfServicesSubscriptions[0].index;
            obj.sectionType = 'Configuration Professional Services';
            obj.doCalculation();                                    
        }
        if(!obj.clientManagementSubscriptions.isEmpty() && obj.clientManagementSubscriptions.size() > 0){
            obj.clientManagementSubscriptions[0].selected = true;
            obj.index = obj.clientManagementSubscriptions[0].index;
            obj.sectionType = 'Client Management';
            obj.doCalculation();                                    
        }   
        test.stopTest();
    }
    
    static testMethod void testMethod22() {
        test.startTest();
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, true)[0];
        PageReference pageRef = Page.ServiceOrderQuoteTool;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('offeringType','Business Edition');     
        ApexPages.StandardController std = new ApexPages.StandardController(new BigMachines__Quote__c());
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.headerRow[0].record.BigMachines__Quantity__c = 1000;
        if(!obj.IVRAndMediaPortOptions.isEmpty() && obj.IVRAndMediaPortOptions.size() > 0){
            obj.IVRAndMediaPortOptions[0].selected = true;    
            obj.index = obj.IVRAndMediaPortOptions[0].index;
            obj.sectionType = 'IVR and Media Port Options';
            obj.doCalculation();                                
        }
        if(!obj.IVRAndMediaPortAddOns.isEmpty() && obj.IVRAndMediaPortAddOns.size() > 0){
            obj.IVRAndMediaPortAddOns[0].selected = true;
            obj.index = obj.IVRAndMediaPortAddOns[0].index;
            obj.sectionType = 'IVR / Media Port Add Ons';
            obj.doCalculation();                                    
        }
        if(!obj.perSeatPricingBase.isEmpty() && obj.perSeatPricingBase.size() > 0){
            obj.perSeatPricingBase[0].selected = true;  
            obj.index = obj.perSeatPricingBase[0].index;
            obj.sectionType = 'Per Seat Pricing (Base Options)';
            obj.doCalculation();                                
        }
        if(!obj.digitalChannelOptions.isEmpty() && obj.digitalChannelOptions.size() > 0){
            obj.digitalChannelOptions[0].selected = true;  
            obj.index = obj.digitalChannelOptions[0].index;
            obj.sectionType = 'Digital Channels Options';
            obj.doCalculation();                                
        }
        if(!obj.inboundSeatAddOnsQM.isEmpty() && obj.inboundSeatAddOnsQM.size() > 0){
            obj.inboundSeatAddOnsQM[0].selected = true;     
            obj.index = obj.inboundSeatAddOnsQM[0].index;
            obj.sectionType = 'Quality Management';
            obj.doCalculation();                            
        }
        if(!obj.inboundSeatAddOnsWO.isEmpty() && obj.inboundSeatAddOnsWO.size() > 0){
            obj.inboundSeatAddOnsWO[0].selected = true; 
            obj.index = obj.inboundSeatAddOnsWO[0].index;
            obj.sectionType = 'Workforce Optimization';
            obj.doCalculation();                                
        }
        if(!obj.inboundSeatAddOnsOS.isEmpty() && obj.inboundSeatAddOnsOS.size() > 0){
            obj.inboundSeatAddOnsOS[0].selected = true;   
            obj.index = obj.inboundSeatAddOnsOS[0].index;
            obj.sectionType = 'Other Services';
            obj.doCalculation();                                
        }
        if(!obj.endUserEndPoints.isEmpty() && obj.endUserEndPoints.size() > 0){
            obj.endUserEndPoints[0].selected = true;              
            obj.index = obj.endUserEndPoints[0].index;
            obj.sectionType = 'End User End Points';
            obj.doCalculation();                    
        }
        if(!obj.cloudContactCenterAdapters.isEmpty() && obj.cloudContactCenterAdapters.size() > 0){
            obj.cloudContactCenterAdapters[0].selected = true;
            obj.index = obj.cloudContactCenterAdapters[0].index;
            obj.sectionType = 'Cloud Contact Center Adapters';
            obj.doCalculation();                                    
        }
        if(!obj.telcoITI.isEmpty() && obj.telcoITI.size() > 0){
            obj.telcoITI[0].selected = true;
            obj.index = obj.telcoITI[0].index;
            obj.sectionType = 'Inbound to IVR';
            obj.doCalculation();                                    
        }   
        if(!obj.telcoBLT.isEmpty() && obj.telcoBLT.size() > 0){
            obj.telcoBLT[0].selected = true;
            obj.index = obj.telcoBLT[0].index;
            obj.sectionType = 'Bridging Leg / Transfer to PSTN or PLMN';
            obj.doCalculation();                                    
        }   
        if(!obj.telcoOP.isEmpty() && obj.telcoOP.size() > 0){
            obj.telcoOP[0].selected = true;
            obj.index = obj.telcoOP[0].index;
            obj.sectionType = 'Outbound to PSTN or PLMN';
            obj.doCalculation();                                    
        }   
        if(!obj.telcoMPLS.isEmpty() && obj.telcoMPLS.size() > 0){
            obj.telcoMPLS[0].selected = true;
            obj.index = obj.telcoMPLS[0].index;
            obj.sectionType = 'MPLS';
            obj.doCalculation();                                    
        }   
        if(!obj.genesysCare.isEmpty() && obj.genesysCare.size() > 0){
            obj.genesysCare[0].selected = true;
            obj.index = obj.genesysCare[0].index;
            obj.sectionType = 'Genesys Care';
            obj.doCalculation();                                    
        }   
        if(!obj.telcoCrossConnect.isEmpty() && obj.telcoCrossConnect.size() > 0){
            obj.telcoCrossConnect[0].selected = true;
            obj.index = obj.telcoCrossConnect[0].index;
            obj.sectionType = 'Telco Cross Connect';
            obj.doCalculation();                                    
        }   
        if(!obj.psRapidDevelopmentImplementationPackage.isEmpty() && obj.psRapidDevelopmentImplementationPackage.size() > 0){
            obj.psRapidDevelopmentImplementationPackage[0].selected = true;
            obj.index = obj.psRapidDevelopmentImplementationPackage[0].index;
            obj.sectionType = 'Professional Services Rapid Deployment ImplementationPackages';
            obj.doCalculation();                                    
        }       
        if(!obj.psImplementation.isEmpty() && obj.psImplementation.size() > 0){
            obj.psImplementation[0].selected = true;
            obj.index = obj.psImplementation[0].index;
            obj.sectionType = 'Professional Services Implementation';
            obj.doCalculation();                                    
        }       
        test.stopTest();
    }
    
    static testMethod void testMethod3() {
    
        test.startTest();
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, true)[0];
        PageReference pageRef = Page.ServiceOrderQuoteTool;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('offeringType','Premier Edition');      
        ApexPages.StandardController std = new ApexPages.StandardController(new BigMachines__Quote__c());
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.headerRow[0].record.BigMachines__Quantity__c = 1000;
        if(!obj.userSubscriptions.isEmpty() && obj.userSubscriptions.size() > 0){
            obj.userSubscriptions[0].selected = true;
            obj.userSubscriptions[0].record.Discount__c = 40;     
            obj.userSubscriptions[0].record.List_Price__c = 100; 
            obj.userSubscriptions[0].record.Installation_Fees__c = 1000;  
            obj.quote.Period__c = 'Monthly';                    
        }        
        obj.save();
        test.stopTest();
       /* 
        List<RecordType> rType = [SELECT id FROM RecordType WHERE SObjectType = 'BigMachines__Quote__c' AND DeveloperName = 'Cloud_Quote'];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, false)[0];
        testQuote.BigMachines__Status__c = 'In Progress';
        testQuote.RecordTypeId = rType[0].id;
        testQuote.Period__c = 'Monthly';
        insert testQuote;
        List<Product2> products = TestUtil.createProducts(2, false);
        products[0].Type__c = 'Cloud';
        products[1].Type__c = 'Cloud';
        insert products;
        List<PricebookEntry> pbes = TestUtil.createPriceBookEntries(products, true);
        Pricebook2 standardPB = [select id from Pricebook2 where isstandard=true LIMIT 1];
        testOpp.Pricebook2Id = standardPB.id;
        update testOpp;
        List<BigMachines__Quote_Product__c> quoteProducts = TestUtil.createQuoteProducts(products, false);      
        quoteProducts[0].BigMachines__Quote__c = testQuote.id;
        quoteProducts[1].BigMachines__Quote__c = testQuote.id;
        insert quoteProducts;
        
        obj.quote = testQuote;        
        obj.sectionType = 'User Subscription';
        obj.addMoreProduct();
        */
    }    
    
    /*
    static testMethod void testMethod4() {
        test.startTest();
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, true)[0];
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(testOpp.id , testAccount.id , 1);
        
        PageReference pageRef = Page.ServiceOrderQuoteTool;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('offeringType','Business Edition');      
        ApexPages.StandardController std = new ApexPages.StandardController(list_NewQuotes[0]);
        ServiceOrderQuoteToolController obj = new ServiceOrderQuoteToolController(std);
        obj.headerRow[0].record.BigMachines__Quantity__c = 1000;
        
        obj.save();
        
        Map<String, List<SelectOption>> mapProductVsProductDevices;
        mapProductVsProductDevices = ServiceOrderQuoteToolHelper.getProductVsProductDevicesMap('USD'); 
        system.debug(list_NewQuotes[0].id);
        ServiceOrderQuoteToolHelper.populateQuoteProducts(list_NewQuotes[0],'Business Edition',null,'true',mapProductVsProductDevices);
        
    }
    */
    
}