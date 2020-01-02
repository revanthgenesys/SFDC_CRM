/*
- Author : MLG
- Company : Kerensen Consulting
- Description : This class list all functions that could be used in other projects
*/

public class Util {

public static string bypassTrigger; //list of trigger that can be bypassed
public static final string userRoleName; // User Role Name
public static final string RtypeId_CoreOppRtype; // Core Opportunity RecordType
public static Map<Id,User> mapUserPRM;
public static boolean Bypass_Trigger_Chk = false;
// Added as part of Cloud Billing project
public static boolean blnRunPPUTrigger = false;
    
public static Boolean blnIgnoreDeleteTrigger = false;
public static Boolean blnIgnoreCalculateMonths = false;
    
    static 
    {       
        // 11/5/2014 : Changing logic to check custom settings for user ids for which triggers are to be skipped (previously bypass flag on users was being checked)
        /*String strUserIds = Global_Configuration_Settings__c.getInstance().Skip_Triggers_For_Users__c;
        if(strUserIds != null && strUserIds.contains(UserInfo.getUserId()))
            Bypass_Trigger_Chk = true;*/
        System.debug('Util.static >>> Util Constructor : BEGIN <<< run by '+ UserInfo.getName());
        User user = [Select BypassApexTriggers__c,Bypass_Triggers__c, UserRole.Name from User where Id =: UserInfo.getUserId() limit 1];
        bypassTrigger = ';' + user.BypassApexTriggers__c + ';';
        
        Bypass_Trigger_Chk = user.Bypass_Triggers__c;
        
        System.Debug('Util.static >>>  bypassTrigger :'+bypassTrigger);
        userRoleName = user.UserRole.Name;  
        System.Debug('Util.static >>>  Assigned Name ' + userRoleName);
        
        // ECD Added this catch for testing not production. Should continue to function as normal.
        try {
	        RtypeId_CoreOppRtype = Config.CORE_OPP_RTYPE;
        } catch (Exception E) {
            System.debug('Caught Exception: ' + E);
        }
        System.Debug('Util.static >>>  RtypeId_CoreOppRtype ' + RtypeId_CoreOppRtype);
    }

//return Map of PRM Users owning Opportunities in Trigger.New or Trigger.Old
public static Map<Id,User> getUserPRMinTriggerContext(Opportunity[] myNewOpps,Opportunity[] myOldOpps)
{
        Util.mapUserPRM = new Map<Id, User>([Select Id, UserType From User where UserType =:Config.USER_PARTNER AND (Id IN :Util.getOwnerIds(myNewOpps) OR Id IN :Util.getOwnerIds(myOldOpps))]);
        return Util.mapUserPRM;
}

public static set<Id> ESDOpptyRecordTypeId()
    {
        System.Debug('## Start ESDOpptyRecordTypeId');
        set<Id> SetRT = new Set<Id>();
        SetRT.add(Config.CORE_OPP_RTYPE_APP_PROCESS);
        SetRT.add(Config.CORE_OPP_RTYPE);
        System.Debug('## End ESDOpptyRecordTypeId');
        return setRT;
    }

public static boolean canTrigger(string ApexName) //if no bypass
{
    System.Debug('## >>> canTrigger() <<< '+ApexName);
    if(bypassTrigger == null)
        bypassTrigger = ';' + [SELECT Bypass_Triggers__c FROM User WHERE Id = :UserInfo.getUserId()].Bypass_Triggers__c + ';';

    return (bypassTrigger.indexOf(';' + ApexName+ ';') == -1);
}

 //check if current get RecordTypeID from RecordType Name
 public static string getRtypeId(String rTypeName)
 {
        System.Debug('## >>> Starting Util.getRtypeId <<<');
        System.Debug('## >>> Get RecordTypeName from RtypeId for RecordTypeName:'+rTypeName);
        RecordType rt = [Select Id From RecordType where name =: rTypeName];
        System.Debug('## >>>>> end of Util.getOppRtypeId -> Return:'+rt.Id +' <<<<<');
        return String.ValueOf(rt.Id);
 }
 
