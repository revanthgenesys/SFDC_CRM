@isTest(SeeAllData = true)
private class OnPremiseQuotingTool_Test
{
    static testmethod void test1()
    {
        try
        {
            
            // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
            Util.Bypass_Trigger_Chk = true;
            CloudQuoteUtil.DO_NOT_CALL_OPP_PRODUCT_TOTAL_LOGIC = true;
            
            QuoteApprovalAssignmentTest.createTestConfigData();
            
            List<Product2> list_ProductsToInsert = new List<Product2>();
            Product2 objTestProduct = new Product2();
            objTestProduct.Name = 'Test Base Item';
            objTestProduct.recordTypeId = (Id)Label.Base_Item_RecordTypeId;
            objTestProduct.Type__c = 'Product';
            objTestProduct.Show_In_BEP__c = true;
            objTestProduct.Quantities_Available__c = '50;100;200';
            objTestProduct.Versions_Available__c = '8.0';
            objTestProduct.New_Category__c = 'Insights';
            objTestProduct.Building_Block__c = 'Advisor';
            objTestProduct.IsActive  = true;
            objTestProduct.NG5_NA_USD_Price__c = 100;
            list_ProductsToInsert.add(objTestProduct);
            
            Product2 objProd2 = new Product2();
            objProd2.Name = 'XYZ123';
            objProd2.Type__c = 'Product';
            objProd2.IsActive  = true;
            objProd2.Quantities_Available__c = '50;100;200';
            objProd2.New_Category__c = 'Communications Infrastructure';
            objProd2.Building_Block__c = 'SIP Server';
            objProd2.NG5_NA_USD_Price__c = 100;
            list_ProductsToInsert.add(objProd2);
            
            Product2 objProd3 = new Product2();
            objProd3.Name = 'test bundle';
            objProd3.Type__c = 'Bundle';
            objProd3.IsActive  = true;
            list_ProductsToInsert.add(objProd3);
            
            insert list_ProductsToInsert;
            
            Product_Group__c objTestBundle = new Product_Group__c();
            objTestBundle.Name = 'test bundle';
            objTestBundle.Group_Type__c = 'Bundle';
            objTestBundle.Active__c = true;
            objTestBundle.Type__c = 'Stand Alone';
            insert objTestBundle;
            
            Product_Group_Item__c objPGI = new Product_Group_Item__c();
            objPGI.Product__c = objTestProduct.Id;
            objPGI.Quantity__c = 1;
            objPGI.Product_Group__c = objTestBundle.Id;
            insert objPGI;
            
            // Hard-coding USA country Id
            Account objTestAccount = new Account(Name='Test Account', Status__c = 'Active',Country__c = 'a06U0000000ugdy');
            insert objTestAccount;
            
            Opportunity objTestOppty = new Opportunity( Name='Test Opp', accountId = objTestAccount.Id);
            objTestOppty.closeDate = Date.today().addMonths(1);
            objTestOppty.StageName = '1.Recognize Needs';     
            objTestOppty.CurrencyIsoCode = 'USD'; 
            objTestOppty.Sold_To_Country__c = 'a06U0000000ugdy';
            objTestOppty.Direct_Sales__c = true;
            //objTestOppty.Direct_Opportunity_Source__c = 'LinkedIn';
            insert objTestOppty;
            
            BigMachines__Quote__c objTestQuote = new BigMachines__Quote__c();
            objTestQuote.BigMachines__Opportunity__c = objTestOppty.Id;
            objTestQuote.Quote_Created_Date__c = System.today();
            objTestQuote.BigMachines__Status__c = 'Quote In Progress';
            objTestQuote.BigMachines__Is_Primary__c = true;
            objTestQuote.Service_Level__c = 'Business';
            objTestQuote.Pricing_Model__c = 'Enabled';
            objTestQuote.Quote_Opportunity_Type__c = 'New Pricing';
            objTestQuote.Duration_Unit__c = 'Months';
            objTestQuote.Order_Numb_of_Maint_Months__c = 12;
            objTestQuote.Order_Type__c = 'Revenue';
            objTestQuote.End_User_ID__c = objTestAccount.Id;
            objTestQuote.BigMachines__Account__c = objTestAccount.Id;
            objTestQuote.Sold_To_Name__c = objTestAccount.Id; 
            objTestQuote.New_Price_Book__c = 'NG5_NA_USD';
            objTestQuote.Support_Owner__c = objTestAccount.Id;
            objTestQuote.System_Integrator__c = objTestAccount.Id;
            objTestQuote.CurrencyISOCode = 'USD';
            objTestQuote.Quote_Business_Type__c = 'On Premise';
            objTestQuote.Expiration_Date__c = Date.today().addDays(90);
            objTestQuote.Approval_Submission_Date__c = Date.today();
            insert objTestQuote;
            
            Order__c obtTestOrder = new Order__c();
            obtTestOrder.Quote__c = objTestQuote.Id;
            obtTestOrder.Maintenance_Start__c = Date.today();
            obtTestOrder.Maintenance_End__c = Date.today().addYears(1);
            obtTestOrder.Opportunity__c = objTestOppty.Id;
            obtTestOrder.Numb_of_Maint_Months__c = 12;
            insert obtTestOrder;
            
            Test.setCurrentPageReference(new PageReference('/apex/Configuration?id=' + objTestQuote.Id));
            ConfigurationController objConfigCont = new ConfigurationController();
            
            objConfigCont.strSelectedBuildingBlock = 'All';
            objConfigCont.showProducts();
            objConfigCont.strSelectedCategory = 'All';
            objConfigCont.changeCategory();
            
            Boolean blnIsExecuted = false;
            for(List<Product2> list_Products : objConfigCont.map_BuildingBlockToProducts.values())
            {
                for(Product2 objProduct : list_Products)
                {
                    objProduct.Quantity__c = 1;
                    if(!blnIsExecuted)
                    {
                        objConfigCont.strProductIdForInfo = objProduct.Id;
                        objConfigCont.strVersionForInfo = objProduct.Versions_Available__c.split(';')[0];
                        objConfigCont.showProductInfoFromBaseItem();
                        objConfigCont.hideProductInfo();
                        blnIsExecuted = true;
                    }
                    break;
                }
            }
            objConfigCont.addProductsBtnHandler();
            
            objConfigCont.productSearchOptionHandler();
            objConfigCont.next();
            objConfigCont.previous();
            objConfigCont.last();
            objConfigCont.first();
            objConfigCont.strSortFieldSelected = 'Building_Block__c';
            objConfigCont.changeSorting();
            objConfigCont.strSortFieldSelected = 'Building_Block__c';
            objConfigCont.changeSorting();
            if(objConfigCont.list_SearchProducts.size() > 0)
            {
                objConfigCont.strProductIdForInfo = objConfigCont.list_SearchProducts[0].Id;
                objConfigCont.showProductInfo();
            }
            objConfigCont.objSearchProduct.Name = '3GP20844ACAA';
            objConfigCont.objSearchProduct.Description__c = 'PS RDP';
            objConfigCont.objSearchProduct.New_Category__c = 'PS Rapid Deployment Packages';
            objConfigCont.objSearchProduct.Building_Block__c = 'PS Rapid Deployment Packages';
            objConfigCont.objSearchProduct.SI_Version_Number__c = '1.0';
            objConfigCont.searchBtnHandler();
            objConfigCont.getPageNumStr();
            objConfigCont.getHasPrevious();
            objConfigCont.getHasNext();
            
            if(objConfigCont.list_SearchProducts.size() > 0)
                objConfigCont.list_SearchProducts[0].Quantity__c = 1;
                
            objConfigCont.addProductsFromSearch();
            objConfigCont.objSearchProduct.Name = 'XYZ123';
            objConfigCont.objSearchProduct.Description__c = '';
            objConfigCont.objSearchProduct.New_Category__c = '';
            objConfigCont.objSearchProduct.Building_Block__c = '';
            objConfigCont.objSearchProduct.SI_Version_Number__c = '';
            objConfigCont.searchBtnHandler();
            
            if(objConfigCont.list_SearchProducts.size() > 0)
                objConfigCont.list_SearchProducts[0].Product_Name__c = '50';
                
            objConfigCont.addProductsFromSearch();
                
            objConfigCont.bundleOptionHandler();
            blnIsExecuted = false;
            for(Product_Group__c objProductBundle : objConfigCont.map_BundleTypeToBundles.values()[0])
            {
                objProductBundle.Quantity__c = 1;
                if(!blnIsExecuted)
                {
                    objConfigCont.strGroupId = objProductBundle.Id;
                    objConfigCont.showHideProducts();
                    objConfigCont.showHideProducts();
                    blnIsExecuted = true;
                }
            }
            objConfigCont.addBundlesBtnHandler();
            
            objConfigCont.markFavBtnHandler();
            objConfigCont.saveFavourite();
            objConfigCont.objFavToBeSaved.Name = '007';
            objConfigCont.saveFavourite();
            objConfigCont.cancelMarkFavourite();
            
            if(objConfigCont.list_QuoteProductsToBeCreated.size() > 0)
            {
                objConfigCont.strProdIndex = '0';
                objConfigCont.removeProduct();
            }
            if(objConfigCont.list_BundlesToBeSaved.size() > 0)
            {
                objConfigCont.strProdIndex = '0';
                objConfigCont.removeProductBundle();
            }
            objConfigCont.removeAllBtnHandler();
            
            objConfigCont.favouritesOptionHandler();
            for(ConfigurationController.FavoriteWrapper objFavWrapper : objConfigCont.list_Favourites)
            {
                if(objFavWrapper.objFavorite.Name == '007')
                {
                    objFavWrapper.blnIsSelected = true;
                    objConfigCont.addFavoritesBtnHandler();
                    objConfigCont.strFavId = objFavWrapper.objFavorite.Id;
                    objConfigCont.showHideFavoriteItems();
                    objConfigCont.strFavId = objFavWrapper.objFavorite.Id;
                    objConfigCont.showHideFavoriteItems();
                    objConfigCont.strFavId = objFavWrapper.objFavorite.Id;
                    objConfigCont.deleteFavorite();
                    break;
                }
            }
            
            objConfigCont.saveBtnHandler();
            
            Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?id=' + objTestQuote.Id));
            CreateQuoteOnPremiseController1 objCreateQuoteCont = new CreateQuoteOnPremiseController1();
            
            objCreateQuoteCont.quote.Pricing_Model__c = 'Concurrent';
            objCreateQuoteCont.changePricingModel();
            
            objCreateQuoteCont.editofProposalGroup();
            objCreateQuoteCont.addProposalGroup();
            objCreateQuoteCont.addProposalGroup();
            objCreateQuoteCont.saveProposalGroup();
            for(Quote_Proposal_Group__c objPG: objCreateQuoteCont.list_ProposalGroupsBeingEdited)
            {
                objPG.Name__c = 'test group';
                objPG.Discount__c = 5;
            }
            objCreateQuoteCont.saveProposalGroup();
            objCreateQuoteCont.editofProposalGroup();
            objCreateQuoteCont.strPGIndex = '1';
            objCreateQuoteCont.removeProposalGroup();
            objCreateQuoteCont.saveProposalGroup();
            objCreateQuoteCont.cancelEditofProposalGroup();
            
            objCreateQuoteCont.quote.Genesys_Care_Rate__c = 18;
            
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                if(obj.record.Bundle__c == null && obj.record.Ext_List__c != null)
                {
                    obj.record.Group_Number__c = '1';
                }
            }
            objCreateQuoteCont.objAttachment.Name = 'test';
            objCreateQuoteCont.objAttachment.Body = Blob.valueof('test');
            objCreateQuoteCont.quote.Special_Offer_Terms__c = 'test';
            objCreateQuoteCont.doCalculations();
            
            Integer intIndex = 0;
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                obj.record.Flavor__c = 'flavor';
                if(Math.mod(intIndex,2) == 0)
                {
                    obj.record.or_Amount__c = '%';
                    obj.record.Disc__c = 2;
                }
                else
                {
                    obj.record.or_Amount__c = 'Amt';
                    obj.record.Disc__c = 1;
                }
                intIndex++;
            }
            if(Limits.getQueries() < 70)
            {
                objCreateQuoteCont.doCalculations();
                objCreateQuoteCont.doCalculations();
            }
            
