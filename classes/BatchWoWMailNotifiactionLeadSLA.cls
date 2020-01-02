/*
Created By:    Swastika Rajkhowa
Function:      Batch schedule every 1 hour to send notification to Lead when he not assign the WoW to Vitual Team  
*/
global class BatchWoWMailNotifiactionLeadSLA implements Database.Batchable<SObject>, Database.Stateful{
   global Database.QueryLocator start(Database.BatchableContext BC){ 
       //Get SLA Time from Custom setting
        List<WoWLeadSLAMailTime__c > lstTimeInterval = new List<WoWLeadSLAMailTime__c>();
        lstTimeInterval=[SELECT Hour__c FROM WoWLeadSLAMailTime__c where Name=:'Hour Interval'];
        decimal dTimeInterval=lstTimeInterval[0].Hour__c;   
        Datetime lastModifiedDate = System.now().addhours(-integer.valueOf(dTimeInterval));
        
        system.debug('dTimeInterval '+dTimeInterval);
        system.debug('lastModifiedDate '+lastModifiedDate);
        List<AggregateResult>  lstWoWFilterHst=new List<AggregateResult> ();
        
        //Find all Maximum History Ids which are in Open and Not Assigned state
        lstWoWFilterHst=[SELECT MAX(Id)Id FROM Wow_Request_Form_History__c Group by WoW_Request_Id__c,Action__c,WoW_Status_del__c,WoW_Request_Id__r.WoW_Status__c Having  Action__c='SLA Email' AND WoW_Status_del__c='Open and Not Assigned' and WoW_Request_Id__r.WoW_Status__c='Open and Not Assigned'];
        system.debug('lstWoWFilterHst '+lstWoWFilterHst);
        
        SET<Id> setWoWList=new SET<Id>();
        SET<Id> setWoWHstAllList=new SET<Id>();
        List<Wow_Request_Form_History__c> lstWoWHst=new List<Wow_Request_Form_History__c>();
        List<Wow_Request_Form_History__c> lstWoWAllDataHst=new List<Wow_Request_Form_History__c>();
        lstWoWAllDataHst=[SELECT WoW_Request_Id__c FROM Wow_Request_Form_History__c WHERE Action__c='SLA Email' AND WoW_Status_del__c='Open and Not Assigned'];
        
        for(Wow_Request_Form_History__c objHst:lstWoWAllDataHst)
                setWoWHstAllList.add(objHst.WoW_Request_Id__c);
        datetime dateHstCreate;
        
        //Find the History ids whose Maxdate is less than 24 hrs comes form custom setting
        for(AggregateResult objHst:lstWoWFilterHst)
        {
            lstWoWHst=[SELECT WoW_Request_Id__c FROM Wow_Request_Form_History__c WHERE Id=:objHst.Id AND CreatedDate<=:lastModifiedDate];  //Find the Wow record from history whose created date before the define time 
            if (lstWoWHst.Size()>0) 
                setWoWList.add(lstWoWHst[0].WoW_Request_Id__c);
        }
        system.debug('setWoWList '+setWoWList);
        return Database.getQueryLocator([SELECT Id,CreatedDate,Opportunity_Id__c,Opportunity_Id__r.Name,Opportunity_Id__r.End_User_Region__c,Opportunity_Id__r.Owner.Name FROM Wow_Request_Form__c WHERE (WoW_Status__c=:'Open and Not Assigned' AND CreatedDate<=:lastModifiedDate AND Opportunity_Id__c!=null AND ID NOT IN:setWoWHstAllList)OR ID IN :setWoWList]);
       }
   global void execute(Database.BatchableContext BC, List<Sobject> scope) {           
             List<Wow_Request_Form__c> lstWoW= (List<Wow_Request_Form__c>)scope; 
             List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
             string strQueueName;
             list<Group> lstGroup=new List<Group>();
             list<GroupMember> lstGroupMem = new list<GroupMember>();
             list<User> lstUser=new list<User>(); 
             list<Opportunity> lstOpp=new list<Opportunity>();
             string[] strmailId= new String[]{}; 
             string body='';
             string subject='';             
             system.debug('lstWoW '+lstWoW);
             if(lstWoW.Size()>0)
                { 
                 for(Wow_Request_Form__c objWoW:lstWoW)
                     {
                            string strWowRequestURL=string.valueof(URL.getSalesforceBaseUrl().toExternalForm())+'/apex/wow_request_form?id='+objWoW.Opportunity_Id__c;  
                            //strQueueName=WoWUtility.GetQueueName(objWoW.Opportunity_Id__r.End_User_Region__c); //Find the queue name
                            //lstGroup=[Select Id from Group where type='Queue' and Name=:strQueueName]; //fetch queue id
                            //lstGroupMem =[Select UserOrGroupId From GroupMember where GroupId in:lstGroup]; //fetch User id  
                            List<string> list_GroupMem =WoWUtility.getSubRegionalUsersForSharing(string.valueof(objWoW.Opportunity_Id__r.End_User_Region__c),string.valueof(objWoW.Opportunity_Id__r.Country_Sub_Region__c));                 
                            
                            lstOpp=[SELECT Account.Name FROM Opportunity WHERE Id=:objWoW.Opportunity_Id__c];
                            //fetch email of queue users
                            Set<string> objUID=new Set<string>();
                            // CreateHistory(string Action,string UserId, string UserType, string WowStage,string Status, Id WowId){
                             //Create a record in History Object and send mail 
                            WoWUtility.CreateHistory('SLA Email',UserInfo.getUserId(), 'Schedule Job','Lead Assign','Open and Not Assigned', objWoW.Id);
                              
                            /*for(GroupMember obj: lstGroupMem )
                                objUID.Add(obj.UserOrGroupId);
                            lstUser=[SELECT Name,Email FROM User WHERE Id in:objUID];*/
                            for(string obj: list_GroupMem)
                               objUID.Add(obj);
                            lstUser=[SELECT Name,Email FROM User WHERE UserName IN : objUID]; 
                            system.debug('lstUser'+lstUser);
                            if (lstUser.Size()>0)
                                {
                                    for(User objUser:lstUser)
                                          {
                                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                            strmailId.clear(); 
                                            strmailId.add(objUser.Email);
                                            //strmailId.add('swastika.rajkhowa@rsystems.com');
                                            mail.setToAddresses(strmailId);
                                            body='<html><body>Dear ' + objUser.Name+ ',<br><br>A Wow Engagement DSR was submitted by '+ objWoW.Opportunity_Id__r.Owner.Name+' tied to '+objWoW.Opportunity_Id__r.Name+'. This DSR has been waiting your approval for 24 hours. Click <a href='+ strWowRequestURL+'>here</a> to review the DSR as well as approve/reject and re-assign to appropriate Wow Engagement owner. If you do not respond to the DSR in 24 hours, you will receive another notification. <br><br>Thanks</body></html>';
                                            mail.setHtmlBody(body);                                                   
                                           
                                            subject='Wow Engagement DSR Submitted for '+lstOpp[0].Account.Name+' '+objWoW.Opportunity_Id__r.Name;
                                           
                                            mail.setSubject(subject); 
                                            //Added and commented by Swastika on 30/12/2015 to update the Lead assign in queue 
                                            /*objWoW.Temp_Lead_SLA__c=objUser.Id;
                                            Update objWoW;
                                            //Added by Swastika On 30/12/2015 to send Notification mail from VF template
                                            mail.setTargetObjectId(objUser.Id); //Mandatory field when use template
                                            mail.setWhatId(objWoW.Id); //Assign Wow Id
                                            mail.setTemplateId([select id from EmailTemplate where Name =: 'Wow Engagement Lead SLA'].id);  //Find the template on the basis of name                    
                                            // Send the email you have created.
                                            mail.SaveAsActivity = false; //Mandatory field when use template
                                            */                                  
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