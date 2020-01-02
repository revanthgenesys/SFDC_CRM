public class CheckServiceContractAndCloudDeploy
{
    // Added By Ashish (08/08/2018)
    // To resolve CPU time limt error
    public static boolean isContactFutureCalled = false;
    
   public CheckServiceContractAndCloudDeploy()
   {
   
   }
   
   public static void CheckSC(ServiceContract objSContract)
   {
      System.debug('objSContract.AccountId>>>>>'+ objSContract.AccountId);
       //Incident INC0393823 - For CRM team: THe NRO submitted against a PPU Termsheet is completed but does not change forecast Status to Booked
       // Added null point check to remove null point exception on changing order status to complete.
       if(objSContract.AccountId != null){
           Account objAcc = [Select id,name,Account_ID__c,Status__c,Date_of_Offboard__c,IsOffboarding__c,IsErrorOffboarding__c,recordtype.name from Account where id =: objSContract.AccountId];
      		ServiceContractAndCd(objAcc);
       }
      
   }
   public static void CheckCD(Cloud_Deployment__c objCd)
   {
      Account objAcc = [Select id,name,IsCustomerPortal,Account_ID__c,Status__c,Date_of_Offboard__c,IsOffboarding__c,IsErrorOffboarding__c,recordtype.name from Account where id =: objCd.Account__c];
      ServiceContractAndCd(objAcc);
   }
   
   public static void ServiceContractAndCd(Account objAcc)
   {    
       try{
       //Service Contract
       List<ServiceContract>list_SC = [Select id,Agreement_Status__c from ServiceContract where AccountId =: objAcc.Account_ID__c];
       boolean isAllSCClose = true;
       for(ServiceContract objSC : list_SC)
       {
         if(objSC.Agreement_Status__c != 'Closed' && objSC.Agreement_Status__c != 'Terminated')
           isAllSCClose = false;
       }
       
       //Cloud Deplyment
       List<Cloud_Deployment__c>list_CD = [Select id,Support_Status__c from Cloud_Deployment__c where Account__c =: objAcc.Account_ID__c];
       boolean isAllCDClose = true;
       for(Cloud_Deployment__c objCD : list_CD)
       {
         if(objCD.Support_Status__c != 'Inactive' )
           isAllCDClose = false;
       }
       
       
       //Customer record type should be 'EMG – Customer Record Type', requested by Jake on 10/18/2017 after PROD Deployment
       if(isAllSCClose && isAllCDClose && objAcc.recordtype.name == 'EMG - Customer Record Type')
       {
          //Update Account
          
          //Conditions corrected by Jitendra
          //These changes are requested by Jake on 11/06/2017
          if(objAcc.Status__c == 'Inactive' || objAcc.Status__c == 'New Logo Trial')
              objAcc.Status__c = 'Inactive';   
          else
              objAcc.Status__c = 'Expired Maintenance';
          
              objAcc.Date_of_Offboard__c = Date.Today();
              objAcc.IsOffboarding__c = true;
              objAcc.IsCustomerPortal = false;
              update objAcc;
          

            
          //Terminate portal access for all contacts
          OnAccountTermination(objAcc);
          
          //Send Email 
          
           /*string BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());  
           string sEmailBody ,sSubject;
           List<string> lstEmail = new List<string>();
           lstEmail.add('amit.singh@rsystems.com');
           
           sSubject  ='Offboarding Status';        
           sEmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5">';
           sEmailBody = sEmailBody + '<tr><td>Data and Finance Team</td></tr>';
           sEmailBody = sEmailBody + '<tr><td></td></tr>';
           sEmailBody = sEmailBody + '<tr><td>The account (Link to the account) is now expired in the system, please perform all necessary checks to insure the account is inactivated in NS.</td></tr>';
           sEmailBody = sEmailBody + '<tr><td></td></tr>';
           sEmailBody = sEmailBody + '<tr><td>Thanks you</td></tr>';
           
           
           sEmailBody = sEmailBody + '</table></body></html>';
           
           EmailNotification(sEmailBody ,sSubject ,lstEmail);*/
           EmailBody(false,'',null);
          
       }
       
      }
      catch(Exception ex)
      {
          objAcc.IsErrorOffboarding__c = true;
           objAcc.Date_of_Offboard__c  = Date.Today();
           update objAcc;
           
           EmailBody(true,ex.getMessage(),objAcc);

           /*string BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());  
           string sEmailBody ,sSubject;
           List<string> lstEmail = new List<string>();
           lstEmail.add('amit.singh@rsystems.com');
           
           sSubject  ='Error Occurred during Onboarding';        
           sEmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5">';
           sEmailBody = sEmailBody + '<tr><td>Account Name</td><td>Account URL</td><td>Error Description</td></tr>';
           sEmailBody = sEmailBody + '<tr><td>'+objAcc.name+'</td><td><a href="'+BaseURL+'/'+objAcc.id+'">'+BaseURL+'/'+objAcc.id+'</a></td><td>'+ex.getMessage()+'</td></tr>';
           sEmailBody = sEmailBody + '</table></body></html>';
           
           EmailNotification(sEmailBody ,sSubject ,lstEmail);*/
      }
   }
   public static void OnAccountTermination(Account objAcc) 
    {    
        
          set<Id> ContactIds = new set<Id>();
          //list<user> list_userToupdate = new list<user>(); 
          list<id> list_Id = new list<id>();
          List<contact> list_Contacts =[SELECT ID FROM Contact WHERE AccountId =: objAcc.id];
           system.debug('list_Contacts ****'+list_Contacts );
            system.debug('list_Contacts size ****'+list_Contacts.size() );
          if(list_Contacts!=null && list_Contacts.size()>0)
              for(contact objContact : list_Contacts )
                  ContactIds.add(objContact.Id);
          
          
          /*list<user> list_user = [SELECT Id, Isactive, IsPortalEnabled FROM user Where ContactID in: ContactIds];
          system.debug('list_user  ****'+list_user );
          for(user objuser: list_user ){
              if(objuser.Isactive==true || objuser.IsPortalEnabled ==true){
                 // objuser.Isactive= false;
                  objuser.IsPortalEnabled = false;
                  //objuser.phone ='222222222';
                  list_userToupdate.add(objuser);
                  list_Id.add(objuser.id);
                  }
           }*/
           //system.debug('list_userToupdate****'+list_userToupdate);
           calloutmethod(ContactIds);   
    }
    
    
    public static void calloutmethod(set<Id> ContactIds)
    {
          list<user> list_userToupdate = new list<user>(); 
          list<user> list_user = [SELECT Id, Isactive, IsPortalEnabled FROM user Where ContactID in: ContactIds];
          system.debug('list_user  ****'+list_user );
          for(user objuser: list_user ){
              if(objuser.Isactive==true || objuser.IsPortalEnabled ==true){
                  objuser.Isactive= false;
                  objuser.IsPortalEnabled = false;
                  //objuser.phone ='222222222';
                  list_userToupdate.add(objuser);
                  //list_Id.add(objuser.id);
                  }
           }
        update  list_userToupdate;  
    }
    public static void EmailNotification(string mailBody,string mailSubject,List<string> lstEmail){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[lstEmail.size()];
        for(integer i=0;i<lstEmail.size();i++)
        {
          toAddresses[i] =  lstEmail[i];
        }
        mail.setToAddresses(toAddresses);
        mail.setPlainTextBody(mailBody);
        mail.setHtmlBody(mailBody);
        mail.setSubject(mailSubject);
        if(!Test.isRunningTest())
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
        
        public static void EmailBody(boolean isError,string strErrMsg,Account objAcc)
        {
          if(isError)
          {
            string BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());  
           string sEmailBody ,sSubject;
           List<string> lstEmail = new List<string>();
           lstEmail.add('amit.singh@rsystems.com');
           
           sSubject  ='Error Occurred during Onboarding';        
           sEmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5">';
           sEmailBody = sEmailBody + '<tr><td>Account Name</td><td>Account URL</td><td>Error Description</td></tr>';
           sEmailBody = sEmailBody + '<tr><td>'+objAcc.name+'</td><td><a href="'+BaseURL+'/'+objAcc.id+'">'+BaseURL+'/'+objAcc.id+'</a></td><td>'+strErrMsg+'</td></tr>';
           sEmailBody = sEmailBody + '</table></body></html>';
           
           EmailNotification(sEmailBody ,sSubject ,lstEmail);
          }
          else
          {
            string BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());  
           string sEmailBody ,sSubject;
           List<string> lstEmail = new List<string>();
           lstEmail.add('amit.singh@rsystems.com');
           
           sSubject  ='Offboarding Status';        
           sEmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5">';
           sEmailBody = sEmailBody + '<tr><td>Data and Finance Team</td></tr>';
           sEmailBody = sEmailBody + '<tr><td></td></tr>';
           sEmailBody = sEmailBody + '<tr><td>The account (Link to the account) is now expired in the system, please perform all necessary checks to insure the account is inactivated in NS.</td></tr>';
           sEmailBody = sEmailBody + '<tr><td></td></tr>';
           sEmailBody = sEmailBody + '<tr><td>Thanks you</td></tr>';
           
           
           sEmailBody = sEmailBody + '</table></body></html>';
           
           EmailNotification(sEmailBody ,sSubject ,lstEmail);
          }
        }

 
    /*
    * Modified By: Amit Singh, 06/26/2018
    * Desc: To update Active/Inactive Purchase Offering and Offering type on Account from the Service Contract
    */
    
    public static void afterInsertUpdate(Boolean isInsert, Boolean isUpdate, List<ServiceContract> newServiceContractList, Map<Id, ServiceContract> oldServiceContractIdObjMap){
        Map<Id, ServiceContract> accountIdSerContActIndirListMap = new Map<Id, ServiceContract>();
        Map<Id, ServiceContract> accountIdSerContActDirListMap = new Map<Id, ServiceContract>();
        Map<Id, ServiceContract> accountIdSerContInactIndirListMap = new Map<Id, ServiceContract>();
        Map<Id, ServiceContract> accountIdSerContInactDirListMap = new Map<Id, ServiceContract>();
        Set<Id> set_AccountId = new Set<Id>();
        
        for(ServiceContract serviceCon : newServiceContractList){
            if(isInsert || (isUpdate && (serviceCon.Agreement_Status__c != oldServiceContractIdObjMap.get(serviceCon.Id).Agreement_Status__c
                        || serviceCon.End_User_Name__c != oldServiceContractIdObjMap.get(serviceCon.Id).End_User_Name__c)))
            {
                if((serviceCon.Agreement_Status__c == 'Active' || serviceCon.Agreement_Status__c == 'Pending' || serviceCon.Agreement_Status__c == 'In Negotiation')
                    && serviceCon.End_User_Name__c != null && serviceCon.Sold_To_Name__c != null && serviceCon.End_User_Name__c != serviceCon.Sold_To_Name__c){
                        accountIdSerContActIndirListMap.put(serviceCon.AccountId, serviceCon);
                }
                else {
                    if((serviceCon.Agreement_Status__c == 'Active' || serviceCon.Agreement_Status__c == 'Pending' || serviceCon.Agreement_Status__c == 'In Negotiation')
                        && serviceCon.End_User_Name__c != null && (serviceCon.Sold_To_Name__c == null || serviceCon.End_User_Name__c == serviceCon.Sold_To_Name__c)){
                            accountIdSerContActDirListMap.put(serviceCon.AccountId, serviceCon);
                    }
                    else {
                        if((serviceCon.Agreement_Status__c != 'Active' && serviceCon.Agreement_Status__c != 'Pending' && serviceCon.Agreement_Status__c != 'In Negotiation')
                            && serviceCon.End_User_Name__c != null && serviceCon.Sold_To_Name__c != null && serviceCon.End_User_Name__c != serviceCon.Sold_To_Name__c){
                                accountIdSerContInactIndirListMap.put(serviceCon.AccountId, serviceCon);
                        }
                        else {
                            if((serviceCon.Agreement_Status__c != 'Active' && serviceCon.Agreement_Status__c != 'Pending' && serviceCon.Agreement_Status__c != 'In Negotiation')
                                && serviceCon.End_User_Name__c != null && (serviceCon.Sold_To_Name__c == null || serviceCon.End_User_Name__c == serviceCon.Sold_To_Name__c)){
                                    accountIdSerContInactDirListMap.put(serviceCon.AccountId, serviceCon);
                            }
                        }
                    }           
                }
            }
            else if(isUpdate && (serviceCon.Offering_Type__c != oldServiceContractIdObjMap.get(serviceCon.Id).Offering_Type__c
                            || serviceCon.Service_Contract_Type__c != oldServiceContractIdObjMap.get(serviceCon.Id).Service_Contract_Type__c)){
                set_AccountId.add(serviceCon.AccountId);
            }
        }
        
        List<Account> accountToUpdateList = new List<Account>();
        
        if(accountIdSerContActIndirListMap.size() > 0){
            system.debug('inside 1:'+accountIdSerContActIndirListMap);
            accountToUpdateList.addAll(updateAccountPurchasedOffering(accountIdSerContActIndirListMap, 'Indirect', true));
        }
        if(accountIdSerContActDirListMap.size() > 0){
            system.debug('inside 2:'+accountIdSerContActIndirListMap);        
            accountToUpdateList.addAll(updateAccountPurchasedOffering(accountIdSerContActDirListMap, 'Direct', true));
        }
        if(accountIdSerContInactIndirListMap.size() > 0){
            system.debug('inside 3:'+accountIdSerContActIndirListMap);            
            accountToUpdateList.addAll(updateAccountPurchasedOffering(accountIdSerContInactIndirListMap, 'Indirect', false));
        }
        if(accountIdSerContInactDirListMap.size() > 0){
            system.debug('inside 4:'+accountIdSerContActIndirListMap);        
            accountToUpdateList.addAll(updateAccountPurchasedOffering(accountIdSerContInactDirListMap, 'Direct', false));
        }
        if(set_AccountId.size() > 0){
            updateOfferingPurchaseOnAccount(set_AccountId);
        }
        
        if(accountToUpdateList.size() > 0){
            system.debug('inside updateList:'+accountToUpdateList);
            update accountToUpdateList;
        }
    }
    
    
    /*
    * Modified By: Amit Singh, 06/26/2018
    * Desc: To update Active/Inactive Purchase Offering and Offering type on Account from the Cloud Deployment
    */
    
    public static void afterInsertUpdateCloudDeply(Boolean isInsert, Boolean isUpdate, List<Cloud_Deployment__c> newcloudDeplyList, Map<Id, Cloud_Deployment__c> oldcloudDeplyIdObjMap){
        Map<Id, Cloud_Deployment__c> accountIdCloudDeplyActIndirListMap = new Map<Id, Cloud_Deployment__c>();
        Map<Id, Cloud_Deployment__c> accountIdCloudDeplyActDirListMap = new Map<Id, Cloud_Deployment__c>();
        Map<Id, Cloud_Deployment__c> accountIdCloudDeplyInactIndirListMap = new Map<Id, Cloud_Deployment__c>();
        Map<Id, Cloud_Deployment__c> accountIdCloudDeplyInactDirListMap = new Map<Id, Cloud_Deployment__c>();
        Set<Id> set_AccountId = new Set<Id>();
        
        for(Cloud_Deployment__c cloudDeply : newcloudDeplyList){
            if(isInsert || (isUpdate && (cloudDeply.Support_Status__c != oldcloudDeplyIdObjMap.get(cloudDeply.Id).Support_Status__c 
                        || cloudDeply.Account__c != oldcloudDeplyIdObjMap.get(cloudDeply.Id).Account__c)))
            {
                if(cloudDeply.Support_Status__c != 'Inactive' && cloudDeply.Account__c != null && cloudDeply.Sold_To_Account__c != null && cloudDeply.Account__c != cloudDeply.Sold_To_Account__c){
                        accountIdCloudDeplyActIndirListMap.put(cloudDeply.Account__c, cloudDeply);
                }
                else {
                    if(cloudDeply.Support_Status__c != 'Inactive'&& cloudDeply.Account__c != null && (cloudDeply.Sold_To_Account__c == null || cloudDeply.Account__c == cloudDeply.Sold_To_Account__c)){
                            accountIdCloudDeplyActDirListMap.put(cloudDeply.Account__c, cloudDeply);
                    }
                    else {
                        if(cloudDeply.Support_Status__c == 'Inactive'&& cloudDeply.Account__c != null && cloudDeply.Sold_To_Account__c != null && cloudDeply.Account__c != cloudDeply.Sold_To_Account__c){
                                accountIdCloudDeplyInactIndirListMap.put(cloudDeply.Account__c, cloudDeply);
                        }
                        else {
                            if(cloudDeply.Support_Status__c == 'Inactive' && cloudDeply.Account__c != null && (cloudDeply.Sold_To_Account__c == null || cloudDeply.Account__c == cloudDeply.Sold_To_Account__c)){
                                    accountIdCloudDeplyInactDirListMap.put(cloudDeply.Account__c, cloudDeply);
                            }
                        }
                    }           
                }
            }
            
            else if(isUpdate && (cloudDeply.Cloud_Platform__c != oldcloudDeplyIdObjMap.get(cloudDeply.Id).Cloud_Platform__c 
                        || cloudDeply.Offering_Detail__c != oldcloudDeplyIdObjMap.get(cloudDeply.Id).Offering_Detail__c)){
                set_AccountId.add(cloudDeply.Account__c);
            }
        }
        
        List<Account> accountToUpdateList = new List<Account>();
        
        if(accountIdCloudDeplyActIndirListMap.size() > 0){
            accountToUpdateList.addAll(updateAccountPurchasedOfferingFrmCloudDeply(accountIdCloudDeplyActIndirListMap, 'Indirect', true));
        }
        if(accountIdCloudDeplyActDirListMap.size() > 0){
            accountToUpdateList.addAll(updateAccountPurchasedOfferingFrmCloudDeply(accountIdCloudDeplyActDirListMap, 'Direct', true));
        }
        if(accountIdCloudDeplyInactIndirListMap.size() > 0){
            accountToUpdateList.addAll(updateAccountPurchasedOfferingFrmCloudDeply(accountIdCloudDeplyInactIndirListMap, 'Indirect', false));
        }
        if(accountIdCloudDeplyInactDirListMap.size() > 0){
            accountToUpdateList.addAll(updateAccountPurchasedOfferingFrmCloudDeply(accountIdCloudDeplyInactDirListMap, 'Direct', false));
        }
        if(set_AccountId.size() > 0){
            updateOfferingPurchaseOnAccount(set_AccountId);
        }
        
        if(accountToUpdateList.size() > 0){
            update accountToUpdateList;
        }
    }
        

    private static List<Account> updateAccountPurchasedOfferingFrmCloudDeply(Map<Id, Cloud_Deployment__c> accountIdCloudDeplyMap, String offeringType, Boolean isActive){
        List<Account> accountList = new List<Account>();
        Map<Id, String> map_AccIdString = new Map<Id, String>();
        Map<Id, Account> map_AccIdObject = new Map<Id, Account>();
        Map<Id, String> map_AccIdCloudPlatform = new Map<Id, String>();
        
        Set<String> picklistValueList = new Set<String>();
        
        Schema.DescribeFieldResult fieldResult = Account.Offering_Type__c.getDescribe();
        List<Schema.PicklistEntry> results = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : results){
            picklistValueList.add(pickListVal.getValue());
        } 
            
        for(Account acc : [SELECT Id, Inactive_Purchased_Offerings__c, AccountOfferingTypes__c, Offering_Type__c 
                                FROM Account 
                                WHERE Id IN :accountIdCloudDeplyMap.keySet()]){
            String cloudPltfrm = accountIdCloudDeplyMap.get(acc.Id).Cloud_Platform__c == null ? '' : accountIdCloudDeplyMap.get(acc.Id).Cloud_Platform__c;
            String offerDetail = accountIdCloudDeplyMap.get(acc.Id).Offering_Detail__c ==  null ? '' : accountIdCloudDeplyMap.get(acc.Id).Offering_Detail__c;
            String finalStr1 = offeringType + ': Cloud, ' + cloudPltfrm + ', ' + offerDetail;
            finalStr1 = finalStr1.trim();
            map_AccIdString.put(acc.Id, finalStr1);
            map_AccIdObject.put(acc.Id,acc);
            
            Cloud_Deployment__c cloudDeploy = accountIdCloudDeplyMap.get(acc.Id);
            
            /*if(cloudDeploy.Cloud_Platform__c != null && picklistValueList.contains(cloudDeploy.Cloud_Platform__c)){
                map_AccIdCloudPlatform.put(acc.Id, cloudDeploy.Cloud_Platform__c);  
            }else if(cloudDeploy.Cloud_Platform__c != null){
                string offType = 'PureConnect Cloud';
                map_AccIdCloudPlatform.put(acc.Id, offType);
            }*/
            
            // Setting the value for the offering type from the Cloud Platform
            
            if(cloudDeploy.Cloud_Platform__c == 'PureConnect Subscription')
                map_AccIdCloudPlatform.put(acc.Id, 'PureConnect Premise');
            else {
                if(cloudDeploy.Cloud_Platform__c == 'Outbound Engagement')
                    map_AccIdCloudPlatform.put(acc.Id, 'PureEngage Cloud Outbound');
                else {
                    if(cloudDeploy.Cloud_Platform__c == 'PureEngage Subscription')
                        map_AccIdCloudPlatform.put(acc.Id, 'PureEngage Premise');
                    else {
                        if(cloudDeploy.Cloud_Platform__c == 'SpeechStorm'    || cloudDeploy.Cloud_Platform__c == 'Legacy Enterprise Edition')
                            map_AccIdCloudPlatform.put(acc.Id, 'PureEngage Cloud');
                        else {
                            if(cloudDeploy.Cloud_Platform__c == 'Premier Edition' || cloudDeploy.Cloud_Platform__c == 'PureConnect Cloud' 
                                    || cloudDeploy.Cloud_Platform__c == 'PureEngage Cloud' || cloudDeploy.Cloud_Platform__c == 'PureCloud')
                                map_AccIdCloudPlatform.put(acc.Id, cloudDeploy.Cloud_Platform__c);
                        }
                    }
                }
            }
        }
        
        // Checking whether any Active/Inactive Cloud deployment record exist for the same account wrt to Inactive/Active cloud deployment
        
        if(map_AccIdString.size() > 0){
            Set<Id> set_AccountHavingCD = new Set<Id>();    
            Set<Id> set_AccountHavingCloudPlatfrm = new Set<Id>();          
            List<Cloud_Deployment__c> list_CloudDeployment = new List<Cloud_Deployment__c>();
            if(isActive){
                list_CloudDeployment = [SELECT Id, Cloud_Platform__c, Offering_Detail__c, Account__c, Sold_To_Account__c 
                                            FROM Cloud_Deployment__c 
                                            WHERE Account__c IN :map_AccIdString.keySet() AND Support_Status__c = 'Inactive'];
            }
            else{
                list_CloudDeployment = [SELECT Id, Cloud_Platform__c, Offering_Detail__c, Account__c, Sold_To_Account__c 
                                            FROM Cloud_Deployment__c 
                                            WHERE Account__c IN :map_AccIdString.keySet() AND Support_Status__c != 'Inactive'];
            }
            for(Cloud_Deployment__c cloudDeply : list_CloudDeployment){
                String offerCode = '';
                if(cloudDeply.Sold_To_Account__c != null && cloudDeply.Account__c != cloudDeply.Sold_To_Account__c){
                    offerCode = 'Indirect';
                }
                else if(cloudDeply.Sold_To_Account__c == null || cloudDeply.Account__c == cloudDeply.Sold_To_Account__c){
                    offerCode = 'Direct';
                }
                String cloudPltfrm = cloudDeply.Cloud_Platform__c == null ? '' : cloudDeply.Cloud_Platform__c;
                String offerDetail = cloudDeply.Offering_Detail__c ==  null ? '' : cloudDeply.Offering_Detail__c;
                String finalStr2 = offerCode + ': Cloud, ' + cloudPltfrm + ', ' + offerDetail;
                finalStr2 = finalStr2.trim();
                if(map_AccIdString.containsKey(cloudDeply.Account__c) && map_AccIdString.get(cloudDeply.Account__c) == finalStr2){
                    set_AccountHavingCD.add(cloudDeply.Account__c);
                }
                
                if(!isActive){
                    if(map_AccIdCloudPlatform.containsKey(cloudDeply.Account__c) && map_AccIdCloudPlatform.get(cloudDeply.Account__c) == cloudDeply.Cloud_Platform__c){
                        set_AccountHavingCloudPlatfrm.add(cloudDeply.Account__c);
                    }
                }
            }
            
            // Updating the Account offering type and Active/Inactive purchase type on Account
            
            for(Account acc : map_AccIdObject.values()){
                String finalStr = map_AccIdString.get(acc.Id);
                if(isActive){
                    acc.AccountOfferingTypes__c =  getOffering(acc.AccountOfferingTypes__c, finalStr, '\n');
                    if(!set_AccountHavingCD.contains(acc.Id)){
                        acc.Inactive_Purchased_Offerings__c = removeOffering(acc.Inactive_Purchased_Offerings__c, finalStr, '\n');
                    }       
                    
                    // Adding value to Account Offering Type
                    if(map_AccIdCloudPlatform.containsKey(acc.Id)){
                        acc.Offering_Type__c = getOffering(acc.Offering_Type__c, map_AccIdCloudPlatform.get(acc.Id), ';');
                    }
                }
                else {
                    acc.Inactive_Purchased_Offerings__c =  getOffering(acc.Inactive_Purchased_Offerings__c, finalStr, '\n');
                    if(!set_AccountHavingCD.contains(acc.Id)){
                        acc.AccountOfferingTypes__c = removeOffering(acc.AccountOfferingTypes__c, finalStr, '\n');
                    }
                    
                    // Removing value from Account Offering Type
                    if(!set_AccountHavingCloudPlatfrm.contains(acc.Id) && map_AccIdCloudPlatform.containsKey(acc.Id) && acc.Offering_Type__c != null){
                        acc.Offering_Type__c = removeOfferingType(acc.Offering_Type__c, map_AccIdCloudPlatform.get(acc.Id));
                    }
                }
                accountList.add(acc);
            }
        }
        return accountList;
    }


    private static List<Account> updateAccountPurchasedOffering(Map<Id, ServiceContract> accountIdSerContMap, String offeringType, Boolean isActive){
        List<Account> accountList = new List<Account>();
        Map<Id, String> map_AccIdString = new Map<Id, String>();
        Map<Id, Account> map_AccIdObject = new Map<Id, Account>();
        Map<Id, String> map_AccIdCloudPlatform = new Map<Id, String>();        
        
        for(Account acc : [SELECT Id, Inactive_Purchased_Offerings__c, AccountOfferingTypes__c, Offering_Type__c 
                                FROM Account 
                                WHERE Id IN :accountIdSerContMap.keySet()]){
            String offerType = accountIdSerContMap.get(acc.Id).Offering_Type__c == null ? '' : accountIdSerContMap.get(acc.Id).Offering_Type__c;
            String contractType = accountIdSerContMap.get(acc.Id).Service_Contract_Type__c ==  null ? '' : accountIdSerContMap.get(acc.Id).Service_Contract_Type__c;
            String finalStr1 = offeringType + ': Premise, ' + offerType + ', ' + contractType;
            finalStr1 = finalStr1.trim();
            map_AccIdString.put(acc.Id, finalStr1);
            map_AccIdObject.put(acc.Id,acc);
            
            // Setting the value for the offering type from the Offering Type and Platform Type
            
            ServiceContract serviceCont = accountIdSerContMap.get(acc.Id);
            
            if((serviceCont.Offering_Type__c == 'PureEngage' || serviceCont.Offering_Type__c == 'PureConnect') && (serviceCont.Platform_Type__c == null || serviceCont.Platform_Type__c == 'Premise'))
            {
                String offType = serviceCont.Offering_Type__c + ' Premise';
                map_AccIdCloudPlatform.put(acc.Id, offType);
            }
            else if((serviceCont.Offering_Type__c == 'PureEngage' || serviceCont.Offering_Type__c == 'PureConnect') && (serviceCont.Platform_Type__c == null || serviceCont.Platform_Type__c == 'Cloud'))
            {
                String offType = serviceCont.Offering_Type__c + ' Cloud';
                map_AccIdCloudPlatform.put(acc.Id, offType);
            }
            else if(serviceCont.Offering_Type__c != null){
                map_AccIdCloudPlatform.put(acc.Id, serviceCont.Offering_Type__c);
            }
            
        }
        
        // Checking whether any Active/Inactive Service Contract record exist for the same account wrt to Inactive/Active Service Contract
        
        if(map_AccIdString.size() > 0){
            Set<Id> set_AccountHavingCD = new Set<Id>();
            Set<Id> set_AccountHavingCloudPlatfrm = new Set<Id>();   
            
            List<ServiceContract> list_ServiceContract = new List<ServiceContract>();
            if(isActive){
                list_ServiceContract = [SELECT Id, Offering_Type__c, Service_Contract_Type__c, AccountId, End_User_Name__c, Sold_To_Name__c 
                                            FROM ServiceContract 
                                            WHERE AccountId IN :map_AccIdString.keySet() AND Agreement_Status__c != 'Active' 
                                            AND Agreement_Status__c != 'Pending' AND Agreement_Status__c != 'In Negotiation'];
            }
            else{
                list_ServiceContract = [SELECT Id, Offering_Type__c, Service_Contract_Type__c, AccountId, End_User_Name__c, Sold_To_Name__c 
                                            FROM ServiceContract 
                                            WHERE AccountId IN :map_AccIdString.keySet() AND (Agreement_Status__c = 'Active' 
                                            OR Agreement_Status__c = 'Pending' OR Agreement_Status__c = 'In Negotiation')];
            }
            for(ServiceContract serviceCon : list_ServiceContract){
                String offerCode = '';
                if(serviceCon.End_User_Name__c != null && serviceCon.Sold_To_Name__c != null && serviceCon.End_User_Name__c != serviceCon.Sold_To_Name__c){
                    offerCode = 'Indirect';
                }
                else if(serviceCon.End_User_Name__c != null && (serviceCon.Sold_To_Name__c == null || serviceCon.End_User_Name__c == serviceCon.Sold_To_Name__c)){
                    offerCode = 'Direct';
                }
                String offerType = serviceCon.Offering_Type__c == null ? '' : serviceCon.Offering_Type__c;
                String contractType = serviceCon.Service_Contract_Type__c ==  null ? '' : serviceCon.Service_Contract_Type__c;
                String finalStr2 = offeringType + ': Premise, ' + offerType + ', ' + contractType;
                finalStr2 = finalStr2.trim();
                if(map_AccIdString.containsKey(serviceCon.AccountId) && map_AccIdString.get(serviceCon.AccountId) == finalStr2){
                    set_AccountHavingCD.add(serviceCon.AccountId);
                }
            }
            
            // Updating the Account offering type and Active/Inactive purchase type on Account
            
            for(Account acc : map_AccIdObject.values()){
                String finalStr = map_AccIdString.get(acc.Id);
                if(isActive){
                    acc.AccountOfferingTypes__c =  getOffering(acc.AccountOfferingTypes__c, finalStr, '\n');
                    if(!set_AccountHavingCD.contains(acc.Id)){
                        acc.Inactive_Purchased_Offerings__c = removeOffering(acc.Inactive_Purchased_Offerings__c, finalStr, '\n');
                    } 
                    
                    // Adding value to Account Offering Type
                    if(map_AccIdCloudPlatform.containsKey(acc.Id)){
                        acc.Offering_Type__c = getOffering(acc.Offering_Type__c, map_AccIdCloudPlatform.get(acc.Id), ';');                  
                    }                  
                }
                else {
                    acc.Inactive_Purchased_Offerings__c =  getOffering(acc.Inactive_Purchased_Offerings__c, finalStr, '\n');
                    if(!set_AccountHavingCD.contains(acc.Id)){
                        acc.AccountOfferingTypes__c = removeOffering(acc.AccountOfferingTypes__c, finalStr, '\n');
                    }
                    
                    // Removing value from Account Offering Type
                    if(!set_AccountHavingCloudPlatfrm.contains(acc.Id) && map_AccIdCloudPlatform.containsKey(acc.Id) && acc.Offering_Type__c != null){
                        acc.Offering_Type__c = removeOfferingType(acc.Offering_Type__c, map_AccIdCloudPlatform.get(acc.Id));
                    }
                }
                accountList.add(acc);
            }
        }
        return accountList;
    }
    
    
    private static String getOffering(String offeringVal, String finalStr, String seperator){
        if(offeringVal == null){
            offeringVal =  finalStr;
        } else{
            if(!offeringVal.contains(finalStr)){
                offeringVal =  offeringVal + seperator + finalStr;
            }
        }
        return offeringVal;
    }

    
    private static String removeOffering(String offeringVal, String finalStr, String seperator){
        String finalStrTemp = seperator + finalStr;
        if(offeringVal != null && offeringVal.contains(finalStrTemp)){
            offeringVal = offeringVal.remove(finalStrTemp); 
        }else{
            if(offeringVal != null && offeringVal.contains(finalStr)){
                offeringVal = offeringVal.remove(finalStr); 
            }
        }
        return offeringVal;
    }
    
    
    
    private static String removeOfferingType(String offeringVal, String finalStr){
        if(offeringVal != null){
            offeringVal = offeringVal + ';';
            String finalStrTemp = finalStr + ';';
            if(offeringVal != null && offeringVal.contains(finalStrTemp)){
                offeringVal = offeringVal.remove(finalStrTemp); 
            }
            if(offeringVal.indexOf(';')!= -1){
                offeringVal = offeringVal.removeEnd(';');
            }
        }
        return offeringVal;
    }
    
    
    /*
    * Added By: Amit Singh, 06/27/2018
    * Desc: To update Offering type on Contact from the Account
    */
    
    public static void updateContactOfferingType(List<Account> newAccList, Map<Id, Account> oldAccMap){
        Set<Id> set_AccountId = new Set<Id>();
        for(Account acc : newAccList){
            if(acc.Offering_Type__c != oldAccMap.get(acc.Id).Offering_Type__c){
                set_AccountId.add(acc.Id);
            }
        }
        if(set_AccountId.size() > 0){
            // Added By Ashish (08/08/2018)
            // To resolve CPU time limt error
            ContactOfferingTypeAsync.processRecords(set_AccountId);
        }
    }
    
    
    private static void updateOfferingPurchaseOnAccount(Set<Id> set_AccountId){
        Map<Id, String> map_AccIdActiveString = new Map<Id, String>();
        Map<Id, String> map_AccIdInActiveString = new Map<Id, String>();
        List<Account> list_Account = new List<Account>();
        
        for(Account acc : [SELECT Id, Inactive_Purchased_Offerings__c, AccountOfferingTypes__c, Offering_Type__c, 
                            (SELECT Id, AccountId, Agreement_Status__c, Sold_To_Name__c, End_User_Name__c, Offering_Type__c, Service_Contract_Type__c FROM ServiceContracts),
                            (SELECT Id, Cloud_Platform__c, Offering_Detail__c, Account__c, Support_Status__c, Sold_To_Account__c FROM Account_Deployments__r)
                            FROM Account WHERE Id IN: set_AccountId]){
            list_Account.add(acc);
            if(acc.ServiceContracts.size() > 0){
                for(ServiceContract serviceCon : acc.ServiceContracts){
                    if((serviceCon.Agreement_Status__c == 'Active' || serviceCon.Agreement_Status__c == 'Pending' || serviceCon.Agreement_Status__c == 'In Negotiation')
                        && serviceCon.End_User_Name__c != null && serviceCon.Sold_To_Name__c != null && serviceCon.End_User_Name__c != serviceCon.Sold_To_Name__c){
                            if(!map_AccIdActiveString.containsKey(serviceCon.AccountId)){
                                map_AccIdActiveString.put(serviceCon.AccountId, createOfferingTypeForServiceContract(serviceCon, 'Indirect'));
                            }
                            else{
                                String activeStrTemp = getOffering(map_AccIdActiveString.get(serviceCon.AccountId), createOfferingTypeForServiceContract(serviceCon, 'Indirect'), '\n');
                                map_AccIdActiveString.put(serviceCon.AccountId, activeStrTemp);
                            }
                    }
                    else {
                        if((serviceCon.Agreement_Status__c == 'Active' || serviceCon.Agreement_Status__c == 'Pending' || serviceCon.Agreement_Status__c == 'In Negotiation')
                            && serviceCon.End_User_Name__c != null && (serviceCon.Sold_To_Name__c == null || serviceCon.End_User_Name__c == serviceCon.Sold_To_Name__c)){
                                if(!map_AccIdActiveString.containsKey(serviceCon.AccountId)){
                                    map_AccIdActiveString.put(serviceCon.AccountId, createOfferingTypeForServiceContract(serviceCon, 'Direct'));
                                }
                                else{
                                    String activeStrTemp = getOffering(map_AccIdActiveString.get(serviceCon.AccountId), createOfferingTypeForServiceContract(serviceCon, 'Direct'), '\n');
                                    map_AccIdActiveString.put(serviceCon.AccountId, activeStrTemp);
                                }
                        }
                        else {
                            if((serviceCon.Agreement_Status__c != 'Active' && serviceCon.Agreement_Status__c != 'Pending' && serviceCon.Agreement_Status__c != 'In Negotiation')
                                && serviceCon.End_User_Name__c != null && serviceCon.Sold_To_Name__c != null && serviceCon.End_User_Name__c != serviceCon.Sold_To_Name__c){
                                    if(!map_AccIdInActiveString.containsKey(serviceCon.AccountId)){
                                        map_AccIdInActiveString.put(serviceCon.AccountId, createOfferingTypeForServiceContract(serviceCon, 'Indirect'));
                                    }
                                    else{
                                        String activeStrTemp = getOffering(map_AccIdInActiveString.get(serviceCon.AccountId), createOfferingTypeForServiceContract(serviceCon, 'Indirect'), '\n');
                                        map_AccIdInActiveString.put(serviceCon.AccountId, activeStrTemp);
                                    }
                            }
                            else {
                                if((serviceCon.Agreement_Status__c != 'Active' && serviceCon.Agreement_Status__c != 'Pending' && serviceCon.Agreement_Status__c != 'In Negotiation')
                                    && serviceCon.End_User_Name__c != null && (serviceCon.Sold_To_Name__c == null || serviceCon.End_User_Name__c == serviceCon.Sold_To_Name__c)){
                                        if(!map_AccIdInActiveString.containsKey(serviceCon.AccountId)){
                                            map_AccIdInActiveString.put(serviceCon.AccountId, createOfferingTypeForServiceContract(serviceCon, 'Direct'));
                                        }
                                        else{
                                            String activeStrTemp = getOffering(map_AccIdInActiveString.get(serviceCon.AccountId), createOfferingTypeForServiceContract(serviceCon, 'Direct'), '\n');
                                            map_AccIdInActiveString.put(serviceCon.AccountId, activeStrTemp);
                                        }
                                }
                            }
                        }           
                    }
                }
            }
            
            if(acc.Account_Deployments__r.size() > 0){
                for(Cloud_Deployment__c cloudDeply : acc.Account_Deployments__r){
                    if(cloudDeply.Support_Status__c != 'Inactive' && cloudDeply.Account__c != null && cloudDeply.Sold_To_Account__c != null && cloudDeply.Account__c != cloudDeply.Sold_To_Account__c){
                        System.debug('---in the active direct loop');
                        if(!map_AccIdActiveString.containsKey(cloudDeply.Account__c)){
                            map_AccIdActiveString.put(cloudDeply.Account__c, createOfferingTypeForCloudDeply(cloudDeply, 'Indirect'));
                        }
                        else{
                            String activeStrTemp = getOffering(map_AccIdActiveString.get(cloudDeply.Account__c), createOfferingTypeForCloudDeply(cloudDeply, 'Indirect'), '\n');
                            map_AccIdActiveString.put(cloudDeply.Account__c, activeStrTemp);
                        }
                        System.debug('---in the active direct loop value---  '+map_AccIdActiveString.get(cloudDeply.Account__c));
                    }
                    else {
                        if(cloudDeply.Support_Status__c != 'Inactive'&& cloudDeply.Account__c != null && (cloudDeply.Sold_To_Account__c == null || cloudDeply.Account__c == cloudDeply.Sold_To_Account__c)){
                            System.debug('---in the active loop');
                            if(!map_AccIdActiveString.containsKey(cloudDeply.Account__c)){
                                map_AccIdActiveString.put(cloudDeply.Account__c, createOfferingTypeForCloudDeply(cloudDeply, 'Direct'));
                            }
                            else{
                                String activeStrTemp = getOffering(map_AccIdActiveString.get(cloudDeply.Account__c), createOfferingTypeForCloudDeply(cloudDeply, 'Direct'), '\n');
                                map_AccIdActiveString.put(cloudDeply.Account__c, activeStrTemp);
                            }
                            System.debug('---in the active loop value---  '+map_AccIdActiveString.get(cloudDeply.Account__c));
                        }
                        else {
                            if(cloudDeply.Support_Status__c == 'Inactive'&& cloudDeply.Account__c != null && cloudDeply.Sold_To_Account__c != null && cloudDeply.Account__c != cloudDeply.Sold_To_Account__c){
                                if(!map_AccIdInActiveString.containsKey(cloudDeply.Account__c)){
                                    map_AccIdInActiveString.put(cloudDeply.Account__c, createOfferingTypeForCloudDeply(cloudDeply, 'Indirect'));
                                }
                                else{
                                    String activeStrTemp = getOffering(map_AccIdInActiveString.get(cloudDeply.Account__c), createOfferingTypeForCloudDeply(cloudDeply, 'Indirect'), '\n');
                                    map_AccIdInActiveString.put(cloudDeply.Account__c, activeStrTemp);
                                }
                            }
                            else {
                                if(cloudDeply.Support_Status__c == 'Inactive' && cloudDeply.Account__c != null && (cloudDeply.Sold_To_Account__c == null || cloudDeply.Account__c == cloudDeply.Sold_To_Account__c)){
                                    if(!map_AccIdInActiveString.containsKey(cloudDeply.Account__c)){
                                        map_AccIdInActiveString.put(cloudDeply.Account__c, createOfferingTypeForCloudDeply(cloudDeply, 'Direct'));
                                    }
                                    else{
                                        String activeStrTemp = getOffering(map_AccIdInActiveString.get(cloudDeply.Account__c), createOfferingTypeForCloudDeply(cloudDeply, 'Direct'), '\n');
                                        map_AccIdInActiveString.put(cloudDeply.Account__c, activeStrTemp);
                                    }
                                }
                            }
                        }           
                    }
                }
            }
        }
        
        for(Account accObj : list_Account){
            if(map_AccIdInActiveString.containsKey(accObj.Id)){
                accObj.Inactive_Purchased_Offerings__c = map_AccIdInActiveString.get(accObj.Id);
            }
            if(map_AccIdActiveString.containsKey(accObj.Id)){
                accObj.AccountOfferingTypes__c = map_AccIdActiveString.get(accObj.Id);
            }
        }
        
        update list_Account;
    }
    
    
    private static String createOfferingTypeForCloudDeply(Cloud_Deployment__c cloudDeployRec, String offeringType){        
        String cloudPltfrm = cloudDeployRec.Cloud_Platform__c == null ? '' : cloudDeployRec.Cloud_Platform__c;
        String offerDetail = cloudDeployRec.Offering_Detail__c ==  null ? '' : cloudDeployRec.Offering_Detail__c;
        String finalStr1 = offeringType + ': Cloud, ' + cloudPltfrm + ', ' + offerDetail;
        finalStr1 = finalStr1.trim();
        return finalStr1;
    }


    private static String createOfferingTypeForServiceContract(ServiceContract serviceCont, String offeringType){
        String offerType = serviceCont.Offering_Type__c == null ? '' : serviceCont.Offering_Type__c;
        String contractType = serviceCont.Service_Contract_Type__c ==  null ? '' : serviceCont.Service_Contract_Type__c;
        String finalStr1 = offeringType + ': Premise, ' + offerType + ', ' + contractType;
        finalStr1 = finalStr1.trim();
        return finalStr1;
    }
    
}