public class TestCommon {
	public static User createUser(String alias, String userName, String lastName, String firstName, Id ProfileId){
		return createUser(alias, userName, lastName, firstName, profileId, true);
	}
	//create User
	public static User createUser(String alias, String userName, String lastName, String firstName, Id ProfileId, Boolean doInsert) 
	{
		System.Debug('### Start createUser');
	
	  	User u=new User();
	  	if(userName == null)
	  		u.Username = 'test654'+ Math.random().format()+'@genesys.com';
	  	else{
	  		userName = userName.split('@')[0] + '@genesys.com';
			u.Username= userName;
	  	}
		u.LastName= lastName;
		u.FirstName= firstName;		
		u.Email= u.Username; 
		u.Alias= alias;
		u.CommunityNickname= u.Username.substring(0, u.Username .indexOf('@'));
		u.TimeZoneSidKey='Europe/Paris';  
		u.LocaleSidKey='fr_FR_EURO';
		u.EmailEncodingKey='ISO-8859-1';
		if(ProfileId == null)
	    	u.ProfileId=Config.PROFIL_ADMIN_ID;  
	    else
	    	u.ProfileId = ProfileId;
	    System.Debug('ProfileId:'+ProfileId);
		u.LanguageLocaleKey='fr';
		u.isActive=true;
		u.ByPassValidationRules__c = true;
		u.EmployeeNumber = 'EMP-'+ Math.random().format();
		//u.BypassTrigger__c = 'TR018 Account';
		System.Debug('user:'+u);
		if(doInsert)
			insert u;
		return u;       
	}
	
	
	
	//create Account
	public static Account createAccount(boolean isInsert) 
	{
		    System.Debug('createAccount');
		    Account a = new Account(Name ='myCompany');
		    if(isInsert)
			{
				insert a;
				System.Debug('createAccount Id created:'+a.Id);
			}
		    System.Debug('Owner Id:'+a.OwnerId);
		    return a;
	}
	
	//create Account Business Partner
	public static Account createAccountBP(boolean isInsert) 
	{
		    System.Debug('createAccount');
		    Account a = new Account(Name ='myCompany', AccountShortName__c='myC');
		    a.RecordTypeId = Config.EMG_BUSINESS_PARTNER_RECORDTYPE;
		    if(isInsert)
			{
				insert a;
				System.Debug('createAccount Id created:'+a.Id);
			}
		    System.Debug('Owner Id:'+a.OwnerId);
		    return a;
	}
	
	//create Contact
	public static Contact createContact(Id accountId) 
	{
		    System.Debug('Create Account');
		    Contact c = new Contact(LastName = 'contactLastName',AccountId = accountId, email = 'olivier.contact@alcatel.com', FirstName = 'test@test.com');
		    insert c;
		     System.Debug('Contact Id created:'+c.Id);
		    return c;
	}
	
	//create Opportunity
	public static Opportunity createOpportunity(Id accountId) 
	{
	    System.Debug('createOpportunity');
	    Opportunity o = new Opportunity(Name='myOppty', StageName = 'Open', CloseDate = Date.today(),AccountId = accountId);
	    insert o;
	    System.Debug('Opportunity Id created:'+o.Id);
	    return o;
	}
	
	//create Product
	public static Product2 createProduct(String Nom,String CodeProduit, boolean Active) 
	{
		System.Debug('createProduct');
		Product2 produit = new Product2 (Name = Nom, ProductCode = CodeProduit,IsActive = Active);
		//Product2 produit = new Product2 (Name = Nom, ProductCode = CodeProduit,IsActive = true);
		insert produit;
		System.Debug('produit Id created:'+produit.Id);
		return produit;
	} 
	
	//create PricebookEntry
	public static PricebookEntry createPricebookEntry(Product2 p) 
	{
		sObject s = [select ID from Pricebook2 where IsStandard = TRUE];
		System.Debug('createPricebookEntry');
		PricebookEntry Pbe = new PricebookEntry (Pricebook2Id = s.Id, Product2Id = p.Id, IsActive = true, UnitPrice = 10.0,UseStandardPrice = false);
		insert Pbe;
		System.Debug('createPricebookEntry Id created:'+Pbe.Id);
		return Pbe;
	}
	
////////////////////////////////////////////////////////////////////
///////////////                     TEST                ////////////
////////////////////////////////////////////////////////////////////
	
	static testMethod void TestCommonMethods() {
		User use = createUser('testmlg', 'Mmichael.legrand@emg.alcatel-lucent.com.emgdev', 'MyTestLastName','MyTestFirstName',Config.PROFIL_ADMIN_ID);
		
		Account myAccount = createAccount(true);
	
		Account myAccountBP = createAccountBP(true);
		
		Contact myContactTest = createContact(myAccount.id);
		
		Product2 p = createProduct('AAA', 'CodeProduit',true);
		
		PricebookEntry pe = createPricebookEntry(p);
	}
}