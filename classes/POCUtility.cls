/*
Created By:     Swastika Rajkhowa
Company:        Rsystems
Description:    To create common functions for POC Request form    
*/
public class POCUtility { 
    public static boolean IsVirtualTeamExist(string POCId,string LogInUser){
             boolean IsExist=false;         
             List<POCVirtualUser__c> list_VT= [SELECT Solution_Consultant__c FROM POCVirtualUser__c WHERE POC_Engagement_Request__c=:POCId AND Solution_Consultant__c =:LogInUser];
             if(list_VT.size()>0)
                IsExist=true;           
             return IsExist;
         } 
         
    //Insert the history data for wow request
    public static Void CreateHistory(string Action,string UserId, string UserType, string POCStage,string Status, Id POCId){
        POC_Request_Form_History__c objPOCHst=new POC_Request_Form_History__c();
        objPOCHst.Action__c=Action;
        objPOCHst.UserId__c=UserId;
        objPOCHst.Action_Date__c=System.now();
        objPOCHst.POC_User_Type__c=UserType;
        objPOCHst.POC_Engagement_Status__c=Status;
        objPOCHst.POC_Request_Id__c=POCId;
        objPOCHst.POC_Stage__c=POCStage;
        insert objPOCHst;
    }

    //Insert the history data for wow request attachments
    public static Void CreateHistory(string Action,string AttachmentType, string AttachmentSubType, string UserId, string UserType, string POCStage,string Status, Id POCId){
        POC_Request_Form_History__c objPOCHst=new POC_Request_Form_History__c ();
        objPOCHst.Action__c=Action;
        objPOCHst.UserId__c=UserId;
        objPOCHst.Action_Date__c=System.now();
        objPOCHst.POC_User_Type__c=UserType;
        objPOCHst.POC_Stage__c=POCStage;
        objPOCHst.POC_Engagement_Status__c=Status;
        objPOCHst.POC_Request_Id__c=POCId;
        objPOCHst.Attachment_Type__c=attachmenttype;        
        insert objPOCHst;
    } 
    
