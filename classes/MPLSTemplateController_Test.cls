@isTest
public class MPLSTemplateController_Test {

  public static testMethod void test1()
  {
     Test.StartTest();
     
      MPLS_RVA_Quote_Request__c objMPLS = new MPLS_RVA_Quote_Request__c();
      objMPLS.name = 'test';
      insert objMPLS;
      
      PageReference pageRef = Page.MPLSTemplate;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('MPLS_Quote_Id', objMPLS.Id);
        ApexPages.currentPage().getParameters().put('ServerURL', 'www.salesforce.com');  
        ApexPages.currentPage().getParameters().put('SessionId', 'ffdfdfdfdfdfdf');
     
      MPLSTemplateController obj = new MPLSTemplateController();
      obj.CreateMPLS();
      
     Test.StopTest();
  }
}