//Ravi V - G360 -  9/3/2013
@isTest(SEEALLDATA=TRUE)
public class test_customer_page_Class
{  


 static testMethod void testClassMethod()
  { 
   List<Account> accounts = new List<Account>{};
   accounts =[select ownerid,SAP_Account_Code__c from account where SAP_Account_Code__c <> null LIMIT 1];
   PageReference pageRef = Page.Customer_Dashboard_Page;
   pageRef.getParameters().put('id',accounts[0].id);
   Test.setCurrentPageReference(pageRef); 
   ApexPages.StandardsetController controller = new ApexPages.StandardsetController(accounts); 
   customer_page cp = new customer_page(controller);
   String st=cp.getExternalurl();
   String userip=cp.GetUserIPAddress();
   Boolean flag =cp.getChecksrc();
  
  }
}