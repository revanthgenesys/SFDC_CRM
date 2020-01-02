@isTest
public with sharing class PartnerPortalBlogController_Test {

	static testMethod void testBlogs() {
		
		Blog_Post__c bPost = new Blog_Post__c();
		bPost.Blog_Content__c = 'this the blogcontent';
		bPost.Expiration_Date__c = Datetime.now() + 10;
		bPost.Publication_Date__c = Datetime.now() -10 ;
		bPost.Home_Page_Flag__c = true;
		insert bPost;
		
		PartnerPortalBlogController ppbc = new PartnerPortalBlogController(new ApexPages.StandardController(bPost));
		
		ppbc.addComment();
		
		System.assert([select id from Blog_Comment__c where Blog_Post__c =: bPost.Id].size() > 0);
		
	}


}