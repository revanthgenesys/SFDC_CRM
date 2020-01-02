public with sharing class CommunityRightSideBar {

	public List<Idea> getMostRecentIdeas (){
		return [Select i.Title, i.CreatedDate, i.CommunityId From Idea i where i.CommunityId =: CommunitySettings__c.getInstance().community_id__c order by i.CreatedDate DESC limit 5];
	}

	public List<Question> getMostPopular (){
		return [Select q.VoteScore,q.Title, q.Priority, q.Origin, q.LastReplyId, q.Id, q.CreatedDate, q.CreatedById, q.CommunityId, q.Body, q.BestReplyId From Question q 
						where q.CommunityId =: CommunitySettings__c.getInstance().community_id__c
							order by q.VoteScore DESC limit 5];
	}
	
	public List<Question> getRecentPosts (){
		return [Select q.LastReplyDate,q.VoteScore,q.Title, q.Priority, q.Origin, q.LastReplyId, q.Id, q.CreatedDate, q.CreatedById, q.CommunityId, q.Body, q.BestReplyId From Question q 
						where q.CommunityId =: CommunitySettings__c.getInstance().community_id__c
							order by q.LastReplyDate DESC limit 5];
	}







}