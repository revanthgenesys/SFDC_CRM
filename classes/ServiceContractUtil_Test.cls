@isTest(seeAllData = true)
private class ServiceContractUtil_Test {
    
    static testMethod void myUnitTest() {
      Test.startTest();
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        ServiceContract testSC = TestUtil.createServiceContracts(1, false)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];
        testSC.Renewal_Opportunity__c = testOpp.id;
        testSC.Quote_Name__c = testQuote.id;
        insert testSC;
        testOpp.Service_Contract__c = testSC.id;
        update testOpp;
        Order__c testOrder = TestUtil.createOrders(1, testQuote.id, testOpp.id, true)[0];
        Test.stopTest();       
        Set<Order__c> setOrders = new Set<Order__c>();
        setOrders.add(testOrder);
        Map<Id, ServiceContract> mapSC = ServiceContractUtil.checkIfServiceContractExists(setOrders);
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        oppMap.put(testOpp.id, testOpp);
        ServiceContractUtil.createServiceContractLineItems(mapSC, oppMap, '');
        //ServiceContractUtil.closeSCsForCoTermOpps(ServiceContractUtil.getCoTermOpps(ServiceContractUtil.getOrdersOppIds(new Set<Id>{testOrder.Id})));
        ServiceContractUtil.updateContractlineItems(new List<ServiceContract>{testSC}, true);
        
