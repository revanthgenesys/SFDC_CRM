/*
    Name           :    PartnerRabateTriggerHandler
    Author         :    
    Date           :    2 Jan 2015
    Description    :    Handler class for Trigger PartnerRabateTrigger
*/
public class PartnerRabateTriggerHandler {
    public static void beforeTrigger(List<Partner_Rebate__c> newPatnerList, Map<Id,Partner_Rebate__c> oldPartnerMap, Set<String> rebateYears, Set<string> partnerNames){
        map<string,list<Partner_Rebate__c>> rebateMap = new map<string,list<Partner_Rebate__c>>(); 
        map<string,Account> accountMap = new map<string,Account>();
        for(Partner_Rebate__c prebate: [SELECT id, Partner_Name__c, Rebate_Year__c FROM Partner_Rebate__c
          WHERE Rebate_Year__c in:rebateYears AND Partner_Name__c in:partnerNames]){        
              list<Partner_Rebate__c> prList = rebateMap.get(prebate.Partner_Name__c + prebate.Rebate_Year__c);
              if(prList == null)
                  prList = new list<Partner_Rebate__c>();
              prList.add(prebate);
              rebateMap.put(prebate.Partner_Name__c + prebate.Rebate_Year__c, prList);            
        }
        for(Account partnerAccount :[select id,name,OwnerId,(select id,name from Contacts 
            where Designated_Partner_Contact__c = true AND Email!=null AND Email!='') from Account where id in:partnerNames]){
                accountMap.put( partnerAccount.Id,  partnerAccount);                        
        }
        for(Partner_Rebate__c prebate: newPatnerList){
            //get the designated contact for the partner
            Account partnerAccount = accountMap.get(prebate.Partner_Name__c);                            
            if(partnerAccount !=null ){
                if(partnerAccount.Contacts != null && partnerAccount.Contacts.size() > 0){
                    Contact  partnerContact = partnerAccount.Contacts[0];
                    prebate.Partner_Designated_Contact__c=partnerContact.Id;
                }
            }
            list<Partner_Rebate__c> prList = rebateMap.get(prebate.Partner_Name__c + prebate.Rebate_Year__c);
            if(prList != null && ((trigger.IsInsert && prList.size()>0)||(trigger.IsUpdate && prList.size()>1))) {
                //Partner_Rebate__c newpr = prMap.get(pr.Rebate_Year__c);
                prebate.Rebate_Year__c.addError('A Rebate with this year and for Partner Name already exists.');
            }
            if(oldPartnerMap==null ||(oldPartnerMap!=null && oldPartnerMap.get(prebate.Id).Published_to_Partner_Portal__c<>prebate.Published_to_Partner_Portal__c)){
                if(prebate.Published_to_Partner_Portal__c==true)
                    prebate.Publish_Date__c=system.today();
                else{
                    prebate.Publish_Date__c=null;
                    prebate.Agree_Disagree_By__c=null;
                    prebate.Agree_Disagree_Flag__c=false;
                    prebate.Date_Agree_Disagree__c =null;
                    prebate.Disagreed__c =false;
                }
            }
        } 
    }
    public static void afterTrigger(List<Partner_Rebate__c>newPatnerList,Map<Id,Partner_Rebate__c>oldPartnerMap,Set<string>partnerNames){
        map<string,Account> accountMap = new map<string,Account>();
        for(Account partnerAccount :[select id,name,OwnerId,Owner.Email,TM_Acc_Country_Region__c,(select id,name from Contacts 
            where Designated_Partner_Contact__c = true) from Account where id in:partnerNames]){
                accountMap.put( partnerAccount.Id,  partnerAccount);                        
        }
        String templateName = '';
        for(Partner_Rebate__c prebate: newPatnerList){
            //get the designated contact for the partner
            Account partnerAccount = accountMap.get(prebate.Partner_Name__c); 
            Contact partnerContact ;                            
            if(partnerAccount !=null ){
                if(partnerAccount.Contacts != null && partnerAccount.Contacts.size() > 0){
                    partnerContact = partnerAccount.Contacts[0];
                }
            }
            if((oldPartnerMap==Null ||(oldPartnerMap!=null && 
                oldPartnerMap.get(prebate.Id).Published_to_Partner_Portal__c<>prebate.Published_to_Partner_Portal__c))
                && prebate.Published_to_Partner_Portal__c==true){
               	 // templateName='Partner Rebate Publish HTML Email Template';
               	 templateName='Partner Rebate Publish Email Template';
                 if(partnerContact!=null) 
                    sendEmail(templateName, prebate.Id, partnerContact.Id, partnerAccount);
                 //else 
                 //   prebate.addError('Designated Contact not defined for this account');
                    
            } 
            if((oldPartnerMap==null ||(oldPartnerMap!=null && 
                oldPartnerMap.get(prebate.Id).Publish_Earned_Amounts_to_Partner_Portal__c<>prebate.Publish_Earned_Amounts_to_Partner_Portal__c))
                && prebate.Publish_Earned_Amounts_to_Partner_Portal__c==true){
                    /*
                    //get the templatename by customsettings
                    Partner_Rebate_Region_Earned_Template__c partnerPortalrebate = Partner_Rebate_Region_Earned_Template__c.getValues(partnerAccount.TM_Acc_Country_Region__c);
                    templateName= partnerPortalrebate.Template_Name__c;    
                    if(templateName==null)
                        prebate.addError('Account Country or region is missing or check email template for this account');
                    
                    */
					templateName='Partner Earned Rebate Publish Email Template';
                    if(partnerContact!=null)
                        sendEmail(templateName,prebate.Id,partnerContact.Id,partnerAccount);
                    //else 
                    //    prebate.addError('Designated Contact not defined for this account');
                    
            }
        } 
        
    }
    
    public static List<Contact> getDesignatedContacts(String accountId){
        return [SELECT id, Name, accountId FROM Contact WHERE accountId =: accountId AND Designated_Partner_Contact__c = true and FirstName != 'Portal'];  
    }
    
    public static void  sendEmail(String templateName,Id whatId,Id targetObjId,Account partnerAccount){
        
        String sDisplayName='partners@genesys.com';
        
        EmailTemplate et = [Select id,HtmlValue from EmailTemplate where name=:templateName  Limit 1];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        String[] CCEmails ;
        if(partnerAccount.OwnerId!=null)
            CCEmails= new String[]{UserInfo.getUserEmail(), partnerAccount.Owner.Email,'partners@genesys.com'};
        else
            CCEmails= new String[]{UserInfo.getUserEmail(),'partners@genesys.com'};
            
        List<Contact> contacts = getDesignatedContacts(partnerAccount.id);      
        for(Contact eachContact : contacts){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                                    
            if(et!=null){               
                mail.setTemplateId(et.id);
                mail.setSaveAsActivity(false);
            }
            
            mail.setCCAddresses(CCEmails);
            mail.setreplyto(sDisplayName);
            mail.setSenderDisplayName(sDisplayName);
            mail.setWhatId(whatId);//Object Id
            mail.setTargetObjectId(eachContact.id);//contactid Lead or Userid
            
            emailList.add(mail);
        }
        
        if(emailList.size() > 0){
            if(!Test.isRunningTest())
            	Messaging.sendEmail( emailList, false );
        }
    }
}