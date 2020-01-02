//Naresh Kumar	10/09/2014
@isTest(seeAllData = true)
public with sharing class ProposalPDFOnPremiseControllerTest {
	 static testMethod void testQuoteAproval() {
        
        //Account
        Account testAccount = TestCommon.createAccount(true);
        //Country
        Country__c testCountry = new Country__c(Country__c = 'United States A');
        testCountry.DAP_Region__c = 'NA';
        testCountry.Region__c = 'NA';
        testCountry.RU__c = 'NA';        
        insert testCountry;
        //Opportunity
        Opportunity testOpp = TestCommon.createOpportunity(testAccount.id);
        //Country
        testOpp.Country__c = testCountry.id;
        update testOpp;
        //Quote
        BigMachines__Quote__c testQuote = new BigMachines__Quote__c();
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        testQuote.ELA__c = true;
        testQuote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_PENDING;
        insert testQuote;        
        //Quote Product
        createQuoteProducts(testOpp, testQuote);
        
        ApexPages.currentPage().getParameters().put('id', testQuote.id);	
        ProposalPDFOnPremiseController objCont = new ProposalPDFOnPremiseController();
        
	 }
	 
	 // Added on Aug 8th - Vijay - Start
	 
	 static testMethod void testControllerHelper1() {
        
        //Account
        Account testAccount = TestCommon.createAccount(true);
        //Country
        Country__c testCountry = new Country__c(Country__c = 'United States A');
        testCountry.DAP_Region__c = 'NA';
        testCountry.Region__c = 'NA';
        testCountry.RU__c = 'NA';        
        insert testCountry;
        //Opportunity
        Opportunity testOpp = TestCommon.createOpportunity(testAccount.id);
        //Country
        testOpp.Country__c = testCountry.id;
        update testOpp;
        //Quote
        BigMachines__Quote__c testQuote = new BigMachines__Quote__c();
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        testQuote.ELA__c = true;
        testQuote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_PENDING;
        testQuote.Offering_Type__c = 'Cloud Partner (PPU)';
        insert testQuote;        
        //Quote Product
        createQuoteProducts(testOpp, testQuote);
        createQuoteProposalGroups(testQuote.Id);
        
        ApexPages.currentPage().getParameters().put('id', testQuote.id);	
        ProposalPDFOnPremiseController objCont = new ProposalPDFOnPremiseController();
        ProposalPDFOnPremiseControllerHelper.getCurrencySymbol('GBP');
        ProposalPDFOnPremiseControllerHelper.getCurrencySymbol('BRL');
        ProposalPDFOnPremiseControllerHelper.getCurrencySymbol('EUR');
        ProposalPDFOnPremiseControllerHelper.getCurrencySymbol('JPY');
        ProposalPDFOnPremiseControllerHelper.getCurrencySymbol('');
        
        ProposalPDFOnPremiseControllerHelper.getTypeName('Product');
        ProposalPDFOnPremiseControllerHelper.getTypeName('Product - Hardware');
        ProposalPDFOnPremiseControllerHelper.getTypeName('PS');
        ProposalPDFOnPremiseControllerHelper.getTypeName('GU');
        
        ProposalPDFOnPremiseControllerHelper.getProporalGroupsMap(testQuote.Id);
        
        List<BigMachines__Quote_Product__c> quoteProducts = [SELECT Id, BigMachines__Product__c
        													 FROM BigMachines__Quote_Product__c
        													 WHERE BigMachines__Quote__c = :testQuote.Id];
        Product2 obj = new Product2(id=quoteProducts[0].BigMachines__Product__c);
        obj.New_Category__c = 'Genesys Care';
        update obj;
        List<BigMachines__Quote_Product__c> otherQuoteProducts = [SELECT Id, BigMachines__Product__c, BigMachines__Product__r.New_Category__c,
        													 BigMachines__Product__r.Taxonomy_Solution__c, BigMachines__Product__r.Taxonomy_Solution_Category__c
        													 FROM BigMachines__Quote_Product__c
        													 WHERE BigMachines__Quote__c = :testQuote.Id AND
        													 BigMachines__Product__c = :quoteProducts[0].BigMachines__Product__c];
        
        testQuote.Do_Not_Group_Output_By_Taxonomy_Category__c = true;
        testQuote.Group_Product_By__c = null;
        update testQuote;
        
        ProposalPDFOnPremiseControllerHelper.getUniqueGroupName(testQuote, otherQuoteProducts[0] ,
        														 new Map<String,String>{'1'=>'Test Name 1', '2'=>'Test Name 2'});
        
        otherQuoteProducts[0].BigMachines__Product__r.New_Category__c = NULL;
        ProposalPDFOnPremiseControllerHelper.getUniqueGroupName(testQuote, otherQuoteProducts[0] ,
        														 new Map<String,String>{'1'=>'Test Name 1', '2'=>'Test Name 2'});
        
        testQuote.Do_Not_Group_Output_By_Taxonomy_Category__c = false;
        testQuote.Offering_Type__c = 'PureConnect On Premise';
        update testQuote;
        
        ProposalPDFOnPremiseControllerHelper.getUniqueGroupName(testQuote, otherQuoteProducts[0] ,
        														 new Map<String,String>{'1'=>'Test Name 1', '2'=>'Test Name 2'});
        
        
        testQuote.Offering_Type__c = 'PureConnect';
        update testQuote;
        
        ProposalPDFOnPremiseControllerHelper.getUniqueGroupName(testQuote, otherQuoteProducts[0] ,
        														 new Map<String,String>{'1'=>'Test Name 1', '2'=>'Test Name 2'});
        
        
        testQuote.Group_Product_By__c = 'Part Number';
        update testQuote;
        otherQuoteProducts[0].Group_Number__c = NULL;
        ProposalPDFOnPremiseControllerHelper.getUniqueGroupName(testQuote, otherQuoteProducts[0] ,
        														 new Map<String,String>{'1'=>'Test Name 1', '2'=>'Test Name 2'});
        
        otherQuoteProducts[0].Group_Number__c = '2';
        ProposalPDFOnPremiseControllerHelper.getUniqueGroupName(testQuote, otherQuoteProducts[0] ,
        														 new Map<String,String>{'1'=>'Test Name 1', '2'=>'Test Name 2'});
	 }
	 
	 private static void createQuoteProposalGroups(Id quoteId){
        Quote_Proposal_Group__c objQPG1 = new Quote_Proposal_Group__c();
        objQPG1.Quote__c = quoteId;
        objQPG1.Group_Number__c = '1';
        objQPG1.Name__c = 'Test Name 1';
        objQPG1.Description__c = 'Test Description';
        
        
        Quote_Proposal_Group__c objQPG2 = new Quote_Proposal_Group__c();
        objQPG2.Quote__c = quoteId;
        objQPG2.Group_Number__c = '2';
        objQPG2.Name__c = 'Test Name 2';
        objQPG2.Description__c = 'This is to test for description lenght longer than 40 chars. This is very loooooooooooooooooooooong';
        
        List<Quote_Proposal_Group__c> list_QPG = new List<Quote_Proposal_Group__c>{objQPG1,objQPG2};
        
        insert list_QPG;
	 }
	 
	 private static List<Product_Group__c> createQuoteProductGroups(List<Product2> list_Products){
		List<Product_Group__c> list_QuoteProductGroups = new List<Product_Group__c>();
		boolean flag = false;
		
		for(Product2 objProd : list_Products ){
			Product_Group__c objQPG = new Product_Group__c();
			objQPG.Name = objProd.Name;
			objQPG.Active__c = true;
			objQPG.Description__c = 'test Description';
			objQPG.User__c = UserInfo.getUserId();
			objQPG.Type__c = 'Standalone';
			objQPG.Product__c = objProd.id;
			objQPG.Pricing_Model__c = 'Enabled';
			objQPG.Quantity__c = 1;
			list_QuoteProductGroups.add(objQPG);
		}
		insert list_QuoteProductGroups;
		return list_QuoteProductGroups;
	}
		 
	 // Added on Aug 8th - Vijay - End
	 
	 
	 private static void createQuoteProducts(Opportunity testOpp,  BigMachines__Quote__c testQuote){
    	Product_Manager_Approval_Group__c testPMGroup = new Product_Manager_Approval_Group__c();
    	testPMGroup.Name = 'Test PM Group';
    	insert testPMGroup;
    	List<Product2> products = TestUtil.createProducts(3, false);
    	products[0].Type__c = QuoteApprovalUtil.PRODUCT_TYPE_GU;
    	products[0].Product_Specific_Discount__c = 10;
    	products[0].Third_Party__c = 'TRUE';
    	products[1].Type__c = QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE;  
    	products[1].Product_Manager_Approval_Group__c = testPMGroup.id;
    	products[1].Shipment_Approval__c = QuoteApprovalUtil.REQUIRED_FOR_NEW_ORDERS_ONLY;
    	products[2].Type__c = 'Cloud';  
    	products[2].Product_Manager_Approval_Group__c = testPMGroup.id;
    	products[2].Shipment_Approval__c = QuoteApprovalUtil.NOTIFICATION_ONLY;    	
    	insert products;
    	List<PricebookEntry> pbes = TestUtil.createPriceBookEntries(products, true);
    	Pricebook2 standardPB = [select id from Pricebook2 where isstandard=true LIMIT 1];
    	testOpp.Pricebook2Id = standardPB.id;    	
    	update testOpp;
    	
    	List<BigMachines__Quote_Product__c> quoteProducts = TestUtil.createQuoteProducts(products, false);    	
    	quoteProducts[0].BigMachines__Quote__c = testQuote.id;
    	quoteProducts[0].Total_Discount__c = 20;
    	quoteProducts[0].BigMachines__Quantity__c = 10;
    	quoteProducts[0].BigMachines__Sales_Price__c = 100;
    	quoteProducts[1].BigMachines__Quote__c = testQuote.id;
    	quoteProducts[1].Total_Discount__c = 20;
    	quoteProducts[1].BigMachines__Quantity__c = 10;
    	quoteProducts[1].BigMachines__Sales_Price__c = 100;
    	quoteProducts[2].BigMachines__Quote__c = testQuote.id;
    	quoteProducts[2].Total_Discount__c = 20;    
    	quoteProducts[2].BigMachines__Quantity__c = 10;
    	quoteProducts[2].BigMachines__Sales_Price__c = 100;	
    	
    	insert quoteProducts;
    	
    	// Added on Aug 8th - Vijay - Start
    	List<Product_Group__c> list_QuoteProductGroups = createQuoteProductGroups(products);
    	
    	List<BigMachines__Quote_Product__c> quoteProducts2 = TestUtil.createQuoteProducts(products, false);    	
    	quoteProducts2[0].BigMachines__Quote__c = testQuote.id;
    	quoteProducts2[0].Total_Discount__c = 20;
    	quoteProducts2[0].BigMachines__Quantity__c = 10;
    	quoteProducts2[0].BigMachines__Sales_Price__c = 100;
    	quoteProducts2[1].BigMachines__Quote__c = testQuote.id;
    	quoteProducts2[1].Total_Discount__c = 20;
    	quoteProducts2[1].BigMachines__Quantity__c = 10;
    	quoteProducts2[1].BigMachines__Sales_Price__c = 100;
    	quoteProducts2[2].BigMachines__Quote__c = testQuote.id;
    	quoteProducts2[2].Total_Discount__c = 20;    
    	quoteProducts2[2].BigMachines__Quantity__c = 10;
    	quoteProducts2[2].BigMachines__Sales_Price__c = 100;	
    	
    	quoteProducts2[0].Bundle__c = list_QuoteProductGroups[0].id;
    	quoteProducts2[1].Bundle__c = list_QuoteProductGroups[1].id;
    	quoteProducts2[2].Bundle__c = list_QuoteProductGroups[2].id;
    	
    	quoteProducts2[0].Bundle_Line__c = quoteProducts[0].id;
    	quoteProducts2[1].Bundle_Line__c = quoteProducts[1].id;
    	quoteProducts2[2].Bundle_Line__c = quoteProducts[2].id;
    	
    	insert quoteProducts2;
    	// Added on Aug 8th - Vijay - End
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}