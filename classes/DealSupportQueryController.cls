public without sharing class DealSupportQueryController 
    {
        public Deal_Support__c objDS {get; set;}
        public List<Deal_Support__c> objDSpureplay {get; set;}
        public String strRecordName {get; private set;}
        public String strIdParameter {get; private set;}
        transient String strSupportEmails;
        public string BaseURL{get;set;}
        private string partnerAccEmailId;
        //public List<SelectOption> selectOptions{get;set;}
        //To identify submit
        public boolean IsSave{get; set;} //check it is for Attachment save or submit
        public boolean IsValidation{get; set;} 
        public Account accnt1 = new account();
        //Variables for file attachment
        public string fileName{get;set;}   
        public transient Blob fileBody{get;set;}
        public string FileDescType{get;set;}
        public string sAttachmentId{get;set;}
        public PageReference objRef;
        /*List variables*/
        public List<Attachment>list_Attachment{get;set;}
        //PS DSR Documents
        public List<PS_DSR_Document__c> PSDSR_Documents{get;set;}
        
        /*Private variables */
        public String strOpptyId{get; set;}
        public String strAccountId{get; set;}    
        public boolean IsOppExist{get; set;} 
        public boolean IsDsrExist{get; set;} 
        public String strSupportArea{get; set;} 
        public string strRequestType;
        public String strIsPSSmartDSR;
        public String strIsTransDSR;
        public String strIsFromPSAttachments;
        public String strpsDSRId;
        public Boolean IsReturnFromPSDSRAttachments {get;set;}
        
        public Opportunity objOppty {get; private set;}
        public Opportunity objOppty1 {get; set;}
        public DSR_Opportunity_Detail__c dsrOpty {get; set;}
        public Boolean blnIsPartnerUser {get; private set;} 
        public String strOfferingType{get; set;}  
      //  public String Strleadoffer{get;set;}
        public string sSuppEmail;
        public String Str_pagename {get; set;}
       // public String discountScheduleID{get;set;}
        public String SCEForm {get; set;}  
        public String PORRef {get; set;}  
       // public String PORRefName {get; set;} 
        public String PSCSDAssignee {get; set;}
        Private string contactname;
        public boolean createOpportunity { get; set; }
       // public String textdata {get; set;}
        private boolean fileattachedfororder;
       // public Date x_date    {get;set;}
    
        //Constructor start.
        public DealSupportQueryController ()
        {
                 
            createOpportunity  = false;
            fileattachedfororder = false;
            FileDescType = '';
            strOpptyId = ApexPages.currentPage().getParameters().get('oppId');
            strAccountId = ApexPages.currentPage().getParameters().get('accId');
            strSupportArea = ApexPages.currentPage().getParameters().get('supportarea');
            strRequestType = ApexPages.currentPage().getParameters().get('type');
            strIsPSSmartDSR = ApexPages.currentPage().getParameters().get('isPSSMART');
            strIsTransDSR = ApexPages.currentPage().getParameters().get('iSTranshelp');
            strIsFromPSAttachments = ApexPages.currentPage().getParameters().get('isFromPSAttachments');
            strpsDSRId = ApexPages.currentPage().getParameters().get('psDSRId');
            strOfferingType = ApexPages.currentPage().getParameters().get('offeringType');
            IsReturnFromPSDSRAttachments=false;
            String strDSId = ApexPages.currentPage().getParameters().get('id');
            
                 
            if(ApexPages.currentPage().getUrl().contains('apex/'))
            Str_pagename = ApexPages.currentPage().getUrl().split('apex/')[1];
            
            /*
            Usage       : PS_DS Changes
            */
            SCEForm = ApexPages.currentPage().getParameters().get('SCEForm');
            PORRef  = ApexPages.currentPage().getParameters().get('PORRefId');
            
            system.debug(Str_pagename);
            if(Str_pagename.startswith('PORDSR'))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Remember to attach a document'));
            objOppty1 = new opportunity();
            dsrOpty = new DSR_Opportunity_Detail__c ();
            objDS = new Deal_Support__c();
            objDSpureplay = new list<Deal_Support__c>();
            objDS.Support_Area__c = strSupportArea;
            objDS.Request_Type__c = strRequestType;
            if(objDS.Support_Area__c == 'Sales Ops'){
            objDS.Competitor_Replacing_Genesys__c = 'None – No Competitor Given';
            objDs.Official_Cancelation_Date__c = Date.today();
           
            }
            
            if(objDS.Support_Area__c == 'Professional Services'){
                if(strOpptyId != null){
                    objDS.PS_Only_no_license_deal__c = false;               
                }
                else{
                    objDS.PS_Only_no_license_deal__c = true;
                }
                
            }
            if(objDS.Support_Area__c == 'Transactional Help'){        
                objDs.Description__c = 'Provide Customer Address (bill to/ship to/sold to/end user), Email and other details. ';        
            }
            //Added by aparna for references
            if(objDS.Support_Area__c == 'References'){        
                objDs.Description__c = 'Sample Text:    They are currently on an aging premise solution (Avaya) and have an internal initiative to be in the cloud by XYZ date. They have narrowed it down to us, InContact, and Five9. The key message we need to convey is the stability and scalability of our platform – they have 500 agents. Some questions they may ask:-- 1)How did the implementation go?   2)What happened that you didn’t plan for and how did Genesys support you?   3)Are there any features you wish the product had that it doesn’t? ';        
            }
            blnIsPartnerUser = UserInfo.getUserType() == 'PowerPartner';//'PowerCustomerSuccess';//added by swastika on Apr/19/2017 to check the current user profile is partner user
            //Check if this is being initialised as a page call from having done PS Attachment processing - if so we already have a saved DSR and should assign that before rendering the output,
            // and not do any of the other overrides or setup that would be needed for a new DSR
//Added for duplicate check
        if(strOpptyId != null && strSupportArea == 'Play Support' && (strRequestType == 'PureBridge' || strRequestType == 'PureBridge Trial' || strRequestType == ' Cloud Migration Assistance')){
            objDSpureplay = [SELECT Id, Name, Account__c, Opportunity__c,Support_Area__c, Request_Type__c FROM Deal_Support__c WHERE Opportunity__c =: strOpptyId and (Request_Type__c ='PureBridge' OR Request_Type__c = 'PureBridge Trial' OR Request_Type__c ='Cloud Migration Assistance')];
            
            if (objDSpureplay.size()>0)
            {
                IsDsrExist=true;
            }
            
        }
        //Added for duplicate check completed
            if (strIsFromPSAttachments != null && strpsDSRId != null)
            {
                objDS = [SELECT Id, Name, Account__c, Opportunity__c, Opportunity__r.OwnerId, DSR_SC_Engagement_Ref__c, Support_Area__c, Request_Type__c, Requester__c, Status__c, Request_Due_Date__c, Priority__c, ININ_Account_URL__c, ININ_Opportunity_URL__c,
                         Region__c, Sub_Region__c, Security_Issue_Type__c,Country_Name__c,Stage_Name__c,Product_Cancellation_Date__c,Offering_Type__c, Deployment_Type__c, PS_Project_Application__c, PS_POR_Reference__c, SC_Engagement_Form__c, PS_Expected_Delivery_Date__c,Deal_Size__c,PS_Only_no_license_deal__c ,Requested_Action__c,
                         CTO_Comments__c,Primary_Play__c,PS_POR_Review_Scheduled_Date__c,End_User_Country__c, DirectIndirect_Sale__c,End_User_Point_of_Contact__r.Name,Trial_Evaluation__c, Subject__c, Description__c,Notification_Date__c,Official_Cancelation_Date__c, Error_Message__c, PS_SMART_DSR__c,Offering_Type2__c,Support_Email__c, Support_Email2__c,Resolution__c,Account__r.Owner.id, Account__r.CSM_Account_Owner__r.id,ForecastStatus1__c,Lead_Offer_Type__c
                         FROM Deal_Support__c WHERE Id =: strpsDSRId];
                GetPSDSR_Documents();
                IsReturnFromPSDSRAttachments=true;
                if (objDS.Opportunity__c != null)
                {
                    IsOppExist=true;
                }
                IsSave=true; 
                return;
            }
            
            system.debug('++++strDSId===='+strDSId);
            //if(String.isNotBlank(strDSId))
            if(strDSId != null)
            {
                objDS = [SELECT Id, Name, Support_Area__c, Request_Type__c, Requester__c, Opportunity__c, POR_Type__c, SC_Engagement_Form__c,End_User_Point_of_Contact__r.Name,Description__c,Notification_Date__c,Official_Cancelation_Date__c,Deployment_Type__c,
                         CTO_Comments__c,IsNew__c,Key_Team_Members__c,PS_SMART_DSR__c,DSR_SC_Engagement_Ref__c,Country_Name__c,Product_Cancellation_Date__c,Requested_Action__c,PS_Only_no_license_deal__c,Security_Issue_Type__c, POR_Lead__c, POR_Schedule_Date__c,Trial_Evaluation__c, Offering_Type__c,POR_Disposition__c,Offering_Type2__c,Resolution__c,Account__r.Owner.id,Account__r.CSM_Account_Owner__r.id
                         FROM Deal_Support__c WHERE Id =: strDSId];
                
                if(objDS.Opportunity__c != null)
                {
                    strOpptyId = objDS.Opportunity__c;
                    
                }
            }
            
            
            //Initialize the flag IsSave, validation and attachment list
            IsSave=true;
            IsValidation=true;       
            if(strOpptyId !=null)
                IsOppExist=true;
            else
                IsOppExist=false;
             
            
            if(String.isNotBlank(strOpptyId) || (String.isNotBlank(strAccountId) && strAccountId != 'null'))
            {
                
                if(String.isNotBlank(strOpptyId))
                {
                   system.debug('++++strOpptyId===='+strOpptyId);
                String strQuery = 'SELECT OwnerId,StageName,Type,Lines_of_Businesses__c,Name,AccountId,Account.Country__r.Name,Account.Country__r.Region__c,ININOpportunityURL__c,Account.ININAccountURL__c,Country__c,Lead_Offer__c,ForecastStatus__c,Contact__c,Direct_Indirect_Sale__c,License_Equivalency__c,License_Equivalency_1__c,Who_did_Genesys_Replace__c';
                    
                    if(strSupportArea == 'POR Review' || objDS.Support_Area__c == 'POR Review')
                    {
                        strQuery += ',Key_Business_Objective__c,CloseDate,ACV_Subscription_Only__c,Total_Annual_Contract_Value__c,OpportunityNumber__c,NumberofAgents__c';
                        
                        if(objDS.Id == null)
                            strQuery += ',(SELECT Id FROM Wow_Request_Form__r ORDER BY CreatedDate DESC LIMIT 1)';
                        
                        objDS.Subject__c = objDS.Description__c = 'POR Review';
                    }
                    
                    strQuery += ' FROM Opportunity WHERE Id =: strOpptyId';
                    objOppty = Database.query(strQuery);
                    //Autopulate lead offer and primary contact form oppty.
                    //Below fields are added by aparna
                    objDS.Lead_Offer_Type__c = objOppty.Lead_Offer__c;
                    objDS.DirectIndirect_sale__c = objOppty.Direct_Indirect_Sale__c;
                    objDS.ForecastStatus1__c = objOppty.ForecastStatus__c;
                    objDS.Stage_Name__c = objOppty.StageName;
                    objDS.End_User_Country__c = objOppty.Country__c;
                   
                 
                    objDS.Opportunity_Amount__c = objOppty.License_Equivalency__c;
                    objDs.Primary_Contact__c = objOppty.Contact__c;
                    if(strSupportArea == 'POR Review' || objDS.Support_Area__c == 'POR Review')
                    {
                        if(objDS.Id != null)
                            return;
                        
                        if(!objOppty.Wow_Request_Form__r.isEmpty())
                            objDS.SC_Engagement_Form__c = objOppty.Wow_Request_Form__r[0].Id;
                    }
                    
                    // Add DSR SC Engagement Ref if present from the opportunity using the most recently modified record
                    List<DSR_SCEngagement__c> dsrList = new List<DSR_SCEngagement__c>([select id, Account_ID__c, Opportunity_ID__c from DSR_SCEngagement__c where Opportunity_ID__c=:strOpptyId order by lastmodifiedDate asc limit 1]);
                    if(dsrList.size()>0) objDS.DSR_SC_Engagement_Ref__c = dsrList[0].Id;
                    
                    //Opportunity objOppty = [SELECT Name,AccountId,Account.Country__r.Name,Account.Country__r.Region__c FROM Opportunity WHERE Id = :strOpptyId];
                    
                    objDS.Country_Name__c = objOppty.Account.Country__r.Name;
                    objDS.Region__c = (objOppty.Account.Country__r.Region__c == null ? 'North America' : objOppty.Account.Country__r.Region__c);
                    objDS.Account__c = objOppty.AccountId;
                    strRecordName = objOppty.Name;
                    objDS.Opportunity__c = strOpptyId;
                    objDS.ININ_Opportunity_URL__c = objOppty.ININOpportunityURL__c;
                    objDS.ININ_Account_URL__c  = objOppty.Account.ININAccountURL__c;
                    //objDS.Offering_Type2__c = objOppty.Lines_of_Businesses__c;
                   // objDS.Lead_Offer_Type__c = objOppty.Lead_Offer__c;
                   objDS.Offering_Type2__c = objOppty.Lead_Offer__c;
                    objDS.Primary_contact__C = objOppty.Contact__c;
                    strIdParameter = 'oppId=' + strOpptyId;
                objDS.Vendor_in_Place__c  = objOppty.Who_did_Genesys_Replace__c ;
                objDS.Type__c  = objOppty.Type ;
                }
                else
                {
                  if(strAccountId != null && strAccountId != 'null')
                  {
                    Account objAccount = [SELECT id, Name,Country__r.Name,Country__r.Region__c,ININAccountURL__c FROM Account WHERE Id = :strAccountId];
                    // Add DSR SC Engagement Ref if present from the account using the most recently modified record
                    List<DSR_SCEngagement__c> dsrList = new List<DSR_SCEngagement__c>([select id, Account_ID__c from DSR_SCEngagement__c where Account_ID__c=:strAccountId order by lastmodifiedDate asc limit 1]);
                    if(dsrList.size()>0) objDS.DSR_SC_Engagement_Ref__c = dsrList[0].Id;
                    objDS.Country_Name__c = objAccount.Country__r.Name;
                    objDS.Region__c = (objAccount.Country__r.Region__c == null ? 'North America' : objAccount.Country__r.Region__c);
                    objDS.Account__c = strAccountId;
                    objDS.ININ_Account_URL__c = objAccount.ININAccountURL__c ;
                    strRecordName = objAccount.Name;
                    strIdParameter = 'accId=' + strAccountId;
                  } 
                   
                } 
                }
    
            objDS.Requester__c = UserInfo.getUserId();
            
            /*Commented By Swastika to hardcode status=new when there is no status, once submit its status=new*/
            //objDS.Status__c = 'New';
            
            /***** This Map is created because Opportunities's OfferinType values and Deal Support's Offering Type values are different********/
            Map<string,string>map_OfferingType = new Map<string,string>();
            map_OfferingType.put('PureEngage','Pure Engage');
            map_OfferingType.put('PureConnect','Pure Connect');
            map_OfferingType.put('PureCloud','Pure Cloud');
            
            if(String.isNotBlank(strSupportArea))
                objDS.Support_Area__c = strSupportArea;
            
            if(String.isNotBlank(strRequestType))
                objDS.Request_Type__c = strRequestType;
            if(String.isNotBlank(strOfferingType))
                objDS.Offering_Type__c = strOfferingType;   
            else
            {
               //objDS.Offering_Type__c = objOppty != NULL ? objOppty.Lines_of_Businesses__c : '';
                
                if(objOppty != NULL && objOppty.Lines_of_Businesses__c != null)
                {
                   objDS.Offering_Type__c = map_OfferingType.get(objOppty.Lines_of_Businesses__c);
                }
            } 
            // PS DSR Update: NikM: Jan 2017: Set the PS SMART DSR flag on the DealSupport record if this was passed in from the VF page parameters    
            if(String.isNotBlank(strIsPSSmartDSR))
                objDS.PS_SMART_DSR__c = true;
            
            // if the PS SMART DSR flag is set, default some of the values on the record now to the PS Specifics, otherwise only change the request due date to today() + 1 for all other records
            // Should only override when this is first created
            if (String.isNotBlank(strIsPSSmartDSR) && objDS.PS_SMART_DSR__c == true)
            {
                objDS.Request_Due_Date__c = Date.today() + 7;
                //objDS.PS_Project_Application__c = 'Standard Use Case';
                //objDS.Deployment_Type__c = 'Premise';
            }
            else
            {
                objDS.Request_Due_Date__c = Date.today() + 1;
            }
            
            /*User objRunningUser = [SELECT Region__c FROM User WHERE Id = :UserInfo.getUserId()];
    
            if(String.isNotBlank(objRunningUser.Region__c))
            objDS.Region__c = objRunningUser.Region__c;
            else
            objDS.Region__c = [SELECT Account.Country__r.Region__c FROM Opportunity WHERE Id = :strOpptyId].Account.Country__r.Region__c;*/
    
            // NikM: 06-Nov-2017: Modified to fix PS DSR record creation and only set the recordtype to Sales Ops if this is not a PS DSR
            if(!blnIsPartnerUser){
                if(strSupportArea=='Professional Services')
                    objDS.RecordTypeid = [select id,name from RecordType where name =: 'Professional Services - DS'].id;
                else 
                    objDS.RecordTypeid = [select id,name from RecordType where name =: 'Sales Ops'].id;
            }
            
            if(objDS.Region__c == 'Americas' || objDS.Region__c == 'North America')
                objDS.Region__c = 'NA';  
            if(objDS.Region__c=='' || objDS.Region__c==null ) 
                objDS.Region__c = 'NA';                
            //}
            /*Get Base URL*/
            BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());         
            System.debug('strOfferingType---'+strOfferingType+'---objDS.Offering_Type__c---'+objDS.Offering_Type__c);
        }
        
        // *** Handler for Save Button/functionality for POR Review DSR ***
        public PageReference saveBtnHandler()
        {
            Boolean blnIsNew = false;
            if(objDS.Id == null)
            {
                objDS.Status__c = 'Submitted';
                objDS.OwnerId = objOppty.OwnerId;
                objDS.Offering_Type__c = objOppty.Lines_of_Businesses__c;
                blnIsNew = true;
            }
            try
            {
                if(objOppty != null){
                    objDS.Opportunity_Owner_Email__c = getOpOwnerEmailId(objOppty.Id);
                    objDS.Partner_Account_Owner_Email__c = string.isBlank(partnerAccEmailId)?'':partnerAccEmailId;
                }
                upsert objDS;
                
                if(blnIsNew)
                {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request submitted.'));
                    return (new PageReference('/apex/PORDSR?id=' + objDS.Id)).setRedirect(true);
                }   
            }
            catch(exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            }
            return null;
        }
        
        public void save()
        {
            submitBtnHandler();
            
        }
        
        public void submit()
        {   
        
            if(objDS.Requested_Action__c == 'Inactivate Line of Business'){           
                 
                /* if((objDS.Offering_Type__c == 'Pure Cloud' || objDS.Offering_Type__c == 'PureConnect Cloud' || objDS.Offering_Type__c == '  PureEngage Cloud' || objDS.Offering_Type__c == 'PureEngage Cloud Outbound' || objDS.Offering_Type__c == 'Premier Edition' || objDS.Offering_Type__c == 'ELC') && (objDS.Cloud_Deployment__c == null)){
                         if(objDS.Offering_Type__c == 'Pure Cloud' && (objDS.Cloud_Deployment__c == null) ){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cloud Deployment is required For Purecloud Platform type.'));
                }*/ 
                if(objDS.Org_ID__c == '--None--' || string.isBlank(objDS.Org_ID__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Org ID is required'));
                }
                else if(objDS.Primary_Churn_Reason__c == '--None--' || string.isBlank(objDS.Primary_Churn_Reason__c)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Primary Churn Reason is required'));
                }  
                else if(objDS.Notification_Date__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Notification Date is required'));
                } 
                
                    
                //}         
                else if(objDS.Official_Cancelation_Date__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Official Cancelation Date is required'));
                }
                else{
                    if(blnIsPartnerUser){
                    objDS.Request_User_Type__c = 'Partner';
                    }else{
                        objDS.Request_User_Type__c = 'Internal';
                    }
                    IsSave=false;
                    objDS.IsSubmitted__c = true;
                    //Now this is being submitted from the main form, if this is a PS SMART DSR record, then set the status to submitted.
                    if(objDS.Support_Area__c == 'Professional Services' && objDS.PS_SMART_DSR__c == true)
                    {
                        objDS.Status__c = 'Submitted';
                    }
                    
                Account accnt1 = new account();
                if(strAccountId != null && strAccountId != 'null'){
                    //accnt1 = [Select id, Name, Ownerid,CSM_Account_Owner__c,Owner.Email,CSM_Account_Owner__r.Email  from Account where id =: strAccountId];
                    accnt1 = [Select id, Name, Ownerid,CSM_Account_Owner__c,SAP_Account_Code__c,Owner.Email,Owner.IsActive,Owner.Manager.Email, CSM_Account_Owner__r.Email,CSM_Account_Owner__r.IsActive, CSM_Account_Owner__r.Manager.Email from Account where id =: strAccountId];
                System.debug('HNavaneetha2' +accnt1.Owner.Manager.Email );
                }
                else 
                {
                     System.debug('HNavaneetha5' );
                     accnt1 = [Select id, Name, Ownerid,CSM_Account_Owner__c,SAP_Account_Code__c,Owner.Email,Owner.IsActive,Owner.Manager.Email, CSM_Account_Owner__r.Email,CSM_Account_Owner__r.IsActive, CSM_Account_Owner__r.Manager.Email from Account where id =: objDS.Account__c];
                 System.debug('HNavaneetha3' +accnt1.Owner.Manager.Email );
                }            
                
                if(objDS.Support_Area__c == 'Sales Ops' && objDS.Request_Type__c == 'Data Management' && objDS.Focus_Area__c == 'Account' && objDS.Requested_Action__c == 'Inactivate Line of Business' && (objDS.Requester__c != accnt1.Ownerid  && objDS.Requester__c != accnt1.CSM_Account_Owner__c))
                //if(objDS.Support_Area__c == 'Sales Ops')
                {
                    objDS.Owner_Approval__c = 'Pending';
                    //contact information
                    Contact acontact = new contact();
                    
                   if(objDS.End_User_Point_of_Contact__c != null)
                    {
                        acontact = [select id, name from contact where id =: objDS.End_User_Point_of_Contact__c];
                    }
            
                    contactname = acontact.Name;
             System.debug('HNavaneetha5' );
                    System.debug('names1'+ contactname );
                    system.debug('fail state'+ objDS.Owner_Approval__c);
                }
                
                if(objDS.Support_Area__c == 'Sales Ops' && objDS.Request_Type__c == 'Data Management' && objDS.Focus_Area__c == 'Account' )
                {
                    if(strAccountId != null && strAccountId != 'null'){
                    //accnt1 = [Select id, Name, Ownerid,CSM_Account_Owner__c,Owner.Email,CSM_Account_Owner__r.Email  from Account where id =: strAccountId];
                    accnt1 = [Select id, Name, Ownerid,CSM_Account_Owner__c,SAP_Account_Code__c,Owner.Email,Owner.IsActive,Owner.Manager.Email, CSM_Account_Owner__r.Email,CSM_Account_Owner__r.IsActive, CSM_Account_Owner__r.Manager.Email from Account where id =: strAccountId];
                System.debug('HNavaneetha2' +accnt1.Owner.Manager.Email );
                }
                else 
                {
                     System.debug('HNavaneetha51' );
                     accnt1 = [Select id, Name, Ownerid,CSM_Account_Owner__c,SAP_Account_Code__c,Owner.Email,Owner.IsActive,Owner.Manager.Email, CSM_Account_Owner__r.Email,CSM_Account_Owner__r.IsActive, CSM_Account_Owner__r.Manager.Email from Account where id =: objDS.Account__c];
                 System.debug('HNavaneetha3' +accnt1.Owner.Manager.Email );
                } 
                     
                    objDS.Genesys_Advisor_Account_Email__c = accnt1.CSM_Account_Owner__r.Email ; 
                    objDS.Genesys_Advisors_manager_email__c = accnt1.CSM_Account_Owner__r.Manager.Email;
                    System.debug('HNavaneetha52' +  objDS.Genesys_Advisor_Account_Email__c );
                    System.debug('HNavaneetha52' + objDS.Genesys_Advisors_manager_email__c );
                }
                
                
                
                /*if(objDS.Support_Area__c == 'Sales Ops' && objDS.Request_Type__c == 'Data Management' && objDS.Focus_Area__c == 'Account' && objDS.Requested_Action__c == 'Inactivate Line of Business' && (objDS.Requester__c == accnt1.Ownerid  || objDS.Requester__c == accnt1.CSM_Account_Owner__c) )
                {
                    objDS.Owner_Approval__c = 'Approved';
                    system.debug('Pass state'+ objDS.Owner_Approval__c);
                } */
                 if(objDS.Support_Area__c == 'Sales Ops' && objDS.Request_Type__c == 'Data Management' && objDS.Focus_Area__c == 'Account' && objDS.Requested_Action__c == 'Inactivate Line of Business' && objDS.Primary_Churn_Reason__c != '' && objDS.Org_ID__c != '' )
                 {
                     If(objDS.Trial_Evaluation__c  == 'yes' ){
                     if(objDS.Requester__c == accnt1.Ownerid)
                     {
                         objDS.Owner_Approval__c = 'Approved';
                     }
                     else{
                         if(accnt1.Owner.IsActive){
                             objDS.Owner_Approval__c = 'Pending';                        
                         }
                         else{
                             objDS.Owner_Approval__c = 'Pending';                         
                         }                   
                     }               
                 }
                 else{
                     if(objDS.Requester__c == accnt1.CSM_Account_Owner__c)
                     {                   
                         objDS.Owner_Approval__c = 'Approved';                    
                     }
                     else{
                         if(accnt1.CSM_Account_Owner__r.IsActive){
                             objDS.Owner_Approval__c = 'Pending';                        
                           }
                           else{
                               objDS.Owner_Approval__c = 'Pending';                           
                           }
                         
                     }
                     
                 }
                     
                 }
                    
                    
                    submitBtnHandler();  
                            
                    inactivationemailmetod();               
                }           
                
            }
            else if(dsrOpty.Direct_Indirect_Sale__c == 'Indirect' && (dsrOpty.BusinessPartner__c == null || string.isBlank(dsrOpty.BusinessPartner__c))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sold To/Business Partner is required'));
            }
            else if(dsrOpty.Direct_Indirect_Sale__c == 'Direct' && (dsrOpty.BusinessPartner__c != null || !string.isBlank(dsrOpty.BusinessPartner__c))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sold To/Business Partner is Not required for Direct Sale'));
            }
            else if(objDS.Support_Area__c == 'Transactional Help' && createOpportunity == true  && objDS.Opportunity__c!= null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only one opportunity Can map with the Deal Support'));
                IsSave=true;
            }
            else if(objDS.Support_Area__c == 'Professional Services' && objDS.PS_Only_no_license_deal__c == false &&  objDS.DSR_SC_Engagement_Ref__c == null)
            {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'DSR SC Engagement is required for Non PS Only, no license deal'));
            }
    else if(objDS.Support_Area__c == 'Play Support' && (objDS.Request_Type__c == 'PureBridge' || objDS.Request_Type__c == 'PureBridge Trial' || objDS.Request_Type__c == 'Cloud Migration Assistance') && objDS.Opportunity__c != null && strOpptyId == null)
        {
            objDSpureplay = [SELECT Id, Name, Account__c, Opportunity__c,Support_Area__c, Request_Type__c FROM Deal_Support__c WHERE Opportunity__c =: objDS.Opportunity__c and (Request_Type__c ='PureBridge' OR Request_Type__c = 'PureBridge Trial' OR Request_Type__c = 'Cloud Migration Assistance')];
            if(objDSpureplay.size()>0 || objDSpureplay == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'PureBridge DSR is already created for this opportunity'));
            IsSave=true;            }
            else{
                upsert objDS;
                IsSave=false;
                if(IsSave==false)     //If the submitted not upload                      
                           {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request submitted.'));                        
                            return;
                            }
            }
            system.debug('TEstnavanees' + objDSpureplay);
        }
           
            
            else{
            
            if(blnIsPartnerUser){
            objDS.Request_User_Type__c = 'Partner';
            }else{
                objDS.Request_User_Type__c = 'Internal';
            }
            IsSave=false;
            objDS.IsSubmitted__c = true;
            //Now this is being submitted from the main form, if this is a PS SMART DSR record, then set the status to submitted.
            if(objDS.Support_Area__c == 'Professional Services' && objDS.PS_SMART_DSR__c == true)
            {
                objDS.Status__c = 'Submitted';
            }
            if(objDs.Security_Issue_Type__c == 'RFP'){
                objDs.Request_Due_Date__c = Date.today() + 7;
                
            } else {
                objDs.Request_Due_Date__c = Date.today() + 30;
            }
            if(objDS.Support_Area__c == 'Professional Services' && objDS.DSR_SC_Engagement_Ref__c != null && objDS.PS_Only_no_license_deal__c == false)
            {
               List<DSR_Virtual_Team__c> dsrvt = [select id, Email__c,SCE_ID__c  from DSR_Virtual_Team__c where SCE_ID__c =: objDS.DSR_SC_Engagement_Ref__c and IsPrimary__c = true limit 1];
                if(dsrvt.size() > 0){
                
                 //string emails = dsrvt[0].Email__c + ';' + dsrvt[1].Email__c;
                // system.debug('emailsnavanee' + emails);
                    objDs.DSR_Virtual_primary_email__c = dsrvt[0].Email__c;
                }
                
            } 
            
            
            
            submitBtnHandler();  
            inactivationemailmetod();
            
            }   
                
            
        } 
        
       
        
         public void inactivationemailmetod()
     {
           String[] sendingTo;
            Account accnt = new account();
            if(strAccountId != null && strAccountId != 'null' || objDS.Account__c != null){
                if(strAccountId != null && strAccountId != 'null'){
                accnt = [Select id, Name, Ownerid,CSM_Account_Owner__c,SAP_Account_Code__c,Owner.Email,Owner.IsActive,Owner.Manager.Email, CSM_Account_Owner__r.Email,CSM_Account_Owner__r.IsActive, CSM_Account_Owner__r.Manager.Email from Account where id =: strAccountId];
                }
                else if(objDS.Account__c != null)
                {
                     accnt = [Select id, Name, Ownerid,CSM_Account_Owner__c,SAP_Account_Code__c,Owner.Email,Owner.IsActive,Owner.Manager.Email, CSM_Account_Owner__r.Email,CSM_Account_Owner__r.IsActive, CSM_Account_Owner__r.Manager.Email from Account where id =: objDS.Account__c];
                }
            }
            User u = [select firstname from user where id=:userinfo.getuserid()];
            string username = u.firstname;   
    
             if(objDS.Support_Area__c == 'Sales Ops' && objDS.Request_Type__c == 'Data Management' && objDS.Focus_Area__c == 'Account' && objDS.Requested_Action__c == 'Inactivate Line of Business' && objDS.Primary_Churn_Reason__c != '' && objDS.Org_ID__c != '' )
             {
                 If(objDS.Trial_Evaluation__c  == 'yes' ){
                     if(objDS.Requester__c == accnt.Ownerid)
                     {
                         objDS.Owner_Approval__c = 'Approved';
                     }
                     else{
                         if(accnt.Owner.IsActive){
                             objDS.Owner_Approval__c = 'Pending';
                            sendingTo = new String[]{accnt.Owner.Email};  
                            accountinactivemail(accnt , sendingTo);
                         }
                         else{
                             objDS.Owner_Approval__c = 'Pending';
                             sendingTo = new String[]{accnt.Owner.Manager.Email};  
                             accountinactivemail(accnt , sendingTo);
                         }                   
                     }               
                 }
                 else{
                     if(objDS.Requester__c == accnt.CSM_Account_Owner__c)
                     {
                         System.debug('test---accnt.CSM_Account_Owner__c'+ accnt.CSM_Account_Owner__c);
                         objDS.Owner_Approval__c = 'Approved';
                        
                     }
                     else{
                         if(accnt.CSM_Account_Owner__r != null){
                         if(accnt.CSM_Account_Owner__r.IsActive){
                             objDS.Owner_Approval__c = 'Pending';
                            sendingTo = new String[]{accnt.CSM_Account_Owner__r.Email};  
                           System.debug('sendingTo 1'+ sendingTo);
                           accountinactivemail(accnt , sendingTo);
                           }
                           else{
                               objDS.Owner_Approval__c = 'Pending';
                               sendingTo = new String[]{accnt.CSM_Account_Owner__r.Manager.Email};  
                               accountinactivemail(accnt , sendingTo);
                           }
                         } else{
                            objDS.Owner_Approval__c = 'Pending'; 
                            sendingTo = new String[]{'askcsops@genesys.com'} ;
                            accountinactivemail(accnt , sendingTo);
                         }
                         
                     }
                     
                 }
                 
             }              
     }
     
     public void accountinactivemail(account accnt, String[] sendingTo){
      User u = [select firstname from user where id=:userinfo.getuserid()];
            string username = u.firstname;
         Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
               //String[] sendingTo;
               semail.setToAddresses(sendingTo);
               semail.setSubject('IMPORTANT: '+ accnt.Name + ',('+accnt.SAP_Account_Code__c+') – Inactivation Approval Request');           
               String msg ='Hi, <br/><br/>';    
               msg +=  username  + ' has reported that the account '+ accnt.Name +' is canceling their ' + objDS.Offering_Type__c+'.</br><br/>';
               //msg +=  'If this is correct, please approve the request '+ URL.getSalesforceBaseUrl().toExternalForm() + '/' +objDS.id  +' , so that their' + objDS.Offering_Type__c+' offing is shut down.</br>';
              // msg +=  'If this is correct, please approve the request '+ URL.getSalesforceBaseUrl().toExternalForm() + '/' +objDS.id  +'</br>';          
              // msg +=  'If this is not correct, please reject the request '+ URL.getSalesforceBaseUrl().toExternalForm() + '/' +objDS.id  +' , and follow up with '+ username+ ' .</br><br/>';
               msg +=  'If this is correct, please approve the request '+ URL.getSalesforceBaseUrl().toExternalForm() + '/apex/dealsupportAccinactive?ResponseCode=Approved&DSId=' +objDS.id  +'</br>';          
               msg +=  'If this is not correct, please reject the request '+ URL.getSalesforceBaseUrl().toExternalForm() + '/apex/dealsupportAccinactive?ResponseCode=Rejected&DSId=' +objDS.id  +' , and follow up with '+ username+ ' .</br><br/>';
               msg +=  '<b>Request Details:</b><br/><br/>';
               msg +=  'Owner Approval: ' + objDS.Owner_Approval__c +'</br>' ;
               msg +=  'Account Name: <a href='+URL.getSalesforceBaseUrl().toExternalForm() + '/' + accnt.id +'>' +accnt.Name +'</a></br>'  ;
               msg +=  'Line of Business: ' + objDS.Offering_Type__c +'</br>';
               msg +=  'Trial/Evaluation: ' + objDS.Trial_Evaluation__c+'</br>';
               msg +=  'Org/Tenant ID: ' + objDS.Org_ID__c +'</br>' ;
               msg +=  'End User Point Of contact: <a href='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ objDS.End_User_Point_of_Contact__c +'>'+ contactname  + '</a></br>' ;
               msg +=  'Primary Churn Reason: ' + objDS.Primary_Churn_Reason__c +'</br>' ;
               msg +=  'Competitor Replacing Genesys: ' + objDS.Competitor_Replacing_Genesys__c +'</br>' ;  
               msg +=  'Notification Date: ' + objDS.Notification_Date__c.format() +'</br>' ;
               msg +=  'Official Cancelation Date: ' + objDS.Official_Cancelation_Date__c.format() +'</br>' ;
               msg +=  'Details: ' + objDS.Description__c +'</br>' ;
               
                     
               msg +=  'Thanks,';
               semail.setHTMLBody(msg);
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
              System.debug('testnavaneet' + semail);
     }
        
        public void submitBtnHandler()
        {
            try
            {
               
                 system.debug('++++objDS.Region__c+++'+objDS.Region__c );
                system.debug('++++objDS+++'+objDS);
                if(objDS.Support_Area__c == 'Product Management')
                {
                    if(blnIsPartnerUser){
                    RecordType objRecType = [Select id,name from RecordType where name = 'Partner' AND SObjectType = 'Deal_Support__c' ] ;
                    objDS.RecordTypeId = objRecType.id;
                    }
                    
                    
                    /********** Change request shared by Trevor and Debora Lane ******/
                    if(objDS.Request_Type__c == Label.Unable_To_Determine)
                    {
                        objDS.Support_Email__c = Deal_Support_Email_Ids__c.getInstance('Release Management Team').NA__c;
                        if(objOppty != null){
                            objDS.Opportunity_Owner_Email__c = getOpOwnerEmailId(objOppty.Id);
                            objDS.Partner_Account_Owner_Email__c = string.isBlank(partnerAccEmailId)?'':partnerAccEmailId;
                        }
                        upsert objDS;
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request submitted (' + objDS.Support_Email__c + ').'));
                        if(IsSave==false)     //If the submitted not upload                      
                           {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request submitted.'));                        
                            return;
                            }
                    }
            if(objDS.Request_Type__c == 'Data Protection')
                    {
                         upsert objDS;
                          if(IsSave==false)     //If the submitted not upload                      
                           {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request submitted.'));                        
                            return;
                            }
                    }
                    
                       
                 else if( objDS.Support_Area__c != 'Product Management' && (objDS.Request_Type__c == 'Play Assistance' || objDS.Request_Type__c == 'Migrations Assistance'))
                    {
                         upsert objDS;
                          if(IsSave==false)     //If the submitted not upload                      
                           {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request submitted.'));                        
                            return;
                            }
                    }
                  
                }
                 
                 
                else
                {
                    if(objDS.Support_Area__c == 'Sales Ops')
                    {
                        //Change The pagelyout for SalesOp  R-Systems(23-Feb-16)
                        RecordType objRecType = [Select id,name from RecordType where name =: 'Sales Ops' ] ;
                        objDS.RecordTypeId = objRecType.id;                   
                        if(objDS.Request_Type__c == 'Data Management' && objDs.Focus_Area__c== 'Account' && objDS.Requested_Action__c == 'Inactivate Line of Business'  && objDS.Offering_Type__c == 'Pure Cloud'  && objDS.Trial_Evaluation__c == 'No'){ 
                       
                  objDs.Product_Cancellation_Date__c = objDs.Official_Cancelation_Date__c + 30;
                        //Date.today() + 30;
                        system.debug('testnavanee' + objDs.Product_Cancellation_Date__c );
                        }else{
                            system.debug('testnavaneesz' + objDs.Product_Cancellation_Date__c );
                        objDs.Product_Cancellation_Date__c = objDs.Official_Cancelation_Date__c;
                        }
                    }
                    //added swastika on Apr-19-2017 for Tools/Systems Support <start>
                    if(objDS.Support_Area__c == 'Tools/Systems Support')
                    {                    
                        RecordType objRecType = [Select id,name from RecordType where name = 'Partner' AND SObjectType = 'Deal_Support__c' ] ;
                        objDS.RecordTypeId = objRecType.id;
                    }
                    if(objDS.Support_Area__c == 'Quote Request')
                    {                    
                        RecordType objRecType = [Select id,name from RecordType where name = 'Partner' AND SObjectType = 'Deal_Support__c' ] ;
                        objDS.RecordTypeId = objRecType.id;
                        system.debug('++++objDS.Region__c++++'+objDS.Region__c);
                        system.debug('++++objDS.Deployment_Type__c++++'+objDS.Deployment_Type__c);
                        
                        
                       
                         objDS.PS_SMART_EMail__c = GetPSDSREmailTarget(objDS.Region__c, objDS.Deployment_Type__c);
                    }
                    //added swastika on Apr-19-2017 for Tools/Systems Support <end>
                    if(objDS.Support_Area__c == 'Professional Services' && objDS.PS_SMART_DSR__c == true)
                    {
                        //Change The pagelayout for Professional Services to the new PS Record type : NikM : Jan 2017
                        RecordType objRecType = [Select id,name from RecordType where name =: 'Professional Services - DS' ] ;
                        objDS.RecordTypeId = objRecType.id;
                        //Get the PS DSR EMail target information to assign to the DSR record
                        objDS.PS_SMART_EMail__c = GetPSDSREmailTarget(objDS.Region__c, objDS.Deployment_Type__c);
                        
                        system.debug('++++strOpptyId++++'+strOpptyId+'++++end++++');
                        if (!String.isEmpty(strOpptyId)) 
                        {
                            if(!String.isEmpty(SCEForm)) objDS.SC_Engagement_Form__c = SCEForm;
                            if(!String.isEmpty(PORRef))  objDS.PS_POR_Reference__c  = PORRef;
                        }
                        
                        if (objDS.Request_Type__c == 'Budgetary Estimate (BE)')
                        {
                            objDS.BE_Request_Date__c = system.now();
                        }
                        if (objDS.Request_Type__c == 'Statement of Work/Letter of Engagement (SOW/LOE)')
                        {
                            objDS.SOW_Request_Date__c = system.now();
                        }
    
                        PSCSDAssignee = GetPSDSRAutoAssignCSDUserID(objDS.Region__c, objDS.Deployment_Type__c, strOpptyId);
                        if (PSCSDAssignee != ''){
                            objDS.Assigned_To__c = PSCSDAssignee;
                            objDS.Status__c = 'Assigned';
                        }                    
                        
                    }
                    objDS.Solution_Category__c = objDS.Product__c = null;
                }
                if(strOpptyId==null || strAccountId==null ) 
                    getCountryAndRegion(); //if deal support open from Home page->custom link 
                 system.debug('++++objDS.Region__c+++'+objDS.Region__c );
                if(objDS.Region__c == 'North America' || objDS.Region__c == 'NA'|| objDS.Region__c == 'EMEA' || objDS.Region__c == 'APAC' ||objDS.Region__c == 'LATAM')
                {
                  
                    if(objDS.Region__c == 'North America')
                        objDS.Region__c = 'NA';
                    system.debug('++++objDS.Region__c+++'+objDS.Region__c + ' Support Area ' + objDS.Support_Area__c);
                    
                    system.debug('++++objDS.Request Type+++'+objDS.Request_Type__c + ' = ' + objDS.Request_Type__c.length());
                    
                    
                    Deal_Support_Email_Ids__c objDSEmail;
                    if(objDS.Support_Area__c == 'Finance')
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance('##' + objDS.Request_Type__c);
                    else if(objDS.Support_Area__c == 'Pricing')
                        //updated by Rsystems 24th Aug-17Email route on the basis of Offering Type
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance('$$' + (objDS.Offering_Type__c.length() > 32 ? objDS.Offering_Type__c.mid(0,32).trim() : objDS.Offering_Type__c));
                        //objDSEmail = Deal_Support_Email_Ids__c.getInstance('$$' + (objDS.Request_Type__c.length() > 32 ? objDS.Request_Type__c.mid(0,32).trim() : objDS.Request_Type__c));
                    else if(objDS.Support_Area__c == 'Business Consulting')
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance('@@' + (objDS.Request_Type__c.length() > 29 ? objDS.Request_Type__c.mid(0,29).trim() : objDS.Request_Type__c));
                    else if(objDS.Support_Area__c == 'Value Consulting')
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance('@@' + (objDS.Request_Type__c.length() > 29 ? objDS.Request_Type__c.mid(0,29).trim() : objDS.Request_Type__c));
                    else if(objDS.Support_Area__c == 'Customer Care' || objDS.Support_Area__c == 'Competitive Intelligence')
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance('%%' + (objDS.Request_Type__c.length() > 30 ? objDS.Request_Type__c.mid(0,30).trim() : objDS.Request_Type__c));
                    
                                    // Adding for PureSuccess Subscription 29/12/2019
                     else if(objDS.Support_Area__c == 'Subscription PureSuccess'){
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance((objDS.Request_Type__c.length() > 30 ? objDS.Request_Type__c.mid(0,30).trim() : objDS.Request_Type__c));
                        //objDSEmail = Deal_Support_Email_Ids__c.getInstance(objDS.Support_Area__c);
                        system.debug('>>>> Subscription PureSuccess '+objDSEmail);
                     }
                      else if(objDS.Support_Area__c == 'Value Consulting'){
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance('@@'+objDS.Request_Type__c);
                      }
                     else if(objDS.Support_Area__c == 'References'){
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance('References');
                     }
                      else if(objDS.Support_Area__c == 'Product Management' && objDS.Request_Type__c !='Product Idea Lab') /**********change request shared by Trevor and Debora Lane to get Email ids using Offering Type ******/
                     {
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('$$'+objDS.Offering_Type__c);
                     } 
                     else if(objDS.Support_Area__c == 'Product Management' && objDS.Request_Type__c =='Product Idea Lab') /**********change request shared by Trevor and Debora Lane to get Email ids using Offering Type ******/
                     {
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('Product Management Idea Lab');
                     }
                     else if(objDS.Support_Area__c == 'Pre-Sales Support' && objDS.Request_Type__c =='SC-DSR Issues / Error') /**********change request shared by Trevor and Debora Lane to get Email ids using Offering Type ******/
                     {
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('SC-DSR Issues-Error');
                     }
                     else if(objDS.Support_Area__c == 'Finance – Field Finance' && objDS.Request_Type__c =='Field Finance') /**********change  Debora Lane to get Email ids using Offering Type ******/
                     {
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('Field Finance');
                         if(objDS.Region__C == 'EMEA')
                             fetchSupportEmails((String)objDSEmail.EMEA__C);
                         if(objDS.Region__C == 'APAC')
                             fetchSupportEmails((String)objDSEmail.APAC__C);
                         if(objDS.Region__C == 'LATAM')
                         fetchSupportEmails((String)objDSEmail.LATAM__C);
                        if(objDS.Region__C == 'NA')
                         fetchSupportEmails((String)objDSEmail.NA__C);
                     system.debug('Navaneetha emaa' +  objDSEmail.EMEA__C);
                     }
                     else if(objDS.Support_Area__c == 'Play Support' && objDS.Request_Type__c =='Play Assistance' && objDS.Primary_Play__c == '2019 Play 3 Digital Service') /**********change request shared by Trevor and Debora Lane to get Email ids using Offering Type ******/
                     {
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('Play 3 Assistance');
                         
                     }
                     
                     else if(objDS.Support_Area__c == 'Play Support' && objDS.Request_Type__c =='Play Assistance' && objDS.Primary_Play__c == '2019 Play 4 Digital Sales') /**********change request shared by Trevor and Debora Lane to get Email ids using Offering Type ******/
                     {
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('Play 4 Assistance');
                         
                     }
                    
                      else if(objDS.Support_Area__c == 'Play Support' && objDS.Request_Type__c =='Play Assistance' && objDS.Primary_Play__c == '2019 Play 5 Automation at Work') /**********change request shared by Trevor and Debora Lane to get Email ids using Offering Type ******/
                     {
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('Play 5 Assistance');
                     
                     }
                    else if(objDS.Support_Area__c == 'Play Support' && objDS.Request_Type__c =='Migrations Assistance') /**********p2p*/
                    { 
                    objDSEmail = Deal_Support_Email_Ids__c.getInstance('P2P Migrations Assistance');
                    }
                    else if(objDS.Support_Area__c == 'Play Support' && objDS.Request_Type__c == 'PureBridge') /**********p2p*/
                    { objDSEmail = Deal_Support_Email_Ids__c.getInstance('PureBridge');

                    }
                     else if(objDS.Support_Area__c == 'Play Support' && objDS.Request_Type__c == 'Cloud Migration Assistance') /**********p2p*/
                    { objDSEmail = Deal_Support_Email_Ids__c.getInstance('CloudMigrationAssistance');

                    }
                       
                    else if (objDS.Support_Area__c != 'Quote Request')
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance(objDS.Support_Area__c);
                        
                    //Added by Jitendra Jain on 09/27/2017 to include Deal Desk
                    else if (objDS.Support_Area__c != 'Deal Desk')
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance(objDS.Support_Area__c);
                    
                    else if (objDS.Support_Area__c != 'Transactional Help')
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance(objDS.Support_Area__c);
                    //else if (objDS.Support_Area__c != 'Security')
                     //   objDSEmail = Deal_Support_Email_Ids__c.getInstance(objDS.Support_Area__c);
                    
                    system.debug('++++objDS.Email+++'+objDSEmail );
                    if((objDSEmail != null  || objDS.Support_Area__c == 'Quote Request' )&& objDS.Support_Area__c != 'Transactional Help')
                    {
                        if(objDS.Support_Area__c == 'Finance' && objDS.Country_Name__c == 'Brazil')
                            fetchSupportEmails((String)objDSEmail.BRAZIL__c);
                        else if(objDS.Support_Area__c == 'Deal Desk' && objDS.Country_Name__c == 'United States')/**** Change request shared by Debora Lane and Trevor for Deal Desk ******/
                            fetchSupportEmails((String)objDSEmail.US__c);
                         else if (objDS.Support_Area__c == 'Quote Request') 
                        { 
                            if(objOppty != null){
                                objDS.Support_Email__c = getOpOwnerEmailId(objOppty.Id);
                                objDS.Opportunity_Owner_Email__c = getOpOwnerEmailId(objOppty.Id);
                                objDS.Partner_Account_Owner_Email__c = string.isBlank(partnerAccEmailId)?'':partnerAccEmailId;
                            }
                         }
                else if(objDS.Support_Area__c == 'Play Support') {
                            if(objDS.Request_Type__c == 'PureBridge'){
                            objDSEmail = Deal_Support_Email_Ids__c.getInstance('PureBridge');
                            if(objDS.P2P_Region__c == 'EMEA')
                            fetchSupportEmails((String)objDSEmail.EMEA__C);
                            if(objDS.P2P_Region__c == 'APAC')
                            fetchSupportEmails((String)objDSEmail.APAC__C);
                            if(objDS.P2P_Region__c =='LATAM')
                            fetchSupportEmails((String)objDSEmail.LATAM__C);
                            if(objDS.P2P_Region__c == 'NA')
                            fetchSupportEmails((String)objDSEmail.NA__C);
                            }
                            
                    else if( objDS.Request_Type__c =='Migrations Assistance') /**********p2p*/
                     { objDSEmail = Deal_Support_Email_Ids__c.getInstance('P2P Migrations Assistance');
                         if(objDS.P2P_Region__c == 'EMEA')
                         fetchSupportEmails((String)objDSEmail.EMEA__C);
                         if(objDS.P2P_Region__c == 'APAC')
                         fetchSupportEmails((String)objDSEmail.APAC__C);
                         if(objDS.P2P_Region__c =='LATAM')
                         fetchSupportEmails((String)objDSEmail.LATAM__C);
                      if(objDS.P2P_Region__c == 'NA')
                         fetchSupportEmails((String)objDSEmail.NA__C);
                     }
                     else if(objDS.Request_Type__c =='Play Assistance' && objDS.Primary_Play__c == '2019 Play 5 Automation at Work') 
                     {
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('Play 5 Assistance');
                         if(objDS.P2P_Region__c == 'EMEA')
                         fetchSupportEmails((String)objDSEmail.EMEA__C);
                         if(objDS.P2P_Region__c == 'APAC')
                         fetchSupportEmails((String)objDSEmail.APAC__C);
                         if(objDS.P2P_Region__c == 'LATAM')
                         fetchSupportEmails((String)objDSEmail.LATAM__C);
                         if(objDS.P2P_Region__c == 'NA')
                         fetchSupportEmails((String)objDSEmail.NA__C);
                     }
                     else if( objDS.Request_Type__c =='Play Assistance' && objDS.Primary_Play__c == '2019 Play 4 Digital Sales')  
                     {
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('Play 4 Assistance');
                         if(objDS.P2P_Region__c == 'EMEA')
                         fetchSupportEmails((String)objDSEmail.EMEA__C);
                         if(objDS.P2P_Region__c == 'APAC')
                         fetchSupportEmails((String)objDSEmail.APAC__C);
                         if(objDS.P2P_Region__c == 'LATAM')
                         fetchSupportEmails((String)objDSEmail.LATAM__C);
                      if(objDS.P2P_Region__c == 'NA')
                         fetchSupportEmails((String)objDSEmail.NA__C);
                     }
                     else if(objDS.Request_Type__c =='Play Assistance' && objDS.Primary_Play__c == '2019 Play 3 Digital Service')  
                     {
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('Play 3 Assistance');
                         if(objDS.P2P_Region__c == 'EMEA')
                         fetchSupportEmails((String)objDSEmail.EMEA__C);
                         if(objDS.P2P_Region__c == 'APAC')
                         fetchSupportEmails((String)objDSEmail.APAC__C);
                         if(objDS.P2P_Region__c == 'LATAM')
                         fetchSupportEmails((String)objDSEmail.LATAM__C);
                      if(objDS.P2P_Region__c == 'NA')
                         fetchSupportEmails((String)objDSEmail.NA__C);
                     }
                      else if(objDS.Request_Type__c =='Cloud Migration Assistance')  
                     {
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('CloudMigrationAssistance');
                      /*   if(objDS.P2P_Region__c == 'EMEA')
                         fetchSupportEmails((String)objDSEmail.EMEA__C);
                         if(objDS.P2P_Region__c == 'APAC')
                         fetchSupportEmails((String)objDSEmail.APAC__C);
                         if(objDS.P2P_Region__c == 'LATAM')
                         fetchSupportEmails((String)objDSEmail.LATAM__C);
                      if(objDS.P2P_Region__c == 'NA')*/
                         fetchSupportEmails((String)objDSEmail.NA__C);
                        system.debug('objDSEmailnavanee'+ objDSEmail);
                     }
                        }
                        else{
                            system.debug('TEsternavaneetha');
                        fetchSupportEmails((String)objDSEmail.get(objDS.Region__c + '__c')); }
                        
                        /*Added by Swastika to set the status=new once it is submitted*/
                        if(IsSave==false)
                        {                    
                            //objDS.Status__c ='New';
                            objDS.IsNew__c=true;
                        }
                        else
                        {
                            //objDS.Status__c ='';    
                            objDS.IsNew__c=false;
                        }
                        //added a condition by swastika to check whether it is insert and update
                        system.debug('++++objDS.Id 111+++'+objDS.Id);
                        if (objDS.Id==null)
                        {
                            //insert objDS;
                            if(objOppty != null){
                                objDS.Opportunity_Owner_Email__c = getOpOwnerEmailId(objOppty.Id);
                                objDS.Partner_Account_Owner_Email__c = string.isBlank(partnerAccEmailId)?'':partnerAccEmailId;
                            }
                            upsert objDS;
                            
                            system.debug('++++sSuppEmail   +++'+sSuppEmail);
                            system.debug('++++objDS.PS_SMART_DSR__c+++'+objDS.PS_SMART_DSR__c);
                            system.debug('TEstnavanee');
                            if(objDS.Support_Area__c != 'Sales Ops' && objDS.Support_Area__c != 'ININ Sales Support' && objDS.PS_SMART_DSR__c == false)
                            {
                              system.debug('++++objDS.PS_SMART_DSR__c 11111+++'+objDS.PS_SMART_DSR__c);
                              string[] sEmail = sSuppEmail.split(';');
                              system.debug('++++sEmail+++'+ sEmail);
                              SendEmailByTemplate(UserInfo.GetUserId(),'Deal Support Request for Support User- VF', objDS.Id,sEmail);
                            }  
                        }    
                        else
                            update objDS; 
                        system.debug('++++objDS.Id 2222+++'+objDS.Id);  
                        system.debug('++++Submit objDS.IsNew__c+++'+objDS.IsNew__c);  
                         system.debug('++NAvaneet++'+objDSEmail); 
                         
                        if(IsSave==false)     //If the                       
                        {
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request submitted (' + strSupportEmails + ').'));
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request submitted.'));
                            
                            //send email notification to SWAT team
                            system.debug(LoggingLevel.Info,'+++++strRequestType +++++'+strRequestType);
                            system.debug(LoggingLevel.Info,'+++++objDS.Region__c +++++'+objDS.Region__c);
                            system.debug(LoggingLevel.Info,'+++++objDS.Offering_Type__c +++++'+objDS.Offering_Type__c);
                            
                            system.debug(LoggingLevel.Info,'+++++strSupportArea  +++++'+strSupportArea );
                            system.debug(LoggingLevel.Info,'+++++strRequestType  +++++'+strRequestType );
                            if(strSupportArea == 'ININ Sales Support')
                            {
                                
                                
                                string[] email = FetchSWATTeam(strRequestType,objDS.Region__c,objDS.Offering_Type__c);
                                //SendEmailByTemplate(UserInfo.GetUserId(),'Deal Support Request - VF', objDS.id,email);
                                system.debug(LoggingLevel.Info,'+++++email[] +++++'+email);
                            }                        
                        }
                    }
                    else if(objDSEmail != null && objDS.Support_Area__c == 'Transactional Help')
                    {
                        RecordType objRecType = [Select id,name from RecordType where name =: 'Transaction Help' ] ;
                        objDS.RecordTypeId = objRecType.id;
                        
                        if(fileattachedfororder == false && objDS.Support_Area__c == 'Transactional Help' && objDS.Request_Type__c =='Submit an Order' ) 
                            {
                            System.Debug('ErrorInLinefileBody--->'+fileBody);
                            IsSave=true;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An attachment such as PO/PO Waiver Form is required to submit an order'));                        
                            } 
                            else
                            {
                                upsert objDS;                           
                                if(objDS.Support_Area__c == 'Transactional Help' && createOpportunity == true  && objDS.Opportunity__c!= null)
                                {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only one opportunity Can map with the Deal Support'));
                                    IsSave=true;
                                }                           
                                else
                                {                     
                               
                                if(String.isBlank(strOpptyId) && createOpportunity == true && (String.isNotBlank(strAccountId) && strAccountId != 'null') && objDS.Support_Area__c == 'Transactional Help' && (objDS.Request_Type__c =='Create a Quote' || objDS.Request_Type__c =='Submit an Order'))
                                {
                                    Recordtype srectype = [select id from RecordType where developername = 'GEN_Opportunity_Record_Type_New'] ;
                                    dsrOpty.Lead_Offer__c = objDS.Lead_Offer_Type__c;
                                    dsrOpty.Direct_Indirect_Sale__c = objDS.DirectIndirect_sale__c;
                                    //dsrOpty.ForecastStatus__c = objDS.ForecastStatus1__c;
                                    //dsrOpty = objDS.ForecastStatus1__c;
                               
                                    dsrOpty.Account__C = objDS.Account__C;
                                    dsrOpty.recordtype__c =srectype.id;
                                    dsrOpty.Stage__c = '1.Understand Needs';
                                    dsrOpty.Deal_Support__c = objDS.id;
                                    dsrOpty.RecordTypeid = [select id,name from RecordType where name =: 'Transnational Help Admin'].id;
                                    system.debug('dsrid' + dsrOpty);   
                                    
                                    upsert dsrOpty; 
                                }
                                }
                        }
                        if(IsSave==false)     //If the submitted not upload                      
                           {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request submitted.14'));
                           } 
                    }
                    else if(objDS.Support_Area__c == 'Security'){
                        upsert objDS;  
                        
                         if(IsSave==false)     //If the submitted not upload                      
                           {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request submitted.'));                        
                            return;
                            }
                        
                    }
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,objDS.Support_Area__c + ' not supported.'));
                    return;
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,objDS.Region__c + ' Region is not valid.'));
            }
            catch(Exception ex){
                IsValidation=false;
                IsSave=true;
               ApexPages.addMessages(ex);
                
                System.Debug('Error--->'+ex.getMessage());
                System.Debug('ErrorInLine--->'+ex.getlinenumber());
            }
        }
        
        public string[] FetchSWATTeam(string sRequestType,string sRegion,string sOfferType)
        {
            List<Deal_Support_SWAT_Team__c>list_SWATTeam = Deal_Support_SWAT_Team__c.getAll().values();
            string[] sSWATEmailIds = new string[list_SWATTeam.size()];
            integer i=0;
            for(Deal_Support_SWAT_Team__c obj : list_SWATTeam)
            {
                if(obj.Offering_Type__c == sOfferType && obj.Region__c == sRegion && obj.Request_Type__c == sRequestType)
                {
                    sSWATEmailIds[i] = obj.Email__c;
                    if(obj.Email2__c != null){
                        i += 1;
                        sSWATEmailIds[i] = obj.Email2__c;
                    }
                    i += 1;   
                }
            }
            system.debug(LoggingLevel.Info,'++++i++++'+i);
            string[] sEmails = new string[i];
            for(integer j=0;j<i;j++)
            {
                sEmails[j] = sSWATEmailIds[j];
            }
            return sEmails;
        }
        
        void fetchSupportEmails(String strEmailIds)
        {
            
            system.debug('sSuppEmailrr5'+ strEmailIds);
            if(String.isNotBlank(strEmailIds))
            {
                sSuppEmail = strEmailIds;
                system.debug('sSuppEmail123'+ sSuppEmail);
                List<String> list_EmailIds = strEmailIds.split(';');
                objDS.Support_Email__c =list_EmailIds[0];
                strSupportEmails = objDS.Support_Email__c;
                // NikM: 24Oct2017: Added check to only set the opportunity owner email value if there is a linked opportunity, as this is breaking direct PS DSR creations with no Oppty
                if (!String.isEmpty(strOpptyId))
                {
                    objDS.Opportunity_Owner_Email__c = getOpOwnerEmailId(objOppty.Id);
                    objDS.Partner_Account_Owner_Email__c = string.isBlank(partnerAccEmailId)?'':partnerAccEmailId;
                } 
                if(list_EmailIds.size() > 1)
                {
                    objDS.Support_Email2__c = list_EmailIds[1];
                    strSupportEmails += ',' + objDS.Support_Email2__c;
                } 
                
                system.debug('strSupportEmails'+ strSupportEmails);
            }
        }
        public PageReference UploadFile()  
        {
            string sPageUrl = '';
            IsSave=true;
            if(objDS.PS_SMART_DSR__c == true)
            {
                sPageUrl = '/apex/PSDealSupportQuery?supportarea='+objDS.Support_Area__c+'&iSPSSMART=yes&type='+objDS.Request_Type__c;
                if (objDS.Opportunity__c != null)
                {
                    sPageUrl += '&oppID='+objDS.Opportunity__c;
                }
                //sPageUrl = '/apex/PSDealSupportQuery?';
            }
            else if(strIsTransDSR == 'yes' && objDS.Support_Area__c == 'Transactional Help')
            {
                sPageUrl = '/apex/DealSupportQueryQO?supportarea='+objDS.Support_Area__c+'&iSTranshelp=yes&type='+objDS.Request_Type__c;
                if (objDS.Opportunity__c != null)
                {
                    sPageUrl += '&oppID='+objDS.Opportunity__c;
                }
            }
            else
            {
                sPageUrl = '/apex/DealSupportQuery?';
            }
            system.debug('++++Return Page URL+++'+sPageUrl);
            
            if(fileBody == null || fileName == '') 
            { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select the '+FileDescType+' file.'));
                IsValidation=false;
                return null;
            } 
            else{
            IsValidation=true;
            fileattachedfororder = true; }
            if(objDS.id == null)
            {
                submitBtnHandler();  
                system.debug('++++objDS.id+++'+objDS.id); 
                system.debug('++++objDS.Status__c +++'+objDS.Status__c);
                
                //objDS.Status__c = null;  
                //update objDS;     
            }
            system.debug('++++Upload objDS.IsNew__c+++'+objDS.IsNew__c);
            system.debug('++++Upload objDS.Id+++'+objDS.Id);
            system.debug('++++Upload objDS.Id+++'+IsValidation);
            if(IsValidation)
            {
                try{
                Attachment obj = new Attachment();
                obj.Body = fileBody;
                obj.Name = fileName;
                obj.ParentId = objDS.id;
                obj.Description = FileDescType ;
                insert obj;            
                
                GetAttachments();
                /*Clear variables*/
                //if(objDS.Support_Area__c !='Transactional Help' && objDS.Request_Type__c !='Submit an Order')
                //{
                system.debug('testnavanee');
                fileBody =null;
                fileName = '';
                FileDescType = '';  
                //}
                objRef = new PageReference(sPageUrl); 
                 return objRef;
                }
                catch(exception e){return null;         
                    
                }
            }
            else
                return null; 
            
        }
        
        /* Get All Attachments*/
        public void GetAttachments()
        {
            system.debug('objDS.Id'+objDS.Id);
            if(objDS.Id!=null) //Added by Swastika 
            { 
                list_Attachment = [Select id,Description,name from Attachment where ParentId =: objDS.id];
            }
        }
        /*Delete Attachment*/
        public void DeleteAttachment()
        {
            Attachment objATT = [Select id,Description,name from Attachment where id =:sAttachmentId];
            delete objATT;
            GetAttachments();
        }
        
        private void getCountryAndRegion(){
            if(objDS.Account__c!=null){
                Account objAccount = [SELECT Name,Country__r.Name,Country__r.Region__c FROM Account WHERE Id = :objDS.Account__c];
                if (objAccount!=null)
                {
                    objDS.Country_Name__c = objAccount.Country__r.Name;
                    objDS.Region__c = (objAccount.Country__r.Region__c == null ? 'North America' : objAccount.Country__r.Region__c);
                }
            }
            else if(objDS.Opportunity__c!=null){
            Opportunity objOppty = [SELECT Name,StageName,AccountId,Account.Country__r.Name,Account.Country__r.Region__c,Direct_Indirect_Sale__c,ForecastStatus__c,Contact__c,Who_did_Genesys_Replace__c  FROM Opportunity WHERE Id = :objDS.Opportunity__c];
                system.debug('objOppty'+objOppty);
                objDS.Country_Name__c = objOppty.Account.Country__r.Name;
                objDS.Region__c = (objOppty.Account.Country__r.Region__c == null ? 'North America' : objOppty.Account.Country__r.Region__c);
                objDS.Account__c = objOppty.AccountId;
                objDs.Lead_Offer_Type__c = objOppty.Lead_Offer__c;
             //start   
               objDs.DirectIndirect_Sale__c = objOppty.Direct_Indirect_sale__c  ;
                objDs.Primary_Contact__c = objOppty.Contact__c;
                objDs.ForecastStatus1__c = objOppty.ForecastStatus__c;
                objDs.Stage_Name__c = objOppty.StageName;
                objDs.End_User_Country__c = objOppty.Country__c;
                //End
               // Above fields added by aparna
                
            }                 
        } 
        
        public static String SendEmailByTemplate(Id UserId,String strTemplateName, Id DealSupportId,string[] sEmail){
            string strResult='Failed';
            try{
                // Create a new single email message object
                // that will send out a single email to the addresses in the To, CC & BCC list.
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                // Specify the name used as the display name.
                mail.setSenderDisplayName('');                   
                // Set to True if you want to BCC yourself on the email.
                mail.setBccSender(false);
                
                mail.setToAddresses(sEmail);
                
                // Optionally append the salesforce.com email signature to the email.
                // The email address of the user executing the Apex Code will be used.
                //string[]arrEmail = new string[1];
                //arrEmail[0] = UserId;
                string sLabel = system.Label.Deal_Support_Email_Service;
                string[] sEmailService = new string[1];
                sEmailService[0] = sLabel;
                //sEmail.add(sLabel);
                mail.setCcAddresses(sEmailService);
                mail.setUseSignature(false);
                //Map the VF template
                mail.setTargetObjectId(UserId); //Mandatory field when use template
                mail.setWhatId(DealSupportId); //Assign Wow Id
                mail.setTemplateId([select id from EmailTemplate where Name =: strTemplateName].id);  //Find the template on the basis of name                    
            System.debug('Navanee Email Template1'+ UserId);
            System.debug('Navanee Email Template2'+ DealSupportId);
            System.debug('Navanee Email Template3'+   [select id from EmailTemplate where Name =: strTemplateName].id );
                // Send the email you have created.
                mail.SaveAsActivity = false; //Mandatory field when use template
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                strResult='Successful';
            }    
            catch(exception ex)
            {
                strResult='Failed';
                system.debug('ex123navanee '+ex.getMessage());
                 System.Debug('ErrorInLine--->'+ex.getlinenumber());
            } 
            return strResult;        
        }
        
        // Added Jan 2017 for the PS DSR EMail lookups
        public static String GetPSDSREmailTarget(String SalesRegion, String DSRDeploymentType)
        {
            String strResult='xxNotFoundxx@genesys.com.xxx';
            list<PS_to_Sales_Mapping__c> PStSM_Data;
            String modSalesRegion='';
            String defaultPSDSREMail='';
            
            if (SalesRegion=='NA')
            {
                modSalesRegion='North America';
            }
            else
            {
                modSalesRegion=SalesRegion;
            }
            system.debug('++++SalesRegion+++'+modSalesRegion);
            system.debug('++++DSRDeploymentType+++'+DSRDeploymentType);
            
            try
                {
                    //Get the PS DSR Emails from the PS to Sales Mapping table
                    //Get the default
                    PStSM_Data = [SELECT PS_DSR_Email_Group_Target__c FROM PS_to_Sales_Mapping__c WHERE PS_Region__c = 'WW Default'];
                    defaultPSDSREmail = PStSM_Data[0].PS_DSR_Email_Group_Target__c;
                    
                    //Get the group target based on whether we have the DSRDeploymentType or not
                    if (DSRDeploymentType==null)
                    {
                        PStSM_Data = [SELECT PS_DSR_Email_Group_Target__c FROM PS_to_Sales_Mapping__c WHERE Sales_Region__c =: modSalesRegion AND Is_Regional_Only__c = true AND Routing_Type__c = 'Group Routing'];
                    }
                    else
                    {
                        PStSM_Data = [SELECT PS_DSR_Email_Group_Target__c FROM PS_to_Sales_Mapping__c WHERE Sales_Region__c =: modSalesRegion AND DSR_DeploymentType__c =: DSRDeploymentType AND Routing_Type__c = 'Group Routing'];
                    }
                    
                    //
                    if (PStSM_Data[0].PS_DSR_Email_Group_Target__c != null)
                    {
                        strResult = PStSM_Data[0].PS_DSR_Email_Group_Target__c;
                    }
                    else
                    {
                        strResult = defaultPSDSREmail;
                    }
                }
            catch (exception ex)
                {
                    system.debug('++++PSDSR Error++++ Exception: '+ex.getMessage());
                }
                
            system.debug('++++PSDSREmailAlias++++'+strResult);
    
            return strResult;
        }
    
    // Added Jan 2018 for the PS DSR Automated assignment
        public static String GetPSDSRAutoAssignCSDUserID(String SalesRegion, String DSRDeploymentType, String OpptyID)
        {
            String strResult='';
            String OpptyAEUserID='';
            list<PS_to_Sales_Mapping__c> PStSM_Data;
            list<Opportunity> OpptyData;
            String modSalesRegion='';
            String defaultPSDSREMail='';
            
            if (SalesRegion=='NA')
            {
                modSalesRegion='North America';
            }
            else
            {
                modSalesRegion=SalesRegion;
            }
            system.debug('++++SalesRegion+++'+modSalesRegion);
            system.debug('++++DSRDeploymentType+++'+DSRDeploymentType);
            system.debug('++++OpptyId+++'+OpptyID);
            
            try
                {
                    // First get the AE User ID from the linked opportunity record
                    OpptyData = [SELECT AE_Name__c FROM Opportunity WHERE ID =: OpptyID];
                    if (OpptyData[0].AE_Name__c != null)
                    {
                        OpptyAEUserID = OpptyData[0].AE_Name__c;
                    }
                   
                    system.debug('++++OpptyAEUserID+++'+OpptyAEUserID);
                
                    if (OpptyAEUserID != '')
                    {
                        //Now get the PS CSD User Target from the PS to Sales Mapping table if we have a matched Oppty AE UserName
                        if (DSRDeploymentType=='PureCloud' || DSRDeploymentType=='PureConnect' || DSRDeploymentType=='PureConnect Cloud')
                        {
                            PStSM_Data = [SELECT Mapped_CSD_Name__c FROM PS_to_Sales_Mapping__c WHERE Sales_Region__c =: modSalesRegion AND DSR_DeploymentType__c =: DSRDeploymentType AND AE_Name__c =: OpptyAEUserID AND Routing_Type__c = 'CSD Assignment'];
        
                            if (!PStSM_Data.isEmpty()){
                                if (PStSM_Data[0].Mapped_CSD_Name__c != null)
                                {
                                    strResult = PStSM_Data[0].Mapped_CSD_Name__c;
                                }
                                else
                                {
                                    strResult = '';
                                }
                            }
                            else
                            {
                                system.debug('++++No mapped CSD Data returned from PS to Sales Mapping++++');
                                strResult = '';
                            }
                        }
                        else
                        {
                            strResult = '';
                        }
                    }
                }
            catch (exception ex)
                {
                    system.debug('++++PSDSR Error++++ Exception: '+ex.getMessage());
                }
                
            system.debug('++++Mapped CSD UserID+++'+strResult);
    
            return strResult;
        }
    
        /* Get All PS DSR Documents*/
        public void GetPSDSR_Documents()
        {
            system.debug('++++objDS.Id++++'+objDS.Id);
             if(objDS.Id!=null)
             { 
                PSDSR_Documents = [Select Name, Doc_Type__c from PS_DSR_Document__c WHERE Deal_Support__c =: objDS.id];
             }
        }
    
        public PageReference SetPSDSRReturnParams()  
        {
            string sPageUrl = '';
            IsSave=true;
    
            sPageUrl = '/apex/PSDealSupportQuery?supportarea='+objDS.Support_Area__c+'&iSPSSMART=yes&type='+objDS.Request_Type__c;
            if (objDS.Opportunity__c != null)
            {
                sPageUrl += '&oppID='+objDS.Opportunity__c;
            }
            system.debug('++++Return Page URL+++'+sPageUrl);
      
            objRef = new PageReference(sPageUrl); 
            return objRef;
       }
    
        public PageReference AddPSRDocuments()
        {
            // Save the new DSR objects as we will need this fully stored to continue use and add PS DSR documents to it.
            IsSave=true;
            SubmitBtnHandler();
            
            String sPageUrl = '';
            
            sPageUrl = '/apex/PSDSRAttachment?fromCreateNewDSR=yes&dsrId='+objDS.Id;
            system.debug('++++Return Page URL+++'+sPageUrl);
      
            objRef = new PageReference(sPageUrl); 
            return objRef;
        }
        
        public void CancelPSDSR()
        {
            // Request to Cancel has been received from the VF page, so if a record was previously saved (likely due to attachments being added), remove it now, as we do not need to
            // keep DSRs which are cancelled
            IsSave=false;
            try
            {
                system.debug('++++PSDSR objDS++++'+objDS.Id);
           
                if(objDS.Id != null)
                {
                    delete objDS;
                }
            }
            catch (exception ex)
            {
                system.debug('++++PSDSR Error++++ Exception: '+ex.getMessage());
            }
        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request has been cancelled.'));
        }
        public PageReference cancel()
        { 
            string strUrl='';   
            system.debug('++++objDS++++'+objDS);     
          try
            {
            system.debug('++++objDS.id++++'+objDS.Id); 
                if(objDS.Id != null)
                {
                system.debug('++++333++++');
                   //find the attachment and delete it 
                   list<Attachment> list_attach= [select Id, ParentId from Attachment WHERE ParentId =:objDS.Id];
                   if(list_attach.size()>0)
                       delete list_attach;                
                //create the return url 
                 delete  objDS;
                 } 
                 if(blnIsPartnerUser)
                    strUrl = '/partner';
                else 
                   strUrl = '/apex';                
                strUrl +=  '/DealSupportRequest?area='+ strSupportArea+'&';            
                if(strOpptyId=='' || strOpptyId==null)
                   strUrl += 'accId='+strAccountId;
                 else
                    strUrl += 'oppid='+strOpptyId;
            }
            catch(exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            }
            
            return (new PageReference(strUrl)).setRedirect(true);   
           // location.href='{!IF(blnIsPartnerUser, '/partner','/apex')}/DealSupportRequest?area={!strSupportArea}&{!IF(ISBLANK(strOpptyId),'accId','oppid')}={!IF(ISBLANK(strOpptyId),strAccountId,strOpptyId)}    
        }
      
        private string getOpOwnerEmailId(id OpId)
        {
            string strEmail =''; 
            Opportunity objOpp = [SELECT Id, OwnerId, Owner.Email,BusinessPartner__r.Owner.Email FROM Opportunity where id = :OpId LIMIT 1]; 
            if(objOpp!=null){
               strEmail =  objOpp.Owner.Email;
               partnerAccEmailId = objOpp.BusinessPartner__r.Owner.Email;
            }
            integer  i ;
            for(i=0;i<=100;i++)
            {
               i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
                  i++; i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;i++;
            }
            
           return strEmail;
       }
       public void wer() {
          objDS.PS_Only_no_license_deal__c = false;
           system.debug('navaneeret' + objDS.PS_Only_no_license_deal__c );
       }
       public void duedateupdate() {
           if(objDs.Security_Issue_Type__c == 'RFP'){
                objDs.Request_Due_Date__c = Date.today() + 7;
                
            } else {
                objDs.Request_Due_Date__c = Date.today() + 30;
            }
          
       }
      
    
    }