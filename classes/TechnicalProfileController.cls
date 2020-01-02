/*
    Created By:            Navaneetha Krishnan
    Created On:            14/Nov/2018
    */
    public class TechnicalProfileController{

    
        Public  Technical_Profile__c objtech{get;set;}
        public String strAccountId{get; set;}  
        public String strTechprofileid{get;set;}
        
        
        
    public TechnicalProfileController(ApexPages.StandardController controller) {
    
             objtech = new Technical_Profile__c ();
             strAccountId = ApexPages.currentPage().getParameters().get('accId');
             strTechprofileid = ApexPages.currentPage().getParameters().get('id');
             if(strTechprofileid != null)             
             {
             objtech = [Select id, Name, Technical_Profile_Acknowledgment_Date__c, Account__c,Account__r.Name,Validation_Box__c,Contact_Center__c,
                          Contact_Center_Specify_Others__c,Contact_Center_Specific_Requests__c, Unified_Communication__c, Unified_Communications_Specify_Others__c ,
                          Unified_Communications_Specific_Request__c, Digital_Channels__c,Digital_Channels_Specify_Other__c,Digital_Channels_Specific_Requests__c,
                          Infrastructure_Deployment_Model__c,Genesys_Routing_Role__c,WEM_Solution__c,WEM_Solution_Specify_Others__c,WEM_Solution_Specific_Requests__c,Predictive_Journey_Analytics__c,
                          Predictive_JA_Specify_Others__c,Predictive_JA_Specific_Requests__c,CRM_Vendors__c,CRM_Vendor_Specify_Others__c, CRM_Vendor_Specific_Requests__c,Voice_IVR_Vendor__c,
                          Voice_IVR_Vendor_Specify_Others__c,Voice_IVR_Vendor_Specific_Requests__c,Voice_Chat_Bots__c,Voice_Chat_Bots_Specify_Others__c,Voice_Chat_Bots_Specific_Requests__c,Multichannel_Campaign_Management__c  ,
                          Multichannel_CM_Specify_Others__c , Multichannel_Campaign_Mgmt_Specific__c, Digital_Marketing_Hubs__c ,Digital_Marketing_Hubs_Specify_Other__c   ,Digital_Marketing_Hubs_Specific_Request__c,
                          Salesforce_Automation__c,Salesforce_Automation_Specify_Others__c,Salesforce_Automation_Specific_Requests__c,CRM_Lead_Management__c,    CRM_Lead_Management_Specify_Others__c,CRM_Lead_Management_Specific_Requests__c,
                          Digital_Commerce_Platform__c,Digital_Commerce_Platform1__c,Digital_Commerce_Platform_Specific__c,Business_Process_Management_Suites__c,Business_Process_Mgmt_Suites_Specify__c,
                          Business_Process_Mgmt_Suites_Specific__c,Master_Data_Management_Customer_Data__c, Master_Data_Mgmt_Cust_Data_Specify__c,Master_Data_Mgmt_Cust__c,Evolution_of_CERM_Profile__c,History_Tech_Profile__c from Technical_Profile__c where id =: strTechprofileid] ;
             
             }
             if(strAccountId != null)
             {
                 Account objAccount = [SELECT id, Name FROM Account WHERE Id = :strAccountId];
                 objtech.Account__c = strAccountId ;
                 objtech.Name = objAccount.Name ;
             }
    }

        
        
        //Constructor
        public TechnicalProfileController()
        {
             /*objtech = new Technical_Profile__c ();
             strAccountId = ApexPages.currentPage().getParameters().get('accId');
             if(strAccountId != null)
             {
                 objtech.Account__c = strAccountId ;
             }*/
        }
        
        public PageReference save(){
        
       
        Id recordTypeId = [select Id from RecordType where DeveloperName = 'Techprofile' AND sObjectType = 'Technical_Profile__c' limit 1].Id;
        if(strTechprofileid != null){
        
        if(objtech.Contact_Center__c != 'Others')
        objtech.Contact_Center_Specify_Others__c = '';
        if(objtech.Unified_Communication__c != 'Others')
        objtech.Unified_Communications_Specify_Others__c = '';
        if(objtech.Digital_Channels__c != 'Others')
        objtech.Digital_Channels_Specify_Other__c = '';
        if(objtech.WEM_Solution__c != 'Others')
        objtech.WEM_Solution_Specify_Others__c = '';
        if(objtech.Predictive_Journey_Analytics__c != 'Others')
        objtech.Predictive_JA_Specify_Others__c = '';
        if(objtech.CRM_Vendors__c != 'Others')
        objtech.CRM_Vendor_Specify_Others__c = '';
        if(objtech.Voice_IVR_Vendor__c != 'Others')
        objtech.Voice_IVR_Vendor_Specify_Others__c = '';
        if(objtech.Voice_Chat_Bots__c != 'Others')
        objtech.Voice_Chat_Bots_Specify_Others__c = '';
        if(objtech.Multichannel_Campaign_Management__c   != 'Others')
        objtech.Multichannel_CM_Specify_Others__c = '';
        if(objtech.Digital_Marketing_Hubs__c != 'Others')
        objtech.Digital_Marketing_Hubs_Specify_Other__c = '';
        if(objtech.Salesforce_Automation__c != 'Others')
        objtech.Salesforce_Automation_Specify_Others__c = '';
        if(objtech.CRM_Lead_Management__c != 'Others')
        objtech.CRM_Lead_Management_Specify_Others__c = '';
        if(objtech.Digital_Commerce_Platform__c != 'Others')
        objtech.Digital_Commerce_Platform1__c = '';
        if(objtech.Business_Process_Management_Suites__c != 'Others')
        objtech.Business_Process_Mgmt_Suites_Specify__c = '';
        if(objtech.Master_Data_Management_Customer_Data__c != 'Others')
        objtech.Master_Data_Mgmt_Cust_Data_Specify__c = '';        
        Objtech.recordTypeid = recordTypeId ;
            upsert objtech ;
             
            
        }
        else
        {        
        List <Technical_Profile__c > Techaccount = new List <Technical_Profile__c >();        
        Techaccount = [Select id, Account__C from Technical_Profile__c where Account__C = : objtech.Account__c] ;
       
        if(Techaccount.size()>0)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Technical profile Record Already exists.  Please edit the record to make changes'));
        
           System.debug('Error-->1' + Techaccount );
            return null;
        } 
        else{
        System.debug('Error-->2' + Techaccount );
        if(objtech.Contact_Center__c != 'Others')
        objtech.Contact_Center_Specify_Others__c = '';
        if(objtech.Unified_Communication__c != 'Others')
        objtech.Unified_Communications_Specify_Others__c = '';
        if(objtech.Digital_Channels__c != 'Others')
        objtech.Digital_Channels_Specify_Other__c = '';
        if(objtech.WEM_Solution__c != 'Others')
        objtech.WEM_Solution_Specify_Others__c = '';
        if(objtech.Predictive_Journey_Analytics__c != 'Others')
        objtech.Predictive_JA_Specify_Others__c = '';
        if(objtech.CRM_Vendors__c != 'Others')
        objtech.CRM_Vendor_Specify_Others__c = '';
        if(objtech.Voice_IVR_Vendor__c != 'Others')
        objtech.Voice_IVR_Vendor_Specify_Others__c = '';
        if(objtech.Voice_Chat_Bots__c != 'Others')
        objtech.Voice_Chat_Bots_Specify_Others__c = '';
        if(objtech.Multichannel_Campaign_Management__c   != 'Others')
        objtech.Multichannel_CM_Specify_Others__c = '';
        if(objtech.Digital_Marketing_Hubs__c != 'Others')
        objtech.Digital_Marketing_Hubs_Specify_Other__c = '';
        if(objtech.Salesforce_Automation__c != 'Others')
        objtech.Salesforce_Automation_Specify_Others__c = '';
        if(objtech.CRM_Lead_Management__c != 'Others')
        objtech.CRM_Lead_Management_Specify_Others__c = '';
        if(objtech.Digital_Commerce_Platform__c != 'Others')
        objtech.Digital_Commerce_Platform1__c = '';
        if(objtech.Business_Process_Management_Suites__c != 'Others')
        objtech.Business_Process_Mgmt_Suites_Specify__c = '';
        if(objtech.Master_Data_Management_Customer_Data__c != 'Others')
        objtech.Master_Data_Mgmt_Cust_Data_Specify__c = '';        
        Objtech.recordTypeid = recordTypeId ;
            upsert objtech ;
           
        
        }
          
        }
        string redir = '/a6z';
       if(objtech.id != null){
          redir = objtech .id ;
       }
       
        pagereference pr = new pagereference('/' + redir);            
            return pr;
        }
        
        public PageReference Cancel(){
        if(objtech.id != null)
        {
        pagereference pr = new pagereference('/' + objtech.id);
        return pr ;
        }
        else{
        pagereference pr = new pagereference('/a6z');
        return pr ;
        }
            
        
        }
    
        public void test1(){
        }
    
    }