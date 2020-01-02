/*
Created On: 04-MAY-2018
Created By: Mukunthan Koothan
Purpose: Test class for DealRegApproveRejectController
*/
@isTest
public class DealRegApproveRejectControllerTest{
    
    static testmethod void approveRecTest(){
        Test.StartTest();
            User currUser = [Select Id, Name, Bypass_Triggers__c from User where ID=:userinfo.getuserid()];
            currUser.Bypass_Triggers__c = true;
            System.runAs(currUser){
                recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
                
                Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
                insert a1;
                
                partner_portal_prospect__c ppp = new partner_portal_prospect__c();
                ppp.Name = 'TestRec';
                ppp.Status__c = 'Request Submitted';
                ppp.End_User_Account__c = a1.Id;
                ppp.What_is_the_Expected_Close_Date__c = Date.Today() + 30;
                ppp.Opportunity_Channel_Manager__c = currUser.Id;
                insert ppp;
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(ppp.Id);
                Approval.ProcessResult processResult = Approval.process(req);
                System.assertEquals('Pending', processResult.getInstanceStatus());
                
                PageReference testPage = Page.DealRegApproveReject;
                Test.setCurrentPage(testPage);
                testPage.getParameters().put('recid',ppp.Id);
                testPage.getParameters().put('step','Channel_Manager');
                
                DealRegApproveRejectController custAppr = new DealRegApproveRejectController();
                custAppr.rejectReason = 'RFP not considered incremental';
                custAppr.approveRec();
                custAppr.rejectReason = '--None--';
                custAppr.approveRec();
                custAppr.getRejectionReason();
                custAppr.cancelRec();
                            
            }
        
        Test.stopTest();
    }
    
    static testmethod void rejectRecTest(){
        Test.StartTest();
            User currUser = [Select Id, Name, Bypass_Triggers__c from User where ID=:userinfo.getuserid()];
            currUser.Bypass_Triggers__c = true;
            System.runAs(currUser){
                recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
                
                Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
                insert a1;
                
                partner_portal_prospect__c ppp = new partner_portal_prospect__c();
                ppp.Name = 'TestRec';
                ppp.Status__c = 'Request Submitted';
                ppp.End_User_Account__c = a1.Id;
                ppp.What_is_the_Expected_Close_Date__c = Date.Today() + 30;
                ppp.Opportunity_Channel_Manager__c = currUser.Id;
                insert ppp;
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(ppp.Id);
                Approval.ProcessResult processResult = Approval.process(req);
                System.assertEquals('Pending', processResult.getInstanceStatus());
                
                PageReference testPage = Page.DealRegApproveReject;
                Test.setCurrentPage(testPage);
                testPage.getParameters().put('recid',ppp.Id);
                testPage.getParameters().put('step','Channel_Manager');
                
                DealRegApproveRejectController custAppr = new DealRegApproveRejectController();
                custAppr.rejectReason = '--None--';
                custAppr.rejectRec();
                custAppr.rejectReason = 'Other';
                custAppr.rejectRec();
                custAppr.rejectReason= 'RFP not considered incremental';
                custAppr.rejectRec();
            }
        
        Test.stopTest();
    }
    
}