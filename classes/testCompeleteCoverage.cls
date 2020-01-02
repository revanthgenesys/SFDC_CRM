@isTest
private class testCompeleteCoverage{
    static testMethod  void test_ApprovalRequests() 
    {
        System.debug('START testCompeleteCoverage.ApprovalRequests');
        ApprovalRequests ap = new ApprovalRequests();
        System.debug('END testCompeleteCoverage.ApprovalRequests');
    }
    
     static testMethod  void test_Bidding_Cost_Controller() 
    {
    }
    
    static testMethod  void test_PopupMessageOQMFormController()    
    {
       PopupMessageOQMFormController c= new  PopupMessageOQMFormController(); 

    }
    
     static testMethod void test_Ctrl02_VF03_ProcessingOQMForm() 
     {        
          Pagereference p1 = Page.VF03_SubmitOQMForm;           
         Test.setCurrentPageReference(p1);              
         OQM_Form__c oqm = [select id from OQM_Form__c limit 1];       
             
         ApexPages.StandardController sc = new ApexPages.standardController(oqm);       
         Ctrl02_VF03_ProcessingOQMForm  BC = new Ctrl02_VF03_ProcessingOQMForm(sc);  
         
         BC.Submit_OQM_Form();  
         BC.Reject_OQM_Form();   
         BC.Pending_OQM_Form();
         BC.Send_RFP_Email('email'); 
     }
    

    }