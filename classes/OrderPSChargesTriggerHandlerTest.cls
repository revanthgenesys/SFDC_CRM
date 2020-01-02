@isTest (seeAllData = true)
private class OrderPSChargesTriggerHandlerTest {

    @isTest static void setup() 
    {
    
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Order__c; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         
        Account accObj = new Account();
        accObj.Phone = '02079918888';                            // Phone
        accObj.Website = 'http://www.hsbc.com';                  // Website
        accObj.SicDesc = 'Bank Holding Companies';               // SIC Description
        accObj.NaicsCode = '551111';                             // NAICS Code
        accObj.YearStarted = '2001';                             // Year Started
        accObj.Name = 'Offices of Bank Holding Companies';       // NAICS Description
        accObj.Tradestyle = 'Hsbc';                              // Tradestyle
        accObj.Type = 'Customer';                                // Type
        accObj.Industry = 'Banking';                             // Industry
        accObj.RecordTypeId  =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('EMG - Customer Record Type').getRecordTypeId();
        insert accObj;
        
        Subsidary__c Ssobj = new Subsidary__c();
        Ssobj.Name = '8325';                             // Subsidary Name
        Ssobj.Active__c = true;                          // Active
        Ssobj.Description__c = '8325 Netherlands';       // Description
        Ssobj.Billing_Invoice_Footer__c = 'Questions';   // Billing Invoice Footer
        insert Ssobj;
        
        Opportunity OppObj = new Opportunity();
        OppObj.Account = accObj;                                                      // Account Name
        OppObj.StageName = '6.Closed';                                                // Stage
        OppObj.Name = 'PS-1-1601388970-HSBC - Contact Centre Transformation Program'; // Opportunity Name
        OppObj.CloseDate = Date.newInstance(2014,03,03);                              // Close Date
        OppObj.Type = 'New logo';                                                     // Type
        OppObj.Probability = 100;                                                     // Probability (%)
        //insert OppObj;
        
        Order__c sobj = new Order__c();
        sobj.Name = 'PS-108817-10126-1';                                              // Order Name
        sobj.Order__c = 'PS-108817-10126';                                            // Order #
        sobj.Status__c = 'Completed';                                                 // Status
        sobj.PO_Number__c = 'DO8590860';                                              // PO Number
        sobj.PO_Date__c = Date.newInstance(2017,03,03);                               // PO Date
        sobj.Order_Type__c = 'Revenue';                                               // Order Type
        sobj.Special_Instructions__c = 'Cons 2678 @ 190.93 and PM 1792.75 @ 206.20';  // Special Instructions
        sobj.Priority__c = '3-Medium';                                                // Priority
        sobj.Payment_Terms__c = 'Due 42 days from invoice date';                      // Payment Terms
        sobj.License_FYM_detail__c = 'PS Orders';                                     // License/FYM detail
        sobj.Opportunity_Type__c = 'GEN_Opportunity_Record_Type_New';                 // Opportunity Type
        sobj.System_Integrator_Information__c = '16101-10126';                        // System Integrator Information
        sobj.OpenAir_Project_Number__c = '108817';                                    // OpenAir Project Number
        sobj.PS_OpenAir_Sales_Order_Line__c = '1-1601388970~DO8590860~Labor';         // PS OpenAir Sales Order Line
        sobj.PS_OpenAir_Sales_Order_Type__c = 'Labor';                                // PS OpenAir Sales Order Type
        sobj.PS_OpenAir_Invoice_Filter__c = 'Time';                                   // PS OpenAir Invoice Filter
        sobj.Bypass_Service_Contract__c = false;                                      // Bypass Service Contract
        sobj.Bypass_Entitlements__c = false;                                          // Bypass Entitlements
        sobj.Exclude_From_Report__c = false;                                          // Exclude From Report
        sobj.Delivery_Method__c = 'No Delivery Required';                             // Delivery Method
        sobj.Total_Order__c = 880975.65;                                              // Total Order $
        sobj.SML_Not_Include__c = false;                                              // SML Not Include
        sobj.Total_Hours__c = 4470.75;                                                // Total Hours
        sobj.Date_Submitted__c = Date.newInstance(2017,03,03);                        // Submitted Date
        sobj.Invoiced__c = true;                                                      // Invoiced?
        sobj.ERP_Hold__c = true;                                                      // ERP Hold
        sobj.Due_Date__c = Date.newInstance(2017,03,03);                              // Due Date
        sobj.Invoice_Number__c = 'INV-8325-30890';                                    // Invoice Number
        sobj.Net_Suite_Order__c = 'SO-8325-27602';                                    // Net Suite Order #
        sobj.Invoice_Date__c = Date.newInstance(2017,03,03);                          // Invoice Date
        sobj.Order_Date__c = Date.newInstance(2017,03,03);                            // Order Date
        sobj.Order_Number__c = 'SO-8325-27602';                                       // Order Number
        sobj.RecordTypeId  = AccountRecordTypeInfo.get('PS Orders').getRecordTypeId();// Record Type
        //sobj.Opportunity__c = OppObj.Id;                                              // Opportunity Name
        //sobj.Subsidaries__c = Ssobj.Id;                                               // Subsidary
        //sobj.End_User_Name__c = accObj.Id;                                            // End User
        //sobj.Sold_To_Name__c = accObj.Id;                                             // Sold To Name
        //sobj.Bill_To_Name__c = accObj.Id;                                             // Bill To
        //sobj.Ship_To_Name__c = accObj.Id;                                             // Ship To Name
        insert sobj;
        
        List<Order_PS_Charges__c> listPsCharges = new List<Order_PS_Charges__c>();
        Order_PS_Charges__c orderpsCharges = new Order_PS_Charges__c();
        orderpsCharges.Name = 'Galluppi, Alessio';                               // Order PS Charge Name
        orderpsCharges.product_Name__c = 'Regular Consulting - (USD All - Org)'; // product Name
        orderpsCharges.Order_PS_Charge__c =sobj.Id;
        orderpsCharges.Hours__c=100;
        orderpsCharges.Minutes__c=10;
        orderpsCharges.Charge_Type__c='T';
        listPsCharges.add(orderpsCharges);
        
        Order_PS_Charges__c orderpsCharges1 = new Order_PS_Charges__c();
        orderpsCharges1.Name = 'Galluppi, Alessio';                               // Order PS Charge Name
        orderpsCharges1.product_Name__c = 'Regular Consulting - (USD All - Org)'; // product Name
        orderpsCharges1.Order_PS_Charge__c =sobj.Id;
        orderpsCharges1.Hours__c=100;
        orderpsCharges1.Minutes__c=10;
        orderpsCharges1.Charge_Type__c='T';
        listPsCharges.add(orderpsCharges1);
        
        insert listPsCharges; 
        
    }
    
