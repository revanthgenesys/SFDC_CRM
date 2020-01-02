@isTest(SeeAllData = true)
public class CreateQuote1ControllerTest {
    static testmethod void test1()
    {
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
            list_ProductsToInsert.add(objTestProd);
            //insert objTestProd;
            
            Product2 objTestProd1 = new Product2();
            objTestProd1.Name = 'Test Prod1';
            objTestProd1.recordTypeId = rtypes[0].Id;
            objTestProd1.Type__c = 'Product';
            objTestProd1.End_of_Support__c = Date.today().format();
            objTestProd1.IsActive = true;
            objTestProd1.Description = 'test 1';
            list_ProductsToInsert.add(objTestProd1);
            //insert objTestProd1;
            
            Product2 objTestProd2 = new Product2();
            objTestProd2.Name = 'Test Prod2';
            objTestProd2.recordTypeId = rtypes[0].Id;
            objTestProd2.Type__c = 'Flex Care';
            objTestProd2.IsActive = true;
            objTestProd2.Description = 'test 2';
            list_ProductsToInsert.add(objTestProd2);
            
            Product2 objTestProd3 = new Product2();
            objTestProd3.Name = 'Test Prod3';
            objTestProd3.recordTypeId = rtypes[0].Id;
            objTestProd3.Type__c = 'Fees';
            objTestProd3.IsActive = true;
            objTestProd3.Description = 'test 3';
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
            
            
            
            Test.setCurrentPageReference(new PageReference('/apex/CreateQuote1?oppId=' + objTestOppty.Id));
            CreateQuote1Controller objCreateQuoteCont = new CreateQuote1Controller();
            
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
            
            BigMachines__Quote__c objQuoteForController = [SELECT Id,CurrencyISOCode,BigMachines__Status__c,Service_Level__c,
                                                    Maintenance_End_Date__c,Cover_Letter_Text__c
                                                    FROM BigMachines__Quote__c WHERE Id = :objCreateQuoteCont.quote.Id];
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('/apex/ConfigurationPage?Id=' + objQuoteForController.Id));
            
            ConfigurationExt objConfig = new ConfigurationExt(new ApexPages.StandardController(objQuoteForController));
            
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
                
            objConfig.objQuote.Has_Extended_End_Of_Support__c = true;
            objConfig.objQuote.Has_Reinstatement__c = true;
            
            objConfig.saveBtnHandler();
            objConfig.initializeData();
            objConfig.objQuote.BigMachines__Status__c = 'Quote Approval Pending';
            objCreateQuoteCont.reviseBtnHandler();
            objConfig.saveBtnHandler();
            
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
            
            Test.setCurrentPageReference(new PageReference('/apex/CreateQuote1?Id=' + objQuoteForController.Id));
            objCreateQuoteCont = new CreateQuote1Controller();
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
            Test.stopTest();
            objCreateQuoteCont.save();
            
            //objCreateQuoteCont.refresh();
            for(CreateQuote1Controller.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
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

            for(CreateQuote1Controller.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
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
       		*/
         	Test.setCurrentPageReference(new PageReference('/apex/CreateRenewalProductUpgrade?Id=' + objQuoteForController.Id));
           	CreateRenewalProductUpgrade cc = new CreateRenewalProductUpgrade(); 
        }
        catch(CalloutException ex)
        {}
    }

}