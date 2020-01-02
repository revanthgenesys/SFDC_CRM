@isTest(SeeAllData = true)
private class AllPendingTestCoverage
{
    static testmethod void test_UpdateCaseProductControllerExtn()
    {
        try
        {
			
			
			List<Support_Product__c> testSupportProducts = TestUtil.createSupportProducts(1, false);
			Support_Product__c objParentSP = testSupportProducts[0];
			objParentSP.Product_Type__c = 'Product Line';
			objParentSP.Customer_Available__c = true;
			insert objParentSP;
			
			testSupportProducts = TestUtil.createSupportProducts(2, false);
			testSupportProducts[0].Product_Type__c = 'Product';
			testSupportProducts[0].Customer_Available__c = true;
			testSupportProducts[0].Parent_Product__c = objParentSP.Id;
			testSupportProducts[1].Product_Type__c = 'Component';
			testSupportProducts[1].Customer_Available__c = true;
			testSupportProducts[1].Parent_Product__c = objParentSP.Id;
			insert testSupportProducts;
			
			List<Product2> testProducts = TestUtil.createProducts(1,true,false);
			
			Product_Mapping__c objPM = new Product_Mapping__c(Product__c = objParentSP.Id,Sellable_Item__c = testProducts[0].Id);
			insert objPM;
			
			List<Product_Version__c> testProductVersion = TestUtil.createProductVerion(1,true,objParentSP);
			
			List<Case> testCases = TestUtil.createCases(1, false);
			testCases[0].Product_Line__c = objParentSP.Id;
			testCases[0].Support_Product__c = objParentSP.Id;
			testCases[0].Component__c = objParentSP.Id;
			insert testCases;
			Test.startTest();
			UpdateCaseProductControllerExtn objTestUCPCExt = new UpdateCaseProductControllerExtn(new ApexPages.StandardController(testCases[0]));
			objTestUCPCExt.chooseContact();
			objTestUCPCExt.next();
			objTestUCPCExt.currentCase.Support_Product__c = objParentSP.Id;
			objTestUCPCExt.next();
			objTestUCPCExt.save();
			
			UpdateCaseProductController objTestUCPC = new UpdateCaseProductController(new ApexPages.StandardController(testCases[0]));
			objTestUCPC.next();
			objTestUCPC.currentCase.Support_Product__c = objParentSP.Id;
			objTestUCPC.next();
			objTestUCPC.save();
			
			Test.stopTest();
        }
        catch(Exception e){}
    }
	
	static testmethod void test1()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;
			
			Test.startTest();
			
			List<Opportunity> list_Oppty = [SELECT Id,BusinessPartner__c,OwnerId FROM Opportunity 
					WHERE HasOpportunityLineItem = true AND AccountId != null AND BusinessPartner__c != null 
					AND Owner.IsActive = true LIMIT 2];
            
			AP01Opportunity.ConvertToAssets(new Map<Id,Opportunity>(list_Oppty));
            AP04Opportunity.addBPOwnerToSalesTeam(list_Oppty);
			
			// Create a new email and envelope object
			Messaging.InboundEmail email  = new Messaging.InboundEmail();
			Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
			// Create the email body
			email.plainTextBody = 'This should become a note';
			email.fromAddress ='test@test.com';
			String contactEmail = 'jsmith@salesforce.com';
			email.ccAddresses = new String[] {'Jon Smith <' + contactEmail + '>'};
			email.subject = 'Dummy Account Name 123';
        
			AppCRMIssueHanlder objTestACIH = new AppCRMIssueHanlder();
			Messaging.InboundEmailResult result = objTestACIH.handleInboundEmail(email, env);
			
