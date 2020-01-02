@isTest(seealldata=true)
public class CreateQuoteCloudControllerTest {
    @isTest
    static void intialTests() {
        
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        
        objCreateQuoteCloudCont.saveBeforeReload(); 
        
        objCreateQuoteCloudCont.showHistoryAndAttachments();
        objCreateQuoteCloudCont.showProposalOptions();
        objCreateQuoteCloudCont.changePricingModel();
        //objCreateQuoteCloudCont.changeProductTier();
        //objCreateQuoteCloudCont.changeOpportunity();
        objCreateQuoteCloudCont.changeSoldTo();
        objCreateQuoteCloudCont.cloneBtnHandler();
        objCreateQuoteCloudCont.reviseMajorBtnHandler();
        objCreateQuoteCloudCont.reviseMinorBtnHandler();
        System.currentPageReference().getParameters().put('clone', '1');
        objCreateQuoteCloudCont.cloneQuoteOnLoad();
          objCreateQuoteCloudCont.thisForCodeCoverage();   
    }
    
    @isTest
    static void otherTests() {
    
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        Test.startTest();
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        
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
        objCreateQuoteCloudCont = new CreateQuoteCloudController();
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
        objCreateQuoteCloudCont.list_ProposalGroupsBeingEdited[0].Name__c = 'PG';
        objCreateQuoteCloudCont.list_ProposalGroupsBeingEdited[0].Goal_Seek__c = 100.00;
        objCreateQuoteCloudCont.list_ProposalGroupsBeingEdited[0].Group_Number__c = 'PG1';
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
        objCreateQuoteCloudCont.quote.Grid_Group_By__c = 'Use Cases';        
        objCreateQuoteCloudCont.createCurrentPageList();
        
        System.currentPageReference().getParameters().put('tab', 'DAPDetails'); 
        objCreateQuoteCloudCont = new CreateQuoteCloudController();
        
        System.currentPageReference().getParameters().put('tab', 'SpecialOffers');
        objCreateQuoteCloudCont = new CreateQuoteCloudController();
        
        System.currentPageReference().getParameters().put('tab', 'QuoteApprovals');
        System.currentPageReference().getParameters().put('mode', 'noAction');
        objCreateQuoteCloudCont = new CreateQuoteCloudController();
        //objCreateQuoteCloudCont.submitForApprovalBtnHandler();
        objCreateQuoteCloudCont.bypassApprovalsBtnHandler();                      
        
        System.currentPageReference().getParameters().put('tab', 'OrderSubmission');
        objCreateQuoteCloudCont = new CreateQuoteCloudController();   
        Test.stopTest();         
      /*  //Quote address
        List<Account_Order_Address__c> list_NewAOAs = TestDataFactoryForQuoteTool.createAOAs(objQuote.Id);
        System.assertEquals(list_NewAOAs.size(), 4);
        
        list_NewAOAs[2].Shipping_Method_Name__c = 'PICK UP';
        update list_NewAOAs[2];
        
        Order_Line_Item_Allocation__c objNewOLIA = new Order_Line_Item_Allocation__c(Order_Shipping_Location__c=list_NewAOAs[2].Id, 
                                                            Quote__c=objQuote.Id, Quantity__c=100,
                                                            Quote_Product__c=list_NewQuoteProds[0].Id);
        insert objNewOLIA;
        
        //Address
        Address__c objNewAddr = new Address__c(Account__c=list_NewAccts[0].Id, Address_Line_1__c='test', Address_Line_2__c='test',
                                    Address_Name__c='test', City__c='test', Country__c='test');
        insert objNewAddr;
       */ 
    
    }
    
