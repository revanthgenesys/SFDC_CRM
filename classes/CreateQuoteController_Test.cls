/*
test class for CreateQuoteController class
added on 06/12/2019

*/

@isTest
private class CreateQuoteController_Test{
    public static Country__c  testCountry;
    public static List<State_Province__c> testStates;
    public static Account testAccount;
    public static List<Contact> testContacts;
    public static List<Product2> testProducts;
    public static List<PricebookEntry> testPriceBookEntries;
    public static List<Opportunity> testOpportunities;
    public static List<ServiceContract> testServiceContracts;
    public static List<ContractLineItem> listContractLineItems;
    public static List<Invoice__c> listInvoices;
    
    @isTest(SeeAllData = true)
    static void test1(){
        try
        {
            // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
            Util.Bypass_Trigger_Chk = true;
            
            List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Product2' AND 
                                                DeveloperName= 'COREProductRecordType'];
            List<Product2> list_ProductsToInsert = new List<Product2>();
            Product2 objTestProd = new Product2();
            objTestProd.Name = 'Test Prod';
            objTestProd.recordTypeId = rtypes[0].Id;
            objTestProd.Type__c = 'Product';
            objTestProd.End_of_Support__c = '01/01/2014';
            objTestProd.IsActive = true;
            objTestProd.Description = 'test 0';
            objTestProd.New_Category__c = 'Services';
            objTestProd.NG2_BRAZIL_BRL_Price__c = 1.0;
            objTestProd.NG5_NA_USD_Price__c = 1.0;
            list_ProductsToInsert.add(objTestProd);
            //insert objTestProd;
            
            Product2 objTestProd1 = new Product2();
            objTestProd1.Name = 'Test Prod1';
            objTestProd1.recordTypeId = rtypes[0].Id;
            objTestProd1.Type__c = 'Product';
            objTestProd1.End_of_Support__c = Date.today().format();
            objTestProd1.IsActive = true;
            objTestProd1.Description = 'test 1';
            objTestProd1.New_Category__c    = 'Services';
            objTestProd1.NG2_BRAZIL_BRL_Price__c = 1.0;
            objTestProd1.NG5_NA_USD_Price__c = 1.0;
            list_ProductsToInsert.add(objTestProd1);
            //insert objTestProd1;
            
            Product2 objTestProd2 = new Product2();
            objTestProd2.Name = 'Test Prod2';
            objTestProd2.recordTypeId = rtypes[0].Id;
            objTestProd2.Type__c = 'Flex Care';
            objTestProd2.IsActive = true;
            objTestProd2.Description = 'test 2';
            objTestProd2.New_Category__c    = 'Services';
            objTestProd2.NG2_BRAZIL_BRL_Price__c = 1.0;
            objTestProd2.NG5_NA_USD_Price__c = 1.0;
            list_ProductsToInsert.add(objTestProd2);
            
            Product2 objTestProd3 = new Product2();
            objTestProd3.Name = 'Test Prod3';
            objTestProd3.recordTypeId = rtypes[0].Id;
            objTestProd3.Type__c = 'Fees';
            objTestProd3.IsActive = true;
            objTestProd3.Description = 'test 3';
            objTestProd3.New_Category__c    = 'Services';
            objTestProd3.NG2_BRAZIL_BRL_Price__c = 1.0;
            objTestProd3.NG5_NA_USD_Price__c = 1.0;
            list_ProductsToInsert.add(objTestProd3);
            
            insert list_ProductsToInsert;
            
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'Brazil' LIMIT 1].Id;
            insert objTestAccount;
            
