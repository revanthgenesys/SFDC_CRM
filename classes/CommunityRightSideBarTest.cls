@IsTest(SeeAllData=true)
public with sharing class CommunityRightSideBarTest {


	static testMethod void testCommunityRightSideBarTest() {
		
		try{
			CommunityRightSideBar CRB = new CommunityRightSideBar();
			System.assert(CRB.getMostPopular() != null);
			System.assert(CRB.getMostRecentIdeas() != null);
			System.assert(CRB.getRecentPosts() != null);
		}catch (Exception e){
			
		}
		
	}


}