  //check if current get ProfileID from Profile Name
 public static string getProfileId(String profileName)
 {
        System.Debug('## >>> Starting Util.getProfileId <<<');
        System.Debug('## >>> Get profileName from ProfileID for profileName :'+profileName);
        list<Profile> pr = [Select Id From Profile where name =: profileName limit 1];
        if(pr.size()>0){
            System.Debug('## >>>>> end of Util.getProfileId -> Return:'+pr[0].Id +' <<<<<');
            return String.ValueOf(pr[0].Id);
        }
        return '';
 }
    
public static Set<Id> getIds(List<sObject> lstObjetct) { 
    Set<Id> idSet = new Set<Id>(); 
    for(sObject obj:lstObjetct) { 
        if(obj.Id != null) idSet.add(obj.Id); 
    } 
    return idSet;
}

public static Set<Id> getOwnerIds(List<Opportunity> lstOpp) { 
    Set<Id> idSet = new Set<Id>(); 
    for(Opportunity opp:lstOpp) { 
        if(opp.OwnerId != null) 
        {
            idSet.add(opp.OwnerId); 
            System.debug('OwnerId IdSet:'+opp.OwnerId);
        }
    } 
    System.debug('Owner IdSet Size:'+idSet.size());
    return idSet;
}

public static Set<String> getSetFromFieldName(List<sObject> lstObject, string fieldName) { 
    System.Debug('### START - getSetFromFieldName()');
    Set<String> stringSet = new Set<String>(); 
    for(sObject obj:lstObject) { 
        if(obj.get(fieldName) != null) stringSet.add((String)obj.get(fieldName)); 
        System.debug('## '+ fieldName + ' IdSet:'+(String)obj.get(fieldName));
    } 
    System.debug('## ' + fieldName + ' IdSet Size:'+stringSet.size());
    System.Debug('### END - getSetFromFieldName()');
    return stringSet;
}

public static Map<String,String> mapBuildFromList(List<sObject> lstObject, string keyFieldName, string valueFieldName)
{
    System.Debug('### START - mapBuildFromList()');
    Map<String,String> mapString = new Map<String,String>();
    for(sObject obj:lstObject) { 
        if(obj.get(keyFieldName) != null && obj.get(valueFieldName) != null)
            mapString.put((String)obj.get(keyFieldName),(String)obj.get(valueFieldName));
        System.debug('## Insert Map (Key:'+ (String)obj.get(keyFieldName) + ', Value:'+(String)obj.get(valueFieldName));
    } 
    System.debug('## Map Size:'+mapString.size());
    System.Debug('### END - mapBuildFromList()');
    return mapString;
}
public static String getListIdForDynamicSoql(Set<String> idSet)
     {
        System.Debug('### START - getListIdFromMap()');
        String strList ='';
        Integer cpt = 1;
        for(String id : idSet)
        {
            if(idSet.size() == cpt)  //pas de virgule pour dernier item
                strList+= '\''+ id + '\'';
            else
             strList+= '\''+ id + '\',';
             
            cpt++;
        }
        System.debug('### Result List:'+strList);
        System.debug('### END - getListIdFromMap()');
        return strList;
     }
////////////////////////////////////////////
//// MANUAL SHARE - PRM02 - OPPORTUNITY ////
////////////////////////////////////////////
public static OpportunityShare manualShareOppEdit(Id recordId, Id userOrGroupId){
    
    System.Debug('## >>> Starting PRM01Opportunity.manualShareEdit <<< recordId:'+recordId+',userOrGroupId:'+userOrGroupId);
    
      // Create new sharing object for the Opportunity
      OpportunityShare oppShare  = new OpportunityShare(); 
   
      // Set the ID of record being shared.
       oppShare.OpportunityId = recordId;
        
      // Set the ID of user or group being granted access.
       oppShare.UserOrGroupId = userOrGroupId;
       //oppShare.UserOrGroupId = '00520000000n2nQAAQ';
       
      // Set the access level.
      oppShare.OpportunityAccessLevel = 'Edit';
        
      // Set rowCause to 'manual' for manual sharing.
      // This line can be omitted as 'manual' is the default value for sharing objects.
      //OpportunityShare.RowCause = Schema.OpportunityShare.RowCause.Manual;
        
      // Insert the sharing record and capture the save result. 
      // The false parameter allows for partial processing if multiple records passed 
      // into the operation.
      System.Debug('UserId:'+UserOrGroupId+',OpportunityId:'+recordId);
     
     return oppShare;
}

public static void  insertOppTMember(List<OpportunityTeamMember> myLstOppTMember)
{   
        Database.SaveResult[] lsr = Database.insert(myLstOppTMember,false);

        // Iterate through the Save Results
        for(Database.SaveResult sr:lsr)
        {
           if(!sr.isSuccess()){
            System.debug('## ERREUR INSERTION TEAM MEMBER');
            Database.Error err = sr.getErrors()[0];
            System.debug('## ERREUR Status / Message: '+err.StatusCode+ ' / ' + err.getMessage());
           }
           else
           {
            System.debug('## OpportunityTeamMember ID created:'+sr.getId());
           }
         }
}

public static void insertOppShare(List<OpportunityShare> myLstoppShare)
{
    
     Database.SaveResult[] lsr = Database.insert(myLstoppShare,false);
    
    // Iterate through the Save Results
        for(Database.SaveResult sr:lsr)
        {
            if(!sr.isSuccess())
            {
             Database.Error err = sr.getErrors()[0];
             System.debug(err.getMessage());
             // Check if the error is related to trival access level.
             // Access levels equal or more permissive than the object's default 
             // access level are not allowed. 
             // These sharing records are not required and thus an insert exception is acceptable. 
             if(err.getStatusCode() == StatusCode.FIELD_INTEGRITY_EXCEPTION  &&  
                      err.getMessage().contains('AccessLevel')){
                // Indicates success.
                System.debug('OK : These sharing records are not required and thus an insert exception is acceptable');
             }
           }
           else
           {
            System.debug('## OpportunityShare ID created:'+sr.getId());
           }
        }
}

////////////////////////////////////////////
//// MANUAL SHARE - PRM04 - ACCOUNT ////
//////////////////////////////////////////// 

public static AccountShare manualShareAcc(Id ashId,Id recordId, Id userOrGroupId, string accountAccessLevel, string contactAccessLevel, string opportunityAccessLevel, string caseAccessLevel ){
    
    System.Debug('## >>> Starting Util.manualShareEdit <<< recordId:'+recordId+',userOrGroupId:'+userOrGroupId);
    
      // Create new sharing object for the Account
      AccountShare accShare  = new AccountShare(Id = ashId); 
        
      // Set the ID of record being shared.
       accShare.AccountId = recordId;
        
      // Set the ID of user or group being granted access.
       accShare.UserOrGroupId = userOrGroupId;
       //oppShare.UserOrGroupId = '00520000000n2nQAAQ';
       
      // Set the access level.
      accShare.AccountAccessLevel = accountAccessLevel;
       //MLG 01/10/2010
      accShare.ContactAccessLevel = contactAccessLevel;
      accShare.OpportunityAccessLevel = opportunityAccessLevel;
      accShare.CaseAccessLevel = caseAccessLevel;
     
      // Set rowCause to 'manual' for manual sharing.
      // This line can be omitted as 'manual' is the default value for sharing objects.
      //OpportunityShare.RowCause = Schema.OpportunityShare.RowCause.Manual;
        
      // Insert the sharing record and capture the save result. 
      // The false parameter allows for partial processing if multiple records passed 
      // into the operation.
      System.Debug('UserId:'+UserOrGroupId+',AccountId:'+recordId);
      System.Debug('## >>> Ending Util.manualShareEdit <<<');
     return accShare;
 
}


public static void  insertAccTMember(List<AccountTeamMember> myLstAccTMember)
{   
        Database.SaveResult[] lsr = Database.insert(myLstAccTMember,false);

        // Iterate through the Save Results
        for(Database.SaveResult sr:lsr)
        {
           if(!sr.isSuccess()){
            System.debug('## ERREUR INSERTION TEAM MEMBER');
            Database.Error err = sr.getErrors()[0];
            System.debug('## ERREUR Status / Message: '+err.StatusCode+ ' / ' + err.getMessage());
           }
           else
           {
            System.debug('## AccountTeamMember ID created:'+sr.getId());
           }
         }
}

public static void insertAccShare(List<AccountShare> myLstAccShare)
{
    
     Database.SaveResult[] lsr = Database.insert(myLstAccShare,false);
    
    // Iterate through the Save Results
        for(Database.SaveResult sr:lsr)
        {
            if(!sr.isSuccess())
            {
             Database.Error err = sr.getErrors()[0];
             System.debug(err.getMessage());
             // Check if the error is related to trival access level.
             // Access levels equal or more permissive than the object's default 
             // access level are not allowed. 
             // These sharing records are not required and thus an insert exception is acceptable. 
             if(err.getStatusCode() == StatusCode.FIELD_INTEGRITY_EXCEPTION  &&  
                      err.getMessage().contains('AccessLevel')){
                // Indicates success.
                System.debug('OK : These sharing records are not required and thus an insert exception is acceptable');
             }
           }
           else
           {
            System.debug('## AccountShare ID created:'+sr.getId());
           }
        }
}


public static Map<Id,Account> getAccountMapFromOpportunities(Set<Id> idSet) { 
    Map<Id,Account> mapAccount = new Map<Id,Account>([Select Id, Country__c from Account where Id in:idSet] ); 
    System.debug('IdSet Size:'+idSet.size());
    System.debug('mapAccount Size:'+mapAccount.size());
    return mapAccount; 
} 

public static Set<Id> getAccountIds(List<Opportunity> lstOpp) { 
    Set<Id> idSet = new Set<Id>(); 
    for(Opportunity opp:lstOpp) { 
        if(opp.AccountId != null) {
            idSet.add(opp.AccountId); 
            System.debug('Account IdSet:'+opp.AccountId);
        }
        
    } 
    System.debug('Account IdSet Size:'+idSet.size());
    return idSet;
} 

public static List<AccountShare> getLstAccShareToUpdate(Set<Id> idsAccount, Set<Id> idsUser, String AccessLevelSrc, String AccessLevelDest )
{
    List<AccountShare> myLstAccShare =  new List<AccountShare>([
    Select Id, AccountId, UserOrGroupId, AccountAccessLevel from AccountShare
    where (AccountId IN : idsAccount AND UserOrGroupId IN : idsUser)]);
    
    System.debug('## List of AccountShare object to update to "Read/Write Access:'+myLstAccShare.size());
    for(AccountShare accS : myLstAccShare)
    {
        accS.AccountAccessLevel = AccessLevelDest;
    }
    //System.debug('## AccountAccessLevel:'+myLstAccShare.get(0).AccountAccessLevel);
    
    return myLstAccShare;
}

public static Map<Id, AccountTeamMember> getUserPRMtoDeleteFromAccountTeam(List<Opportunity> lstOpp)
{
//Get AccountTeam member which user PRM is
    Map<Id,AccountTeamMember> accTMMap =  new Map<Id,AccountTeamMember>(
     [Select UserId, TeamMemberRole, AccountId, AccountAccessLevel, Id 
     From AccountTeamMember
     Where (AccountId in : Util.getAccountIds(lstOpp))
            AND (TeamMemberRole =: Config.BP_TEAM_MEMBER_ROLE)
            AND UserId In : mapUserPRM.keySet()]);
            //MECommentaire ligne below MLG 10/06/2009
            //AND UserId In : Util.getUserPRMinTriggerContext(null,null).KeySet()]); // User is PRM User in TriggerContext Old/New (we put null in parameter as Map is already defined)
    
     return accTMMap;
}


public static void sendEmail(String[] toAddresses, String body)
{
    // Create a new single email message object
// that will send out a single email to the addresses in the To, CC & BCC list.
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

// Strings to hold the email addresses to which you are sending the email.
//String[] toAddresses = new String[] {'user@acme.com'}; 
//String[] ccAddresses = new String[] {'smith@gmail.com'};
  
// Assign the addresses for the To and CC lists to the mail object.
mail.setToAddresses(toAddresses);
//mail.setCcAddresses(ccAddresses);

// Specify the address used when the recipients reply to the email. 
mail.setReplyTo('didier.comte@alcatel-lucent.fr');

// Specify the name used as the display name.
mail.setSenderDisplayName('');

// Specify the subject line for your email address.
mail.setSubject('TM - Field over 255 length');
// Set to True if you want to BCC yourself on the email.
mail.setBccSender(false);
// Optionally append the salesforce.com email signature to the email.
// The email address of the user executing the Apex Code will be used.
mail.setUseSignature(false);
// Specify the text content of the email.
//mail.setPlainTextBody('Your Case: ' + case.Id +' has been created');

mail.setHtmlBody(body);
//Values not taken into account because of 255 caracters field size
// 'TM Account Field XXX' : Opty Value (Opp.Id :XXX), Opty Value (Opp.Id:XXX)
// Send the email you have created.
if(!Test.isRunningTest())
	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}

////////////////////////////////////////////////////////
//// BATCH METHODS - BA01 - OPPORTUNITY AND ACCOUNT ////
////////////////////////////////////////////////////////

public static void dataBaseActionLstSobjects(List<SObject> lstSobj,String Action,List<ErrorLogItem> lstErrorLogItem,Map<String,Integer> mapObjectNbSuccessDML,Map<String,Integer> mapObjectNbErrorDML )
{
    System.debug('### START dataBaseActionLstSobjects()');
    
    Database.SaveResult[] lsr;
    Database.DeleteResult[] lsrDelete;
    
    if(Action == 'Update'){
        lsr = Database.update(lstSobj,false);
        reportSaveResult(lsr, lstSobj,lstErrorLogItem,mapObjectNbSuccessDML,mapObjectNbErrorDML);
    }
    else if(Action == 'Insert'){
        lsr = Database.insert(lstSobj,false);
        reportSaveResult(lsr, lstSobj,lstErrorLogItem,mapObjectNbSuccessDML,mapObjectNbErrorDML);
    } 
    // Process the delete results
    else if(Action == 'Delete'){
        lsrDelete = Database.delete(lstSobj,false);
        reportDeleteResult(lsrDelete, lstSobj,lstErrorLogItem,mapObjectNbSuccessDML,mapObjectNbErrorDML);
    }
    System.debug('### END dataBaseActionLstSobjects()');
}   
    
public static void reportSaveResult(List<Database.SaveResult> lsr, List<SObject> lstSobj,List<ErrorLogItem> lstErrorLogItem,Map<String,Integer> mapObjectNbSuccessDML,Map<String,Integer> mapObjectNbErrorDML)
{
    System.debug('### START Util.reportSaveResult()');
    Integer cpt = 0;  //index of listObj, see NOTE Below
    String SObjectName = lstSobj.get(0).getSObjectType().getDescribe().getName();
    // Process the save results
    for(Database.SaveResult sr : lsr)
    {
        if(!sr.isSuccess())
        {
            //mapIdItemProcessedErrorMsg.put(lstSobj.get(cpt).Id,sr.getErrors()[0].getStatusCode() + ':'+ sr.getErrors()[0].getMessage());  
            ErrorLogItem errItem = new ErrorLogItem();
            errItem.Id = lstSobj.get(cpt).Id;
            errItem.objectTypeItem = SObjectName;
            errItem.ErrorMsg = sr.getErrors()[0].getStatusCode() + ':'+ sr.getErrors()[0].getMessage();
            lstErrorLogItem.add(errItem);
            //NOTE : sr.getId() does not work when an error occurs
            Util.myLog('Id Item Error:'+ lstSobj.get(cpt) +', Error message:' + sr.getErrors()[0]);
            //COMPTEUR ERROR
            if(mapObjectNbErrorDML.get(SObjectName) == null)
                mapObjectNbErrorDML.put(SObjectName,1);
            else
                mapObjectNbErrorDML.put(SObjectName,mapObjectNbErrorDML.get(SObjectName)+1);
        }
        else
        {   Util.myLog('Id Item Success:'+ sr.getId());
            //COMPTEUR SUCCESS
            if(mapObjectNbSuccessDML.get(SObjectName) == null)
                mapObjectNbSuccessDML.put(SObjectName,1);
            else
                mapObjectNbSuccessDML.put(SObjectName,mapObjectNbSuccessDML.get(SObjectName)+1);
        }
        cpt++;
    }
    System.debug('### END Util.reportSaveResult()');
}


public static void reportDeleteResult(List<Database.DeleteResult> lsrDelete, List<SObject> lstSobj,List<ErrorLogItem> lstErrorLogItem,Map<String,Integer> mapObjectNbSuccessDML,Map<String,Integer> mapObjectNbErrorDML)
{
    Util.myLog('### START Util.reportDeleteResult()');
    Integer cpt = 0;  //index of listObj, see NOTE Below
    String SObjectName = lstSobj.get(0).getSObjectType().getDescribe().getName();
    // Process the save results
    for(Database.DeleteResult sr : lsrDelete)
    {
        if(!sr.isSuccess())
        {
            //mapIdItemProcessedErrorMsg.put(lstSobj.get(cpt).Id,sr.getErrors()[0].getStatusCode() + ':'+ sr.getErrors()[0].getMessage());  
            ErrorLogItem errItem = new ErrorLogItem();
            errItem.Id = lstSobj.get(cpt).Id;
            errItem.objectTypeItem = SObjectName;
            errItem.ErrorMsg = sr.getErrors()[0].getStatusCode() + ':'+ sr.getErrors()[0].getMessage();
            lstErrorLogItem.add(errItem);
            //NOTE : sr.getId() does not work when an error occurs
            Util.myLog('Id Item Error:'+ lstSobj.get(cpt) +', Error message:' + sr.getErrors()[0]);
            //COMPTEUR ERROR
            if(mapObjectNbErrorDML.get(SObjectName) == null)
                mapObjectNbErrorDML.put(SObjectName,1);
            else
                mapObjectNbErrorDML.put(SObjectName,mapObjectNbErrorDML.get(SObjectName)+1);
        }
        else
        {   Util.myLog('Id Item Success:'+ sr.getId());
            //COMPTEUR SUCCESS
            if(mapObjectNbSuccessDML.get(SObjectName) == null)
                mapObjectNbSuccessDML.put(SObjectName,1);
            else
                mapObjectNbSuccessDML.put(SObjectName,mapObjectNbSuccessDML.get(SObjectName)+1);
        }
        cpt++;
    }
    Util.myLog('### END Util.reportDeleteResult()');
}       
    public static void batchApexFinishReport(Database.BatchableContext BC,String batchEmailSubject,String batchObjectName,Set<String> setObjectsTreated,List<ErrorLogItem > lstErrorLogItem,Map<String,Integer> mapObjectNbSuccessDML,Map<String,Integer> mapObjectNbErrorDML)
{
     System.Debug('### START - Util.batchApexFinishReport()');
     AsyncApexJob a = [SELECT id, ApexClassId, Status,CreatedDate, CompletedDate,
                          JobItemsProcessed, 
                          TotalJobItems, 
                          NumberOfErrors, 
                          CreatedBy.Email 
                          FROM AsyncApexJob 
                          WHERE id = :BC.getJobId()];
         
         Integer sumErrors =  0;
         for(String obj : setObjectsTreated) sumErrors += mapObjectNbErrorDML.get(obj);
         String subject = batchEmailSubject+' Report ['+ batchObjectName +'] - Nb Erreurs :'+sumErrors;
         
         String emailMessage = subject;
         emailMessage += '<br /> Task started:' + a.CreatedDate;
         emailMessage += '<br /> Task ended:' + a.CompletedDate;
         emailMessage += '<br /> Result : \n' + a.totalJobItems  + ' / ' + a.TotalJobItems + ' Jobs de 200 éléments traités (batchSize = 200)';
         emailMessage += '<br /> '+ a.NumberOfErrors +' Job(s) en Erreur';
         emailMessage +=' <br />';
         for(String obj : setObjectsTreated)
         {
             emailMessage += '<br /> Nbr '+obj+'s Mis à jour:' + mapObjectNbSuccessDML.get(obj);
             emailMessage += '<br /> Nbr '+obj+'(s) en Erreurs:' + mapObjectNbErrorDML.get(obj);
             emailMessage +=' <br />'; 
         }
         emailMessage +=' <br />';
         emailMessage += 'Liste des erreurs : <hr />';
         emailMessage += 'Id,Objet,Error <br />';
         //Log Errors
         for(ErrorLogItem item : lstErrorLogItem)
            emailMessage += item.Id +','+ item.objectTypeItem + ','+ item.ErrorMsg +'<br />';
         //for(Id sObjId : mapIdItemProcessedErrorMsg.keySet())
        //  emailMessage += sObjId +','+ mapIdItemProcessedErrorMsg.get(sObjId) + '<br />';
         Messaging.SingleEmailMessage mail = 
                  new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[] 
                  {a.createdBy.email};
         if(System.Label.BA01_EmailDest != '' && System.Label.BA01_EmailDest != null)
            toAddresses.add(System.Label.BA01_EmailDest);
         mail.setToAddresses(toAddresses);
         mail.setReplyTo('noreply@salesforce.com');
         mail.setSenderDisplayName('Batch Job Summary');
         mail.setSubject(subject);
         mail.setPlainTextBody(emailMessage);
         mail.setHtmlBody(emailMessage.replace('\\n', '<br />'));
         if(!Test.isRunningTest())
         	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
       System.Debug('### END - Util.batchApexFinishReport()');
}