    public static string GetUserType(id UserID, Id POCID, string Event){
        string strResult='';
        //get profile Id of user
        string sProfileName = WoWUtility.GetProfileName(userinfo.getProfileId());  
        List<POC_Engagement_Request__c> lstPOC=new List<POC_Engagement_Request__c>();
        lstPOC=[SELECT Id, AE__c,Assignto__c,Opportunity_Id__r.End_User_Region__c,Opportunity_Id__r.Country_Sub_Region__c FROM POC_Engagement_Request__c WHERE Id=:POCID];
           
        if(lstPOC.size()>0){ 
            if (lstPOC[0].Assignto__c== 'Lead Assign')
               if(UserID==lstPOC[0].AE__c) 
                    strResult='AE';
                else If (sProfileName=='System Administrator')  
                     strResult='System Administrator';
                else
                   strResult='Other'; 
               
            else if(lstPOC[0].Assignto__c=='AE' )
               if (WoWUtility.getSubRegionalUsers(lstPOC[0].Opportunity_Id__r.End_User_Region__c,lstPOC[0].Opportunity_Id__r.Country_Sub_Region__c,UserINfo.getUserName()))    
                    strResult='Leadership';
               else if(UserID==lstPOC[0].AE__c) 
                    strResult='AE';
                else If (sProfileName=='System Administrator')  
                     strResult='System Administrator';
                else
                   strResult='Other'; 
                      
            else if ((lstPOC[0].Assignto__c=='Virtual Team' || lstPOC[0].Assignto__c=='Virtual Team for Result') && Event== null)
                {
                //If the user not exist in the queue
                 if (!WoWUtility.getSubRegionalUsers(lstPOC[0].Opportunity_Id__r.End_User_Region__c,lstPOC[0].Opportunity_Id__r.Country_Sub_Region__c,UserINfo.getUserName()))
                     {
                         if (sProfileName=='System Administrator')
                              strResult='System Administrator';
                         else
                             strResult='Other';   
                     }
                 else //User Exist in the Sub regional leader
                        strResult='Leadership';   
                }
            else if((lstPOC[0].Assignto__c=='Virtual Team' && Event=='Save') || lstPOC[0].Assignto__c== 'Lead Completed') 
            {
                if(IsVirtualTeamExist(lstPOC[0].Id,UserINfo.getUserId()))  
                    strResult='Solution Consultant';                 
                else if(sProfileName=='System Administrator')  
                    strResult='System Administrator';
                else
                    strResult='Other';        
            
              }             
         }     
        return strResult;
   }    
   public static String SendEmailNotification(string NotificationType, Id POCId,List<POCVirtualUser__c>NewVT){
        string strResult='Failed';
        list<Group> lstGroup=new List<Group>();
        list<GroupMember> lstGroupMem = new list<GroupMember>(); 
        list<User> lstUser=new list<User>();
        list<POCVirtualUser__c> list_OldVT = new  list<POCVirtualUser__c>();
        //Find current user and user name
        User Usr = new User();
        Usr = [SELECT Id,Name FROM User WHERE Id = : UserInfo.getUserId()];
        
        //Find the opportunity region
        list<POC_Engagement_Request__c> lstPOC=[SELECT Id,Opportunity_Id__c,Opportunity_Id__r.Country_Sub_Region__c,Opportunity_Id__r.Owner.Id,Opportunity_Id__r.Region__c,Opportunity_Id__r.Name,Opportunity_Id__r.Owner.Name,Opportunity_Id__r.Owner.Email,Opportunity_Id__r.End_User_Region__c,AE__c,AE__r.Name, AE__r.Email,lastModifieddate FROM POC_Engagement_Request__c WHERE Id=:POCId]; 
        system.debug('lstPOC '+lstPOC); 
        
        //Find the account Name from opportunity 
        list<Opportunity> lstOpp=[SELECT Account.Name,End_User_Region__c,Country_Sub_Region__c,Owner.Segment__C, Owner.Owner_Sub_Region__c,Lines_of_Businesses__c  FROM Opportunity WHERE Id=:lstPOC[0].Opportunity_Id__c];
        
        //01/11/19 Muthu Added the code
        string offeringtype = lstOpp[0].Lines_of_Businesses__c;
       
        //List<string> ListSubRegionalUser=WOWUtility.getSubRegionalUsersForSharing(lstPOC[0].Opportunity_Id__r.End_User_Region__c,lstPOC[0].Opportunity_Id__r.Country_Sub_Region__c);        
        try{ 
            system.debug('NotificationType &&&&'+NotificationType); 
              //POC Engagement Lead Assigned- Notify the Leader while submit POC
              if(NotificationType=='Lead Assigned' || NotificationType=='Lead Approval' || NotificationType=='Lead Completed') //then find the members and their email ids in queue
                {
                    //List<string> ListSubRegionalUser=WOWUtility.getSubRegionalUsersForSharing(lstPOC[0].Opportunity_Id__r.End_User_Region__c,lstPOC[0].Opportunity_Id__r.Country_Sub_Region__c);  
                    
                    // Method added RSystems 28-09-2917
                    List<string> ListSubRegionalUser=getSubRegionalNewUsersForSharing(lstOpp[0].Owner.Segment__C,lstOpp[0].Owner.Owner_Sub_Region__c, lstOpp[0].Lines_of_Businesses__c);  
                    //fetch email of Custom settting
                    Set<string> objUID=new Set<string>();
                    for(string obj: ListSubRegionalUser)
                        objUID.Add(obj);
                       
                    lstUser=[SELECT Name,Email FROM User WHERE UserName=:objUID];
                }
                //Find the list of email ids from queue if Notificationtype=Lead
                if(NotificationType=='Lead Assigned')
                {
                    //added user in send to array
                    //1/11/19 Muthu Added the code
                    Set<String> AddUsrId = new Set<String>();                   
                    List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
                    for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion)
                    {
                       if(objSubRegion.Segment__c == 'LeadAssignedAddionalEmails')
                       {
                           AddUsrId.add(objSubRegion.User_Name__c);
                           system.debug('<---'+objSubRegion.User_Name__c+'--->');
                       }
                       if(objSubRegion.Name == offeringtype)
                       {
                           String emailIds = String.isnotblank(objSubRegion.Region__c)?objSubRegion.Region__c+';'+objSubRegion.Segment__c:objSubRegion.Segment__c;    
                           List<String> emailList=new List<String>(); 
                           if(!String.isBlank(emailIds))                            
                           emailList = emailIds.split(';');
                           for(String email:emailList)
                           {
                           AddUsrId.add(email);
                           system.debug('<---'+email+'--->');
                           }
                       }
                    }
                    List<User> AddUsr = [SELECT Id,Name FROM User WHERE Email IN : AddUsrId];
                    if(AddUsr.size()>0)
                    lstUser.addAll(AddUsr);
                    //1/11/19 Muthu Code ends here
                    //added user in send to array
                    for(User objUser:lstUser)
                    {
                         system.debug('<---'+objUser.Id+'--->');
	                     SendEmailByTemplate(objUser.Id,'POC Engagement Lead Assigned',lstPOC[0].Id);                                             
                    }                    
                 }
                 else if (NotificationType=='Lead Rejected'){
                     system.debug('Lead Rejected &&&'); 
                      SendEmailByTemplate(lstPOC[0].Opportunity_Id__r.Owner.Id,'POC Engagement Lead Rejected',lstPOC[0].Id); 
                  }
                 else if (NotificationType=='Lead Approval'){
                     //added user in send to array
                    for(User objUser:lstUser)
                    {
                       SendEmailByTemplate(objUser.Id,'POC Engagement Lead Approval',lstPOC[0].Id);                                             
                    }  
                  } 
                else if (NotificationType=='Lead Completed'){
                     //added user in send to array
                    for(User objUser:lstUser)
                    {
                       SendEmailByTemplate(objUser.Id,'POC Engagement Lead Completed',lstPOC[0].Id);                                             
                    }  
                  }    
                //POC Engagement Lead Submitted- AE submit POC 
                else if (NotificationType=='Lead Submitted') 
                 {
                      SendEmailByTemplate(lstPOC[0].Opportunity_Id__r.Owner.Id,'POC Engagement Lead Submitted',lstPOC[0].Id);                     
                 }                
                //POC Engagement Virtual Team Assigned - Notification to virtual team once it is assigned by Leader  
                else if(NotificationType=='Virtual Team Assigned' || NotificationType=='Lead Approved')
                {                     
                    Set<Id>set_UId = new Set<Id>();                   
                    list_OldVT =[SELECT Solution_Consultant__c FROM POCVirtualUser__c Where POC_Engagement_Request__c=:POCId];
                    //List<POCVirtualUser__c> list_VT=getDiffVTList(NewVT,list_OldVT );
                    System.debug(LoggingLevel.Info, '**NewVT** '+NewVT);
                     
                    //for(POCVirtualUser__c objVTUser : list_VT)
                    for(POCVirtualUser__c objVTUser : NewVT)
                        set_UId.add(objVTUser.Solution_Consultant__c);
                          
                    system.debug('++++set_UId+++'+set_UId);
                    List<User>lstUs = [Select id,name,email from User where id IN : set_UId];
                    System.debug(LoggingLevel.Info, '**lstUs** '+lstUs );
                    //Send Email for SC
                    if(NotificationType=='Virtual Team Assigned'){
                        for(User objU:lstUs)
                        {
                          SendEmailByTemplate(objU.Id,'POC Engagement Virtual Team Assigned',lstPOC[0].Id);
                        } 
                     }
                    /*else if(NotificationType=='Lead Rejected'){  
                      for(User objU:lstUs)
                        {
                          SendEmailByTemplate(objU.Id,'POC Engagement Lead Rejected',lstPOC[0].Id);
                        } 
                     }*/
                 }                
                 //POC Engagement Lead Approval - virtual team submit POC for approval to Leader
                
                /*else if(NotificationType=='Virtual Team Assigned')
                { 
                     system.debug('++++In Wow Utility Virtusal Team+++');
                     system.debug('++++lstWoW[0].SE__c+++'+lstWoW[0].SE__c);
                     system.debug('++++lstWoW[0].BC__c +++'+lstWoW[0].BC__c );
                     system.debug('++++lstWoW[0].SEM__c+++'+lstWoW[0].SEM__c);
                    //Send Email TO SE,BC and SEM
                    Set<Id>set_UId = new Set<Id>();
                    //List<WoW_Virtual_Users__c> list_VT=getDiffVTList(NewVT,OldVT);
                   //List<WoW_Virtual_Users__c> list_VT=[SELECT Virtual_User__c FROM WoW_Virtual_Users__c WHERE Wow_Request_Form__c=:lstWoW[0].Id];                  
                    if(lstWoW[0].SE__c != null )
                      set_UId.add(lstWoW[0].SE__c);
                    if(lstWoW[0].BC__c != null )
                      set_UId.add(lstWoW[0].BC__c);
                    if(lstWoW[0].SEM__c != null )
                      set_UId.add(lstWoW[0].SEM__c);
                          
                    system.debug('++++set_UId+++'+set_UId);
                    List<User>lstUs = [Select id,name,email from User where id IN : set_UId];
                    
                    //Send Email for SE,BC and SEM
                    for(User objU:lstUs)
                    {
                      SendEmailByTemplate(objU.Id,'Wow Engagement Virtual Team Assigned',lstWoW[0].Id);
                    }  
                 }
                 else if (NotificationType=='Lead Submitted') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement Lead Submitted',lstWoW[0].Id);                     
                 } 
                 else if (NotificationType=='WoW Rejected') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement Lead Rejected',lstWoW[0].Id);                      
                 }
                 else if (NotificationType=='WoW Accepted') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement Lead Accepted',lstWoW[0].Id);                     
                 }
                 else if (NotificationType=='Lead Completed') 
                 {
                      //added user in send to array
                    for(User objUser:lstUser)
                    {
                            aryUser.clear(); 
                            //Update the Temp lead for all queue members for VF email template
                            lstWoW[0].Temp_Lead__c= objUser.Id;
                            Update lstWoW[0];  
                            SendEmailByTemplate(objUser.Id,'Wow Engagement Lead Completed',lstWoW[0].Id);                                             
                     }
                      //SendEmailByTemplate(lstWoW[0].Lead__c,'Wow Engagement Lead Completed',lstWoW[0].Id);                     
                 } 
                 else if (NotificationType=='AE') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement AE',lstWoW[0].Id);                    
                 } */               
                  strResult='Successful';   
                }
       catch(exception ex)
           {
               strResult='Failed';
           }           
        return strResult;
    }
    public static List<POCVirtualUser__c> getDiffVTList(List<POCVirtualUser__c> newVTlist,List<POCVirtualUser__c> oldVTlist)
     {
         List<POCVirtualUser__c> listDiffVT =new List<POCVirtualUser__c>();
         boolean flag=false;
         if(oldVTlist!=null){
            for(POCVirtualUser__c objNew : newVTlist)
                {
                flag=false;
                for(POCVirtualUser__c objOld : oldVTlist)
                    {
                        if(objNew.Solution_Consultant__c==objOld.Solution_Consultant__c)
                           flag=true; 
                    }
                   if(flag==false) 
                      listDiffVT.add(objNew);
                }
             return listDiffVT;
             }
         else
          return newVTlist;
     } 
   //send email from VF template
    public static String SendEmailByTemplate(Id UserId,String strTemplateName, Id POCId){
          string strResult='Failed';
             try{
                  system.debug('SendEmailByTemplate%%%%%');
                    // Create a new single email message object
                    // that will send out a single email to the addresses in the To, CC & BCC list.
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                    // Specify the name used as the display name.
                    mail.setSenderDisplayName('');                   
                    // Set to True if you want to BCC yourself on the email.
                    mail.setBccSender(false);
                    // Optionally append the salesforce.com email signature to the email.
                    // The email address of the user executing the Apex Code will be used.
                    mail.setUseSignature(false);
                    //Map the VF template
                    mail.setTargetObjectId(UserId); //Mandatory field when use template
                    mail.setWhatId(POCId); //Assign Wow Id
                    mail.setTemplateId([select id from EmailTemplate where Name =: strTemplateName].id);  //Find the template on the basis of name                    
                    // Send the email you have created.
                    mail.SaveAsActivity = false; //Mandatory field when use template
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    system.debug('SendEmailByTemplate-end');
                    strResult='Successful';
                    }    
                catch(exception ex)
                    {
                    strResult='Failed';
                    system.debug('ex '+ex.getMessage());
                    } 
             return strResult;        
         }  
   
   public static Id getSubRegionalUsers(string Region,string SubRegion){
         Id Idleader;
         List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
         set<string> set_FinalSubRegion=new set<string>();
         if(list_SubRegion.size()>0)
             for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion)
                 {
                 if(objSubRegion.Region__c==Region && objSubRegion.SubRegion__c==SubRegion )
                     set_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
                 }
           List<User> List_User =[SELECT Id FROM User Where UserName in :set_FinalSubRegion]; 
           if(List_User.size()>0)    
              Idleader= List_User[0].Id;
        return Idleader;
     }
     
     
     // Method added By RSystems 28-09-2017 as per Debora Email
     public static List<string> getSubRegionalNewUsersForSharing(String segment,String SubRegion, String offeringtype){
         
         List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
         List<string> list_FinalSubRegion=new List<string>();
         
         if(list_SubRegion.size() > 0 && (( segment != '' && SubRegion != null ) || offeringtype == 'PureCloud' ) ){
             for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                 
                if(objSubRegion.Offering_Type__c == offeringtype){
                    list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
                }
                else if(objSubRegion.Segment__c == segment && objSubRegion.SubRegion__c == SubRegion){
                    list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
                }
             }
             
             //if no leader exist then pick all admin
            if(list_FinalSubRegion.size()<=0){
                for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                   if(objSubRegion.Is_Admin__c)
                    list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
                } 
            } 
         }
         else {
            for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
              if(objSubRegion.Is_Admin__c)
                 list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
            }
         }       
        system.debug('##list_FinalSubRegion--'+list_FinalSubRegion);
        return list_FinalSubRegion;
     }
     
    // Method added by Rsystems 28-09-2017 as per Debora Email
     
     public static List<Wow_Sub_Regional_Users__c> getSubRegionalNewUsersName(String segment,String SubRegion, String offeringtype){
        List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
        List<Wow_Sub_Regional_Users__c> list_FinalSubRegion=new List<Wow_Sub_Regional_Users__c>();
       
        if(list_SubRegion.size() > 0 && (( segment != '' && SubRegion != null ) || offeringtype == 'PureCloud' )){
       
            for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                if(objSubRegion.Offering_Type__c == offeringtype){
                    list_FinalSubRegion.add(objSubRegion);
                }
                else if(objSubRegion.Segment__c == segment && objSubRegion.SubRegion__c == SubRegion){
                    list_FinalSubRegion.add(objSubRegion);
                }
            }
        
            //if no leader exist then pick all admin
            if(list_FinalSubRegion.size() <= 0){
                for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                   if(objSubRegion.Is_Admin__c)
                    list_FinalSubRegion.add(objSubRegion);
                } 
            }    
        }
        else{
            for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                if(objSubRegion.Is_Admin__c)
                    list_FinalSubRegion.add(objSubRegion);
            }
        }        
        return list_FinalSubRegion;
     }
     
     
   public static Map<String,List<String>>  GetDependentPickListValues(string objectName,string controllingField,string dependentField)
   {
        //String objectName = 'address__c';
        //String controllingField = 'country__C';
        //String dependentField = 'state__c';        
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!Schema.getGlobalDescribe().containsKey(objectName)){
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
        }
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType==null){
            return objResults;
        }
        Bitset bitSetObj = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            return objResults;     
        }
        List<Schema.PicklistEntry> contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        objFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        for(Integer contrIndex=0; contrIndex<contrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String label = ctrlentry.getLabel();
            objResults.put(label,new List<String>());
            controllingIndexes.add(contrIndex);
        }
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        for(Integer dependentIndex=0; dependentIndex<depEntries.size(); dependentIndex++){            
               Schema.PicklistEntry depentry = depEntries[dependentIndex];
               objEntries.add(depentry);
        } 
        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries){
            if (objJson.validFor==null || objJson.validFor==''){
                continue;
            }
            indexes = bitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : indexes){                
                String contrLabel = contrEntries[idx].getLabel();
                objResults.get(contrLabel).add(objJson.label);
            }
        }
        system.debug('####'+objEntries);        
        objEntries = null;
        objJsonEntries = null;
        system.debug('####AA'+ objResults);
        
        return objResults;
   }
       
   public class PicklistEntryWrapper{
    
        public PicklistEntryWrapper(){            
        }
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
    }  
    
    public class BitSet{
    public Map<String,Integer> alphaNumCharCodes {get;set;}
    public Map<String, Integer> base64CharCodes {get;set;}
    
    public BitSet(){
        LoadCharCodes();
    }
    
    //Method loads the character codes for all letters
    private void LoadCharCodes(){
        alphaNumCharCodes = new Map<String,Integer>{
            'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
            'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
            'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90    
        };
        base64CharCodes = new Map<String, Integer>();
        //all lower cases
        Set<String> pUpperCase = alphaNumCharCodes.keySet();
        for(String pKey : pUpperCase){
            //the difference between upper case and lower case is 32
            alphaNumCharCodes.put(pKey.toLowerCase(),alphaNumCharCodes.get(pKey)+32);
            //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
            base64CharCodes.put(pKey,alphaNumCharCodes.get(pKey) - 65);
            base64CharCodes.put(pKey.toLowerCase(),alphaNumCharCodes.get(pKey) - (65) + 26);
        }
        //numerics
        for (Integer i=0; i<=9; i++){
            alphaNumCharCodes.put(string.valueOf(i),i+48);
            //base 64 numeric starts from 52
            base64CharCodes.put(string.valueOf(i), i + 52);
        }
    }
        
      public List<Integer> testBits(String pValidFor,List<Integer> nList){
            List<Integer> results = new List<Integer>();
            List<Integer> pBytes = new List<Integer>();
            Integer bytesBeingUsed = (pValidFor.length() * 6)/8;
            Integer pFullValue = 0;
            if (bytesBeingUsed <= 1)
                return results;
            for(Integer i=0;i<pValidFor.length();i++){
                pBytes.Add((base64CharCodes.get((pValidFor.Substring(i, i+1)))));
            }   
            for (Integer i = 0; i < pBytes.size(); i++)
            {
                Integer pShiftAmount = (pBytes.size()-(i+1))*6;//used to shift by a factor 6 bits to get the value
                pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
            }
            
            Integer bit;
            Integer targetOctet;
            Integer shiftBits;
            Integer tBitVal;
            Integer n;
            Integer nListSize = nList.size();
            for(Integer i=0; i<nListSize; i++){
                n = nList[i];
                bit = 7 - (Math.mod(n,8)); 
                targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed); 
                shiftBits = (targetOctet * 8) + bit;
                tBitVal = ((Integer)(2 << (shiftBits-1)) & pFullValue) >> shiftBits;
                if (tBitVal==1)
                    results.add(n);
            }
            return results;
        }

    }
    
     public static void SharePOCRequest(List<User>list_Users,POC_Engagement_Request__c objPOC)
     {
         List<POC_Engagement_Request__Share> jobShares = new List<POC_Engagement_Request__Share>();
        
         for(User objUser : list_Users)
         {
             /** Create a new Wow_Request_Form_Share record to be inserted in to the Test_Share table. **/
             POC_Engagement_Request__Share objPOCReq = new POC_Engagement_Request__Share ();
             /** Populate the Test_Share record with the ID of the record to be shared. **/
             objPOCReq.ParentId = objPOC.Id;
             /* Then, set the ID of user or group being granted access. */
             objPOCReq.UserOrGroupId = objUser.id;
             objPOCReq.AccessLevel = 'Edit';
             objPOCReq.RowCause = Schema.POC_Engagement_Request__Share.RowCause.POC__c;
             jobShares.add(objPOCReq);
         }
         insert jobShares;
     } 
 
  
}