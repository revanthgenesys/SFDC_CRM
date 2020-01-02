@isTest(SeeAllData=true)
private class Update_Order_WS_Test {

    static testMethod void updateOrderStatus_Test() {      
        Test.StartTest();
          Account testAccount_1 = TestUtil.createAccounts(1, true)[0];         
            
          Order__c ord_1 = new Order__c();
          ord_1.Name = '12345 Test';
          ord_1.Maintenance_Start__c = Date.today();
          ord_1.Maintenance_End__c = Date.today().addYears(1);
          ord_1.Numb_of_Maint_Months__c = 12;
          ord_1.status__c = 'Approved';
          ord_1.Approved_By_Manager__c = false;
          insert ord_1;
          
          Product_Manager_Approval_Group__c pmagroup = new Product_Manager_Approval_Group__c();
          pmagroup.Product_Manager_Email_Addresses__c = 'test@test.com';
          insert pmagroup;
                      
          Product2 prod = new Product2();
          List<RecordType> rtypes_1 = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
          prod.Name = 'Test Prod';
          prod.recordTypeId = rtypes_1[0].Id;
          prod.Type__c = 'Product';
          prod.Approval_Required__c = false;
          prod.Product_Manager_Approval_Group__c = pmagroup.id;
          insert prod;
          
          Product2 prod_1 = new Product2();
          prod_1.Name = 'Test Prod1';
          prod_1.recordTypeId = rtypes_1[0].Id;
          prod_1.Type__c = 'Product';
          prod_1.Approval_Required__c = false;
          prod.Product_Manager_Approval_Group__c = pmagroup.id;
          insert prod_1;
          
          List<Product2> prodList = new List<Product2>();
          prodList.add(prod);
          prodList.add(prod_1);
 
          Order_Line_Item__c oline =  new Order_Line_Item__c();
          oline.Order__c = ord_1.Id;
          oline.Product__c = prod.Id;
          oline.Contract_Line_Update_Status__c = '';
          oline.BigMachines_Quantity__c = 1;
          oline.Sales_Price__c = 10;
          insert oline;
          
          Update_Order_WS.updateOrderStatus(ord_1.id, 'Approved', testAccount_1.id, 1, 'No Shipment Required', 'test');
          Update_Order_WS.buildAndSendApprovalRequiredEmail(prodList,ord_1.Id);
          Update_Order_WS.NotifyApprovalRequiredViaEmail('Test@test.com', 'test@test1.com', 'test', 'test');
          Update_Order_WS.updateOrderStatus(ord_1.id, 'Approved', testAccount_1.id, 1, 'No Shipment', 'test');
          
          Test.stopTest();
   
    }
}