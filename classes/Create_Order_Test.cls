/*
    04/25/2013  Naresh Kumar
    Test Class for the controller class Create_Order
*/
@isTest (seeAllData = true)
private class Create_Order_Test {
	
    static testMethod void myUnitTest(){
        Test.startTest();
        Create_Order.CreateOrderTest();
        Order__c testOrder = TestUtil.createOrders(1, true)[0];
        Opportunity opp = TestUtil.createOpportunities(1,true)[0];
        
        BigMachines__Quote__c quo = TestUtil.createQuotes( 1, opp.id, true)[0];
        quo.BigMachines__Is_Primary__c = true;
        
        
        testOrder.Quote__c = quo.id;   
        testOrder.End_User_Name__c = opp.accountid;
        update testOrder;
        update quo;        
        Map<id,Order__c> ordMap = new Map<id,order__c>();
        ordmap.put(testorder.id,testorder);
        AccountUpdateOrder.updateAccount(ordMap ,ordMap );
        
        Test.StopTest();
    }
    
    
    static testMethod void myUnitTest2(){
        Test.startTest();
        
        BigMachines__Quote__c objQuote = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
        Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
        BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
        BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId from BigMachines__Quote__c where Offering_Type__c = 'PureConnect Cloud' and Shipping_Required__c = true order by lastmodifieddate desc limit 1];
        objQuote.Offering_Type__c = 'PureCloud';
        update objQuote;
        //Create_Order.CreateMultiShipOrder(objQuote.id, objQuote.Offering_Type__c);        
        
        Order__c objOrder = [Select id,Quote__c,Name,End_User_Name__c,Sold_To_Name__c,Maintenance_Start__c,Maintenance_End__c,
			Payment_Terms__c,Opportunity__c,Date_Submitted__c,Due_Date__c,PO_Received_Date__c, 
			PO_Number__c,PO_Date__c,recordtypeid,Genesys_Care_Specialist_Email__c,Genesys_Care_Ops_Email__c,Net_Maint__c,OwnerId,status__c,
            License_FYM_detail__c,Maintenance_Amount__c,Opportunity_Type__c,Numb_of_Maint_Months__c,Net_License__c,Revised_Net_License_Value__c,
            Comments__c,Ship_To_Name__c,Shipping_Contact_Phone_Number__c,Shipping_Contact__c,Shipping_Instructions__c,Shipping_Contact_Email__c,
            Order_Fulfillment_Email_Receipt__c,Delivery_Method__c,CurrencyIsoCode,quote_number__c,Ship_software_via__c,Date_Rejected__c,
            Date_Re_Submitted__c,
			Direct_Sales_Rep_1__c, Indirect_Sales_Rep_1__c,Bill_To_Name__c,Subsidaries__c                             
            from  Order__c where Quote__c != null order by lastmodifieddate desc limit 1];
        Create_Order.CloneOrder(objOrder,objOrder.Quote__c,null);
        
