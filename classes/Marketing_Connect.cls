public class Marketing_Connect {

  public List<Marketing_Content__c> contentList_news {get;set;}
  public List<Marketing_Content__c> contentList_events {get;set;}
  public List<Marketing_Content__c> contentList_webs {get;set;}
  public List<Marketing_Content__c> contentList_topics {get;set;}
  public List<Marketing_Content__c> contentList_groups {get;set;}


  public Marketing_Connect()
  {
   contentList_news = [Select Id,Header__c,Type__c,Link__c from Marketing_Content__c where Type__c ='News' and active__c = true order by order__c ];
   contentList_events = [Select Id,Header__c,Type__c,Link__c from Marketing_Content__c where Type__c ='Events' and active__c = true order by order__c];
   contentList_webs = [Select Id,Header__c,Type__c,Link__c from Marketing_Content__c where Type__c ='Webinars' and active__c = true order by order__c];
   contentList_topics = [Select Id,Header__c,Type__c,Link__c from Marketing_Content__c where Type__c ='Chatter Topics' and active__c = true order by order__c];
   contentList_groups = [Select Id,Header__c,Type__c,Link__c from Marketing_Content__c where Type__c ='Chatter Groups' and active__c = true order by order__c];
  }
}