    static testMethod void PreEvaluationDocuments_Test() {
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Order__c; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Order__c sobj = new Order__c();
        sobj.Name = 'PS-108817-10126-1';                                              // Order Name
        sobj.Order__c = 'PS-108817-10126';                                            // Order #
        sobj.Status__c = 'Completed';                                                 // Status
        sobj.PO_Number__c = 'DO8590860';                                              // PO Number
        sobj.PO_Date__c = Date.newInstance(2017,03,03);                               // PO Date
        sobj.Order_Type__c = 'Revenue';                                               // Order Type
        sobj.Special_Instructions__c = 'Cons 2678 @ 190.93 and PM 1792.75 @ 206.20';  // Special Instructions
        sobj.Priority__c = '3-Medium';                                                // Priority
        sobj.Payment_Terms__c = 'Due 42 days from invoice date';                      // Payment Terms
        sobj.License_FYM_detail__c = 'PS Orders';                                     // License/FYM detail
        sobj.Opportunity_Type__c = 'GEN_Opportunity_Record_Type_New';                 // Opportunity Type
        sobj.System_Integrator_Information__c = '16101-10126';                        // System Integrator Information
        sobj.OpenAir_Project_Number__c = '108817';                                    // OpenAir Project Number
        sobj.PS_OpenAir_Sales_Order_Line__c = '1-1601388970~DO8590860~Labor';         // PS OpenAir Sales Order Line
        sobj.PS_OpenAir_Sales_Order_Type__c = 'Labor';                                // PS OpenAir Sales Order Type
        sobj.PS_OpenAir_Invoice_Filter__c = 'Time';                                   // PS OpenAir Invoice Filter
        sobj.Bypass_Service_Contract__c = false;                                      // Bypass Service Contract
        sobj.Bypass_Entitlements__c = false;                                          // Bypass Entitlements
        sobj.Exclude_From_Report__c = false;                                          // Exclude From Report
        sobj.Delivery_Method__c = 'No Delivery Required';                             // Delivery Method
        sobj.Total_Order__c = 880975.65;                                              // Total Order $
        sobj.SML_Not_Include__c = false;                                              // SML Not Include
        sobj.Total_Hours__c = 4470.75;                                                // Total Hours
        sobj.Date_Submitted__c = Date.newInstance(2017,03,03);                        // Submitted Date
        sobj.Invoiced__c = true;                                                      // Invoiced?
        sobj.ERP_Hold__c = true;                                                      // ERP Hold
        sobj.Due_Date__c = Date.newInstance(2017,03,03);                              // Due Date
        sobj.Invoice_Number__c = 'INV-8325-30890';                                    // Invoice Number
        sobj.Net_Suite_Order__c = 'SO-8325-27602';                                    // Net Suite Order #
        sobj.Invoice_Date__c = Date.newInstance(2017,03,03);                          // Invoice Date
        sobj.Order_Date__c = Date.newInstance(2017,03,03);                            // Order Date
        sobj.Order_Number__c = 'SO-8325-27602';                                       // Order Number
        sobj.RecordTypeId  = AccountRecordTypeInfo.get('PS Orders').getRecordTypeId();// Record Type
        //sobj.Opportunity__c = OppObj.Id;                                              // Opportunity Name
        //sobj.Subsidaries__c = Ssobj.Id;                                               // Subsidary
        //sobj.End_User_Name__c = accObj.Id;                                            // End User
        //sobj.Sold_To_Name__c = accObj.Id;                                             // Sold To Name
        //sobj.Bill_To_Name__c = accObj.Id;                                             // Bill To
        //sobj.Ship_To_Name__c = accObj.Id;                                             // Ship To Name
        insert sobj;
        
        List<Order_PS_Charges__c> listPsCharges = new List<Order_PS_Charges__c>();
        Order_PS_Charges__c orderpsCharges = new Order_PS_Charges__c();
        orderpsCharges.Name = 'Galluppi, Alessio';                               // Order PS Charge Name
        orderpsCharges.product_Name__c = 'Regular Consulting - (USD All - Org)'; // product Name
        orderpsCharges.Order_PS_Charge__c =sobj.Id;
        orderpsCharges.Hours__c=100;
        orderpsCharges.Minutes__c=10;
        orderpsCharges.Rate__c=111.00;
        orderpsCharges.Charge_Type__c='T';
        listPsCharges.add(orderpsCharges);
        
        Order_PS_Charges__c orderpsCharges1 = new Order_PS_Charges__c();
        orderpsCharges1.Name = 'Galluppi, Alessio';                               // Order PS Charge Name
        orderpsCharges1.product_Name__c = 'Regular Consulting - (USD All - Org)'; // product Name
        orderpsCharges1.Order_PS_Charge__c =sobj.Id;
        orderpsCharges1.Hours__c=100;
        orderpsCharges1.Minutes__c=10;
        orderpsCharges1.Rate__c=140.00;
        orderpsCharges1.Charge_Type__c='T';
        listPsCharges.add(orderpsCharges1);
        
        insert listPsCharges;
        
        Test.startTest();
        UpdateOrderPSChargesBatch  obj = new UpdateOrderPSChargesBatch();
        DataBase.executeBatch(obj); 
        Test.stopTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(sobj);
        OrderSummaryOfPSChargesExt ext = new OrderSummaryOfPSChargesExt(sc);
        //PageReference pageRef = Page.OrderSummaryOfPSCharges;
        //Test.setCurrentPage(pageRef);
    }
    
}