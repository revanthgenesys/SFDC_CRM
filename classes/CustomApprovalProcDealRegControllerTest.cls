/*
Created By: Mukunthan Koothan
Created On: 25-APR-2018
Purpose: Test class for CustomApprovalProcDealRegController and CustomApprovalProcExpEtnController
*/
@isTest
public class CustomApprovalProcDealRegControllerTest{

    static testmethod void customApprHistoryTest(){
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
                
                PageReference testPage = Page.CustomApprovalProcDealReg;
                Test.setCurrentPage(testPage);
                testPage.getParameters().put('id',ppp.Id);
                            
                ApexPages.StandardController Std_Con = new ApexPages.standardController(ppp);
                            
                CustomApprovalProcDealRegController custAppProc = new CustomApprovalProcDealRegController(Std_Con);
            }
        
        Test.stopTest();
    }
    
    static testmethod void customExpExtnApprHistoryTest(){
        Test.startTest();
            User currUser = [Select Id, Name, Bypass_Triggers__c from User where ID=:userinfo.getuserid()];
            currUser.Bypass_Triggers__c = true;
            System.runAs(currUser){
                recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
                
                Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
                insert a1;
                
                partner_portal_prospect__c ppp = new partner_portal_prospect__c();
                ppp.Name = 'TestRec';
                ppp.Status__c = 'Approved';
                ppp.End_User_Account__c = a1.Id;
                ppp.Proposed_End_Date__c = Date.today() + 30;
                ppp.What_is_the_Expected_Close_Date__c = Date.Today() + 30;
                ppp.Opportunity_Channel_Manager__c = currUser.Id;
                insert ppp;
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(ppp.Id);
                /*
                Approval.ProcessResult processResult = Approval.process(req);
                System.assertEquals('Pending', processResult.getInstanceStatus());
                
                PageReference testPage = Page.CustomApprovalProcExpExtn;
                Test.setCurrentPage(testPage);
                testPage.getParameters().put('id',ppp.Id);
                            
                ApexPages.StandardController Std_Con = new ApexPages.standardController(ppp);
                            
                CustomApprovalProcExpEtnController custAppProc = new CustomApprovalProcExpEtnController(Std_Con);
				*/
            }
        
        Test.stopTest();
    }

}