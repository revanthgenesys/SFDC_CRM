@isTest
public class QuoteRequestDataCenterSubmit_Test {

  public static testMethod void test1()
  {
     Test.StartTest();
      MPLS_RVA_Quote_Request__c obj = new MPLS_RVA_Quote_Request__c();
       try
       {
          
           obj.name = 'test';
           
           
           QuoteRequestDataCenterSubmit.submitStatus(obj.id);
           
       }
       catch(Exception ex)    
       {
         
       }
       insert obj;
     
     Test.StopTest();
  }
}