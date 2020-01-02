@isTest
global class TestAccountContext {

    
    //private final String SOPPermissionSet = 'SOP';
    //private final string SalesPermissionSet = 'Inside_Sales';
    //private Map<String, Id> permissionSetMap;

    public User CANFCSUser
    {
        get;
        private set;
    }
    
    public User USUser
    {
        get;
        private set;
    }
        
    public User GMBHUser
    {
        get;
        private set;
    }
   
    public Account InternalProsAcct
    {
        get;
        private set;
    }
    
    public Account PartnerAcct1
    {
        get;
        private set;
    }

    public Account PartnerAcct2
    {
        get;
        private set;
    }
    
    public Account PartnerAcct3
    {
        get;
        private set;
    }
    
    public Account CustomerAcct1
    {
        get;
        private set;
    }

    public Account CustomerAcct2
    {
        get;
        private set;
    }
    
    public Account PureCloudAcct1
    {
        get;
        private set;
    }
        
    public Contact partContact1
    {
        get;
        private set;
    }
    
    public Contact partContact2
    {
        get;
        private set;
    }
    
    public Contact partContact3
    {
        get;
        private set;
    }
    
    public Contact partContact4
    {
        get;
        private set;
    }
    
    public Contact partContact5
    {
        get;
        private set;
    }
    
    public Contact purecloudContact1
    {
        get;
        private set;
    }
    
    public Account PartnerProsAcct1
    {
        get;
        private set;
    }
    
    public Account PartnerProsAcct2
    {
        get;
        private set;
    }

    /*public Addresses__c Address1
    {
        get;
        private set;
    } 
    
    public Addresses__c Address2
    {
        get;
        private set;
    }
    
    public Addresses__c Address3
    {
        get;
        private set;
    } 
    
    public Addresses__c Address4
    {
        get;
        private set;
    }
    
    public Addresses__c Address5
    {
        get;
        private set;
    }*/
   
    public UserRole fcsRole
    {
        get;
        private set;
    }
    
    /*public Map<string, Sales_Territory_List__c> territories
    {
        get;
        private set;
    }*/
    
    /*public Map<string, AX_Legal_Entity__c> entities
    {
        get;
        private set;
    }*/
    
    /*public Map<string, Country__c> countries
    {
        get;
        private set;
    }
    
    public Map<string, State__c> states
    {
        get;
        private set;
    }*/
    
    public TestAccountContext()
    {
        //LoadPermissionSets();
        
        List<UserRole> roles = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName IN ('WWWorldwideSalesDirector')];
        
        for(UserRole ur : roles)
        {
            if(ur.DeveloperName == 'WWWorldwideSalesDirector')
            {
                fcsRole = ur;
            }
        }    
        
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            List<General_Custom_Settings__c> settings = GeneralCustomSettingFactory.CreateDefaultCustomSettings();
            insert settings;
        
            CANFCSUser = UserFactory.CreateFCSUser('CANFCSUser');
            //CANFCSUser.Sales_Region__c = SalesTerrirotyListFactory.CreateCANTerritory().Name;
            CANFCSUSer.UserRoleId = fcsRole.Id;
            USUser = UserFactory.CreateInternalUser('USUser');
            //USUser.Sales_Region__c = SalesTerrirotyListFactory.CreateUSTerritory().Name;
            GMBHUser = UserFactory.CreateInternalUser('GMBHUser');
            //GMBHUser.Sales_Region__c = SalesTerrirotyListFactory.CreateGERTerritory().Name;
            insert new List<User> { CANFCSUser, USUser, GMBHUser };
                
            //PermissionSetAssignment psa1 = new PermissionSetAssignment();
            //psa1.AssigneeId = CANFCSUser.Id;
            //psa1.PermissionSetId = permissionSetMap.get(SOPPermissionSet);
            //insert psa1;                
        }
                
        //countries = StateFactory.Countries;

        /*entities = new Map<string, AX_Legal_Entity__c>();
        entities.put(AxLegalEntityFactory.CreateDefaultEntity().Name, AxLegalEntityFactory.CreateDefaultEntity(countries.get('USA')));        
        entities.put(AxLegalEntityFactory.CreateCANEntity().Name, AxLegalEntityFactory.CreateCANEntity(countries.get('CAN')));
        entities.put(AxLegalEntityFactory.CreateGEREntity().Name, AxLegalEntityFactory.CreateGEREntity(countries.get('DEU')));
        
        insert entities.values();*/
        
        /*territories = new Map<string, Sales_Territory_List__c>();
        Sales_Territory_List__c tempTerritory = new Sales_Territory_List__c();
        
        territories.put(SalesTerrirotyListFactory.CreateUSTerritory().Name, SalesTerrirotyListFactory.CreateUSTerritory());
        tempTerritory = territories.get(SalesTerrirotyListFactory.CreateUSTerritory().Name);
        tempTerritory.TM_SA_Manager__c = USUser.Id;
        tempTerritory.AX_Legal_Entity__c = entities.get(AxLegalEntityFactory.CreateDefaultEntity().Name).Id;
        
        territories.put(SalesTerrirotyListFactory.CreateCANTerritory().Name, SalesTerrirotyListFactory.CreateCANTerritory());
        tempTerritory = territories.get(SalesTerrirotyListFactory.CreateCANTerritory().Name);
        tempTerritory.TM_SA_Manager__c = CANFCSUser.Id;
        tempTerritory.AX_Legal_Entity__c = entities.get(AxLegalEntityFactory.CreateCANEntity().Name).Id;
        
        territories.put(SalesTerrirotyListFactory.CreateGERTerritory().Name, SalesTerrirotyListFactory.CreateGERTerritory());
        tempTerritory = territories.get(SalesTerrirotyListFactory.CreateGERTerritory().Name);
        tempTerritory.TM_SA_Manager__c = GMBHUser.Id;
        tempTerritory.AX_Legal_Entity__c = entities.get(AxLegalEntityFactory.CreateGEREntity().Name).Id;
        
        insert territories.values();*/
        
        // This account must exist due to a contact trigger performing a query on the record by name
        // ContactUtil class line 127
        Account holdingAccount = AccountFactory.CreateHoldingAccount();

        InternalProsAcct = AccountFactory.CreateProspectAccount('internalProsAcct');        
        InternalProsAcct.OwnerId = CANFCSUser.Id;        
        
        PartnerAcct1 = AccountFactory.CreatePartnerProspectAccount('partnerAcct1');
        PartnerAcct1.OwnerId = USUser.Id;        
        //PartnerAcct1.Ldap_Account_Permissions__c = 'GeneralAccess;AccountAccess';    
        PartnerAcct1.Approved_for_PureCloud_Billing__c = true;
        PartnerAcct2 = AccountFactory.CreatePartnerProspectAccount('partnerAcct2');
        PartnerAcct2.OwnerId = CANFCSUser.Id; 
        PartnerAcct2.Approved_for_PureCloud_Billing__c = true;
        PartnerAcct3 = AccountFactory.CreatePartnerProspectAccount('partnerAcct3');
        PartnerAcct3.OwnerId = USUser.Id;
        PartnerAcct3.Approved_for_PureCloud_Billing__c = true;
        PartnerAcct3.Ldap_Account_Permissions__c = 'GeneralAccess';
        
        
        CustomerAcct1 = AccountFactory.CreateProspectAccount('customerAcct1');
        CustomerAcct1.OwnerId = USUser.Id;        
        //CustomerAcct1.Ldap_Account_Permissions__c = 'GeneralAccess;AccountAccess';        
        CustomerAcct2 = AccountFactory.CreateProspectAccount('customerAcct2');
        CustomerAcct2.OwnerId = CANFCSUser.Id;  
        PureCloudAcct1 = AccountFactory.CreateProspectAccount('purecloudAcct1');
        PureCloudAcct1.OwnerId = USUser.Id;    

        PartnerProsAcct1 = AccountFactory.CreateProspectAccount('partnerProsAcct1');        
        PartnerProsAcct1.OwnerId = USUser.Id;
        PartnerProsAcct2 = AccountFactory.CreateProspectAccount('partnerProsAcct2');        
        PartnerProsAcct2.OwnerId = CANFCSUser.Id;    
        insert new List<Account> { holdingAccount, InternalProsAcct, PartnerAcct1, PartnerAcct2, PartnerAcct3, CustomerAcct1, CustomerAcct2, PureCloudAcct1, PartnerProsAcct1, PartnerProsAcct2 };
                        
        partContact1 = ContactFactory.CreateContact('partnerContact1');
        partContact1.AccountId = PartnerAcct1.Id;
        //partContact1.Ldap_Contact_Permissions__c = 'AccountBasic';
        partContact1.Contact_ID__c = 'TEST';
        partContact2 = ContactFactory.CreateContact('partnerContact2');
        partContact2.AccountId = PartnerAcct2.Id;
        partContact3 = ContactFactory.CreateContact('customerContact1');
        partContact3.AccountId = CustomerAcct1.Id;
        partContact4 = ContactFactory.CreateContact('customerContact2');
        partContact4.AccountId = CustomerAcct2.Id;
        partContact5 = ContactFactory.CreateContact('partnerContact3');
        partContact5.AccountId = PartnerAcct3.Id;
        partContact5.Ldap_Contact_Permissions__c = 'Support';
        
        purecloudContact1 = ContactFactory.CreateContact('purecloudContact1');
        purecloudContact1.AccountId = purecloudAcct1.Id;
        purecloudContact1.MailingCountry = 'United States'; //This is needed for Zquote that is used for ordering, a validation requires this to be set.
        insert new List<Contact> { partContact1, partContact2, partContact3, partContact4, partContact5, purecloudContact1 };
            
        //PartnerAcct1.Primary_Contact__c = partContact1.Id;
        //PartnerAcct2.Primary_Contact__c = partContact2.Id; 
        //CustomerAcct1.Primary_Contact__c = partContact3.Id; 
        //CustomerAcct2.Primary_Contact__c = partContact4.Id; 
        //purecloudAcct1.Primary_Contact__c = purecloudContact1.Id;
        
        //System.debug('## Countries added: ' + countries);
        //states = StateFactory.CreateStatesList();
        //System.debug('## States included: ' + states);
        
        //insert states.values();
        //System.debug('## States added: ' + states);
        /*Address1 = AddressFactory.CreateGeneralAddress('address');
        Address1.Account__c = PartnerAcct1.Id;
        if(countries.values() != null)
        {
            Address1.Country__c = countries.get('USA').Id;
        }
        if(states.values() != null)
        {
            Address1.State__c = states.get('IN').Id;
        }
        Address1.Billing_Contact__c = partContact1.Id;
        Address1.Shipping_Contact__c = partContact1.Id;
        Address2 = AddressFactory.CreateGeneralAddress('address');
        
        Address2.Account__c = PartnerAcct2.Id;        
        if(countries.values() != null)
        {
            Address2.Country__c = countries.get('USA').Id;
        }
        if(states.values() != null)
        {
            Address2.State__c = states.get('IN').Id;
        }
        Address2.Billing_Contact__c = partContact2.Id;
        Address2.Shipping_Contact__c = partContact2.Id;
        Address3 = AddressFactory.CreateGeneralAddress('address');
        Address3.Account__c = CustomerAcct1.Id;
        if(countries.values() != null)
        {
            Address3.Country__c = countries.get('USA').Id;
        }
        if(states.values() != null)
        {
            Address3.State__c = states.get('IN').Id;
        }
        Address3.Billing_Contact__c = partContact3.Id;
        Address3.Shipping_Contact__c = partContact3.Id;
        Address4 = AddressFactory.CreateGeneralAddress('address');
        Address4.Account__c = CustomerAcct2.Id;
        if(countries.values() != null)
        {
            Address4.Country__c = countries.get('USA').Id;
        }
        if(states.values() != null)
        {
            Address4.State__c = states.get('IN').Id;
        }
        Address4.Billing_Contact__c = partContact4.Id;
        Address4.Shipping_Contact__c = partContact4.Id;
        Address5 = AddressFactory.CreateGeneralAddress('address');
        Address5.Account__c = purecloudAcct1.Id;
        if(countries.values() != null)
        {
            Address5.Country__c = countries.get('USA').Id;
        }
        if(states.values() != null)
        {
            Address5.State__c = states.get('IN').Id;
        }
        Address5.Billing_Contact__c = purecloudContact1.Id;
        Address5.Shipping_Contact__c = purecloudContact1.Id;
        insert new List<Addresses__c> { Address1, Address2, Address3, Address4, Address5 };*/
            
        AccountFactory.SetRequiredPartnerFields(PartnerAcct1);        
        AccountFactory.SetRequiredPartnerFields(PartnerAcct2);  
        AccountFactory.SetRequiredPartnerFields(PartnerAcct3);
        AccountFactory.SetRequiredCustomerFields(CustomerAcct1); 
        AccountFactory.SetRequiredCustomerFields(CustomerAcct2);
        AccountFactory.SetRequiredPureCloudCustomerFields(purecloudAcct1);
        update new List<Account> { PartnerAcct1, PartnerAcct2, PartnerAcct3, CustomerAcct1, CustomerAcct2, purecloudAcct1 };
            
        System.debug('Total number of SOQL Queries in Context after all inserts: ' + Limits.getQueries());            
    }
    
    /*private void LoadPermissionSets()
    {
        permissionSetMap = new Map<String, Id>();
        for (PermissionSet ps : [SELECT Id, Name FROM PermissionSet where name IN (:SOPPermissionSet, :SalesPermissionSet)])
        {            
            permissionSetMap.put(ps.Name, ps.Id);
        }
        
    }*/
    
    /*public void AddChannelTypeRoleMappings()
    {
        List<ChannelType_Roles_Mappings__c> channelTypeRoleMaps = ChannelTypeRoleMappingsFactory.CreateMappings();
        insert channelTypeRoleMaps;
    }*/
    
    public void Refresh()
    {
        for (Account acc : [           
            SELECT Id, Type, Name, OwnerId, Account_Sub_Type__c, RecordTypeId, RecordType.DeveloperName, BillingStreet, BillingState, BillingCity,
            BillingCountry, BillingPostalCode, ShippingCity, ShippingCountry, ShippingState, ShippingStreet, ShippingPostalCode, 
            Account_Segmentation__c, DunsNumber
            FROM Account           
            WHERE Id IN (:InternalProsAcct.Id, :PartnerAcct1.Id, :PartnerAcct2.Id, :CustomerAcct1.Id, :CustomerAcct2.Id, :PartnerProsAcct1.Id, :purecloudAcct1.Id)])
        {
            if (acc.Id == PartnerAcct1.Id) 
            {
                PartnerAcct1 = acc; 
            }
            else if (acc.Id == PartnerAcct2.Id)
            {
                PartnerAcct2 = acc;
            }
            else if (acc.Id == CustomerAcct1.id)
            {
                CustomerAcct1 = acc;
            }
            else if (acc.Id == CustomerAcct2.id)
            {
                CustomerAcct2 = acc;
            }
            else if (acc.Id == InternalProsAcct.id)
            {
                InternalProsAcct = acc;
            }
            else if (acc.Id == PartnerProsAcct1.id)
            {
                PartnerProsAcct1 = acc;
            }
            else if (acc.Id == purecloudAcct1.id)
            {
                purecloudAcct1 = acc;
            }
        }
        
        System.debug('Total number of SOQL Queries in Context after refresh: ' + Limits.getQueries());
    }

    public static void addPartnerMargins(Id accountId)
    {
        PureCloud_Partner_Margin__c partnerMargin = new PureCloud_Partner_Margin__c
        (
            Account__c = accountId,
            Percent__c = 10,
            From_Date__c = Date.Today(),
            To_Date__c = Date.Today(),
            Margin_Type__c = 'PureCloud'
        );

        insert partnerMargin;
    }
}