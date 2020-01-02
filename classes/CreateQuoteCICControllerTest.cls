@isTest(seealldata=true)
private class CreateQuoteCICControllerTest {
   // private static user currentuser = [select id,Bypass_Triggers__c from user where id =: userinfo.getUserId()];
   @isTest
    static void intialTests() { 
     
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
        objCreateQuoteSubCont.QuoteToolTest();
        objCreateQuoteSubCont.convertToRealQuoteBtnHandler();
        objCreateQuoteSubCont.changePricingModel();
        Test.startTest();
        
        objCreateQuoteSubCont.CalculateScore();
        objCreateQuoteSubCont.saveBeforeReload();
        objCreateQuoteSubCont.showHistoryAndAttachments();
        
        objCreateQuoteSubCont.reviseMinorBtnHandler();
        
        
        
        objCreateQuoteSubCont.changeSoldTo();
        objCreateQuoteSubCont.cloneBtnHandler();
        objCreateQuoteSubCont.reviseMajorBtnHandler();
        
        objCreateQuoteSubCont.cloneQuoteOnLoad();
        
        
        //objCreateQuoteSubCont.showProposalOutputOptions();
        
        //objCreateQuoteSubCont.doCalculationAndReturnToOpp();
        
        
        
        Test.stopTest();
      
    }
    
    //for blnHasBundles
    @isTest
    static void intialTests_2() {
     
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        Test.startTest();
        BigMachines__Quote__c objQuote = prepareData2();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
       
        objCreateQuoteSubCont.convertToRealQuoteBtnHandler();
        objCreateQuoteSubCont.changePricingModel();
        
        /*objCreateQuoteSubCont.CalculateScore();
        objCreateQuoteSubCont.saveBeforeReload();
        
        objCreateQuoteSubCont.showHistoryAndAttachments();
        
        objCreateQuoteSubCont.reviseMinorBtnHandler();*/
        
        
        
        objCreateQuoteSubCont.changeSoldTo();
        objCreateQuoteSubCont.cloneBtnHandler();
        objCreateQuoteSubCont.reviseMajorBtnHandler();
        
        objCreateQuoteSubCont.cloneQuoteOnLoad();
        
        //Added on 12/09
        objCreateQuoteSubCont.showApprovalHistory = false;
        objCreateQuoteSubCont.overAllStatus = 'blank';
        objCreateQuoteSubCont.showLastSubmission  = false;
        
        
        
        
        //objCreateQuoteSubCont.doCalculationAndReturnToOpp();
        
        
        
        Test.stopTest();
      
    }
    
    //for blnHasBundles
    /*--mukunth
    @isTest
    static void intialTests_2_5() {
     
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        Test.startTest();
        BigMachines__Quote__c objQuote = prepareData6();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
       
        objCreateQuoteSubCont.convertToRealQuoteBtnHandler();
        objCreateQuoteSubCont.changePricingModel();*///--mukunth
        //==========
        /*objCreateQuoteSubCont.CalculateScore();
        objCreateQuoteSubCont.saveBeforeReload();
        
        objCreateQuoteSubCont.showHistoryAndAttachments();
        
        objCreateQuoteSubCont.reviseMinorBtnHandler();
        //=======
        
        
        objCreateQuoteSubCont.changeSoldTo();
        objCreateQuoteSubCont.cloneBtnHandler();
        objCreateQuoteSubCont.reviseMajorBtnHandler();
        
        objCreateQuoteSubCont.cloneQuoteOnLoad();*/
        
        
        
        
        
        //objCreateQuoteSubCont.doCalculationAndReturnToOpp();
        
        
        
        //Test.stopTest();--mukunth
      
    //}--mukunth
    
    
    
    //for blnHasBundles
    @isTest
    static void intialTests_2_2() {
     
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        
        BigMachines__Quote__c objQuote = prepareData2_2();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
       
        objCreateQuoteSubCont.convertToRealQuoteBtnHandler();
        //objCreateQuoteSubCont.changePricingModel();
        Test.startTest();
        objCreateQuoteSubCont.CalculateScore();
        objCreateQuoteSubCont.saveBeforeReload();
        
        //objCreateQuoteSubCont.showHistoryAndAttachments();
        
        objCreateQuoteSubCont.reviseMinorBtnHandler();
        
        
        
        objCreateQuoteSubCont.changeSoldTo();
        objCreateQuoteSubCont.cloneBtnHandler();
        objCreateQuoteSubCont.reviseMajorBtnHandler();
        
        objCreateQuoteSubCont.cloneQuoteOnLoad();
        
        
        //objCreateQuoteSubCont.showProposalOutputOptions();
        
        
        
        //objCreateQuoteSubCont.doCalculationAndReturnToOpp();
        
        
        
        Test.stopTest();
      
    }
    
    
    
    @isTest
    static void intialTests_2_3() {
     
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        Test.startTest();
        BigMachines__Quote__c objQuote = prepareData2();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
       
        //objCreateQuoteSubCont.convertToRealQuoteBtnHandler();
       // objCreateQuoteSubCont.changePricingModel();
        
        objCreateQuoteSubCont.CalculateScore();
        objCreateQuoteSubCont.saveBeforeReload();
        
        objCreateQuoteSubCont.showHistoryAndAttachments();
        
        objCreateQuoteSubCont.reviseMinorBtnHandler();
        
        
        
        
        /*objCreateQuoteSubCont.changeSoldTo();
        objCreateQuoteSubCont.cloneBtnHandler();
        objCreateQuoteSubCont.reviseMajorBtnHandler();
        
        objCreateQuoteSubCont.cloneQuoteOnLoad();
        
        
        objCreateQuoteSubCont.showProposalOutputOptions();*/
        
        
        
        //objCreateQuoteSubCont.doCalculationAndReturnToOpp();
        
        
        
        Test.stopTest();
      
    }
    
     @isTest
    static void intialTests_2_4() {
     
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        Test.startTest();
        BigMachines__Quote__c objQuote = prepareData2();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
       
        
        objCreateQuoteSubCont.quote.Pricing_Model__c = 'Named User';
        objCreateQuoteSubCont.changePricingModel();
        
        
        
        
        
        Test.stopTest();
      
    }
    
    @isTest
    static void intialTests_3() {
     
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        
        BigMachines__Quote__c objQuote = prepareData3();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
       
        objCreateQuoteSubCont.convertToRealQuoteBtnHandler();
        objCreateQuoteSubCont.changePricingModel();
         objCreateQuoteSubCont.CalculateScore();
        objCreateQuoteSubCont.saveBeforeReload();
        Test.startTest();
        objCreateQuoteSubCont.showHistoryAndAttachments();
        
        objCreateQuoteSubCont.reviseMinorBtnHandler();
        
        
        
        objCreateQuoteSubCont.changeSoldTo();
        objCreateQuoteSubCont.cloneBtnHandler();
        objCreateQuoteSubCont.reviseMajorBtnHandler();
        
        objCreateQuoteSubCont.cloneQuoteOnLoad();
        
        
        objCreateQuoteSubCont.showProposalOutputOptions();
        
        
        
        objCreateQuoteSubCont.doCalculationAndReturnToOpp();
        
        
        
        Test.stopTest();
      
    }
    
