/*
Created By:    Swastika Rajkhowa
Function:      Batch schedule every 1 hour to send notification to Lead when he not assign the POC to Vitual Team  
*/
global class BatchPOCMailNotifiactionLeadSLA implements Database.Batchable<SObject>, Database.Stateful{
   global Database.QueryLocator start(Database.BatchableContext BC){ 
       //Get SLA Time from Custom setting
        List<WoWLeadSLAMailTime__c > lstTimeInterval = new List<WoWLeadSLAMailTime__c>();
        lstTimeInterval=[SELECT Hour__c FROM WoWLeadSLAMailTime__c where Name=:'Hour Interval'];
        decimal dTimeInterval=lstTimeInterval[0].Hour__c;   
        Datetime lastModifiedDate = System.now().addhours(-integer.valueOf(dTimeInterval));
        
        List<AggregateResult>  lstPOCFilterHst=new List<AggregateResult> ();
        
        //Find all Maximum History Ids which are in Open and Not Assigned state
        lstPOCFilterHst=[SELECT MAX(Id)Id FROM POC_Request_Form_History__c Group by POC_Request_Id__c,Action__c,POC_Engagement_Status__c,POC_Request_Id__r.POC_Status__c Having  Action__c='SLA Email' AND POC_Engagement_Status__c='Open and Not Assigned' and POC_Request_Id__r.POC_Status__c='Open and Not Assigned'];
                
        SET<Id> setPOCList=new SET<Id>();
        SET<Id> setPOCHstAllList=new SET<Id>();
        List<POC_Request_Form_History__c> lstPOCHst=new List<POC_Request_Form_History__c>();
        List<POC_Request_Form_History__c> lstPOCAllDataHst=new List<POC_Request_Form_History__c>();
        lstPOCAllDataHst=[SELECT POC_Request_Id__c FROM POC_Request_Form_History__c WHERE Action__c='SLA Email' AND POC_Engagement_Status__c='Open and Not Assigned'];
        
        for(POC_Request_Form_History__c objHst:lstPOCAllDataHst)
                setPOCHstAllList.add(objHst.POC_Request_Id__c);
        datetime dateHstCreate;
        
        //Find the History ids whose Maxdate is less than 24 hrs comes form custom setting
        for(AggregateResult objHst:lstPOCFilterHst)
        {
            lstPOCHst=[SELECT POC_Request_Id__c FROM POC_Request_Form_History__c WHERE Id=:objHst.Id AND CreatedDate<=:lastModifiedDate];  //Find the POC record from history whose created date before the define time 
            if (lstPOCHst.Size()>0) 
                setPOCList.add(lstPOCHst[0].POC_Request_Id__c);
        }
        
        return Database.getQueryLocator([SELECT Id,CreatedDate,Opportunity_Id__c,Opportunity_Id__r.Name,Opportunity_Id__r.End_User_Region__c,Opportunity_Id__r.Owner.Name FROM POC_Engagement_Request__c WHERE (POC_Status__c=:'Open and Not Assigned' AND CreatedDate<=:lastModifiedDate AND Opportunity_Id__c!=null AND ID NOT IN:setPOCHstAllList)OR ID IN :setPOCList]);
        
       }
   global void execute(Database.BatchableContext BC, List<Sobject> scope) {           
             List<POC_Engagement_Request__c> lstPOC= (List<POC_Engagement_Request__c>)scope; 
             List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
             string strQueueName;
             list<Group> lstGroup=new List<Group>();
             list<GroupMember> lstGroupMem = new list<GroupMember>();
             list<User> lstUser=new list<User>(); 
             list<Opportunity> lstOpp=new list<Opportunity>();
             string[] strmailId= new String[]{}; 
             string body='';
             string subject='';  
             if(lstPOC.Size()>0)
                { 
                 for(POC_Engagement_Request__c objPOC:lstPOC)
                     {
                            string strPOCRequestURL=string.valueof(URL.getSalesforceBaseUrl().toExternalForm())+'/apex/POCEngagementRequest?id='+objPOC.Opportunity_Id__c;  
                           
                            List<string> list_GroupMem =WoWUtility.getSubRegionalUsersForSharing(string.valueof(objPOC.Opportunity_Id__r.End_User_Region__c),string.valueof(objPOC.Opportunity_Id__r.Country_Sub_Region__c));                 
                            
                            lstOpp=[SELECT Account.Name FROM Opportunity WHERE Id=:objPOC.Opportunity_Id__c];
                            //fetch email of queue users
                            Set<string> objUID=new Set<string>();                           
                             //Create a record in History Object and send mail 
                            POCUtility.CreateHistory('SLA Email',UserInfo.getUserId(), 'Schedule Job','Lead Assign','Open and Not Assigned', objPOC.Id);
                            
                            for(string obj: list_GroupMem)
                               objUID.Add(obj);
                            lstUser=[SELECT Name,Email FROM User WHERE UserName IN : objUID]; 
                            
                            if (lstUser.Size()>0)
                                {
                                    for(User objUser:lstUser)
                                          {
                                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                            strmailId.clear(); 
                                            strmailId.add(objUser.Email);
                                            //strmailId.add('swastika.rajkhowa@rsystems.com');
                                            mail.setToAddresses(strmailId);
                                            body='<html><body>Dear ' + objUser.Name+ ',<br><br>A POC Engagement DSR was submitted by '+ objPOC.Opportunity_Id__r.Owner.Name+' tied to '+objPOC.Opportunity_Id__r.Name+'. This DSR has been waiting your approval for 24 hours. Click <a href='+ strPOCRequestURL+'>here</a> to review the DSR as well as approve/reject and re-assign to appropriate POC Engagement owner. If you do not respond to the DSR in 24 hours, you will receive another notification. <br><br>Thanks</body></html>';
                                            mail.setHtmlBody(body);
                                            subject='POC Engagement DSR Submitted for '+lstOpp[0].Account.Name+' '+objPOC.Opportunity_Id__r.Name;                                           
                                            mail.setSubject(subject);    
                                            mails.add(mail);
                                          }
                                 }
                           
                        }  
                    Messaging.sendEmail(mails); //Send bulk mailing by List to overcome the governor limit 10 mails per transaction
                    system.debug('mails' +mails);
               }  
           }         
   global void finish(Database.BatchableContext ctx){
               //Empty
           }
}