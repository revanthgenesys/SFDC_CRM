//Naresh Kumar  09/08/2014
global without sharing class WinLossWeeklySchedular implements Schedulable{
    global void execute(SchedulableContext SC) {
        sendEmail();        
    }
    
    public static void sendEmail(){
        Set<Id> setOfRecipients = new Set<Id>();
        Set<Id> setOfQueueAsRecipients = new Set<Id>();
        if(Test.isRunningTest()){
        	setOfRecipients.add(UserInfo.getUserId());   
       	}
        else{
            for(String eachId : Label.Win_Loss_Weekly_Recipients.split(',')){
                if(eachId != '' && eachId.startsWith('005'))
                    setOfRecipients.add(eachId);
                else
                    setOfQueueAsRecipients.add(eachId);          
            }   
            for(GroupMember eachGM : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN : setOfQueueAsRecipients]){
                setOfRecipients.add(eachGM.UserOrGroupId);   
            }
        }
        System.debug('NKC debug setOfRecipients ['+setOfRecipients+']');
        Contact objContact = new Contact(id=Label.Temp_Contact_Id_To_Send_Emails);
        List<String> listOfRecipients1 = new List<String>();
        List<String> listOfRecipients2 = new List<String>();
        //for(Integer i = 0; i <= 90 ; i++)
         //   listOfRecipients.add('nareshk.it@gmail.com');
        
        Integer recipientCounter = 1;
        for(User eachUser : [SELECT Email FROM User WHERE id IN : setOfRecipients]){
            if(recipientCounter <= 90)
            	listOfRecipients1.add(eachUser.Email);
            else
                listOfRecipients2.add(eachUser.Email);
            recipientCounter ++;
        }
        EmailTemplate template = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'Win_Loss_Weekly' LIMIT 1];
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        List<String> emailAds = new List<String>();
        List<Messaging.SingleEmailMessage> listOfEmails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setOrgWideEmailAddressId(Label.Win_Loss_Weekly_From_Address);
            mail1.setTargetObjectId(objContact.id);
            mail1.setWhatId(opp.id);
            mail1.setToAddresses(listOfRecipients1);
            mail1.setTemplateId(template.ID);
        	Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail1});
        
        	Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
            mail2.setOrgWideEmailAddressId(Label.Win_Loss_Weekly_From_Address);
            mail2.setTargetObjectId(objContact.id);
            mail2.setWhatId(opp.id);
            mail2.setToAddresses(listOfRecipients2);
            mail2.setTemplateId(template.ID);
        	Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail2});
        
    }
}