            Opportunity objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
            objTestOppty.CloseDate = Date.today().addMonths(1);
            objTestOppty.StageName = '1.Recognize Needs';     
            objTestOppty.CurrencyIsoCode = 'BRL';
            objTestOppty.Previous_Maintenance_Rate__c = 0;
            objTestOppty.BusinessPartner__c = objTestAccount.Id;
            objTestOppty.Gene_Care_Specialist__c = UserInfo.getUserId();
            objTestOppty.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' 
                                        AND DeveloperName = 'Genesys_Renewal'].Id;
            insert objTestOppty;
            
            Pricebook2 objStandardPB = [SELECT ID FROM Pricebook2 where IsStandard = true];
            
            List<PricebookEntry> list_TestPBEs = new List<PricebookEntry>();
            for(Integer i=0; i<3; i++) 
            {
                PricebookEntry objTestPBE = new PricebookEntry();
                objTestPBE.Pricebook2Id = objStandardPB.Id;
                objTestPBE.IsActive = true;
                if(i==2)
                    objTestPBE.Product2Id = objTestProd1.Id;
                else
                    objTestPBE.Product2Id = objTestProd.Id;
                objTestPBE.UnitPrice = 10;
                objTestPBE.UseStandardPrice = false;
                if(i==0)
                    objTestPBE.CurrencyIsoCode = 'USD';
                else
                    objTestPBE.CurrencyIsoCode = 'BRL';
                list_TestPBEs.add(objTestPBE);
            }           
            insert list_TestPBEs;
            
            List<ServiceContract> list_TestSCs = new List<ServiceContract>();
            for(Integer i=0; i<4; i++) 
            {
                ServiceContract objTestSC = new ServiceContract();
                objTestSC.Name = 'Test Service Contract';
                objTestSC.Pricebook2id = objStandardPB.Id;
                if(i==0)
                    objTestSC.CurrencyIsoCode = 'USD';
                else
                    objTestSC.CurrencyIsoCode = 'BRL';
                list_TestSCs.add(objTestSC);
            }           
            insert list_TestSCs;
            
            List<ContractLineItem> list_TestCLIs = new List<ContractLineItem>();
            for(Integer i=0; i<4; i++) 
            {
                ContractLineItem objTestCLI = new ContractLineItem();
                objTestCLI.ServiceContractId = list_TestSCs[i].Id;
                objTestCLI.Quantity = 5;
                objTestCLI.UnitPrice = 100;
                objTestCLI.PricebookEntryId = list_TestPBEs[(i>2 ? 2:i)].Id;
                objTestCLI.Lic_Invoice__c = '123';
                if(i==0)
                    objTestCLI.Sales_Order__c = '123';
                else
                    objTestCLI.Sales_Order__c = '';
                objTestCLI.Maintenance_Start_Date__c = Date.today() - 1;
                list_TestCLIs.add(objTestCLI);
            }
            insert list_TestCLIs;
            
            Test.setCurrentPageReference(new PageReference('/apex/CreateQuote?oppId=' + objTestOppty.Id));
            CreateQuoteController objCreateQuoteCont = new CreateQuoteController();
            
            objCreateQuoteCont.quote.Service_Level__c  = 'Business Care';
            objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today().addYears(2);
            objCreateQuoteCont.quote.Maintenance_End_Date__c = Date.today().addYears(1);
            objCreateQuoteCont.save();
            objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today();
            objCreateQuoteCont.quote.Previous_Maint_Rate__c = null;
            objCreateQuoteCont.save();
            
            List<BigMachines__Quote_Product__c> list_QPInsert = new List<BigMachines__Quote_Product__c>();
            // Flex Care
            list_QPInsert.add(new BigMachines__Quote_Product__c(BigMachines__Product__c = objTestProd2.Id,BigMachines__Sales_Price__c = 2,
                            BigMachines__Quote__c = objCreateQuoteCont.quote.Id,BigMachines__Quantity__c = 1));
            // Fees
            list_QPInsert.add(new BigMachines__Quote_Product__c(BigMachines__Product__c = objTestProd3.Id,BigMachines__Sales_Price__c = 2,
                            BigMachines__Quote__c = objCreateQuoteCont.quote.Id,BigMachines__Quantity__c = 1));
            // Normal Product
            list_QPInsert.add(new BigMachines__Quote_Product__c(BigMachines__Product__c = objTestProd1.Id,BigMachines__Sales_Price__c = 2,
                            BigMachines__Quote__c = objCreateQuoteCont.quote.Id,BigMachines__Quantity__c = 1));
            insert list_QPInsert;
            Test.startTest();
            BigMachines__Quote__c objQuoteForController = [SELECT Id,CurrencyISOCode,BigMachines__Status__c,Service_Level__c,
                                                    Maintenance_End_Date__c,Cover_Letter_Text__c
                                                    FROM BigMachines__Quote__c WHERE Id = :objCreateQuoteCont.quote.Id];
            
            Test.setCurrentPageReference(new PageReference('/apex/ConfigurationPage?Id=' + objQuoteForController.Id));
            
         /*   ConfigurationExt objConfig = new ConfigurationExt(new ApexPages.StandardController(objQuoteForController));
            
            objConfig.addFlexCareLine();
            objConfig.strIndex = '0';
            objConfig.removeFlexCareLine();
            objConfig.addFlexCareLine();
            if(objConfig.list_FlexCare.size() > 0)
                objConfig.list_FlexCare[0].blnIsSelected = true;
            
            for(ConfigurationExt.ProductSelectRow objRow : objConfig.list_Fees)
                objRow.blnIsSelected = true;
                
            objConfig.saveBtnHandler();
            
            if(objConfig.list_ServiceLevelOptions.size() > 0)
                objConfig.strServiceLevelSelected = objConfig.list_ServiceLevelOptions[0].getValue();
            
            if(objConfig.list_FlexCare.size() > 0)
            {
                objConfig.list_FlexCare[0].objQuoteProduct.Maintenance_Start_Date__c = Date.today();
                objConfig.list_FlexCare[0].objQuoteProduct.Maintenance_End_Date__c = Date.today() - 1;
                objConfig.list_FlexCare[0].objQuoteProduct.BigMachines__Sales_Price__c = 100;
                objConfig.list_FlexCare[0].objQuoteProduct.Period_Number__c = '1';
                objConfig.list_FlexCare[0].strProductId = objConfig.list_FlexCareProductOptions[0].getValue();
            }
            
            for(ConfigurationExt.ProductSelectRow objRow : objConfig.list_Fees)
            {
                objRow.objQuoteProduct.Maintenance_Start_Date__c = Date.today();
                objRow.objQuoteProduct.Maintenance_End_Date__c = Date.today() - 1;
                objRow.objQuoteProduct.BigMachines__Sales_Price__c = 100;
            }
            
            objConfig.saveBtnHandler();
            
            if(objConfig.list_FlexCare.size() > 0)
                objConfig.list_FlexCare[0].objQuoteProduct.Maintenance_End_Date__c = Date.today() + 7;
            
            for(ConfigurationExt.ProductSelectRow objRow : objConfig.list_Fees)
                objRow.objQuoteProduct.Maintenance_End_Date__c = Date.today() + 7;
            objConfig.saveBtnHandler();   
            objConfig.objQuote.Has_Extended_End_Of_Support__c = true;
            objConfig.objQuote.Has_Reinstatement__c = true;
            
            objConfig.saveBtnHandler();
            objConfig.initializeData();
            objConfig.objQuote.BigMachines__Status__c = 'Quote Approval Pending';
            objCreateQuoteCont.reviseBtnHandler();
            objConfig.saveBtnHandler(); */
            
            AddQuoteProductsExt objAddProd = new AddQuoteProductsExt(new ApexPages.StandardController(new BigMachines__Quote__c()));
            objAddProd = new AddQuoteProductsExt(new ApexPages.StandardController(objQuoteForController));
            
            objAddProd.saveBtnHandler();
            objAddProd.objCurrentQP.BigMachines__Product__c = objTestProd.Id;
            objAddProd.objQuote.Sold_To_Name__c = objTestAccount.Id;
            objAddProd.objQuote.End_User_ID__c = objTestAccount.Id;
            objAddProd.objCurrentQP.Original_Qty__c = 1;
            objAddProd.objCurrentQP.Current_Qty__c = 1;
            objAddProd.objCurrentQP.Previous_Line_Maintenance_Value__c = 1000;
            objAddProd.objCurrentQP.Original_Net_License_Value__c = 1000;
            objAddProd.objCurrentQP.Revised_Net_License_Value__c = 1000;
            objAddProd.objCurrentQP.Maintenance_Start_Date__c = Date.today();
            objAddProd.saveBtnHandler();
            objAddProd.getIsQuoteUnLocked();
            objAddProd.objQuote.BigMachines__Status__c = 'Quote In Progress';
            objAddProd.getIsQuoteUnLocked();
            objAddProd.strQPIndex = '0';
            objAddProd.removeQuotePorduct();
            
            List<Quote_Service_Contracts__c> list_TestQSCs = new List<Quote_Service_Contracts__c>();
            for(Integer i=0; i<3; i++) 
            {
                Quote_Service_Contracts__c objTestQSC = new Quote_Service_Contracts__c();
                objTestQSC.Quote__c = objQuoteForController.Id;
                objTestQSC.Service_Contract__c = list_TestSCs[i].Id;
                list_TestQSCs.add(objTestQSC);
            }           
            insert list_TestQSCs;
            
            delete ([SELECT Id FROM Quote_Period__c WHERE Quote__c = :objQuoteForController.Id]);
            
            Test.setCurrentPageReference(new PageReference('/apex/CreateQuote?Id=' + objQuoteForController.Id));
            objCreateQuoteCont = new CreateQuoteController();
            objCreateQuoteCont.quote.BigMachines__Status__c = 'Quote In Progress';
            update objCreateQuoteCont.quote;
            objCreateQuoteCont.syncQuoteProducts();
            
            objCreateQuoteCont.futureQuoteBtnHandler();
            objCreateQuoteCont.doCalculations();
            
            objCreateQuoteCont.quote.Maintenance_Start_Date__c = null;
            objCreateQuoteCont.quote.Maintenance_End_Date__c = null;
            
            objCreateQuoteCont.applyQuotePeriod();
            objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today().addYears(2);
            objCreateQuoteCont.quote.Maintenance_End_Date__c = Date.today().addYears(1);
            objCreateQuoteCont.applyQuotePeriod();
            objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today();
            objCreateQuoteCont.applyQuotePeriod();
            objCreateQuoteCont.applyQuotePeriod();
            objCreateQuoteCont.cancelEditofQuotePeriod();
            objCreateQuoteCont.editofQuotePeriod();
            objCreateQuoteCont.strQPIndex = '0';
            objCreateQuoteCont.removeQuotePeriod();
            objCreateQuoteCont.addQuotePeriod();
            objCreateQuoteCont.strQPIndex = '1';
            objCreateQuoteCont.removeQuotePeriod();
            objCreateQuoteCont.addQuotePeriod();
            objCreateQuoteCont.saveQuotePeriod();
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].Start_Date__c = Date.today() + 1;
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].End_Date__c = Date.today();
            objCreateQuoteCont.saveQuotePeriod();
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].Start_Date__c = Date.today() - 1;
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[1].Start_Date__c = Date.today();
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[1].End_Date__c = Date.today() + 1;
            objCreateQuoteCont.saveQuotePeriod();
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].Start_Date__c = Date.today();
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].End_Date__c = Date.today() + 1;
            objCreateQuoteCont.saveQuotePeriod();
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].Start_Date__c = Date.today();
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].End_Date__c = Date.today() + 5;
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[1].Start_Date__c = Date.today() + 7;
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[1].End_Date__c = objCreateQuoteCont.quote.Maintenance_End_Date__c;
            objCreateQuoteCont.saveQuotePeriod();
            objCreateQuoteCont.list_QuotePeriodsBeingEdited[1].Start_Date__c = Date.today() + 6;
            objCreateQuoteCont.saveQuotePeriod();
            
            objCreateQuoteCont.next();
            objCreateQuoteCont.previous();
            objCreateQuoteCont.first();
            objCreateQuoteCont.last();
            objCreateQuoteCont.getPageNumStr();
            
            objCreateQuoteCont.viewOpportunity();
            
            objCreateQuoteCont.upgradeProduct();
            objCreateQuoteCont.objFromProduct.BigMachines__Product__c = objTestProd.Id;
            objCreateQuoteCont.objToProduct.BigMachines__Product__c = objTestProd.Id;
            objCreateQuoteCont.upgradeProduct();
            
            for(Quote_Period__c objQP : objCreateQuoteCont.list_QuotePeriods)
            {
                objQP.Default_Period_Care_Rate__c = 5;
                objQP.Default_Increase__c = 5;
                objQP.Quarterly_Semi_Annual_Fee__c = 5;
                objQP.Partner_to_Partner_Uplift_Fee__c = 5;
                objQP.KPI1__c = 1;
                objQP.KPI2__c = 2;
            }
            if(objCreateQuoteCont.list_QuotePeriods.size() > 0)
            {
                update objCreateQuoteCont.list_QuotePeriods;
                objCreateQuoteCont.applyRates();
            }
            
            objCreateQuoteCont.quote.Increase_type__c = 'Genesys Care Rate';
            objCreateQuoteCont.initializeRates();
            
            objCreateQuoteCont.checkUncheckAll();
            objCreateQuoteCont.toggleOverrideAll();
            objCreateQuoteCont.toggleOverrideAllRevisedNet();
            objCreateQuoteCont.toggleOverrideAllPreviousMaintenance();
            objCreateQuoteCont.applyRevisedNetUpliftToLines();
            objCreateQuoteCont.removeRevisedNetUpliftFromLines();
            
            objCreateQuoteCont.save();
            
            //objCreateQuoteCont.refresh();
            for(CreateQuoteController.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                obj.selected = true;
            }
            objCreateQuoteCont.refreshSelected();
            
            objCreateQuoteCont.strToDelete = 'yes';
            /*List<BigMachines__Quote_Product__c> list_ToDelete = [SELECT Id,Service_Contract_Line_ID__c FROM BigMachines__Quote_Product__c 
                    WHERE BigMachines__Quote__c != :objCreateQuoteCont.quote.Id AND BigMachines__Quote__r.Name LIKE '2014%' AND
                        Service_Contract_Line_ID__c != null ORDER BY BigMachines__Quote__r.Name LIMIT 1];
            if(list_ToDelete.size() > 0)
            {
                objCreateQuoteCont.quoteProductIdToBeDeleted = list_ToDelete[0].Id;
                objCreateQuoteCont.strSCLIIdBeingDeleted =  list_ToDelete[0].Service_Contract_Line_ID__c;
                objCreateQuoteCont.deleteQuoteProduct();
            }*/
            BigMachines__Quote_Product__c objQPToDelete = new BigMachines__Quote_Product__c(BigMachines__Product__c = objTestProd1.Id,BigMachines__Sales_Price__c = 2,
                        BigMachines__Quote__c = objCreateQuoteCont.quote.Id,BigMachines__Quantity__c = 1,Service_Contract_Line_ID__c = list_TestCLIs[3].Id);
            insert objQPToDelete;
            objCreateQuoteCont.quoteProductIdToBeDeleted = objQPToDelete.Id;
            objCreateQuoteCont.strSCLIIdBeingDeleted =  objQPToDelete.Service_Contract_Line_ID__c;
            objCreateQuoteCont.deleteQuoteProduct();
            
            
            objCreateQuoteCont.futureQuoteBtnHandler();
            objCreateQuoteCont.cloneBtnHandler();
            objCreateQuoteCont.reviseBtnHandler();
            objCreateQuoteCont.reviseMajorBtnHandler();
            objCreateQuoteCont.reviseMinorBtnHandler();
            
            objCreateQuoteCont.adjustDatesOnPeriods();
            
            objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today() + 1;
            objCreateQuoteCont.quote.Maintenance_End_Date__c = Date.today();
            objCreateQuoteCont.doCalculations();
            objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today();
            objCreateQuoteCont.quote.Maintenance_End_Date__c = Date.today().addYears(1);            
            objCreateQuoteCont.doCalculations();

            for(CreateQuoteController.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                obj.record.Original_Qty__c = 3;
                obj.record.Current_Qty__c = 3;
                obj.record.Revised_Net_Override__c = false;
                obj.record.Amount_Due_Override__c = false;
                obj.record.Previous_Line_Maintenance_Value__c = 1000;
                obj.record.Original_Net_License_Value__c = 1000;
                obj.record.Revised_Net_Override__c = true;
            }
            
            objCreateQuoteCont.finalizeRevisedNet();
            
            Test.stopTest();
            
            /*
            objCreateQuoteCont.list_QuoteProducts[1].record.Current_Qty__c = 2;
            objCreateQuoteCont.doCalculations();
            objCreateQuoteCont.list_QuoteProducts[1].record.Current_Qty__c = 3;
            objCreateQuoteCont.list_QuoteProducts[0].record.Maintenance_Start_Date__c = Date.today() + 7;
            objCreateQuoteCont.doCalculations();
            objCreateQuoteCont.list_QuoteProducts[0].record.Maintenance_Start_Date__c = Date.today() + 1;
            objCreateQuoteCont.doCalculations();
            objCreateQuoteCont.quote.Increase_type__c = 'Genesys Care Rate';
            objCreateQuoteCont.list_QuoteProducts[1].record.Revised_Net_License_Value__c = 1000;
           
            objCreateQuoteCont.list_QuoteProducts[0].record.Current_Qty__c = 2;
            objCreateQuoteCont.doCalculations();
            objCreateQuoteCont.list_QuoteProducts[0].record.Current_Qty__c = 3;
            objCreateQuoteCont.list_QuoteProducts[0].record.Maintenance_Start_Date__c = Date.today() + 7;
            objCreateQuoteCont.doCalculations();
            objCreateQuoteCont.list_QuoteProducts[0].record.Maintenance_Start_Date__c = Date.today() + 1;
            objCreateQuoteCont.doCalculations();
            objCreateQuoteCont.quote.Increase_type__c = 'Genesys Care Rate';
            objCreateQuoteCont.list_QuoteProducts[0].record.Revised_Net_License_Value__c = 1000;
            
            objCreateQuoteCont.quote.Previous_Maint_Rate__c = null;
            objCreateQuoteCont.submitForApprovalBtnHandler();
            
            objCreateQuoteCont.quote.Service_Level__c  = 'Business Care';
            objCreateQuoteCont.save();

            objCreateQuoteCont.quote.Current_Maint_Rate__c = 10;
            objCreateQuoteCont.quote.Previous_Maint_Rate__c = 9;
            objCreateQuoteCont.save();
            objCreateQuoteCont.submitForApprovalBtnHandler();
            
            
            
            if(objCreateQuoteCont.list_QuoteProducts.size() > 0)
            {
                objCreateQuoteCont.list_QuoteProducts[0].record.Contract_Line_Update_Status__c = 'Drop';
            }
            objCreateQuoteCont.doCalculations();
            objCreateQuoteCont.quote.LRA_Uplift__c = 5;
            objCreateQuoteCont.quote.LDA_Uplift__c = 7;
            objCreateQuoteCont.doCalculations();
            if(objCreateQuoteCont.list_QuoteProducts.size() > 0)
            {
                objCreateQuoteCont.list_QuoteProducts[0].record.Reinstatement__c = true;
                objCreateQuoteCont.list_QuoteProducts[0].record.Extended_End_of_Support__c = true;
            }
            objCreateQuoteCont.doCalculations();
            objCreateQuoteCont.quote.Reinstatement__c = 10;
            objCreateQuoteCont.quote.Reinstated_Date__c = Date.today() + 5;
            objCreateQuoteCont.doCalculations();
            objCreateQuoteCont.quote.Extended_End_of_Support_Percent__c = 10;
            objCreateQuoteCont.quote.Increase_type__c = 'Increase Percentage';
            objCreateQuoteCont.doCalculations();
            objCreateQuoteCont.checkUncheckAllReinstatement();
            objCreateQuoteCont.applyLRAUpliftToLines();
            objCreateQuoteCont.removeLRAUpliftFromLines();
            
            objCreateQuoteCont.submitOrderBtnHandler();
            objCreateQuoteCont.quote.Order_PO_Number__c = '123';
            objCreateQuoteCont.quote.Order_PO_Date__c = Date.today() + 1;
            Attachment objAttach = new Attachment(ParentId=objCreateQuoteCont.quote.Id,Name='test',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert objAttach;
            objCreateQuoteCont.submitOrderBtnHandler();
            
            objCreateQuoteCont.quote.CurrencyISOCode = 'USD';
            objCreateQuoteCont.changeQuoteCurrency();
            
            ExportToExcelController objExportCont = new ExportToExcelController();
            objExportCont.dummyMethod();
            ProposalOptionsExt objProposalOptions = new ProposalOptionsExt(new ApexPages.StandardController(objQuoteForController));
            objProposalOptions.viewContract();
            ProposalPdfInlineDataExt objProposalPDf = new ProposalPdfInlineDataExt(new ApexPages.StandardController(objQuoteForController));
            objQuoteForController.Group_Product_By__c = 'Part Number';
            objQuoteForController.Hide_Periods__c = true;
            update objQuoteForController;
            objProposalPDf = new ProposalPdfInlineDataExt(new ApexPages.StandardController(objQuoteForController));
            objQuoteForController.Group_Product_By__c = 'Invoice Number';
            objQuoteForController.Show_Product_Code__c = true;
            update objQuoteForController;
            objProposalPDf = new ProposalPdfInlineDataExt(new ApexPages.StandardController(objQuoteForController));
            
            // FYM Re-Importing button functionality
            objCreateQuoteCont.reimportBtnHandler();
            
            MyOutputTextController objOTCont = new MyOutputTextController();
            objOTCont.decCurrencyValue = 1000000000;
            objOTCont.blnIsHideDecimals = true;
            objOTCont.strCurrencyCode = 'USD';
            objOTCont.getFormattedValue();
            objOTCont.blnIsHideDecimals = false;
            objOTCont.getFormattedValue();
            objOTCont.strCurrencyCode = 'EUR';
            objOTCont.decCurrencyValue = -100.33;
            objOTCont.getFormattedValue();
            objOTCont.decCurrencyValue = null;
            objOTCont.getFormattedValue();
       
            Test.setCurrentPageReference(new PageReference('/apex/CreateRenewalProductUpgrade?Id=' + objQuoteForController.Id));
            CreateRenewalProductUpgrade cc = new CreateRenewalProductUpgrade(); 
             */
        }
        catch(CalloutException ex)
        {}
    }
    
    @isTest
    static void testCreateQuoteController1(){
        // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true; 
        setupTestData('PureEngage', 'Customer');
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('/apex/CreateQuote?oppId=' + testOpportunities[0].Id));
        CreateQuoteController objCreateQuoteCont = new CreateQuoteController();
        
        objCreateQuoteCont.quote.Service_Level__c  = 'Business Care';
        objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today().addYears(2);
        objCreateQuoteCont.quote.Maintenance_End_Date__c = Date.today().addYears(1);
        objCreateQuoteCont.save();
        objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today();
        objCreateQuoteCont.quote.Previous_Maint_Rate__c = null;
        objCreateQuoteCont.quote.BigMachines__Status__c = 'Quote In Progress';
        objCreateQuoteCont.save();

        String quoteId = objCreateQuoteCont.quote.Id;
    
        Test.setCurrentPageReference(new PageReference('/apex/CreateQuote?Id=' + quoteId));
        objCreateQuoteCont = new CreateQuoteController();
        objCreateQuoteCont.syncQuoteProducts();
        
        objCreateQuoteCont.futureQuoteBtnHandler();
        objCreateQuoteCont.doCalculations();
        
        objCreateQuoteCont.quote.Maintenance_Start_Date__c = null;
        objCreateQuoteCont.quote.Maintenance_End_Date__c = null;
        objCreateQuoteCont.applyQuotePeriod();

        objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today().addYears(2);
        objCreateQuoteCont.quote.Maintenance_End_Date__c = Date.today().addYears(1);
        objCreateQuoteCont.applyQuotePeriod();

        objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today();
        objCreateQuoteCont.applyQuotePeriod();

        objCreateQuoteCont.cancelEditofQuotePeriod();
        objCreateQuoteCont.editofQuotePeriod();
        objCreateQuoteCont.strQPIndex = '0';
        objCreateQuoteCont.removeQuotePeriod();
        objCreateQuoteCont.addQuotePeriod();
        objCreateQuoteCont.strQPIndex = '1';
        objCreateQuoteCont.removeQuotePeriod();
        objCreateQuoteCont.addQuotePeriod();
        objCreateQuoteCont.saveQuotePeriod();

        objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].Start_Date__c = Date.today() + 1;
        objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].End_Date__c = Date.today();
        objCreateQuoteCont.saveQuotePeriod();

        objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].Start_Date__c = Date.today() - 1;
        objCreateQuoteCont.list_QuotePeriodsBeingEdited[1].Start_Date__c = Date.today();
        objCreateQuoteCont.list_QuotePeriodsBeingEdited[1].End_Date__c = Date.today() + 1;
        objCreateQuoteCont.saveQuotePeriod();

        objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].Start_Date__c = Date.today();
        objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].End_Date__c = Date.today() + 1;
        objCreateQuoteCont.saveQuotePeriod();

        objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].Start_Date__c = Date.today();
        objCreateQuoteCont.list_QuotePeriodsBeingEdited[0].End_Date__c = Date.today() + 5;
        objCreateQuoteCont.list_QuotePeriodsBeingEdited[1].Start_Date__c = Date.today() + 7;
        objCreateQuoteCont.list_QuotePeriodsBeingEdited[1].End_Date__c = objCreateQuoteCont.quote.Maintenance_End_Date__c;
        objCreateQuoteCont.saveQuotePeriod();

        objCreateQuoteCont.list_QuotePeriodsBeingEdited[1].Start_Date__c = Date.today() + 6;
        objCreateQuoteCont.saveQuotePeriod();
            
        objCreateQuoteCont.next();
        objCreateQuoteCont.previous();
        objCreateQuoteCont.first();
        objCreateQuoteCont.last();
        objCreateQuoteCont.getPageNumStr();
        
        objCreateQuoteCont.viewOpportunity();
        Test.stopTest();    
        objCreateQuoteCont.upgradeProduct();
        objCreateQuoteCont.objFromProduct.BigMachines__Product__c = testProducts[3].Id;
        objCreateQuoteCont.objToProduct.BigMachines__Product__c = testProducts[8].Id;
        objCreateQuoteCont.upgradeProduct();
        
        for(Quote_Period__c objQP : objCreateQuoteCont.list_QuotePeriods){
            objQP.Default_Period_Care_Rate__c = 5;
            objQP.Default_Increase__c = 5;
            objQP.Quarterly_Semi_Annual_Fee__c = 5;
            objQP.Partner_to_Partner_Uplift_Fee__c = 5;
            objQP.KPI1__c = 1;
            objQP.KPI2__c = 2;
        }
        
        if(objCreateQuoteCont.list_QuotePeriods.size() > 0){
            update objCreateQuoteCont.list_QuotePeriods;
            objCreateQuoteCont.applyRates();
        }
            
        objCreateQuoteCont.quote.Increase_type__c = 'Genesys Care Rate';
        objCreateQuoteCont.initializeRates();
        
        objCreateQuoteCont.checkUncheckAll();
        objCreateQuoteCont.toggleOverrideAll();
        objCreateQuoteCont.toggleOverrideAllRevisedNet();
        objCreateQuoteCont.toggleOverrideAllPreviousMaintenance();
        objCreateQuoteCont.applyRevisedNetUpliftToLines();
        objCreateQuoteCont.removeRevisedNetUpliftFromLines();
        
        objCreateQuoteCont.save();
            
        //objCreateQuoteCont.refresh();
        for(CreateQuoteController.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts){
            obj.selected = true;
        }
        objCreateQuoteCont.refreshSelected();
        
        objCreateQuoteCont.strToDelete = 'yes';
    
    
        BigMachines__Quote_Product__c objQPToDelete = new BigMachines__Quote_Product__c(BigMachines__Product__c = testProducts[4].Id ,BigMachines__Sales_Price__c = 2,
                                                                                        BigMachines__Quote__c = objCreateQuoteCont.quote.Id, BigMachines__Quantity__c = 1,
                                                                                        Service_Contract_Line_ID__c = listContractLineItems[1].Id);
        insert objQPToDelete;
        objCreateQuoteCont.quoteProductIdToBeDeleted = objQPToDelete.Id;
        objCreateQuoteCont.strSCLIIdBeingDeleted =  objQPToDelete.Service_Contract_Line_ID__c;
        objCreateQuoteCont.deleteQuoteProduct();
        
        ProposalOptionsExt objProposalOptions = new ProposalOptionsExt(new ApexPages.StandardController(objCreateQuoteCont.quote));
        objProposalOptions.viewContract();
        ProposalPdfInlineDataExt objProposalPDf = new ProposalPdfInlineDataExt(new ApexPages.StandardController(objCreateQuoteCont.quote));
        objCreateQuoteCont.quote.Group_Product_By__c = 'Part Number';
        objCreateQuoteCont.quote.Hide_Periods__c = true;
        update objCreateQuoteCont.quote;
        objProposalPDf = new ProposalPdfInlineDataExt(new ApexPages.StandardController(objCreateQuoteCont.quote));
        objCreateQuoteCont.quote.Group_Product_By__c = 'Invoice Number';
        objCreateQuoteCont.quote.Show_Product_Code__c = true;
        update objCreateQuoteCont.quote;
        objProposalPDf = new ProposalPdfInlineDataExt(new ApexPages.StandardController(objCreateQuoteCont.quote));
        
        /*
        objCreateQuoteCont.futureQuoteBtnHandler();
        objCreateQuoteCont.cloneBtnHandler();
        objCreateQuoteCont.reviseBtnHandler();
        objCreateQuoteCont.reviseMajorBtnHandler();
        objCreateQuoteCont.reviseMinorBtnHandler();
        
        objCreateQuoteCont.adjustDatesOnPeriods();
            
        objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today() + 1;
        objCreateQuoteCont.quote.Maintenance_End_Date__c = Date.today();
        objCreateQuoteCont.doCalculations();
        
        objCreateQuoteCont.quote.Maintenance_Start_Date__c = Date.today();
        objCreateQuoteCont.quote.Maintenance_End_Date__c = Date.today().addYears(1);            
        objCreateQuoteCont.doCalculations();

        for(CreateQuoteController.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts){
            obj.record.Original_Qty__c = 3;
            obj.record.Current_Qty__c = 3;
            obj.record.Revised_Net_Override__c = false;
            obj.record.Amount_Due_Override__c = false;
            obj.record.Previous_Line_Maintenance_Value__c = 1000;
            obj.record.Original_Net_License_Value__c = 1000;
            obj.record.Revised_Net_Override__c = true;
        }
            
        objCreateQuoteCont.finalizeRevisedNet();
        */
    }
    
    
    @isTest
    static void testCreateQuoteController2(){
        setupTestData('PureConnect', 'Partner');
        
        // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('/apex/CreateQuote?oppId=' + testOpportunities[0].Id));
        CreateQuoteController objCreateQuoteCont = new CreateQuoteController();
        objCreateQuoteCont.quote.Service_Level__c  = 'Business Care';
        objCreateQuoteCont.quote.Maintenance_Start_Date__c = testOpportunities[0].CloseDate.addDays(2);
        objCreateQuoteCont.quote.Maintenance_End_Date__c = testOpportunities[0].CloseDate.addDays(2).addMonths(24);
        objCreateQuoteCont.quote.Previous_Maint_Rate__c = null;
        objCreateQuoteCont.quote.Genesys_Care_Rep_Name__c = UserInfo.getUserId();
        objCreateQuoteCont.save();
        Quote_Service_Contracts__c cotermServiceContract =new Quote_Service_Contracts__c(Quote__c = objCreateQuoteCont.quote.Id, Service_Contract__c = testServiceContracts[1].Id);
        insert cotermServiceContract;
        objCreateQuoteCont.syncQuoteProducts();
        objCreateQuoteCont.reimportBtnHandler();
        objCreateQuoteCont.fetchQuotePeriods();
        objCreateQuoteCont.list_QuotePeriods = new List<Quote_Period__c>();
        objCreateQuoteCont.applyQuotePeriod();         
        objCreateQuoteCont.applyLRAUpliftToLines();
        objCreateQuoteCont.removeLRAUpliftFromLines();
        objCreateQuoteCont.quote.CurrencyISOCode = 'CAD';
        objCreateQuoteCont.changeQuoteCurrency();
        objCreateQuoteCont.applyELAChange();
        
        Test.setCurrentPageReference(new PageReference('/apex/CreateQuote?Id=' + objCreateQuoteCont.quote.Id));
        objCreateQuoteCont = new CreateQuoteController();
        objCreateQuoteCont.objFromProduct.BigMachines__Product__c = testProducts[5].Id;
        objCreateQuoteCont.objToProduct.BigMachines__Product__c = testProducts[9].Id;
        objCreateQuoteCont.upgradeProduct();
        objCreateQuoteCont.applyPureConnectUpgrades();
        
        // CreateQuoteController anotherCreateQuoteController = new CreateQuoteController(objCreateQuoteCont.quote.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateQuoteController3(){
        setupTestData('PureConnect', 'Partner');
        
        // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('/apex/CreateQuote?oppId=' + testOpportunities[0].Id));
        CreateQuoteController objCreateQuoteCont = new CreateQuoteController();
        objCreateQuoteCont.quote.Service_Level__c  = 'Business Care';
        objCreateQuoteCont.quote.Maintenance_Start_Date__c = testOpportunities[0].CloseDate.addDays(2);
        objCreateQuoteCont.quote.Maintenance_End_Date__c = testOpportunities[0].CloseDate.addDays(2).addMonths(24);
        objCreateQuoteCont.quote.Previous_Maint_Rate__c = null;
        objCreateQuoteCont.quote.Genesys_Care_Rep_Name__c = UserInfo.getUserId();
        objCreateQuoteCont.save();
        Quote_Service_Contracts__c cotermServiceContract =new Quote_Service_Contracts__c(Quote__c = objCreateQuoteCont.quote.Id, Service_Contract__c = testServiceContracts[1].Id);
        insert cotermServiceContract;
        objCreateQuoteCont.syncQuoteProducts();
        objCreateQuoteCont.reimportBtnHandler();
        objCreateQuoteCont.fetchQuotePeriods();
        objCreateQuoteCont.list_QuotePeriods = new List<Quote_Period__c>();
        objCreateQuoteCont.applyQuotePeriod();         
        objCreateQuoteCont.applyLRAUpliftToLines();
        objCreateQuoteCont.removeLRAUpliftFromLines();
        objCreateQuoteCont.quote.CurrencyISOCode = 'CAD';
        objCreateQuoteCont.changeQuoteCurrency();
        objCreateQuoteCont.applyELAChange();
        
        Test.setCurrentPageReference(new PageReference('/apex/CreateQuote?Id=' + objCreateQuoteCont.quote.Id));
        objCreateQuoteCont = new CreateQuoteController();
        //objCreateQuoteCont.objFromProduct.BigMachines__Product__c = testProducts[5].Id;
        //objCreateQuoteCont.objToProduct.BigMachines__Product__c = testProducts[9].Id;
        //objCreateQuoteCont.upgradeProduct();
        objCreateQuoteCont.applyPureConnectUpgrades();
        List<SelectOption> DiscountTypes = objCreateQuoteCont.getDiscountTypes();
        
        objCreateQuoteCont.quote.Maintenance_Due_Discount_Type__c = 'None';
        objCreateQuoteCont.DiscountApplied();
        objCreateQuoteCont.quote.Maintenance_Due_Discount_Type__c = 'Flat';
        objCreateQuoteCont.quote.Maintenance_Due_Discount_Value__c = 10;
        objCreateQuoteCont.DiscountApplied();
        objCreateQuoteCont.quote.Maintenance_Due_Discount_Type__c = 'Percentage';
        objCreateQuoteCont.quote.Maintenance_Due_Discount_Percentage__c = 10;
        objCreateQuoteCont.DiscountApplied(); 
        objCreateQuoteCont.DiscountTypeChanged();
        objCreateQuoteCont.submitForApprovalBtnHandler();
        objCreateQuoteCont.quote.Order_PO_Number__c = '123';
        objCreateQuoteCont.quote.Order_PO_Date__c = Date.today() + 1;
        Attachment objAttach = new Attachment(ParentId=objCreateQuoteCont.quote.Id,Name='test',Body=Blob.valueOf('Unit Test Attachment Body'));
        insert objAttach;
        objCreateQuoteCont.submitOrderBtnHandler();
        objCreateQuoteCont.dummyForCodeCoverage();
        CreateQuoteController anotherCreateQuoteController = new CreateQuoteController(objCreateQuoteCont.quote.Id);
        Test.stopTest();
        
    }
    
    static void setupTestData(String OfferingType, String accountType){
        // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;

        testCountry = new Country__c(
            Name = 'United States', Region__c = 'North America', DAP_Region__c = 'NA', ISO_Code__c = 'USD',  Country__c = 'USA',
            SW_Download_Site__c = 'Canada', Old_DAP_Region__c = 'NA', Old_Sub_Region__c = 'North America', Old_Sub_Sub_Region__c = 'USA',
            price_book__c = 'NA-USD', Old_Price_Book__c = 'G5_NA_USD', New_Price_Book__c = 'NG5_NA_USD',
            Big_Four__c = 'North America', Big_Six__c = 'North America',
            Basic_Care_New_End_User__c = 18.0, Basic_Care_New_Partner__c = 18.0,
            Business_Care_New_End_User__c = 18.0, Business_Care_New_Partner__c = 18.0,
            Premium_Care_New_End_User__c = 18.0, Premium_Care_New_Partner__c = 18.0,
            Basic_Care_Renewal_End_User__c = 18.0, Basic_Care_Renewal_Partner__c = 18.0,
            Business_Care_Renewal_End_User__c = 18.0, Business_Care_Renewal_Partner__c = 18.0,
            Premium_Care_Renewal_End_User__c = 18.0, Premium_Care_Renewal_Partner__c = 18.0,
            Business_Care_New_End_User_Licensing__c = 18.0, Premium_Care_New_End_User_Licensing__c = 18.0,
            Business_Care_New_Partner_Licensing__c = 18.0, Premium_Care_New_Partner_Licensing__c = 18.0,
            Basic_Support__c = 18.0, Standard_Support__c = 18.0, Priority_Support__c = 18.0, VIP_Priority_Support__c = 18.0
        );
        insert testCountry;
        
        testStates = new List<State_Province__c>();
        testStates.add(new State_Province__c(Name = 'GA', Country__c = testCountry.Id));
        testStates.add(new State_Province__c(Name = 'MI', Country__c = testCountry.Id));
        insert testStates; 
        
        testAccount = new Account(Name = 'Account 1', AccountNameNative__c = 'Account 1', Status__c = 'Active', Country__c = testCountry.Id, 
                                    Type = accountType, Genesys_Care_specialist__c = UserInfo.getUserId(), Genesys_Care_Ops__c = UserInfo.getUserId(),
                                    Genesys_Care_Offering__c = 'Business Care-Renewal(End User)', Support_Option__c = 'Basic Support',
                                    Software_Price_Multiplier__c = 30.0, Education_Price_Multiplier__c = 40.0, 
                                    Auto_Renew_Eligible__c = true, Auto_Renew_Anniversary__c = Date.Today().addDays(120), Auto_Renew_Contract_Term__c = 24,
                                    Auto_Renew_Rate__c = 22.0, Increased_Percentage__c = false, Auto_Renew_Contractual_Increase__c = 5.0);
        insert testAccount;                                          
        
        testContacts = new List<Contact>();
        for( Integer i=0; i < 5; i++ ) {
            testContacts.add(new Contact(FirstName = 'FN' + i, LastName = 'LN' + i, Email = 'test'+i+'@genesys.com', Send_Quote__c = true, accountId = testAccount.id));
        }
        insert testContacts;
                
        ID BaseItemRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();  
        ID CoreProductRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('CORE - Product Record Type').getRecordTypeId();  
        
        testProducts = new List<Product2>();
        // Care Products for Genesys Care 
        testProducts.add(new Product2(Name = 'Business Care-Renewal(End User)', Description = 'Business Care-Renewal(End User)', Product_Name__c = 'Business Care-Renewal(End User)',
                                        Description__c = 'Business Care-Renewal(End User)', Gore_Integration_ID__c = '10001',  APN_Number__c = '10001',
                                        RecordTypeId = BaseItemRT, Price_Type__c = 'Fixed Price', Product_Option__c = 'Quantity',
                                        Base_Item__c = 'Business Care-Renewal(End User)', BaseItem_MML_Id__c = '10001', IsActive = true,
                                        Availability_Status__c = 'Active', Price_Permission__c = 'Public', Family = '1.0.0', Third_Party__c = NULL,
                                        Type__c  = 'Genesys Care',  Base_Item_Lookup__c = NULL, Care_Rate_Applicable__c = 'Business_Care_Renewal_End_User__c',
                                        BRAZIL_R_Price__c = -1.00, NG1_APAC_ANZ_AUD_Price__c    = -1.00, G1_APAC_AUD_Price__c = -1.00,
                                        NG1_APAC_KOREA_SE_ASIA_USD_Price__c = -1.00, G1_APAC_USD_Price__c = -1.00, NG1_APAC_USD_Price__c = -1.00, 
                                        G2_CALA_USD_Price__c = -1.00, NG2_BRAZIL_BRL_Price__c = -1.00, G3_EMEA_EUR_Price__c = -1.00, NG2_CALA_USD_Price__c = -1.00,
                                        G3_EMEA_GBP_Price__c = -1.00, NG3_EMEA_EUR_Price__c = -1.00, G3_EMEA_USD_Price__c   = -1.00, NG3_EMEA_GBP_Price__c  = -1.00,
                                        G4_JAPAN_JPY_Price__c = -1.00, NG3_EMEA_USD_Price__c = -1.00, G5_NA_CAD_Price__c = -1.00, NG4_APAC_CHINA_INDIA_USD_Price__c = -1.00,
                                        G5_NA_USD_Price__c = -1.00, NG4_APAC_JAPAN_YEN_Price__c = -1.00, NG5_NZD_Price__c   = -1.00, NG5_NA_USD_Price__c    = -1.00,
                                        NG5_ZAR_Price__c = -1.00, NG5_NA_CAD_Price__c   = -1.00,
                                        NG1_PPU_Silver_USD__c  = -1.00, NG1_PPU_USD__c     = -1.00, NG1_PPU_Gold_USD__c    = -1.00
                                ));
                                 
        testProducts.add(new Product2(Name = 'Basic Support',  Description = 'Basic Support', Product_Name__c = 'Basic Support',
                                        Description__c = 'Basic Support', Gore_Integration_ID__c = '10002', APN_Number__c = '10002',
                                        RecordTypeId = BaseItemRT, Price_Type__c = 'Fixed Price', Product_Option__c = 'Quantity',
                                        Base_Item__c = 'Priority Support', BaseItem_MML_Id__c = '10002', IsActive = true,
                                        Availability_Status__c = 'Active', Price_Permission__c = 'Public', Family = '1.0.0', Third_Party__c = NULL,
                                        Type__c  = 'Genesys Care',  Base_Item_Lookup__c = NULL, Care_Rate_Applicable__c = 'Basic_Support__c',
                                        BRAZIL_R_Price__c = -1.00, NG1_APAC_ANZ_AUD_Price__c    = -1.00, G1_APAC_AUD_Price__c = -1.00,
                                        NG1_APAC_KOREA_SE_ASIA_USD_Price__c = -1.00, G1_APAC_USD_Price__c = -1.00, NG1_APAC_USD_Price__c = -1.00, 
                                        G2_CALA_USD_Price__c = -1.00, NG2_BRAZIL_BRL_Price__c = -1.00, G3_EMEA_EUR_Price__c = -1.00, NG2_CALA_USD_Price__c = -1.00,
                                        G3_EMEA_GBP_Price__c = -1.00, NG3_EMEA_EUR_Price__c = -1.00, G3_EMEA_USD_Price__c   = -1.00, NG3_EMEA_GBP_Price__c  = -1.00,
                                        G4_JAPAN_JPY_Price__c = -1.00, NG3_EMEA_USD_Price__c = -1.00, G5_NA_CAD_Price__c = -1.00, NG4_APAC_CHINA_INDIA_USD_Price__c = -1.00,
                                        G5_NA_USD_Price__c = -1.00, NG4_APAC_JAPAN_YEN_Price__c = -1.00, NG5_NZD_Price__c   = -1.00, NG5_NA_USD_Price__c    = -1.00,
                                        NG5_ZAR_Price__c = -1.00, NG5_NA_CAD_Price__c   = -1.00,
                                        NG1_PPU_Silver_USD__c  = -1.00, NG1_PPU_USD__c     = -1.00, NG1_PPU_Gold_USD__c    = -1.00
                                ));
        
        testProducts.add(new Product2(Name = 'Custom App Support (Partner)', Description = 'Custom App Support (Partner)', Product_Name__c = 'Custom App Support (Partner)',
                                        Description__c = 'Custom App Support (Partner)', Gore_Integration_ID__c = '10003', APN_Number__c = '10003', 
                                        RecordTypeId = BaseItemRT, Price_Type__c = 'Fixed Price', Product_Option__c = 'Quantity',
                                        Base_Item__c = 'Custom App Support (Partner)', BaseItem_MML_Id__c = '10003', IsActive = true,
                                        Availability_Status__c = 'Active', Price_Permission__c = 'Public', Family = '1.0.0', Third_Party__c = NULL,
                                        Type__c  = 'PS',  Base_Item_Lookup__c = NULL, Care_Rate_Applicable__c = '',
                                        BRAZIL_R_Price__c = -1.00, NG1_APAC_ANZ_AUD_Price__c    = -1.00, G1_APAC_AUD_Price__c = -1.00,
                                        NG1_APAC_KOREA_SE_ASIA_USD_Price__c = -1.00, G1_APAC_USD_Price__c = -1.00, NG1_APAC_USD_Price__c = -1.00, 
                                        G2_CALA_USD_Price__c = -1.00, NG2_BRAZIL_BRL_Price__c = -1.00, G3_EMEA_EUR_Price__c = -1.00, NG2_CALA_USD_Price__c = -1.00,
                                        G3_EMEA_GBP_Price__c = -1.00, NG3_EMEA_EUR_Price__c = -1.00, G3_EMEA_USD_Price__c   = -1.00, NG3_EMEA_GBP_Price__c  = -1.00,
                                        G4_JAPAN_JPY_Price__c = -1.00, NG3_EMEA_USD_Price__c = -1.00, G5_NA_CAD_Price__c = -1.00, NG4_APAC_CHINA_INDIA_USD_Price__c = -1.00,
                                        G5_NA_USD_Price__c = -1.00, NG4_APAC_JAPAN_YEN_Price__c = -1.00, NG5_NZD_Price__c   = -1.00, NG5_NA_USD_Price__c    = -1.00,
                                        NG5_ZAR_Price__c = -1.00, NG5_NA_CAD_Price__c   = -1.00,
                                        NG1_PPU_Silver_USD__c  = -1.00, NG1_PPU_USD__c     = -1.00, NG1_PPU_Gold_USD__c    = -1.00
                                ));
        for(Integer i = 1; i <= 10; i ++){
            testProducts.add(new Product2(Name = 'Core Product ' + i, Description = 'Core Product ' + i, Product_Name__c = 'Core Product ' + i, Description__c = 'Core Product ' + i, Base_Item__c = 'Core Product ' + i,
                                            Type__c  = 'Product', RecordTypeId = CoreProductRT,  Gore_Integration_ID__c = '2000' + i, BaseItem_MML_Id__c = '2000' + i,  APN_Number__c = '2000' + i,
                                            Price_Type__c = 'Fixed Price', Product_Option__c = 'Quantity', Availability_Status__c = 'Active', Price_Permission__c = 'Public', Family = '1.0.0', Third_Party__c  = NULL,
                                             Base_Item_Lookup__c = NULL, Care_Rate_Applicable__c = '', IsActive = true,
                                            BRAZIL_R_Price__c = 1000.00, NG1_APAC_ANZ_AUD_Price__c  = 1000.00, G1_APAC_AUD_Price__c = 1000.00,
                                            NG1_APAC_KOREA_SE_ASIA_USD_Price__c = 1000.00, G1_APAC_USD_Price__c = 1000.00, NG1_APAC_USD_Price__c = 1000.00, 
                                            G2_CALA_USD_Price__c = 1000.00, NG2_BRAZIL_BRL_Price__c = 1000.00, G3_EMEA_EUR_Price__c = 1000.00, NG2_CALA_USD_Price__c = 1000.00,
                                            G3_EMEA_GBP_Price__c = 1000.00, NG3_EMEA_EUR_Price__c   = 1000.00, G3_EMEA_USD_Price__c = 1000.00, NG3_EMEA_GBP_Price__c    = 1000.00,
                                            G4_JAPAN_JPY_Price__c = 1000.00, NG3_EMEA_USD_Price__c = 1000.00, G5_NA_CAD_Price__c = 1000.00, NG4_APAC_CHINA_INDIA_USD_Price__c   = 1000.00,
                                            G5_NA_USD_Price__c = 1000.00, NG4_APAC_JAPAN_YEN_Price__c   = 1000.00, NG5_NZD_Price__c = 1000.00, NG5_NA_USD_Price__c  = 1000.00,
                                            NG5_ZAR_Price__c = 1000.00, NG5_NA_CAD_Price__c = 1000.00,
                                            NG1_PPU_Silver_USD__c    = 1000.00, NG1_PPU_USD__c       = 1000.00, NG1_PPU_Gold_USD__c  = 1000.00
                                    ));
        }
        insert testProducts;
        
        testProducts[3].Product_Upgrade__c = testProducts[8].id;
        testProducts[4].Product_Upgrade__c = testProducts[9].id;
        update testProducts;
        
        testPriceBookEntries = new List<PricebookEntry>();
        for(Product2 p : testProducts){
            testPriceBookEntries.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p.Id, IsActive = true,
                                                        UnitPrice = 1000, UseStandardPrice = false, CurrencyIsoCode = 'USD'));
        }           
        insert testPriceBookEntries;
        
        ID RenewalOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
        testOpportunities = new List<Opportunity>();
        testOpportunities.add(new Opportunity(Name = 'Regular Opp 1', Opportunity_Status__c = 'In Progress', StageName = '8.Renewal', CurrencyIsoCode = 'USD',
                                            AccountId = testAccount.Id, BusinessPartner__c = testAccount.Id, CloseDate = Date.Today().addDays(130), 
                                            Country__c = testCountry.Id, Sold_To_Country__c = testCountry.Id, Forecasted_Flag__c = true,
                                            Previous_Maintenance_Rate__c = 18.0, Gene_Care_Specialist__c = UserInfo.getUserId(),
                                            Lines_of_Businesses__c = OfferingType, RecordTypeId = RenewalOppRT, Pricebook2Id = Test.getStandardPricebookId()));
        testOpportunities.add(new Opportunity(Name = 'Regular Opp 2', Opportunity_Status__c = 'In Progress', StageName = '8.Renewal', CurrencyIsoCode = 'USD',
                                            AccountId = testAccount.Id, BusinessPartner__c = testAccount.Id, CloseDate = Date.Today().addDays(140), 
                                            Country__c = testCountry.Id, Sold_To_Country__c = testCountry.Id, Forecasted_Flag__c = true, 
                                            Previous_Maintenance_Rate__c = 18.0, Gene_Care_Specialist__c = UserInfo.getUserId(),
                                            Lines_of_Businesses__c = OfferingType, RecordTypeId = RenewalOppRT, Pricebook2Id = Test.getStandardPricebookId()));
        testOpportunities.add(new Opportunity(Name = 'Gap Opp 1', Opportunity_Status__c = 'In Progress', StageName = '8.Renewal', CurrencyIsoCode = 'USD',
                                            AccountId = testAccount.Id, BusinessPartner__c = testAccount.Id, CloseDate = Date.Today().addDays(110), 
                                            Country__c = testCountry.Id, Sold_To_Country__c = testCountry.Id, Forecasted_Flag__c = true,
                                            Previous_Maintenance_Rate__c = 18.0, Gene_Care_Specialist__c = UserInfo.getUserId(),
                                            Lines_of_Businesses__c = OfferingType, RecordTypeId = RenewalOppRT, Pricebook2Id = Test.getStandardPricebookId()));
        testOpportunities.add(new Opportunity(Name = 'Gap Opp 2', Opportunity_Status__c = 'In Progress', StageName = '8.Renewal', CurrencyIsoCode = 'USD',
                                            AccountId = testAccount.Id, BusinessPartner__c = testAccount.Id, CloseDate = Date.Today().addDays(110), 
                                            Country__c = testCountry.Id, Sold_To_Country__c = testCountry.Id, Forecasted_Flag__c = true,
                                            Previous_Maintenance_Rate__c = 18.0, Gene_Care_Specialist__c = UserInfo.getUserId(),
                                            Lines_of_Businesses__c = OfferingType, RecordTypeId = RenewalOppRT, Pricebook2Id = Test.getStandardPricebookId()));
        insert testOpportunities;
        
        testServiceContracts = new List<ServiceContract>();
        for(Integer i=0; i<4; i++) {
            testServiceContracts.add(new ServiceContract( Name = 'Service Contract ' + i, Pricebook2id = Test.getStandardPricebookId(), 
                                                CurrencyIsoCode = 'USD', Agreement_Status__c = 'Active', Override_Offering_Type__c = OfferingType,
                                                StartDate = testOpportunities[i].CloseDate.addMonths(-24), EndDate = testOpportunities[i].CloseDate.addDays(1), 
                                                Sold_To_Name__c = testAccount.id, End_User_Name__c = testAccount.id, 
                                                AccountId = testAccount.id, Renewal_Opportunity__c = testOpportunities[i].Id
            ));
        }           
        insert testServiceContracts;
        
        listContractLineItems = new List<ContractLineItem>();
        listInvoices = new List<Invoice__c>();
        for(Integer i=0; i<4; i++){
            for(integer j=3; j<7; j++){
                listContractLineItems.add(new ContractLineItem(
                    ServiceContractId = testServiceContracts[i].id,
                    Current_Quantity__c = j+1, 
                    Quantity = j+1,
                    UnitPrice = 100,
                    PricebookEntryId = testPriceBookEntries[j].id,
                    Lic_Invoice__c = '1000'+i+j,
                    Sales_Order__c = '1000'+i+j,
                    Maintenance_Start_Date__c = testOpportunities[i].CloseDate.addMonths(-24),
                    Maintenance_End_Date__c = testOpportunities[i].CloseDate.addDays(1)
                ));
                listInvoices.add(new invoice__c(Name = '1000'+i+j, ELA__c = true));
                
            }
            listContractLineItems.add(new ContractLineItem(
                    ServiceContractId = testServiceContracts[i].id,
                    Current_Quantity__c = 10, 
                    Quantity = 10,
                    UnitPrice = 100,
                    PricebookEntryId = testPriceBookEntries[11].id,
                    Lic_Invoice__c = '100010',
                    Sales_Order__c = '100010',
                    Maintenance_Start_Date__c = testOpportunities[i].CloseDate.addMonths(-24),
                    Maintenance_End_Date__c = testOpportunities[i].CloseDate.addDays(1)
            ));
            listContractLineItems.add(new ContractLineItem(
                    ServiceContractId = testServiceContracts[i].id,
                    Current_Quantity__c = 10, 
                    Quantity = 10,
                    UnitPrice = 100,
                    PricebookEntryId = testPriceBookEntries[11].id,
                    Lic_Invoice__c = '100010',
                    Sales_Order__c = '100010',
                    Maintenance_Start_Date__c = testOpportunities[i].CloseDate.addMonths(-24),
                    Maintenance_End_Date__c = testOpportunities[i].CloseDate.addDays(1)
            ));
            listInvoices.add(new invoice__c(Name = '100010', ELA__c = true));
        }
        insert listContractLineItems;
        insert listInvoices;
        
        for(Integer i=0; i<4; i++) {
            testOpportunities[i].Service_Contract__c = testServiceContracts[i].id;
        }
        update testOpportunities;

        
        List<Pure_Connect_Version_Upgrade__c> pureConnectVersionUpgrades = new List<Pure_Connect_Version_Upgrade__c>();
        pureConnectVersionUpgrades.add(new Pure_Connect_Version_Upgrade__c(Mapping_Type__c = '3 --> 7', Multiplier__c = 1, Old_Part_Number__c = testProducts[3].APN_Number__c, New_Part_Number__c = testProducts[7].APN_Number__c));
        pureConnectVersionUpgrades.add(new Pure_Connect_Version_Upgrade__c(Mapping_Type__c = '4 --> 8', Multiplier__c = 1, Old_Part_Number__c = testProducts[4].APN_Number__c, New_Part_Number__c = testProducts[8].APN_Number__c));
        pureConnectVersionUpgrades.add(new Pure_Connect_Version_Upgrade__c(Mapping_Type__c = '5 --> 9', Multiplier__c = 1, Old_Part_Number__c = testProducts[5].APN_Number__c, New_Part_Number__c = testProducts[9].APN_Number__c));
        pureConnectVersionUpgrades.add(new Pure_Connect_Version_Upgrade__c(Mapping_Type__c = '5 --> 10', Multiplier__c = 1, Old_Part_Number__c = testProducts[5].APN_Number__c, New_Part_Number__c = testProducts[10].APN_Number__c));
        insert pureConnectVersionUpgrades;
         
        List<Product_Upgrade_Request__c> versionUpgradeRequests = new List<Product_Upgrade_Request__c>();
        versionUpgradeRequests.add(new Product_Upgrade_Request__c(Account__c = testAccount.id, Product__c = testProducts[3].id, Type__c = 'Version', Processed__c = false));
        versionUpgradeRequests.add(new Product_Upgrade_Request__c(Account__c = testAccount.id, Product__c = testProducts[4].id, Type__c = 'Version', Processed__c = false));
        versionUpgradeRequests.add(new Product_Upgrade_Request__c(Account__c = testAccount.id, Product__c = testProducts[5].id, Type__c = 'Version', Processed__c = false));
        insert versionUpgradeRequests;
        
        List<UL_Upsize_Parts__c> upLiftParts = new List<UL_Upsize_Parts__c>();
        upLiftParts.add(new  UL_Upsize_Parts__c(Name = testProducts[6].APN_Number__c, Part_To_Be_Decremented__c = testProducts[11].APN_Number__c, Part_To_Be_Incremented__c = testProducts[12].APN_Number__c));
        insert upLiftParts;
        Util.Bypass_Trigger_Chk = false;
    }
}