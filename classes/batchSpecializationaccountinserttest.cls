@isTest
public class batchSpecializationaccountinserttest {
 
    static testmethod void batchtest(){
        Test.startTest();   
      User currUser = [Select Id, Name, Bypass_Triggers__c from User where ID=:userinfo.getuserid()];
        currUser.Bypass_Triggers__c = true;
        update currUser;
        System.runAs(currUser){   
        country__c country = new country__C(Name='United States',
                                              RU__c = 'North America', 
                                              SubRegion__c = 'AMERICAS',
                                              SubRU__c='USA', 
                                              Region__c='North America',
                                              PSRDP_Region__c='NA',
                                              Country__c ='United States1',
                                              ISO_Code__c='911' , 
                                              LegacyId__c = 'test',
                                              Legacy_EMG_Id__c = 'test' );
        insert country;
        
        recordtype recTp = [Select Id,DeveloperName from recordtype where DeveloperName = 'EMGBusinessPartnerRecordType'];
    Global_Setting__c setting = new Global_Setting__c();
        setting.Name = 'United States';
        setting.ID__c = 'a24U00000004XlJ';
        setting.Type__c = 'Subsidary';
        setting.Information__c = '8100 United States';
        insert setting;
        
        
         account testaccount = new Account(Name='Test Account',Subsidary__c = setting.ID__c,status__c = 'Active',Country__c = country.id,Partner_Tier__c = 'gold',SMART_Qualified__c = true,Screening_Checklist_Completed__c=true, isDirect__c= true, PartnerType__c = 'VAR',recordtypeid=recTp.Id, Specialization__c = 'Speech Analytics' );
         insert testaccount;
        
        list<String> paccount = new list<string>();
        paccount.add(testaccount.Specialization__c);
        
        list<Account> acclst = [SELECT Id, Name, PartnerType__c, Specialization__c, Partner_Tier__c, Partner_Business_Size__c FROM Account where  RecordType__c = 'Enterprise - Business Partner' limit 100];
        
        batchSpecializationaccountinsert bsa = new batchSpecializationaccountinsert();
        Database.executeBatch(bsa);
         //bsa.start(bsa);
       
        }
    }
}