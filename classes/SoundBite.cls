/* Test class: Test_CaseSurveyRequestJob
*/
public without sharing class SoundBite 
{
    public String text { get; set; }
    
    
    public SoundBite(){

    }
    public PageReference submit(){
         if(ApexPages.CurrentPage().getparameters().containsKey('id')){    
             callSoundBite(ApexPages.CurrentPage().getparameters().get('id'));
         }
         return null;
    }
    
    public static void sendInfoToSoundBite(List<Case> updatedCases, Map<Id, Case> oldMap){ 
  
      ///surveys are sent to Product Cases only and to external contacts, exclude emails like @genesys.com
   //   ID recTypeId = Global_Setting__c.getInstance('Genesys_Product_Case').ID__c ;
      
      List<Survey_Case_Log__c> survToSentList = new List<Survey_Case_Log__c>();
      
      List<Case> csList = ([SELECT id, Status, ClosedDate, CaseNumber, Contact.FirstName, Contact.LastName, Contact.MobilePhone, Contact.Email,
             Account.Name, Priority, Business_Age__c, Sold_To_Account__r.Name, Owner.Name, Expert_Help__r.Name, Assigned_Manager__r.Name,
             Product_Support_Group__c, Support_Product__r.Name, Component__r.Name, CSM__c, Parent_Escalation__r.CaseNumber, Highest_Level_of_Service__c, 
             Subject, Account.Country__r.Name, Contact_Phone__c, Cloud_Platform__c, BOA_Platform__c, RecordType.DeveloperName FROM Case 
             WHERE id IN : updatedCases 
               AND Status = 'Closed' 
               AND Product_Support_Group__c != 'Custom Applications'
               AND RecordType.DeveloperName IN ('Genesys_Product_Case','Genesys_Cloud_Support_Request','Genesys_Cloud_Service_Request',
                                                 'Genesys_Cloud_Incident', 'Premises_Service_Request')
               AND (NOT Contact.Email LIKE '%genesys.com') 
               AND (NOT Contact.Email LIKE '%genesyslab.com')
               AND (NOT Contact.Email LIKE '%echopass.com')]);

        List<Survey_Case_Log__c> survLogList = [SELECT Case__c, Date_Closed__c FROM Survey_Case_Log__c WHERE Case__c IN : updatedCases];
        
        for(Case eachCase : csList) {  
          Boolean sent = false;      
          if (oldMap.get(eachCase.id).Status != 'Closed' && eachCase.Status == 'Closed') {
            
             ///survey alredy been sent
             for (Survey_Case_Log__c survLog : survLogList )  {
                 if ( eachCase.Id == survLog.Case__c && eachCase.ClosedDate == survLog.Date_Closed__c )
                        sent = true;
                        break;
             }             
             if ( sent == false ) {          
              //string body = prepareJSON(eachCase);
                // callSoundBite(body);             
                   survToSentList.add (new Survey_Case_Log__c(Case__c = eachCase.ID, 
                                                            Date_Closed__c = eachCase.ClosedDate,
                                                            Body__c = prepareJSON(eachCase)));
             }
            }
        }
        
        if ( ! survToSentList.isEmpty() )
            insert survToSentList;
    }
    
  // @future(callout=true)
    public static void callSoundBite(String body){
  
           String endPoint = Label.SoundBite_Credentials.split(',')[0];//'https://service3.soundbite.com/site/c/4/CampaignManagementService/createContactBatch';
           String userName = Label.SoundBite_Credentials.split(',')[1];//'API_international@genesys.com';
           String password = Label.SoundBite_Credentials.split(',')[2];//'g3n34pi!!';
                   
           HttpRequest req = new HttpRequest();
           req.setEndpoint(endPoint);
           req.setMethod('POST');
    
           Blob headerValue = Blob.valueOf(userName + ':' + password);
           String authorizationHeader = 'Basic ' +
           EncodingUtil.base64Encode(headerValue);
           req.setHeader('Authorization', authorizationHeader);
                 
           //string body = prepareJSON(currentCase);
                 
           req.setBody('payload=' + body);             
           // Create a new http object to send the request object
           // A response object is generated as a result of the request  
           // 
           if ( Test.isRunningTest() ) 
               return;
        
           Http http = new Http();
           HTTPResponse res = http.send(req);
           System.debug('*****'+res.getBody());
 
    }
    
   public static String prepareJSON(Case currentCase) {
    	Boolean cldcase = currentCase.RecordType.DeveloperName != null && currentCase.RecordType.DeveloperName.startswith('Genesys_Cloud_') ? true : false;
    	
    	String notify = '';    	
    	if ( cldcase && currentCase.Cloud_Platform__c != null && currentCase.Cloud_Platform__c.startswith('PureConnect') )
    	     notify = 'CCPureConnectNPS@genesys.com';
    	else if ( !cldcase && currentCase.BOA_Platform__c != null && currentCase.BOA_Platform__c.startswith('PureConnect') )
    	     notify = 'CCPureConnectNPS@genesys.com';
    	else
    	     notify = 'CCNPSDetractorAlert@genesys.com';
    	
        String json = '' +
        '[' +
            '{' +
                '"owner": {' +
                    '"internalId": "' + Label.SoundBite_OwnerId + '"' +
                '},' +
                '"campaign": {' +
                    '"externalId": "Customer_Care_Survey"' +
                '},' +
                '"outreachStrategy": {' +
                        '"externalId": "Outbound_Email"' +
                    '}' +           
            '},' +
            '[' +
                '{' +
                    '"externalId": "' + currentCase.CaseNumber + '",' +
                    '"devices": [' +
                        '{' +
                            '"externalId": "' + currentCase.Contact.Email + '"},' +
                            '{"externalId": "' + notify + '"' +
                           '}, ' +
                             '{"externalId": "' + notify + '"' +
                           '}' +
                    '],' +
                    '"attributes": [' +
                        '{' +
                            '"name": "firstName",' +
                            '"value": "' + nullCheck(currentCase.Contact.FirstName) + '"' +
                        '},' +
                        '{' +
                            '"name": "lastName",' +
                            '"value": "' + nullCheck(currentCase.Contact.LastName) + '"' +
                        '},' +
                        '{' +
                            '"name": "company",' +
                            '"value": "' + nullCheck(currentCase.Account.Name) + '"' +
                        '},' +
                        '{' +
                            '"name": "other1",' +
                            '"value": "' + nullCheck(currentCase.Priority) + '|' + currentCase.Business_Age__c + '"' +
                        '},' +
                        '{' +
                            '"name": "other2",' +
                            '"value": "' + nullCheck(currentCase.Sold_To_Account__r.Name) + '"' +
                        '},' +
                        '{' +
                            '"name": "other3",' +
                            '"value": "N|N|N"' +
                        '},' +
                        '{' +
                            '"name": "other4",' +
                            '"value": "' + nullCheck(currentCase.Owner.Name) + '|' + nullCheck(currentCase.Expert_Help__r.Name) + '|' + nullCheck(currentCase.Assigned_Manager__r.Name) + '|' + nullCheck(currentCase.CSM__c) + '"' +
                        '},' +
                        '{' +
                            '"name": "other5",' +
                            '"value": "' + nullCheck(currentCase.Product_Support_Group__c)  + '|' + 
                                           nullCheck( cldcase ? currentCase.Cloud_Platform__c : currentCase.Support_Product__r.Name ) + '|' + 
                                           nullCheck( cldcase ? null : currentCase.Component__r.Name) + '"' +
                        '},' +
                        '{' +
                            '"name": "other6",' +
                            '"value": "' + nullCheck(currentCase.Contact_Phone__c)  + '"' +
                        '},' +
                        '{' +
                            '"name": "other7",' +
                             '"value": "' + nullCheck(Label.Genesys_Authenticated_Base_URL + currentCase.id) + '"' +
                        '},' +
                        '{' +
                            '"name": "other8",' +
                            '"value": "' + nullCheck(currentCase.Highest_Level_of_Service__c) + '"' +
                        '},' +
                        '{' +
                            '"name": "other9",' +
                            '"value": "' + nullCheck(currentCase.Subject) + '"' +
                        '}' +
                    ']' +
                '}' +
            ']' +
        ']';
        System.debug('NKC debug json ['+json+']');
        return json;        
    } 
        
    private static String nullCheck(String value){
        if(value == null)
            return '';
        else 
            return value.replace('&','%26').replace('+','%2B').replace('$','%24').replace(',','%2C').replace('/','%2F').replace(':','%3A').replace(';','%3B').replace('=','%3D').replace('?','%3F').replace('@','%40').replace('"','');
    }
    
}