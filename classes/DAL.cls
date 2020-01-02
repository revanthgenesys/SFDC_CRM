global class DAL {

	public static string getGroupByName (string queueName){
		List<Group> listgroups = [ select id, name from Group where name =: queueName];
		return (listgroups.size()>0)? listgroups[0].id : null;
	}
	
	public static set<string> getGroupMembers(string queueGroupId){
		set<string> userIds = new set<string>();
		List<GroupMember> listgroupMembers = [ select id, UserOrGroupId, groupId from GroupMember where groupId =: queueGroupId];
		if(listgroupMembers.size() > 0){
			for(GroupMember gm : listgroupMembers){
				userIds.add(gm.UserOrGroupId);
			}
		}
		return (userIds.size()>0)? userIds : null;
	}
	
	public static list<string> getMailUsersByIds (set<string> userIds){
		List<User> users = [select id, name, email from user where id in: userIds];
		List<string> mails = new List<string>();
		if(users.size() > 0){
			for(User u : users){
				mails.add(u.email);
			}
		}
		return (mails.size()>0)? mails : null;
	}
	
	static  testMethod void testDAL()
	{	
		DAL.getGroupByName('queueName');
		DAL.getGroupMembers('groupId');
		DAL.getMailUsersByIds(new Set<String>{'1878787873'});
	}
}