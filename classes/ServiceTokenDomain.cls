public class ServiceTokenDomain {
    
    private Account acct;
    public List<Service_Token__c> tokens;
    private String ServiceTokenDefinitionKey = 'ServiceTokenDefinitionKey';   
    
    
    public ServiceTokenDomain (Account a)
    {
        if (a == null)
        {
            throw new ApplicationException('Account is required.');
        }
        acct = a;
    } 
    
    public Map<String, service_token_definition__c> tokenDefMap
    {
        Get
        {
            System.debug('Begin: Get tokenDevMap.');
            LoadServiceTokenDefinition();
            return(Map<String, service_token_definition__c>) Cache.Org.get(ServiceTokenDefinitionKey);
        }
        
    }
    
    private void LoadServiceTokenDefinition()
    {
        system.debug('Begin: LoadServiceTokenDefinition()');
        Boolean cachedItemExist = Cache.Org.contains(ServiceTokenDefinitionKey);
        System.debug('cachedItemExist :' + cachedItemExist);
        
        Boolean cachedItemIsNull = Cache.Org.get(ServiceTokenDefinitionKey) == null;
        System.debug('cachedItemIsNull :' + cachedItemIsNull);
        
        if (!cachedItemExist || cachedItemIsNull) {
            System.debug('Loading Service Token Definition in the cache.');
            Map<string, service_token_definition__c> tdMap = new Map<string, service_token_definition__c>();
            for (service_token_definition__c td : [select id, name, part_number__c, service_token_count__c, support_Purchase_count__c, 
                                                   support_option__c from service_token_definition__c])
            {
                tdMap.put(td.part_number__c,td);
            }
            try {			
                Cache.Org.put(ServiceTokenDefinitionKey, tdMap);
                System.debug('ServiceTokenDefinition put in the cache.');
            }
            catch (Exception ex)
            {
                system.debug(ex);
            }
        }
    }
    
    
    
    public List<Service_Token__c> ServiceTokens 
    {
        get{
            if (tokens == null)
            {
                tokens = [select id, name, account__c, action__c, batch__c, contact__c, effective_date__c, expiration_date__c, quantity__c, reference_number__c 
                          from service_token__c where account__c =: acct.id order by batch__c, Quantity__c desc];
            }
            return tokens;
        }
    } 
    
    
    public static integer AvailableServiceTokens(ID AccountId)
    {
        system.debug('Begin static AvailableServiceTokens()');
        if (AccountId == null)
        {
            throw new ApplicationException('Invalid Account ID');
        }
        integer availableTokens=0;
        for (service_token__c t : [select id, name, action__c, batch__c, contact__c, effective_date__c, expiration_date__c, quantity__c, reference_number__c 
                                   from service_token__c where account__c =: AccountId])
        {
            if ((t.effective_date__c <= date.Today()) && (date.Today() <= t.expiration_date__c))
            {
                availableTokens = availableTokens + t.quantity__c.intValue();
            }            
        }
        return availableTokens;        
    }
    public static integer AvailableServiceTokens(Account acct)
    {
        if (acct == null)
        {
            throw new ApplicationException('Invalid Account');
        }
        Id AccountId = acct.Id;
        return AvailableServiceTokens(AccountId);
    }
    
    
    public void CreateServiceTokens(string PartNumber, integer OrderQuantity, date EffectiveStartDate)
    {    
        integer nextBatchNumber = 0;
        integer currBatchNumber = 0;
        AggregateResult[] results = [select account__c Id, max(batch__c) lastBatchId from service_token__c where account__c =: acct.Id group by account__c];
        if (results.size() > 0)
        {
            AggregateResult ar = results[0];
            currBatchNumber = ((decimal)ar.get('lastBatchId')).intValue();
        }
        nextBatchNumber = currBatchNumber + 1;
        service_token_definition__c def = tokenDefMap.get(PartNumber);
        
        Service_Token__c token = new Service_Token__c();    
        token.action__c = 'Token Purchase';
        token.Account__c = acct.Id;
        token.Description__c = partNumber;
        token.Effective_Date__c = EffectiveStartDate;
        token.Expiration_Date__c = date.today().addYears(1);
        
        // system.debug('---> ServiceTokenCount: ' + def.Service_Token_Count__c + '\n---> Zuora__Quantity__c: '+ qty );
        token.Quantity__c = (def.Service_Token_Count__c).intValue() * (OrderQuantity);                
        token.Batch__c = nextBatchNumber;
        system.debug('--> add token: ' + token);
        
        insert token;        
        ServiceTokens.add(token);
    }
    
    public void UseTokens(Integer Quantity, string ReferenceNumber)
    {
        system.debug('==> UseTokens: ' + Quantity + ' - ' + ReferenceNumber);
        integer i = AvailableServiceTokens;
        if (Quantity > i)
        {
            throw new ApplicationException('There are not enough service tokens to make this request.');
        }
        if (Quantity < 1)
        {
            return;
        }
        
        Map<integer,List<Service_Token__c>> sTMap = new Map<integer,List<Service_Token__c>> ();
        for (Service_Token__c t : tokens)
        {
            if ((t.effective_date__c <= date.Today()) && (date.Today() <= t.expiration_date__c))
            {
                
                if (sTMap.containsKey(t.Batch__c.intValue()))
                {
                    sTMap.get(t.Batch__c.intValue()).add(t);
                }
                else
                {
                    stMap.put(t.Batch__c.intValue(), new List<Service_Token__c>{t});
                }
            }
        }
        
        // loop thru the batches to see how much is available.
        system.debug('--> batchMap: ' + sTMap);
        List<Service_Token__c> tokensToAdd = new List<Service_Token__c>();
        integer StillNeeded = Quantity;
        integer Used = 0;
        List<Batch> batches = new List<Batch>();
        
        for (integer key : stMap.keySet())
        {
            Batch b;
            for (Service_Token__c t : stMap.get(key))
            {
                if (b == null)
                {
                    b = new Batch();
                    b.AccountId = t.Account__c;
                    b.BatchNumber = t.Batch__c.intValue();
                    b.EffectiveDate = t.effective_date__c;
                    b.ExpirationDate = t.expiration_date__c;                
                }
                b.AddQuantity(t.Quantity__c.intValue());
            }
            if (b.TotalAvailable <= StillNeeded)
            {
                Service_Token__c t = new Service_Token__c();
                t.Account__c = b.AccountId;
                t.Batch__c = b.BatchNumber;
                t.Quantity__c = (b.TotalAvailable * -1); 
                t.Action__c = 'Use Tokens';
                t.Effective_Date__c = b.EffectiveDate;
                t.Expiration_Date__c = b.ExpirationDate;
                t.reference_number__c = ReferenceNumber;    
                tokensToAdd.add(t);
                StillNeeded = StillNeeded - b.TotalAvailable;
                Used = Used + b.TotalAvailable; 
            }
            else
            {
                Service_Token__c t = new Service_Token__c();
                t.Account__c = b.AccountId;
                t.Batch__c = b.BatchNumber;
                t.Quantity__c = (StillNeeded * -1);
                t.Action__c = 'Use Tokens';
                t.Effective_Date__c = b.EffectiveDate;
                t.Expiration_Date__c = b.ExpirationDate;
                t.reference_number__c = ReferenceNumber;    
                tokensToAdd.add(t);
                StillNeeded = StillNeeded - StillNeeded;
                Used = Used + StillNeeded;             
            }    
        }
        system.debug('==> tokensToAdd: ' + tokensToAdd);
        if (tokensToAdd.size() > 0)
        {
            insert tokensToAdd;
            ServiceTokens.addAll(tokensToAdd);
        }        
        
    }
    
    public integer AvailableServiceTokens
    {
        get 
        {
            system.debug('Begin Get AvailableServiceTokens');
            integer availableTokens = 0;
            if (acct == null)
            {
                throw new ApplicationException('Must set the account first.');
            }
            for (service_token__c t : ServiceTokens)
            {
                if ((t.effective_date__c <= date.Today()) && (date.Today() <= t.expiration_date__c))
                {
                    availableTokens = availableTokens + t.quantity__c.intValue();
                }  
            }
            return availableTokens;
        }
        set;
    }
    
    
    class Batch
    {
        public String AccountId {get;set;}
        public Integer BatchNumber {get;set;}
        public Date EffectiveDate {get;set;}
        public Date ExpirationDate{get;set;}
        public Integer TotalAdditions {get;set;}
        public Integer TotalSubtractions {get;set;} 
        public Integer TotalAvailable
        {
            get {
                return TotalAdditions - TotalSubtractions;
            }
        }
        public Batch()
        {
            TotalAdditions = 0;
            TotalSubtractions = 0;
        }
        public void AddQuantity(integer Q)
        {
            if (Q > 0)
            {
                TotalAdditions = TotalAdditions + Q;
            }
            else
            {
                TotalSubtractions = TotalSubtractions + (Q * -1);
            }
        }
    }
    
}