/*
	04/25/2013	Naresh Kumar
	Test Class to test main class FR_FieldUpdat
*/
@isTest (seeAllData = true)
private class FR_FieldUpdate_Test {

    static testMethod void myTestMethodComponent() {
    	List<Support_Product__c> testParentSupportProducts = TestUtil.createSupportProducts(2, true);
    	
    	List<Support_Product__c> testSupportProducts = TestUtil.createSupportProducts(6, false);
    	testSupportProducts[0].Product_Type__c = 'Component';
    	testSupportProducts[0].Parent_Product__c = testParentSupportProducts[0].id;
    	testSupportProducts[1].Product_Type__c = 'Component';
    	testSupportProducts[1].Parent_Product__c = testParentSupportProducts[1].id;    
    	testSupportProducts[2].Product_Type__c = 'Product Line';
    	testSupportProducts[3].Product_Type__c = 'Product Line';    	
    	testSupportProducts[4].Product_Type__c = 'Product';
    	testSupportProducts[4].Parent_Product__c = testParentSupportProducts[0].id;
    	testSupportProducts[5].Product_Type__c = 'Product';
    	testSupportProducts[5].Parent_Product__c = testParentSupportProducts[1].id;
    	
    	insert testSupportProducts;
    	
    	Case testCase = TestUtil.createCases(1, false)[0];
    	testCase.Component__c = testSupportProducts[0].id;
    	//testCase.Product_Line__c = testSupportProducts[2].id;
    	
    	testCase.Support_Product__c = testSupportProducts[4].id;
    	testCase.Product_Line__c = testParentSupportProducts[0].id;
    	insert testCase; 
    	testCase.Component__c = testSupportProducts[1].id;
    	testParentSupportProducts[1].Product_Type__c = 'Product';
    	testCase.Support_Product__c = testSupportProducts[5].id;
    	testCase.Product_Line__c = testParentSupportProducts[1].id;
    	update testCase;
    }
    static testMethod void myTestMethodSupportProduct() {
    	List<Support_Product__c> testParentSupportProducts = TestUtil.createSupportProducts(2, false);
		testParentSupportProducts[0].Product_Type__c = 'Product';
    	testParentSupportProducts[1].Product_Type__c = 'Product';
    	insert testParentSupportProducts;	    	  
    	Case testCase = TestUtil.createCases(1, false)[0];
    	testCase.Support_Product__c = testParentSupportProducts[0].id;
    	insert testCase; 
    	testCase.Support_Product__c = testParentSupportProducts[1].id;
    	update testCase;
    }
    static testMethod void myTestMethodProductLine() {
    	List<Support_Product__c> testSupportProducts = TestUtil.createSupportProducts(6, false);
    	testSupportProducts[2].Product_Type__c = 'Product Line';
    	testSupportProducts[3].Product_Type__c = 'Product Line';    	
    	insert testSupportProducts;
    	
    	Case testCase = TestUtil.createCases(1, false)[0];
    	testCase.Product_Line__c = testSupportProducts[2].id;    	
    	insert testCase; 
    	testCase.Product_Line__c = testSupportProducts[3].id;
    	update testCase;
    }
}