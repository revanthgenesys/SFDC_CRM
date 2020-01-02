/*
* Created By: Ashish Goyal (09/04/2018)
* Desc: Test class for the VF Controller, Trigger, and TriggerHelper created for MDM Functionality
*/
@isTest 
private class MDMFunctionality_Test {

    /*
    * Added By: Ashish Goyal (09/04/2018)
    * Desc: Test method to code coverage for the class BusinessRegionTemplateController
    */
    
    static void updateUserPermission() {
    	
    	List<PermissionSet> ps = [SELECT ID From PermissionSet WHERE Name = 'Finance_MDM_Admin'];
    	
    	try { //insert if not already
    		
    		if ( ps.isEmpty() ) {
    		  List<PermissionSetAssignment> assigned = [SELECT ID From PermissionSetAssignment 
    		                                 WHERE PermissionSetId = :ps[0].Id AND AssigneeId = :UserInfo.getUserId() ];
    		
    		  if (assigned.isEmpty())
    		  	insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps[0].Id );
    		  	
    		  User usr = new User(id=UserInfo.getUserId(), BypassValidationRules__c = true);
    		  update usr;
    	   }
    	}
    	catch (Exception e) { 
    		//continue
        }
    	
    }
    static testmethod void test_BusinessRegionTemplateController(){
    	updateUserPermission();
        Cost_Center_Blackout_Peroid__c blackOut = new Cost_Center_Blackout_Peroid__c();
        blackOut.Start_Date__c = Date.today().addDays(-3);
        blackOut.End_Date__c = Date.today().addDays(3);
        insert blackOut;
        
        Business_Region__c objRec = new Business_Region__c();
        objRec.Description__c = 'Test Val';
        objRec.Definition__c = 'Test Val';
        objRec.Region_ID__c = 'IND';
        
        Test.startTest();
        insert objRec;
        update objRec;
        
        try {
	        Business_Region__c objRec1 = new Business_Region__c();
	        objRec1.Description__c = 'Test Val';
	        objRec1.Definition__c = 'Test Val';
	        objRec1.Region_ID__c = 'IND';
	        insert objRec1;
        } catch(Exception ex) {}
        
        try {
	        Business_Region__c objRec2 = new Business_Region__c();
	        objRec2.Description__c = 'Test Val';
	        objRec2.Definition__c = 'Test Val2';
	        objRec2.Region_ID__c = 'TTT';
	        insert objRec2;
        } catch(Exception ex) {}
        
        BusinessRegionTemplateController controllr = new BusinessRegionTemplateController();
        controllr.costId = objRec.Id;
        System.assert(controllr.getCostWrap() != null);
       
        Test.stopTest();
    }
    
    
    /*
    * Added By: Ashish Goyal (09/04/2018)
    * Desc: Test method to code coverage for the class BusinessSegmentTemplateController
    */
    static testmethod void test_BusinessSegmentTemplateController(){
    	updateUserPermission();
        Cost_Center_Blackout_Peroid__c blackOut = new Cost_Center_Blackout_Peroid__c();
        blackOut.Start_Date__c = Date.today().addDays(-3);
        blackOut.End_Date__c = Date.today().addDays(3);
        insert blackOut;
        
        Business_Segment__c objRec = new Business_Segment__c();
        objRec.Description__c = 'Test Val';
        objRec.Definition__c = 'Test Val';
        objRec.Business_Segment_ID__c = 'IND';
        
        Test.startTest();
        insert objRec;
        
        Legal_Entity__c legal = new Legal_Entity__c();
        legal.Legal_Entity_ID__c = '1000010';
        legal.Definition__c = 'Test rec';
        legal.Name_No_Hierarchy__c = 'Test Rec';
        insert legal;
        
        try {
	        Legal_Entity__c legal1 = new Legal_Entity__c();
	        legal1.Legal_Entity_ID__c = '1000013';
	        legal1.Definition__c = 'Test rec';
	        legal1.Name_No_Hierarchy__c = 'Test Rec';
	        insert legal1;
	       
        } catch(Exception ex) {}
        
        
        Business_Segment_Legal_Entity__c legalChild = new Business_Segment_Legal_Entity__c();
        legalChild.Approval_Counter__c = 1;
        legalChild.Business_Segment__c = objRec.Id;
        legalChild.Legal_Entity__c = legal.Id;
        legalChild.Status__c = 'Active';
        insert legalChild;
        
        BusinessSegmentTemplateController  controllr = new BusinessSegmentTemplateController ();
        controllr.costId = objRec.Id;
        System.assert(controllr.getCostWrap() != null);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objRec);
        ManageLegalEntitiesController contrl = new ManageLegalEntitiesController(sc);
        contrl.redirectToBS();
        ApexPages.currentPage().getParameters().put('id', objRec.Id);
        ManageLegalEntitiesController contrl2 = new ManageLegalEntitiesController();
        contrl2.listOfLegalEntitiesWrapper.get(0).blnSelected = true;
        contrl2.saveBS();
        
        Test.stopTest();
    }
    
    
    /*
    * Added By: Ashish Goyal (09/18/2018)
    * Desc: Test method to code coverage for the class CostCenterTemplateController
    */
    static testmethod void test_CostCenterTemplateController(){
    	updateUserPermission();
        Cost_Center_Blackout_Peroid__c blackOut = new Cost_Center_Blackout_Peroid__c();
        blackOut.Start_Date__c = Date.today().addDays(-3);
        blackOut.End_Date__c = Date.today().addDays(3);
        insert blackOut;
        
        Business_Region__c objRec1 = new Business_Region__c();
        objRec1.Description__c = 'Test Val';
        objRec1.Definition__c = 'Test Val';
        objRec1.Region_ID__c = 'IND';
        
        Hierarchy__c hierGap = new Hierarchy__c();
        hierGap.Domain__c = 'Cost Center';
        hierGap.Hierarchy_Description__c = 'Function Cost Center GAAP Reporting Hierarchy';
        hierGap.Node_ID1__c = 'N123';
        hierGap.Level__c = 1;
        hierGap.Node_Type__c = 'Hierarchy Data';
        hierGap.Status__c = 'Active';
        hierGap.Node_Description__c = 'Test rec';
        insert hierGap;
        
        Hierarchy__c hierMgm = new Hierarchy__c();
        hierMgm.Domain__c = 'Cost Center';
        hierMgm.Hierarchy_Description__c = 'Function Cost Center Management Reporting Hierarchy';
        hierMgm.Node_ID1__c = 'N02';
        hierMgm.Level__c = 1;
        hierMgm.Node_Type__c = 'Hierarchy Data';
        hierMgm.Status__c = 'Active';
        hierMgm.Node_Description__c = 'Test rec';
        insert hierMgm;
 
        Global_Setting__c mngmt = new Global_Setting__c(name = 'MDMHierarchyIdTotalFunctionOrg', ID__c = hierMgm.Id);
        insert mngmt;
        Global_Setting__c gaap = new Global_Setting__c(name = 'MDMHierarchyIdTotalFunction', ID__c = hierGap.Id);
        insert gaap; 

        Test.startTest();
        insert objRec1;
        
        try {
	         Business_Region__c objRec2 = new Business_Region__c();
	        objRec2.Description__c = 'Test Val';
	        objRec2.Definition__c = 'Test Val';
	        objRec2.Region_ID__c = 'IND3';
	        insert objRec2;
        } catch(Exception ex) {}
        
        Cost_Center__c objRec = new Cost_Center__c();
        objRec.Description__c = 'Test Val';
        objRec.Definition__c = 'Test Val';
        objRec.Function_ID__c = 'IN01';
        objRec.Region__c = objRec1.Id;
        objRec.Cost_Center_GAAP_Reporting_Hierarchy__c = hierGap.Id;
        objRec.Cost_Center_Management_Hierarchy__c = hierMgm.id;
        insert objRec;
        
        Legal_Entity__c legal = new Legal_Entity__c();
        legal.Legal_Entity_ID__c = '1000010';
        legal.Definition__c = 'Test rec';
        legal.Name_No_Hierarchy__c = 'Test Rec';
        insert legal;
        
        Cost_Center_Legal_Entity__c legalChild = new Cost_Center_Legal_Entity__c();
        legalChild.Approval_Counter__c = 1;
        legalChild.Cost_Center__c = objRec.Id;
        legalChild.Legal_Entity__c = legal.Id;
        legalChild.Status__c = 'Active';
        insert legalChild;
        
        CostCenterTemplateController controllr = new CostCenterTemplateController();
        controllr.costId = objRec.Id;
        System.assert(controllr.getCostWrap() != null);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objRec);
        ManageLegalEntitiesController contrl = new ManageLegalEntitiesController(sc);
        contrl.redirectToCC();
        ApexPages.currentPage().getParameters().put('id', objRec.Id);
        ManageLegalEntitiesController contrl2 = new ManageLegalEntitiesController();
        contrl2.listOfLegalEntitiesWrapper.get(0).blnSelected = true;
        contrl2.saveCC();
        
        objRec.Approval_Status__c = 'Approved';
        update objRec; 
        
        objRec.Approval_Status__c = 'New';
        update objRec; 
       
        objRec1.Description__c = 'New Descr'; 
        objRec.Cost_Center_Management_Hierarchy__c = null;
        objRec.Approval_Status__c = 'Approved';
        update objRec; 
        
        Test.stopTest();
    }
    
    
    /*
    * Added By: Ashish Goyal (09/19/2018)
    * Desc: Test method to code coverage for the class CurrencyTemplateController
    */
    static testmethod void test_CurrencyTemplateController(){
    	updateUserPermission();
        Cost_Center_Blackout_Peroid__c blackOut = new Cost_Center_Blackout_Peroid__c();
        blackOut.Start_Date__c = Date.today().addDays(-3);
        blackOut.End_Date__c = Date.today().addDays(3);
        insert blackOut;
        
        Test.startTest();
        
        Currencies__c objRec = new Currencies__c();
        objRec.Currency_ISO_Code__c = 'USD';
        objRec.Definition__c = 'Test Val';
        objRec.Description__c = 'IN01';
        objRec.Currency_Key__c = 'USD';
        objRec.Currency__c = 'US Dollar';
        insert objRec;
        
        try {
	        Currencies__c objRec1 = new Currencies__c();
	        objRec1.Currency_ISO_Code__c = 'USD';
	        objRec1.Definition__c = 'Test Val';
	        objRec1.Description__c = 'IN01';
	        objRec1.Currency_Key__c = 'USD';
	        objRec1.Currency__c = 'US Dollar';
	        insert objRec1;
        } catch(Exception ex) {}
        
        CurrencyTemplateController controllr = new CurrencyTemplateController();
        controllr.costId = objRec.Id;
        System.assert(controllr.getCostWrap() != null);
        
        Test.stopTest();
    }
    
    
    /*
    * Added By: Ashish Goyal (09/19/2018)
    * Desc: Test method to code coverage for the class ERPCurrencyTemplateController
    */
    static testmethod void test_ERPCurrencyTemplateController(){
    	updateUserPermission();
    	
        Cost_Center_Blackout_Peroid__c blackOut = new Cost_Center_Blackout_Peroid__c();
        blackOut.Start_Date__c = Date.today().addDays(-3);
        blackOut.End_Date__c = Date.today().addDays(3);
        insert blackOut;
        
        Test.startTest();
        
        Currencies__c objRec = new Currencies__c();
        objRec.Currency_ISO_Code__c = 'USD';
        objRec.Definition__c = 'Test Val';
        objRec.Description__c = 'IN01';
        objRec.Currency_Key__c = 'USD';
        objRec.Currency__c = 'US Dollar';
        insert objRec;
        
        ERP_Currency_Daily_Exchange_Rate__c erp = new ERP_Currency_Daily_Exchange_Rate__c();
        erp.CONVERSION_RATE__c = 1.0;
        erp.From_Currency_Name__c = objRec.Id;
        erp.To_Currency_Name__c = objRec.Id;
        erp.FROM_CURRENCY_CODE__c = 'USD';
        erp.TO_CURRENCY_CODE__c = 'USD';
        erp.EXCHANGE_RATE_TYPE__c = 'DAILY';
        erp.Effective_Date__c = System.today();
        erp.Exchange_Rate_Source__c = 'Spot';
        insert erp;
        
        ERP_Currency_Daily_Exchange_Rate__c erp2 = new ERP_Currency_Daily_Exchange_Rate__c();
        erp2.CONVERSION_RATE__c = 1.0;
        erp2.From_Currency_Name__c = objRec.Id;
        erp2.To_Currency_Name__c = objRec.Id;
        erp2.FROM_CURRENCY_CODE__c = 'USD';
        erp2.TO_CURRENCY_CODE__c = 'USD';
        erp2.EXCHANGE_RATE_TYPE__c = 'FORECAST';
        erp2.Effective_Date__c = System.today().addDays(-1);
        erp2.Exchange_Rate_Source__c = 'User';
        insert erp2;
        
        erp.Effective_Date__c = System.today().addDays(-2);
        erp2.Effective_Date__c = System.today();
        update erp;
        update erp2;
        
        ERP_Currency_Daily_Exchange_Rate__c erp3 = new ERP_Currency_Daily_Exchange_Rate__c();
        erp3.Name = 'Xignite';
        erp3.CONVERSION_RATE__c = 1.0;
        erp3.From_Currency_Name__c = objRec.Id;
        erp3.To_Currency_Name__c = objRec.Id;
        erp3.FROM_CURRENCY_CODE__c = 'USD';
        erp3.TO_CURRENCY_CODE__c = 'USD';
        erp3.EXCHANGE_RATE_TYPE__c = 'FORECAST';
        erp3.Effective_Date__c = System.today().addDays(-1);
        erp3.Exchange_Rate_Source__c = 'Xignite';
        insert erp3;
       // update erp3;
        
        ERPCurrencyTemplateController controllr = new ERPCurrencyTemplateController();
        controllr.costId = erp.Id;
        System.assert(controllr.getCostWrap() != null);
        
        Test.stopTest();
    }
    
    
    
    /*
    * Added By: Ashish Goyal (09/18/2018)
    * Desc: Test method to code coverage for the class GL_AccountTemplateController
    */
    static testmethod void test_GL_AccountTemplateController(){
    	updateUserPermission();
        Cost_Center_Blackout_Peroid__c blackOut = new Cost_Center_Blackout_Peroid__c();
        blackOut.Start_Date__c = Date.today().addDays(-3);
        blackOut.End_Date__c = Date.today().addDays(3);
        insert blackOut;
        
        Hierarchy__c hierGap = new Hierarchy__c();
        hierGap.Domain__c = 'GL Account';
        hierGap.Hierarchy_Description__c = 'Planning GL Account GAAP Hierarchy';
        hierGap.Node_ID1__c = 'N1';
        hierGap.Level__c = 1;
        hierGap.Node_Type__c = 'Hierarchy Data';
        hierGap.Status__c = 'Active';
        hierGap.Node_Description__c = 'Test rec';
        insert hierGap;
        
        Hierarchy__c hierMgm = new Hierarchy__c();
        hierMgm.Domain__c = 'GL Account';
        hierMgm.Hierarchy_Description__c = 'GL Account Management Hierarchy';
        hierMgm.Node_ID1__c = 'N02';
        hierMgm.Level__c = 1;
        hierMgm.Node_Type__c = 'Hierarchy Data';
        hierMgm.Status__c = 'Active';
        hierMgm.Node_Description__c = 'Test rec';
        insert hierMgm;
        
        Hierarchy__c prfMgm = new Hierarchy__c();
        prfMgm.Domain__c = 'GL Account';
        prfMgm.Hierarchy_Description__c = 'GL Account Management w Proforma Hierarchy';
        prfMgm.Node_ID1__c = 'N03';
        prfMgm.Level__c = 1;
        prfMgm.Node_Type__c = 'Hierarchy Data';
        prfMgm.Status__c = 'Active';
        prfMgm.Node_Description__c = 'Test rec';
        insert prfMgm;
        
        Hierarchy__c lndrMgm = new Hierarchy__c(
        Domain__c = 'GL Account',
        Hierarchy_Description__c = 'GL Account Lender Hierarchy',
        Node_ID1__c = 'N04',
        Level__c = 1,
        Node_Type__c = 'Hierarchy Data',
        Status__c = 'Active',
        Node_Description__c = 'Test rec');
        insert lndrMgm;
        
        Hierarchy__c statMgm = new Hierarchy__c(
        Domain__c = 'GL Account',
        Hierarchy_Description__c = 'Statistical Account Hierarchy',
        Node_ID1__c = 'N05',
        Level__c = 1,
        Node_Type__c = 'Hierarchy Data',
        Status__c = 'Active',
        Node_Description__c = 'Test rec');
        insert statMgm;
 
        Global_Setting__c gaap = new Global_Setting__c(name = 'MDMPlanningGLAccountGAAPHierarchy', ID__c = hierMgm.Id);
        insert gaap; 
        Global_Setting__c mngmt = new Global_Setting__c(name = 'MDMGLAccountManagementHierarchy', ID__c = hierGap.Id);
        insert mngmt;        
        Global_Setting__c prf = new Global_Setting__c(name = 'MDMGLAccountMngmtProformaHierarchy', ID__c = prfMgm.Id);
        insert prf;
        Global_Setting__c lndr = new Global_Setting__c(name = 'MDMGLAccountLenderHierarchy', ID__c = lndrMgm.Id);
        insert lndr;
        Global_Setting__c statist = new Global_Setting__c(name = 'MDMStatisticalAccountHierarchy', ID__c = statMgm.Id);
        insert statist;
        
	    GL_Account__c objRec = new GL_Account__c(
	      Description__c = 'Test Val',
	      Proposed_GL_Account_ID__c = 'IN01',
	      Status__c = 'Active',
	      Planning_GL_Account_GAAP_Hierarchy__c = hierGap.Id,
	      GL_Account_Management_Hierarchy__c = hierMgm.Id,
	      GL_Account_Management_w_Proforma__c = prfMgm.Id,
	      GL_Account_Lender_Hierarchy__c = lndrMgm.Id,
	      Statistical_Account_Hierarchy__c = statMgm.Id
	    );	    
	    insert objRec;
	    
	    objRec.Status__c = 'Inactive';
	    update objRec;
     
        try {
	        GL_Account__c objRec3 = new GL_Account__c();
	        objRec3.Description__c = 'Test Val';
	        objRec3.Proposed_GL_Account_ID__c = 'IN01';
	        insert objRec3;
	    } catch(Exception ex) {}
        
        Legal_Entity__c legal = new Legal_Entity__c();
        legal.Legal_Entity_ID__c = '1000010';
        legal.Definition__c = 'Test rec';
        legal.Name_No_Hierarchy__c = 'Test Rec';
        insert legal;
        
        GL_Account_Legal_Entity__c legalChild = new GL_Account_Legal_Entity__c();
        legalChild.Approval_Counter__c = 1;
        legalChild.GL_Account__c = objRec.Id;
        legalChild.Legal_Entity__c = legal.Id;
        legalChild.Status__c = 'Active';
        insert legalChild;
        
        Test.startTest(); 
         
        GL_AccountTemplateController controllr = new GL_AccountTemplateController();
        controllr.costId = objRec.Id;
        System.assert(controllr.getCostWrap() != null);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objRec);
        ManageLegalEntitiesController contrl = new ManageLegalEntitiesController(sc);
        contrl.redirectToGLA();
        ApexPages.currentPage().getParameters().put('id', objRec.Id);
        ManageLegalEntitiesController contrl2 = new ManageLegalEntitiesController();
        contrl2.listOfLegalEntitiesWrapper.get(0).blnSelected = true;
        contrl2.saveGLA();
        
        FinanceMDMTriggerHelper.checkDuplicateGLIdOrDescription(new List<GL_Account__c>());
        FinanceMDMTriggerHelper.checkDuplicateLegalIdOrDescription(new List<Legal_Entity__c>());
        FinanceMDMTriggerHelper.checkDuplicateCurrencyIdOrDescription(new List<Currencies__c>());
        Test.stopTest();
    }
    
    
    /*
    * Added By: Ashish Goyal (09/18/2018)
    * Desc: Test method to code coverage for the class HierarchyTemplateController
    */
    static testmethod void test_HierarchyTemplateController(){
    	updateUserPermission();
        Cost_Center_Blackout_Peroid__c blackOut = new Cost_Center_Blackout_Peroid__c();
        blackOut.Start_Date__c = Date.today().addDays(-3);
        blackOut.End_Date__c = Date.today().addDays(3);
        insert blackOut;
                
        Test.startTest(); 
        
        Hierarchy__c objRec = new Hierarchy__c();
        objRec.Domain__c = 'Legal Entity';
        objRec.Hierarchy_Description__c = 'Legal Entity Hierarchy';
        objRec.Node_ID1__c = 'N123';
        objRec.Level__c = 1;
        objRec.Node_Type__c = 'Master Data';
        objRec.Node_Description__c = 'Test rec';
        insert objRec;
        
        objRec.Node_Description__c = 'Test rec1';
        update objRec;
        
        HierarchyTemplateController controllr = new HierarchyTemplateController();
        controllr.costId = objRec.Id;
        System.assert(controllr.getCostWrap() != null);
        Test.stopTest();
    }
    
    
    /*
    * Added By: Ashish Goyal (09/19/2018)
    * Desc: Test method to code coverage for the class LegalEntityTemplateController
    */
    static testmethod void test_LegalEntityTemplateController (){
    	updateUserPermission();
        Cost_Center_Blackout_Peroid__c blackOut = new Cost_Center_Blackout_Peroid__c();
        blackOut.Start_Date__c = Date.today().addDays(-3);
        blackOut.End_Date__c = Date.today().addDays(3);
        insert blackOut;
                
        Test.startTest(); 
        
        Legal_Entity__c legal = new Legal_Entity__c();
        legal.Legal_Entity_ID__c = '1000010';
        legal.Definition__c = 'Test rec';
        legal.Name_No_Hierarchy__c = 'Test Rec';
        insert legal;
                
        LegalEntityTemplateController controllr = new LegalEntityTemplateController();
        controllr.costId = legal.Id;
        System.assert(controllr.getCostWrap() != null);
        Test.stopTest();
    }
    
    
    /*
    * Added By: Ashish Goyal (09/19/2018)
    * Desc: Test method to code coverage for the class ReferenceDataTemplateController
    */
    static testmethod void test_ReferenceDataTemplateController(){
    	updateUserPermission();
        Cost_Center_Blackout_Peroid__c blackOut = new Cost_Center_Blackout_Peroid__c();
        blackOut.Start_Date__c = Date.today().addDays(-3);
        blackOut.End_Date__c = Date.today().addDays(3);
        insert blackOut;
                
        Test.startTest(); 
        
        Reference_Data__c objRec = new Reference_Data__c();
        objRec.Data_Element_ID_Description__c = 'Business Segment Cloud View Hierarchy';
        objRec.Data_Element_ID__c = 123;
        objRec.Data_Element_ID_Status__c = 'Active';
        insert objRec;
                
        ReferenceDataTemplateController controllr = new ReferenceDataTemplateController();
        controllr.costId = objRec.Id;
        System.assert(controllr.getCostWrap() != null);
        Test.stopTest();
    }
}