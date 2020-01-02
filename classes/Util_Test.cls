@isTest
private class Util_Test {
    @isTest(seeAllData=true)
    static void test1(){
    	
    	// Test for Util.getPriceFieldName
    	String fieldName = '';
    	fieldName = Util.getPriceFieldName('USD');
    	fieldName = Util.getPriceFieldName('AUD');
    	fieldName = Util.getPriceFieldName('BRL');
    	fieldName = Util.getPriceFieldName('CAD');
    	fieldName = Util.getPriceFieldName('EUR');
    	fieldName = Util.getPriceFieldName('GBP');
    	fieldName = Util.getPriceFieldName('JPY');
    	fieldName = Util.getPriceFieldName('NZD');
    	fieldName = Util.getPriceFieldName('ZAR');
    	
    	// Test for Util.ESDOpptyRecordTypeId
    	Set<Id> esdOppRTs = Util.ESDOpptyRecordTypeId();
    	
    	// Test for Util.canTrigger
    	Boolean canTrigger = Util.canTrigger('Util');
    	// Test for Util.getRtypeId
    	String oppGenesysRenewalRT = Util.getRtypeId('Genesys Renewal');
    	// Test for Util.getProfileId
    	String sysAdminProfileId = Util.getProfileId('System Administrator'); 
    	
    	Opportunity[] opportunities = [SELECT id, Name, StageName, AccountId, Account.Name, OwnerId, Owner.Name FROM Opportunity LIMIT 3];
    	
    	Map<Id,User> mapIdUsers = Util.getUserPRMinTriggerContext(opportunities, opportunities);
    	Set<Id> setIds = Util.getIds(opportunities);
    	Set<Id> setOwnerIds = Util.getOwnerIds(opportunities);
    	Set<String> setFromFields = Util.getSetFromFieldName(opportunities, 'Name');
    	Map<String,String> mapKeyValues = Util.mapBuildFromList(opportunities, 'Name', 'StageName');
    	String idForDynamicSOQL = Util.getListIdForDynamicSoql(new Set<String>{opportunities[0].id, opportunities[1].id, opportunities[2].id});
    	OpportunityShare oppShareRecord1 = Util.manualShareOppEdit(opportunities[0].id, UserInfo.getUserId());
    	OpportunityShare oppShareRecord2 = Util.manualShareOppEdit(opportunities[1].id, UserInfo.getUserId());
    	Util.insertOppShare(new List<OpportunityShare>{oppShareRecord1, oppShareRecord2});
    	Util.insertOppShare(new List<OpportunityShare>{oppShareRecord1, oppShareRecord2});
    	
    	List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
    	for(Opportunity o : opportunities){
    		otmList.add(new OpportunityTeamMember(OpportunityId = o.Id,   UserId = UserInfo.getUserId(), TeamMemberRole = 'Account Manager'));
    	}
    	
    	Util.insertOppTMember(otmList);
    	Set<Id> setAccountIdsFromOpps = Util.getAccountIds(opportunities);
    	Map<Id,Account> mapAccounts = Util.getAccountMapFromOpportunities(setAccountIdsFromOpps);
    	List<AccountShare> accountShareList = new List<AccountShare>();
    	for(String s: setAccountIdsFromOpps){
    		accountShareList.add(Util.manualShareAcc(null, s, UserInfo.getUserId(), 'Edit', 'Edit', 'Edit', 'Edit'));
    	}
    	Util.insertAccShare(accountShareList);
		
		List<AccountTeamMember> atmList = new List<AccountTeamMember>();
    	for(String s: setAccountIdsFromOpps){
    		atmList.add(new AccountTeamMember(AccountId= s, UserId = UserInfo.getUserId(), TeamMemberRole = 'Account Manager'));
    	}
    	Util.insertAccTMember(atmList);
    	
    	List<AccountShare> asRecords = Util.getLstAccShareToUpdate(setAccountIdsFromOpps, new Set<Id>{UserInfo.getUserId()}, 'Edit', 'Edit');
    	Map<Id, AccountTeamMember> atmListToDelete = Util.getUserPRMtoDeleteFromAccountTeam(opportunities);
    	
    	List<string> emailAddresses = new List<string>();
       	emailAddresses.add('Prabhuram.Doraiswamy@genesys.com');
       	emailAddresses.add('narasimha@dasincusa.com');
    	Util.sendEmail(emailAddresses, 'Sample Body of the Email');
    	Util.EmailNotification('Sample Body of the Email', 'Sample Email Subject', emailAddresses);
    	String idsForSOQL = Util.getSoqlListIdFromSet( new Set<Id>{opportunities[0].id, opportunities[1].id, opportunities[2].id} );
    	Util.Wrappers wrapperObject = new Util.Wrappers(opportunities[0]);
    	Decimal monthBetween1 = Util.calculateDurationInMonths(Date.newInstance(2017,6,1), Date.newInstance(2017,6,15));
    	Decimal monthBetween2 = Util.calculateDurationInMonths(Date.newInstance(2017,6,1), Date.newInstance(2017,12,15));

		Map<String,Decimal> map_ConversionRates = new Map<String,Decimal>();
		for(CurrencyType curr: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
        	map_ConversionRates.put(curr.IsoCode,curr.ConversionRate);
		}         
 		Decimal amount1 = Util.convertCurrencyCustom('CAD', 'EUR', map_ConversionRates, null);
 		Decimal amount2 = Util.convertCurrencyCustom('CAD', 'EUR', map_ConversionRates, 1000);
 		
 		List<BigMachines__Quote__c> quotes = [SELECT Id, Name, Maintenance_Start_Date__c, Maintenance_End_Date__c, CurrencyISOCode FROM BigMachines__Quote__c LIMIT 2];
		List<BigMachines__Quote_Product__c> quoteProducts = Util.createQPFromOnPremiseToRenewal(quotes[0].id, quotes[1]);
		
		List<Account> accounts = new List<Account>();
        for( Integer i=0; i < 10; i++ ) {
            Account a = new Account( Name='Test Account', Status__c = 'Active' );            
            accounts.add( a );
        }
    	Util.dataBaseActionLstSobjects(accounts, 'Insert', new List<ErrorLogItem>(), new Map<String,Integer>(), new Map<String,Integer>());
    	Util.dataBaseActionLstSobjects(accounts, 'Update', new List<ErrorLogItem>(), new Map<String,Integer>(), new Map<String,Integer>());
    	Util.dataBaseActionLstSobjects(accounts, 'Delete', new List<ErrorLogItem>(), new Map<String,Integer>(), new Map<String,Integer>());
    }
}