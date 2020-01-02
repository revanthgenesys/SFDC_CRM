@isTest
public with sharing class PartnerPortalHomeController_Test {


	static testMethod void testHomePageLanding() {
		
		
		Partner_Portal_Video__c video = new Partner_Portal_Video__c();
		
		video.Video_Link__c = 'https://sfdc.com';
		video.Video_Type__c = 'Youtube';
		video.Title__c = 'sfdc';
		video.Home_Page_Flag__c=true;
		insert video;
		
		
		Blog_Post__c bPost = new Blog_Post__c();
		bPost.Blog_Content__c = 'this the blogcontent';
		bPost.Expiration_Date__c = Datetime.now() + 10;
		bPost.Publication_Date__c = Datetime.now() -10 ;
		bPost.Home_Page_Flag__c = true;
		insert bPost;
		
		
		Partner_Portal_Events_Webinars__c ppew = new Partner_Portal_Events_Webinars__c();
		ppew.name = 'videoNameTest';
		ppew.Event_Id__c = video.id;
		ppew.Order__c = 1;
		insert ppew ; 
		     
		     
		Partner_Portal_Hot_Content__c pphc = new Partner_Portal_Hot_Content__c();
		pphc.name = 'videoNameTest';
		pphc.Content_Id__c =video.id;
		pphc.Order__c = 1;
		insert pphc ;                                                    
		                                                        
		                                                        
		
		PartnerPortalHomeController pphctrl = new PartnerPortalHomeController();
		
		
		System.assert (pphctrl.hotContentLinks != null);
		
		System.assert (pphctrl.eventContentLinks != null);
		
		System.assert (pphctrl.selected_blog_post.id == bPost.id);
		
		System.assert (pphctrl.spotlight_video.id == video.id);
		
		
		
		
		
	}



}