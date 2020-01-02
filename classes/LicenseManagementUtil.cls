public class LicenseManagementUtil {
    public static Set<String> partnerProfiles = new Set<String>{	
         															'Genesys Portal Partner',
        															'Genesys Portal Partner - PureConnect',
        															'Custom Gold Partner'
                                                                };
	public static Set<String> customerProfiles = new Set<String>{
                                                                    'Genesys Portal End User',
                                                                    'Genesys Portal Gold Partner'
    															};
    
    public static String convertListToSOQLString(List<String> strings){
        Set<String> uniqueStringSet = new Set<String>();
		uniqueStringSet.addAll(strings);        
        String soqlString = '' ;
        for(String s : uniqueStringSet)
            soqlString += '\'' + s + '\',';

        soqlString = soqlString.lastIndexOf(',') > 0 ? '(' + soqlString.substring(0,soqlString.lastIndexOf(',')) + ')' : soqlString ;
        return soqlString;
    }
    
    // -- Partner Access related Wrapper classes ...
    public static CurrentUserAccessProfile getUserAccessProfile(String userId){
    	CurrentUserAccessProfile userAccessProfile = new CurrentUserAccessProfile();
        userAccessProfile.userType = 'Unknown';
        
        User u = [SELECT id, ContactId, Contact.AccountId, Contact.Account.Name, ProfileId, Profile.Name FROM User WHERE Id = :userId];
        if(u.ContactId != NULL){
        	userAccessProfile.userAccountId = u.Contact.AccountId;
            userAccessProfile.userAccountName = u.Contact.Account.Name;
        	
            // Check for Customer Type Logged In
            if(customerProfiles.contains(u.Profile.Name)){
				List<Support_Access__c> supportAccessRequests = [SELECT id, Contact__c, Contact__r.AccountId, LMS_Access__c, SR_Access_Level__c,
																		Back_Office_Account__r.End_User_Account__c, Back_Office_Account__r.End_User_Account__r.Name, 
																		Back_Office_Account__r.Sold_To_Account__c, Back_Office_Account__r.Sold_To_Account__r.Name 
																FROM Support_Access__c
																WHERE 
																	Contact__c = :u.ContactId AND Status__c = 'Active' 	
																 	AND Back_Office_Account__r.Approval_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Contract_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Platform__c = 'PureConnect On Premise'
																 ORDER BY 
																 	Back_Office_Account__r.End_User_Account__r.Name, 
																 	Back_Office_Account__r.Sold_To_Account__r.Name];
				
				// Direct Customer - Access												 	
				if(supportAccessRequests.size() == 1 && supportAccessRequests[0].Back_Office_Account__r.End_User_Account__c == u.Contact.AccountId && supportAccessRequests[0]. Back_Office_Account__r.Sold_To_Account__c == u.Contact.AccountId){
            		userAccessProfile.userType = 'Direct Customer';	
					AccountIdName endUserAccount = new AccountIdName(supportAccessRequests[0].Back_Office_Account__r.End_User_Account__c, supportAccessRequests[0].Back_Office_Account__r.End_User_Account__r.Name);
					AccountIdName soldToAccount = new AccountIdName(supportAccessRequests[0].Back_Office_Account__r.Sold_To_Account__c, supportAccessRequests[0].Back_Office_Account__r.Sold_To_Account__r.Name);
					userAccessProfile.userAccounts.add(new EndUserSoldToCombination(endUserAccount, new List<AccountIdName>{soldToAccount}));
				} else if(supportAccessRequests.size() > 0){ // Indirect Customer - Access
            		userAccessProfile.userType = 'Indirect Customer';
					Map<Id, EndUserSoldToCombination> userAccounts = new Map<Id, EndUserSoldToCombination>();
					for(Support_Access__c sar : supportAccessRequests){
						AccountIdName endUserAccount = new AccountIdName(sar.Back_Office_Account__r.End_User_Account__c, sar.Back_Office_Account__r.End_User_Account__r.Name);
						AccountIdName soldToAccount = new AccountIdName(sar.Back_Office_Account__r.Sold_To_Account__c, sar.Back_Office_Account__r.Sold_To_Account__r.Name);
						if(userAccounts.containsKey(sar.Back_Office_Account__r.End_User_Account__c)){
							userAccounts.get(sar.Back_Office_Account__r.End_User_Account__c).soldToAccounts.add(soldToAccount);		
						} else {
							userAccounts.put(sar.Back_Office_Account__r.End_User_Account__c, new EndUserSoldToCombination(endUserAccount, new List<AccountIdName>{soldToAccount}));
						}
					}
					userAccessProfile.userAccounts = userAccounts.values();	
	        	} 
	        	
            }
            // Check for Partner Profiles
            if(partnerProfiles.contains(u.Profile.Name)){
        		userAccessProfile = new CurrentUserAccessProfile();
        		userAccessProfile.userType = 'Partner';
        		// Get all BOA Accounts for the Current User Account as Sold on BOA Accounts
        		List<Back_Office_Account__c> backOfficeAccounts = [SELECT id, End_User_Account__c, End_User_Account__r.Name, Sold_To_Account__c, Sold_To_Account__r.Name 
																FROM Back_Office_Account__c
																WHERE 
																	Sold_To_Account__c = :u.Contact.AccountId
																	AND Approval_Status__c = 'Active' 
																 	AND Contract_Status__c = 'Active' 
																 	AND Platform__c = 'PureConnect On Premise'];
																 	
				Map<Id, EndUserSoldToCombination> userAccounts = new Map<Id, EndUserSoldToCombination>();												
				for(Back_Office_Account__c boa : backOfficeAccounts){	
					AccountIdName endUserAccount = new AccountIdName(boa.End_User_Account__c, boa.End_User_Account__r.Name);
					AccountIdName soldToAccount = new AccountIdName(u.Contact.AccountId, u.Contact.Account.Name);
					if(userAccounts.containsKey(boa.End_User_Account__c)){
						userAccounts.get(boa.End_User_Account__c).soldToAccounts.add(soldToAccount);		
					} else {
						userAccounts.put(boa.End_User_Account__c, new EndUserSoldToCombination(endUserAccount, new List<AccountIdName>{soldToAccount}));
					}
				}
				
				// Check for any additional accounts from Support Access of the current user
				List<Support_Access__c> supportAccessRequests = [SELECT id, Contact__c, Contact__r.AccountId, LMS_Access__c, SR_Access_Level__c,
																		Back_Office_Account__r.End_User_Account__c, Back_Office_Account__r.End_User_Account__r.Name, 
																		Back_Office_Account__r.Sold_To_Account__c, Back_Office_Account__r.Sold_To_Account__r.Name 
																FROM Support_Access__c
																WHERE 
																	Contact__c = :u.ContactId AND Status__c = 'Active' 	
																 	AND Back_Office_Account__r.Approval_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Contract_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Platform__c = 'PureConnect On Premise'
																 ORDER BY 
																 	Back_Office_Account__r.End_User_Account__r.Name, 
																 	Back_Office_Account__r.Sold_To_Account__r.Name];	
				if(supportAccessRequests.size() > 0){ 
					for(Support_Access__c sar : supportAccessRequests){
						AccountIdName endUserAccount = new AccountIdName(sar.Back_Office_Account__r.End_User_Account__c, sar.Back_Office_Account__r.End_User_Account__r.Name);
						AccountIdName soldToAccount = new AccountIdName(sar.Back_Office_Account__r.Sold_To_Account__c, sar.Back_Office_Account__r.Sold_To_Account__r.Name);
						if(userAccounts.containsKey(sar.Back_Office_Account__r.End_User_Account__c)){
							Boolean soldToAlreadyExists = false;
							for(AccountIdName ain : userAccounts.get(sar.Back_Office_Account__r.End_User_Account__c).soldToAccounts){
								if(ain.accountId == soldToAccount.accountId){
									soldToAlreadyExists = true;	
								}	
							}
							if(!soldToAlreadyExists)
								userAccounts.get(sar.Back_Office_Account__r.End_User_Account__c).soldToAccounts.add(soldToAccount);		
						} else {
							userAccounts.put(sar.Back_Office_Account__r.End_User_Account__c, new EndUserSoldToCombination(endUserAccount, new List<AccountIdName>{soldToAccount}));
						}
					}
	        	}
	        	userAccessProfile.userAccounts = userAccounts.values(); 													 											
            }
        } else {
        	userAccessProfile.userType = 'Internal'; 
        }
        return userAccessProfile;
    }
    
    public class AccountIdName {
    	public String accountId {get; set;}
        public String accountName {get; set;}
        
        public AccountIdName(){
        	this.accountId = '';
        	this.accountName = '';	
        }
        public AccountIdName(String accountId, String accountName){
        	this.accountId = accountId;
        	this.accountName = accountName;	
        }
    }
    
    public class EndUserSoldToCombination {
    	public AccountIdName endUserAccount {get; set;}
    	public List<AccountIdName> soldToAccounts {get; set;}
    	
    	public EndUserSoldToCombination(){
    		this.endUserAccount = new AccountIdName();
    		this.soldToAccounts = new List<AccountIdName>();	
    	}
    	public EndUserSoldToCombination(AccountIdName endUser){
    		this.endUserAccount = endUser;
    		this.soldToAccounts = new List<AccountIdName>();
    	}
    	public EndUserSoldToCombination(AccountIdName endUser, List<AccountIdName> soldToAccounts){
    		this.endUserAccount = endUser;
    		this.soldToAccounts = soldToAccounts;
    	}
    }

    public class CurrentUserAccessProfile {
    	public String userType {get; set;}
    	public String userAccountId {get; set;}
    	public String userAccountName {get; set;}
    	public List<EndUserSoldToCombination> userAccounts {get; set;}
    	
    	public CurrentUserAccessProfile(){
    		this.userType = '';
    		this.userAccounts = new List<EndUserSoldToCombination>();	
    	}
    	public CurrentUserAccessProfile(String userType){
    		this.userType = userType;
    		this.userAccounts = new List<EndUserSoldToCombination>();
    	}
    	public CurrentUserAccessProfile(String userType, List<EndUserSoldToCombination> userAccounts){
    		this.userType = userType;
    		this.userAccounts = userAccounts;
    	}
    	
    	public List<String> getEndUserAccountIds(){
    		List<String> endUserAccountIds = new List<String>();
    		for(EndUserSoldToCombination eustc : userAccounts){
    			endUserAccountIds.add(eustc.endUserAccount.accountId);
    		}
    		return endUserAccountIds;
    	}
    	
    	public List<String> getSoldToAccountIds(String endUserId){
    		List<String> soldAccountIds	= new List<String>();
    		for(EndUserSoldToCombination eustc : userAccounts){
    			if(eustc.endUserAccount.accountId == endUserId){
    				for(AccountIdName ain : eustc.soldToAccounts){
    					soldAccountIds.add(ain.accountId);	
    				}
    			}
    		}
    		return soldAccountIds;
    	}
    }
    
    public static List<SelectOption> SortOptionList(List<SelectOption> ListToSort){
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
            
        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();
        integer pivot = ListToSort.size() / 2;
          
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        for(SelectOption x : ListToSort){
            if(x.getLabel() <= pivotValue.getLabel())
                Less.add(x);
            else if(x.getLabel() > pivotValue.getLabel()) Greater.add(x);   
        }
        List<SelectOption> returnList = new List<SelectOption> ();
        returnList.addAll(SortOptionList(Less));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(Greater));
        return returnList; 
    }  
    
    public static List<AccountIdName> SortAccountIdNames(List<AccountIdName> ListToSort){
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
            
        List<AccountIdName> Less = new List<AccountIdName>();
        List<AccountIdName> Greater = new List<AccountIdName>();
        integer pivot = ListToSort.size() / 2;
          
        // save the pivot and remove it from the list
        AccountIdName pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        for(AccountIdName x : ListToSort){
            if(x.accountName <= pivotValue.accountName)
                Less.add(x);
            else 
                if(x.accountName > pivotValue.accountName) 
                	Greater.add(x);   
        }
        List<AccountIdName> returnList = new List<AccountIdName>();
        returnList.addAll(SortAccountIdNames(Less));
        returnList.add(pivotValue);
        returnList.addAll(SortAccountIdNames(Greater));
        return returnList; 
    }
}