    // Added by Vijay - July 17 2017 - Start
    @isTest
    static void otherTest2(){
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        
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
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        
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
        objQuote.Contract_Signature_Date__c = system.today();
        objQuote.Treat_SO_as_PO__c = true;
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController(); 
        List<Account_Order_Address__c> list_Addresses = new List<Account_Order_Address__c>();
        list_Addresses.add( new Account_Order_Address__c(Address_Type__c = 'Bill To' , Quote__c = objQuote.Id) ) ; 
        list_Addresses.add( new Account_Order_Address__c(Address_Type__c = 'End User' , Quote__c = objQuote.Id) ) ; 
        list_Addresses.add( new Account_Order_Address__c(Address_Type__c = 'Ship To' , Quote__c = objQuote.Id , Email__c = 'testgen@testgensys.com') ) ; 
        list_Addresses.add( new Account_Order_Address__c(Address_Type__c = 'Sold To' , Quote__c = objQuote.Id) ) ; 
        insert list_Addresses ; 
        objQuote.End_User_ID__c = objQuote.Sold_To_Name__c;
        update objQuote;
        Country__c objNewCountry = new Country__c(Country__c='United Statess', DAP_Region__c='NA', Region__c='NA', RU__c='NA',         
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objNewCountry;
        Account objAcc = new Account(id =  objQuote.End_User_ID__c, screening_checklist_completed__c = true ,  Country__c = objNewCountry.id);
        Util.Bypass_Trigger_Chk = true ;
        update objAcc;
        
        List<BigMachines__Quote_Product__c> list_QuoteProducts = [sELECT Id, List_Price__c,Group_Number__c,Ext_List__c,BigMachines__Product__c FROM BigMachines__Quote_Product__c
                                                                  WHERE BigMachines__Quote__c = :objQuote.id ];
        decimal count = 0;
        for(BigMachines__Quote_Product__c objQP : list_QuoteProducts){
            objQP.Ext_List__c = 10;
            objQP.List_Price__c = 10;
            objQP.Group_Number__c = 'PG1';
            
        }
        list_QuoteProducts[1].Ext_List__c = 20;
        
        update list_QuoteProducts;
        
        
        Product2 objProduct = [SELECT id,New_Category__c,Partner_Margin_Category__c,Unit_of_Measure__c,Sub_Category__c,Product_Group__c,Price_Type__c,Charge_Type__c,ProductSubFamily__c,Type__c, Discountable__c FROM Product2 WHERE id = :list_QuoteProducts[1].BigMachines__Product__c];
        objProduct.New_Category__c = 'Services';
        objProduct.Sub_Category__c = 'Addon';
        objProduct.Product_Group__c = 'Services';
        objProduct.Price_Type__c = 'Cloud';
        objProduct.Charge_Type__c = 'Fixed';
        objProduct.ProductSubFamily__c = 'Services';
        objProduct.Type__c = 'Cloud';
        objProduct.Unit_of_Measure__c = 'Seat';
        objProduct.Partner_Margin_Category__c = 'No Margin';        
        objProduct.Discountable__c = false ;
        update objProduct;
        objCreateQuoteCloudCont.list_QuoteProductRecords = list_QuoteProducts;
        objCreateQuoteCloudCont.submitOrderBtnHandler();
        objCreateQuoteCloudCont.quote.Goal_Seek__c = 15.00;
        objCreateQuoteCloudCont.goalSeekResetBtnHandler();
        objCreateQuoteCloudCont.goalSeekBtnHandler();
        objCreateQuoteCloudCont.quote.Adjustment__c = 2.5;
        objCreateQuoteCloudCont.applyAdjustmentBtnHandler();
        objCreateQuoteCloudCont.strPGIndex = 0+'';
        objCreateQuoteCloudCont.list_ProposalGroups[0] = [SELECT id, Quote__c, Name__c, Description__c, Discount__c, Group_Number__c, Goal_Seek__c
                                                          FROM Quote_Proposal_Group__c WHERE Quote__c = :objQuote.id];
        
        Quote_Proposal_Group__c objQProposalGroup = [SELECT id, Quote__c ,Description__c ,Discount__c,Group_Number__c,Goal_Seek__c,Name__c
                                                    FROM Quote_Proposal_Group__c WHERE Quote__c = :objQuote.id];
        objCreateQuoteCloudCont.goalSeekForPG();
        objCreateQuoteCloudCont.list_ProposalGroupsBeingEdited = new List<Quote_Proposal_Group__c>();
        objCreateQuoteCloudCont.list_ProposalGroups= new List<Quote_Proposal_Group__c>();
        objCreateQuoteCloudCont.strPGIndex = '0';
        objCreateQuoteCloudCont.goalSeekForPG();
        objCreateQuoteCloudCont.addProposalGroup();
         
        objCreateQuoteCloudCont.saveProposalGroup();
        
    }
    

    @isTest
    static void otherTest5(){
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();
        objCreateQuoteCloudCont.list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
        objCreateQuoteCloudCont.finalizeQuote();
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
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
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        
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
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();
        objCreateQuoteCloudCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteCloudCont.quote.id , Body = Blob.valueOf('test'));
        objCreateQuoteCloudCont.doCalculations();
    }
    
