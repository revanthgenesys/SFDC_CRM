public with sharing class ctrlRFPSupportReqHandler {

    public RFP_Support_Request__c objRFP {
        get;
        set;
    }
    public Opportunity opp {
        get;
        set;
    }
    public Boolean bCheck{get;set;}
    public String ownerEmail = '';
    public Id targetId;

    public ctrlRFPSupportReqHandler(ApexPages.StandardController controller) {
        objRFP = (RFP_Support_Request__c) controller.getRecord();
        init();
    }

    public void init() {
        if (ApexPages.currentPage().getParameters().containsKey('oppId') && (ApexPages.currentPage().getParameters().get('oppId') != null || ApexPages.currentPage().getParameters().get('oppId') != '')) {
            opp = [Select Id, Name,CurrencyIsoCode, Country_Region__c,AccountId, CloseDate, OwnerId, Amount, Direct_Sales__c, BusinessPartner__c, Owner.Email,Proposal_Manager__c,Technical_Writer__c from Opportunity where Id = : ApexPages.currentPage().getParameters().get('oppId')];
            objRFP.Opportunity__c = opp.Id;
            objRFP.Account__c = opp.AccountId;
            objRFP.Close_Date__c = opp.CloseDate;
            objRFP.Opportunity_Owner__c = opp.OwnerId;
            objRFP.Sold_To_Business_Partner__c = opp.BusinessPartner__c;
            objRFP.Direct_Sales__c = opp.Direct_Sales__c;
            objRFP.Total_Amount__c = opp.Amount;
            objRFP.CurrencyIsoCode = opp.CurrencyIsoCode;
            //objRFP.Proposal_Manager__c = opp.Proposal_Manager__c;
           //objRFP.Technical_Writer__c = opp.Technical_Writer__c;
            //objRFP.Deal_Stage_At_Queue_Entry__c = opp.StageName;
            ownerEmail = opp.Owner.Email;
            targetId = opp.Owner.Id;
        
        } else {
            objRFP = [Select Direct_Sales_1__c,Total_Amount_1__c,of_Technical_Questions__c,Proposal_Outcome_1__c,Proposal_Outcome__c,Override_Proposal_Outcome__c ,Account__c,Name,Opportunity__r.OwnerId,Opportunity__r.Owner.Email,SaveSubmitCheck__c,Total_Amount__c,Opportunity__c,Close_Date__c,
                        Opportunity_Owner__c,Direct_Sales__c,Sold_To_Business_Partner__c,Document_Type__c,MNDA_Executed__c,Date_Received__c,Due_Date__c,Extension_Due_Date__c,Decision_Date__c,Solution_Engineer_Name__c,
                        Additional_Resources__c,Deliverable__c,No_of_Questions__c,Deployment_Model__c,Solution_Type__c,Additional_Details__c,Genesys_Influence__c,Existing_Customer__c,How_do_we_rate_vs_competition__c,
                        Percentage_Solution_Fit__c,Proposal_Status__c,Proposal__c,Proposal_Manager__c,Opportunity__r.Country_Region__c,Carahsoft_Passthrough__c,Additional_Resource__c,
                        Status_Comment__c, Response_Strategy__c ,Primary_DSR__c,First_Pass_Complete__c,First_Pass_Date_Completed__c,Submitted__c,language__c,URL__c,username__c,password__c,Date_RFP_Issued__c,Reason_No_TW__c,Outcome_Reason__c,technical_writer__c,Questions_Influenced__c from RFP_Support_Request__C where id = : objRFP.Id];
            Profile pr = [SELECT Id,Name from Profile where Id = : UserInfo.getProfileId()];
            if(pr.Name.equalsIgnoreCase('System Administrator') || pr.Name.equalsIgnoreCase('Gen - SalesOps Read Only') || pr.Name.equalsIgnoreCase('GEN - Solution Engineer') || pr.Name.equalsIgnoreCase('Regional Sales Ops') || pr.Name.equalsIgnoreCase('Regional Sales Ops (Edit all)'))
            {
               bCheck = false;
               }
               else { 
                if(objRFP.SaveSubmitCheck__c || objRFP.Submitted__c){
                    bCheck = true;
                }
               else { 
                 bCheck = false;
               }
               
            }
            ownerEmail = objRFP.Opportunity__r.Owner.Email;
            targetId = objRFP.Opportunity__r.OwnerId;
        }
    }

    public Pagereference saveSubmit() {
        boolean check = false;
        List < RFP_Support_Request__c > lstRFP = new List < RFP_Support_Request__c > ();
        
        if(!objRFP.SaveSubmitCheck__c || !objRFP.Submitted__c  ) {
         objRFP.SaveSubmitCheck__c = true;
         objRFP.Submitted__c = true;
         check = true;
        }
      
        lstRFP.add(objRFP);

        if (lstRFP.size() > 0) {
            List < Database.UpsertResult > sr = Database.Upsert(lstRFP, false);
            if (sr[0].isSuccess()) {
                String templateApiName = 'RFP_Proposal_Manager_Notification';
                List < String > toRecipients = new List < String > {
                    //ownerEmail,'rfpcentral@genesys.com'
                   'Kevin.Colliton@genesys.com','vikram.sharma@genesys.com'
                };
               
                Id templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(toRecipients);
                email.setTemplateId(templateId);
                email.setTargetObjectId(targetId);
              
                email.setsaveAsActivity(false);
               
                //if(check) 
               //  Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                //    email
               // });

                Pagereference pg = new Pagereference('/' +lstRFP[0].Id);
                pg.setRedirect(true);
                return pg;
            }
        }
        return null;
    }

    public Pagereference saveRFP() {
        List < RFP_Support_Request__c > lstRFP = new List < RFP_Support_Request__c > ();
        lstRFP.add(objRFP);

        if (lstRFP.size() > 0) {
            List < Database.UpsertResult > sr = Database.upsert(lstRFP, false);
            system.debug('Check::'+lstRFP[0]+'uufahds'+lstRFP[0].Id);
            Pagereference pg = new Pagereference('/'+lstRFP[0].Id);
            pg.setRedirect(true);
            return pg;
         }
        return null;
    }

    public Pagereference cancelRFP() {
        if (ApexPages.currentPage().getParameters().containsKey('oppId')) {
            Pagereference pg = new Pagereference('/' + ApexPages.currentPage().getParameters().get('oppId'));
            pg.setRedirect(true);
            return pg;
        } else {
            Pagereference pg = new Pagereference('/' + ApexPages.currentPage().getParameters().get('id'));
            pg.setRedirect(true);
            return pg;
        }
    }
}