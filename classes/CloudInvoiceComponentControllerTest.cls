/**
 * Created by 		: Vijay Gopi
 * Description 		: Test cover for Invoice PDF Generator.
 * Covered Class 	: CloudInvoiceComponentController
 */
@isTest
private class CloudInvoiceComponentControllerTest {

	@testSetup
    static void setUpData() {
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_Accounts = TestUtil.createAccounts(1,false);
        list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
        insert list_Accounts;
        Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
    	objOpportunity.Lines_of_Businesses__c = 'PureCloud';
        insert objOpportunity;
        zqu__Quote__c objQuote = setupZuoraQuote('PureCloud Test ZQuote 1', objOpportunity.AccountId ,objOpportunity.id, 24);
		objQuote.zqu__StartDate__c = System.today()- 730; 
        insert objQuote;
        GCR_Content_Document_Detail__c objContract = setupContracts(objQuote);
        Genesys_Entity__c objGenEntity = setupGenesysEntity();
        objContract.Genesys_Entity__c = objGenEntity.id;
        insert objContract;
        Order__c objOrder = setupOrder(objContract);
        objOrder.Order_Date__c = System.today();
        objOrder.Memo__c = '111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111'+
            				'11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        insert objOrder;
        System.debug('objOrder : '+objOrder);
        List<Product2> list_Products = setupProducts();
        //List<PricebookEntry> list_PricebookEntry =  TestUtil.createPriceBookEntries(list_Products, true, 'USD');
        List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines( list_Products, objOrder.id, false);
        for(Order_Line_Item__c objOLI : list_OLIs){
            objOLI.Memo__c = 'Test Memo';
        }
        List<SureTax_Settings__c> list_SureTaxDesciption = setupSureTaxSettings();
        List<Order_Line_Item__c> list_OLISureTax = setupOLISureTax(list_SureTaxDesciption, objOrder.id , list_Products[0]);
        list_OLIs.addAll(list_OLISureTax);
        insert list_OLIs;
        Invoice__c objInvoice = new Invoice__c(Name = 'Test Invoice', Order__c = objOrder.id );
        insert objInvoice;
        System.debug('objInvoice : '+objInvoice);
    }
    
    private static testmethod void testExtensionController(){
        Invoice__c objInvoice = [SELECT Id FROM Invoice__c Limit 1];
        ApexPages.StandardController objStdInv = new ApexPages.StandardController(objInvoice);
        CBInvoicePDFExtensionController objExtCont = new CBInvoicePDFExtensionController(objStdInv);
    }
    
    private static testmethod void testController(){
        Invoice__c objInvoice = [SELECT id FROM Invoice__c LIMIT 1];
        Test.startTest();
        CloudInvoiceComponentController objController = new CloudInvoiceComponentController();
        Test.setCurrentPage(Page.CloudInvoicePDF);
        ApexPages.currentPage().getParameters().put('id',objInvoice.Id);
        objController.idInvoice = objInvoice.Id;
        objController.getObjGenesysEntity();
        Test.stopTest();
    }
    
    static List<Cloud_Deployment__c> setupCloudDeployments(List<GCR_Content_Document_Detail__c> list_Contracts){
    	List<Cloud_Deployment__c> list_CloudDeployments = new List<Cloud_Deployment__c>();
    	
    	for(GCR_Content_Document_Detail__c objContract : list_Contracts){
    		Cloud_Deployment__c objCloudDeployment = new Cloud_Deployment__c();
    		objCloudDeployment.Account__c = objContract.Account_Name__c;
    		//objCloudDeployment.Cloud_Billing_Contract__c = objContract.id ;
    		objCloudDeployment.Cloud_Platform__c = 'PureCloud';
    		objCloudDeployment.PureCloud_OrgID__c = objContract.Account_Name__c + '#'+ objContract.id ;
    		list_CloudDeployments.add(objCloudDeployment);
    	}
    	insert list_CloudDeployments;
    	return list_CloudDeployments;
    }
    
