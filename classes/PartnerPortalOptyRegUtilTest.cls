/*
Created By: Mukunthan Koothan
Created On: 23-APR-2018
Purpose: Test class for PartnerPortalOptyRegUtil class
*/
@isTest
public class PartnerPortalOptyRegUtilTest{

    public static testmethod void fetchSalesLeadTest(){

        Test.startTest();
        
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
                
                List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId 
                                                            FROM ProcessInstanceWorkitem 
                                                            WHERE ProcessInstance.TargetObjectId = :ppp.Id];
                List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
                for(ProcessInstanceWorkitem workItem : workItems){
                Approval.ProcessWorkitemRequest req1 = new Approval.ProcessWorkitemRequest();
                req1.setWorkitemId(workItem.Id);
                req1.setAction('Approve');
                req1.setNextApproverIds(new Id[] {currUser.Id});
                req1.setComments('Your Comment.');
                requests.add(req1);
                }
                Approval.ProcessResult[] processResults = Approval.process(requests);
                
                //if(ppp.Status__c == 'Request Submitted' && ppp.Channel_Manager_Approved__c ==true){
                    PartnerPortalOptyRegUtil.fetchSalesLead(new string[] {ppp.Id});
                //}
            }
        Test.stopTest();
    
    }
    
    
    
public static testmethod void fetchoppsTest(){
        Test.startTest();
        
            User currUser = [Select Id, Name, Bypass_Triggers__c from User where ID=:userinfo.getuserid()];
            currUser.Bypass_Triggers__c = true;
            System.runAs(currUser){
                recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
                
                Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ',Ownerid = userinfo.getuserid()); 
                insert a1;
                
                recordtype rc1 = [select id, Name from recordtype where name = 'Cloud Renewal'  limit 1];
                
                Opportunity  oppt = new Opportunity();
                oppt.Name = 'TestRec';               
                oppt.Accountid =  a1.id; 
                oppt.ownerid = userinfo.getuserid();
                oppt.CSM_GA_Opportunity_Owner__c =   userinfo.getuserid();            
                oppt.CloseDate  = Date.Today() + 30;
                oppt.StageName = '6.Closed';
                oppt.ForecastStatus__c = '0.Booked';
                oppt.RecordTypeid  = rc1.id;
                oppt.Lead_Offer__c ='PureEngage Premise';
                insert oppt;     
                list<opportunity> lstop = new list<opportunity> ();
                lstop.add(oppt);
                oppt.ForecastStatus__c = '1.In Hand';
                oppt.ownerid = userinfo.getuserid();
                update oppt;
                Map<id, Opportunity> mapop = new Map<id, Opportunity>();
                mapop.put(oppt.id,oppt );
                
                    global_setting__c cs = new global_setting__c();
                    cs.ID__c= rc1.id;
                    cs.Information__c= 'test';
                    cs.Type__c = 'test';
                    cs.Name = 'Cloud Renewal Opty recordtype';
                    insert cs;
                
                OpportunityTeamMember opptm = new OpportunityTeamMember();
                opptm.OpportunityId = oppt.id;
                opptm.UserId = oppt.ownerid;
                opptm.OpportunityAccessLevel = 'Edit';
                opptm.TeamMemberRole = 'Opportunity Owner';
                insert opptm;
                
               // PartnerPortalOptyRegUtil.updateopportunityclosedate(lstop , mapop );    
                PartnerPortalOptyRegUtil.updateopportunityteammember(lstop , mapop, 'insert' );
                
                PartnerPortalOptyRegUtil.updateopportunityteammember(lstop , mapop, 'update' );
                
                
                
            }
        Test.stopTest();
    } 
    }