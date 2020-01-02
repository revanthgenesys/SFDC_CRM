/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
@isTest
public without sharing class TestServicesReadyContactsContext{

    public static string internalUserProfile = 'GEN - Professional Services'; //'ININ Standard User'; 
    
    public static User PartnerOwner
    {
        get
        {
            if (PartnerOwner == null)
            {
                Profile p1 = [SELECT Id FROM Profile WHERE Name = :internalUserProfile];
                
                // Owner must have a user role set
                UserRole r1 = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
                
                PartnerOwner = new User(
                    Alias = 'partOwn',
                    Email='partOwn@inin.com',
                    LastName='PartnerOwner',
                    ProfileId = p1.Id,
                    UserName='partOwn@inin.com',
                    UserRoleId = r1.Id,
                    EmailEncodingKey='UTF-8',
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    TimeZoneSidKey='America/Los_Angeles');
                    
                insert PartnerOwner;
                
            }
            
            return PartnerOwner;
        }
        set;
    }    
     
    public static void createLoginQueueEntry(Contact PortalUserContact)
    {
       CreateLoginQueue__c createLoginQueueEntry;
       if (createLoginQueueEntry == null)
       {
           System.runAs(new User(Id = UserInfo.getUserId()))
           {
               createLoginQueueEntry = new CreateLoginQueue__c(
                   ContactId__c = PortalUserContact.Id
               ); 
               insert createLoginQueueEntry;
           }
       }        
    }
    
    public static ServicesReadyContactPermission__c contactPermissionEntry
    {
        get
        {   
            if (contactPermissionEntry == null)
            {
                System.runAs(new User(Id = UserInfo.getUserId()))
                {
                    contactPermissionEntry = new ServicesReadyContactPermission__c(
                        Name = 'IProject',
                        Account_Permission__c = 'SupportAccess'
                    ); 
                    insert contactPermissionEntry;
                }
            }
            
            return contactPermissionEntry;
        }
        set;
    }
}