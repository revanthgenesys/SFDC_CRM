public without sharing class zSubscrProductChargeManagement {
    private Map<Id, Zuora__SubscriptionProductCharge__c> subscrProdChargesMap;    
    private Zuora__Subscription__c oldSubscr, currSubscrProdCharge;    
    private String ServiceTokenDefinitionKey = 'ServiceTokenDefinitionKey';   
    
    private Map<string,string> PurecloudSupportOptions
    {
        get
        {
            if (PurecloudSupportOptions == null)
            {
                PurecloudSupportOptions = new Map<String,String>();
                PurecloudSupportOptions.put('PS-170-PURE-SVBRONZE','Bronze Support');
                PurecloudSupportOptions.put('PS-170-PURE-SVBRONZEAN','Bronze Support');
                PurecloudSupportOptions.put('PS-170-PURE-SVSILVER','Silver Support');
                PurecloudSupportOptions.put('PS-170-PURE-SVSILVERAN','Silver Support');
                PurecloudSupportOptions.put('PS-170-PURE-GOLD','Gold Support');
                PurecloudSupportOptions.put('PS-170-PURE-GOLDAN','Gold Support');
                PurecloudSupportOptions.put('PS-170-PURE-PLATINUM','Platinum Support');
                PurecloudSupportOptions.put('PS-170-PURE-PLATINUMAN','Platinum Support');
            }
            return PurecloudSupportOptions;
            }
        set;
    }
    
    public zSubscrProductChargeManagement(Map<Id, Zuora__SubscriptionProductCharge__c> subscrProdChargesMap)
    {
        this.subscrProdChargesMap = subscrProdChargesMap;        
    }
    
    public static Void AfterInsert(Map<Id, Zuora__SubscriptionProductCharge__c> subscrProdChargesMap)
    {
       zSubscrProductChargeManagement qManagement = new zSubscrProductChargeManagement(subscrProdChargesMap);
       //qManagement.UpdatePureCloudProductFieldonAccount();
       qManagement.CreateServiceTokens();
       qManagement.UpdateAccountFields(); 
    }

    public static void AttachToProductRatePlanCharge( List<Zuora__SubscriptionProductCharge__c> subscrProdCharges )
    {
        system.debug('Begin AttachToProductRatePlanCharge()');
        system.debug('---> charges: ' + subscrProdCharges);
        set<string> zuoraIds = new set<string>();
        List<Zuora__SubscriptionProductCharge__c> udpatedCharges = new List<Zuora__SubscriptionProductCharge__c>();
        Map<string,id> idMap = new Map<string,id>();

        for (Zuora__SubscriptionProductCharge__c charge : subscrProdCharges)
        {
            zuoraIds.add(charge.Zuora__OriginalProductRatePlanChargeId__c);
        }

        for (zqu__ProductRatePlanCharge__c c : [select id, name, zqu__zuoraId__c from zqu__ProductRatePlanCharge__c where zqu__zuoraId__c in :zuoraIds ])
        {
            idMap.put(c.zqu__zuoraId__c, c.id);
        }

        for (Zuora__SubscriptionProductCharge__c charge : subscrProdCharges)
        {
            if (idMap.containsKey(charge.Zuora__OriginalProductRatePlanChargeId__c))
            {
                charge.Product_Rate_Plan_Charge__c = idMap.get(charge.Zuora__OriginalProductRatePlanChargeId__c);
            }
        }        
    }
    
    
    public static Void SetProductCategories(List<Zuora__SubscriptionProductCharge__c> subscrProdCharges)
    {
        system.debug('Begin SetProductCategories()');
        system.debug('---> charges: ' + subscrProdCharges);

        set<string> skus = new set<string>();
        map<string,string> categoryMap = new map<string,string>();
        map<string,string> subcategoryMap = new map<string,string>();

        for (Zuora__SubscriptionProductCharge__c charge : subscrProdCharges)
        {
            skus.add(charge.Zuora__ProductSKU_Product__c);
        }
        for (Product2 product :  [select id, name, zqu__sku2__c,  product_category__c , product_subcategory__c from Product2 where zqu__sku2__c in : skus])
        {
            categoryMap.put(product.zqu__SKU2__c,product.product_category__c);
            subcategoryMap.put(product.zqu__SKU2__c,product.product_subcategory__c);
        }        

        for (Zuora__SubscriptionProductCharge__c charge : subscrProdCharges)
        {
            charge.product_category__c = categoryMap.get(charge.Zuora__ProductSKU_Product__c);
            charge.product_subcategory__c = subcategoryMap.get(charge.Zuora__ProductSKU_Product__c);
        }
    
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
            for (service_token_definition__c td : [select id, name, part_number__c, service_token_count__c, Service_Token_Expire_Days__c,
                                                    support_Purchase_count__c, Support_Purchase_Expire_Days__c,
                                                    support_option__c from service_token_definition__c])
            {
                tdMap.put(td.part_number__c,td);
            }
            
            Cache.Org.put(ServiceTokenDefinitionKey, tdMap);
            System.debug('ServiceTokenDefinition put in the cache.');
        }
    }

    private void CreateServiceTokens()
    {
        system.debug('ENTER CreateServiceTokens()');
        map<id, List<Service_Token__c>> existingTokens = new map<id, List<Service_Token__c>>();
        map<id,List<support_purchase__c>> existingEPS =  new map<id, List<support_purchase__c>>();
        Set<Id> accts = new Set<Id>();
        for(Zuora__SubscriptionProductCharge__c c : subscrProdChargesMap.values())
        {
            accts.add(c.zuora__Account__c);
        }
        system.debug('--> accounts: ' + accts);

        for (support_purchase__c eps : [select id, name, account__c, effective_date__c, Description__c from support_purchase__c where account__c in : accts])
        {
            if (existingEPS.ContainsKey(eps.Account__c))
            {
                List<Support_Purchase__c> s1 = existingEPS.get(eps.Account__c);
                s1.add(eps);
            }
            else
            {
                List<Support_Purchase__c> s1 = new List<Support_Purchase__c>();
                s1.add(eps);
                existingEPS.put(eps.account__c,s1);
            }
        }

        for (Service_Token__c token : [select id, name, batch__c, account__c, effective_date__c, description__c, expiration_date__c, quantity__c
            from service_token__c where account__c in : accts order by batch__c])
        {
            if (existingTokens.containsKey(token.account__c))
            {
                List<service_token__c> tl = existingTokens.get(token.account__c);
                tl.add(token);
            }
            else
            {
                List<service_token__c> tl = new List<service_token__c>();
                tl.add(token);
                existingTokens.put(token.account__c,tl);
            }
        }

        map<id,integer> acctBatchMap = new map<id,integer>();
        AggregateResult[] results = [select account__c Id, max(batch__c) lastBatchId from service_token__c where account__c in : accts group by account__c];
        for (AggregateResult ar : results)
        {
            if(ar.get('id') != null && ar.get('lastBatchId') != null)
            {
                acctBatchMap.put((String)ar.get('id'), ((decimal)ar.get('lastBatchId')).intValue());
            }            
        }
        system.debug('--> acctBatchMap: ' + acctBatchMap);
        List<Service_Token__c> tokensToAdd = new List<Service_Token__c>();
        List<support_purchase__c> epsToAdd = new List<support_purchase__c>();
        // This map should be in the system cache
        //system.debug('--> tokenDefMap: ' + tokenDefMap);

        for(Zuora__SubscriptionProductCharge__c c : subscrProdChargesMap.values())
        {
            system.debug('--> Zuora__SubscriptionProductCharge__c: ' + c);
            if (tokenDefMap.containsKey(c.Zuora__ProductSKU_Product__c))
            {
                // system.debug('--->  ProductSKU: ' + c.Zuora__ProductSKU_Product__c);
                service_token_definition__c def = tokenDefMap.get(c.Zuora__ProductSKU_Product__c);
                //system.debug('def: ' + def);
                // System.debug('--> Create new support purchase record. ');
                boolean createNewEPS = true;
                if (existingEPS.containsKey(c.zuora__Account__c))
                {
                    for (support_purchase__c p : existingEPS.get(c.zuora__Account__c))
                    {
                        if ((p.Effective_Date__c == c.Zuora__EffectiveStartDate__c) 
                            && String.isNotEmpty(p.Description__c)
                            && (p.Description__c.contains(c.Zuora__ProductSKU_Product__c)))
                        {
                            createNewEPS = false;
                        }
                    }
                }
                if (createNewEPS)
                {
                    Support_Purchase__c sp = new Support_Purchase__c();
                    sp.Account__c = c.zuora__Account__c;
                    sp.Order__c = null;
                    sp.Action__c = 'Support Purchase';
                    integer qty = (c.Zuora__Quantity__c).intValue();                
                    sp.Quantity__c = (def.support_Purchase_count__c).intValue() * (qty);
                    sp.Description__c = 'Purchased as a part of: ' + c.Zuora__ProductSKU_Product__c + ' on subscription: ' + c.zuora__Subscription__c;
                    sp.Effective_Date__c = c.Zuora__EffectiveStartDate__c;
                    sp.Expiration_Date__c = c.Zuora__EffectiveStartDate__c.addDays(Integer.ValueOf(def.Support_Purchase_Expire_Days__c));
                    epsToAdd.add(sp);
                }

               // system.debug('---> def: ' + def);
               boolean createNewToken = true;
               if (existingTokens.ContainsKey(c.zuora__Account__c))
               {                   
                   for (service_token__c t : existingTokens.get(c.zuora__Account__c))
                   {
                        if ((t.Effective_Date__c == c.Zuora__EffectiveStartDate__c) && (t.Description__c.contains(c.Zuora__ProductSKU_Product__c)))
                        {
                            createNewToken = false;
                        }
                   }
               }
               if (createNewToken)
               {
                    Service_Token__c token = new Service_Token__c();
                    token.action__c = 'Token Purchase';
                    token.Account__c = c.zuora__Account__c;
                    //token.Description__c = c.Zuora__ProductSKU_Product__c;
                    token.Description__c = 'Purchased as a part of: ' + c.Zuora__ProductSKU_Product__c + ' on subscription: ' + c.zuora__Subscription__c;
                    token.Effective_Date__c = c.Zuora__EffectiveStartDate__c;
                    token.Expiration_Date__c = c.Zuora__EffectiveStartDate__c.addDays(Integer.ValueOf(def.Service_Token_Expire_Days__c));
                    integer qty = (c.Zuora__Quantity__c).intValue();

                    //system.debug('---> ServiceTokenCount: ' + def.Service_Token_Count__c + '\n---> Zuora__Quantity__c: '+ qty );
                    token.Quantity__c = (def.Service_Token_Count__c).intValue() * (qty);                
                    if (acctBatchMap.containsKey(c.zuora__Account__c))
                    {                    
                        integer i = acctBatchMap.get(c.zuora__Account__c);
                    //    system.debug('--> getBatch: ' + i);
                        i++;
                        token.Batch__c = i;
                    }
                    else
                    {
                    //  system.debug('--> no Batches');
                        token.Batch__c = 1;
                    }
                    //system.debug('--> add token: ' + token);
                    tokensToAdd.add(token);                
               }
            }
        }

        if (tokensToAdd.size() > 0)
        {
            system.debug('---> insert tokens');
            upsert tokensToAdd;
        }
        if (epsToAdd.size() > 0)
        {
            system.debug('---> insert support purchases');
            insert epsToAdd;
        }
    }

    private void UpdateAccountFields()
    {
    system.debug('--> Enter UpdateAccountFields()');
    // update fields on the account:
    //  1. account.PureCloud_Products__c
    //  2. account.SupportOption__c
    //  3. account.Exclude_from_New_Logo_Count__c 

        Map<string,integer> tokenRank = new Map<String,integer>();
        tokenRank.put('Bronze Support',1);
        tokenRank.put('Silver Support',2);
        tokenRank.put('Gold Support',3);
        tokenRank.put('Platinum Support',4);

        List<Account> accountsToUpdate = new List<Account>();
        Set<id> accountIds = new Set<id>();
        Set<String> existingPCProducts = new Set<String>();
        List<String> productSubCategories = new List<String>();

        Map<id, List<Zuora__SubscriptionProductCharge__c>> acctCharges = new Map<id, List<Zuora__SubscriptionProductCharge__c>>();
        Map<id, List<Zuora__SubscriptionProductCharge__c>> acctCurrentCharges = new Map<id, List<Zuora__SubscriptionProductCharge__c>>();
        
        // get all of the account id's
        for ( Zuora__SubscriptionProductCharge__c charge  : subscrProdChargesMap.values())
        {
            accountIds.add(charge.zuora__Account__c);
        }

        // create a map of all the charges for the account (including those not on this subscription)    
        Map<ID, Account> accountMap = new Map<ID, Account> ([select id, name, Support_Option__c, PureCloud_Products__c from account where id in: accountIds]);
        for (Zuora__SubscriptionProductCharge__c charge : [select id, name, Is_Service_Token_Part__c, zuora__ProductSku__c, zuora__Account__c,
                        zuora__Subscription__r.zuora__Status__c, Zuora__Type__c, product_subcategory__c 
                        from Zuora__SubscriptionProductCharge__c where zuora__Account__c in : accountIds and zuora__Subscription__r.zuora__Status__c = 'Active' ] )
        {
            if (acctCharges.containsKey(charge.zuora__Account__c))
            {
                List<Zuora__SubscriptionProductCharge__c> charges = acctCharges.get(charge.zuora__Account__c);
                charges.add(charge);
            }
            else
            {
                List<Zuora__SubscriptionProductCharge__c> charges = new List<Zuora__SubscriptionProductCharge__c>();
                charges.add(charge);
                acctCharges.put(charge.zuora__Account__c, charges);
            }
        }

        // So now we have a list of AccountId's, a Map of accounts that may need to be updated, and a map of charges, by account

        for (id AcctId : accountMap.keySet())
        {
            Account acct = accountMap.get(AcctId);
            system.debug('---> Account: ' + acct.Id + ': ' + acct.Name);
            system.debug('-----> support option: ' + acct.support_option__c);
            boolean updAccount = false;
            string SupportOption = acct.Support_Option__c;
            List<Zuora__SubscriptionProductCharge__c> charges = acctCharges.get(AcctId);
            if (charges != null)
            {
                for (Zuora__SubscriptionProductCharge__c charge : charges)
                {
                    system.debug('----> charge SKU: ' + charge.zuora__ProductSku__c );
                    system.debug('-----> type: ' + charge.zuora__Type__c);
                    system.debug('-----> isServiceTokenPart: ' + charge.is_Service_Token_Part__c);
                    system.debug('-----> subcategory: ' + charge.product_subcategory__c);
                    // Exclude from New Logo Count?  --> The PureCloudPromo part number is on an active subscription for this account
                    /* Not migrating from ININ
                    if(charge.Product_Subcategory__c == 'Promo Partner' 
                        && !acct.Exclude_from_New_Logo_Count__c)
                    {
                        acct.Exclude_from_New_Logo_Count__c = true;
                        acct.New_Logo_Exclusion_End_Date__c = Date.today().addDays(180);
                        updAccount = true;
                    }*/

                    // figure out the support option
                    if (charge.is_Service_Token_Part__c == true)
                    {
                        system.debug('----> charge isServiceTokenPart: ' + charge.is_Service_Token_Part__c);
                        // what type of support should they get with that?
                        string supportType =PurecloudSupportOptions.get(charge.zuora__ProductSku__c); 
                        if (String.IsBlank(SupportOption) || tokenRank.get(supportType) > tokenRank.get(supportOption))
                        {
                            SupportOption = supportType;
                        }
                        system.debug('----> supportOption: ' + SupportOption);
                    }
                    // figure out the PureCloud products

                    if (charge.zuora__Type__c == 'Usage')
                    {
                        existingPCProducts.add(charge.product_subcategory__c);
                    }
                }                
            }
            // finished looping thru all of the active subscription charges for this account
            if ((acct.Support_Option__c != supportOption) && (String.isNotBlank(supportOption)))
            {
                updAccount = true;
                acct.Support_Option__c = supportOption;
            }

            string PCProducts;
            if (existingPCProducts.size() > 0)
            {
                PCProducts = String.join(new List<string>(existingPCProducts), ';');   
            }            
            else
            {
                PCProducts = '';                
            }
            system.debug ( '----> PC Products: ' + PCProducts );

            if (PCProducts != acct.PureCloud_Products__c)
            {
                acct.PureCloud_Products__c = PCProducts;
                updAccount = true;
            }


            if (updAccount == true)
            {
                accountsToUpdate.add(acct);                
            }
        }

        if(accountsToUpdate.size() > 0)
        {
            update accountsToUpdate;
        }

    }

}