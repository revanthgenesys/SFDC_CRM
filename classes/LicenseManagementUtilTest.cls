@isTest(seeAllData=true)
public class LicenseManagementUtilTest {
    @isTest
    static void testLicenseManagementUtil1(){
    	Test.startTest();
    	String soqlString = LicenseManagementUtil.convertListToSOQLString(new List<String>{'Name', 'ContactId', 'Contract.FirstName', 'Contract.LastName'});
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('SUN', 'SUN'));
    	options.add(new SelectOption('MON', 'MON'));
    	options.add(new SelectOption('TUE', 'TUE'));
    	options.add(new SelectOption('WED', 'WED'));
    	options.add(new SelectOption('THU', 'THU'));
    	options.add(new SelectOption('FRI', 'FRI'));
    	options.add(new SelectOption('SAT', 'SAT'));
    	List<SelectOption> ortionsSorted = LicenseManagementUtil.SortOptionList(options);
    	
    	List<LicenseManagementUtil.AccountIdName> accountIdNamesList = new List<LicenseManagementUtil.AccountIdName>();
    	accountIdNamesList.add(new LicenseManagementUtil.AccountIdName('SUN', 'SUN'));
    	accountIdNamesList.add(new LicenseManagementUtil.AccountIdName('MON', 'MON'));
    	accountIdNamesList.add(new LicenseManagementUtil.AccountIdName('TUE', 'TUE'));
    	accountIdNamesList.add(new LicenseManagementUtil.AccountIdName('WED', 'WED'));
    	accountIdNamesList.add(new LicenseManagementUtil.AccountIdName('THU', 'THU'));
    	accountIdNamesList.add(new LicenseManagementUtil.AccountIdName('FRI', 'FRI'));
    	accountIdNamesList.add(new LicenseManagementUtil.AccountIdName('SAT', 'SAT'));
    	LicenseManagementUtil.AccountIdName ain = new LicenseManagementUtil.AccountIdName();
    	ain.accountId = 'Test';
    	ain.accountName = 'Test';
    	accountIdNamesList.add(ain);
    	List<LicenseManagementUtil.AccountIdName> accountIdNamesListSorted = LicenseManagementUtil.SortAccountIdNames(accountIdNamesList);
    	Test.stopTest();
    }
    
    @isTest
    static void testLicenseManagementUtil2(){
    	
    	List<Support_Access__c> supportAccessCustomer = [SELECT id, Name, Contact__c, End_User_Account__c FROM Support_Access__c WHERE 
    																End_User_Account__r.ININ_ID__c != NULL
    																AND End_User_Account__r.Type = 'Customer'
    																AND Back_Office_Account__r.Approval_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Contract_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Platform__c = 'PureConnect On Premise' LIMIT 2];
																 	
    	List<Support_Access__c> supportAccessPartner = [SELECT id, Name, Contact__c, End_User_Account__c FROM Support_Access__c WHERE 
    																End_User_Account__r.ININ_ID__c != NULL
    																AND End_User_Account__r.Type = 'Partner'
    																AND Back_Office_Account__r.Approval_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Contract_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Platform__c = 'PureConnect On Premise' LIMIT 2];
		Test.startTest();
		
		if(supportAccessCustomer.size() > 0 ){
			User u1 = [SELECT id FROM User WHERE ContactId = :supportAccessCustomer[0].Contact__c];
			User u2 = [SELECT id FROM User WHERE ContactId = :supportAccessCustomer[1].Contact__c];
	    	LicenseManagementUtil.CurrentUserAccessProfile u1UserAccessProfile = LicenseManagementUtil.getUserAccessProfile(u1.id);
	    	List<String> u1EndUserAccounts = u1UserAccessProfile.getEndUserAccountIds();
			List<String> u1SoldToAccounts = u1UserAccessProfile.getSoldToAccountIds(u1EndUserAccounts[0]);
	    	LicenseManagementUtil.CurrentUserAccessProfile u2UserAccessProfile = LicenseManagementUtil.getUserAccessProfile(u2.id);
	    	List<String> u2EndUserAccounts = u2UserAccessProfile.getEndUserAccountIds();
			List<String> u2SoldToAccounts = u2UserAccessProfile.getSoldToAccountIds(u2EndUserAccounts[0]);
		}

		if(supportAccessPartner.size() > 0 ){
			User u1 = [SELECT id FROM User WHERE ContactId = :supportAccessPartner[0].Contact__c];
			User u2 = [SELECT id FROM User WHERE ContactId = :supportAccessPartner[1].Contact__c];
	    	LicenseManagementUtil.CurrentUserAccessProfile u1UserAccessProfile = LicenseManagementUtil.getUserAccessProfile(u1.id);
	    	List<String> u1EndUserAccounts = u1UserAccessProfile.getEndUserAccountIds();
			List<String> u1SoldToAccounts = u1UserAccessProfile.getSoldToAccountIds(u1EndUserAccounts[0]);
	    	LicenseManagementUtil.CurrentUserAccessProfile u2UserAccessProfile = LicenseManagementUtil.getUserAccessProfile(u2.id);
	    	List<String> u2EndUserAccounts = u2UserAccessProfile.getEndUserAccountIds();
			List<String> u2SoldToAccounts = u2UserAccessProfile.getSoldToAccountIds(u2EndUserAccounts[0]);
		}

		LicenseManagementUtil.EndUserSoldToCombination eustCombination = new LicenseManagementUtil.EndUserSoldToCombination();
		eustCombination = new LicenseManagementUtil.EndUserSoldToCombination(new LicenseManagementUtil.AccountIdName());

		LicenseManagementUtil.CurrentUserAccessProfile currentUserAccessProfile = new LicenseManagementUtil.CurrentUserAccessProfile('Direct Customer');
		currentUserAccessProfile = new LicenseManagementUtil.CurrentUserAccessProfile('Direct Customer', new List<LicenseManagementUtil.EndUserSoldToCombination>{eustCombination});

		Test.stopTest();
    }
}