    public static String getSoqlListIdFromSet(Set<Id> idSet)
     {
        System.Debug('### START - getSoqlListIdFromSet()');
        String strList ='';
        Integer cpt = 1;
        for(Id id : idSet)
        {
            if(idSet.size() == cpt)  //pas de virgule pour dernier item
                strList+= '\''+ id + '\'';
            else
             strList+= '\''+ id + '\',';
             
            cpt++;
        }
        System.debug('### Result List:'+strList);
        System.debug('### END - getSoqlListIdFromSet()');
        return strList;
     }
     
    public static void myLog(String myString){system.debug('###### >>> '+myString+' <<< ######');}
    
    public Class Wrappers {
        public sobject obj {get; set;}
        public Boolean isSelected {get; set;}
        public Boolean isMoved {get; set;}
        public Wrappers(sobject o){
            this.obj = o;
            isSelected = false;
            isMoved = false;
        }
        
    }
    
    //*** Calculates duration between dates in months ***
    public static Decimal calculateDurationInMonths(Date dtStart,Date dtEnd)
    {
        Decimal decMonthsDuration = 0.0;
        Integer intMonths = dtStart.monthsBetween(dtEnd);
        if(intMonths == 0)
        {
            // Multiplied by 1.0 to prevent data precision loss before data type promotion
            decMonthsDuration = (dtStart.daysBetween(dtEnd) + 1)/(Date.daysInMonth(dtStart.year(), dtStart.month()) * 1.0);
        }
        else
        {
            decMonthsDuration += intMonths - 1;
            // Start Date Month
            Integer intStartDateMonthDays = Date.daysInMonth(dtStart.year(), dtStart.month());
            decMonthsDuration += (intStartDateMonthDays - dtStart.day() + 1)/(intStartDateMonthDays * 1.0);
            // End Date Month
            Integer intEndDateMonthDays = Date.daysInMonth(dtEnd.year(), dtEnd.month());
            decMonthsDuration += (dtEnd.day())/(intEndDateMonthDays * 1.0);
        }
        return decMonthsDuration;
    }
    