    @isTest
    static void intialTests_4() {
     
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        
        BigMachines__Quote__c objQuote = prepareData4();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
       
        objCreateQuoteSubCont.convertToRealQuoteBtnHandler();
        objCreateQuoteSubCont.changePricingModel();
         objCreateQuoteSubCont.CalculateScore();
        objCreateQuoteSubCont.saveBeforeReload();
        Test.startTest();
        objCreateQuoteSubCont.showHistoryAndAttachments();
        
        objCreateQuoteSubCont.reviseMinorBtnHandler();
        
        
        
        objCreateQuoteSubCont.changeSoldTo();
        objCreateQuoteSubCont.cloneBtnHandler();
        objCreateQuoteSubCont.reviseMajorBtnHandler();
        
        objCreateQuoteSubCont.cloneQuoteOnLoad();
        
        
        objCreateQuoteSubCont.showProposalOutputOptions();
        
        
        
        objCreateQuoteSubCont.doCalculationAndReturnToOpp();
        
        
        
        Test.stopTest();
      
    }
    //for DDS
    @isTest
    static void intialTests_4_2() {
     
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        
        
        BigMachines__Quote__c objQuote = prepareData5();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
        Test.startTest();
        
        objCreateQuoteSubCont.CalculateScore();
        objCreateQuoteSubCont.createCurrentPageList();
        objCreateQuoteSubCont.quote.Grid_Group_By__c = 'Taxonomy Solution Category - Taxonomy Solution';
        objCreateQuoteSubCont.createCurrentPageList();
        
        objCreateQuoteSubCont.quote.Pricing_Model__c = 'Concurrent';
        objCreateQuoteSubCont.changePricingModel();
        
        objCreateQuoteSubCont.quote.Pricing_Model__c = 'Branch Office';
        //objCreateQuoteSubCont.changePricingModel();
        
        
        Test.stopTest();
      
    }
    
 @isTest
    static void otherTests() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
        
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
        //CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
        objCreateQuoteSubCont = new CreateQuoteCICController();
        objCreateQuoteSubCont.saveBeforeReload(); 
        for(BigMachines__Quote_Product__c objQP : [SELECT Id, List_Price__c , Disc__c, Group_Number__c
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id]) {
            system.debug(objQP.Group_Number__c );
            system.debug(objQP.Group_Number__c );
            system.debug(objQP.List_Price__c );
        }
        //proposal group coverage
        objCreateQuoteSubCont.editofProposalGroup();
        objCreateQuoteSubCont.list_ProposalGroupsBeingEdited[0].Name__c = 'PG';
        objCreateQuoteSubCont.list_ProposalGroupsBeingEdited[0].Goal_Seek__c = 100.00;
        objCreateQuoteSubCont.list_ProposalGroupsBeingEdited[0].Group_Number__c = 'PG1';
        objCreateQuoteSubCont.saveProposalGroup();            
        objCreateQuoteSubCont.strPGIndex='0';
        objCreateQuoteSubCont.goalSeekForPG();
        objCreateQuoteSubCont.goalSeekResetForPG();  
        objCreateQuoteSubCont.cancelEditofProposalGroup();          
        objCreateQuoteSubCont.removeProposalGroup();
        
            
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
        
        objCreateQuoteSubCont.blnHasError = false;
        System.currentPageReference().getParameters().put('tab', 'GenesysCare'); 
        objCreateQuoteSubCont = new CreateQuoteCICController();
        
        objCreateQuoteSubCont.blnHasError = false;
        System.currentPageReference().getParameters().put('tab', 'DAPDetails'); 
        objCreateQuoteSubCont = new CreateQuoteCICController();
        
        objCreateQuoteSubCont.blnHasError = false;
        System.currentPageReference().getParameters().put('tab', 'SpecialOffers');
        objCreateQuoteSubCont = new CreateQuoteCICController();
        
        objCreateQuoteSubCont.blnHasError = false;
        System.currentPageReference().getParameters().put('tab', 'QuoteApprovals');
        System.currentPageReference().getParameters().put('mode', 'noAction');
        Test.startTest();
        objCreateQuoteSubCont = new CreateQuoteCICController();
        //objCreateQuoteSubCont.submitForApprovalBtnHandler();
        
        //objCreateQuoteSubCont.bypassApprovalsBtnHandler();                      
        
