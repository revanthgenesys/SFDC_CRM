/**
    * Description: Class to be used to display Partner Rebate terms Page
    * Created:12/18/2014
    */
public without sharing  Class PartnerRebateController{
    public  Partner_Rebate__c prebate {get;set;}
    public boolean isERPublished {get;set;}
    Account partnerAccount{get;set;}
    Contact partnerContact{get;set;}
    public boolean isExpired{get;set;}
    Public List<Partner_Rebate__c> PRebateList{get; set;}
    Public Boolean FlagYes {get; set;}
    public Boolean viewOnly {get; set;}
    
    public PartnerRebateController(PartnerPortal_PeriodicReview_Class controller) {
        User currentUser = new User();
        //String userId = ApexPages.currentPage().getParameters().get('runAs');
        //System.debug('>>>>>>>userId:: ' + userId);
        
        System.debug('>>>>>>>Userinfo.getUserId():: ' + Userinfo.getUserId());
        currentUser = [SELECT id,contactId, Contact.AccountId, Contact.Designated_Partner_Contact__c FROM User where id =:Userinfo.getUserId()];
        System.debug('>>>>>>>currentUser:: ' + currentUser);
        
        System.debug('>>>>>>>system.today().year():: ' + system.today().year());
        String syear=''+system.today().year();
        
        System.debug(System.Today().Year().format()+'>>>>>>>'+currentUser.Contact.AccountId );
        
        
        PRebateList = new List<Partner_Rebate__c>();
        
        if (currentUser.Contact.Designated_Partner_Contact__c == true){
        PRebateList = [select id,Rebate_Name__c,Start_Date__c,End_Date__c,Amount__c,SaaS_Amount__c,License_Amount__c,Type__c,
                        Status__c,Earned_Genesys_Care_Amount__c,
                        Earned_License_Amount__c,
                        Earned_SaaS_Amount__c,
                        Publish_Earned_Amounts_to_Partner_Portal__c,
                       	CurrencyIsoCode  
                        from Partner_Rebate__c 
                        where Status__c = 'Active' and 
                        Published_to_Partner_Portal__c = true 
                        and Agree_Disagree_Flag__c=true 
                        AND Rebate_Year__c=:syear
                        AND Partner_Name__c=:currentUser.Contact.AccountId];
                        
        System.debug('>>>>>>>PRebateList.size():: ' + PRebateList.size());
        }
        
        if(PRebateList.size() > 0){
            prebate=PRebateList[0];
            FlagYes = true; 
            if( prebate.Publish_Earned_Amounts_to_Partner_Portal__c==true)  isERPublished=true;       
        }
        
    }    
    public PartnerRebateController(ApexPages.StandardController controller) {
        String pRebateId = controller.getId();
        viewOnly = false;
        if(ApexPages.currentPage().getParameters().get('viewonly') != NULL)
            viewOnly = true;
        
        List<Partner_Rebate__c> pRebateList = [select id,Partner_Name__c,Partner_Name__r.Name,
                                    Published_to_Partner_Portal__c,Publish_Date__c,Active_Days__c,
                                    Rebate_Year__c,Date_Agree_Disagree__c, Agree_Disagree_By__c, 
									Amount__c,License_Amount__c,Saas_Amount__c,CurrencyIsoCode,
									Disagreed__c, Agree_Disagree_Flag__c
                                    from Partner_Rebate__c where id=:pRebateId limit 1];
        if(pRebateList!=null && pRebateList.size()>0){
            prebate = pRebateList[0];
            System.debug('*****prebate'+prebate);
            if(viewOnly == false){
                if(prebate.Published_to_Partner_Portal__c && prebate.Active_Days__c!=null && prebate.Active_Days__c>0 && prebate.Publish_Date__c!=null){
                    Integer NumberOfDays = prebate.Publish_Date__c.daysBetween(System.today());
                    System.debug('*****NumberOfDays'+NumberOfDays);
                    
                    if(NumberOfDays>prebate.Active_Days__c){
                        System.debug('****Add error message');
                        isExpired=true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Rebate is expired. Please contact your Channel Manager'));
                    }
                    if(prebate.Date_Agree_Disagree__c!=null){
                       isExpired=true;
                       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This rebate agreement has already been processed. Please check with Genesys Channel Manager for further assistance.'));
                    }
                }
            }
            List<Account> partnerAccountList = [select id,name,Channel_Manager__c,Channel_Manager__r.Email,(select id, name, accountId from Contacts where Designated_Partner_Contact__c = true) from Account where id =: prebate.Partner_Name__c limit 1];
            if(partnerAccountList !=null && partnerAccountList.size()>0){
                partnerAccount = partnerAccountList[0];
                System.debug('*****partnerAccount'+partnerAccount);
                if(partnerAccount.Contacts != null && partnerAccount.Contacts.size() > 0){
                    partnerContact = partnerAccount.Contacts[0];
                } 
                System.debug('*****partnerContact'+partnerContact);               
            }
        }              
    }

     public PageReference saveTermsWithAgree(){
         try{
             prebate.Agree_Disagree_Flag__c = true;
             prebate.Disagreed__c = false;
             prebate.Date_Agree_Disagree__c = system.Today();
             update prebate;
             sendEmail(true);
         }catch(Exception ex){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex + ' Please Contact with Genesys Support for further assistance.'));
              return null;
         }
         
         PageReference pRef = new PageReference('/partner/apex/Home');
         return pRef;        
     }
     public PageReference saveTermsWithDisagree(){
         try{
             prebate.Disagreed__c = true;
             prebate.Agree_Disagree_Flag__c = false;
             prebate.Date_Agree_Disagree__c = system.Today();
             update prebate;
             sendEmail(false);
         }catch(Exception ex){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex + ' Please Contact with Genesys Support for further assistance.'));
              return null;
         }
         
         PageReference pRef = new PageReference('/partner/apex/Home');
         return pRef;          
     }
     
     private void sendEmail(boolean agreed){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String sDisplayName='partners@genesys.com';
        Messaging.SingleEmailMessage mail;
        String templateName='Partner Rebate Program Disagree HTML Template';
        if(agreed)templateName='Partner Rebate Acceptance Template';//'Partner Rebate Email Contact Confirmation Template';
        if(partnerContact!=null){
            List<Contact> contacts = PartnerRabateTriggerHandler.getDesignatedContacts(partnerContact.accountId);
            String[] emailIds=new String[]{partnerAccount.Channel_Manager__r.Email,'partners@genesys.com'};
            for(Contact eachContact : contacts){
                mail = new Messaging.SingleEmailMessage();               
                EmailTemplate et = [Select id from EmailTemplate where name=:templateName  Limit 1];  
                          
                if(et!=null){
                    mail.setTemplateId(et.id);
                    mail.setSaveAsActivity(false);
                }
                mail.setWhatId(prebate.Id);
                mail.setTargetObjectId(eachContact.Id);
                mail.setCcAddresses(emailIds);
                mail.setreplyto(sDisplayName);
                mail.setSenderDisplayName(sDisplayName);
                System.debug(emailIds+'*****mail'+mail);
                mails.add(mail);
            }
        }
        
       
        if(mails!=null && mails.size()>0){
            //Messaging.SendEmailResult[] sendEmailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            Messaging.SendEmailResult[] sendEmailResult = Messaging.sendEmail( mails );         
            System.debug('*****sendEmailResult'+sendEmailResult);
        }
     }
  /**
    * Description: Method to return back to Original object/page.
    * Return: Pagereference
    */
    public Pagereference doCancel(){
       /* ApexPages.Action cancelAction = new ApexPages.Action('{!cancel}');
        return cancelAction.invoke();
        */
        PageReference pRef = new PageReference('/partner/apex/Home');
        return pRef;  
    }
}