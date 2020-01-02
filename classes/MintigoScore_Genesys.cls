public class MintigoScore_Genesys extends MintigoScore_AbstractBase {
        public static boolean is_running = false;    
        
        @future(callout=true)
        public static void enrichAccounts(Set<Id> ids) {
          if(Test.isRunningTest()) return;
          MintigoScore_Genesys myInstance = new MintigoScore_Genesys();
          is_running = true;

            System.debug('Inside enrichAccounts()');

            List<Account> accounts = new List<Account>();
            List<Account> updatedAccounts = new List<Account>();

            try {
                System.debug('Start');
                
                accounts = [Select Name, Website, Mintigo_Data_Enriched__c, Mintigo_Last_Enriched_Date__c, Mintigo_Do_Not_Enrich__c from Account where Id in :ids];

                for (Account o : accounts) {
                    System.debug('Account. ID=' + o.Id + ' Name=' + o.Name);
                    
                    System.debug(o);
                    Datetime today = system.now();
                    
                    // ignore account from enrichment if needed
                    if (o.Mintigo_Do_Not_Enrich__c) {
                        System.debug('This account should be ignored by enrichment');
                        continue;                        
                    }

                // refresh after 30 days
                    if (o.Mintigo_Last_Enriched_Date__c != NULL) {
                        integer intDays = o.Mintigo_Last_Enriched_Date__c.Date().daysBetween(today.Date());
                        if (intDays >= 90) {
                            System.debug('This account enriched more than 30 days ago, clear enrichment state and enrich again');
                            o.Mintigo_Data_Enriched__c = Boolean.valueOf('false');
                        }
                    }

                    if (o.Mintigo_Data_Enriched__c) {
                        System.debug('This account was already enriched by Mintigo');
                        continue;
                    }
                    
                    Map<String, Object> data = new Map<String, Object>{
                        'customer_company_name' => o.Name,
                        'url' => o.Website
                    };
                                
                    Dom.XMLNode root, root2, root3, root4;
                    // Change this to control the environment address and market UUID
                    try {
                        root = myInstance.getEnrichedData(data, 'api.mintigo.com', '449efc5130a542768c8e4828a85a3bb1',
                        true);   // MIs + scores
                        root2 = myInstance.getEnrichedData(data, 'api.mintigo.com', 'd1f85000b33f4c4998d355dec6a2a6e0',
                        true);   // scores
                        root3 = myInstance.getEnrichedData(data, 'api.mintigo.com', '9a516d01c9dd4833ad22da2e9507e16f',
                        true);   // scores
                        root4 = myInstance.getEnrichedData(data, 'api.mintigo.com', 'e8781b838b324ab7a12f7e8946e2f988',
                        true);   // scores
                    } catch (CalloutException e) {
                        System.debug(logginglevel.ERROR,'Error during callout. Possible timeout.');
                        continue;
                    } catch (XmlException e) {
                        System.debug(logginglevel.ERROR,'Error during callout. Got malformed XML.' + e.getMessage());
                        continue;
                    }
                    System.debug('Got data for account Name=' + o.Name);                   

                    // Change this to control enrichment fields from Mintigo to SFDC
                    o.MI_Annual_Revenue__c = (String)myInstance.getEnrichedValue(root, 'annual_revenue_category_new', String.class);
                    o.MI_Sub_Industry__c = (String)myInstance.getEnrichedValue(root, 'sub_industry_category_new', String.class);                
                    o.MI_Industry__c = (String)myInstance.getEnrichedValue(root, 'industry_category_new', String.class, true);
                    o.MI_Number_of_Employees__c = (String)myInstance.getEnrichedValue(root, 'number_of_employees_category_new', String.class);

                    o.Mintigo_Predict_Rank_ABM_Enterprise_ML__c = (String)myInstance.getEnrichedValue(root,'company_ad_rank', String.class);
                    o.Mintigo_Predict_Score_ABM_Enterprise_ML__c = (Integer)myInstance.getEnrichedValue(root,'account_score', Integer.class);

                    o.Mintigo_Predict_Rank_ABM_Commercial_MM__c = (String)myInstance.getEnrichedValue(root2,'company_ad_rank', String.class);
                    o.Mintigo_Predict_Score_ABM_Commercial_MM__c = (Integer)myInstance.getEnrichedValue(root2,'account_score', Integer.class);

                    o.Mintigo_Predict_Rank_ABM_Mid_Market_ML__c = (String)myInstance.getEnrichedValue(root3,'company_ad_rank', String.class);
                    o.Mintigo_Predict_Score_ABM_Mid_Market_ML__c = (Integer)myInstance.getEnrichedValue(root3,'account_score', Integer.class);

                    o.Mintigo_Predict_Rank_ABM_Velocity_MM__c = (String)myInstance.getEnrichedValue(root4,'company_ad_rank', String.class);
                    o.Mintigo_Predict_Score_ABM_Velocity_MM__c = (Integer)myInstance.getEnrichedValue(root4,'account_score', Integer.class);

                    String stringDate = (String)myInstance.getEnrichedValue(root, 'created_on', String.class);
                    o.Mintigo_Last_Enriched_Date__c = datetime.valueOf(stringDate);

                    o.Mintigo_Data_Enriched__c = Boolean.valueOf('true');
                    updatedAccounts.add(o);
                }
                System.debug('Updating all modified accounts');
                update(updatedAccounts);
            } catch(DMLException ex) {
                if(ex.getMessage().contains('UNABLE_TO_LOCK_ROW')) {
                    System.debug(logginglevel.ERROR,'Got exception UNABLE_TO_LOCK_ROW, detail:' + ex.getMessage());
                    System.debug(logginglevel.ERROR,'Problematic accounts: ' + updatedAccounts);
                }        
            } finally {
                is_running = false;
            }
            
            System.debug('Finished');
        }
        
    }