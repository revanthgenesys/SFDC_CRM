public with sharing class Portal_Banners_Controller {

    public List<Partner_Portal_Announcement__c> announcementsList{get;set;}

    public Portal_Banners_Controller()
    {
        announcementsList = new List<Partner_Portal_Announcement__c>();
        for(Partner_Portal_Announcement__c rec : [Select Id,name,type__c,title__c,description__c,image__c from Partner_Portal_Announcement__c]){
            if(rec.type__c!=null && rec.type__c.equalsIgnoreCase('Banner'))
                announcementsList.add(rec);
        }
    } 

}