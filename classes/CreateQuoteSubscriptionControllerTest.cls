@isTest(seealldata=true)
private class CreateQuoteSubscriptionControllerTest {
   // private static user currentuser = [select id,Bypass_Triggers__c from user where id =: userinfo.getUserId()];
    static void intialTests() {
     //   system.runAs(currentuser){
        Test.startTest();
        Util.Bypass_Trigger_Chk = true;
        
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();          
        objCreateQuoteSubCont.saveBeforeReload();         
        objCreateQuoteSubCont.showHistoryAndAttachments();
        objCreateQuoteSubCont.showProposalOptions();
        objCreateQuoteSubCont.changePricingModel();
        //objCreateQuoteCloudCont.changeProductTier();
        //objCreateQuoteCloudCont.changeOpportunity();
        //objCreateQuoteSubCont.idSoldToAccount = null; 
        objCreateQuoteSubCont.changeSoldTo();
        objCreateQuoteSubCont.cloneBtnHandler();
        //objCreateQuoteSubCont.strSelectedTab = 'Quote Approvals';
        objCreateQuoteSubCont.reviseMajorBtnHandler();
        System.currentPageReference().getParameters().put('clone', '1');
        objCreateQuoteSubCont.cloneQuoteOnLoad();
        
        objCreateQuoteSubCont.migrationCreditResetBtnHandler();
        Product_Group__c objPG = [SELECT id FROM Product_Group__c WHERE Group_Type__c = 'Base Package' LIMIT 1];
        objCreateQuoteSubCont.populateBasePackageWeightageIfMissing(objPG.id);
        
         Test.stopTest();
      //  }
    }
    
   
    @isTest
    static void otherTests() {
        Test.startTest();
        PriceBook2 priceBook= [select Id,Name from pricebook2 where Name = 'Standard Price Book' LIMIT 1];
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Customer_Contractual_Rate__c  = 2;
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        Currency_Configuration__c currConfig = new Currency_Configuration__c();
        currConfig.Price_Book__c = 'G5_NA_USD';
        currConfig.Pricing_Type__c = 'Old Pricing';
        currConfig.Multiplier__c = 1.1002;
        currConfig.Conversion_Rate__c = 1.1;
        currConfig.Offering_Type__c = 'PureConnect';
        currConfig.Start_Date__c = Date.today().addDays(-2);
        currConfig.End_Date__c = Date.today().addDays(2);
        insert currConfig;
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController(); 
        //Pagination
        objCreateQuoteSubCont.first();
        objCreateQuoteSubCont.last();
        objCreateQuoteSubCont.next();
        objCreateQuoteSubCont.previous();
        objCreateQuoteSubCont.getPageNumStr();
        
        //Select Columns
        objCreateQuoteSubCont.selectColumnsHandler();
        objCreateQuoteSubCont.saveColumnsHandler();
        objCreateQuoteSubCont.cancelColumnsHandler();
    
        objQuote.BigMachines__Status__c='Quote Approval Pending';
        update objQuote;
        //CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController(); 
        objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        objCreateQuoteSubCont.saveBeforeReload(); 
        List<BigMachines__Quote_Product__c> objQpList = [SELECT Id, List_Price__c , Disc__c, Group_Number__c
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
        for(BigMachines__Quote_Product__c objQP : objQpList) {
            system.debug(objQP.Group_Number__c );
            system.debug(objQP.Group_Number__c );
            system.debug(objQP.List_Price__c );
            objQP.Group_Number__c = '1';
            objQP.Extended_Price_Per_Month__c = 6;
            objQP.BigMachines__Quantity__c = 2;
            objQP.List_Price__c = 2;
            
        }
        update objQpList;
        //proposal group coverage
        objCreateQuoteSubCont.editofProposalGroup();
        objCreateQuoteSubCont.list_ProposalGroupsBeingEdited[0].Name__c = 'PG';
        objCreateQuoteSubCont.list_ProposalGroupsBeingEdited[0].Goal_Seek__c = 100.00;
        objCreateQuoteSubCont.list_ProposalGroupsBeingEdited[0].Group_Number__c = 'PG1';
        objCreateQuoteSubCont.saveProposalGroup();            
        objCreateQuoteSubCont.strPGIndex='0';
        //objCreateQuoteSubCont.goalSeekForPG();
        //objCreateQuoteSubCont.goalSeekResetForPG();  
        objCreateQuoteSubCont.cancelEditofProposalGroup();          
        objCreateQuoteSubCont.removeProposalGroup();
        Test.stopTest();
            
        objCreateQuoteSubCont.finalizeQuote();
        objCreateQuoteSubCont.convertToRealQuote();
        objCreateQuoteSubCont.synchAndGoToDQ();
        objCreateQuoteSubCont.showReviseVisibility();
        objCreateQuoteSubCont.hideReviseVisibility();
        
        objCreateQuoteSubCont.quote.Grid_Group_By__c = 'Sub Categories';
        objCreateQuoteSubCont.createCurrentPageList();
        objCreateQuoteSubCont.quote.Grid_Group_By__c = 'Recurring/Non-Recurring';
        objCreateQuoteSubCont.createCurrentPageList();
        objCreateQuoteSubCont.quote.Grid_Group_By__c = 'Bundles/Products';
        objCreateQuoteSubCont.createCurrentPageList();
        objCreateQuoteSubCont.quote.Grid_Group_By__c = 'Proposal Groups';
        objCreateQuoteSubCont.createCurrentPageList();
        objCreateQuoteSubCont.quote.Grid_Group_By__c = 'Nothing';        
        objCreateQuoteSubCont.createCurrentPageList();
        objCreateQuoteSubCont.quote.Grid_Group_By__c = 'Use Cases';        
        objCreateQuoteSubCont.createCurrentPageList();
        
        System.currentPageReference().getParameters().put('tab', 'DAPDetails'); 
        objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        
        System.currentPageReference().getParameters().put('tab', 'SpecialOffers');
        objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        
        System.currentPageReference().getParameters().put('tab', 'QuoteApprovals');
        System.currentPageReference().getParameters().put('mode', 'noAction');
        objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        //objCreateQuoteSubCont.submitForApprovalBtnHandler();
        objCreateQuoteSubCont.bypassApprovalsBtnHandler();                      
        
        System.currentPageReference().getParameters().put('tab', 'OrderSubmission');
        objCreateQuoteSubCont = new CreateQuoteSubscriptionController();            
      
        CreateQuoteSubscriptionController.approvalWrapper wr = new CreateQuoteSubscriptionController.approvalWrapper();
        objCreateQuoteSubCont.refresh();
        objCreateQuoteSubCont.resetRightToBust();
        PageReference pr = objCreateQuoteSubCont.showHistoryAndAttachments();
        PageReference pr1 = objCreateQuoteSubCont.showProposalOptions();

        String sn = wr.stepName;
         String sc = wr.styleClass;
         String rt = wr.rowType;
         String ar = wr.approvalReason;
         String fn = wr.functionName;
         String aa = wr.actualApprover;
         String an = wr.approverName;
         String ae = wr.actualApproverEmailId;
    }
    
    @isTest
    static void otherTest2(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Total_Contract_Value__c = 10;
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        
        
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                                        = new Product_Manager_Approval_Group__c(name='Test',
                                                                                Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        Product2 objQtProd = [SELECT id FROM Product2 WHERE OfferingType__c INCLUDES ('PureConnect Subscription') LIMIT 1];
        objQtProd.Building_Block__c = 'PS Rapid Deployment Packages';
        objQtProd.Third_Party__c = 'TRUE';
        objQtProd.Type__c = 'Migration Credit';
        objQtProd.Product_Type__c = 'Year 1';
        update objQtProd;
        BigMachines__Quote_Product__c objMassUpdateInput = new BigMachines__Quote_Product__c(Disc__c = 2, or_Amount__c = 'test' , Quantity__c  = 1, BigMachines__Product__c =objQtProd.id );
        Quote_Approver_Step_Approver_Details__c objQASAD 
                                        = new Quote_Approver_Step_Approver_Details__c(Name='Test Function Name',
                                                                                     Action_Text__c = 'Test Action',
                                                                                     Actual_Approver__c = UserInfo.getUserId(),
                                                                                     Email__c = 'test123@gensystestemail.com',
                                                                                     Minor_Quote_Change__c = 'Minor Quote Change Only',
                                                                                     Product_Ids__c = objQtProd.id);
        insert objQASAD;
        Quote_Approval_Steps__c objQAS = new Quote_Approval_Steps__c(Name = 'Step Name 1',
                                                                    Deal_Size_Threshold_From__c = 500,
                                                                    Description__c = 'Test Description',
                                                                    Notification_Only__c = true,
                                                                    Order__c = 1);
        insert objQAS;
        
        Quote_Approval_Regions__c objQAR = new Quote_Approval_Regions__c(DAP_Region__c = 'NA',
                                                                        Region__c = 'North America',
                                                                        Sub_Region__c = 'NA',
                                                                        test__c = 'APAC.APAC.NA');
        insert objQAR;
        Quote_Approval_Step_Details__c objQuoteApprovalStepDetail 
                            = new Quote_Approval_Step_Details__c(Priority_Sequence__c = 1,
                                                                Product_Manager_Approval_Group__c = objProdMangerApprovalGroup.id,
                                                                Quote_Approval_Region__c = objQAR.id,
                                                                Quote_Approval_Step__c = objQAS.id,
                                                                Quote_Approver_Step_Approver_Detail__c = objQASAD.id);
        
        insert objQuoteApprovalStepDetail;
        
        Quote_Approval_Config__c objQAC  = new Quote_Approval_Config__c(Active__c = true , Approval_Type__c = 'Deal Size' , Care_Override_Threshold__c = 'Override < 2 %',
                                                                       Quote_Type__c = 'Test Type', Threshold_From__c = 1 , Threshold_To__c = 2, 
                                                                       Threshold_Price_From__c = 1, Threshold_Price_To__c = 2,
                                                                       No_Of_Days_After_Quote_Expires__c = 10,
                                                                       Pricing_Model__c = 'PPU',Pricing_Type__c = 'New Pricing',
                                                                       Offering_Type__c = 'Cloud Partner (PPU)');
        insert objQAC;
        
        Quote_Approval_And_Quote_Approval_Region__c objQAandQAR  = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c = objQAC.Id, 
                                                                                                                  Quote_Approval_Region__c = objQAR.Id);
        
        insert objQAandQAR;
        
        Deal_Qualification__c objDQ = new Deal_Qualification__c(Pricing_Type__c = 'New Pricing', Platform_Type__c = 'On Premise',
                                                               Offering_Type__c = objQuote.Offering_Type__c, Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL,
                                                               Opportunity__c = objQuote.BigMachines__Opportunity__c);
        insert objDQ;
        
        Quote_Approval__c objQuoteApproval = new Quote_Approval__c();
        objQuoteApproval.Actual_Approver__c = UserInfo.getUserId();
        objQuoteApproval.Status__c = 'In Progress';
        objQuoteApproval.Quote_Approval_Step_Details__c = objQuoteApprovalStepDetail.id;
        objQuoteApproval.Quote_Approval_Date__c = System.today();
        objQuoteApproval.Step__c = 1;
        objQuoteApproval.BigMachines_Quote__c = objQuote.id;
        objQuoteApproval.Submitted_Date__c = System.today();
        insert objQuoteApproval;
        
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController(); 
        
        objCreateQuoteSubCont.massUpdateBtnHandler();
        List<CreateQuoteSubscriptionController.approvalWrapper> tempList = new List<CreateQuoteSubscriptionController.approvalWrapper>();
        objCreateQuoteSubCont.upfrontApprovals = tempList;
        objCreateQuoteSubCont.quote.Revise_Minor__c = true;
        objCreateQuoteSubCont.quote.Expiration_Date__c = System.today().addDays(100);
        objCreateQuoteSubCont.fetchApprovals();
        objCreateQuoteSubCont.blnIsHeaderChecked = true;
        objCreateQuoteSubCont.checkUncheckAll();
        
        objCreateQuoteSubCont.strToDelete = 'yes';
        /*objCreateQuoteSubCont.quoteProductIdToBeDeleted = [SELECT Id FROM BigMachines__Quote_Product__c 
                                                             WHERE BigMachines__Quote__c =: objQuote.Id LIMIT 1].id ;
        objCreateQuoteSubCont.deleteQuoteProduct();*/
        objCreateQuoteSubCont.changeOpportunity();
       // objCreateQuoteSubCont.adjustmentResetBtnHandler();
        
       // objCreateQuoteSubCont.map_GroupHeaderToQuoteProdWrapper.values()[0][0].selected = true ;
        //objCreateQuoteSubCont.deleteQuoteProducts();
        objCreateQuoteSubCont.showGenesysCare();
        objCreateQuoteSubCont.blnHasError = true;
        //objCreateQuoteSubCont.showProposalOptions();

        Decimal dealsize = objCreateQuoteSubCont.getDealSizeUSD(objQuote, 100.0);
        Boolean valid = objCreateQuoteSubCont.isValidLeverByDealSize(100.0);
        String ramp = CreateQuoteSubscriptionController.getPureBridgeRampPeriod((Date)System.today());
    }
    
    @isTest
    static void otherTest3(){
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Opportunity' and DeveloperName != 'New Pricing'];
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';        
        insert opportunities;
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.BigMachines__Is_Primary__c = true;
        objQuote.Grid_Group_By__c = 'Bundles/Products';
        objQuote.BigMachines__Opportunity__c = opportunities.id;
        objQuote.New_Price_Book__c = 'NG3_EMEA_USD';
        objQuote.Total_Contract_Value__c = 10;
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController(); 
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                                        = new Product_Manager_Approval_Group__c(name='Test',
                                                                                Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        Product2 objQtProd = [SELECT id FROM Product2 WHERE OfferingType__c INCLUDES ('PureConnect Subscription') LIMIT 1 ];
        objQtProd.Type__c = 'Migration Credit';
        objQtProd.Product_Type__c = 'Year 2';
        update objQtProd;
        objQtProd.EMEA_Volume_Discount_Eligible__c = true;
        update objQtProd;
        Quote_Approver_Step_Approver_Details__c objQASAD 
                                        = new Quote_Approver_Step_Approver_Details__c(Name='Test Function Name',
                                                                                     Action_Text__c = 'Test Action',
                                                                                     Actual_Approver__c = UserInfo.getUserId(),
                                                                                     Email__c = 'test123@gensystestemail.com',
                                                                                     Minor_Quote_Change__c = 'Minor Quote Change Only',
                                                                                     Product_Ids__c = objQtProd.id);
        insert objQASAD;
        Quote_Approval_Steps__c objQAS = new Quote_Approval_Steps__c(Name = 'Step Name 1',
                                                                    Deal_Size_Threshold_From__c = 500,
                                                                    Description__c = 'Test Description',
                                                                    Notification_Only__c = true,
                                                                    Order__c = 1);
        insert objQAS;
        
        Quote_Approval_Regions__c objQAR = new Quote_Approval_Regions__c(DAP_Region__c = 'ANZ',
                                                                        Region__c = 'North America',
                                                                        Sub_Region__c = 'ANZ',
                                                                        test__c = 'APAC.APAC.ANZ');
        insert objQAR;
        Quote_Approval_Step_Details__c objQuoteApprovalStepDetail 
                            = new Quote_Approval_Step_Details__c(Priority_Sequence__c = 1,
                                                                Product_Manager_Approval_Group__c = objProdMangerApprovalGroup.id,
                                                                Quote_Approval_Region__c = objQAR.id,
                                                                Quote_Approval_Step__c = objQAS.id,
                                                                Quote_Approver_Step_Approver_Detail__c = objQASAD.id);
        
        insert objQuoteApprovalStepDetail;
        
        Quote_Approval__c objQuoteApproval = new Quote_Approval__c();
        objQuoteApproval.Actual_Approver__c = UserInfo.getUserId();
        objQuoteApproval.Status__c = 'In Progress';
        objQuoteApproval.Quote_Approval_Step_Details__c = objQuoteApprovalStepDetail.id;
        objQuoteApproval.Quote_Approval_Date__c = System.today();
        objQuoteApproval.Step__c = 1;
        objQuoteApproval.BigMachines_Quote__c = objQuote.id;
        objQuoteApproval.Submitted_Date__c = System.today();
        insert objQuoteApproval;
        
        objCreateQuoteSubCont.fetchApprovals();
        objCreateQuoteSubCont.cloneQuote(true);
        
        BigMachines__Quote_Product__c objMassUpdateInput = new BigMachines__Quote_Product__c(Disc__c = 2, or_Amount__c = 'test' , Quantity__c  = 1, BigMachines__Product__c =objQtProd.id );
        objCreateQuoteSubCont.objMassUpdateInput = objMassUpdateInput;
        //objCreateQuoteSubCont.massUpdateBtnHandler();
        
        objMassUpdateInput = new BigMachines__Quote_Product__c(Disc__c = 2, or_Amount__c = '');
        objCreateQuoteSubCont.objMassUpdateInput = objMassUpdateInput;
        objCreateQuoteSubCont.list_QuoteProducts[0].selected = true;
        objCreateQuoteSubCont.massUpdateBtnHandler();
        objQuote.Product_Tier__c = 'Preferred';
        update objQuote;
        //objCreateQuoteSubCont.changeProductTier();
       // Order__c objOrder = new Order__c(Name = objQuote.Name , Quote__c = objQuote.id);
    //    insert objOrder;
        Order__c ordr= [SELECT Id FROM Order__c LIMIT 1];
        ordr.Quote__c = objQuote.id;
        update ordr; 
        objCreateQuoteSubCont.updateOrders();
      //  objCreateQuoteSubCont.blnIsReviseOrder = true; 
        objCreateQuoteSubCont.saveOrderInfo();
       // objCreateQuoteSubCont.strSelectedTab = 'Order Submission';
        objCreateQuoteSubCont.reviseOrderBtnHandler();
    }
    
     @isTest
    static void otherTest4(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Treat_SO_as_PO__c = true;
        objQuote.Order_PO_Number__c =  'Test PO Num';
        objQuote.Order_Payment_Terms__c = 'Test Term';
        objQuote.Product_Description__c = 'Testing';
        objQuote.BigMachines__Status__c='Quote Approval Pending';
        objQuote.Keep_the_existing_estate_on_Perpetual__c = false;
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController(); 
        List<Account_Order_Address__c> list_Addresses = new List<Account_Order_Address__c>();
        list_Addresses.add( new Account_Order_Address__c(Address_Type__c = 'Bill To' , Quote__c = objQuote.Id) ) ; 
        list_Addresses.add( new Account_Order_Address__c(Address_Type__c = 'End User' , Quote__c = objQuote.Id) ) ; 
        list_Addresses.add( new Account_Order_Address__c(Address_Type__c = 'Ship To' , Quote__c = objQuote.Id , Email__c = 'testgen@testgensys.com') ) ; 
        list_Addresses.add( new Account_Order_Address__c(Address_Type__c = 'Sold To' , Quote__c = objQuote.Id) ) ; 
        insert list_Addresses ; 
        objQuote.End_User_ID__c = objQuote.Sold_To_Name__c;
        update objQuote;
        
        Country__c objNewCountry = new Country__c(Country__c='United StateA', DAP_Region__c='NA', Region__c='NA', RU__c='NA',         
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objNewCountry; 
        
        Account objAcc = new Account(id =  objQuote.End_User_ID__c, screening_checklist_completed__c = true ,  Country__c = objNewCountry.id);
        Util.Bypass_Trigger_Chk = true ;
        update objAcc;
        
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(objAcc.Id, 1);
        list_NewOpps[0].Type = 'Existing Business - Cross Sell';
        update list_NewOpps[0];
        
        objQuote.BigMachines__Opportunity__c = list_NewOpps[0].id;
        update objQuote;
        List<BigMachines__Quote_Product__c> list_QuoteProducts = [sELECT Id, Ext_List__c,BigMachines__Product__c FROM BigMachines__Quote_Product__c
                                                                  WHERE BigMachines__Quote__c = :objQuote.id ];
        decimal count = 0;
        for(BigMachines__Quote_Product__c objQP : list_QuoteProducts){
            objQP.Ext_List__c = 10;
            objQP.List_Price__c = 10;
            objQP.Group_Number__c = 'PG1';
            
        }
        list_QuoteProducts[0].Ext_List__c = 20;
        update list_QuoteProducts;
        
        Product2 objProduct = [SELECT id, Discountable__c FROM Product2 WHERE id = :list_QuoteProducts[0].BigMachines__Product__c];
        objProduct.Discountable__c = true ;
        objProduct.Genesys_Care_Quote__c = true;
        update objProduct;
        
        
     //   objCreateQuoteSubCont.list_QuoteProductRecords = list_QuoteProducts;
     
        
        objCreateQuoteSubCont.quote.Goal_Seek__c = 15.00;
       // objCreateQuoteSubCont.goalSeekResetBtnHandler();
      //  objCreateQuoteSubCont.goalSeekBtnHandler();
        objCreateQuoteSubCont.quote.Adjustment__c = 2.5;
      //  objCreateQuoteSubCont.applyAdjustmentBtnHandler();
        objCreateQuoteSubCont.strPGIndex = 0+'';
        objCreateQuoteSubCont.list_ProposalGroups[0] = [SELECT id, Quote__c, Name__c, Description__c, Discount__c, Group_Number__c, Goal_Seek__c
                                                          FROM Quote_Proposal_Group__c WHERE Quote__c = :objQuote.id];
        
        Quote_Proposal_Group__c objQProposalGroup = [SELECT id, Quote__c ,Description__c ,Discount__c,Group_Number__c,Goal_Seek__c,Name__c
                                                    FROM Quote_Proposal_Group__c WHERE Quote__c = :objQuote.id];
        //objCreateQuoteSubCont.goalSeekForPG();
        objCreateQuoteSubCont.list_ProposalGroupsBeingEdited = new List<Quote_Proposal_Group__c>();
        objCreateQuoteSubCont.addProposalGroup();
        objCreateQuoteSubCont.saveProposalGroup();
        
    }
    
    @isTest
    static void otherTest5(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Editable_List_Price_Approval_Required__c = true;
        objQuote.Customer_Contractual_Rate__c  = 2;
        objQuote.Total_Contract_Value__c = 10;
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        Currency_Configuration__c currConfig = new Currency_Configuration__c();
        currConfig.Price_Book__c = 'G5_NA_USD';
        currConfig.Pricing_Type__c = 'Old Pricing';
        currConfig.Multiplier__c = 1.1002;
        currConfig.Conversion_Rate__c = 1.1;
        currConfig.Offering_Type__c = 'PureConnect';
        currConfig.Start_Date__c = Date.today().addDays(-2);
        currConfig.End_Date__c = Date.today().addDays(2);
        insert currConfig;
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        //objCreateQuoteSubCont.list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
        //objCreateQuoteSubCont.finalizeQuote();
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Extended_Price_Per_Month__c = 6;
            objQP.BigMachines__Quantity__c = 2;
            objQP.List_Price__c = 2;
            objQP.Disc__c=10;
        }    
        update list_NewQuoteProds;
        List<BigMachines__Quote_Product__c> list_NewQuoteProds1 = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Extended_Price_Per_Month__c = 6;
            objQP.BigMachines__Quantity__c = 2;
            objQP.List_Price__c = 2;
            objQP.Disc__c=10;
        }    
        update list_NewQuoteProds1;
        
       // objCreateQuoteSubCont.intPageSize = 1;
        objCreateQuoteSubCont.first();
        objCreateQuoteSubCont.next();
        objCreateQuoteSubCont.previous();
        objCreateQuoteSubCont.last();
        objCreateQuoteSubCont.getHasNext();
        objCreateQuoteSubCont.getHasPrevious();
        
        
        objCreateQuoteSubCont.blnHasError = true;
       // objCreateQuoteSubCont.submitForApprovalBtnHandler();
        //objCreateQuoteSubCont.showHistoryAndAttachments();
       // objCreateQuoteSubCont.showProposalOptions();
        
        objCreateQuoteSubCont.blnHasError = false;
        objCreateQuoteSubCont.quote.Service_Level__c = '';
      //  objCreateQuoteSubCont.submitForApprovalBtnHandler();
        
        
       // objCreateQuoteSubCont.list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
      //  objCreateQuoteSubCont.submitForApprovalBtnHandler();
       // objCreateQuoteSubCont.finalizeQuote();
        
        objCreateQuoteSubCont.upfrontApprovals = null;
        objCreateQuoteSubCont.showQuoteDetails();
        objCreateQuoteSubCont.showDAPDetails();
        
        objCreateQuoteSubCont.showOrderSubmission();
        objCreateQuoteSubCont.showSpecialOffers() ;
        
        objCreateQuoteSubCont.quote.Pricing_Model__c = 'Concurrent';
      //  objCreateQuoteSubCont.getPricingMultiplier('test');
      //  objCreateQuoteSubCont.strSelectedTab = 'Quote Approvals';
      //  objCreateQuoteSubCont.submitForApprovalBtnHandler();
        
    }
    
    @isTest
    static void otherTest6(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();  
        
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                                        = new Product_Manager_Approval_Group__c(name='Test',
                                                                                Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        Product2 objQtProd = [SELECT id FROM Product2 WHERE OfferingType__c INCLUDES ('PureConnect Subscription') LIMIT 1];
        objQtProd.Third_Party_GC__c = 2;
        update objQtProd;
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.BigMachines__Product__c = objQtProd.id;
        }    
        update list_NewQuoteProds; 
        Quote_Approver_Step_Approver_Details__c objQASAD 
                                        = new Quote_Approver_Step_Approver_Details__c(Name='Test Function Name',
                                                                                     Action_Text__c = 'Test Action',
                                                                                     Actual_Approver__c = UserInfo.getUserId(),
                                                                                     Email__c = 'test123@gensystestemail.com',
                                                                                     Minor_Quote_Change__c = 'Minor Quote Change Only',
                                                                                     Product_Ids__c = objQtProd.id);
        insert objQASAD;
        Quote_Approval_Steps__c objQAS = new Quote_Approval_Steps__c(Name = 'Step Name 1',
                                                                    Deal_Size_Threshold_From__c = 500,
                                                                    Description__c = 'Test Description',
                                                                    Notification_Only__c = true,
                                                                    Order__c = 1);
        insert objQAS;
        
        Quote_Approval_Regions__c objQAR = new Quote_Approval_Regions__c(DAP_Region__c = 'NA',
                                                                        Region__c = 'North America',
                                                                        Sub_Region__c = 'NA',
                                                                        test__c = 'APAC.APAC.NA');
        insert objQAR;
        Quote_Approval_Step_Details__c objQuoteApprovalStepDetail 
                            = new Quote_Approval_Step_Details__c(Priority_Sequence__c = 1,
                                                                Product_Manager_Approval_Group__c = objProdMangerApprovalGroup.id,
                                                                Quote_Approval_Region__c = objQAR.id,
                                                                Quote_Approval_Step__c = objQAS.id,
                                                                Quote_Approver_Step_Approver_Detail__c = objQASAD.id);
        
        insert objQuoteApprovalStepDetail;
        
        Quote_Approval_Config__c objQAC  = new Quote_Approval_Config__c(Active__c = true , Approval_Type__c = 'Product Management' , Care_Override_Threshold__c = 'Override < 2 %',
                                                                       Quote_Type__c = 'Test Type', Threshold_From__c = 1 , Threshold_To__c = 2, 
                                                                       Threshold_Price_From__c = 1, Threshold_Price_To__c = 2,
                                                                       No_Of_Days_After_Quote_Expires__c = 10,
                                                                        Doesn_t_Depend_on_Region_Sub_Region__c = true,
                                                                       Pricing_Model__c = 'PPU',Pricing_Type__c = 'New Pricing',
                                                                       Offering_Type__c = 'Cloud Partner (PPU)');
        insert objQAC;
        
        Quote_Approval_And_Quote_Approval_Region__c objQAandQAR  = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c = objQAC.Id, 
                                                                                                                  Quote_Approval_Region__c = objQAR.Id);
        
        insert objQAandQAR;
        
        Quote_Approval__c objQuoteApproval = new Quote_Approval__c();
        objQuoteApproval.Actual_Approver__c = UserInfo.getUserId();
        objQuoteApproval.Status__c = 'In Progress';
        objQuoteApproval.Quote_Approval_Step_Details__c = objQuoteApprovalStepDetail.id;
        objQuoteApproval.Quote_Approval_Date__c = System.today();
        objQuoteApproval.Step__c = 1;
        objQuoteApproval.BigMachines_Quote__c = objQuote.id;
        objQuoteApproval.Submitted_Date__c = System.today();
        insert objQuoteApproval;
        
        objCreateQuoteSubCont.quote.Revise_Minor__c = true;
        objCreateQuoteSubCont.quote.Expiration_Date__c = System.today().addDays(100);
        objCreateQuoteSubCont.fetchApprovals();
        //objCreateQuoteCloudCont.fetchUpfrontApprovals();
        
       // objCreateQuoteSubCont.list_QuoteProductRecords[0].addError('test Error');
        objCreateQuoteSubCont.saveBeforeReload();
    }
    //=============
    