    //*** Converts an amount from one currency to another ***
    public static Decimal convertCurrencyCustom(String strOldCurrencyCode, String strNewCurrencyCode,
                                                    Map<String,Decimal> map_ConversionRates, Decimal decAmount)
    {
        if(decAmount == null)
            return null;        

        //Convert incoming Amount into USD
        Decimal decConversionRate = map_ConversionRates.get(strOldCurrencyCode);
        if(decConversionRate != 0.0 && decConversionRate != null)
            decAmount = decAmount / decConversionRate;
        
        //Convert amount as per new currency
        if(strNewCurrencyCode != 'USD')
        {
            decConversionRate = map_ConversionRates.get(strNewCurrencyCode);
            if(decConversionRate != null)
                decAmount = decAmount * decConversionRate;
        }
        return decAmount;
    }
    
    public static List<BigMachines__Quote_Product__c> createQPFromOnPremiseToRenewal(Id idSrcQuote,BigMachines__Quote__c objDestQuote)
    {
        List<BigMachines__Quote_Product__c> list_QuoteProducts = new List<BigMachines__Quote_Product__c>();
        
        for(BigMachines__Quote_Product__c objSrcQP : [SELECT BigMachines__Quantity__c,Ext_Net_Price__c,BigMachines__Product__c,
                        BigMachines__Product__r.Name,BigMachines__Product__r.APN_Number__c,BigMachines__Product__r.Description,
                        List_Price__c
                        FROM BigMachines__Quote_Product__c WHERE 
                        BigMachines__Quote__c = :idSrcQuote AND BigMachines__Product__r.Genesys_Care_Quote__c = false
                        AND BigMachines__Product__r.Type__c NOT IN ('Genesys Care','Bundle')])
        {
            BigMachines__Quote_Product__c objDestQP = new BigMachines__Quote_Product__c();
            objDestQP.BigMachines__Quote__c = objDestQuote.Id;
            objDestQP.Original_Qty__c = objSrcQP.BigMachines__Quantity__c;
            objDestQP.Current_Qty__c = objSrcQP.BigMachines__Quantity__c;
            objDestQP.BigMachines__Quantity__c = objSrcQP.BigMachines__Quantity__c;
            objDestQP.Revised_Net_License_Value__c = objSrcQP.Ext_Net_Price__c;
            objDestQP.Revised_Net_From_Contract_Line__c = objSrcQP.Ext_Net_Price__c;
            objDestQP.Original_Net_License_Value__c = objSrcQP.Ext_Net_Price__c;
            objDestQP.List_Price__c = objSrcQP.List_Price__c;
            objDestQP.BigMachines__Sales_Price__c = 0;
            objDestQP.Previous_Line_Maintenance_Value__c = 0;
            objDestQP.BigMachines__Product__c = objSrcQP.BigMachines__Product__c;
            objDestQP.Name = objSrcQP.BigMachines__Product__r.Name;
            objDestQP.APN_Number__c = objSrcQP.BigMachines__Product__r.APN_Number__c;
            objDestQP.BigMachines__Description__c = objSrcQP.BigMachines__Product__r.Description;
            objDestQP.Maintenance_Start_Date__c = objDestQuote.Maintenance_Start_Date__c;
            objDestQP.Maintenance_End_Date__c = objDestQuote.Maintenance_End_Date__c;
            objDestQP.CurrencyISOCode = objDestQuote.CurrencyISOCode;
            
            list_QuoteProducts.add(objDestQP);
        }
        
        return list_QuoteProducts;
    }
    
   
    //Added by Swastika on 26-oct-2015
   /* public static string getCreatableFieldsSOQL(String objectName, String whereClause){         
        String selects = '';         
        if (whereClause == null || whereClause == ''){ return null; }         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}             
        }         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;         
    }*/
    

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
    