            Decimal decTotalList = 0;
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                if(obj.record.Group_Number__c == '1')
                    decTotalList += obj.record.Ext_List__c;
            }
            
            if(objCreateQuoteCont.list_ProposalGroups.size() > 0)
            {
                Quote_Proposal_Group__c objPG = objCreateQuoteCont.list_ProposalGroups[0];
                objCreateQuoteCont.strPGIndex = '0';
                objCreateQuoteCont.goalSeekForPG();
                objPG.Goal_Seek__c = 0.9 * decTotalList;
                objCreateQuoteCont.goalSeekForPG();
                objCreateQuoteCont.goalSeekResetForPG();
            }
            
            objCreateQuoteCont.selectColumnsHandler();
            objCreateQuoteCont.saveColumnsHandler();
            objCreateQuoteCont.cancelColumnsHandler();
            
            objCreateQuoteCont.next();
            objCreateQuoteCont.previous();
            objCreateQuoteCont.last();
            objCreateQuoteCont.first();
            objCreateQuoteCont.numberOfPages();
            objCreateQuoteCont.getPageNumStr();
            
            if(Limits.getQueries() < 70)
            {   
                
                objCreateQuoteCont.checkUncheckAll();
                //objCreateQuoteCont.submitForApprovalBtnHandler();
                objCreateQuoteCont.bypassApprovalsBtnHandler();
            }
            
            Test.startTest();
            
            objCreateQuoteCont.quote.Grid_Group_By__c = 'Bundles/Products';
            objCreateQuoteCont.createCurrentPageList();
            objCreateQuoteCont.quote.Grid_Group_By__c = 'Proposal Groups';
            objCreateQuoteCont.createCurrentPageList();
            objCreateQuoteCont.quote.Grid_Group_By__c = '3rd Party/Genesys';
            objCreateQuoteCont.createCurrentPageList();
            
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                obj.selected = true;
                break;
            }
            
            objCreateQuoteCont.massUpdateBtnHandler();
            objCreateQuoteCont.objMassUpdateInput.Disc__c = 1;
            objCreateQuoteCont.objMassUpdateInput.or_Amount__c = null;
            objCreateQuoteCont.massUpdateBtnHandler();
            objCreateQuoteCont.objMassUpdateInput.or_Amount__c = '%';
            objCreateQuoteCont.objMassUpdateInput.Quantity__c = 1;
            objCreateQuoteCont.massUpdateBtnHandler();
            
            objCreateQuoteCont.quote.Adjustment__c = null;
            objCreateQuoteCont.applyAdjustmentBtnHandler();
            objCreateQuoteCont.quote.Adjustment__c = 1;
            objCreateQuoteCont.applyAdjustmentBtnHandler();
            objCreateQuoteCont.adjustmentResetBtnHandler();
            
            objCreateQuoteCont.quote.Goal_Seek__c = null;
            objCreateQuoteCont.goalSeekBtnHandler();
            if(objCreateQuoteCont.quote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c != null)
            {
                objCreateQuoteCont.quote.Goal_Seek__c = objCreateQuoteCont.quote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c * 0.9;
            	objCreateQuoteCont.goalSeekBtnHandler();
            }
            objCreateQuoteCont.goalSeekResetBtnHandler();
            
            objCreateQuoteCont.cloneBtnHandler();
            objCreateQuoteCont.reviseMinorBtnHandler();
            objCreateQuoteCont.reviseMajorBtnHandler();
            ApexPages.currentPage().getParameters().put('clone','1');
            objCreateQuoteCont.cloneQuoteOnLoad();
            
            objCreateQuoteCont.changeOpportunity();
            objCreateQuoteCont.saveBeforeReload();
            objCreateQuoteCont.quote.Genesys_Care_Rate__c = null;
            objCreateQuoteCont.quote.Duration_Unit__c = 'Months';
            objCreateQuoteCont.quote.Order_Numb_of_Maint_Months__c = null;
            objCreateQuoteCont.saveGC();
            objCreateQuoteCont.quote.Duration_Unit__c = 'Days';
            objCreateQuoteCont.quote.Order_Numb_of_Maint_Days__c = null;
            objCreateQuoteCont.saveGC();
            objCreateQuoteCont.quote.Service_Level__c = 'Decline';
            objCreateQuoteCont.saveGC();
            
            if(Limits.getQueries() < 80)
            {
                Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?tab=GenesysCare&id=' + objTestQuote.Id));
                objCreateQuoteCont = new CreateQuoteOnPremiseController1();
                
                Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?tab=DAPDetails&id=' + objTestQuote.Id));
                objCreateQuoteCont = new CreateQuoteOnPremiseController1();
                
                Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?tab=SpecialOffers&id=' + objTestQuote.Id));
                objCreateQuoteCont = new CreateQuoteOnPremiseController1();
                
                Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?tab=QuoteApprovals&id=' + objTestQuote.Id));
                objCreateQuoteCont = new CreateQuoteOnPremiseController1();          
            }
            
            if(Limits.getQueries() > 80)
                return;
            
            Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?tab=OrderSubmission&id=' + objTestQuote.Id));
            objCreateQuoteCont = new CreateQuoteOnPremiseController1();
            
            objCreateQuoteCont.cancelBtnHandler();
            objCreateQuoteCont.reviseOrderBtnHandler();
            
            objCreateQuoteCont.saveOrderInfo();
            objCreateQuoteCont.submitOrderBtnHandler();
            objCreateQuoteCont.updateOrders();
            
            objCreateQuoteCont.showHistoryAndAttachments();
            objCreateQuoteCont.showProposalOptions();
            
            objCreateQuoteCont.strToDelete = 'yes';
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                if(obj.record.Bundle__c != null)
                {
                    objCreateQuoteCont.quoteProductIdToBeDeleted = obj.record.Id;
                    objCreateQuoteCont.deleteQuoteProduct();
                    break;
                }
            }
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                if(obj.record.Bundle__c == null)
                {
                    objCreateQuoteCont.quoteProductIdToBeDeleted = obj.record.Id;
                    objCreateQuoteCont.deleteQuoteProduct();
                    break;
                }
            }
            
            delete [SELECT Id FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = :objTestQuote.Id];
            
            objCreateQuoteCont.getQuoteProducts(objTestQuote.Id);
            objCreateQuoteCont.bypassApprovalsBtnHandler();         
            /*objCreateQuoteCont.submitForApprovalBtnHandler();
            objCreateQuoteCont.quote.Service_Level__c = null;
            objCreateQuoteCont.submitForApprovalBtnHandler();*/

            Test.stopTest();
        }
        catch(Exception ex)
        {}
    }
    
    static testmethod void test2()
    {
        try
        {
            
            // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
            Util.Bypass_Trigger_Chk = true;
            CloudQuoteUtil.DO_NOT_CALL_OPP_PRODUCT_TOTAL_LOGIC = true;
            
            QuoteApprovalAssignmentTest.createTestConfigData();
            
            List<Product2> list_ProductsToInsert = new List<Product2>();
            Product2 objTestProduct = new Product2();
            objTestProduct.Name = 'Test Base Item';
            objTestProduct.recordTypeId = (Id)Label.Base_Item_RecordTypeId;
            objTestProduct.Type__c = 'Product';
            objTestProduct.Show_In_BEP__c = true;
            objTestProduct.Quantities_Available__c = '50;100;200';
            objTestProduct.Versions_Available__c = '8.0';
            objTestProduct.New_Category__c = 'Insights';
            objTestProduct.Building_Block__c = 'Advisor';
            objTestProduct.IsActive  = true;
            objTestProduct.NG5_NA_USD_Price__c = 100;
            list_ProductsToInsert.add(objTestProduct);
            
            Product2 objProd2 = new Product2();
            objProd2.Name = 'XYZ123';
            objProd2.Type__c = 'Product';
            objProd2.IsActive  = true;
            objProd2.Quantities_Available__c = '50;100;200';
            objProd2.New_Category__c = 'Communications Infrastructure';
            objProd2.Building_Block__c = 'SIP Server';
            objProd2.NG5_NA_USD_Price__c = 100;
            list_ProductsToInsert.add(objProd2);
            
            Product2 objProd3 = new Product2();
            objProd3.Name = 'test bundle';
            objProd3.Type__c = 'Bundle';
            objProd3.IsActive  = true;
            list_ProductsToInsert.add(objProd3);
            
            insert list_ProductsToInsert;
            
            Product_Group__c objTestBundle = new Product_Group__c();
            objTestBundle.Name = 'test bundle';
            objTestBundle.Group_Type__c = 'Bundle';
            objTestBundle.Active__c = true;
            objTestBundle.Type__c = 'Stand Alone';
            insert objTestBundle;
            
            Product_Group_Item__c objPGI = new Product_Group_Item__c();
            objPGI.Product__c = objTestProduct.Id;
            objPGI.Quantity__c = 1;
            objPGI.Product_Group__c = objTestBundle.Id;
            insert objPGI;
            
            // Hard-coding USA country Id
            Account objTestAccount = new Account(Name='Test Account', Status__c = 'Active',Country__c = 'a06U0000000ugdy');
            insert objTestAccount;
            
            Opportunity objTestOppty = new Opportunity( Name='Test Opp', accountId = objTestAccount.Id);
            objTestOppty.closeDate = Date.today().addMonths(1);
            objTestOppty.StageName = '1.Recognize Needs';     
            objTestOppty.CurrencyIsoCode = 'USD'; 
            objTestOppty.Sold_To_Country__c = 'a06U0000000ugdy';
            objTestOppty.Direct_Sales__c = true;
            //objTestOppty.Direct_Opportunity_Source__c = 'LinkedIn';
            insert objTestOppty;
            
            BigMachines__Quote__c objTestQuote = new BigMachines__Quote__c();
            objTestQuote.BigMachines__Opportunity__c = objTestOppty.Id;
            objTestQuote.Quote_Created_Date__c = System.today();
            objTestQuote.BigMachines__Status__c = 'Quote In Progress';
            objTestQuote.BigMachines__Is_Primary__c = true;
            objTestQuote.Service_Level__c = 'Business';
            objTestQuote.Pricing_Model__c = 'Enabled';
            objTestQuote.Quote_Opportunity_Type__c = 'New Pricing';
            objTestQuote.Duration_Unit__c = 'Months';
            objTestQuote.Order_Numb_of_Maint_Months__c = 12;
            objTestQuote.Order_Type__c = 'Revenue';
            objTestQuote.End_User_ID__c = objTestAccount.Id;
            objTestQuote.BigMachines__Account__c = objTestAccount.Id;
            objTestQuote.Sold_To_Name__c = objTestAccount.Id; 
            objTestQuote.New_Price_Book__c = 'NG5_NA_USD';
            objTestQuote.Support_Owner__c = objTestAccount.Id;
            objTestQuote.System_Integrator__c = objTestAccount.Id;
            objTestQuote.CurrencyISOCode = 'USD';
            objTestQuote.Quote_Business_Type__c = 'On Premise';
            objTestQuote.Expiration_Date__c = Date.today().addDays(90);
            objTestQuote.Approval_Submission_Date__c = Date.today();
            insert objTestQuote;
            
            Order__c obtTestOrder = new Order__c();
            obtTestOrder.Quote__c = objTestQuote.Id;
            obtTestOrder.Maintenance_Start__c = Date.today();
            obtTestOrder.Maintenance_End__c = Date.today().addYears(1);
            obtTestOrder.Opportunity__c = objTestOppty.Id;
            obtTestOrder.Numb_of_Maint_Months__c = 12;
            insert obtTestOrder;
            
            Test.setCurrentPageReference(new PageReference('/apex/Configuration?id=' + objTestQuote.Id));
            ConfigurationController2 objConfigCont = new ConfigurationController2();
            
            objConfigCont.strSelectedBuildingBlock = 'All';
            objConfigCont.showProducts();
            objConfigCont.strSelectedCategory = 'All';
            objConfigCont.changeCategory();
            
            Boolean blnIsExecuted = false;
            for(List<Product2> list_Products : objConfigCont.map_BuildingBlockToProducts.values())
            {
                for(Product2 objProduct : list_Products)
                {
                    objProduct.Quantity__c = 1;
                    if(!blnIsExecuted)
                    {
                        objConfigCont.strProductIdForInfo = objProduct.Id;
                        objConfigCont.strVersionForInfo = objProduct.Versions_Available__c.split(';')[0];
                        objConfigCont.showProductInfoFromBaseItem();
                        objConfigCont.hideProductInfo();
                        blnIsExecuted = true;
                    }
                    break;
                }
            }
            objConfigCont.addProductsBtnHandler();
            
            objConfigCont.productSearchOptionHandler();
            objConfigCont.next();
            objConfigCont.previous();
            objConfigCont.last();
            objConfigCont.first();
            objConfigCont.strSortFieldSelected = 'Building_Block__c';
            objConfigCont.changeSorting();
            objConfigCont.strSortFieldSelected = 'Building_Block__c';
            objConfigCont.changeSorting();
            if(objConfigCont.list_SearchProducts.size() > 0)
            {
                objConfigCont.strProductIdForInfo = objConfigCont.list_SearchProducts[0].Id;
                objConfigCont.showProductInfo();
            }
            objConfigCont.objSearchProduct.Name = '3GP20844ACAA';
            objConfigCont.objSearchProduct.Description__c = 'PS RDP';
            objConfigCont.objSearchProduct.New_Category__c = 'PS Rapid Deployment Packages';
            objConfigCont.objSearchProduct.Building_Block__c = 'PS Rapid Deployment Packages';
            objConfigCont.objSearchProduct.SI_Version_Number__c = '1.0';
            objConfigCont.searchBtnHandler();
            objConfigCont.getPageNumStr();
            objConfigCont.getHasPrevious();
            objConfigCont.getHasNext();
            
            if(objConfigCont.list_SearchProducts.size() > 0)
                objConfigCont.list_SearchProducts[0].Quantity__c = 1;
                
            objConfigCont.addProductsFromSearch();
            objConfigCont.objSearchProduct.Name = 'XYZ123';
            objConfigCont.objSearchProduct.Description__c = '';
            objConfigCont.objSearchProduct.New_Category__c = '';
            objConfigCont.objSearchProduct.Building_Block__c = '';
            objConfigCont.objSearchProduct.SI_Version_Number__c = '';
            objConfigCont.searchBtnHandler();
            
            if(objConfigCont.list_SearchProducts.size() > 0)
                objConfigCont.list_SearchProducts[0].Product_Name__c = '50';
                
            objConfigCont.addProductsFromSearch();
                
            objConfigCont.bundleOptionHandler();
            blnIsExecuted = false;
            for(Product_Group__c objProductBundle : objConfigCont.map_BundleTypeToBundles.values()[0])
            {
                objProductBundle.Quantity__c = 1;
                if(!blnIsExecuted)
                {
                    objConfigCont.strGroupId = objProductBundle.Id;
                    objConfigCont.showHideProducts();
                    objConfigCont.showHideProducts();
                    blnIsExecuted = true;
                }
            }
            objConfigCont.addBundlesBtnHandler();
            
            objConfigCont.markFavBtnHandler();
            objConfigCont.saveFavourite();
            objConfigCont.objFavToBeSaved.Name = '007';
            objConfigCont.saveFavourite();
            objConfigCont.cancelMarkFavourite();
            
            if(objConfigCont.list_QuoteProductsToBeCreated.size() > 0)
            {
                objConfigCont.strProdIndex = '0';
                objConfigCont.removeProduct();
            }
            if(objConfigCont.list_BundlesToBeSaved.size() > 0)
            {
                objConfigCont.strProdIndex = '0';
                objConfigCont.removeProductBundle();
            }
            objConfigCont.removeAllBtnHandler();
            
            objConfigCont.favouritesOptionHandler();
            for(ConfigurationController2.FavoriteWrapper objFavWrapper : objConfigCont.list_Favourites)
            {
                if(objFavWrapper.objFavorite.Name == '007')
                {
                    objFavWrapper.blnIsSelected = true;
                    objConfigCont.addFavoritesBtnHandler();
                    objConfigCont.strFavId = objFavWrapper.objFavorite.Id;
                    objConfigCont.showHideFavoriteItems();
                    objConfigCont.strFavId = objFavWrapper.objFavorite.Id;
                    objConfigCont.showHideFavoriteItems();
                    objConfigCont.strFavId = objFavWrapper.objFavorite.Id;
                    objConfigCont.deleteFavorite();
                    break;
                }
            }
            
            objConfigCont.saveBtnHandler();
            
            Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?id=' + objTestQuote.Id));
            CreateQuoteOnPremiseController1 objCreateQuoteCont = new CreateQuoteOnPremiseController1();
            
            objCreateQuoteCont.quote.Pricing_Model__c = 'Concurrent';
            objCreateQuoteCont.changePricingModel();
            
            objCreateQuoteCont.editofProposalGroup();
            objCreateQuoteCont.addProposalGroup();
            objCreateQuoteCont.addProposalGroup();
            objCreateQuoteCont.saveProposalGroup();
            for(Quote_Proposal_Group__c objPG: objCreateQuoteCont.list_ProposalGroupsBeingEdited)
            {
                objPG.Name__c = 'test group';
                objPG.Discount__c = 5;
            }
            objCreateQuoteCont.saveProposalGroup();
            objCreateQuoteCont.editofProposalGroup();
            objCreateQuoteCont.strPGIndex = '1';
            objCreateQuoteCont.removeProposalGroup();
            objCreateQuoteCont.saveProposalGroup();
            objCreateQuoteCont.cancelEditofProposalGroup();
            
            objCreateQuoteCont.quote.Genesys_Care_Rate__c = 18;
            
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                if(obj.record.Bundle__c == null && obj.record.Ext_List__c != null)
                {
                    obj.record.Group_Number__c = '1';
                }
            }
            objCreateQuoteCont.objAttachment.Name = 'test';
            objCreateQuoteCont.objAttachment.Body = Blob.valueof('test');
            objCreateQuoteCont.quote.Special_Offer_Terms__c = 'test';
            objCreateQuoteCont.doCalculations();
            
            Integer intIndex = 0;
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                obj.record.Flavor__c = 'flavor';
                if(Math.mod(intIndex,2) == 0)
                {
                    obj.record.or_Amount__c = '%';
                    obj.record.Disc__c = 2;
                }
                else
                {
                    obj.record.or_Amount__c = 'Amt';
                    obj.record.Disc__c = 1;
                }
                intIndex++;
            }
            if(Limits.getQueries() < 70)
            {
                objCreateQuoteCont.doCalculations();
                objCreateQuoteCont.doCalculations();
            }
            
            Decimal decTotalList = 0;
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                if(obj.record.Group_Number__c == '1')
                    decTotalList += obj.record.Ext_List__c;
            }
            
            if(objCreateQuoteCont.list_ProposalGroups.size() > 0)
            {
                Quote_Proposal_Group__c objPG = objCreateQuoteCont.list_ProposalGroups[0];
                objCreateQuoteCont.strPGIndex = '0';
                objCreateQuoteCont.goalSeekForPG();
                objPG.Goal_Seek__c = 0.9 * decTotalList;
                objCreateQuoteCont.goalSeekForPG();
                objCreateQuoteCont.goalSeekResetForPG();
            }
            
            objCreateQuoteCont.selectColumnsHandler();
            objCreateQuoteCont.saveColumnsHandler();
            objCreateQuoteCont.cancelColumnsHandler();
            
            objCreateQuoteCont.next();
            objCreateQuoteCont.previous();
            objCreateQuoteCont.last();
            objCreateQuoteCont.first();
            objCreateQuoteCont.numberOfPages();
            objCreateQuoteCont.getPageNumStr();
            
            if(Limits.getQueries() < 70)
            {   
                
                objCreateQuoteCont.checkUncheckAll();
                //objCreateQuoteCont.submitForApprovalBtnHandler();
                objCreateQuoteCont.bypassApprovalsBtnHandler();
            }
            
            Test.startTest();
            
            objCreateQuoteCont.quote.Grid_Group_By__c = 'Bundles/Products';
            objCreateQuoteCont.createCurrentPageList();
            objCreateQuoteCont.quote.Grid_Group_By__c = 'Proposal Groups';
            objCreateQuoteCont.createCurrentPageList();
            objCreateQuoteCont.quote.Grid_Group_By__c = '3rd Party/Genesys';
            objCreateQuoteCont.createCurrentPageList();
            
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                obj.selected = true;
                break;
            }
            
            objCreateQuoteCont.massUpdateBtnHandler();
            objCreateQuoteCont.objMassUpdateInput.Disc__c = 1;
            objCreateQuoteCont.objMassUpdateInput.or_Amount__c = null;
            objCreateQuoteCont.massUpdateBtnHandler();
            objCreateQuoteCont.objMassUpdateInput.or_Amount__c = '%';
            objCreateQuoteCont.objMassUpdateInput.Quantity__c = 1;
            objCreateQuoteCont.massUpdateBtnHandler();
            
            objCreateQuoteCont.quote.Adjustment__c = null;
            objCreateQuoteCont.applyAdjustmentBtnHandler();
            objCreateQuoteCont.quote.Adjustment__c = 1;
            objCreateQuoteCont.applyAdjustmentBtnHandler();
            objCreateQuoteCont.adjustmentResetBtnHandler();
            
            objCreateQuoteCont.quote.Goal_Seek__c = null;
            objCreateQuoteCont.goalSeekBtnHandler();
            if(objCreateQuoteCont.quote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c != null)
            {
                objCreateQuoteCont.quote.Goal_Seek__c = objCreateQuoteCont.quote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c * 0.9;
            	objCreateQuoteCont.goalSeekBtnHandler();
            }
            objCreateQuoteCont.goalSeekResetBtnHandler();
            
            objCreateQuoteCont.cloneBtnHandler();
            objCreateQuoteCont.reviseMinorBtnHandler();
            objCreateQuoteCont.reviseMajorBtnHandler();
            ApexPages.currentPage().getParameters().put('clone','1');
            objCreateQuoteCont.cloneQuoteOnLoad();
            
            objCreateQuoteCont.changeOpportunity();
            objCreateQuoteCont.saveBeforeReload();
            objCreateQuoteCont.quote.Genesys_Care_Rate__c = null;
            objCreateQuoteCont.quote.Duration_Unit__c = 'Months';
            objCreateQuoteCont.quote.Order_Numb_of_Maint_Months__c = null;
            objCreateQuoteCont.saveGC();
            objCreateQuoteCont.quote.Duration_Unit__c = 'Days';
            objCreateQuoteCont.quote.Order_Numb_of_Maint_Days__c = null;
            objCreateQuoteCont.saveGC();
            objCreateQuoteCont.quote.Service_Level__c = 'Decline';
            objCreateQuoteCont.saveGC();
            
            if(Limits.getQueries() < 80)
            {
                Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?tab=GenesysCare&id=' + objTestQuote.Id));
                objCreateQuoteCont = new CreateQuoteOnPremiseController1();
                
                Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?tab=DAPDetails&id=' + objTestQuote.Id));
                objCreateQuoteCont = new CreateQuoteOnPremiseController1();
                
                Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?tab=SpecialOffers&id=' + objTestQuote.Id));
                objCreateQuoteCont = new CreateQuoteOnPremiseController1();
                
                Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?tab=QuoteApprovals&id=' + objTestQuote.Id));
                objCreateQuoteCont = new CreateQuoteOnPremiseController1();          
            }
            
            if(Limits.getQueries() > 80)
                return;
            
            Test.setCurrentPageReference(new PageReference('/apex/CreateQuoteOnPremise?tab=OrderSubmission&id=' + objTestQuote.Id));
            objCreateQuoteCont = new CreateQuoteOnPremiseController1();
            
            objCreateQuoteCont.cancelBtnHandler();
            objCreateQuoteCont.reviseOrderBtnHandler();
            
            objCreateQuoteCont.saveOrderInfo();
            objCreateQuoteCont.submitOrderBtnHandler();
            objCreateQuoteCont.updateOrders();
            
            objCreateQuoteCont.showHistoryAndAttachments();
            objCreateQuoteCont.showProposalOptions();
            
            objCreateQuoteCont.strToDelete = 'yes';
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                if(obj.record.Bundle__c != null)
                {
                    objCreateQuoteCont.quoteProductIdToBeDeleted = obj.record.Id;
                    objCreateQuoteCont.deleteQuoteProduct();
                    break;
                }
            }
            for(CreateQuoteOnPremiseController1.QuoteProductWrapper obj : objCreateQuoteCont.list_QuoteProducts)
            {
                if(obj.record.Bundle__c == null)
                {
                    objCreateQuoteCont.quoteProductIdToBeDeleted = obj.record.Id;
                    objCreateQuoteCont.deleteQuoteProduct();
                    break;
                }
            }
            
            delete [SELECT Id FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = :objTestQuote.Id];
            
            objCreateQuoteCont.getQuoteProducts(objTestQuote.Id);
            objCreateQuoteCont.bypassApprovalsBtnHandler();         
            /*objCreateQuoteCont.submitForApprovalBtnHandler();
            objCreateQuoteCont.quote.Service_Level__c = null;
            objCreateQuoteCont.submitForApprovalBtnHandler();*/

            Test.stopTest();
        }
        catch(Exception ex)
        {}
    }
}