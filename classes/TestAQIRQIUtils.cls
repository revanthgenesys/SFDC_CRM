@IsTest
public class TestAQIRQIUtils {

	 public static final String TEST_COACH_LOGIN = 'sctest123coach@genesyslab.com';
	public static final String TEST_AGENT_LOGIN = 'sctest123agent@genesyslab.com';
	public static final String TEST_AGENT_NAME = 'agent123coach';
	public static final String TEST_Coach_NAME = 'coach123coach';
    
    public static User createTestAgent(String coachId) {
		List<User> uList = (List<User>) [SELECT Id FROM User WHERE Username =: TEST_AGENT_LOGIN LIMIT 1];
		User agent;
		if (uList != null && !uList.isEmpty()) {
			agent = uList[0];
		} else {
			List<Profile> profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
			//TODO: Time zone picklist,LanguageLocaleKey, Email encoding key, LocaleSidKey
			//fetch possible values and then set it				
			agent = new User(FirstName = TEST_AGENT_NAME, LastName = TEST_AGENT_NAME, Username = TEST_AGENT_LOGIN, Email = TEST_AGENT_LOGIN, 
				Alias = 'agent', CommunityNickname=TEST_AGENT_LOGIN, TimeZoneSidKey = 'America/Los_Angeles', ProfileId = profile[0].Id,
				EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US');
			insert agent;
		}
		return agent;
	}	

}