  public static String getPriceFieldName(String quoteCurrency){
        String strPricebookFieldName = '';
        if(quoteCurrency == 'USD'){
            strPricebookFieldName = 'NG5_NA_USD_Price__c';
        }
        else if(quoteCurrency == 'AUD'){
            strPricebookFieldName = 'NG1_APAC_ANZ_AUD_Price__c';
        }
        else if(quoteCurrency == 'BRL'){
            strPricebookFieldName = 'NG2_BRAZIL_BRL_Price__c';
        }
        else if(quoteCurrency == 'CAD'){
            strPricebookFieldName = 'NG5_NA_CAD_Price__c';
        }
        else if(quoteCurrency == 'EUR'){
            strPricebookFieldName = 'NG3_EMEA_EUR_Price__c';
        }
        else if(quoteCurrency == 'GBP'){
            strPricebookFieldName = 'NG3_EMEA_GBP_Price__c';
        }
        else if(quoteCurrency == 'JPY'){
            strPricebookFieldName = 'NG4_APAC_JAPAN_YEN_Price__c';
        }
        else if(quoteCurrency == 'NZD'){
            strPricebookFieldName = 'NG5_NZD_Price__c';
        }
        else if(quoteCurrency == 'ZAR'){
            strPricebookFieldName = 'NG5_ZAR_Price__c';
        }
        return strPricebookFieldName;
    }  
}