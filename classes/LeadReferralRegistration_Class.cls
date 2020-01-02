public without sharing class LeadReferralRegistration_Class{

   public Lead_Referral_Registration__c leadReferralObj;  
    public Contact cnct {get;set;}
    private ApexPages.StandardController sController;  
    public String leadReferralObjId ;
    public Map<String,String> mapFieldLabelVsHelpText {get;set;}
    public List<SelectOption> channelManagerOptionList {get;set;}
    public String selectedChannelManagerId{get;set;}
    public Boolean isReadOnly {get;set;}
    public Boolean showError {get;set;}
    public LeadReferralRegistration_Class(ApexPages.StandardController controller) {
    
        try{
            isReadOnly = false;
            showError = false;
            sController = controller;
            
            leadReferralObjId = ApexPages.CurrentPage().getParameters().get('id');  
            mapFieldLabelVsHelpText = getMapOfFieldsAndHelpText();   
            
            String runAs = UserInfo.getUserId();
            if(ApexPages.CurrentPage().getParameters().get('ro') != null)
                isReadOnly = true;  
            if(ApexPages.CurrentPage().getParameters().get('runAs') != null)
              runAs = ApexPages.CurrentPage().getParameters().get('runAs');
              
            User currentUser = [SELECT ContactId,email,AccountId FROM User where id =:runAs];
            Contact userContact = [Select AccountId,Name,Title,Email,Legacy_Company_Name__c from Contact where id =:currentUser.ContactId ];
            Account currentAccount = [SELECT AccountNameNative__c,Owner.Id, Owner.IsActive, Country__r.Region__c FROM Account where Id =:userContact.AccountId];
            
            leadReferralObj = (Lead_Referral_Registration__c)controller.getRecord();
          
            
            if (currentAccount.Owner.Id == null || currentAccount.Owner.IsActive != true) {
          Partner_Portal_Settings__c partnerPortalLeadReferralSetting = Partner_Portal_Settings__c.getValues('Janelle Mertens');  
          leadReferralObj.Channel_Manager__c = partnerPortalLeadReferralSetting.Id_Value__c;
        }
        else {
          leadReferralObj.Channel_Manager__c = currentAccount.Owner.Id;
        } 

            
            leadReferralObj.Status__c = 'Request Submitted';
            leadReferralObj.Account__c = userContact.AccountId; 
            leadReferralObj.Your_Title__c = userContact.Title;
            leadReferralObj.Your_Name__c =  userContact.Name;
            leadReferralObj.Your_Email__c = userContact.Email;
            leadReferralObj.Regions__c = currentAccount.Country__r.Region__c;           
            leadReferralObj.Your_Company_Name__c = currentAccount.AccountNameNative__c;
        
            if(leadReferralObjId != null){
                Lead_Referral_Registration__c leadReferralRegi = [SELECT Account__c, Status__c FROM Lead_Referral_Registration__c WHERE id =: leadReferralObjId];      
                leadReferralObj.Status__c = leadReferralRegi.Status__c;
                if(leadReferralRegi.Account__c != userContact.AccountId){
                    showError = true;           
                }       
            }   
        }
        catch(Exception e){
            System.debug('****Exception'+e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception occured'+e.getMessage()));
        }
    }
    public PageReference saveleadReferralObj() {  
        try{
        
            if(leadReferralObj.Channel_Manager__c == null ){
                Partner_Portal_Settings__c partnerPortalLeadReferralSetting = Partner_Portal_Settings__c.getValues('Janelle Mertens');
                String channelManagerId;
                
                if(partnerPortalLeadReferralSetting!=null){
                    channelManagerId = partnerPortalLeadReferralSetting.Id_Value__c;
                }
                
                if(channelManagerId!=null){
                    leadReferralObj.Channel_Manager__c  = channelManagerId;
                }
            }
            
            if(leadReferralObjId != null && leadReferralObjId !=''){
             update leadReferralObj;   
            } else {
                Integer noOfDaysToExpire = 364;
                if(PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig') != NULL)
                    noOfDaysToExpire = (Integer)PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig').No_of_Days_To_Expire__c;        
                
                leadReferralObj.End_Date__c = Date.today().addDays(noOfDaysToExpire);      
                insert leadReferralObj;
                submitLeadToApprovalProcess(leadReferralObj); 
            }     
        }
        catch(Exception e){
            System.debug('****Exception'+e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception occured'+e.getMessage()));
        }
        PageReference pr = new PageReference('/partner/apex/Home');  
        return pr;
        
    }
        
    public PageReference cancelleadReferralObj() {     
        PageReference pr = new PageReference('/partner/apex/Home');  
        return pr;
    }
    
    public static void submitLeadToApprovalProcess(Lead_Referral_Registration__c newApplication){
    //public static void submitLeadToApprovalProcess(string newApplication){
        
        System.debug('*****submitPartnerApplicationToApprovalProcess');

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Request submitted for approval automatically.');
        req.setObjectId(newApplication.id);
        //req.setObjectId(newApplication);
        
        Partner_Portal_Settings__c partnerPortalApprovalSetting = Partner_Portal_Settings__c.getValues('LeadReferralApprovalProcess');
        String approvalProcessName= partnerPortalApprovalSetting.Id_Value__c;
           
        //System.debug('*****newApplication.Channel_Manager__c: '+newApplication.Channel_Manager__c);
        //System.debug('*****newApplication.id: '+newApplication.id);
        //System.debug('*****newApplication.name: '+newApplication.name);

        
        Approval.ProcessResult result = Approval.process(req);
        
    }
 
    
     public static Map<String,String> getMapOfFieldsAndHelpText(){
        String objName ='Lead_Referral_Registration__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String, String> mapFieldLabelVsHelpText = new Map<String, String>();
        for (String fieldName: fieldMap.keySet()) {
            String label = fieldMap.get(fieldName).getDescribe().getLabel();
            String helpText = fieldMap.get(fieldName).getDescribe().getInlineHelpText();
            if(helpText == null || helpText == '')
                helpText = label;
            mapFieldLabelVsHelpText.put(label, helpText);
            }   
        return mapFieldLabelVsHelpText;
    }  
           
}