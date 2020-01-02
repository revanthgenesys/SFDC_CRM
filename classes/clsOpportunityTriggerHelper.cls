/*
Pankaj Kr Pandey
Cloud Deployment Autocreation
12/04/2017    
Description   : Class is called from Opportunity trigger (after update) to create the Cloud Deployment record and send the mailer to list of related user.
*/
public without sharing class clsOpportunityTriggerHelper {

    public static void CreateCloudDeployment(Map < Id, Opportunity > newMapOpportunity, Map < Id, Opportunity > oldMapOpprtuity) {
    
        Set<Id> accountIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Set<String> cldName = new Set<String>();
        Set<String> cldName1 = new Set<String>();
        Map<ID, String> mapOpp = new Map<ID, String>();
        //Get the RecordtypeId.Updated by Rony Joseph on June 21 2018 to include Cloud Renewal Recordtype
        Map<Id,RecordType> recIdList = new Map<Id,RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Opportunity' AND Name in ('GEN - Opportunity Record Type','Cloud Renewal')]);
        /*Id OppRecId;
        if(recIdList != null && recIdList.size() > 0){
            OppRecId = recIdList.get(0).Id;
        }*/
        
        //Looping over each Opportunity to get the Account Id and Opportunity
        for(Opportunity eachOpp : newMapOpportunity.values()){      
            if(eachOpp.StageName != oldMapOpprtuity.get(eachOpp.Id).StageName || eachOpp.Win_Loss_Status__c != oldMapOpprtuity.get(eachOpp.Id).Win_Loss_Status__c 
                    || eachOpp.ForecastStatus__c != oldMapOpprtuity.get(eachOpp.Id).ForecastStatus__c || eachOpp.Primary_Line_of_Business__c != oldMapOpprtuity.get(eachOpp.Id).Primary_Line_of_Business__c
                    || eachOpp.Lines_Of_Businesses__c != oldMapOpprtuity.get(eachOpp.Id).Lines_Of_Businesses__c){
                accountIds.add(eachOpp.accountId);
                oppIds.add(eachOpp.id);                 
            }
        }
        
        if(oppIds.size() > 0){          
            Map <ID, Account> mapAccountIdObj = new MAP<ID, Account>([Select ID, Name,OwnerId, CSM_Account_Owner__c, CSM_Account_Owner__r.Email, Owner.Email from Account where Id IN: accountIds]);
            System.debug('This Is Cloud name PP====='+cldName);
            //Create a record for the Cloud Deployment if condition match for the Opportunity

            List <Contact> cont = new List<Contact>();
            List < Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage > (); 
            Set<Id> OpportunityWithCloud = new Set<ID>();
            for(Cloud_Deployment__c cdep : [Select id,Opportunity__c,Cloud_Offering__c,Cloud_Platform__c, Name, Offering_Detail__c  from Cloud_Deployment__c where Opportunity__c IN : oppIds]){
                      OpportunityWithCloud.add(cdep.Opportunity__c);
            }
            for(Cloud_Deployment__c cdep : [Select id,Opportunity__c,Cloud_Offering__c,Cloud_Platform__c, Name, Offering_Detail__c  from Cloud_Deployment__c where Account__c IN : accountIds]){
                  cldName.add(cdep.Cloud_Platform__c+','+cdep.Offering_Detail__c);// Assign the Opportunity ID and its Offering Detail   
            }
            
            String[] emailarr;
            emailarr = String.valueof(Label.CloudDeploymentEmail).split(';');
            String templateName = 'CloudDeploymentName';
            String theTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = : templateName].Id;
            String sDisplayName = 'customercare@genesys.com';
            Integer counter = 0;
            List < Cloud_Deployment__c > cldDeploy = new List < Cloud_Deployment__c > ();
            System.debug('PP Print Opp Id=====PP===='+OpportunityWithCloud);
            Cloud_Deployment__c cDeploy = new Cloud_Deployment__c();
            for (Opportunity opp: newMapOpportunity.values()) {
                System.debug('PP Print Opp Id=====PP===='+opp.id);
                String str;
                if(!OpportunityWithCloud.contains(opp.id) )
                {
                    if(opp.Lines_of_Businesses__c != null || opp.Lines_of_Businesses__c != ''){
                      str = opp.Lines_of_Businesses__c ;  
                    }
                    if(opp.Offering_Detail__c != null || opp.Offering_Detail__c != ''){
                      str = str +','+opp.Offering_Detail__c;
                    }
                    if(!cldName.contains(str)){
                    if((opp.StageName == '6.Closed') && (opp.Win_Loss_Status__c == 'Won') && (opp.ForecastStatus__c == '0.Booked') 
                        && (opp.Primary_Line_of_Business__c == 'Cloud') && (opp.Lines_Of_Businesses__c == 'PureCloud') && recIdList.containsKey(opp.recordTypeId)){
                        System.debug('PP Cloud Deployment Condition meet');
                        cDeploy.Name = mapAccountIdObj.get(opp.AccountId).Name + '-' + opp.Lines_of_Businesses__c+','+opp.Offering_Detail__c;
                        cDeploy.Cloud_Offering__c = Opp.Primary_Line_of_Business__c;        
                        cDeploy.Cloud_Platform__c = Opp.Lines_of_Businesses__c;
                        cDeploy.Status__c = 'Production';
                        cDeploy.Support_status__c = 'Order Processing';
                        cDeploy.Account__c = opp.AccountId;
                        cDeploy.Care_level__c = 'PureCloud Standard';
                        cDeploy.CSM_Owner__c = mapAccountIdObj.get(opp.AccountId).CSM_account_Owner__c;
                        cDeploy.Sold_to_Account__c = (opp.BusinessPartner__c != null)? opp.BusinessPartner__c : opp.AccountId;
                        cDeploy.Opportunity__c = opp.Id;
                        cDeploy.Email_Alias__c = mapAccountIdObj.get(opp.AccountId).CSM_Account_Owner__r.Email + ';' + mapAccountIdObj.get(opp.AccountId).Owner.Email;
                        cDeploy.Offering_Detail__c = opp.Offering_Detail__c;
                        cldDeploy.add(cDeploy);
                        
                        Contact contObj = new Contact();
                        contObj.firstName = 'Pankaj';
                        contObj.lastName = 'P' + counter;
                        //contObj.email = (mapAccountIdObj.get(opp.AccountId).CSM_Account_Owner__r.Email != null) ? mapAccountIdObj.get(opp.AccountId).CSM_Account_Owner__r.Email : 'test@test.com'  ;
                        String formattedDate = string.valueof(datetime.now());
                        formattedDate=formattedDate.replace('-','').replace(':','').replace(' ','');
                        //system.debug('####'+formattedDate);
                        contObj.email = 'testemail'+formattedDate+'@test'+formattedDate+'.com';
                        cont.add(contObj);
                        counter++;
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setSaveAsActivity(false);
                        mail.setTemplateId(theTemplate);
                        mail.setInReplyTo(sDisplayName);
                        //mail.setWhatId(cDeploy.Id);
                        //mail.setTargetObjectId(contObj.Id);
                        mail.setToAddresses(emailarr); //add other emails here.
                        emails.add(mail);
                    }
                    }
                }
            }
            if (cldDeploy.size() > 0) {
                insert cldDeploy;
                insert cont;
                for(Integer indexloop = 0; indexloop < cldDeploy.size(); indexloop++ ){
                    emails.get(indexloop).setWhatId(cldDeploy.get(indexloop).Id);
                    emails.get(indexloop).setTargetObjectId(cont.get(indexloop).Id); 
                }
                Messaging.sendEmail(emails);
                System.debug('PP Contact size=='+cont.size());
                                System.debug('PP Contact =='+cont);
                Contact[] conto = [Select Id from Contact where Id = : cont];
                try {
                    delete conto;
                } 
                catch (DmlException e) {
                    System.debug('Record not deleted.');
                }
            }
        }
    }
}