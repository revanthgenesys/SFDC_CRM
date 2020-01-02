@isTest
public class PartnerPortalTabsControllerTest {

    @isTest
    public static void test1(){
		Profile profileId = [SELECT Id FROM Profile WHERE Name = :Label.Potential_Partner_User_Profile_Name LIMIT 1];
        
       
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
       
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
      
     	User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdf.com.123',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US',
                            contactId=con.Id
                           );
        insert usr;
      System.runAs(usr) {
		
        PartnerPortalTabsController pp=new PartnerPortalTabsController();
         System.assertequals(pp.isPotentialPartner,True) ;
      }
        
    }
}