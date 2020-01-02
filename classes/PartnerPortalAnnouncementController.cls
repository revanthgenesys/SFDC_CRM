public with sharing class PartnerPortalAnnouncementController {
    
    public List<Partner_Portal_Announcement__c> announcements;
    public String pageName { get; set; }
    
    public PartnerPortalAnnouncementController() {
  		pageName = null;	
  		announcements = null;
    }
    
    public PartnerPortalAnnouncementController(String picklistVal) {
    	pageName = picklistVal;
    	updateAnnouncements();
    }
    
    public void updateAnnouncements() {
    	announcements = [SELECT Announcement__c FROM Partner_Portal_Announcement__c WHERE Portal_Page__c INCLUDES (:pageName) ];
    }
    
    public List<Partner_Portal_Announcement__c> getAnnouncements() {
    	if (pageName==null) return new List<Partner_Portal_Announcement__c>();
    	if (announcements==null) updateAnnouncements();
    	return announcements;
    }
    
}