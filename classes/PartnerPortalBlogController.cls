public with sharing class PartnerPortalBlogController {

	public Blog_Comment__c newComment {get;set;}
	
	public String thePostId {get;set;}
	
	public List<Blog_Comment__c> comments { get; set; }
		
	public PartnerPortalBlogController(ApexPages.StandardController sc) {

		newComment = new Blog_Comment__c();
		
		
		newComment.Blog_Post__c = sc.getRecord().id;
		
		thePostId = sc.getRecord().id;
		
		
		comments = [ SELECT Id,Comment__c,CreatedById, CreatedDate FROM Blog_Comment__c WHERE Blog_Post__r.Id=:thePostId order by CreatedDate ];
		
	}
	
	/*public BlogPostWrapper blogPost { get; set; }
	
	public String commentText { get; set; }
	
	public class BlogPostWrapper {
		public Id blogPostId;
		public String Title { get; set; }
		public String Content { get; set; }
		public List<Blog_Comment__c> comments { get; set; }
		
		public BlogPostWrapper(Blog_Post__c bp) {
			blogPostId=bp.id;
			Title = bp.Name;
			Content = bp.Blog_Content__c;
			comments = [ SELECT Id,Comment__c FROM Blog_Comment__c WHERE Blog_Post__r.Id=:blogPostId ];
		}
	}
	
	public PartnerPortalBlogController() {
		Map<String,String> parms = ApexPages.currentPage().getParameters();
		String bid = parms.get('id');
		Datetime now = Datetime.now();
		List<Blog_Post__c> posts = [ SELECT Name,Blog_Content__c,Publication_Date__c,Expiration_Date__c 
		                               FROM Blog_Post__c 
		                              WHERE Id=:bid AND Expiration_Date__c>:now AND Publication_Date__c<=:now  ];
		 
		Blog_Post__c posting = posts.size()>0 ? posts[0] : null;
		blogPost = posting==null ? null : new BlogPostWrapper(posting);
	}

	// return published, non-expired list of (Id,Name) from Blogs
	public List<Blog_Post__c> getBlogList() {
		Datetime now = Datetime.now();
		List<Blog_Post__c> posts = [ SELECT Id,Name FROM Blog_Post__c 
		                                           WHERE Expiration_Date__c>:now AND Publication_Date__c<=:now 
		                                           ORDER BY CreatedDate ];
		return posts;
	}
*/

	public PageReference addComment() {
		if (newComment!=null) {
			insert newComment;	
		}
		PageReference budgetPage = new PageReference('/partner/Partner_Portal_Blog_Post?id=' + thePostId);
        budgetPage.setRedirect(true);
        return budgetPage;
		
	}
	
	
	
}