/**
  * Apex Class: TestDataFactory2
  * Description: Utility class for test data
  * Created By: Navaneetha Krishnan 
  * Created Date: 10-JAN-2018
*/
@isTest(seeAllData = false)
public class TestDataFactory2{
    
    Public static List<Opportunity> createOpportunity(String recTypeName, integer numOpty){

        List<Opportunity> optyList = new List<Opportunity>();
        Id rtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        
        for(integer i=0;i<numOpty;i++){
            Opportunity opty = new Opportunity(Name = 'Test Opty '+i,stageName = '1.Understand Needs',
                                                CloseDate= date.valueof(System.today()),recordtypeid=rtId);
            optyList.add(opty);
        }
        return optyList;
    }
    
   public static User createUser(){
   Profile p = [Select id from Profile where name = 'Customer Care Data Admin'];
   String randomNumber = String.valueof(math.random()).substring(3,6);
   String sTimeStamp = String.valueOf(system.now());
        DateTime myDateTime = DateTime.now();
        string millisec = String.valueOf(myDateTime.millisecond());
        sTimeStamp = sTimeStamp.replaceAll( '\\s+', '');
        sTimeStamp = sTimeStamp.replaceAll( '-', '');
        sTimeStamp = sTimeStamp.replaceAll( ':', '');
       return new User(Alias='SamUsr',Email='sampleuser'+randomNumber+millisec+'@example.com',EmailEncodingKey='UTF-8',LastName='sampleUser'+sTimeStamp+millisec,LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',ProfileId=P.Id,TimeZoneSidKey='America/Los_Angeles',UserName='SampleUser'+sTimeStamp+millisec+'@example.com',Country='Canada');
   }
    
    //*** Method to create accounts //
    public static List<Account> createAccounts(Integer intNumOfAccts) {
        List<Account> list_NewAccts = new List<Account>();
        for(Integer i=0; i<intNumOfAccts; i++) {
            Account a = new Account(Name='TestAccount' + i,
            Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id,
            Screening_Checklist_Completed__c=true);
            list_NewAccts.add(a);
        }
        insert list_NewAccts;
        return list_NewAccts;
    } 
    
    //*** Method to create contacts //
    public static List<Contact> createContacts(Id acctId, Integer intNumOfConts) {   
        List<Contact> list_NewConts = new List<Contact>();
        for(Integer i=0; i<intNumOfConts; i++) {
            list_NewConts.add(new Contact(LastName=' Contact ' + i,                                   
                                          AccountId=acctId));
        }
        // Insert all contacts for accounts.
        insert list_NewConts;         
        return list_NewConts;
    }
    
    //*** Method to create opportunities //
    public static List<Opportunity> createOpportunties(Id acctId, Integer intNumOfOpps) {   
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        for(Integer i=0; i<intNumOfOpps; i++) {
            list_NewOpps.add(new Opportunity(Name=' Opportunity ' + i,
                                   StageName='1.Recognize Needs',
                                   CurrencyIsoCode = 'USD',
                                   Sold_To_Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id,
                                  // Sold_To_Country__c = list_NewAccts.country__C,
                                   Direct_Sales__c = true,
                                   CloseDate=System.today().addMonths(1),
                                   AccountId=acctId));
        }
        // Insert all opportunities for all accounts.
        insert list_NewOpps;         
        return list_NewOpps;
    }
    
    Public static List<Deal_Qualification__c> createDealQualification(string optyId,integer numDQ){

        List<Deal_Qualification__c> dqList = new List<Deal_Qualification__c>();
        for(integer i=0;i<numDQ;i++){
            Deal_Qualification__c dq = new Deal_Qualification__c(Opportunity__c=optyId, Pricing_Type__c='Old Pricing',
                                        Platform_Type__c='Cloud', Offering_Type__c='Premier Edition',Type__c='History',Status__c='Revision Pending');
            dqList.add(dq);
        }
        return dqList;
    }
    
}