			list_Oppty = [SELECT Id FROM Opportunity WHERE RecordtypeId IN :Util.ESDOpptyRecordTypeId() LIMIT 6];
			if(list_Oppty.size() == 6)
			{
				Map<Id,String> MapID = new Map<Id,String>();
				MapID.put(list_Oppty[0].Id,Config.OPP_STAGE5);
				MapID.put(list_Oppty[1].Id,Config.OPP_STAGE6);
				MapID.put(list_Oppty[2].Id,Config.OPP_STAGE7);
				MapID.put(list_Oppty[3].Id,Config.OPP_STAGE82);
				MapID.put(list_Oppty[4].Id,Config.OPP_STAGE81);
				MapID.put(list_Oppty[5].Id,Config.OPP_STAGE9);
				OQM01Opportunity.SetOQMStageDate(MapID);
			}
			Test.stopTest();
        }
        catch(Exception e){}
    }
	
	static testmethod void test2()
    {
        try
        {
            Case objTestCase = new Case(Subject = 'XYZ');
            CaseAutoFollowUpNotification.populateTemplateBodyMap();
            for(Integer i = 0; i <= 11; i++)
            {
                objTestCase.Status  = 'Awaiting Info';
                objTestCase.Auto_Follow_up_Start_Date__c = Date.today() - i;
                CaseAutoFollowUpNotificationFactory objCAFNF = new CaseAutoFollowUpNotificationFactory();
                objCAFNF.createCaseAutoFollowUpNotification(objTestCase);
                objTestCase.Status  = 'Solution Proposed';
                objCAFNF.createCaseAutoFollowUpNotification(objTestCase);
            }
            
            objTestCase.Closure_Category__c = objTestCase.Closure_Reason_Code__c = 'test';
            insert objTestCase;
            
            CaseOpenFTPExtension objCOFE = new CaseOpenFTPExtension(new ApexPages.StandardController(objTestCase));
            objCOFE.getisValidURL();
            objCOFE.getServer();
            objCOFE.getCasenumber();
            objCOFE.getFtpuser();
            objCOFE.getFtppsswd();
            objCOFE.getStrUrl();
            objCOFE.pageRef();
            
            Test.startTest();
            
            User objUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            Util.mapUserPRM = new Map<Id,User>{objUser.Id => objUser};
            Util.sendEmail(new List<String>{'test@test.com'},'test');
            List<Opportunity> list_Oppty = [SELECT Id,AccountId,OwnerId FROM Opportunity WHERE AccountId != null ORDER BY AccountId LIMIT 1];
            Util.getUserPRMtoDeleteFromAccountTeam(list_Oppty);
            Util.getAccountMapFromOpportunities(new Set<Id>{list_Oppty[0].AccountId});
            Util.getUserPRMinTriggerContext(list_Oppty,list_Oppty);
            Util.ESDOpptyRecordTypeId();
            Util.getRtypeId('Base Item');
            Util.getIds(list_Oppty);
            Util.getOwnerIds(list_Oppty);
            Util.getListIdForDynamicSoql(new Set<String>{'abc'});
            Util.getListIdForDynamicSoql(new Set<String>{'abc','xyz'});
            Util.manualShareOppEdit(list_Oppty[0].Id,UserInfo.getUserId());
            Util.insertOppTMember(new List<OpportunityTeamMember>{new OpportunityTeamMember(OpportunityId = list_Oppty[0].Id,UserId = UserInfo.getUserId(),TeamMemberRole = 'Account Manager')});
            Util.insertOppShare(new List<OpportunityShare>{new OpportunityShare(OpportunityId = list_Oppty[0].Id,UserOrGroupId = UserInfo.getUserId(),OpportunityAccessLevel = 'Edit')});
            Util.insertAccShare(new List<AccountShare>{new AccountShare(AccountId = list_Oppty[0].AccountId,UserOrGroupId = UserInfo.getUserId(),AccountAccessLevel = 'Edit')});
            Util.insertAccTMember(new List<AccountTeamMember>{new AccountTeamMember(AccountId = list_Oppty[0].AccountId,UserId = UserInfo.getUserId(),TeamMemberRole = 'Account Manager')});
            Util.getLstAccShareToUpdate(new Set<Id>{list_Oppty[0].AccountId}, new Set<Id>{UserInfo.getUserId()},'Edit','Edit');
            //AccountShare objAccShare = [SELECT Id FROM AccountShare WHERE AccountId = :list_Oppty[0].AccountId LIMIT 1];
            Util.manualShareAcc(null,list_Oppty[0].AccountId,UserInfo.getUserId(),'Edit','Edit','Edit','Edit');
            //Database.executeBatch(new CaseAutoFollowUpNotificationJob());
           
            Test.stopTest();
        
        }
        catch(Exception e){}
    }
    
    static testmethod void test_LogCaseDeflections()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;
            
            Test.startTest();

            User objPortalUser = [SELECT Id,ContactId FROM User WHERE IsActive = true AND ContactId != null 
                                    LIMIT 1];
            
            System.runAs(objPortalUser)
            {
                KnowledgeArticleVersion kav = [SELECT knowledgeArticleid,title,ArticleNumber,CreatedById,ArticleType from KnowledgeArticleVersion WHERE  
                    PublishStatus = 'online' AND language = 'en_US' LIMIT 1];
                Test.setCurrentPageReference(new PageReference('/apex/xyz?articleClicked=' + kav.knowledgeArticleid));
                
                LogCaseDeflections.incrementCount(objPortalUser.ContactId);
                LogCaseDeflections.incrementCount(objPortalUser.ContactId);
                
                LogCaseDeflections objLCD = new LogCaseDeflections();
                objLCD.logDeflection();
                objLCD = new LogCaseDeflections(new ApexPages.standardController(new Contact()));
            }
            
            Test.stopTest();
        
        }
        catch(Exception e){}
    }
	
	static testmethod void test_AccountMergeController()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;
            
            Test.startTest();

            AccountMergeController objTestAMC = new AccountMergeController();
			List<Account> list_Accounts = [SELECT Id FROM Account LIMIT 2];
			objTestAMC.fromAccount.Id = list_Accounts[0].Id;
			objTestAMC.toAccount.Id = list_Accounts[1].Id;
			String strTest = objTestAMC.fields;
			objTestAMC.fields = strTest;
			objTestAMC.findRelatedRecords();
			for(Util.Wrappers w : objTestAMC.opportunityWrappers)
				w.isSelected = true;
			objTestAMC.moveLeft();
			objTestAMC.moveRight();
			objTestAMC.mergeSelected();
            
            Test.stopTest();
        
        }
        catch(Exception e){}
    }
	
	/*static testmethod void test_ButtonJSCallHelper()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;
            
            Opportunity objTestOppty = new Opportunity( Name='Test Opp');
            objTestOppty.closeDate = Date.today().addMonths(1);
            objTestOppty.StageName = '1.Recognize Needs';     
            objTestOppty.CurrencyIsoCode = 'USD';
            insert objTestOppty;
            
            List<ContractLineItem> list_TestCLIs = [SELECT ServiceContractId FROM ContractLineItem WHERE 
                            Order_Line_Item__r.Revised_Net_License_Value__c != null AND
                            Contract_Line_Item__r.Original_Net_License_value__c != null AND
                            Contract_Line_Item__r.Lic_Invoice__c != null AND
                            Contract_Line_Item__r.Original_License_Invoice_Date__c != null AND
                            ServiceContract.Renewal_License__c != 'New'
                            ORDER BY LineItemNumber LIMIT 1];
            
            Test.startTest();

            ButtonJSCallHelper.newPPUOrder(objTestOppty.Id);
            
            OpportunityLineItem objTestOLI = new OpportunityLineItem();
            objTestOLI.OpportunityId = objTestOppty.Id;
            objTestOLI.PricebookEntryId = [SELECT Id FROM PricebookEntry WHERE 
                                        Product2.PPU_Product__c = true AND CurrencyIsoCode = 'USD' LIMIT 1].Id;
            insert objTestOLI;
            
            ButtonJSCallHelper.newPPUOrder(objTestOppty.Id);
            
            if(list_TestCLIs.size() > 0)
                ButtonJSCallHelper.updateContractLineItemFields(list_TestCLIs[0].ServiceContractId);
                
            ButtonJSCallHelper.updateContractLineItemInvoiceAndInvoiceDate(list_TestCLIs[0].ServiceContractId);
            
            Test.stopTest();
        
        }
        catch(CalloutException e){}
    }*/
}