@isTest(SeeAllData=true)
public class PartnerOpportunityHelper_Test {    
    static testMethod void tst() {     
        Test.startTest(); 
        Util.Bypass_Trigger_Chk = true;
        
        List<User> users = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND UserType ='PowerPartner' AND ContactId != NULL AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' LIMIT 2];
        List<String> contactIds = new List<String>();
        List<String> accountIds = new List<String>();
        for(User u : users){
            contactIds.add(u.ContactId);    
            accountIds.add(u.Contact.AccountId);
        }
        
        List<Opportunity> opportunities = [SELECT id, Name, BusinessPartner__c, OwnerId,Type FROM Opportunity WHERE BusinessPartner__c != NULL AND BusinessPartner__c IN :accountIds AND Owner.isActive = true LIMIT 10]; 
        //Priyank added below code to increase the test coverage.
        List<Account> accounts = TestUtil.createAccounts(1, true);
        Opportunity opportunities1 = new Opportunity();
        opportunities1.Name = 'Test Opp';
        opportunities1.accountid = accounts[0].Id;
        opportunities1.BusinessPartner__c = accounts[0].Id;
        opportunities1.closeDate = Date.today().addMonths(1);
        opportunities1.Direct_Indirect_Sale__c = 'Indirect';
        opportunities1.StageName = '1.Recognize Needs';
        opportunities1.CurrencyIsoCode = 'USD';
        insert opportunities1;
        //priyank code ends.
        Set<String> businessPartners = new Set<String>();
        for(Opportunity o : opportunities){
            businessPartners.add(o.BusinessPartner__c); 
        }
        system.runAs(users[0]){
       // try{
            PartnerOpportunityHelper.populatePartnerOpportunityOnInsert(new List<Opportunity>{opportunities1});
     //   }
     //   catch(exception e){}
        Test.stopTest(); }
    }
    
    
    /*
    * Added By: Ashish Goyal (08/16/2018)
    * Desc: To manage the Opportunity Team Member whenever Solt To/Business Partner is populated/updated on the Opportunity
    * Requested By: Debbie
    */
    static testMethod void testOpportunityTeamMember() {     
        Test.startTest(); 
        List<Opportunity> opportunities = [SELECT id, Name, BusinessPartner__c FROM Opportunity WHERE BusinessPartner__c = NULL LIMIT 1];
        opportunities.addAll([SELECT id, Name, BusinessPartner__c FROM Opportunity WHERE BusinessPartner__c != NULL LIMIT 2]);
        List<Contact> list_Cont = [SELECT AccountId, Account.Name FROM Contact WHERE Designated_Partner_Contact__c = true limit 2];
        opportunities.get(0).BusinessPartner__c = list_Cont.get(0).AccountId;
        opportunities.get(1).BusinessPartner__c = list_Cont.get(1).AccountId;
        opportunities.get(2).BusinessPartner__c = null;
        opportunities.get(0).Direct_Indirect_Sale__c = 'Direct';
        opportunities.get(1).Direct_Indirect_Sale__c = 'Direct';
        opportunities.get(2).Direct_Indirect_Sale__c = 'Direct';
        update opportunities;
        Test.stopTest(); 
    }
}