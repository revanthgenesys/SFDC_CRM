@isTest
public class UserFactory {
    
    private static final String internalUserProfile = 'GEN - Sales Ops';
    private static final String fcsUserProfile = 'GEN - Finance';
    private static final String portalUserProfile = 'Genesys Portal Partner User';
    private static final String internalAdminUserProfile = 'System Administrator';
    private static final Map<String, Id> profileMap;
    private static final Id RoleId;    
    private static final Id RevRecRoleId;
    
    public static User CreateInternalUser(string name)
    {
        User u = CreateUser(name, profileMap.get(internalUserProfile));
        u.UserRoleId = RoleId;

        return u;
    }
    
    public static User CreateSysAdminUser(string name)
    {
        return CreateUser(name,profileMap.get(internalAdminUserProfile));
    }
    
    public static User CreatePartnerUser(string name)
    {
        return CreateUser(name, profileMap.get(portalUserProfile));
    }

    //AHaun: removing for Demo Request install
    //public static User CreateRevRecUser (string name)    
    //{
    //    User u = CreateUser(Name,profileMap.get(internalUserProfile));        
    //    u.UserRoleId = RevRecRoleId;                
    //    return u;                
    //}
    public static User CreateFCSUser(string name)
    {
        user u = CreateUser(name, profileMap.get(fcsUserProfile));
        return u;
    }
    
    public static User CreateUser(string name, Id profileId)
    {
        String alias = name;
        if (name.length() > 8)
        {
            alias = name.left(8);
        }
        Long rnd =  Math.roundToLong(Math.random() * 1000);        
        return new User(
            Alias = alias,
            Email = name + '@genesys.com.test',
            LastName = 'TestUser',
            ProfileId = profileId,
            UserName = name + '_' + rnd + '@genesys.com.test',    
            CommunityNickname = name + '_' + rnd + '.TestUser',           
            EmailEncodingKey ='UTF-8',
            LanguageLocaleKey ='en_US',
            LocaleSidKey ='en_US',
            Organization__c = 'IT',
            TimeZoneSidKey ='America/New_York');
    }
    
    static
    {
        profileMap = new Map<String, Id>();
        for (Profile p : [SELECT Id, Name FROM Profile WHERE Name IN (:internalUserProfile, :portalUserProfile, :fcsUserProfile, :internalAdminUserProfile)])
        {
            profileMap.put(p.Name, p.Id);
        }
 
        //UserRole rr = [SELECT Id FROM UserRole WHERE Name = 'Revenue Recognition' LIMIT 1];
        //RevRecRoleId = rr.Id;
        
        UserRole r1 = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        RoleId = r1.Id;
    }
}