     @isTest
    static void otherTest8(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();
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
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();
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
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();
        objCreateQuoteCloudCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteCloudCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteCloudCont.quote.Approval_Submission_Date__c;
        objCreateQuoteCloudCont.quote.BigMachines__Status__c = 'Quote Approved';
        objCreateQuoteCloudCont.quote.Approval_Submission_Date__c = objCreateQuoteCloudCont.quote.Expiration_Date__c.addDays(-5);
        objCreateQuoteCloudCont.quote.addError('test Error');
        objCreateQuoteCloudCont.doCalculations();
    }
    
     @isTest
    static void otherTest11(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.Grid_Group_By__c = 'Proposal Groups';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();
    }
    
     @isTest
    static void otherTest12(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.Grid_Group_By__c = 'Recurring/Non-Recurring';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();
    }
     @isTest
    static void otherTest13(){
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.Grid_Group_By__c = 'Test Group';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();
    }
    // Added by Vijay - July 17 2017 - End
    
   @isTest
    static void changeBillingPeriodTest() {
        
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        
        objCreateQuoteCloudCont.changeBillingPeriod();
        objCreateQuoteCloudCont.checkDealViolations('Convert');
        objCreateQuoteCloudCont.checkDealViolations('Finalize');


        CreateQuoteCloudController.approvalWrapper objApprovalWrapper = new CreateQuoteCloudController.approvalWrapper();
        objApprovalWrapper.actualApprover = 'David';
        objApprovalWrapper.actualApproverEmailId = 'david@test.com';
        objApprovalWrapper.approvalReason = 'test';
        objApprovalWrapper.approverName = 'David';
        objApprovalWrapper.functionName = 'testfunction';
        objApprovalWrapper.rowType = 'two';
        objApprovalWrapper.stepName = 'Level 2';
        objApprovalWrapper.styleClass = 'bold';
        
    }

     @isTest
    static void testchangeBillingPeriodTest() {
        
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        
        objCreateQuoteCloudCont.changeBillingPeriod();
        objCreateQuoteCloudCont.checkDealViolations('Convert');
        objCreateQuoteCloudCont.checkDealViolations('Finalize');
        

        CreateQuoteCloudController.approvalWrapper objApprovalWrapper = new CreateQuoteCloudController.approvalWrapper();
        objApprovalWrapper.actualApprover = 'David';
        objApprovalWrapper.actualApproverEmailId = 'david@test.com';
        objApprovalWrapper.approvalReason = 'test';
        objApprovalWrapper.approverName = 'David';
        objApprovalWrapper.functionName = 'testfunction';
        objApprovalWrapper.rowType = 'two';
        objApprovalWrapper.stepName = 'Level 2';
        objApprovalWrapper.styleClass = 'bold';
        
    }

     @isTest
    static void testgetproductTier() {
        
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        List<SelectOption> list_selectOption = objCreateQuoteCloudCont.getproductTier();
        objCreateQuoteCloudCont.setMSALink();   
    }

    @isTest
    static void testbuildChangeHistoryForAmendSubscr() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        list_NewQuotes[1].Offering_Type__c = 'PureConnect Cloud';
        update list_NewQuotes[1];
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
        //Create subscription & products        
        List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
        insert objNewSubscription;
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;