    static zqu__Quote__c setupZuoraQuote(String strName, String strAccId , String strOppId, Integer intPeriod ){
        zqu__Quote__c objZquQuote = new zqu__Quote__c();
        objZquQuote.Name = strName;
        objZquQuote.zqu__Account__c = strAccId;
        objZquQuote.zqu__Opportunity__c = strOppId;
        objZquQuote.PureCloud_Ramp_Up_Period__c = intPeriod;
        return objZquQuote;
    }
    
    static GCR_Content_Document_Detail__c setupContracts(zqu__Quote__c objQuote){
        GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c();
        objContract.Account_Name__c = objQuote.zqu__Account__c;
        objContract.Document_Name__c = 'Cloud Billing Contract';
        objContract.Zuora_Quote__c = objQuote.id;
        objContract.Order_Date_Option__c = 'Last Day of Usage Month';
        objContract.Status__c = 'New';
        objContract.Active__c = true;
        objContract.Status__c = 'Approved';
        objContract.Pricing_Start_Date__c = System.today() - 730 ;
        return objContract;
    }
    
    static Order__c setupOrder(GCR_Content_Document_Detail__c objContract){
        Order__c objOrder = new Order__c(Name = 'Test Order');
		objOrder.Contract_Lookup__c = objContract.Id;
        objOrder.Month__c = System.today().month()+'';
        objOrder.Year__c = System.today().year()+'';
        objOrder.status__c = 'In Progress';
        objOrder.End_User_Name__c = objOrder.Bill_To_Name__c = objOrder.Sold_To_Name__c = objOrder.Ship_To_Name__c = objContract.Account_Name__c ;
        objOrder.Opportunity__c = objContract.Zuora_Quote__r.zqu__Opportunity__c;
        return objOrder;
    }
    
    static List<Product2> setupProducts(){
        return TestUtil.createProducts(5, true);
    }
    
    static Genesys_Entity__c setupGenesysEntity(){
        Genesys_Entity__c objGenEntity = new Genesys_Entity__c();
        objGenEntity.Remit_To__c = 'Test Remit To Info';
        objGenEntity.Selling_Entity__c = 'Test Selling Entity Info';
        objGenEntity.CurrencyIsoCode = 'USD';
        insert objGenEntity;
        return objGenEntity;
    }
    
    static List<SureTax_Settings__c> setupSureTaxSettings(){
        List<SureTax_Settings__c> list_SureTaxDesciption = new List<SureTax_Settings__c>();
        list_SureTaxDesciption.add(new SureTax_Settings__c(name = '100' , Value__c = 'Test Tax 1'));
        list_SureTaxDesciption.add(new SureTax_Settings__c(name = '101' , Value__c = 'Test Tax 1'));
        list_SureTaxDesciption.add(new SureTax_Settings__c(name = '102' , Value__c = 'Test Tax 1'));
        list_SureTaxDesciption.add(new SureTax_Settings__c(name = '103' , Value__c = 'Test Tax 1'));
        insert list_SureTaxDesciption;
        return list_SureTaxDesciption;
    }
    
    static List<Order_Line_Item__c> setupOLISureTax(List<SureTax_Settings__c> list_SureTaxDesciption , id strOrderId, Product2 objProduct){
        List<Order_Line_Item__c> list_OLI = new List<Order_Line_Item__c>();
        Order_Line_Item__c objBaseOLI = TestUtil.createOrderLines(new List<Product2>{objProduct}, strOrderId , false)[0];
        for(SureTax_Settings__c objSureTaxSetting : list_SureTaxDesciption){
            Order_Line_Item__c objOLI = objBaseOLI ;
            objOLI.Name = 'Tax Group';
            objOLI.Memo__c = objSureTaxSetting.Value__c;
        }
        return list_OLI;
    }
}