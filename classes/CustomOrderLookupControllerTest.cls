@isTest
private class CustomOrderLookupControllerTest
{
	@isTest
	static void TestMethod1()
	{
		Account testacc=new Account();
		testacc.Name='testtting account';
		insert testacc;
		 Auto_number__c myCS1 = new Auto_number__c();
		 myCS1.Name='start';
		 myCS1.values__c=1.00;
		 insert myCS1;
		Order__c ord=new Order__c();
		ord.End_User_Name__c=testacc.Id;
		ord.Name='test order';
		ord.status__c='Completed';
		insert ord;
		
	PageReference pageRef = Page.customorderLookup;
	Test.setCurrentPage(pageRef);
	ApexPages.currentPage().getParameters().put('acc',testacc.id);
CustomOrderLookupController contr=new CustomOrderLookupController();
contr.search();
System.assert(contr.results.size()>0);
contr.getFormTag();
contr.getTextBox();

	}
}