        List<BigMachines__Quote__c> list_NewQuotes1 = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1); 
        list_NewQuotes1[0].Amendment_For__c = objNewSubscription.Id;
        list_NewQuotes1[0].Order_Type__c = 'Amend Subscription';
        update list_NewQuotes1[0];
        List<BigMachines__Quote_Product__c> list_NewQuoteProds1 = TestDataFactoryForQuoteTool.createQuoteProducts2(list_NewQuotes1[0].Id);
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes1[0].Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        
        objCreateQuoteCloudCont.buildChangeHistoryForAmendSubscr();


    }
     @isTest
    static void otherTestIndirect(){
        BigMachines__Quote__c objQuote = prepareData();
        
        Account objAcc = [SELECT id FROM Account
                            WHERE PartnerType__c includes ('Cloud Reseller')
                            AND Partner_Offering_Type__c includes ('PureConnect Cloud Reseller') 
                            LIMIT 1];
        
        Opportunity objOpp = new Opportunity(id = objQuote.BigMachines__Opportunity__c, Direct_Indirect_Sale__c = 'Indirect',BusinessPartner__c = objAcc.id);
        update objOpp;
        objQuote.Sold_To_Name__c = objAcc.id;
        update objQuote;
        
        Partner_Discount__c objDiscount = new Partner_Discount__c(Account__c = objQuote.Sold_To_Name__c,
                                                                type__c = SubscriptionUtil.OFFERING_TYPE_PCC , 
                                                                Category__c = 'Base Line Discount',
                                                                Discount__c = 10);
        insert objDiscount;
                                                                
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'PureConnect Cloud';
        update objQuote;
        
        Product2 objProd = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 
                                        WHERE Price_Type__c = 'Range' LIMIT 1];
        objProd.Product_Specific_Discount__c = 10;
        update objProd;
                                        
        BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                                                  BigMachines__Quote__c = objQuote.id, BigMachines__Product__c = objProd.Id,
                                                  Name = objProd.Name, Build_Type__c = objProd.Name, APN_Number__c = objProd.APN_Number__c,
                                                  BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000,Disc__c=5,or_Amount__c='%');
        insert  objNewQuoteProduct;
        BigMachines__Quote_Product__c objNewQuoteProduct2 = new BigMachines__Quote_Product__c(
                                                  BigMachines__Quote__c = objQuote.id, BigMachines__Product__c = objProd.Id,
                                                  Name = objProd.Name, Build_Type__c = objProd.Name, APN_Number__c = objProd.APN_Number__c,
                                                  BigMachines__Quantity__c=0, BigMachines__Sales_Price__c=0,Is_Overage__c = true);
        insert  objNewQuoteProduct2;   
                                                                              
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();
        
        objProd.Discountable__c = false;
        update objProd;
        
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        objCreateQuoteCloudCont = new CreateQuoteCloudController();
    }

    @isTest
    static void testgetInitialSubscrTerms(){

         BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        List<SelectOption> list_selectOption = objCreateQuoteCloudCont.getInitialSubscrTerms();
        Set<Id> set_Id = objCreateQuoteCloudCont.findOverageChargeAPNs();

    }

    @isTest
    static void testPartnerOpportunity(){
         Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccountspartner(2);
        System.assertEquals(list_NewAccts.size(), 2);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportuntiesPartner(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes2(list_NewOpps[0].Id, list_NewAccts[0].Id,list_NewAccts[1].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        list_NewQuotes[1].Offering_Type__c = 'PureConnect Cloud';
        update list_NewQuotes[1];
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];

        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts5(list_NewQuotes[0].Id);
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
        List<BigMachines__Quote__c> list_NewQuotes1 = TestDataFactoryForQuoteTool.createPCQuotes2(list_NewOpps[0].Id, list_NewAccts[0].Id,list_NewAccts[1].Id, 1); 
        list_NewQuotes1[0].Order_Type__c = 'Amend Subscription';
        update list_NewQuotes1[0];
         Map<String, Decimal> map_PCCPartnerMargins = new Map<String, Decimal>();

        List<BigMachines__Quote_Product__c> list_NewQuoteProds1 = TestDataFactoryForQuoteTool.createQuoteProducts5(list_NewQuotes1[0].Id);
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes1[0].Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();
        objCreateQuoteCloudCont.doCalculations();
    }


    @isTest
    static void testbuildChangeHistoryForAmendSubscr2() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        list_NewQuotes[1].Offering_Type__c = 'PureConnect Cloud';
        update list_NewQuotes[1];
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
        //Create subscription & products        
        List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = objNewSubscription.Total_Non_Recurring_Fees__c = 0;
        objNewSubscription.Telco_CMRR__c = objNewSubscription.Total_Tokens__c=0;
        insert objNewSubscription;
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;

        List<BigMachines__Quote__c> list_NewQuotes1 = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1); 
        list_NewQuotes1[0].Amendment_For__c = objNewSubscription.Id;
        list_NewQuotes1[0].Order_Type__c = 'Amend Subscription';
        update list_NewQuotes1[0];
        List<BigMachines__Quote_Product__c> list_NewQuoteProds1 = TestDataFactoryForQuoteTool.createQuoteProducts5(list_NewQuotes1[0].Id);
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes1[0].Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        
        objCreateQuoteCloudCont.buildChangeHistoryForAmendSubscr();
        objCreateQuoteCloudCont.doCalculations();


    }

    @isTest
    static void testbuildChangeHistoryForAmendSubscr3() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        list_NewQuotes[1].Offering_Type__c = 'PureConnect Cloud';
        update list_NewQuotes[1];
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts7(list_NewQuotes[0].Id);
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
        //Create subscription & products        
        List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = objNewSubscription.Total_Non_Recurring_Fees__c = 0;
        objNewSubscription.Telco_CMRR__c = objNewSubscription.Total_Tokens__c=0;
        insert objNewSubscription;
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            objNewSubscriptionProd.Quantity__c = 10;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;

        List<BigMachines__Quote__c> list_NewQuotes1 = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1); 
        list_NewQuotes1[0].Amendment_For__c = objNewSubscription.Id;
        list_NewQuotes1[0].Order_Type__c = 'Amend Subscription';
        update list_NewQuotes1[0];
        List<BigMachines__Quote_Product__c> list_NewQuoteProds1 = new List<BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds){

            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c(BigMachines__Quote__c = list_NewQuotes1[0].Id, BigMachines__Product__c = objQtProd.BigMachines__Product__c,
                                                  Name = objQtProd.Name, Build_Type__c = objQtProd.Name, APN_Number__c = objQtProd.APN_Number__c,
                                                  BigMachines__Quantity__c=5, BigMachines__Sales_Price__c=1000, Quantity__c = 5,
                                                  List_Price__c = 10 ) ;
            list_NewQuoteProds1.add(objQP);
        }
        insert list_NewQuoteProds1;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes1[0].Id);  
        CreateQuoteCloudController objCreateQuoteCloudCont = new CreateQuoteCloudController();  
        
        objCreateQuoteCloudCont.buildChangeHistoryForAmendSubscr();
        objCreateQuoteCloudCont.doCalculations();


    }
    
    public static BigMachines__Quote__c prepareData() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
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
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(), 2);  
    
        //Unit tests for CreateQuoteCloudController methods    
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
        objQuote.offering_type__c ='PureConnect Cloud';
        objQuote.CurrencyIsoCode = 'USD';
        objQuote.Annual_Contract_Value__c = 1000;
        objQuote.Subscription_Start_Date__c = system.today();
        update objQuote;      
                 
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='PG1';
        }    
        list_NewQuoteProds[1].or_Amount__c='Amt';
        update list_NewQuoteProds;
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, 
        ProductShippable__c='Yes', 
        New_Category__c = 'Services',
        Sub_Category__c = 'Addon',
        Product_Group__c = 'Services',
        Price_Type__c = 'Cloud',
        Charge_Type__c = 'Fixed',
        ProductSubFamily__c = 'Services',
        Type__c = 'Cloud',
        Unit_of_Measure__c = 'Seat',
        Partner_Margin_Category__c = 'No Margin',
        Include_in_CMMR_Total__c=true );      
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




}