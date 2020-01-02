@isTest
public with sharing class ctrlRFPSupportReqHandler_test
{

    
    static testMethod void testctrlRFPSubmitReqHandler()
       {
       
           TestUtil.setConfigValues();
           
           Account acc = TestUtil.createAccounts(1,true)[0];
           
           Opportunity opp = TestUtil.createOpportunities(1,acc.Id,true)[0];
           
           RFP_Support_Request__c rfpReq = new RFP_Support_Request__c();
           rfpReq.Opportunity__c = opp.Id;
           rfpReq.Account__c = acc.Id;
           insert rfpReq;
           
            Test.startTest();
            ApexPages.StandardController con = new ApexPages.StandardController(rfpReq);
            ctrlRFPSubmitReqHandler rfpSupp = new ctrlRFPSubmitReqHandler(con);
            rfpSupp.saveSubmit();
            Test.stopTest();       
              
       
       }
       
    
    
    static testMethod void testRFPRequestController()
       {
       
           TestUtil.setConfigValues();
           
           Account acc = TestUtil.createAccounts(1,true)[0];
           
           Opportunity opp = TestUtil.createOpportunities(1,acc.Id,true)[0];
           
           RFP_Support_Request__c rfpReq = new RFP_Support_Request__c();
           rfpReq.Opportunity__c = opp.Id;
           rfpReq.Account__c = acc.Id;
           insert rfpReq;
           
            Test.startTest();
            ApexPages.StandardController con = new ApexPages.StandardController(rfpReq);
            ctrlRFPSupportReqHandler rfpSupp = new ctrlRFPSupportReqHandler(con);
            rfpSupp.saveSubmit();
            rfpSupp.saveRFP();
            rfpSupp.cancelRFP();
            Test.stopTest();       
       
       
       
       }
       
    static testMethod void testRFPRequestFromOpportunity()
    {
    
          TestUtil.setConfigValues();
           
           Account acc = TestUtil.createAccounts(1,true)[0];
           
           Opportunity opp = TestUtil.createOpportunities(1,acc.Id,true)[0];
           
           RFP_Support_Request__c rfpReq = new RFP_Support_Request__c();
           rfpReq.Opportunity__c = opp.Id;
           rfpReq.Account__c = acc.Id;
           insert rfpReq;
           
           ApexPages.currentPage().getParameters().put('oppId',opp.Id);
            Test.startTest();
            ApexPages.StandardController con = new ApexPages.StandardController(rfpReq);
            ctrlRFPSupportReqHandler rfpSupp = new ctrlRFPSupportReqHandler(con);
            rfpSupp.saveSubmit();
            rfpSupp.saveRFP();
            rfpSupp.cancelRFP();
            Test.stopTest();       
       
    }   

}