//Ravi V - Sales Compliance -  10/16/2013
global class ComplianexpireBatch implements Database.batchable<Export_Screening_Checklist__c>
{
   global Iterable<Export_Screening_Checklist__c> start(Database.batchableContext info)
   {
        return new ChecklistIterable();     
   }
   global void execute(Database.batchableContext info, List<Export_Screening_Checklist__c> scope)
   {
       List<Export_Screening_Checklist__c> memsToUpdate = new List<Export_Screening_Checklist__c>();
       for(Export_Screening_Checklist__c cl : scope)
       {
           Export_Screening_Checklist__c temp = new Export_Screening_Checklist__c(id=cl.id);
           Date myDate = date.today();
           Integer todayDy = myDate.day();
           Integer todayMon = myDate.month();
           Integer todayyear = myDate.year();
           Integer dy =  cl.Checklist_expiration_date__c.day();
           Integer mon =  cl.Checklist_expiration_date__c.month()-1;
           Integer mon1 =  cl.Checklist_expiration_date__c.month();
           Integer yea =  cl.Checklist_expiration_date__c.year();
           if(todayDy == dy && todayMon == mon && todayyear==yea)
           {
               Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
               List<String> toAddresses = new List<String>();
               toAddresses.add(cl.owner.email);
               email.setToAddresses(toAddresses);
               List<String> ccAddresses = new List<String>();
               ccAddresses.add(cl.account__r.owner.email);
               email.setCcAddresses(ccAddresses);
               email.setSubject('Notification : Export Screening Checklist against Account:'+cl.account__r.name+'Asia will EXPIRE in a month. Please update it to keep it current.');
               String message = '<html><table cellspacing = "7"><tr><td>Dear User,<td></tr><tr><td><p style="text-indent: 5em;"> Please note that the Export Screening Checklist on your Account '+cl.account__r.name+'  will expire on '+mon1+'/'+dy+'/'+yea+'.You must renew the checklist for this customer or end-user before submitting a Sales Order.<br><br>Please click on the link below, review your answers on the Export Screening checklist and click UPDATE. This will automatically set the new expiry date to a year from the date it was updated.<br><br>Name of Account: '+cl.account__r.name+' <br><br>Export Screening Checklist : <a href="https://genesys.my.salesforce.com/'+cl.id+'">'+cl.name+'</a>  and use login credentials.</p></td></tr><br><br><tr><td >Thank You!</td></tr></table></html>';
               email.setHtmlBody(message);
               Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
               Task task = new Task();
               task.WhatId = cl.id;
               task.ownerid=cl.ownerid; 
               task.Activity_Type__c='Record Update';
               task.Subject = 'Notification : Export Screening Checklist against Account:'+cl.account__r.name;
               task.priority= 'High';
               task.status = 'Not Started';
               task.description ='Please note that the Export Screening Checklist on your Account '+cl.account__r.name+' will expire on'+mon1+'/'+dy+'/'+yea+'.You must renew the checklist for this customer or end-user before submitting a Sales Order. Please click on the link below, review your answers on the Export Screening checklist and click UPDATE. This will automatically set the new expiry date to a year from the date it was updated. Name of Account: '+cl.account__r.name+' Export Screening Checklist :  https://genesys.my.salesforce.com/'+cl.id+'. Thank You!' ;
               insert task;
               
            }
           if(todayDy == dy && todayMon == mon1 && todayyear==yea)
           {
             
             temp.status__c='Expired';
             memsToUpdate.add(temp);
            }
        }
       update memsToUpdate;
    }
   global void finish(Database.batchableContext info)
   {
    }
}