    @isTest
    static void otherTest7(){
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Third_Party_GC__c =4;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'test1';
        objTestProd1.type__c = 'Bundle';
        list_ProductsToInsert.add(objTestProd1);                
        insert list_ProductsToInsert;
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.Product_Tier__c = 'Preferred';
        update objQuote;
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.BigMachines__Product__c = list_ProductsToInsert[0].id;
        }    
        update list_NewQuoteProds;
        
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        //objCreateQuoteSubCont.doCalculations();
    }
    
     @isTest
    static void otherTest8(){
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        List<Account> accounts = TestUtil.createAccounts(2, false);
        accounts[0].Country__c = objCountry.id;
        insert accounts;
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.type = 'Existing Business - Cross Sell';
        opportunities.CurrencyIsoCode = 'USD';      
        insert opportunities;
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Product';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Genesys_Care_Quote__c = true;
        objTestProd1.zqu__SKU__c = 'test1';
        objTestProd1.type__c = 'Product - Hardware';
        list_ProductsToInsert.add(objTestProd1);        
        insert list_ProductsToInsert;
        
        BigMachines__Quote__c objQuote1 = new BigMachines__Quote__c();
        objQuote1.Name = 'Test';
        objQuote1.Highest_Discount__c = 2;
        objQuote1.Total_Contract_Value_1__c = 2;
        objQuote1.Annual_Contract_Value_2__c = 2;
        objQuote1.PureSuccess_Offer_Subscription_Amount__c = 2;
        objQuote1.Keep_the_existing_estate_on_Perpetual__c = false;
        objQuote1.Annual_Contract_Value_1__c = 2;
        objQuote1.A_La_Carte_PureSuccess_Services_Amount__c = 2;
        objQuote1.Sold_To_Name__c = accounts[0].id;
        objQuote1.One_Time_Charges_1__c = 2;
        objQuote1.BEP_Third_Party_Genesys_Care__c = 2;
        objQuote1.Total_Contract_Value_1__c = 2;
        objQuote1.Annual_Contract_Value_2__c = 2;
        objQuote1.Amount_Due_At_Anniversary__c = 2;
        objQuote1.Cloud_Total__c = 2;
        insert objQuote1;
        
        Subscription__c objSub = new Subscription__c(Account__c = accounts[0].id);
        objSub.Subscription_Start_Date__c = System.today();
        objSub.Subscription_End_Date__c = System.today().addMonths(6);
        objSub.Quote__c = objQuote1.id;
        insert objSub;
        
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Total_Hardware__c= 20;
        objQuote.No_Of_Months__c=12;
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.BigMachines__Opportunity__c = opportunities.Id;
        objQuote.Amendment_For__c = objSub.id;
        objQuote.PureSuccess__c = 'Guide';
        objQuote.Quote_Created_Date__c = System.today();
        objQuote.PureSuccess_Offer_Subscription_Amount__c = 2;
        objQuote.A_La_Carte_PureSuccess_Services_Amount__c = 2;
        objQuote.One_Time_Charges_1__c = 2;
        objQuote.BEP_Third_Party_Genesys_Care__c = 2;
        objQuote.Total_Contract_Value_1__c = 2;
        objQuote.Annual_Contract_Value_1__c = 2;
        objQuote.Sold_To_Name__c = accounts[1].id;
        objQuote.Annual_Contract_Value_2__c = 2;
        objQuote.Amount_Due_At_Anniversary__c = 2;
        objQuote.Cloud_Total__c = 2;
        objQuote.Highest_Discount__c = 2;
        objQuote.BigMachines__Status__c = 'Quote In Progress';
        objQuote.BigMachines__Is_Primary__c = true;
        objQuote.Service_Level__c = 'Business'; 
        objQuote.New_Price_Book__c = 'NG5_NA_USD';
        Test.startTest();
        insert objQuote;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'PureSuccess';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Tes1t';
        prdgrp1.Group_Type__c = 'Base Package';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        Product_Group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Tes1t';
        prdgrp2.Group_Type__c = 'Campaigns';
        prdgrp2.Order__c = 12;
        prdgrp2.Quantity__c = 10;
        prdgrp2.Type__c = 'A la Carte';
        insert prdgrp2;
        
        BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();         
        qp.BigMachines__Quote__c = objQuote.id;
        qp.BigMachines__Quantity__c = 10;
        qp.BigMachines__Sales_Price__c = 500;
        qp.Ext_Net_Price__c = 20;
        qp.Ext_Net_Price_1__c = 1;
        qp.Ext_Net_Price_2__c = 1;
        qp.Net_Unit_Price_1__c = 1;
        qp.Net_Unit_Price_2__c = 1;
        qp.BigMachines__Product__c = list_ProductsToInsert[0].id;
        qp.Bundle__c = prdgrp.id;
        insert qp;
        
        BigMachines__Quote_Product__c qp1 = new BigMachines__Quote_Product__c();         
        qp1.BigMachines__Quote__c = objQuote.id;
        qp1.BigMachines__Quantity__c = 10;
        qp1.BigMachines__Sales_Price__c = 500;
        qp1.Ext_Net_Price__c = 20;
        qp1.Ext_Net_Price_1__c = 1;
        qp1.Ext_Net_Price_2__c = 1;
        qp1.Net_Unit_Price_1__c = 1;
        qp1.Net_Unit_Price_2__c = 1;
        qp1.BigMachines__Product__c = list_ProductsToInsert[0].id;
        qp1.Bundle_Line__c = qp.id;
        qp1.Bundle__c = prdgrp1.id;
        insert qp1;
        BigMachines__Quote_Product__c qp2 = new BigMachines__Quote_Product__c();         
        qp2.BigMachines__Quote__c = objQuote.id;
        qp2.BigMachines__Quantity__c = 10;
        qp2.BigMachines__Sales_Price__c = 500;
        qp2.Ext_Net_Price__c = 20;
        qp2.Ext_Net_Price_1__c = 1;
        qp2.Ext_Net_Price_2__c = 1;
        qp2.Net_Unit_Price_1__c = 1;
        qp2.Net_Unit_Price_2__c = 1;
        qp2.BigMachines__Product__c = list_ProductsToInsert[0].id;
        qp2.Bundle_Line__c = qp.id;
        qp2.Bundle__c = prdgrp2.id;
        insert qp2;
        qp.Bundle_Line__c = qp1.id;
        update qp;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        Test.stopTest();
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        //Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
       // objCreateQuoteSubCont.quote.BigMachines__Status__c = 'Quote Approved';
        //objCreateQuoteSubCont.quote.Approval_Submission_Date__c  = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(5);
       // objCreateQuoteSubCont.doCalculations();
        objCreateQuoteSubCont.migrationCreditResetBtnHandler();
        objCreateQuoteSubCont.changeSoldTo();
        
    }
    
    @isTest
    static void otherTest8a(){
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        List<Account> accounts = TestUtil.createAccounts(1, false);
        accounts[0].Country__c = objCountry.id;
        insert accounts;
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';      
        insert opportunities;
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';            
        objTestProd1.Type__c = 'Migration Credit';
        objTestProd1.Product_Type__c = 'Year 2';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'test1';
        objTestProd1.type__c = 'Product';
        list_ProductsToInsert.add(objTestProd1);

        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod1';            
        objTestProd.Type__c = 'Migration Credit';
        objTestProd.Product_Type__c = 'Year 1';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Description = 'test 1';
        objTestProd.OfferingType__c = 'PureSuccess';
        objTestProd.APN_Number__c = 'Tokens1';
        objTestProd.zqu__SKU__c = 'test12';
        objTestProd.type__c = 'GU';
        list_ProductsToInsert.add(objTestProd);
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Name = 'Test Prod1';            
        objTestProd2.Type__c = 'Token';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Description = 'test 1';
        objTestProd2.OfferingType__c = 'PureSuccess';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.zqu__SKU__c = 'test13';
        objTestProd2.type__c = 'PS';
        list_ProductsToInsert.add(objTestProd2);
        
        insert list_ProductsToInsert;
        
        BigMachines__Quote__c objQuote1 = new BigMachines__Quote__c();
        objQuote1.Name = 'Test';
        objQuote1.Highest_Discount__c = 2;
        objQuote1.Total_Contract_Value_1__c = 2;
        objQuote1.Annual_Contract_Value_2__c = 2;
        objQuote1.PureSuccess_Offer_Subscription_Amount__c = 2;
        objQuote1.Annual_Contract_Value_1__c = 2;
        objQuote1.A_La_Carte_PureSuccess_Services_Amount__c = 2;
        objQuote1.One_Time_Charges_1__c = 2;
        objQuote1.Treat_SO_as_PO__c = true;
        objQuote1.BEP_Third_Party_Genesys_Care__c = 2;
        objQuote1.Total_Contract_Value_1__c = 2;
        objQuote1.Annual_Contract_Value_2__c = 2;
        objQuote1.Amount_Due_At_Anniversary__c = 2;
        objQuote1.Cloud_Total__c = 2;
        insert objQuote1;
        
        Subscription__c objSub = new Subscription__c(Account__c = accounts[0].id);
        objSub.Subscription_Start_Date__c = System.today();
        objSub.Subscription_End_Date__c = System.today().addMonths(6);
        objSub.Quote__c = objQuote1.id;
        insert objSub;
        
        Subscription_Product__c subProd = new Subscription_Product__c();
        subProd.Subscription__c = objSub.Id;
        subProd.Hide_Record__c = true;
        subProd.Product__c = objTestProd1.Id;
        subProd.List_Price__c = 2;
        subProd.Is_Overage__c = false;
        insert subProd;
        
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.BigMachines__Opportunity__c = opportunities.Id;
        objQuote.Amendment_For__c = objSub.id;
        objQuote.PureSuccess__c = 'Guide';
        objQuote.Quote_Created_Date__c = System.today();
        objQuote.PureSuccess_Offer_Subscription_Amount__c = 2;
        objQuote.A_La_Carte_PureSuccess_Services_Amount__c = 2;
        objQuote.One_Time_Charges_1__c = 2;
        objQuote.BEP_Third_Party_Genesys_Care__c = 2;
        objQuote.Total_Contract_Value_1__c = 2;
        objQuote.Annual_Contract_Value_1__c = 2;
        objQuote.Annual_Contract_Value_2__c = 2;
        objQuote.Amount_Due_At_Anniversary__c = 2;
        objQuote.Multi_Year_Quote__c = true;
        objQuote.Cloud_Total__c = 2;
        objQuote.Highest_Discount__c = 2;
        objQuote.BigMachines__Status__c = 'Quote In Progress';
        objQuote.BigMachines__Is_Primary__c = true;
        objQuote.Service_Level__c = 'Business'; 
        objQuote.New_Price_Book__c = 'NG5_NA_USD';
        Test.startTest();
        insert objQuote;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'Base Package';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Tes1t';
        prdgrp1.Group_Type__c = 'A la Carte';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        Product_Group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Tes1t';
        prdgrp2.Group_Type__c = 'Campaigns';
        prdgrp2.Order__c = 12;
        prdgrp2.Quantity__c = 10;
        prdgrp2.Type__c = 'A la Carte';
        insert prdgrp2;
        
        BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();         
        qp.BigMachines__Quote__c = objQuote.id;
        qp.BigMachines__Quantity__c = 10;
        qp.BigMachines__Sales_Price__c = 500;
        qp.Ext_Net_Price_1__c = 1;
        qp.Ext_Net_Price_2__c = 1;
        qp.Net_Unit_Price_1__c = 1;
        qp.Net_Unit_Price_2__c = 1;
        qp.BigMachines__Product__c = list_ProductsToInsert[0].id;
        qp.Bundle__c = prdgrp.id;
        insert qp;
        
        BigMachines__Quote_Product__c qp1 = new BigMachines__Quote_Product__c();         
        qp1.BigMachines__Quote__c = objQuote.id;
        qp1.BigMachines__Quantity__c = 10;
        qp1.BigMachines__Sales_Price__c = 500;
        qp1.Ext_Net_Price_1__c = 1;
        qp1.Ext_Net_Price_2__c = 1;
        qp1.Net_Unit_Price_1__c = 1;
        qp1.Net_Unit_Price_2__c = 1;
        qp1.BigMachines__Product__c = list_ProductsToInsert[1].id;
        //qp1.Bundle_Line__c = qp.id;
        qp1.Bundle__c = prdgrp1.id;
        insert qp1;
        BigMachines__Quote_Product__c qp2 = new BigMachines__Quote_Product__c();         
        qp2.BigMachines__Quote__c = objQuote.id;
        qp2.BigMachines__Quantity__c = 10;
        qp2.BigMachines__Sales_Price__c = 500;
        qp2.Ext_Net_Price_1__c = 1;
        qp2.Ext_Net_Price_2__c = 1;
        qp2.Net_Unit_Price_1__c = 1;
        qp2.Net_Unit_Price_2__c = 1;
        qp2.BigMachines__Product__c = list_ProductsToInsert[2].id;
        //qp2.Bundle_Line__c = qp.id;
        qp2.Bundle__c = prdgrp2.id;
        insert qp2;
        qp.Bundle_Line__c = qp1.id;
        update qp;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        Test.stopTest();
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        //Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
       // objCreateQuoteSubCont.quote.BigMachines__Status__c = 'Quote Approved';
        //objCreateQuoteSubCont.quote.Approval_Submission_Date__c  = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(5);
        objCreateQuoteSubCont.createCurrentPageList();
        objCreateQuoteSubCont.deleteQuoteProducts();
        objCreateQuoteSubCont.doCalculations();
        
    }
    
    @isTest
    static void otherTest8b(){
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        List<Account> accounts = TestUtil.createAccounts(1, false);
        accounts[0].Country__c = objCountry.id;
        insert accounts;
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';      
        insert opportunities;
        
        ID BaseItemRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();  
        ID CoreProductRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('CORE - Product Record Type').getRecordTypeId();          
        List<Product2> list_ProductsToInsert = new List<Product2>();
        
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'test1';
        list_ProductsToInsert.add(objTestProd1);        
        insert list_ProductsToInsert;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'PureSuccess';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;

        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Lab';
        insert prdgrpItm;
        
        BigMachines__Quote__c objTestQuote1 = new BigMachines__Quote__c();
        objTestQuote1.BigMachines__Opportunity__c = opportunities.Id;
        objTestQuote1.Quote_Created_Date__c = System.today();
        objTestQuote1.BigMachines__Status__c = 'Quote In Progress';
        objTestQuote1.BigMachines__Is_Primary__c = true;
        objTestQuote1.Service_Level__c = 'Business'; 
        objTestQuote1.New_Price_Book__c = 'NG5_NA_USD';
        objTestQuote1.Pricing_Model__c = 'Enabled';
        objTestQuote1.Quote_Opportunity_Type__c = 'New Pricing';
        objTestQuote1.Annual_Contract_Value_1__c = 2;
        objTestQuote1.PureSuccess_Offer_Subscription_Amount__c = 2;
        objTestQuote1.A_La_Carte_PureSuccess_Services_Amount__c = 2;
        objTestQuote1.One_Time_Charges_1__c = 2;
        objTestQuote1.BEP_Third_Party_Genesys_Care__c = 2;
        objTestQuote1.Total_Contract_Value_1__c = 2;
        objTestQuote1.Annual_Contract_Value_2__c = 2;
        objTestQuote1.Amount_Due_At_Anniversary__c = 2;
        objTestQuote1.Cloud_Total__c = 2;
        objTestQuote1.Highest_Discount__c = 2;
        objTestQuote1.Duration_Unit__c = 'Months';
        objTestQuote1.Order_Numb_of_Maint_Months__c = 12;
        objTestQuote1.End_User_ID__c = accounts[0].id;
        objTestQuote1.Expiration_Date__c = Date.today().addDays(9);
        objTestQuote1.Approval_Submission_Date__c = Date.today().addDays(8);
        insert objTestQuote1;
        
        Subscription__c objSub = new Subscription__c(Account__c = objTestQuote1.End_User_ID__c);
        objSub.Subscription_Start_Date__c = System.today();
        objSub.Quote__c = objTestQuote1.id;
        objSub.Subscription_End_Date__c = System.today().addMonths(6);
        insert objSub;
        
        Subscription_Product__c subProd = new Subscription_Product__c();
        subProd.Subscription__c = objSub.Id;
        subProd.Hide_Record__c = true;
        subProd.Product__c = objTestProd1.Id;
        subProd.Is_Overage__c = false;
        insert subProd;
            
        BigMachines__Quote__c objTestQuote = new BigMachines__Quote__c();
        objTestQuote.BigMachines__Opportunity__c = opportunities.Id;
        objTestQuote.Quote_Created_Date__c = System.today();
        objTestQuote.BigMachines__Status__c = 'Quote In Progress';
        objTestQuote.BigMachines__Is_Primary__c = true;
        objTestQuote.Service_Level__c = 'Business'; 
        objTestQuote.New_Price_Book__c = 'NG5_NA_USD';
        objTestQuote.Pricing_Model__c = 'Enabled';
        objTestQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objTestQuote.Duration_Unit__c = 'Months';
        objTestQuote.Order_Numb_of_Maint_Months__c = 12;
        objTestQuote.Annual_Contract_Value_1__c = 2;
        objTestQuote.PureSuccess_Offer_Subscription_Amount__c = 2;
        objTestQuote.A_La_Carte_PureSuccess_Services_Amount__c = 2;
        objTestQuote.One_Time_Charges_1__c = 2;
        objTestQuote.BEP_Third_Party_Genesys_Care__c = 2;
        objTestQuote.Total_Contract_Value_1__c = 2;
        objTestQuote.Annual_Contract_Value_2__c = 2;
        objTestQuote.Amount_Due_At_Anniversary__c = 2;
        objTestQuote.Cloud_Total__c = 2;
        objTestQuote.Order_Type__c = 'Amend';
        objTestQuote.End_User_ID__c = accounts[0].id; 
        objTestQuote.Amendment_For__c = objSub.id;
        objTestQuote.BigMachines__Account__c = accounts[0].id;
        objTestQuote.Sold_To_Name__c = accounts[0].id; 
        objTestQuote.Support_Owner__c = accounts[0].id;
        objTestQuote.System_Integrator__c = accounts[0].id;
        objTestQuote.CurrencyISOCode = 'USD';
        objTestQuote.Quote_Business_Type__c = 'On Premise';
        objTestQuote.Highest_Discount__c = 2;
        objTestQuote.Expiration_Date__c = Date.today().addDays(9);
        objTestQuote.Approval_Submission_Date__c = Date.today().addDays(8);
        insert objTestQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objTestQuote.Id);  
        Test.StartTest();
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
        objCreateQuoteSubCont.quote.BigMachines__Status__c = 'Quote Approved';
        objCreateQuoteSubCont.quote.Approval_Submission_Date__c  = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(5);
        objCreateQuoteSubCont.doCalculations();
        Test.StopTest();
    }
    
    @isTest
    static void otherTest9(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Quote_Approval__c objQuoteApproval = new Quote_Approval__c();
        objQuoteApproval.Actual_Approver__c = UserInfo.getUserId();
        objQuoteApproval.Status__c = 'In Progress';
        objQuoteApproval.Quote_Approval_Date__c = System.today();
        objQuoteApproval.Step__c = 1;
        objQuoteApproval.BigMachines_Quote__c = objQuote.id;
        objQuoteApproval.Submitted_Date__c = System.today();
        insert objQuoteApproval;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
        objCreateQuoteSubCont.quote.Approval_Submission_Date__c  = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(-100);
        objCreateQuoteSubCont.quote.BigMachines__Status__c ='Quote Approval Pending';
        objCreateQuoteSubCont.doCalculations();       
        objCreateQuoteSubCont.reviseMajorBtnHandler();
    }
    
    @isTest
    static void otherTest10(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
        objCreateQuoteSubCont.quote.BigMachines__Status__c = 'Quote Approved';
        objCreateQuoteSubCont.quote.Approval_Submission_Date__c = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(-5);
        objCreateQuoteSubCont.quote.addError('test Error');
        objCreateQuoteSubCont.doCalculations();
    }
    
    /* @isTest
    static void otherTest11(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.Grid_Group_By__c = 'Proposal Groups';
        objQuote.Annual_Contract_Value_1__c = 2;
        objQuote.Highest_Discount__c = 2;
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();    
        
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);                
        list_NewQuotes[0].Order_Type__c = 'Amend';        
        update list_NewQuotes[0];
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
        //Create subscription & products        
        List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
        Subscription__c objNewSubscription = (list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
        objNewSubscription.Quote__c = objQuote.id;
        insert objNewSubscription;
        
        objQuote.Offering_Type__c = 'PureEngage Subscription';
        objQuote.Genesys_Care_Default_Pricing_Percentage__c = 10;
        objQuote.Genesys_Care_Rate__c = null;
        objQuote.Annual_Contract_Value_1__c = 2;
        objQuote.Duration_Unit__c = '';
        objQuote.Order_Numb_of_Maint_Months__c = null;
        objQuote.One_Time_Charges_1__c = 2;
        objQuote.BEP_Third_Party_Genesys_Care__c = 2;
        objQuote.Total_Contract_Value_1__c = 2;
        objQuote.Annual_Contract_Value_2__c = 2;
        objQuote.Amount_Due_At_Anniversary__c = 2;
        objQuote.Cloud_Total__c = 2;
        objQuote.Service_Level__c = null;
        objQuote.A_La_Carte_PureSuccess_Services_Amount__c =2;
        objQuote.Keep_the_existing_estate_on_Perpetual__c = false;
        objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
        objQuote.Pass_through__c = true;
        objQuote.PureSuccess_Offer_Subscription_Amount__c = 2;
        objQuote.Amendment_For__c = objNewSubscription.id;
        objQuote.Highest_Discount__c = 2;
        objQuote.BigMachines__Is_Primary__c = true;
        objQuote.Legal_Contract__c = null;
        update objQuote;
        
        list_NewQuotes[0].Order_Type__c = 'Amend';        
        list_NewQuotes[0].Amendment_For__c = objNewSubscription.id;
        update list_NewQuotes[0];
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;
        
        List<Subscription_Product__c> list_SubscriptionProds = [SELECT Id, Product__r.APN_Number__c, Product__c,Subscription__r.Account__c,
                                                                       Subscription__r.Subscription_Start_Date__c, Quantity__c,
                                                                       Subscription__r.Start_Date__c, Subscription__r.Name, Subscription__c
                                                                FROM Subscription_Product__c 
                                                                WHERE Subscription__c =: objNewSubscription.Id];
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].id);  
        CreateQuoteSubscriptionController objCreateQuoteSubCont1 = new CreateQuoteSubscriptionController();
        //objCreateQuoteSubCont1.buildChangeHistoryForAmendSubscr();
        
    }*/
    
    @isTest
    static void otherTest11(){
        List<Account> accounts = TestUtil.createAccounts(2, false);
        insert accounts;
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.type = 'Existing Business - Cross Sell';
        opportunities.CurrencyIsoCode = 'USD';      
        insert opportunities;
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'Campaign';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'test1';
        insert objTestProd1;
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.BigMachines__Opportunity__c = opportunities.Id;
        objQuote.Credit_Adjustment__c = 2;
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'PureConnect Subscription';
        objQuote.Pricing_Model__c ='Concurrent';
        objQuote.Service_Level__c = 'TEst';
        objQuote.Sold_To_Name__c = accounts[0].id;
        objQuote.Keep_the_existing_estate_on_Perpetual__c = false;
        objQuote.MSA_Link_Type__c = 'Standard';
        update objQuote;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'Campaigns';
        prdgrp.Offering_Type__c = 'PureConnect Subscription';
        prdgrp.Quantity__c = 10;
        prdgrp.Active__c = true;
        prdgrp.Pricing_Model__c ='Concurrent';
        insert prdgrp;
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
        list_NewQuoteProds[0].Bundle__c = prdgrp.id;
        list_NewQuoteProds[0].Third_Party_GC__c = 1;
        list_NewQuoteProds[0].Ext_List__c = 1;
        list_NewQuoteProds[0].Partner_Price__c = 1;
        list_NewQuoteProds[0].Product_Specific_Discount__c = 1;
        list_NewQuoteProds[0].Group_Number__c = 'test';
        list_NewQuoteProds[0].Discount__c = 1;
        list_NewQuoteProds[0].BigMachines__Product__c = objTestProd1.id;
        update list_NewQuoteProds;
        
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);
        System.currentPageReference().getParameters().put('clone', '1');        
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
        objCreateQuoteSubCont.quote.BigMachines__Status__c = 'Quote Approved';
        objCreateQuoteSubCont.quote.Approval_Submission_Date__c = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(-5);
        objCreateQuoteSubCont.quote.addError('test Error');
        objCreateQuoteSubCont.doCalculations();
        objCreateQuoteSubCont.changePricingModel();
        objCreateQuoteSubCont.cloneBtnHandler();
        objQuote.Sold_To_Name__c = accounts[1].id;
        objCreateQuoteSubCont.changeSoldTo();
        objCreateQuoteSubCont.reviseMajorBtnHandler();
        objCreateQuoteSubCont.cloneQuoteOnLoad();
        objCreateQuoteSubCont.setMSALink();
        objCreateQuoteSubCont.cancelBtnHandler();
        objCreateQuoteSubCont.saveGC();
        objCreateQuoteSubCont.populateBasePackageWeightageIfMissing(prdgrp.id);
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        objQuote.Sold_To_Name__c = acc.id;
        update objQuote;
        objCreateQuoteSubCont.changeSoldTo();
        objCreateQuoteSubCont.quoteProductIdToBeDeleted = [SELECT Id FROM BigMachines__Quote_Product__c 
                                                             WHERE BigMachines__Quote__c =: objQuote.Id LIMIT 1].id ;
        objCreateQuoteSubCont.strToDelete = 'yes';
        objCreateQuoteSubCont.deleteQuoteProduct();
        
    }
    
     @isTest
    static void otherTest12(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.Grid_Group_By__c = 'Recurring/Non-Recurring';
        objQuote.Highest_Discount__c = 1;
        objQuote.Annual_Contract_Value_1__c = 2;
        objQuote.PureSuccess_Offer_Subscription_Amount__c = 2;
        objQuote.A_La_Carte_PureSuccess_Services_Amount__c = 2;
        objQuote.One_Time_Charges_1__c = 2;
        objQuote.BEP_Third_Party_Genesys_Care__c = 2;
        objQuote.Total_Contract_Value_1__c = 2;
        objQuote.Annual_Contract_Value_2__c = 2;
        objQuote.Amount_Due_At_Anniversary__c = 2;
        objQuote.Cloud_Total__c = 2;
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        
        
        
        Opportunity objOpp = new Opportunity(id = objQuote.BigMachines__Opportunity__c, Type = 'Existing Business - Cross Sell');
        update objOpp;
        
        Subscription__c objSub = new Subscription__c(Account__c = objQuote.End_User_ID__c);
        objSub.Subscription_Start_Date__c = System.today();
        objSub.Quote__c = objQuote.id;
        objSub.Subscription_End_Date__c = System.today().addMonths(6);
        insert objSub;
        
        objQuote.Offering_Type__c = 'PureEngage Subscription';
        objQuote.Genesys_Care_Default_Pricing_Percentage__c = 10;
        objQuote.Genesys_Care_Rate__c = null;
        objQuote.Annual_Contract_Value_1__c = 2;
        objQuote.Duration_Unit__c = '';
        objQuote.Order_Numb_of_Maint_Months__c = null;
        objQuote.One_Time_Charges_1__c = 2;
        objQuote.BEP_Third_Party_Genesys_Care__c = 2;
        objQuote.Total_Contract_Value_1__c = 2;
        objQuote.Annual_Contract_Value_2__c = 2;
        objQuote.Amount_Due_At_Anniversary__c = 2;
        objQuote.Cloud_Total__c = 2;
        objQuote.Service_Level__c = null;
        objQuote.A_La_Carte_PureSuccess_Services_Amount__c =2;
        objQuote.Keep_the_existing_estate_on_Perpetual__c = false;
        objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
        objQuote.Pass_through__c = true;
        objQuote.PureSuccess_Offer_Subscription_Amount__c = 2;
        objQuote.Amendment_For__c = objSub.id;
        objQuote.Highest_Discount__c = 2;
        objQuote.BigMachines__Is_Primary__c = true;
        objQuote.Legal_Contract__c = null;
        update objQuote;
        CreateQuoteSubscriptionController objCreateQuoteSubCont1 = new CreateQuoteSubscriptionController();
        objCreateQuoteSubCont1.initializeCareRate(); 
        //objCreateQuoteSubCont1.calculatePercentPriceForAmendment();
        objSub.Subscription_End_Date__c = System.today().addMonths(14);
        update objSub;
        //objCreateQuoteSubCont1.calculatePercentPriceForAmendment();
        //objCreateQuoteSubCont1.populateAmendTotals();
        
        
        Contact con = new Contact();
        con.AccountId = objQuote.End_User_ID__c;
        con.LastName = 'Test Contact';
        con.Email = 'standarduser@testorg.com';
        
        GCR__c gcr = new GCR__c();
        gcr.Contact__c = con.id;
        gcr.Account__c = objQuote.End_User_ID__c;
        gcr.Request_Type__c = 'Sales';
        gcr.Contact_Name__c = con.Name;
        gcr.Contact_Phone__c = con.ContactPhone__c;
        gcr.Requestor_Name__c = UserInfo.getUserId();
        gcr.Attorney_Name__c = UserInfo.getUserId();
        insert gcr;
        
        GCR_Content_Document_Folder__c gcrFolder = new GCR_Content_Document_Folder__c();
        gcrFolder.Name = gcr.Name;
        gcrFolder.Account__c = gcr.Account__c;
        gcrFolder.GCR__c = gcr.id;
        gcrFolder.Active__c = true;
        
        GCR_Content_Document_Detail__c  gcrDocDetail = new GCR_Content_Document_Detail__c();
        gcrDocDetail.Folder__c = gcrFolder.id;
        gcrDocDetail.Account_Name__c = objQuote.End_User_ID__c;
        gcrDocDetail.GCR__c = gcr.id;
        gcrDocDetail.Document_Name__c = gcr.Name;
        gcrDocDetail.Active__c = true;
        insert gcrDocDetail;
        
        //objCreateQuoteSubCont1.popualateContractOnQuote();
        
        //CreateQuoteSubscriptionController.updateShippingAndHandling(objQuote, null, new BigMachines__Quote_Product__c(), null);
        //CreateQuoteSubscriptionController.updateShippingAndHandling(objQuote, new BigMachines__Quote_Product__c(), new BigMachines__Quote_Product__c(), null);
        
        
    }
     @isTest
    static void otherTest13(){
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        List<Account> accounts = TestUtil.createAccounts(1, false);
        accounts[0].Country__c = objCountry.id;
        insert accounts;
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';      
        insert opportunities;
        
        ID BaseItemRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();  
        ID CoreProductRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('CORE - Product Record Type').getRecordTypeId();          
        List<Product2> list_ProductsToInsert = new List<Product2>();
        
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'test1';
        list_ProductsToInsert.add(objTestProd1);        
        insert list_ProductsToInsert;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'PureSuccess';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;

        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Lab';
        insert prdgrpItm;
        
        BigMachines__Quote__c objTestQuote1 = new BigMachines__Quote__c();
        objTestQuote1.BigMachines__Opportunity__c = opportunities.Id;
        objTestQuote1.Quote_Created_Date__c = System.today();
        objTestQuote1.BigMachines__Status__c = 'Quote In Progress';
        objTestQuote1.BigMachines__Is_Primary__c = true;
        objTestQuote1.Service_Level__c = 'Business'; 
        objTestQuote1.New_Price_Book__c = 'NG5_NA_USD';
        objTestQuote1.Pricing_Model__c = 'Enabled';
        objTestQuote1.Order_Type__c = 'Amend';
        objTestQuote1.Quote_Opportunity_Type__c = 'New Pricing';
        objTestQuote1.Annual_Contract_Value_1__c = 2;
        objTestQuote1.PureSuccess_Offer_Subscription_Amount__c = 2;
        objTestQuote1.A_La_Carte_PureSuccess_Services_Amount__c = 2;
        objTestQuote1.One_Time_Charges_1__c = 2;
        objTestQuote1.BEP_Third_Party_Genesys_Care__c = 2;
        objTestQuote1.Total_Contract_Value_1__c = 2;
        objTestQuote1.Annual_Contract_Value_2__c = 2;
        objTestQuote1.Amount_Due_At_Anniversary__c = 2;
        objTestQuote1.Cloud_Total__c = 2;
        objTestQuote1.Highest_Discount__c = 2;
        objTestQuote1.Duration_Unit__c = 'Months';
        objTestQuote1.Migration_Credit__c = 1;
        objTestQuote1.Order_Numb_of_Maint_Months__c = 12;
        objTestQuote1.New_Price_Book__c = 'NG3_EMEA_USD';
        objTestQuote1.End_User_ID__c = accounts[0].id;
        objTestQuote1.Expiration_Date__c = Date.today().addDays(9);
        objTestQuote1.Approval_Submission_Date__c = Date.today().addDays(8);
        insert objTestQuote1;
        
        Subscription__c objSub = new Subscription__c(Account__c = objTestQuote1.End_User_ID__c);
        objSub.Subscription_Start_Date__c = System.today();
        objSub.Quote__c = objTestQuote1.id;
        objSub.Subscription_End_Date__c = System.today().addMonths(6);
        insert objSub;
        
        Subscription_Product__c subProd = new Subscription_Product__c();
        subProd.Subscription__c = objSub.Id;
        subProd.Hide_Record__c = true;
        subProd.Product__c = objTestProd1.Id;
        subProd.Is_Overage__c = false;
        insert subProd;
        
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c ();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'PureConnect Subscription';
        objQuote.Grid_Group_By__c = 'Test Group';
        objQuote.Annual_Contract_Value_1__c = 2;
        objQuote.PureSuccess_Offer_Subscription_Amount__c = 2;
        objQuote.A_La_Carte_PureSuccess_Services_Amount__c = 2;
        objQuote.One_Time_Charges_1__c = 2;
        objQuote.BEP_Third_Party_Genesys_Care__c = 2;
        objQuote.Total_Contract_Value_1__c = 2;
        objQuote.Annual_Contract_Value_2__c = 2;
        objQuote.Migration_Credit__c = 1;
        objQuote.Amount_Due_At_Anniversary__c = 2;
        objQuote.Cloud_Total__c = 2;
        objQuote.Highest_Discount__c = 2;
        objQuote.Pricing_Model__c = 'Enabled';
        objQuote.New_Price_Book__c = 'NG3_EMEA_USD';
        objQuote.Order_Type__c = 'Amend';
        objQuote.Amendment_For__c = objSub.id;
        insert objQuote;

        Product2 objQtProd = [SELECT id FROM Product2 WHERE OfferingType__c INCLUDES ('PureConnect Subscription') LIMIT 1];
        objQtProd.Flavors_Available__c = 'test';       
        update objQtProd;
        
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
        list_NewQuoteProds[0].Unit_of_Measure__c = 'seat';  
        list_NewQuoteProds[0].Quantity__c  = 1;
        list_NewQuoteProds[1].Quantity__c  = 1;
        update list_NewQuoteProds;
        
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        
        //objCreateQuoteSubCont.deleteQuoteProducts();
        Test.startTest();
        objCreateQuoteSubCont.changePricingModel();
        Util.Bypass_Trigger_Chk = true;
        list_NewQuoteProds[0].Pricing_Model__c = 'Concurrent';
        update list_NewQuoteProds;
        objQuote.Pricing_Model__c = 'Concurrent';
        objQuote.Migration_Credit__c = 0;
        update objQuote;
        CreateQuoteSubscriptionController objCreateQuoteSubCont1 = new CreateQuoteSubscriptionController();
        objCreateQuoteSubCont1.migrationCreditBtnHandler();
        //objCreateQuoteSubCont1.changePricingModel();
        list_NewQuoteProds[0].Pricing_Model__c = 'Concurrent';
        update list_NewQuoteProds;
        objQuote.Pricing_Model__c = 'Concurrent';
        objQuote.Migration_Credit__c = 1000;
        objQuote.Annual_Contract_Value_2__c = 1010;
        objQuote.Annual_Contract_Value_1__c = 1010;
        update objQuote;
        CreateQuoteSubscriptionController objCreateQuoteSubCont2 = new CreateQuoteSubscriptionController();
        objCreateQuoteSubCont2.migrationCreditBtnHandler();
        
        //objCreateQuoteSubCont2.changePricingModel();
        list_NewQuoteProds[0].Pricing_Model__c = 'Named User';
        update list_NewQuoteProds;
        objQuote.Pricing_Model__c = 'Named User';
        update objQuote;
        Test.StopTest();  
    }
    
    @isTest
    static void otherTest13a(){
        
        Util.Bypass_Trigger_Chk = true;
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = '3GP00590AMC1';
        objTestProd1.zqu__SKU__c = 'test1';        
        insert objTestProd1;
        
        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod1';            
        objTestProd.Type__c = 'Token';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Description = 'test 1';
        objTestProd.OfferingType__c = 'PureSuccess';
        objTestProd.APN_Number__c = '3GP00590AMC2';
        objTestProd.zqu__SKU__c = 'test';        
        insert objTestProd;
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Treat_SO_as_PO__c = true;
        objQuote.Order_Ship_Software_Via__c = 'FTP';
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'PureConnect Subscription';
        objQuote.Grid_Group_By__c = 'Test Group';
        objQuote.Pricing_Model__c = 'Enabled';
        objQuote.Migration_Credit__c = 2;
        objQuote.Product_Tier__c = 'Preferred';
        objQuote.Annual_Contract_Value_1__c = 4;
        objQuote.Annual_Contract_Value_2__c =4;
        update objQuote;
        Product2 objQtProd = [SELECT id FROM Product2 WHERE OfferingType__c INCLUDES ('PureConnect Subscription') LIMIT 1];
        objQtProd.Flavors_Available__c = 'test';
        update objQtProd;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
        list_NewQuoteProds[0].Unit_of_Measure__c = 'seat';  
        list_NewQuoteProds[0].Quantity__c  = 1;
        list_NewQuoteProds[1].Quantity__c  = 1;
        update list_NewQuoteProds;
        
        CreateQuoteSubscriptionController objCreateQuoteSubCont3 = new CreateQuoteSubscriptionController();
        objQuote.Migration_Credit__c = 10000;
        update objQuote;
        //objCreateQuoteSubCont3.migrationCreditBtnHandler();       
        Test.StartTest(); 
        //objCreateQuoteSubCont3.changePricingModel();
        objCreateQuoteSubCont3.submitOrderBtnHandler();
        list_NewQuoteProds[0].Pricing_Model__c = 'Branch Office';
        update list_NewQuoteProds;
        objQuote.Pricing_Model__c = 'Branch Office';
        update objQuote;
        CreateQuoteSubscriptionController objCreateQuoteSubCont4 = new CreateQuoteSubscriptionController();
        //objCreateQuoteSubCont4.objAttachment = new Attachment(Name = 'Test', ParentId = objQuote.id, Body = Blob.valueOf('This is test body'));        
        objCreateQuoteSubCont4.submitOrderBtnHandler();
        
        //objCreateQuoteSubCont4.changePricingModel();
        Test.stopTest();
    }
    
    @isTest
    static void otherTest13b(){
        
        Util.Bypass_Trigger_Chk = true;
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = '3GP00590AMC1';
        objTestProd1.zqu__SKU__c = 'test1';        
        insert objTestProd1;
        
        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod1';            
        objTestProd.Type__c = 'Token';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Description = 'test 1';
        objTestProd.OfferingType__c = 'PureSuccess';
        objTestProd.APN_Number__c = '3GP00590AMC2';
        objTestProd.zqu__SKU__c = 'test';        
        insert objTestProd;
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Treat_SO_as_PO__c = true;
        objQuote.Order_Ship_Software_Via__c = 'FTP';
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'PureConnect Subscription';
        objQuote.Grid_Group_By__c = 'Test Group';
        objQuote.Pricing_Model__c = 'Enabled';
        objQuote.Product_Tier__c = 'Preferred';
        objQuote.Migration_Credit__c = 2;
        objQuote.Annual_Contract_Value_1__c = 4;
        objQuote.Annual_Contract_Value_2__c =4;
        update objQuote;
        Product2 objQtProd = [SELECT id FROM Product2 WHERE OfferingType__c INCLUDES ('PureConnect Subscription') LIMIT 1];
        objQtProd.Flavors_Available__c = 'test';
        update objQtProd;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
        list_NewQuoteProds[0].Unit_of_Measure__c = 'seat';  
        list_NewQuoteProds[0].Quantity__c  = 1;
        list_NewQuoteProds[1].Quantity__c  = 1;
        update list_NewQuoteProds;
        Test.StartTest();
        
        list_NewQuoteProds[0].Pricing_Model__c = 'Test';
        update list_NewQuoteProds;
        objQuote.Pricing_Model__c = 'Test';        
        update objQuote;
        CreateQuoteSubscriptionController objCreateQuoteSubCont5 = new CreateQuoteSubscriptionController();
        objQuote.Order_PO_Number__c = '1234567';
        objQuote.Order_PO_Date__c = System.today();
        objQuote.Order_Ship_Software_Via__c = 'Courier';
        objQuote.Server_OS__c = 'AIX';
        objQuote.PBX__c= 'Alcatel';
        objQuote.Database__c = 'DB2';
        objQuote.Add_Language__c = 'English';
        objQuote.IVR__c = 'Agility';
        objQuote.IVR__c = 'Agility';
        objQuote.IVR__c = 'Agility';
        update objQuote;
        objCreateQuoteSubCont5.submitOrderBtnHandler();
        //objCreateQuoteSubCont5.changePricingModel();
        //objCreateQuoteSubCont5.finalizeQuote();
        Test.stopTest();
    }
    
    @isTest
    static void otherTest13c(){
        Util.Bypass_Trigger_Chk = true;
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = '3GP00590AMC1;3GP00590AMC2';
        objTestProd1.zqu__SKU__c = 'test1';        
        insert objTestProd1;
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Treat_SO_as_PO__c = true;
        objQuote.Order_Ship_Software_Via__c = 'FTP';
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'PureConnect Subscription';
        objQuote.Grid_Group_By__c = 'Test Group';
        objQuote.Pricing_Model__c = 'Enabled';
        objQuote.Product_Tier__c = 'Preferred';
        objQuote.Migration_Credit__c = 2;
        objQuote.Annual_Contract_Value_1__c = 4;
        objQuote.Annual_Contract_Value_2__c =4;
        update objQuote;
        Product2 objQtProd = [SELECT id FROM Product2 WHERE OfferingType__c INCLUDES ('PureConnect Subscription') LIMIT 1];
        objQtProd.Flavors_Available__c = 'test';
        update objQtProd;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
        list_NewQuoteProds[0].Unit_of_Measure__c = 'seat';  
        list_NewQuoteProds[0].Quantity__c  = 1;
        list_NewQuoteProds[1].Quantity__c  = 1;
        update list_NewQuoteProds;
        CreateQuoteSubscriptionController objCreateQuoteSubCont3 = new CreateQuoteSubscriptionController();
        objQuote.Migration_Credit__c = 10000;
        update objQuote;
        //objCreateQuoteSubCont3.migrationCreditBtnHandler();        
        //objCreateQuoteSubCont3.changePricingModel();
        Test.StartTest();
        objCreateQuoteSubCont3.submitOrderBtnHandler();
        list_NewQuoteProds[0].Pricing_Model__c = 'Branch Office';
        update list_NewQuoteProds;
        objQuote.Pricing_Model__c = 'Branch Office';
        update objQuote;
        CreateQuoteSubscriptionController objCreateQuoteSubCont4 = new CreateQuoteSubscriptionController();
        //objCreateQuoteSubCont4.objAttachment = new Attachment(Name = 'Test', ParentId = objQuote.id, Body = Blob.valueOf('This is test body'));        
        objCreateQuoteSubCont4.submitOrderBtnHandler();
        //objCreateQuoteSubCont4.changePricingModel();
        Test.stopTest();
    }
    
    @isTest
    static void otherTest13d(){
        Util.Bypass_Trigger_Chk = true;
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = '3GP00590AMC1;3GP00590AMC2';
        objTestProd1.zqu__SKU__c = 'test1';        
        insert objTestProd1;
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Treat_SO_as_PO__c = true;
        objQuote.Order_Ship_Software_Via__c = 'FTP';
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'PureConnect Subscription';
        objQuote.Grid_Group_By__c = 'Test Group';
        objQuote.Pricing_Model__c = 'Enabled';
        objQuote.Migration_Credit__c = 2;
        objQuote.Product_Tier__c = 'Preferred';
        objQuote.Annual_Contract_Value_1__c = 4;
        objQuote.Annual_Contract_Value_2__c =4;
        update objQuote;
        Product2 objQtProd = [SELECT id FROM Product2 WHERE OfferingType__c INCLUDES ('PureConnect Subscription') LIMIT 1];
        objQtProd.Flavors_Available__c = 'test';
        update objQtProd;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
        list_NewQuoteProds[0].Unit_of_Measure__c = 'seat';  
        list_NewQuoteProds[0].Quantity__c  = 1;
        list_NewQuoteProds[1].Quantity__c  = 1;
        update list_NewQuoteProds;
        
        Test.StartTest();
        list_NewQuoteProds[0].Pricing_Model__c = 'Test';
        update list_NewQuoteProds;
        objQuote.Pricing_Model__c = 'Test';
        
        update objQuote;
        CreateQuoteSubscriptionController objCreateQuoteSubCont5 = new CreateQuoteSubscriptionController();
        objQuote.Order_PO_Number__c = '1234567';
        objQuote.Order_PO_Date__c = System.today();
        objQuote.Order_Ship_Software_Via__c = 'Courier';
        objQuote.Server_OS__c = 'AIX';
        objQuote.PBX__c= 'Alcatel';
        objQuote.Database__c = 'DB2';
        objQuote.Add_Language__c = 'English';
        objQuote.IVR__c = 'Agility';
        objQuote.IVR__c = 'Agility';
        objQuote.IVR__c = 'Agility';
        update objQuote;
        objCreateQuoteSubCont5.submitOrderBtnHandler();
        //objCreateQuoteSubCont5.changePricingModel();
        //objCreateQuoteSubCont5.finalizeQuote();
        Test.stopTest();
    }
   
    //==========
    
    
     private static BigMachines__Quote__c prepareData() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        list_NewOpps[0].Total_PS_Support__c = 2;
        update list_NewOpps;
        System.assertEquals(list_NewOpps.size(), 1);
      
      //  List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        
        List<BigMachines__Quote__c> list_NewQuotes = new List<BigMachines__Quote__c>();
        List<RecordType> rt = [SELECT Id FROM RecordType WHERE SobjectType = 'BigMachines__Quote__c' AND Name = 'Standard'];
        BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c(
                RecordTypeId = rt[0].Id,
                BigMachines__Opportunity__c = list_NewOpps[0].id, Quote_Created_Date__c = System.today(), 
                BigMachines__Status__c = 'Quote In Progress', BigMachines__Is_Primary__c = true,
                Product_Tier__c = 'Premium', Offering_Type__c = 'PureConnect Cloud',
                Service_Level__c = 'Business', Pricing_Model__c = 'Enabled', 
                Quote_Opportunity_Type__c = 'New Pricing', Duration_Unit__c = 'Months', 
                Order_Numb_of_Maint_Months__c = 12, Order_Type__c = 'Revenue', 
                End_User_ID__c = list_NewAccts[0].id, BigMachines__Account__c = list_NewAccts[0].id, 
                Sold_To_Name__c = list_NewAccts[0].id, New_Price_Book__c = 'NG5_NA_USD', 
                Support_Owner__c = list_NewAccts[0].id, System_Integrator__c = list_NewAccts[0].id, 
                CurrencyISOCode = 'USD', Quote_Business_Type__c = 'Cloud', 
                Expiration_Date__c = Date.today().addDays(90), Deployment_Model__c = 'Local Control',
                Approval_Submission_Date__c = Date.today(),Annual_Contract_Value__c = 1000000,Total_Hardware__c = 1000,Total_Education__c = 1000,Setup_Provisioning_Charges__c = 1000,Ramp_Period__c = '180.8976');
        insert objNewQuote;
        list_NewQuotes.add(objNewQuote);

        System.assertEquals(list_NewQuotes.size(), 1);
        Country__c objNewCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD');    
        insert objNewCountry;
        
        list_NewAccts[0].Country__c = objNewCountry.Id;
        update list_NewAccts[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        update list_NewOpps[0];
        
        //Add quote line items        
       // List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
       //System.assertEquals(list_NewQuoteProds.size(), 2);  
    
       List<Product2> list_Products = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 WHERE OfferingType__c INCLUDES ('PureConnect Subscription') LIMIT 1];
      
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = new  List<BigMachines__Quote_Product__c>();
        BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = list_NewQuotes[0].Id, BigMachines__Product__c = list_Products[0].Id,
                Name = list_Products[0].Name, Build_Type__c = list_Products[0].Name, APN_Number__c = list_Products[0].APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000,List_Price__c=100,Extended_Price_Per_Month__c = 1100,Quantity__c=200);
        insert objNewQuoteProduct;
        list_NewQuoteProds.add(objNewQuoteProduct);

        //Unit tests for CreateQuoteSubscriptionController methods    
        BigMachines__Quote__c objQuote = list_NewQuotes[0];  
        objQuote.No_Of_Months__c=12;
        objQuote.Deployment_Model__c='Local Control';
        objQuote.Ramp_Period__c='60';
        objQuote.Initial_Subscription_Term__c='1 Year';
        objQuote.Billing_Period__c='Annually';
        objQuote.MSA_Link__c='www.google.com';  
        objQuote.Sold_To_Name__c=[SELECT Id FROM Account WHERE Id != :list_NewAccts[0].Id LIMIT 1].Id;  
        objQuote.Sent_to_Customer__c=true;
        objQuote.Special_Offer_Terms__c='New Offer';
        objQuote.Grid_Group_By__c='Categories';
        objQuote.Product_Tier__c = 'Preferred';
        objQuote.New_Price_Book__c='NG5_NA_USD';
        update objQuote;      
                 
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='1';
            objQP.Ext_List__c =102;
        }    
        list_NewQuoteProds[0].or_Amount__c='Amt';
        update list_NewQuoteProds;
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objQtProd;
        
        Quote_Proposal_Group__c objQProposalGroup = new Quote_Proposal_Group__c( Quote__c = objQuote.id,
                                                                                Description__c = 'Test',
                                                                                Discount__c = 2.5,
                                                                                Group_Number__c = 'PG1',
                                                                                Goal_Seek__c = 1 ,
                                                                                Name__c = 'Test Proposal Group'
                                                                               );
        insert objQProposalGroup;
        
        return objQuote;
    }
    
    @isTest
    static void intialTests_14a() {
     
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        Test.startTest();
        BigMachines__Quote__c objQuote = prepareData2();
        objQuote.Total_Contract_Value__c = 10;
        update objQuote;
        //Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteSubscriptionController  objCreateQuoteSubCont = new CreateQuoteSubscriptionController (); 
       
        //objCreateQuoteSubCont.convertToRealQuoteBtnHandler();
        objCreateQuoteSubCont.saveBeforeReload();         
        //objCreateQuoteSubCont.showHistoryAndAttachments();
        //objCreateQuoteSubCont.showProposalOptions();
        //objCreateQuoteSubCont.changePricingModel();
        //objCreateQuoteSubCont.changeSoldTo();
        //objCreateQuoteSubCont.cloneBtnHandler();
        //objCreateQuoteSubCont.reviseMajorBtnHandler();
        
        
        
        
        Test.stopTest();
      
    }
    
    private static BigMachines__Quote__c prepareData2() {
        
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        Country__c objNewCountry = new Country__c(Name='Japan',Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD');    
        insert objNewCountry;
        
        list_NewAccts[0].Country__c = objNewCountry.Id;
        update list_NewAccts[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        update list_NewOpps[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        //System.assertEquals(list_NewQuoteProds.size(), 2);  
    
        //Unit tests for CreateQuoteOnPremiseController1 methods    
        BigMachines__Quote__c objQuote = list_NewQuotes[0];  
        objQuote.No_Of_Months__c=12;
        objQuote.Deployment_Model__c='Local Control';
        objQuote.Ramp_Period__c='60';
        objQuote.Initial_Subscription_Term__c='1 Year';
        objQuote.Billing_Period__c='Annually';
        objQuote.MSA_Link__c='www.google.com';  
        objQuote.Sold_To_Name__c=[SELECT Id FROM Account WHERE Id != :list_NewAccts[0].Id LIMIT 1].Id;  
        objQuote.Sent_to_Customer__c=true;
        objQuote.Special_Offer_Terms__c='New Offer';
        objQuote.Grid_Group_By__c='Categories';
        objQuote.New_Price_Book__c='NG5_NA_USD';
        objQuote.Pricing_Model__c = 'Enabled';
        objQuote.Services_Tax_Rate__c = 0.2;
        objQuote.Training_Tax_Rate__c = 0.1;
        objQuote.Tax_Rate__c = 0.1;
        update objQuote;      
        
        //added on 21Aug'18
        BigMachines__Quote_Product__c qpRec=    [SELECT Id,Unit_of_Measure__c, Adjustment__c, Disc__c, or_Amount__c,                   BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id limit 1];  
        
        qpRec.APN_Number__c = 'CS-012-NV-RBAF';
        qpRec.Group_Number__c = 'PG1';
        qpRec.Quantity__c = 10;
        //qpRec.Group_Type__c = 'Campaigns';
        qpRec.or_Amount__c='%';
        qpRec.Third_Party__c = 'TRUE';
        update qpRec;
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c,Unit_of_Measure__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c,Total_Discount__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        
        System.debug('******************list_NewQuoteProds size***** ' + list_NewQuoteProds.size());
        if(list_NewQuoteProds.size() > 0)
            list_NewQuoteProds[1].Bundle_Line__c= qpRec.id;
          
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        //update objQtProd;
        
        //Added on 21/08/18
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Bundle';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Shipment_Approval__c ='Required for New Orders Only';
        objTestProd1.Description = 'Campaign';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Flavors_Available__c = 'test';
        objTestProd1.Building_Block__c = 'Chat';
        objTestProd1.zqu__SKU__c = 'test213';
        objTestProd1.Include_in_Agent_Seat_Count__c = true;
        objTestProd1.Third_Party__c = 'TRUE';
        list_ProductsToInsert.add(objTestProd1);
        
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Name = 'Test Prod1';            
        objTestProd2.Type__c = 'Product - Hardware';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Shipment_Approval__c ='Required for New Orders Only';
        objTestProd2.Description = 'Campaign';
        objTestProd2.OfferingType__c = 'PureSuccess';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.Shipping_Cost__c = 100;
        objTestProd2.Pricing_Model__c = 'Concurrent';
        objTestProd2.Flavors_Available__c = 'test';
        objTestProd2.Building_Block__c = 'Chat';
        objTestProd2.zqu__SKU__c = 'testin213';
        objTestProd2.Include_in_Agent_Seat_Count__c = true;
        objTestProd2.Third_Party__c = 'TRUE';
        list_ProductsToInsert.add(objTestProd2);
               
        insert list_ProductsToInsert;
        
        
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Partner PureSuccess';
        prdgrp.Group_Type__c = 'Campaigns';//qpRec.Group_Type__c = 'Campaigns';
        prdgrp.Active__c = true;
        prdgrp.Pricing_Model__c = 'Named User';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = ' PureConnect On Premise';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Equip';
        prdgrp2.Group_Type__c = 'PureSuccess';
        prdgrp2.Active__c = true;
        prdgrp2.Pricing_Model__c = 'Concurrent';
        prdgrp2.Product__c = list_ProductsToInsert[0].id;
        prdgrp2.Offering_Type__c = ' PureConnect On Premise';
        prdgrp2.Order__c = 12;
        prdgrp2.Quantity__c = 10;
        prdgrp2.Type__c = 'A la Carte';
        insert prdgrp2;
        
        Product_Group__c prdgrp3 = new Product_group__c();
        prdgrp3.Name = 'Guide';
        prdgrp3.Group_Type__c = 'PureSuccess';
        prdgrp3.Active__c = true;
        prdgrp3.Pricing_Model__c = 'test';
        prdgrp3.Product__c = list_ProductsToInsert[0].id;
        prdgrp3.Offering_Type__c = ' PureConnect On Premise';
        prdgrp3.Order__c = 12;
        prdgrp3.Quantity__c = 10;
        prdgrp3.Type__c = 'A la Carte';
        insert prdgrp3;
        
        Product_group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Drive';
        prdgrp1.Group_Type__c = 'Favorite';
        prdgrp1.User__c = UserInfo.getUserId();
        prdgrp1.Pricing_Model__c ='test';
        prdgrp1.Active__c = true;
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureConnect On Premise';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
       prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        Product_group__c prdgrp4 = new Product_group__c();
        prdgrp4.Name = 'Drive';
        prdgrp4.Group_Type__c = 'Favorite';
        prdgrp4.User__c = UserInfo.getUserId();
        prdgrp4.Pricing_Model__c ='test';
        prdgrp4.Active__c = true;
        prdgrp4.Product__c = list_ProductsToInsert[1].id;
        prdgrp4.Offering_Type__c = 'PureConnect On Premise';
        prdgrp4.Order__c = 12;
        prdgrp4.Quantity__c = 10;
        prdgrp4.Type__c = 'A la Carte';
        insert prdgrp4;
                
        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp1.id;
        prdgrpItm.Product_Type__c = 'Lab';
        prdgrpItm.Bundle__c = prdgrp1.id;
        insert prdgrpItm;
        
        Product_Group_Item__c prdgrpItm2 = new Product_Group_Item__c();
        prdgrpItm2.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm2.Product_Group__c = prdgrp4.id;
        prdgrpItm2.Product_Type__c = 'Lab';
        prdgrpItm2.Bundle__c = prdgrp4.id;
        insert prdgrpItm2;
        
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='PG1';
            objQP.Total_Discount__c = 230;
            objQP.Ext_List__c = 100;
            objQP.List_Price_1__c = 2;
            objQP.List_Price_2__c = 2;
            objQP.List_Price__c = 2;
            objQP.Partner_Discount_1__c =1;
            objQP.Partner_Discount_2__c =1;
            objQP.Partner_Price__c =1;
            objQP.Partner_Price_1__c =1;
            objQP.Partner_Price_2__c =1;
            objQP.Ext_Net_Price__c = 20;
            objQP.APN_Number__c = 'CS-012-NV-RBAF';
            objQP.Unit_of_Measure__c = 'seat';
            objQP.or_Amount__c = 'Amt';
            objQP.Adjustment__c = 12;
            objQP.Quantity__c = 10;
            //objQP.Product_Description__c = 'Campaign';
            objQP.Bundle__c = prdgrp.id;
            objQP.Partner_Price__c = 200;
            objQP.Net_Unit_Price__c = 1000;
            objQP.Adjustment__c = 12;
            objQP.List_Price__c = 12;
            objQP.Third_Party__c = 'TRUE';
            //added on 21Aug'18
            //objQP.Bundle_Line__c= qpRec.id;
            
        }
        
        
        list_NewQuoteProds[0].BigMachines__Product__c = list_ProductsToInsert[0].id;
        
        list_NewQuoteProds[1].or_Amount__c='Amt';
        list_NewQuoteProds[1].BigMachines__Product__c = list_ProductsToInsert[1].Id;
        
        update list_NewQuoteProds;
        
        
        
        
        
        Quote_Proposal_Group__c objQProposalGroup = new Quote_Proposal_Group__c( Quote__c = objQuote.id,
                                                                                Description__c = 'Test',
                                                                                Discount__c = 2.5,
                                                                                Group_Number__c = 'PG1',
                                                                                Goal_Seek__c = 1 ,
                                                                                Name__c = 'Test Proposal Group'
                                                                               );
        insert objQProposalGroup;
        
        return objQuote;
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    
    @isTest
    static void Other8aMethod1(){
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        List<Account> accounts = TestUtil.createAccounts(1, false);
        accounts[0].Country__c = objCountry.id;
        insert accounts;
        
        List<Account> accounts2 = TestUtil.createAccounts(1, false);
        accounts2[0].Country__c = objCountry.id;
        accounts2[0].Name='Test Account';
        insert accounts2;
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';      
        insert opportunities;
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'PureBridge';
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';            
        objTestProd1.Type__c = 'Migration Credit';
        objTestProd1.Product_Type__c = 'Year 2';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'test1';
        objTestProd1.type__c = 'Product';
        objTestProd1.Third_Party__c='TRUE';
        objTestProd1.Genesys_Care_Quote__c=true;
        objTestProd1.Pricing_Model__c='Concurrent';
        list_ProductsToInsert.add(objTestProd1);

        Product2 objTestProd = new Product2();
        objTestProd.Name = 'PureBridge';            
        objTestProd.Type__c = 'Migration Credit';
        objTestProd.Product_Type__c = 'Year 1';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Description = 'test 1';
        objTestProd.OfferingType__c = 'PureSuccess';
        objTestProd.APN_Number__c = 'Tokens1';
        objTestProd.zqu__SKU__c = 'test12';
        objTestProd.type__c = 'GU';
        objTestProd.Third_Party__c='TRUE';
        objTestProd.Genesys_Care_Quote__c=true;
        objTestProd.Pricing_Model__c='Concurrent';
        list_ProductsToInsert.add(objTestProd);
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Name = 'Test Prod1';            
        objTestProd2.Type__c = 'Token';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Description = 'test 1';
        objTestProd2.OfferingType__c = 'PureSuccess';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.zqu__SKU__c = 'test13';
        objTestProd2.type__c = 'PS';
        objTestProd2.Third_Party__c='TRUE';
        objTestProd2.Pricing_Model__c='Concurrent';
        list_ProductsToInsert.add(objTestProd2);
        
        insert list_ProductsToInsert;
        
        BigMachines__Quote__c objQuote1 = new BigMachines__Quote__c();
        objQuote1.Name = 'Test';
        objQuote1.Highest_Discount__c = 2;
        objQuote1.Total_Contract_Value_1__c = 2;
        objQuote1.Annual_Contract_Value_2__c = 2;
        objQuote1.PureSuccess_Offer_Subscription_Amount__c = 2;
        objQuote1.Annual_Contract_Value_1__c = 2;
        objQuote1.A_La_Carte_PureSuccess_Services_Amount__c = 2;
        objQuote1.One_Time_Charges_1__c = 2;
        objQuote1.Treat_SO_as_PO__c = true;
        objQuote1.BEP_Third_Party_Genesys_Care__c = 2;
        objQuote1.Total_Contract_Value_1__c = 2;
        objQuote1.Annual_Contract_Value_2__c = 2;
        objQuote1.Amount_Due_At_Anniversary__c = 2;
        objQuote1.Cloud_Total__c = 2;
        objQuote1.Sold_To_Name__c=accounts[0].id;
        objQuote1.Lever__c='Lever 1;Lever 2;Lever 3';
        objQuote1.BigMachines__Status__c = 'Simulated Quote';
        objQuote1.Pricing_Model__c='Concurrent';
        objQuote1.No_Of_Months__c=10;
        objQuote1.Show_Why_Genesys__c=true;
        insert objQuote1;
        
        Subscription__c objSub = new Subscription__c(Account__c = accounts[0].id);
        objSub.Subscription_Start_Date__c = System.today();
        objSub.Subscription_End_Date__c = System.today().addMonths(6);
        objSub.Quote__c = objQuote1.id;
        insert objSub;
        
        Subscription_Product__c subProd = new Subscription_Product__c();
        subProd.Subscription__c = objSub.Id;
        subProd.Hide_Record__c = true;
        subProd.Product__c = objTestProd1.Id;
        subProd.List_Price__c = 2;
        subProd.Is_Overage__c = false;
        insert subProd;
        
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.BigMachines__Opportunity__c = opportunities.Id;
        objQuote.Sold_To_Name__c=accounts[0].id;
        objQuote.Amendment_For__c = objSub.id;
        objQuote.PureSuccess__c = 'Guide';
        objQuote.Quote_Created_Date__c = System.today();
        objQuote.PureSuccess_Offer_Subscription_Amount__c = 2;
        objQuote.A_La_Carte_PureSuccess_Services_Amount__c = 2;
        objQuote.One_Time_Charges_1__c = 2;
        objQuote.BEP_Third_Party_Genesys_Care__c = 2;
        objQuote.Total_Contract_Value_1__c = 2;
        objQuote.Annual_Contract_Value_1__c = 2;
        objQuote.Annual_Contract_Value_2__c = 2;
        objQuote.Amount_Due_At_Anniversary__c = 2;
        objQuote.Multi_Year_Quote__c = true;
        objQuote.Cloud_Total__c = 2;
        objQuote.Highest_Discount__c = 2;
        objQuote.BigMachines__Status__c = 'Quote In Progress';
        objQuote.BigMachines__Is_Primary__c = false;
        objQuote.Service_Level__c = 'Business'; 
        objQuote.New_Price_Book__c = 'NG5_NA_USD';
        objQuote.Lever__c='Lever 1;Lever 2;Lever 3';
        objQuote.BigMachines__Status__c = 'Simulated Quote';
        objQuote.Pricing_Model__c='Concurrent';
        objQuote.No_Of_Months__c=10;
        objQuote.Show_Why_Genesys__c=true;
        Test.startTest();
        insert objQuote;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'Campaigns';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Tes1t';
        prdgrp1.Group_Type__c = 'A la Carte';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        Product_Group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Tes1t';
        prdgrp2.Group_Type__c = 'Campaigns';
        prdgrp2.Order__c = 12;
        prdgrp2.Quantity__c = 10;
        prdgrp2.Type__c = 'A la Carte';
        insert prdgrp2;
        
        BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();         
        qp.BigMachines__Quote__c = objQuote.id;
        qp.BigMachines__Quantity__c = 10;
        qp.BigMachines__Sales_Price__c = 500;
        qp.Ext_Net_Price_1__c = 1;
        qp.Ext_Net_Price_2__c = 1;
        qp.Net_Unit_Price_1__c = 1;
        qp.Net_Unit_Price_2__c = 1;
        qp.BigMachines__Product__c = list_ProductsToInsert[0].id;
        qp.Bundle__c = prdgrp.id;
        insert qp;
        
        BigMachines__Quote_Product__c qp1 = new BigMachines__Quote_Product__c();         
        qp1.BigMachines__Quote__c = objQuote.id;
        qp1.BigMachines__Quantity__c = 10;
        qp1.BigMachines__Sales_Price__c = 500;
        qp1.Ext_Net_Price_1__c = 1;
        qp1.Ext_Net_Price_2__c = 1;
        qp1.Net_Unit_Price_1__c = 1;
        qp1.Net_Unit_Price_2__c = 1;
        qp1.BigMachines__Product__c = list_ProductsToInsert[1].id;
        //qp1.Bundle_Line__c = qp.id;
        qp1.Bundle__c = prdgrp1.id;
        insert qp1;
        BigMachines__Quote_Product__c qp2 = new BigMachines__Quote_Product__c();         
        qp2.BigMachines__Quote__c = objQuote.id;
        qp2.BigMachines__Quantity__c = 10;
        qp2.BigMachines__Sales_Price__c = 500;
        qp2.Ext_Net_Price_1__c = 1;
        qp2.Ext_Net_Price_2__c = 1;
        qp2.Net_Unit_Price_1__c = 1;
        qp2.Net_Unit_Price_2__c = 1;
        qp2.BigMachines__Product__c = list_ProductsToInsert[2].id;
        //qp2.Bundle_Line__c = qp.id;
        qp2.Bundle__c = prdgrp2.id;
        insert qp2;
        qp.Bundle_Line__c = qp1.id;
        update qp;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteSubscription')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        Test.stopTest();
        CreateQuoteSubscriptionController objCreateQuoteSubCont = new CreateQuoteSubscriptionController();
        
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        //Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
       // objCreateQuoteSubCont.quote.BigMachines__Status__c = 'Quote Approved';
        //objCreateQuoteSubCont.quote.Approval_Submission_Date__c  = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(5);
        objCreateQuoteSubCont.createCurrentPageList();
        objCreateQuoteSubCont.deleteQuoteProducts();
        objCreateQuoteSubCont.doCalculations();
        CreateQuoteSubscriptionController.getPureBridgeRampPeriod(system.Date.today().addDays(185));
        objCreateQuoteSubCont.idSoldToAccount=accounts2[0].id;
        objCreateQuoteSubCont.changeSoldTo();
        objCreateQuoteSubCont.testCoverageMethod();
        /*objCreateQuoteSubCont.historyWrapper wrap= new objCreateQuoteSubCont.historyWrapper('test');
        wrap.stepName='Test Name';
        wrap.statusClass='Test Status';
        wrap.actualApprover=userinfo.getUserId();*/
        //objCreateQuoteSubCont.list_QuoteProductRecords.clear();
        //objCreateQuoteSubCont.bypassApprovalsBtnHandler();
        
    }
        
}