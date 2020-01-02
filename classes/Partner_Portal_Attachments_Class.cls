public with sharing class Partner_Portal_Attachments_Class {

 public List<Attachment> atmtList {get;set;}


 public Partner_Portal_Attachments_Class ()
 {
   User currentUser = [SELECT ContactId,email FROM User where id =:Userinfo.getUserId()];
   Contact userContact = [Select AccountId from Contact where id =:currentUser.ContactId ];
   atmtList  = new List<Attachment>();
   atmtList = [SELECT Id,Name FROM Attachment where parentId =:userContact.AccountId];
 }
}