        objCreateQuoteSubCont.blnHasError = false;
        System.currentPageReference().getParameters().put('tab', 'OrderSubmission');
        objCreateQuoteSubCont = new CreateQuoteCICController();   
        Test.stopTest();
        
    
    }
    
    @isTest
    static void otherTest2(){
        
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        Test.startTest();
        
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        
        
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
        
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
        objCreateQuoteSubCont.quote.Revise_Minor__c = true;
        objCreateQuoteSubCont.quote.Expiration_Date__c = System.today().addDays(100);
        
        objCreateQuoteSubCont.checkUncheckAll();
        
        objCreateQuoteSubCont.deleteQuoteProducts();
        objCreateQuoteSubCont.strToDelete = 'yes';
        objCreateQuoteSubCont.quoteProductIdToBeDeleted = [SELECT Id FROM BigMachines__Quote_Product__c 
                                                             WHERE BigMachines__Quote__c =: objQuote.Id LIMIT 1].id ;
        objCreateQuoteSubCont.deleteQuoteProduct();
        objCreateQuoteSubCont.changeOpportunity();
       // objCreateQuoteSubCont.adjustmentResetBtnHandler();
        
        objCreateQuoteSubCont.map_GroupHeaderToQuoteProdWrapper.values()[0][0].selected = true ;
        //objCreateQuoteSubCont.deleteQuoteProducts();
        objCreateQuoteSubCont.showGenesysCare();
        objCreateQuoteSubCont.blnHasError = true;
        objCreateQuoteSubCont.showProposalOptions();
        Test.stopTest();
    }
   
   @isTest
    static void otherTest3(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        Test.startTest();
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.BigMachines__Is_Primary__c = false;
        objQuote.Grid_Group_By__c = 'Bundles/Products';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
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
        
        
        objCreateQuoteSubCont.cloneQuote(true);
        
        BigMachines__Quote_Product__c objMassUpdateInput = new BigMachines__Quote_Product__c(Disc__c = 2, or_Amount__c = 'test' , Quantity__c  = 1);
        objCreateQuoteSubCont.objMassUpdateInput = objMassUpdateInput;
        objCreateQuoteSubCont.massUpdateBtnHandler();
        
        objMassUpdateInput = new BigMachines__Quote_Product__c(Disc__c = 2, or_Amount__c = '');
        objCreateQuoteSubCont.objMassUpdateInput = objMassUpdateInput;
        objCreateQuoteSubCont.list_QuoteProducts[0].selected = true;
        objCreateQuoteSubCont.massUpdateBtnHandler();
        //objQuote.Product_Tier__c = 'Preferred';
        update objQuote;
        
        objCreateQuoteSubCont.updateOrders();
        objCreateQuoteSubCont.saveOrderInfo();
        objCreateQuoteSubCont.reviseOrderBtnHandler();
        Test.stopTest();
    }
    
    @isTest
    static void otherTest4(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        Test.startTest();
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Treat_SO_as_PO__c = true;
        objQuote.Order_PO_Number__c =  'Test PO Num';
        objQuote.Order_Payment_Terms__c = 'Test Term';
        objQuote.BigMachines__Status__c='Quote Approval Pending';
        objQuote.Tax_Rate__c = null;
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
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
        
        List<BigMachines__Quote_Product__c> list_QuoteProducts = [sELECT Id, Ext_List__c,BigMachines__Product__c FROM BigMachines__Quote_Product__c
                                                                  WHERE BigMachines__Quote__c = :objQuote.id ];
        decimal count = 0;
        for(BigMachines__Quote_Product__c objQP : list_QuoteProducts){
            objQP.Ext_List__c = 10;
            objQP.List_Price__c = 10;
            objQP.Group_Number__c = 'PG1';
            
        }
        list_QuoteProducts[1].Ext_List__c = 20;
        update list_QuoteProducts;
        
        
        Product2 objProduct = [SELECT id, Discountable__c FROM Product2 WHERE id = :list_QuoteProducts[1].BigMachines__Product__c];
        objProduct.Discountable__c = true ;
        update objProduct;
     
        
        objCreateQuoteSubCont.quote.Goal_Seek__c = 15.00;
        objCreateQuoteSubCont.quote.Adjustment__c = 2.5;
        objCreateQuoteSubCont.strPGIndex = 0+'';
        objCreateQuoteSubCont.list_ProposalGroups[0] = [SELECT id, Quote__c, Name__c, Description__c, Discount__c, Group_Number__c, Goal_Seek__c
                                                          FROM Quote_Proposal_Group__c WHERE Quote__c = :objQuote.id];
        
        Quote_Proposal_Group__c objQProposalGroup = [SELECT id, Quote__c ,Description__c ,Discount__c,Group_Number__c,Goal_Seek__c,Name__c
                                                    FROM Quote_Proposal_Group__c WHERE Quote__c = :objQuote.id];
        objCreateQuoteSubCont.goalSeekForPG();
        objCreateQuoteSubCont.list_ProposalGroupsBeingEdited = new List<Quote_Proposal_Group__c>();
        objCreateQuoteSubCont.addProposalGroup();
        objCreateQuoteSubCont.saveProposalGroup();
        objCreateQuoteSubCont.populateDefaultOrderAddress();
        Test.stopTest();
    }
    
  /*@isTest
    static void otherTest5(){
        
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        
        BigMachines__Quote__c objQuote = prepareData();
        //objQuote.Editable_List_Price_Approval_Required__c = true;
        //update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController();
        //objCreateQuoteSubCont.list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
        objCreateQuoteSubCont.finalizeQuote();
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(objQuote.Id);
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
        }    
        update list_NewQuoteProds;
        
       // objCreateQuoteSubCont.intPageSize = 1;
        objCreateQuoteSubCont.first();
        objCreateQuoteSubCont.next();
        objCreateQuoteSubCont.previous();
        objCreateQuoteSubCont.last();
        objCreateQuoteSubCont.getHasNext();
        objCreateQuoteSubCont.getHasPrevious();
        
        
        objCreateQuoteSubCont.blnHasError = true;
       // objCreateQuoteSubCont.submitForApprovalBtnHandler();
       Test.startTest();
        objCreateQuoteSubCont.showHistoryAndAttachments();
        objCreateQuoteSubCont.showProposalOptions();
        
        objCreateQuoteSubCont.blnHasError = false;
        objCreateQuoteSubCont.quote.Service_Level__c = '';
        
        
        objCreateQuoteSubCont.showQuoteDetails();
        //objCreateQuoteSubCont.showDAPDetails();
        
        //objCreateQuoteSubCont.showOrderSubmission();
        //objCreateQuoteSubCont.showSpecialOffers() ;
        
        objCreateQuoteSubCont.quote.Pricing_Model__c = 'Concurrent';
      
//objCreateQuoteSubCont.submitForApprovalBtnHandler();
        Test.stopTest();
        
    }*/
    
    @isTest
    static void otherTest5_2(){
        
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        
        BigMachines__Quote__c objQuote = prepareData();
        //objQuote.Editable_List_Price_Approval_Required__c = true;
        //update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController();
        //objCreateQuoteSubCont.list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
        
        objCreateQuoteSubCont.blnHasError = true;
       // objCreateQuoteSubCont.submitForApprovalBtnHandler();
       Test.startTest();
        
        objCreateQuoteSubCont.blnHasError = false;
        objCreateQuoteSubCont.quote.Service_Level__c = '';
        
        objCreateQuoteSubCont.showDAPDetails();
        objCreateQuoteSubCont.showOrderSubmission();
        objCreateQuoteSubCont.showSpecialOffers() ;
        
        objCreateQuoteSubCont.quote.Pricing_Model__c = 'Concurrent';
      
        objCreateQuoteSubCont.submitForApprovalBtnHandler();
        Test.stopTest();
        
    }
    
    @isTest
    static void otherTest6(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        Test.startTest();
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController();  
        
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
        
        objCreateQuoteSubCont.quote.Revise_Minor__c = true;
        objCreateQuoteSubCont.quote.Expiration_Date__c = System.today().addDays(100);
        
        objCreateQuoteSubCont.saveBeforeReload();
        Test.stopTest();
    }
    //=============
    
    @isTest
    static void otherTest7(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        Test.startTest();
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController();
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        objCreateQuoteSubCont.doCalculations();
        Test.stopTest();
    }
    
     @isTest
    static void otherTest8(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        Test.startTest();
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController();
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
        objCreateQuoteSubCont.quote.BigMachines__Status__c = 'Quote Approved';
        objCreateQuoteSubCont.quote.Approval_Submission_Date__c  = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(5);
        objCreateQuoteSubCont.doCalculations();
        Test.stopTest();
    }
    
    @isTest
    static void otherTest9(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        Test.startTest();
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController();
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
        objCreateQuoteSubCont.quote.Approval_Submission_Date__c  = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(-100);
        objCreateQuoteSubCont.quote.BigMachines__Status__c ='Quote Approval Pending';
        objCreateQuoteSubCont.doCalculations();
        Test.stopTest();
    }
    
    @isTest
    static void otherTest10(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        Test.startTest();
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController();
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
        objCreateQuoteSubCont.quote.BigMachines__Status__c = 'Quote Approved';
        objCreateQuoteSubCont.quote.Approval_Submission_Date__c = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(-5);
        objCreateQuoteSubCont.quote.addError('test Error');
        objCreateQuoteSubCont.doCalculations();
        Test.stopTest();
    }
    
     @isTest
    static void otherTest11(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        Test.startTest();
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.Grid_Group_By__c = 'Proposal Groups';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController();    
        
        
        
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
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
        insert objNewSubscription;
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
        CreateQuoteCICController objCreateQuoteSubCont1 = new CreateQuoteCICController();
        objCreateQuoteSubCont1.populateDefaultOrderAddress();
        Test.stopTest();
        
    }
    
    @isTest
    static void otherTest12(){
        
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        Test.startTest();
        
        BigMachines__Quote__c objQuote = prepareData();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.Grid_Group_By__c = 'Recurring/Non-Recurring';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        
        
        
        Opportunity objOpp = new Opportunity(id = objQuote.BigMachines__Opportunity__c, Type = 'Existing Business - Cross Sell');
        update objOpp;
        
        Subscription__c objSub = new Subscription__c(Account__c = objQuote.End_User_ID__c);
        objSub.Subscription_Start_Date__c = System.today();
        objSub.Subscription_End_Date__c = System.today().addMonths(6);
        insert objSub;
        
        objQuote.Offering_Type__c = 'PureEngage Subscription';
        objQuote.Genesys_Care_Default_Pricing_Percentage__c = 10;
        objQuote.Genesys_Care_Rate__c = null;
        objQuote.Duration_Unit__c = '';
        objQuote.Order_Numb_of_Maint_Months__c = null;
        objQuote.Service_Level__c = null;
        objQuote.Keep_the_existing_estate_on_Perpetual__c = false;
        objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
        objQuote.Pass_through__c = true;
        objQuote.Amendment_For__c = objSub.id;
        objQuote.BigMachines__Is_Primary__c = true;
        objQuote.Legal_Contract__c = null;
        update objQuote;
        CreateQuoteCICController objCreateQuoteSubCont1 = new CreateQuoteCICController();
        
        objSub.Subscription_End_Date__c = System.today().addMonths(14);
        update objSub;
        
        
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
        
        Test.stopTest();
        
        
    }
     @isTest
    static void otherTest13(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        Test.startTest();
        
        BigMachines__Quote__c objQuote = prepareData3();
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        objQuote.Grid_Group_By__c = 'Test Group';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
         CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController();
        
        
        Util.Bypass_Trigger_Chk = true;
        
        objQuote.Migration_Credit__c = 0;
        update objQuote;
        CreateQuoteCICController objCreateQuoteSubCont1 = new CreateQuoteCICController();
        
        
        objQuote.Migration_Credit__c = 1000;
        objQuote.Annual_Contract_Value_2__c = 1010;
        update objQuote;
        CreateQuoteCICController objCreateQuoteSubCont2 = new CreateQuoteCICController();
        
        CreateQuoteCICController objCreateQuoteSubCont3 = new CreateQuoteCICController();
        objQuote.Migration_Credit__c = 10000;
        update objQuote;
        
        
        objCreateQuoteSubCont3.submitOrderBtnHandler();
        
        CreateQuoteCICController objCreateQuoteSubCont4 = new CreateQuoteCICController();
        objCreateQuoteSubCont4.objAttachment = new Attachment(Name = 'Test', ParentId = objQuote.id, Body = Blob.valueOf('This is test body'));        
        objCreateQuoteSubCont4.submitOrderBtnHandler();
        
        CreateQuoteCICController objCreateQuoteSubCont5 = new CreateQuoteCICController();
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
        Util.Bypass_Trigger_Chk = false;
        Test.stopTest();
    }
    //==========
    
 @isTest
    static void intialTests14() {
     
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
     
        
        
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
       
        
        
        objCreateQuoteSubCont.goalSeekBtnHandler();
        objCreateQuoteSubCont.goalSeekResetBtnHandler();
        Test.startTest();
        objCreateQuoteSubCont.applyAdjustmentBtnHandler();
        
        objCreateQuoteSubCont.adjustmentResetBtnHandler();
        objCreateQuoteSubCont.cancelBtnHandler();
        objCreateQuoteSubCont.assignDefaultGCRate();
        objCreateQuoteSubCont.goToinitializeCareRate();
        
        
        Test.stopTest();
      
    }
    
    /*@isTest
    static void otherTest15(){
        
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
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
    
        //Unit tests for CreateQuoteCICController methods    
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
        update objQuote;      
        
        //added on 21Aug'18
        BigMachines__Quote_Product__c qpRec=    [SELECT Id,Unit_of_Measure__c, Adjustment__c, Disc__c, or_Amount__c,                   BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id limit 1];  
        
        qpRec.APN_Number__c = 'CS-012-NV-RBAF';
        //update qpRec;
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c,Unit_of_Measure__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c,Total_Discount__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='PG1';
            objQP.Total_Discount__c = 230;
            objQP.Ext_List__c = 111;
            objQP.Ext_Net_Price__c = 20;
            objQP.APN_Number__c = 'CS-012-NV-RBAF';
            objQP.Unit_of_Measure__c = 'seat';
            objQP.or_Amount__c = 'Amt';
            objQP.Adjustment__c = 12;
            
            
            //added on 21Aug'18
            //objQP.Bundle_Line__c= qpRec.id;
            
        }
        System.debug('******************list_NewQuoteProds size***** ' + list_NewQuoteProds.size());
        if(list_NewQuoteProds.size() > 0)
            list_NewQuoteProds[1].Bundle_Line__c= qpRec.id;
        
        
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objQtProd;
        
        
        //Added on 21/08/18
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Bundle';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Shipment_Approval__c ='Required for New Orders Only';
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Flavors_Available__c = 'test';
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        list_ProductsToInsert.add(objTestProd1);
        
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Name = 'Test Prod1';            
        objTestProd2.Type__c = 'Product - Hardware';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Shipment_Approval__c ='Required for New Orders Only';
        objTestProd2.Description = 'test 1';
        objTestProd2.OfferingType__c = 'PureSuccess';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.Shipping_Cost__c = 100;
        objTestProd2.Pricing_Model__c = 'Concurrent';
        objTestProd2.Flavors_Available__c = 'test';
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        list_ProductsToInsert.add(objTestProd2);
               
        insert list_ProductsToInsert;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Partner PureSuccess';
        prdgrp.Group_Type__c = 'PureSuccess';
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
        
        list_NewQuoteProds[0].BigMachines__Product__c = list_ProductsToInsert[0].id;
        
        list_NewQuoteProds[1].or_Amount__c='Amt';
        list_NewQuoteProds[1].BigMachines__Product__c = list_ProductsToInsert[1].Id;
        
        update list_NewQuoteProds;
        
        
        Test.startTest();
        
        
        Quote_Proposal_Group__c objQProposalGroup = new Quote_Proposal_Group__c( Quote__c = objQuote.id,
                                                                                Description__c = 'Test',
                                                                                Discount__c = 2.5,
                                                                                Group_Number__c = 'PG1',
                                                                                Goal_Seek__c = 1 ,
                                                                                Name__c = 'Test Proposal Group'
                                                                               );
        insert objQProposalGroup;
        
     
        
        
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController();
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
        objCreateQuoteSubCont.quote.BigMachines__Status__c = 'Quote Approved';
        objCreateQuoteSubCont.quote.Approval_Submission_Date__c  = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(5);
        objCreateQuoteSubCont.doCalculations();
        Test.stopTest();
    } */
    
    
   /* @isTest
    static void otherTest16(){
        
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        
        BigMachines__Quote__c objQuote = prepareData2();
     
        Test.startTest();
        
        objQuote.Quote_Business_Type__c = 'Test Type';
        objQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        update objQuote;
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id);  
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController();
        objCreateQuoteSubCont.objAttachment = new Attachment(Name = 'testAttachment.txt', ParentId = objCreateQuoteSubCont.quote.id , Body = Blob.valueOf('test'));
        Date dtTempDate = objCreateQuoteSubCont.quote.Approval_Submission_Date__c;
        objCreateQuoteSubCont.quote.BigMachines__Status__c = 'Quote Approved';
        objCreateQuoteSubCont.quote.Approval_Submission_Date__c  = objCreateQuoteSubCont.quote.Expiration_Date__c.addDays(5);
        objCreateQuoteSubCont.doCalculations();
        Test.stopTest();
    }*/
    
    
    
     private static BigMachines__Quote__c prepareData() {
        
        
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
    
    
        Order__c ord_1 = new Order__c();
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.status__c = 'In Progress';
        //ord_1.Opportunity__c = testOpp.id;
        ord_1.Quote__c = list_NewQuotes[0].id;
        insert ord_1;
    
        //Unit tests for CreateQuoteCICController methods    
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
        
        objQuote.Order_PO_Number__c = 'test1';
        objQuote.Order_PO_Date__c = Date.newInstance(2018,12,12);
        objQuote.PO_for_FYM__c = 'Separate PO for FYM';
        objQuote.Order_Special_Instructions__c = 'test1';
        
        objQuote.Order_Payment_Terms__c  = 'Net 30'; 
        objQuote.Order_Ship_Software_Via__c  = 'Courier'; 
        objQuote.Bill_To_Name__c  = list_NewAccts[0].id; 
        objQuote.Ship_To_Information__c  = 'test1'; 
        objQuote.Support_Owner__c  = list_NewAccts[0].id; 
        objQuote.System_Integrator__c  = list_NewAccts[0].id;  
        objQuote.Server_OS__c  = 'AIX 3.2'; 
        objQuote.PBX__c  = 'Alcatel'; 
        objQuote.Database__c  = 'DB2'; 
        objQuote.IVR__c  = 'Alcatel'; 
        objQuote.Add_Language__c  = 'Czech'; 
        objQuote.Sold_To_Address__c = '';
        objQuote.Sold_To_City__c = '';
        objQuote.Sold_To_State__c = '';
        objQuote.Sold_To_Country__c = '';
        objQuote.Sold_To_Zip_Code__c = '';
        
        objQuote.Goal_Seek__c = 23.23;
        objQuote.Adjustment__c = 0.1;
        update objQuote;      
        
        //added on 21Aug'18
        BigMachines__Quote_Product__c qpRec=    [SELECT Id,Unit_of_Measure__c, Adjustment__c, Disc__c, or_Amount__c,                   BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id limit 1];  
        
        qpRec.APN_Number__c = 'CS-012-NV-RBAF';
        qpRec.Group_Number__c = 'PG1';
        update qpRec;
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c,Unit_of_Measure__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c,Total_Discount__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='PG1';
            objQP.Total_Discount__c = 230;
            objQP.Ext_List__c = 100;
            objQP.Ext_Net_Price__c = 20;
            objQP.APN_Number__c = 'CS-012-NV-RBAF';
            objQP.Unit_of_Measure__c = 'seat';
            objQP.or_Amount__c = 'Amt';
            objQP.Adjustment__c = 12;
            objQP.List_Price__c = 12;
            
            
            
            //added on 21Aug'18
            //objQP.Bundle_Line__c= qpRec.id;
            
        }
        System.debug('******************list_NewQuoteProds size***** ' + list_NewQuoteProds.size());
        if(list_NewQuoteProds.size() > 0)
            list_NewQuoteProds[1].Bundle_Line__c= qpRec.id;
        
        
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objQtProd;
        
        //Added on 21/08/18
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Bundle';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Shipment_Approval__c ='Required for New Orders Only';
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Flavors_Available__c = 'test';
        objTestProd1.Building_Block__c = 'Chat';
        list_ProductsToInsert.add(objTestProd1);
        
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Name = 'Test Prod1';            
        objTestProd2.Type__c = 'Product - Hardware';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Shipment_Approval__c ='Required for New Orders Only';
        objTestProd2.Description = 'test 1';
        objTestProd2.OfferingType__c = 'PureSuccess';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.Shipping_Cost__c = 100;
        objTestProd2.Pricing_Model__c = 'Concurrent';
        objTestProd2.Flavors_Available__c = 'test';
        objTestProd1.Building_Block__c = 'Chat';
        list_ProductsToInsert.add(objTestProd2);
               
        insert list_ProductsToInsert;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Partner PureSuccess';
        prdgrp.Group_Type__c = 'PureSuccess';
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
        
        //list_NewQuoteProds[0].BigMachines__Product__c = list_ProductsToInsert[0].id;
        
        list_NewQuoteProds[1].or_Amount__c='Amt';
        list_NewQuoteProds[1].BigMachines__Product__c = list_ProductsToInsert[1].Id;
        
        update list_NewQuoteProds;
        
        //Added End
        
        
        
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
        System.assertEquals(list_NewQuoteProds.size(), 2);  
    
        //Unit tests for CreateQuoteCICController methods    
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
        update qpRec;
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c,Unit_of_Measure__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c,Total_Discount__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        
        System.debug('******************list_NewQuoteProds size***** ' + list_NewQuoteProds.size());
        if(list_NewQuoteProds.size() > 0)
            list_NewQuoteProds[1].Bundle_Line__c= qpRec.id;
        
        
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objQtProd;
        
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
        objTestProd1.Include_in_Agent_Seat_Count__c = true;
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
        objTestProd2.Include_in_Agent_Seat_Count__c = true;
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
    
    
     private static BigMachines__Quote__c prepareData2_2() {
        
        
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
        System.assertEquals(list_NewQuoteProds.size(), 2);  
    
        //Unit tests for CreateQuoteCICController methods    
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
        qpRec.Ext_List__c = 10;
        qpRec.Disc__c=100;
            
        qpRec.Total_Discount__c = 230;
        update qpRec;
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c,Unit_of_Measure__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c,Total_Discount__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        
        System.debug('******************list_NewQuoteProds size***** ' + list_NewQuoteProds.size());
        if(list_NewQuoteProds.size() > 0)
            list_NewQuoteProds[1].Bundle_Line__c= qpRec.id;
        
        
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objQtProd;
        
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
        objTestProd1.Include_in_Agent_Seat_Count__c = true;
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
        objTestProd2.Include_in_Agent_Seat_Count__c = true;
        list_ProductsToInsert.add(objTestProd2);
               
        insert list_ProductsToInsert;
        
        Product2 objTestProd3 = [SELECT Id, Name, Unit_of_Measure__c, Product_Specific_Discount__c FROM Product2
                    WHERE id =: Label.CreateQuoteOnPremise_Shipping_Handling_Product_Id];
                    
        
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
            objQP.Disc__c=100;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='PG1';
            objQP.Total_Discount__c = 230;
            objQP.Ext_List__c = 100;
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
            //added on 21Aug'18
            //objQP.Bundle_Line__c= qpRec.id;
            
        }
        
        
        list_NewQuoteProds[0].BigMachines__Product__c = list_ProductsToInsert[0].id;
        
        list_NewQuoteProds[1].or_Amount__c='Amt';
        list_NewQuoteProds[1].BigMachines__Product__c = objTestProd3.Id;
        
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
    
    
    private static BigMachines__Quote__c prepareData3() {
        
        
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
    
    
        Order__c ord_1 = new Order__c();
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.status__c = 'In Progress';
        //ord_1.Opportunity__c = testOpp.id;
        ord_1.Quote__c = list_NewQuotes[0].id;
        insert ord_1;
    
        //Unit tests for CreateQuoteCICController methods    
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
        
        objQuote.Order_PO_Number__c = 'test1';
        objQuote.Order_PO_Date__c = Date.newInstance(2018,12,12);
        objQuote.PO_for_FYM__c = 'Separate PO for FYM';
        objQuote.Order_Special_Instructions__c = 'test1';
        
        objQuote.Order_Payment_Terms__c  = 'Net 30'; 
        objQuote.Order_Ship_Software_Via__c  = 'Courier'; 
        objQuote.Bill_To_Name__c  = list_NewAccts[0].id; 
        objQuote.Ship_To_Information__c  = 'test1'; 
        objQuote.Support_Owner__c  = list_NewAccts[0].id; 
        objQuote.System_Integrator__c  = list_NewAccts[0].id;  
        objQuote.Server_OS__c  = 'AIX 3.2'; 
        objQuote.PBX__c  = 'Alcatel'; 
        objQuote.Database__c  = 'DB2'; 
        objQuote.IVR__c  = 'Alcatel'; 
        objQuote.Add_Language__c  = 'Czech'; 
        objQuote.Sold_To_Address__c = '';
        objQuote.Sold_To_City__c = '';
        objQuote.Sold_To_State__c = '';
        objQuote.Sold_To_Country__c = '';
        objQuote.Sold_To_Zip_Code__c = '';
        
        objQuote.BigMachines__Is_Primary__c = true;
        
        objQuote.Goal_Seek__c = 23.23;
        objQuote.Adjustment__c = 0.1;
        
        objQuote.BigMachines__Opportunity__c = list_NewOpps[0].id;
        update objQuote;      
        
        List<Account_Order_Address__c> accOrderAddressList = new List<Account_Order_Address__c>();
        Account_Order_Address__c accOrderAdd1 = new Account_Order_Address__c();
        accOrderAdd1.Address_Type__c = 'Bill To';
        accOrderAdd1.Quote__c = objQuote.id;
        accOrderAddressList.add(accOrderAdd1);
        
        Account_Order_Address__c accOrderAdd2 = new Account_Order_Address__c();
        accOrderAdd2.Address_Type__c = 'End User';
        accOrderAdd2.Quote__c = objQuote.id;
        accOrderAddressList.add(accOrderAdd2);
        
        Account_Order_Address__c accOrderAdd3 = new Account_Order_Address__c();
        accOrderAdd3.Address_Type__c = 'Ship To';
        accOrderAdd3.Quote__c = objQuote.id;
        accOrderAddressList.add(accOrderAdd3);
        
        Account_Order_Address__c accOrderAdd4 = new Account_Order_Address__c();
        accOrderAdd4.Address_Type__c = 'Sold To';
        accOrderAdd4.Quote__c = objQuote.id;
        accOrderAddressList.add(accOrderAdd4);
        
        //added on 21Aug'18
        BigMachines__Quote_Product__c qpRec=    [SELECT Id,Unit_of_Measure__c, Adjustment__c, Disc__c, or_Amount__c,                   BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id limit 1];  
        
        qpRec.APN_Number__c = 'CS-012-NV-RBAF';
        qpRec.Group_Number__c = 'PG1';
        qpRec.or_Amount__c='%';
        update qpRec;
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c,Unit_of_Measure__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c,Total_Discount__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='PG1';
            objQP.Total_Discount__c = 230;
            objQP.Ext_List__c = 100;
            objQP.Ext_Net_Price__c = 20;
            objQP.APN_Number__c = 'CS-012-NV-RBAF';
            objQP.Unit_of_Measure__c = 'seat';
            objQP.or_Amount__c = 'Amt';
            objQP.Adjustment__c = 12;
            objQP.List_Price__c = 12;
            
            
            
            //added on 21Aug'18
            //objQP.Bundle_Line__c= qpRec.id;
            
        }
        System.debug('******************list_NewQuoteProds size***** ' + list_NewQuoteProds.size());
        if(list_NewQuoteProds.size() > 0)
            list_NewQuoteProds[1].Bundle_Line__c= qpRec.id;
        
        
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objQtProd;
        
        //Added on 21/08/18
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Bundle';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Shipment_Approval__c ='Required for New Orders Only';
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Flavors_Available__c = 'test';
        objTestProd1.Building_Block__c = 'Chat';
        list_ProductsToInsert.add(objTestProd1);
        
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Name = 'Test Prod1';            
        objTestProd2.Type__c = 'Product - Hardware';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Shipment_Approval__c ='Required for New Orders Only';
        objTestProd2.Description = 'test 1';
        objTestProd2.OfferingType__c = 'PureSuccess';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.Shipping_Cost__c = 100;
        objTestProd2.Pricing_Model__c = 'Concurrent';
        objTestProd2.Flavors_Available__c = 'test';
        objTestProd1.Building_Block__c = 'Chat';
        list_ProductsToInsert.add(objTestProd2);
               
        insert list_ProductsToInsert;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Partner PureSuccess';
        prdgrp.Group_Type__c = 'PureSuccess';
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
        
        //list_NewQuoteProds[0].BigMachines__Product__c = list_ProductsToInsert[0].id;
        
        list_NewQuoteProds[1].or_Amount__c='Amt';
        list_NewQuoteProds[1].BigMachines__Product__c = list_ProductsToInsert[0].Id;
        
        update list_NewQuoteProds;
        
        //Added End
        
        
        
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
    private static BigMachines__Quote__c prepareData4() {
        
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        Country__c objNewCountry = new Country__c(Name='Brazil',Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
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
    
        //Unit tests for CreateQuoteCICController methods    
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
        objQuote.Total_Prepaid_Prof_Services__c = 12;
        objQuote.End_User_ID__c = list_NewAccts[0].id;
        objQuote.Services_Tax_Rate__c = 0.2;
        objQuote.Training_Tax_Rate__c = 0.1;
        objQuote.Tax_Rate__c = 0.1;
        objQuote.Total_Genesys_Care__c = 12;
        objQuote.BigMachines__Is_Primary__c = false;
        update objQuote;      
        
        //added on 21Aug'18
        BigMachines__Quote_Product__c qpRec=    [SELECT Id,Unit_of_Measure__c, Adjustment__c, Disc__c, or_Amount__c,                   BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id limit 1];  
        
        qpRec.APN_Number__c = 'CS-012-NV-RBAF';
        qpRec.Group_Number__c = 'PG1';
        qpRec.Quantity__c = 10;
        qpRec.or_Amount__c='%';
        //qpRec.Product_Description__c = 'Test1';
        
        //qpRec.Group_Type__c = 'Campaigns';
        
        update qpRec;
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c,Unit_of_Measure__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c,Total_Discount__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        
        System.debug('******************list_NewQuoteProds size***** ' + list_NewQuoteProds.size());
        if(list_NewQuoteProds.size() > 0)
            list_NewQuoteProds[1].Bundle_Line__c= qpRec.id;
        
        
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objQtProd;
        
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
        objTestProd1.Include_in_Agent_Seat_Count__c = true;
        objTestProd1.Shipping_Cost__c = 100;
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
        objTestProd2.Include_in_Agent_Seat_Count__c = true;
        objTestProd2.Shipping_Cost__c = 100;
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
            objQP.Third_Party_GC__c = 100;
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
    
    private static BigMachines__Quote__c prepareData5() {
        
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'GEN - Opportunity Record Type' LIMIT 1];
        
        //System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        Country__c objNewCountry = new Country__c(Name='Brazil',Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD');    
        insert objNewCountry;
        
        list_NewAccts[0].Country__c = objNewCountry.Id;
        update list_NewAccts[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        list_NewOpps[0].Cloud_Renewal__c = false;
        list_NewOpps[0].Lines_of_Businesses__c = 'PureConnect';
        list_NewOpps[0].Win_Loss_Status__c = 'Won';
        list_NewOpps[0].Primary_Line_of_Business__c = 'On Premise';
        list_NewOpps[0].RecordTypeId = rt.id;
        update list_NewOpps[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(), 2);  
    
        //Unit tests for CreateQuoteCICController methods    
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
        objQuote.Grid_Group_By__c='Use Cases';
        objQuote.New_Price_Book__c='NG5_NA_USD';
        objQuote.Pricing_Model__c = 'Named User';
        objQuote.Total_Prepaid_Prof_Services__c = 12;
        objQuote.End_User_ID__c = list_NewAccts[0].id;
        objQuote.Services_Tax_Rate__c = 0.2;
        objQuote.Training_Tax_Rate__c = 0.1;
        objQuote.Tax_Rate__c = 0.1;
        objQuote.Total_Genesys_Care__c = 12;
        objQuote.BigMachines__Is_Primary__c = false;
        objQuote.BigMachines__Is_Primary__c = true;
        objQuote.Quote_Business_Type__c = 'Renewal';
        //objQuote.End_User_ID__c = acc.id;
        objQuote.BigMachines__Opportunity__c = list_NewOpps[0].Id;
        update objQuote;      
        
        //added on 21Aug'18
        BigMachines__Quote_Product__c qpRec=    [SELECT Id,Unit_of_Measure__c, Adjustment__c, Disc__c, or_Amount__c,                   BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id limit 1];  
        
        qpRec.APN_Number__c = 'CS-012-NV-RBAF';
        qpRec.Group_Number__c = 'PG1';
        qpRec.Quantity__c = 10;
        qpRec.or_Amount__c='%';
        //qpRec.Product_Description__c = 'Test1';
        
        //qpRec.Group_Type__c = 'Campaigns';
        
        update qpRec;
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c,Unit_of_Measure__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c,Total_Discount__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        
        System.debug('******************list_NewQuoteProds size***** ' + list_NewQuoteProds.size());
        if(list_NewQuoteProds.size() > 0)
            list_NewQuoteProds[1].Bundle_Line__c= qpRec.id;
        
        
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objQtProd;
        
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
        objTestProd1.Include_in_Agent_Seat_Count__c = true;
        objTestProd1.Shipping_Cost__c = 100;
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
        objTestProd2.Include_in_Agent_Seat_Count__c = true;
        objTestProd2.Shipping_Cost__c = 100;
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
            objQP.Ext_Net_Price__c = 20;
            objQP.APN_Number__c = 'CS-012-NV-RBAF';
            objQP.Unit_of_Measure__c = 'Named User';
            objQP.or_Amount__c = 'Amt';
            objQP.Adjustment__c = 12;
            objQP.Quantity__c = 10;
            //objQP.Product_Description__c = 'Campaign';
            objQP.Bundle__c = prdgrp.id;
            objQP.Partner_Price__c = 200;
            objQP.Net_Unit_Price__c = 1000;
            objQP.Adjustment__c = 12;
            objQP.List_Price__c = 12;
            objQP.Third_Party_GC__c = 100;
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
    
    
    
    private static BigMachines__Quote__c prepareData6() {
        
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'GEN - Opportunity Record Type' LIMIT 1];
        
        //System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        Country__c objNewCountry = new Country__c(Name='Brazil',Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD');    
        insert objNewCountry;
        
        list_NewAccts[0].Country__c = objNewCountry.Id;
        update list_NewAccts[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        list_NewOpps[0].Cloud_Renewal__c = false;
        list_NewOpps[0].Lines_of_Businesses__c = 'PureConnect';
        list_NewOpps[0].Win_Loss_Status__c = 'Won';
        list_NewOpps[0].Primary_Line_of_Business__c = 'On Premise';
        list_NewOpps[0].RecordTypeId = rt.id;
        list_NewOpps[0].ForecastStatus__c = '0.Booked';
        update list_NewOpps[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(), 2);  
    
        //Unit tests for CreateQuoteCICController methods    
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
        objQuote.Grid_Group_By__c='Use Cases';
        objQuote.New_Price_Book__c='NG5_NA_USD';
        objQuote.Pricing_Model__c = 'Named User';
        objQuote.Total_Prepaid_Prof_Services__c = 12;
        objQuote.End_User_ID__c = list_NewAccts[0].id;
        objQuote.Services_Tax_Rate__c = 0.2;
        objQuote.Training_Tax_Rate__c = 0.1;
        objQuote.Tax_Rate__c = 0.1;
        objQuote.Total_Genesys_Care__c = 12;
        objQuote.BigMachines__Is_Primary__c = false;
        objQuote.BigMachines__Is_Primary__c = true;
        objQuote.Quote_Business_Type__c = 'Renewal';
        //objQuote.End_User_ID__c = acc.id;
        objQuote.BigMachines__Opportunity__c = list_NewOpps[0].Id;
        update objQuote;      
        
        //added on 21Aug'18
        BigMachines__Quote_Product__c qpRec=    [SELECT Id,Unit_of_Measure__c, Adjustment__c, Disc__c, or_Amount__c,                   BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id limit 1];  
        
        qpRec.APN_Number__c = 'CS-012-NV-RBAF';
        qpRec.Group_Number__c = 'PG1';
        qpRec.Quantity__c = 10;
        qpRec.or_Amount__c='%';
        //qpRec.Product_Description__c = 'Test1';
        
        //qpRec.Group_Type__c = 'Campaigns';
        
        update qpRec;
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c,Unit_of_Measure__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c,Total_Discount__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        
        System.debug('******************list_NewQuoteProds size***** ' + list_NewQuoteProds.size());
        if(list_NewQuoteProds.size() > 0)
            list_NewQuoteProds[1].Bundle_Line__c= qpRec.id;
        
        
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objQtProd;
        
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
        objTestProd1.Include_in_Agent_Seat_Count__c = true;
        objTestProd1.Shipping_Cost__c = 100;
        list_ProductsToInsert.add(objTestProd1);
        
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Name = 'Test Prod1';            
        objTestProd2.Type__c = 'Product';
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
        objTestProd2.Include_in_Agent_Seat_Count__c = true;
        objTestProd2.Shipping_Cost__c = 100;
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
            objQP.Ext_Net_Price__c = 20;
            objQP.APN_Number__c = 'CS-012-NV-RBAF';
            objQP.Unit_of_Measure__c = 'Named User';
            objQP.or_Amount__c = 'Amt';
            objQP.Adjustment__c = 12;
            objQP.Quantity__c = 10;
            //objQP.Product_Description__c = 'Campaign';
            objQP.Bundle__c = prdgrp.id;
            objQP.Partner_Price__c = 200;
            objQP.Net_Unit_Price__c = 1000;
            objQP.Adjustment__c = 12;
            objQP.List_Price__c = 12;
            objQP.Third_Party_GC__c = 100;
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
    @isTest
    static void testresetReducedGCAmount() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
        
        objCreateQuoteSubCont.resetReducedGCAmount();
    }        
    @isTest
    static void testSaveGCGenesysCareRate() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
        
        objCreateQuoteSubCont.quote.Genesys_Care_Rate__c = null;
        objCreateQuoteSubCont.saveGC();
    }
    @isTest
    static void testSaveGCMonths() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 

        objCreateQuoteSubCont.quote.Duration_Unit__c = 'Months';
        objCreateQuoteSubCont.quote.Order_Numb_of_Maint_Months__c = null;
        objCreateQuoteSubCont.saveGC();
    }
    @isTest
    static void testSaveGCDays() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
        

        objCreateQuoteSubCont.quote.Duration_Unit__c = 'Days';
        objCreateQuoteSubCont.quote.Order_Numb_of_Maint_Months__c = null;
        objCreateQuoteSubCont.saveGC();
    }
    @isTest
    static void testSaveGCDecline() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
        

        objCreateQuoteSubCont.quote.Service_Level__c = 'Decline';
        objCreateQuoteSubCont.quote.Order_Numb_of_Maint_Months__c = null;
        objCreateQuoteSubCont.saveGC();
    }    
    //quote.Service_Level__c != 'Decline'
    @isTest
    static void testCheckRequiredFieldsRequirementspOnUMBER() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
        
        objCreateQuoteSubCont.quote.Order_PO_Number__c = null;
        objCreateQuoteSubCont.quote.Treat_SO_as_PO__c = false;
        objCreateQuoteSubCont.checkRequiredFields();
    }
    @isTest
    static void testCheckRequiredFieldsRequirementspOdATE() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 
        
        objCreateQuoteSubCont.quote.Order_PO_Number__c = 'Fake-PO-Number1';
        objCreateQuoteSubCont.quote.Order_PO_Date__c = null;
        objCreateQuoteSubCont.quote.Treat_SO_as_PO__c = false;
        objCreateQuoteSubCont.checkRequiredFields();
    }
    @isTest
    static void testCheckRequiredFieldsRequirementsPoForFym() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 

        objCreateQuoteSubCont.quote.Order_PO_Number__c = 'Fake-PO-Number1';
        objCreateQuoteSubCont.quote.Order_PO_Date__c = Date.today();
        objCreateQuoteSubCont.quote.PO_for_FYM__c = null;
        objCreateQuoteSubCont.quote.Treat_SO_as_PO__c = true;
        objCreateQuoteSubCont.checkRequiredFields();
    }
    @isTest
    static void testCheckRequiredFieldsRequirementsIsPartner() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 

        objCreateQuoteSubCont.quote.Order_PO_Number__c = 'Fake-PO-Number1';
        objCreateQuoteSubCont.quote.Order_PO_Date__c = Date.today();
        objCreateQuoteSubCont.quote.PO_for_FYM__c = null;
        objCreateQuoteSubCont.quote.Treat_SO_as_PO__c = true;
        objCreateQuoteSubCont.blnIsPartner = true;
        objCreateQuoteSubCont.checkRequiredFields();
    }

    @isTest
    static void testGetPricingMultiplierBranchOffice() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        Test.startTest();
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 

        objCreateQuoteSubCont.getPricingMultiplier('Branch Office');
        objCreateQuoteSubCont.oldPricingModel = 'Branch Office';

        Util.Bypass_Trigger_Chk = true;
        objCreateQuoteSubCont.changePricingModel();
        test.stopTest();
    }

    
    @isTest
    static void testFinalizeQuote1() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 

        objCreateQuoteSubCont.quote.Order_Payment_Terms__c = null;
        objCreateQuoteSubCont.finalizeQuote();
    }

    @isTest
    static void testFinalizeQuote2() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 

        objCreateQuoteSubCont.quote.Order_Payment_Terms__c = '30';
        objCreateQuoteSubCont.quote.PS_GU_Carveout__c = true;
        objCreateQuoteSubCont.finalizeQuote();
    }

    @isTest
    static void testFinalizeQuote3() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 

        objCreateQuoteSubCont.quote.Order_Payment_Terms__c = '30';
        objCreateQuoteSubCont.quote.PS_GU_Carveout__c = false;
        objCreateQuoteSubCont.quote.Free_GU__c = true;
        objCreateQuoteSubCont.finalizeQuote();
    }

    @isTest
    static void testFinalizeQuote4() {
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 

        objCreateQuoteSubCont.quote.Order_Payment_Terms__c = '30';
        objCreateQuoteSubCont.quote.PS_GU_Carveout__c = false;
        objCreateQuoteSubCont.quote.Free_GU__c = false;
        objCreateQuoteSubCont.quote.Free_Events__c = true;
        objCreateQuoteSubCont.finalizeQuote();
    }
    
    @isTest
    static void testChangePricingModel() {
        
        BigMachines__Quote__c objQuote = prepareData();
        Test.setCurrentPageReference(new PageReference('Page.CreateQuoteCIC')); 
        System.currentPageReference().getParameters().put('id', objQuote.Id); 
        System.currentPageReference().getParameters().put('clone', '1');
        Test.startTest();
        CreateQuoteCICController objCreateQuoteSubCont = new CreateQuoteCICController(); 

        Util.Bypass_Trigger_Chk = true;
        objCreateQuoteSubCont.oldPricingModel = 'Branch Office';
        objCreateQuoteSubCont.changePricingModel();
        Test.stopTest();
    }

}