@isTest(seeAllData=true)
private class HomeControllerTest{

    static Config__c configData(String name,String value){
        
        Config__c config = new Config__c();
        config.Name = name;
        config.Value__c = value;
        return config;
    }
    
    static testmethod void TestHomeController(){
       
        Test.startTest();
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1]; 
        
        Account acc1 = new Account (Name = 'Holding Account');  
        insert acc1;
        
        Contact contt = new Contact (AccountId = acc1.id,LastName = 'portalTestUser');
        insert contt;
        
        System.assertEquals('portalTestUser', contt.LastName);
        
        
        User usrManager = new User(profileId = partnerProfile.id,username = 'newUser211@salesforce.com',email = 'pb211@ff.com',
                                    emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                    timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',contactId = contt.id);
        insert usrManager; 
    
        Contact contact = new Contact (AccountId = acc1.id,LastName = 'portalTestUser');
        insert contact; 
        
        User usrChannelManager = new User(profileId = partnerProfile.id,username = 'newUser11@salesforce.com',email = 'pb11@ff.com',
                                    emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US', 
                                    timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',contactId = contact.id,
                                    ManagerId=usrManager.Id);
        insert usrChannelManager; 
        
        acc1.Channel_Manager__c = usrChannelManager.Id;
        update acc1;

        Contact cont = new Contact (AccountId = acc1.id,LastName = 'portalTestUser');
        insert cont;

        User newUser = new User(profileId = partnerProfile.id,username = 'newUser@salesforce.com',email = 'pb@ff.com',
                                    emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US', 
                                    timezonesidkey = 'America/Los_Angeles',  alias='nuser',lastname='lastname',contactId = cont.id,
                                    UserPermissionsSFContentUser=true);
        insert newUser; 
        
        PortalHomeDefaults__c pHomeDefaults =  PortalHomeDefaults__c.getInstance(UserInfo.getOrganizationId());
        pHomeDefaults.ContentListSize__c = 10;
        upsert pHomeDefaults;
        
        List<ContentVersion> contentList = new List<ContentVersion>();
        ContentVersion content = new ContentVersion(Title='Test Content',Description='',ContentModifiedDate=Date.today(),
                                                        ContentUrl='https://genesys--sbgenfull.cs21.my.salesforce.com');
        contentList.add(content);
        insert contentList;
        
        List<ContentVersion> whatsNewList = new List<ContentVersion>();
        
        for (ContentVersion cv : contentList) {  
            whatsNewList.add(cv);
         }
        
        
        List<Favorite_Content__c> favoriteContentList = new List<Favorite_Content__c>();  
        Favorite_Content__c favoriteContent = new Favorite_Content__c(Content_Version_Id__c=content.Id,User_Id__c=newUser.Id,
                                                                        RatingCount__c='Positive Rating Count');
        favoriteContentList.add(favoriteContent);
        insert favoriteContentList;
   
        System.runAs(newUser){

        User usr1 = [SELECT Name FROM User WHERE Id =: acc1.Channel_Manager__c];            
         HomeController controller = new HomeController();

        }

        Test.stopTest();
    }
    
}