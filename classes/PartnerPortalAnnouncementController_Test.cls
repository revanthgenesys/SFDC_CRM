@isTest
public with sharing class PartnerPortalAnnouncementController_Test {

	static testMethod void testAnnouncements() {
		
		PartnerPortalAnnouncementController ppac = new PartnerPortalAnnouncementController();
		system.assert(ppac.getAnnouncements() != null);
		ppac = new PartnerPortalAnnouncementController('oneOfThePages');
		system.assert(ppac.getAnnouncements() != null);
		
		
	}

}