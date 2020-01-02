/* @Class Name   : RFPSupportRequestSchedulerEMEA
 * @Description  : Scheduler class which is used to schedule this class to run at a particular time in a week. This class will be used to send email report.
 * @Created On   : 23/07/2019 
 */
global without sharing class RFPSupportRequestSchedulerEMEA implements Schedulable{
     
    /**    
    * @Description: execute method is overridden from Schedulable Interface. Gets invoked when scheduler invokes the class at defined time.
    * @Param: Scheduler Context
    * @Return: void
    */
    global void execute(SchedulableContext SC) {
        sendEmail();        
    }
    
     
    /**    
    * @Description: Method gets invoked from execute method and used to prepare email to be sent. getting the receipients and template and finally sending an email
    * @Param: none
    * @Return: void
    */
    public static void sendEmail(){
        Set<Id> setOfRecipients = new Set<Id>();
        Set<Id> setOfQueueAsRecipients = new Set<Id>();
        for(String eachId : Label.RFP_Report_EMEA_Recipients.split(',')){
            if(eachId != '' && eachId.startsWith('005'))
                setOfRecipients.add(eachId);
            else
                setOfQueueAsRecipients.add(eachId);          
        }
        List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN : setOfQueueAsRecipients];
        for(GroupMember eachGM : groupMembers){
            setOfRecipients.add(eachGM.UserOrGroupId);   
        }        
        List<User> users = [SELECT Email FROM User WHERE id IN : setOfRecipients];
        List<Contact> tempContacts = new List<Contact>();
        for(User eachUser : users){
            Contact tempContact = new Contact( LastName = 'test', Email = eachUser.Email );
            tempContacts.add(tempContact);
        }
        insert tempContacts;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT id FROM EmailTemplate WHERE DeveloperName =:label.RFP_Email_Template_EMEA LIMIT 1];
        for(Contact eachContact : tempContacts){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
            //OrgWide Address set
            mail.setOrgWideEmailAddressId(Label.RFP_Weekly_From_Address_EMEA);
            //Target Object Id
            mail.setTargetObjectId(eachContact.id);            
            //Set Email Template
            mail.setTemplateId(template.ID);                 
            mails.add(mail);
        }   
        Messaging.sendEmail(mails);
        delete tempContacts;
    }
}