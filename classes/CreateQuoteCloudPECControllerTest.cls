/************************************************************************************
Purpose : Unit test class for CreateQuoteCloudPECController
Written By : Ranjith Punneli
Test Classes : N/A
*************************************************************************************/
@isTest(seealldata=true)
private class CreateQuoteCloudPECControllerTest {
    
    static Subscription__c objNewSubscription = new Subscription__c();
    static List<BigMachines__Quote_Product__c> list_NewQuoteProds;
    
    @isTest   
    static void intialTest() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();  
        objCreateQuoteCloudCont.saveBeforeReload(); 
        
        objCreateQuoteCloudCont.showHistoryAndAttachments();
        
        objCreateQuoteCloudCont.showProposalOptions();
        objCreateQuoteCloudCont.changePricingModel();
        objCreateQuoteCloudCont.changeBillingPeriod();
        objCreateQuoteCloudCont.changeSoldTo();
        objCreateQuoteCloudCont.cloneBtnHandler();
        objCreateQuoteCloudCont.reviseMajorBtnHandler();
        objCreateQuoteCloudCont.reviseMinorBtnHandler();
        System.currentPageReference().getParameters().put('clone', '1');
        objCreateQuoteCloudCont.cloneQuoteOnLoad();       
    }
    
    @isTest
    static void otherTests() {
    
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();  
               
        //Pagination
        objCreateQuoteCloudCont.first();
        objCreateQuoteCloudCont.last();
        objCreateQuoteCloudCont.next();
        objCreateQuoteCloudCont.previous();
        objCreateQuoteCloudCont.getPageNumStr();
        
        //Select Columns
        objCreateQuoteCloudCont.selectColumnsHandler();
        objCreateQuoteCloudCont.saveColumnsHandler();
        objCreateQuoteCloudCont.cancelColumnsHandler();
    
        objQuote.BigMachines__Status__c='Quote Approval Pending';
        update objQuote;
        objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        objCreateQuoteCloudCont.saveBeforeReload(); 
        for(BigMachines__Quote_Product__c objQP : [SELECT Id, List_Price__c , Disc__c, Group_Number__c
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id]) {
            system.debug(objQP.Group_Number__c );
            system.debug(objQP.Group_Number__c );
            system.debug(objQP.List_Price__c );
        }
        //proposal group coverage
        objCreateQuoteCloudCont.editofProposalGroup();
        objCreateQuoteCloudCont.saveProposalGroup();            
        objCreateQuoteCloudCont.strPGIndex='0';
        objCreateQuoteCloudCont.goalSeekForPG();
        objCreateQuoteCloudCont.goalSeekResetForPG();  
        objCreateQuoteCloudCont.cancelEditofProposalGroup();          
        objCreateQuoteCloudCont.removeProposalGroup();
    
        objCreateQuoteCloudCont.finalizeQuote();
        objCreateQuoteCloudCont.convertToRealQuoteBtnHandler();
        objCreateQuoteCloudCont.convertToRealQuote();
        objCreateQuoteCloudCont.synchAndGoToDQ();
        objCreateQuoteCloudCont.showReviseVisibility();
        objCreateQuoteCloudCont.hideReviseVisibility();
        Test.startTest();
        objCreateQuoteCloudCont.quote.Grid_Group_By__c = 'Sub Categories';
        objCreateQuoteCloudCont.createCurrentPageList();
        objCreateQuoteCloudCont.quote.Grid_Group_By__c = 'Recurring/Non-Recurring';
        objCreateQuoteCloudCont.createCurrentPageList();
        objCreateQuoteCloudCont.quote.Grid_Group_By__c = 'Bundles/Products';
        objCreateQuoteCloudCont.createCurrentPageList();
        objCreateQuoteCloudCont.quote.Grid_Group_By__c = 'Proposal Groups';
        objCreateQuoteCloudCont.createCurrentPageList();
        objCreateQuoteCloudCont.quote.Grid_Group_By__c = 'Nothing';        
        objCreateQuoteCloudCont.createCurrentPageList();
        
        System.currentPageReference().getParameters().put('tab', 'DAPDetails'); 
        objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        
        System.currentPageReference().getParameters().put('tab', 'SpecialOffers');
        objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        
        System.currentPageReference().getParameters().put('tab', 'QuoteApprovals');
        System.currentPageReference().getParameters().put('mode', 'noAction');
        objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        objCreateQuoteCloudCont.submitForApprovalBtnHandler();
        objCreateQuoteCloudCont.bypassApprovalsBtnHandler();                      
        
        System.currentPageReference().getParameters().put('tab', 'OrderSubmission');
        objCreateQuoteCloudCont = new CreateQuoteCloudPECController(); 
        Test.stopTest();     
    }
    
    @isTest
    static void otherTest2(){
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();  
        
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                          = new Product_Manager_Approval_Group__c(name='Test',
                                                                                Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        Product2 objQtProd = [SELECT id FROM Product2 LIMIT 1];
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
        
        Quote_Approval__c objQuoteApproval = new Quote_Approval__c();
        objQuoteApproval.Actual_Approver__c = UserInfo.getUserId();
        objQuoteApproval.Status__c = 'In Progress';
        objQuoteApproval.Quote_Approval_Step_Details__c = objQuoteApprovalStepDetail.id;
        objQuoteApproval.Quote_Approval_Date__c = System.today();
        objQuoteApproval.Step__c = 1;
        objQuoteApproval.BigMachines_Quote__c = objQuote.id;
        objQuoteApproval.Submitted_Date__c = System.today();
        insert objQuoteApproval;
        
        objCreateQuoteCloudCont.quote.Revise_Minor__c = true;
        objCreateQuoteCloudCont.quote.Expiration_Date__c = System.today().addDays(100);
        objCreateQuoteCloudCont.fetchApprovals();
        objCreateQuoteCloudCont.quote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_REJECTED;
        objCreateQuoteCloudCont.fetchApprovals();
        objCreateQuoteCloudCont.quote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_REVISION_PENDING;
        objCreateQuoteCloudCont.fetchApprovals();

        //objCreateQuoteCloudCont.fetchUpfrontApprovals();
        objCreateQuoteCloudCont.checkUncheckAll();
        
        objCreateQuoteCloudCont.deleteQuoteProducts();
        objCreateQuoteCloudCont.strToDelete = 'yes';
        objCreateQuoteCloudCont.quoteProductIdToBeDeleted = [SELECT Id FROM BigMachines__Quote_Product__c 
                                                             WHERE BigMachines__Quote__c =: objQuote.Id LIMIT 1].id ;
        objCreateQuoteCloudCont.deleteQuoteProduct();
        objCreateQuoteCloudCont.changeOpportunity();
        objCreateQuoteCloudCont.adjustmentResetBtnHandler();
        
        objCreateQuoteCloudCont.map_GroupHeaderToQuoteProdWrapper.values()[0][0].selected = true ;
        objCreateQuoteCloudCont.deleteQuoteProducts();
        
    }
    
    @isTest
    static void otherTest3(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.BigMachines__Is_Primary__c = true;
        objQuote.Grid_Group_By__c = 'Bundles/Products';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();  
        
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                          = new Product_Manager_Approval_Group__c(name='Test',
                                                                                Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        Product2 objQtProd = [SELECT id FROM Product2 LIMIT 1];
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
        
        objCreateQuoteCloudCont.fetchApprovals();
        objCreateQuoteCloudCont.cloneQuote(true);
        
        BigMachines__Quote_Product__c objMassUpdateInput = new BigMachines__Quote_Product__c(Disc__c = 2, or_Amount__c = 'test' , Quantity__c  = 1);
        objCreateQuoteCloudCont.objMassUpdateInput = objMassUpdateInput;
        objCreateQuoteCloudCont.massUpdateBtnHandler();
        
        objMassUpdateInput = new BigMachines__Quote_Product__c(Disc__c = 2, or_Amount__c = '');
        objCreateQuoteCloudCont.objMassUpdateInput = objMassUpdateInput;
        objCreateQuoteCloudCont.list_QuoteProducts[0].selected = true;
        objCreateQuoteCloudCont.list_QuoteProducts[0].record.BigMachines__Product__r.Discountable__c = true;
        objCreateQuoteCloudCont.massUpdateBtnHandler();

        objMassUpdateInput.Disc__c = null;
        objMassUpdateInput.Quantity__c = null;
        objCreateQuoteCloudCont.massUpdateBtnHandler();

        objQuote.Product_Tier__c = 'Preferred';
        update objQuote;
        objCreateQuoteCloudCont.changeProductTier();
        Order__c objOrder = new Order__c(Name = objQuote.Name , Quote__c = objQuote.id);
        insert objOrder;
        
        objCreateQuoteCloudCont.updateOrders();
        objCreateQuoteCloudCont.blnIsReviseOrder = true; 
        objCreateQuoteCloudCont.saveOrderInfo();
        objCreateQuoteCloudCont.strSelectedTab = 'Order Submission';
        objCreateQuoteCloudCont.reviseOrderBtnHandler();
    }
    
    
    @isTest
    static void otherTest4(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Treat_SO_as_PO__c = true;
        objQuote.Order_PO_Number__c =  'Test PO Num';
        objQuote.Order_Payment_Terms__c = 'Test Term';
        objQuote.BigMachines__Status__c='Quote Approval Pending';
        objQuote.End_User_ID__c = objQuote.Sold_To_Name__c;
        objQuote.Include_Special_Offer_in_Output__c = true;
        objQuote.Special_Offer_Terms__c = 'test';
        objQuote.Contract_Signature_Date__c = Date.today();
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController(); 
        
        Country__c objNewCountry = new Country__c(Country__c='United StatesA', DAP_Region__c='NA', Region__c='NA', RU__c='NA',         
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objNewCountry;
        Account objAcc = new Account(id =  objQuote.End_User_ID__c, screening_checklist_completed__c = true ,  Country__c = objNewCountry.id);
        Util.Bypass_Trigger_Chk = true ;
        update objAcc;
        
        List<BigMachines__Quote_Product__c> list_QuoteProducts = [SELECT Id, Ext_List__c,BigMachines__Product__c, Quantity__c,
                                                                  BigMachines__Product__r.ProductShippable__c, BigMachines__Product__r.Discountable__c,
                                                                  Product_Specific_Discount__c
                                                                  FROM BigMachines__Quote_Product__c
                                                                  WHERE BigMachines__Quote__c = :objQuote.id ];
        decimal count = 0;
        Id shipToAddrId = null;
        for(Account_Order_Address__c objAOA : [SELECT Id, Address_Type__c  FROM Account_Order_Address__c WHERE Quote__c =:objQuote.id]) {
            if(objAOA.Address_Type__c == 'Ship To') {
                shipToAddrId = objAOA.Id;
            }
        }
        
        List<BigMachines__Quote_Product__c> list_objQPs = new List<BigMachines__Quote_Product__c>();
        List<Order_Line_Item_Allocation__c> list_NewOLIAs = new List<Order_Line_Item_Allocation__c>();
        for(BigMachines__Quote_Product__c objQP : list_QuoteProducts){
            objQP.Ext_List__c = 10;
            objQP.List_Price__c = 10;
            objQP.Group_Number__c = 'PG1';
            if(objQP.BigMachines__Product__r.ProductShippable__c == 'Yes') {
                Order_Line_Item_Allocation__c objNewOLIA = new Order_Line_Item_Allocation__c(
                                                                Quote__c=objQuote.Id, Quote_Product__c=objQP.Id,
                                                                Quantity__c= objQP.Quantity__c, Order_Shipping_Location__c=shipToAddrId);
                list_NewOLIAs.add(objNewOLIA);
            }
        }
        insert list_NewOLIAs;
        
        list_QuoteProducts[1].Ext_List__c = 20;
        update list_QuoteProducts;
        
        Product2 objProduct = [SELECT id, Discountable__c FROM Product2 WHERE id = :list_QuoteProducts[1].BigMachines__Product__c];
        objProduct.Discountable__c = true ;
        update objProduct;
        objCreateQuoteCloudCont.list_QuoteProductRecords = list_QuoteProducts;
System.Debug('otherTest4: 1');
        objCreateQuoteCloudCont.submitOrderBtnHandler();
        objCreateQuoteCloudCont.quote.Goal_Seek__c = 15.00;
System.Debug('otherTest4: 2');
        objCreateQuoteCloudCont.goalSeekResetBtnHandler();
System.Debug('otherTest4: 3');
        objCreateQuoteCloudCont.goalSeekBtnHandler();
        objCreateQuoteCloudCont.quote.Goal_Seek__c = null;
        objCreateQuoteCloudCont.goalSeekBtnHandler();

        objCreateQuoteCloudCont.quote.Adjustment__c = 2.5;
System.Debug('otherTest4: 4');
        objCreateQuoteCloudCont.applyAdjustmentBtnHandler();
        objCreateQuoteCloudCont.strPGIndex = 0+'';
System.Debug('otherTest4: 5');
        objCreateQuoteCloudCont.goalSeekForPG();
        objCreateQuoteCloudCont.list_ProposalGroupsBeingEdited = new List<Quote_Proposal_Group__c>();
System.Debug('otherTest4: 6');
        objCreateQuoteCloudCont.addProposalGroup();
System.Debug('otherTest4: 7');
        objCreateQuoteCloudCont.saveProposalGroup();
System.Debug('otherTest4: 8');
        objCreateQuoteCloudCont.getproductTier();
System.Debug('otherTest4: 9');
        objCreateQuoteCloudCont.getInitialSubscrTerms();
    }
    @isTest
    static void otherTest5(){
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        objCreateQuoteCloudCont.list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
        objCreateQuoteCloudCont.finalizeQuote();
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(objQuote.Id);
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
        }    
        update list_NewQuoteProds;
        
        objCreateQuoteCloudCont.intPageSize = 1;
        objCreateQuoteCloudCont.first();
        objCreateQuoteCloudCont.next();
        objCreateQuoteCloudCont.previous();
        objCreateQuoteCloudCont.last();
        objCreateQuoteCloudCont.getHasNext();
        objCreateQuoteCloudCont.getHasPrevious();
        
        
        objCreateQuoteCloudCont.blnHasError = true;
        objCreateQuoteCloudCont.submitForApprovalBtnHandler();
        objCreateQuoteCloudCont.showHistoryAndAttachments();
        objCreateQuoteCloudCont.showProposalOptions();
        objCreateQuoteCloudCont.convertToRealQuoteBtnHandler();
        
        objCreateQuoteCloudCont.blnHasError = false;
        objCreateQuoteCloudCont.quote.Service_Level__c = '';
        objCreateQuoteCloudCont.submitForApprovalBtnHandler();
        
        
        objCreateQuoteCloudCont.list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
        objCreateQuoteCloudCont.submitForApprovalBtnHandler();
        objCreateQuoteCloudCont.finalizeQuote();
        
        objCreateQuoteCloudCont.upfrontApprovals = null;
        objCreateQuoteCloudCont.showQuoteDetails();
        objCreateQuoteCloudCont.showDAPDetails();
        
        objCreateQuoteCloudCont.showOrderSubmission();
        objCreateQuoteCloudCont.showSpecialOffers() ;
        
        objCreateQuoteCloudCont.quote.Pricing_Model__c = 'Concurrent';
        objCreateQuoteCloudCont.getPricingMultiplier('test');
        objCreateQuoteCloudCont.strSelectedTab = 'Quote Approvals';
        objCreateQuoteCloudCont.submitForApprovalBtnHandler();
        
    }
    
    @isTest
    static void otherTest6(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();  
        
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                          = new Product_Manager_Approval_Group__c(name='Test',
                                                                  Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        Product2 objQtProd = [SELECT id FROM Product2 LIMIT 1];
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
        
        objCreateQuoteCloudCont.quote.Revise_Minor__c = true;
        objCreateQuoteCloudCont.quote.Expiration_Date__c = System.today().addDays(100);
        objCreateQuoteCloudCont.fetchApprovals();
        //objCreateQuoteCloudCont.fetchUpfrontApprovals();
        
        objCreateQuoteCloudCont.list_QuoteProductRecords[0].addError('test Error');
        objCreateQuoteCloudCont.saveBeforeReload();
    }
    
     @isTest
    static void otherTest7(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        objCreateQuoteCloudCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteCloudCont.quote.id , Body = Blob.valueOf('test'));
        objCreateQuoteCloudCont.doCalculations();
    }
    
    @isTest
    static void otherTest8(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        objCreateQuoteCloudCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteCloudCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteCloudCont.quote.Approval_Submission_Date__c;
        objCreateQuoteCloudCont.quote.BigMachines__Status__c = 'Quote Approved';
        objCreateQuoteCloudCont.quote.Approval_Submission_Date__c  = objCreateQuoteCloudCont.quote.Expiration_Date__c.addDays(5);
        objCreateQuoteCloudCont.doCalculations();
    }
    
    @isTest
    static void otherTest9(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        objCreateQuoteCloudCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteCloudCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteCloudCont.quote.Approval_Submission_Date__c;
        objCreateQuoteCloudCont.quote.Approval_Submission_Date__c  = objCreateQuoteCloudCont.quote.Expiration_Date__c.addDays(-100);
        objCreateQuoteCloudCont.quote.BigMachines__Status__c ='Quote Approval Pending';
        objCreateQuoteCloudCont.doCalculations();
    }
    
    @isTest
    static void otherTest10(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.Billing_Category__c = 'M2M';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        objCreateQuoteCloudCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteCloudCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteCloudCont.quote.Approval_Submission_Date__c;
        objCreateQuoteCloudCont.quote.BigMachines__Status__c = 'Quote Approved';
        objCreateQuoteCloudCont.quote.Approval_Submission_Date__c = objCreateQuoteCloudCont.quote.Expiration_Date__c.addDays(-5);
        objCreateQuoteCloudCont.quote.addError('test Error');
        objCreateQuoteCloudCont.doCalculations();
    }
    
    @isTest
    static void otherTest11() {
        BigMachines__Quote__c objQuote = prepareData();  
                    
        Test.setCurrentPageReference(new PageReference('Page.OptyQuoteCategory')); 
        System.currentPageReference().getParameters().put('oppId', objQuote.BigMachines__Opportunity__c);  
        OptyQuoteHandler objOptyQuoteHandler = new OptyQuoteHandler();
        objOptyQuoteHandler.selectedSubscrToAmend = objNewSubscription.Id;
        objOptyQuoteHandler.map_Subscriptions = SubscriptionUtil.getSubscriptionInfo(objQuote.BigMachines__Account__c, 'PureCloud');
        objOptyQuoteHandler.strSubscrSubType = Label.Amend_Subscription;
        PageReference newQuotePage = objOptyQuoteHandler.createAmendPureCloudQuote();
        String strAmendQuoteId = newQuotePage.getParameters().get('id'); 
        
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', strAmendQuoteId);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();  
        //objCreateQuoteCloudCont.doCalculations();
    }
    @isTest
    static void otherTest12() {
        BigMachines__Quote__c objQuote = prepareData(); 
        objQuote.Annual_Contract_Value__c = 500;
        objQuote.Price_Escalation__c = '3%';
        objQuote.Initial_Subscription_Term__c='10 Years';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        objCreateQuoteCloudCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteCloudCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteCloudCont.quote.Approval_Submission_Date__c;
        objCreateQuoteCloudCont.quote.BigMachines__Status__c = 'Quote Approved';
        objCreateQuoteCloudCont.quote.Approval_Submission_Date__c = objCreateQuoteCloudCont.quote.Expiration_Date__c.addDays(-5);
        objCreateQuoteCloudCont.quote.addError('test Error');
        objCreateQuoteCloudCont.changeOfMSALinkTypeByUser();
        objQuote.MSA_Link_Type__c = 'Custom';
        objCreateQuoteCloudCont.changeOfMSALinkTypeByUser();
        objCreateQuoteCloudCont.doCalculations();
        
    }
    @isTest
    static void otherTest13() {
        BigMachines__Quote__c objQuote = prepareData(); 
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(objQuote);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
        insert objNewSubscription;
        objQuote.Amendment_For__c = objNewSubscription.id;
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        objCreateQuoteCloudCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteCloudCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteCloudCont.quote.Approval_Submission_Date__c;
        objCreateQuoteCloudCont.quote.Approval_Submission_Date__c = objCreateQuoteCloudCont.quote.Expiration_Date__c.addDays(-5);
        objCreateQuoteCloudCont.quote.addError('test Error');
        objCreateQuoteCloudCont.changeOfMSALinkTypeByUser();
        objQuote.MSA_Link_Type__c = 'Custom';
        objCreateQuoteCloudCont.changeOfMSALinkTypeByUser();
        objCreateQuoteCloudCont.quote.BigMachines__Status__c ='Quote In Progress';
        objCreateQuoteCloudCont.quote.Amendment_For__r.Status__c = 'Active';
        objCreateQuoteCloudCont.doCalculations();
    }
    @isTest
    static void otherDoCalculationsOnRealQuoteWithAmendment() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
       // System.currentPageReference().getParameters().put('id', '');
       System.currentPageReference().getParameters().put('id',  objQuote.Id); 
        Test.startTest();
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        objCreateQuoteCloudCont.quote.BigMachines__Status__c ='Quote In Progress';
        //objCreateQuoteCloudCont.quote.Amendment_For__r.Status__c = 'Active';
        //objCreateQuoteCloudCont.list_QuoteProductRecords = list_NewQuoteProds;
        string query = 'SELECT Id, (Select Id,BigMachines__Product__r.NG5_NA_USD_Price__c';
        for(Schema.FieldSetMember flset:SObjectType.BigMachines__Quote_Product__c.FieldSets.Grid_Fields_Cloud.getFields()){
            if(flset.getFieldPath() != 'Id')
            query += ',' + flset.getFieldPath();
        }
        query += ' from BigMachines__BigMachines_Quote_Products__r) from BigMachines__Quote__c where Id=\''+objQuote.Id+'\'';
        BigMachines__Quote__c tmpQuote = database.query(query);
        System.Debug('tmpQuote.BigMachines__BigMachines_Quote_Products__r--->'+tmpQuote.BigMachines__BigMachines_Quote_Products__r);
        objCreateQuoteCloudCont.list_QuoteProductRecords.addAll(tmpQuote.BigMachines__BigMachines_Quote_Products__r);
        
        objCreateQuoteCloudCont.doCalculations();
        objCreateQuoteCloudCont.quote.Require_Contractual_Discount__c =false;
        objCreateQuoteCloudCont.refreshContractDiscount();
        objCreateQuoteCloudCont.findOverageChargeAPNs();
        objCreateQuoteCloudCont.codeCoverage();
        Test.stopTest();
    }  

    
    private static BigMachines__Quote__c prepareData() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);          
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4);        
        Country__c objNewCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD');    
        insert objNewCountry;
        
        list_NewAccts[0].Country__c = objNewCountry.Id;
        update list_NewAccts[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        update list_NewOpps[0];
        
        //Add quote line items         
        list_NewQuoteProds = TestDataFactoryForQuoteTool.createPECQuoteProducts(list_NewQuotes[0].Id);
 
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
                              
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            //objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='PG1';
        }    
        list_NewQuoteProds[1].or_Amount__c='Amt';
        update list_NewQuoteProds;
        //Please ensure to fill in Category, Sub Category, Product Group, Price Type, Charge Type, Product Sub Family, Type, Unit of Measure and Partner Margin Type for PureCloud products: []
        Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true,
                                       New_Category__c = 'Voice Services', Sub_Category__c = '', Product_Group__c = 'Inbound to IVR', Price_Type__c = 'Fixed Price',
                                       Charge_Type__c = 'M2M', ProductSubFamily__c = 'Inbound Voice', Unit_of_Measure__c = 'Minutes', Partner_Margin_Type__c = 'No Margin',
                                       Partner_Margin_Category__c = 'Software');
        update objProd;
        
        //Create subscription & products        
        List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
        objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
        insert objNewSubscription;
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;
        
        return list_NewQuotes[0];   
    }

    @isTest
    static void testCreateQuoteCloudPEC(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloudPEC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudPECController objCreateQuoteCloudCont = new CreateQuoteCloudPECController();
        objCreateQuoteCloudCont.strNewOrderName = 'TestName';
        CreateQuoteCloudPECController.approvalWrapper objApprovalWrapper = new CreateQuoteCloudPECController.approvalWrapper();
        objApprovalWrapper.stepName = '';
        objApprovalWrapper.styleClass = '';
        objApprovalWrapper.rowType = '';
        objApprovalWrapper.approvalReason = '';
        objApprovalWrapper.functionName = '';
        objApprovalWrapper.actualApprover = '';
        objApprovalWrapper.approverName = '';
        objApprovalWrapper.actualApproverEmailId = '';

        CreateQuoteCloudPECController.historyWrapper objHistoryWrapper = new CreateQuoteCloudPECController.historyWrapper();
        objHistoryWrapper.showAction = true;
        objHistoryWrapper.actionTitle = '';
        objHistoryWrapper.approvalRecord = null;
        objHistoryWrapper.actualApprover = null;        
        objHistoryWrapper.rowType = '';
        objHistoryWrapper.stepName = '';
        objHistoryWrapper.styleClass = '';
        objHistoryWrapper.statusClass = '';
        objHistoryWrapper.showOverallStatus = true;
        objHistoryWrapper.submittedDate = '';
        objHistoryWrapper.approvalRejectDate = '';
        objHistoryWrapper.style = '';
        
        objCreateQuoteCloudCont.totalDiscount = 0.0;
        }
    
}