        Account acc = new Account(); 
        acc.name='test'; 
        insert acc;     
        Case cs = new Case(); 
        Entitlement en = new Entitlement();
        en.Name = 'TestEntitlement';
        en.AccountId = acc.id;
        insert en;
        cs.EntitlementId = en.Id;
        insert cs; 
        
    }
    
    
    static testMethod void myUnitTest1() {
      
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0]; 
        
        Order__c testOrder = TestUtil.createOrders(1, testQuote.id, testOpp.id, false)[0];      
        testOrder.License_FYM_Detail__c = 'Hardware Order';
        testOrder.Maintenance_End__c = Date.today().addYears(2);
        testOrder.Maintenance_End__c = testOrder.Maintenance_End__c.addDays(-1);
        testOrder.Status__c = 'Approved';
        testOrder.Sent_to_Customer__c = false;
        insert testOrder;   
        Test.startTest();
        Set<Order__c> setOrders = new Set<Order__c>();
        setOrders.add(testOrder);
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        oppMap.put(testOpp.id, testOpp);
        
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        Product2 objTestProd2 = new Product2();
        objTestProd2.Name='Test Prod2';
        objTestProd2.recordTypeId = rtypes[0].Id;
        objTestProd2.Type__c = 'Genesys Care';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Description = 'test 1';
        objTestProd2.OfferingType__c = 'PureSuccess';
        objTestProd2.APN_Number__c = 'SY';
        objTestProd2.zqu__SKU__c = 'testAeshosh';
        insert objTestProd2;
        
        List<Order_Line_Item__c> list_NewOLI = new List<Order_Line_Item__c>();
        for(Integer ind = 0; ind < 4; ind++){
            Order_Line_Item__c oli = new Order_Line_Item__c();
            oli.Order__c = testOrder.Id;
            
            oli.CurrencyISOCode = 'USD';
            oli.Name = 'test'+ind;
            oli.POB_Type__c = 'Cloud-Uncommitted';
            oli.Maintenance_Start_Date__c = Date.today();
            oli.Maintenance_End_Date__c = Date.today().addDays(364);
            oli.Product__c = objTestProd2.Id;
            list_NewOLI.add(oli);
        }
        insert list_NewOLI;
                
        Map<Id, ServiceContract> orderIdToSCMap = ServiceContractUtil.createServiceContracts(setOrders,oppMap);
        ServiceContractUtil.createServiceContractLineItems(orderIdToSCMap,oppMap,'');      
        
        Map<Id, ServiceContract> map_neeSC = new Map<Id, ServiceContract>();
        ServiceContract scnew;
        for(ServiceContract sc : [SELECT Id, Override_Lines_Date_From_Header__c FROM ServiceContract limit 1]){
            scnew = new ServiceContract(Override_Lines_Date_From_Header__c = true, Id = sc.Id);
            map_neeSC.put(sc.Id, sc);
        }
        update scnew;
        ServiceContractUtil.populateDatesOnSCLineItems(new Map<Id, ServiceContract>{scnew.Id => scnew},map_neeSC);
        Test.stopTest(); 
    }
    
    
    testmethod static void unitTest2(){
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, false)[0];
        testQuote.Offering_Type__c = 'Business Edition';
        testQuote.Quote_Business_Type__c = 'Renewal';
        insert testQuote;
        
        
        
        Account acc = new Account(); 
        acc.name='test'; 
        acc.SAP_Account_Code__c = 'test1';
        insert acc;  
        
        Account acc2 = new Account(); 
        acc2.name='test 2'; 
        acc2.SAP_Account_Code__c = 'test2';
        Test.startTest();
        insert acc2;
        
        
        Id orderGeneralRT = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('General Orders').getRecordTypeId();
        Order__c testOrder = TestUtil.createOrders(1, testQuote.id, testOpp.id, false)[0];
        testOrder.RecordTypeId = orderGeneralRT;
        testOrder.License_FYM_Detail__c = 'Subscription Order';
        testOrder.End_User_Name__c = acc.id;
        testOrder.Sold_To_Name__c = acc2.id;
        testOrder.Maintenance_End__c = Date.today().addYears(2);
        testOrder.Maintenance_End__c = testOrder.Maintenance_End__c.addDays(-1);
        testOrder.Status__c = 'Approved';
        testOrder.Sent_to_Customer__c = false;
        insert testOrder;
        
        Set<Order__c> set_Order = new Set<Order__c>();
        set_Order.add(testOrder);
        Map<Id, Opportunity> map_Opp = new  Map<Id, Opportunity>();
        map_Opp.put(testOpp.id,testOpp); 
        
        Order__c testOrd = [SELECT Id, RecordTypeId, Maintenance_Start__c, Maintenance_End__c, status__c, Order_Category__C, License_FYM_Detail__c, Bypass_Service_Contract__c FROM Order__c WHERE Id =:testOrder.Id];
        
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
        insert objTestProd1;
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Name='Test Prod2';
        objTestProd2.recordTypeId = rtypes[0].Id;
        objTestProd2.Type__c = 'Genesys Care';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Description = 'test 1';
        objTestProd2.OfferingType__c = 'PureSuccess';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.zqu__SKU__c = 'testAeshosh';
        insert objTestProd2;
        
        List<Order_Line_Item__c> list_NewOLI = new List<Order_Line_Item__c>();
        for(Integer ind = 0; ind < 4; ind++){
            Order_Line_Item__c oli = new Order_Line_Item__c();
            oli.Order__c = testOrd.Id;
            
            oli.CurrencyISOCode = 'USD';
            oli.Name = 'test'+ind;
            oli.POB_Type__c = 'Cloud-Uncommitted';
            oli.Maintenance_Start_Date__c = Date.today();
            oli.Maintenance_End_Date__c = Date.today().addDays(364);
            if(ind/2 == 0){
                oli.Product__c = objTestProd1.Id;
            }
            else{                
                oli.Product__c = objTestProd2.Id;
            }
            list_NewOLI.add(oli);
        }
        insert list_NewOLI;
        
        Set<Order__c> setOrders = new Set<Order__c>();
        Order__c testOrd2 = [SELECT Id, Name, Quote__c, License_FYM_detail__c, Maintenance_End__c, End_User_Name__c FROM Order__c WHERE Id =: testOrd.Id];
        setOrders.add(testOrd2);
        ServiceContractUtil.CheckdropSplit(setOrders);
        
        Map<Id, ServiceContract> orderIdToSCMap = ServiceContractUtil.createServiceContracts(set_Order,map_Opp);
        ServiceContractUtil.createServiceContractLineItems(orderIdToSCMap,map_Opp,'');
        
        ServiceContractUtil.createRenewalOpportunities(setOrders, new Set<Id>{testQuote.Id});
        Test.stopTest();
        List<ContractLineItem> newCLIs = new List<ContractLineItem>([SELECT Id FROM ContractLineItem 
                                                                        WHERE ServiceContract.Order__r.Opportunity__r.AccountId != null 
                                                                        AND PricebookEntry.Product2.Type__c = 'Genesys Care'
                                                                        LIMIT 1]);
        ServiceContractUtil.createEntitlements(newCLIs);
        ServiceContractUtil.addFtpAccess(orderIdToSCMap.values());        
    } 
}