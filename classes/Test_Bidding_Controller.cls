@isTest
private class Test_Bidding_Controller {

    static testMethod void myUnitTest() {
      	Pagereference p1 = Page.BiddingCost;
     
     	p1.getParameters().put('retUrl','/home');
     	Test.setCurrentPageReference(p1);
     	
     	string oqmId = [select id from OQM_Form__c limit 1].id;
     	double days = 5;
     	Bidding_Cost__c bcRecord = new Bidding_Cost__c(NB_DAYS__c = days, OQM_name__c = oqmId);
     	insert bcRecord;
     	ApexPages.StandardController sc = new ApexPages.standardController(bcRecord);
     	Bidding_Cost_Controller BC = new Bidding_Cost_Controller(sc);
     	BC.getCostItem();
     	BC.getCurrencyIsoCode();
    }
}