        objQuote = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
        Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
        BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
        BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId from BigMachines__Quote__c where id = :objOrder.Quote__c order by lastmodifieddate desc limit 1];
        objQuote.Offering_Type__c = 'PureCloud';
        update objQuote;
        //Create_Order.CreateMultiShipOrder(objQuote.id, objQuote.Offering_Type__c); 
        
        
        
        
        Test.StopTest();
    }
    
    static testMethod void myUnitTest3(){
        Test.startTest();
        
        Order_Line_Item_Allocation__c olina = [SELECT id, Order_Line_Item__c, Quantity__c, Quote_Product__c, Quote_Product__r.BigMachines__Quote__c,
                Order_Shipping_Location__c, Order_Shipping_Location__r.Address__c, Order_Shipping_Location__r.City__c,Quote_Product__r.BigMachines__Quote__r.Offering_Type__c,
                Order_Shipping_Location__r.State__c FROM Order_Line_Item_Allocation__c
                WHERE Quantity__c > 0 and Quote_Product__c != null order by lastmodifieddate desc limit 1];
        //Create_Order.CreateMultiShipOrder(olina.Quote_Product__r.BigMachines__Quote__c, olina.Quote_Product__r.BigMachines__Quote__r.Offering_Type__c); 
        
        BigMachines__Quote__c  objQuote = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
        Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
        BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
        BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId from BigMachines__Quote__c where id = :olina.Quote_Product__r.BigMachines__Quote__c order by lastmodifieddate desc limit 1];
        objQuote.Offering_Type__c = 'PureConnect Cloud';
        update objQuote;
        //Create_Order.CreateMultiShipOrder(objQuote.id, objQuote.Offering_Type__c); 
        
        
        Test.StopTest();
    }
    
    static testMethod void myUnitTest4(){
        Test.startTest();
        
        Order_Line_Item_Allocation__c olina = [SELECT id, Order_Line_Item__c, Quantity__c, Quote_Product__c, Quote_Product__r.BigMachines__Quote__c,
                Order_Shipping_Location__c, Order_Shipping_Location__r.Address__c, Order_Shipping_Location__r.City__c,Quote_Product__r.BigMachines__Quote__r.Offering_Type__c,
                Order_Shipping_Location__r.State__c FROM Order_Line_Item_Allocation__c
                WHERE Quantity__c > 0 and Quote_Product__c != null order by lastmodifieddate desc limit 1];
        //Create_Order.CreateMultiShipOrder(olina.Quote_Product__r.BigMachines__Quote__c, olina.Quote_Product__r.BigMachines__Quote__r.Offering_Type__c); 
        
        BigMachines__Quote__c  objQuote = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
        Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
        BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
        BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId from BigMachines__Quote__c where id = :olina.Quote_Product__r.BigMachines__Quote__c order by lastmodifieddate desc limit 1];
        
        objQuote.Offering_Type__c = 'PureConnect Subscription';
        update objQuote;
        //Create_Order.CreateMultiShipOrder(objQuote.id, objQuote.Offering_Type__c);
        
        Test.StopTest();
    }
    
    static testMethod void myUnitTest5(){
        Test.startTest();
        
        BigMachines__Quote__c objQuote = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
        Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
        BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
        BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId from BigMachines__Quote__c where Offering_Type__c = 'PureConnect Cloud' and Shipping_Required__c = true order by lastmodifieddate desc limit 1];
        objQuote.Offering_Type__c = 'PureConnect Subscription';
        update objQuote;
        Create_Order.CreateMultiShipOrder(objQuote.id, objQuote.Offering_Type__c);        
        
         Order__c objOrder = [Select id,Quote__c,Name,End_User_Name__c,Sold_To_Name__c,Maintenance_Start__c,Maintenance_End__c,
			Payment_Terms__c,Opportunity__c,Date_Submitted__c,Due_Date__c,PO_Received_Date__c, 
			PO_Number__c,PO_Date__c,recordtypeid,Genesys_Care_Specialist_Email__c,Genesys_Care_Ops_Email__c,Net_Maint__c,OwnerId,status__c,
            License_FYM_detail__c,Maintenance_Amount__c,Opportunity_Type__c,Numb_of_Maint_Months__c,Net_License__c,Revised_Net_License_Value__c,
            Comments__c,Ship_To_Name__c,Shipping_Contact_Phone_Number__c,Shipping_Contact__c,Shipping_Instructions__c,Shipping_Contact_Email__c,
            Order_Fulfillment_Email_Receipt__c,Delivery_Method__c,CurrencyIsoCode,quote_number__c,Ship_software_via__c,Date_Rejected__c,
            Date_Re_Submitted__c,
			Direct_Sales_Rep_1__c, Indirect_Sales_Rep_1__c,Bill_To_Name__c,Subsidaries__c    
			from  Order__c where Quote__c != null order by lastmodifieddate desc limit 1];
        Create_Order.CloneOrder(objOrder,objOrder.Quote__c,null);
        
        objQuote = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
        Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
        BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
        BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId from BigMachines__Quote__c where id = :objOrder.Quote__c order by lastmodifieddate desc limit 1];
        objQuote.Offering_Type__c = 'PureConnect Subscription';
        update objQuote;
        //Create_Order.CreateMultiShipOrder(objQuote.id, objQuote.Offering_Type__c); 
        
        
        
        
        Test.StopTest();
    }
    
    /**static testMethod void myUnitTest6(){
        Test.startTest();
        
        Account_Order_Address__c aOA = [Select id,Quote__c,Order__c from Account_Order_Address__c where Address_Type__c = 'Ship To' and Quote__c != null and Order__c != null order by lastmodifieddate desc limit 1];
        Order__c objOrder = [Select id,Quote__c,Name,End_User_Name__c,Sold_To_Name__c,Maintenance_Start__c,Maintenance_End__c,
Payment_Terms__c,Opportunity__c,Date_Submitted__c,Due_Date__c,PO_Received_Date__c,
PO_Number__c,PO_Date__c,recordtypeid,Genesys_Care_Specialist_Email__c,Genesys_Care_Ops_Email__c,Net_Maint__c,OwnerId,status__c,License_FYM_detail__c,Maintenance_Amount__c,Opportunity_Type__c,Numb_of_Maint_Months__c,Net_License__c,Revised_Net_License_Value__c,Comments__c,Ship_To_Name__c,Shipping_Contact_Phone_Number__c,Shipping_Contact__c,Shipping_Instructions__c,Shipping_Contact_Email__c,Order_Fulfillment_Email_Receipt__c,Delivery_Method__c,CurrencyIsoCode,quote_number__c,Ship_software_via__c,Date_Rejected__c,Date_Re_Submitted__c from  Order__c where id = :aOA.Order__c limit 1];
        
        
        Create_Order.createMultiShipOrderForPureConnect(aOA.Quote__c, objOrder ); 
        
         
        
        Test.StopTest();
    }**/
    
    static testMethod void myUnitTest7(){
        Test.startTest();
        
        Account objAcc = TestDataFactoryForQuoteTool.createAccounts(1)[0];
        
        Opportunity objOpp = TestDataFactoryForQuoteTool.createOpportunties(objAcc.Id, 1)[0];
        
        BigMachines__Quote__c objQuote = TestDataFactoryForQuoteTool.createQuotes(objOpp.Id, objAcc.Id, 1)[0];
        
        objQuote.offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        
        Create_Order.Insert_Orders(objQuote,'Quote Approved','test','EMEA','','New Logo',objOpp);
         
        
        Test.StopTest();
    }
    
    static testMethod void myUnitTest8(){
        Test.startTest();
        
        Account objAcc = TestDataFactoryForQuoteTool.createAccounts(1)[0];
        
        Opportunity objOpp = TestDataFactoryForQuoteTool.createOpportunties(objAcc.Id, 1)[0];
        
        BigMachines__Quote__c objQuote = TestDataFactoryForQuoteTool.createQuotes(objOpp.Id, objAcc.Id, 1)[0];
        
        objQuote.offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.Quote_Business_Type__c = 'Renewal';
        update objQuote;
        
        Create_Order.Insert_Orders(objQuote,'Quote Approved','License only order','EMEA','','New Logo',objOpp);
         
        
        Test.StopTest();
    }
    
    static testMethod void myUnitTest9(){
        Test.startTest();
        
        Account objAcc = TestDataFactoryForQuoteTool.createAccounts(1)[0];
        
        Opportunity objOpp = TestDataFactoryForQuoteTool.createOpportunties(objAcc.Id, 1)[0];
        
        BigMachines__Quote__c objQuote = TestDataFactoryForQuoteTool.createQuotes(objOpp.Id, objAcc.Id, 1)[0];
        
        Order__c objOrder = TestDataFactoryForQuoteTool.createOrders(objQuote.id,objOpp.id,1)[0];
        
        objQuote.offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        
        Create_Order.Update_Orders(objQuote,objOrder.id,'Order Approved','License only order','EMEA','','New Logo',objOpp);
         
        
        Test.StopTest();
    }
    
    static testMethod void myUnitTest10(){
        Test.startTest();
        
        Account objAcc = TestDataFactoryForQuoteTool.createAccounts(1)[0];
        
        Opportunity objOpp = TestDataFactoryForQuoteTool.createOpportunties(objAcc.Id, 1)[0];
        
        BigMachines__Quote__c objQuote = TestDataFactoryForQuoteTool.createQuotes(objOpp.Id, objAcc.Id, 1)[0];
        
        Order__c objOrder = TestDataFactoryForQuoteTool.createOrders(objQuote.id,objOpp.id,1)[0];
        
        List<Product2> listOfProducts = TestUtil.createProducts(2, true, true);
        
        List<Order_Line_Item__c> listOfOLIs = TestUtil.createOrderLines(listOfProducts, objOrder.id, true);
        update objQuote;
        
        Account_Order_Address__c objAOA = new Account_Order_Address__c(Address_Type__c = 'Ship To', 
                             Quote__c = objQuote.id, Shipping_Method_Name__c = 'Economy');
        insert objAOA;        
        
        Create_Order.Insert_Orders(objQuote,'Quote Approved','License only order','EMEA','','New Logo',objOpp);
        Create_Order.createChildOrdersForNRO(objQuote.id);
        Create_Order.CreateOrderAddressFromQuote(objOrder.id);
        Test.StopTest();
    }
    
    static testMethod void myUnitTest11(){
        Test.startTest();
        
        Account objAcc = TestDataFactoryForQuoteTool.createAccounts(1)[0];
        
        Opportunity objOpp = TestDataFactoryForQuoteTool.createOpportunties(objAcc.Id, 1)[0];
        
        BigMachines__Quote__c objQuote = TestDataFactoryForQuoteTool.createQuotes(objOpp.Id, objAcc.Id, 1)[0];
        
        List<BigMachines__Quote_Product__c> listOfQuoteProducts = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.id);
        
        Order__c objOrder = TestDataFactoryForQuoteTool.createOrders(objQuote.id,objOpp.id,1)[0];
        
        List<Product2> listOfProducts = TestUtil.createProducts(2, true, true);
        
        List<Order_Line_Item__c> listOfOLIs = TestUtil.createOrderLines(listOfProducts, objOrder.id, true);
        objQuote.Quote_Business_Type__c = 'Renewal';
        update objQuote;
        
        Account_Order_Address__c objAOA = new Account_Order_Address__c(Address_Type__c = 'Ship To', 
                             Quote__c = objQuote.id, Shipping_Method_Name__c = 'Economy');
        insert objAOA;        
        
        Create_Order.Insert_Orders(objQuote,'Quote Approved','License only order','EMEA','','New Logo',objOpp);
        Create_Order.createChildOrdersForNRO(objQuote.id);
        try{
        Create_Order.buildOrderLI(objOrder, objQuote, listOfQuoteProducts[0], null);
        }catch(Exception ex){}
        Test.StopTest();
    }
    
    
}