/*
* Class Name       : SendEmailNotificationForPSSCTest 
* Description      : Test class for SendEmailNotificationForPSSC. 
* ***************************************************************************************************************
* Developer Note   : *
*    02-Dec-2019   : Nik - Updated test class to explicitly create test objects and call methods on the scoped class rather than relying on triggers to fire and call the class
* ***************************************************************************************************************
*/
@isTest(SeeAllData=true)
private class SendEmailNotificationForPSSCTest {
    
    static Order__c testOrder;
    static Opportunity testOpp;
    static Order_Line_Item__c testOrderLine;
    static ContractLineItem testContractLineItem;
    static ServiceContract testServiceContract;
    
    static testMethod void test1SendEmailNotificationForPSSCNew() {
        List <Order__c> allOrders = new List <Order__c>();
        
        createAllTestData();
        allOrders.add(testOrder);
        
        Util.Bypass_Trigger_Chk = true;

        Test.startTest();
        //Order__c objTestOrder = [SELECT id from Order__c
        //                         WHERE Order_Category__c = 'PureEngage - On Premise'
        //                         AND status__c != 'Completed'
        //                         AND Order_lines_Count__c > 0
        //                         Order by lastmodifieddate limit 1];
                           
        //objTestOrder.status__c = 'Completed';
        testOrder.status__c = 'Completed';
        update testOrder;
        
        SendEmailNotificationForPSSC.sendEmailAlert(allOrders, null, true);
        
        Test.stopTest();
        
        Util.Bypass_Trigger_Chk = false;
    }
    
    static testMethod void test2SendEmailNotificationForPSSCRejected() {
        List <Order__c> allOrders = new List <Order__c>();
        
        createAllTestData();
        allOrders.add(testOrder);

        Util.Bypass_Trigger_Chk = true;

        Test.startTest();
        //Order__c objTestOrder = [SELECT id from Order__c
        //                         WHERE Order_Category__c = 'PureEngage - On Premise'
        //                         AND status__c != 'Completed'
        //                         AND Order_lines_Count__c > 0
        //                         Order by lastmodifieddate limit 1];
        
                   
        //objTestOrder.status__c = 'Rejected';
        //update objTestOrder;
        
        testOrder.status__c = 'Rejected';
        testOrder.Reject_Reasons__c = 'Other';
        testOrder.Reject_Details__c = 'This is a test rejection';
        update testOrder;
        
        SendEmailNotificationForPSSC.sendEmailAlert(allOrders, null, true);
        
        Test.stopTest();
        
        Util.Bypass_Trigger_Chk = false;
    }
    
    static void createAllTestData()
    {
        Util.Bypass_Trigger_Chk = true;    
        
        List <Country__c> testCountry = [SELECT Id, Region__c FROM Country__c WHERE Name = 'United States'];
        
        List<Pricebook2> pBook = [SELECT Id, Name
                                  FROM Pricebook2
                                  WHERE Name =: 'Standard Price Book'];
        
        List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode, Product2.Product_Category__c
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'USD' AND Product2.PS_Contract__c = true AND IsActive = true];
    
        Account acc = new Account(Name='Test PCR Account Diff', Status__c = 'Active', Country__c = testCountry[0].Id);
        insert acc;
    
        List <Product2> testProds = [SELECT Id, PS_Contract__c, Type__c, Description__c FROM Product2 WHERE PS_Contract__c = true AND IsActive = true];
    
        testOpp = new Opportunity(Name = 'Test PSSC Opp', AccountId = acc.id, BusinessPartner__c = acc.id, StageName = '6.Closed', CurrencyIsoCode = 'USD', CloseDate = Date.today());
        
        insert testOpp;
    
        testOrder = new Order__c (Name = 'TestOrderSendPSSCNotice', PS_CAS_Order__c = true, PS_CAS_Related_Oppty_Line_of_Business__c = 'PureEngage', Order_Type__c = 'Revenue', License_FYM_Detail__c = 'PS Orders', Status__c = 'Submitted',
                                    CurrencyIsoCode = 'USD', Sold_To_Name__c = acc.id, End_User_Name__c = acc.id, Opportunity__c = testOpp.Id, Maintenance_Start__c = Date.today(), Maintenance_End__c = Date.today().addMonths(3),
                                    Maintenance_Amount__c = 1000.00);
        insert testOrder;
        
        testOrderLine = new Order_Line_Item__c (Name = 'TestOrderLineSendPSSCNoticeItem', Order__c = testOrder.Id, product__c = testProds[0].Id, Maintenance_Start_Date__c = Date.today(), Maintenance_End_Date__c = Date.today().addMonths(3));
        
        insert testOrderLine;
        
        testServiceContract = new ServiceContract (Name = 'TestServiceContract', StartDate = Date.today(), EndDate = Date.today().addMonths(3), Pricebook2Id = pBook[0].Id);
        
        insert testServiceContract;
        
        testContractLineItem = new ContractLineItem (Order_Line_Item__c = testOrderLine.Id, Maintenance_Start_Date__c = Date.today(), Maintenance_End_Date__c = Date.today().addMonths(3),
                                                     Project_ID__c = 'Test PSSC Send Project', Solution_Name__c = 'Test Solution Name', CX_Platform__c = 'PureEngage Premise', 
                                                     Quantity = 1, UnitPrice = 1000.00, PriceBookEntryId = pbEntry[0].Id, ServiceContractId = testServiceContract.Id);
    
        insert testContractLineItem;
    
        Util.Bypass_Trigger_Chk = false;
    }
}