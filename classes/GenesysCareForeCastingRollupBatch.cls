/*
 * Class            : GenesysCareForeCastingRollupBatch
 * Description      : This Batch Class consolidates all the data for UI.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Dec 19, 2016
 * Test Class       : GenesysCareForecastingBatchesTest 
 *---------------------------------------------------------------------------------
 * History
 *---------------------------------------------------------------------------------
 * Harish, 03/09/2017 - added renew sub category under CONSTANTS.GCF_REVENUETYPE_BS, CONSTANTS.GCF_REVENUETYPE_DR, CONSTANTS.GCF_REVENUETYPE_RR2.
 */
global class GenesysCareForeCastingRollupBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc){
        // Actual Query Locator 
        String query = 'SELECT Id, Unique_Id__c, Year__c,  Month__c, Quarter__c, '
                        + ' APAC_Billing_Schedule__c, APAC_Deferred_Revenue__c, APAC_Incremental_Revenue__c, APAC_Revenue_Recognition__c, APAC_First_Year_Maintenance__c,'
                        + ' EMEA_Billing_Schedule__c, EMEA_Deferred_Revenue__c, EMEA_Incremental_Revenue__c, EMEA_Revenue_Recognition__c, EMEA_First_Year_Maintenance__c,'
                        + ' Latin_America_Billing_Schedule__c, Latin_America_Deferred_Revenue__c, Latin_America_Incremental_Revenue__c, Latin_America_Revenue_Recognition__c, Latin_America_First_Year_Maintenance__c,'
                        + ' North_America_Billing_Schedule__c, North_America_Deferred_Revenue__c, North_America_Incremental_Revenue__c, North_America_Revenue_Recognition__c, North_America_First_Year_Maintenance__c,'
                        + ' APAC_Billing_Schedule_EUR__c, APAC_Deferred_Revenue_EUR__c, APAC_Incremental_Revenue_EUR__c, APAC_Revenue_Recognition_EUR__c, APAC_First_Year_Maintenance_EUR__c,'
                        + ' EMEA_Billing_Schedule_EUR__c, EMEA_Deferred_Revenue_EUR__c, EMEA_Incremental_Revenue_EUR__c, EMEA_Revenue_Recognition_EUR__c, EMEA_First_Year_Maintenance_EUR__c,'
                        + ' Latin_America_Billing_Schedule_EUR__c, Latin_America_Deferred_Revenue_EUR__c, Latin_America_Incremental_Revenue_EUR__c, Latin_America_Revenue_Recognition_EUR__c, Latin_America_First_Year_Maintenance_EUR__c,'
                        + ' North_America_Billing_Schedule_EUR__c, North_America_Deferred_Revenue_EUR__c, North_America_Incremental_Revenue_EUR__c, North_America_Revenue_Recognition_EUR__c, North_America_First_Year_Maintenance_EUR__c,'
                        + ' APAC_Billing_Schedule_FYM__c, APAC_Deferred_Revenue_FYM__c, APAC_Revenue_Recognition_FYM__c, APAC_Incremental_Revenue_E__c, APAC_First_Year_Maint_E__c, '
                        + ' EMEA_Billing_Schedule_FYM__c, EMEA_Deferred_Revenue_FYM__c, EMEA_Revenue_Recognition_FYM__c, EMEA_Incremental_Revenue_E__c, EMEA_First_Year_Maint_E__c, '
                        + ' Latin_America_Billing_Schedule_FYM__c, Latin_America_Deferred_Revenue_FYM__c, Latin_America_Revenue_Recognition_FYM__c, Latin_America_Incremental_Revenue_E__c, Latin_America_First_Year_Maint_E__c, '
                        + ' North_America_Billing_Schedule_FYM__c, North_America_Deferred_Revenue_FYM__c, North_America_Revenue_Recognition_FYM__c, North_America_Incremental_Revenue_E__c, North_America_First_Year_Maint_E__c, '
                        + ' APAC_Billing_Schedule_FYM_EUR__c, APAC_Deferred_Revenue_FYM_EUR__c, APAC_Revenue_Recognition_FYM_EUR__c, APAC_Incremental_Revenue_E_EUR__c, APAC_First_Year_Maint_E_EUR__c, '
                        + ' EMEA_Billing_Schedule_FYM_EUR__c, EMEA_Deferred_Revenue_FYM_EUR__c, EMEA_Revenue_Recognition_FYM_EUR__c, EMEA_Incremental_Revenue_E_EUR__c, EMEA_First_Year_Maint_E_EUR__c, '
                        + ' Latin_America_Billing_Schedule_FYM_EUR__c, Latin_America_Deferred_Revenue_FYM_EUR__c, Latin_America_Revenue_Recognition_F_EUR__c, Latin_America_Incremental_Revenue_E_EUR__c, Latin_America_First_Year_Maint_E_EUR__c, '
                        + ' North_America_Billing_Schedule_FYM_EUR__c, North_America_Deferred_Revenue_FYM_EUR__c, North_America_Revenue_Recognition_F_EUR__c, North_America_Incremental_Revenue_E_EUR__c, North_America_First_Year_Maint_E_EUR__c, '
                        + ' APAC_Billing_Schedule_Renew__c, APAC_Deferred_Revenue_Renew__c, APAC_Revenue_Recognition_Renew__c, APAC_Incremental_Revenue_U__c, APAC_First_Year_Maint_U__c, '
                        + ' EMEA_Billing_Schedule_Renew__c, EMEA_Deferred_Revenue_Renew__c, EMEA_Revenue_Recognition_Renew__c, EMEA_Incremental_Revenue_U__c, EMEA_First_Year_Maint_U__c, '
                        + ' Latin_America_Billing_Schedule_Renew__c, Latin_America_Deferred_Revenue_Renew__c, Latin_America_Revenue_Recognition_Renew__c, Latin_America_Incremental_Revenue_U__c, Latin_America_First_Year_Maint_U__c, '
                        + ' North_America_Billing_Schedule_Renew__c, North_America_Deferred_Revenue_Renew__c, North_America_Revenue_Recognition_Renew__c, North_America_Incremental_Revenue_U__c, North_America_First_Year_Maint_U__c, '
                        + ' APAC_Billing_Schedule_Renew_EUR__c, APAC_Deferred_Revenue_Renew_EUR__c, APAC_Revenue_Recognition_Renew_EUR__c, APAC_Incremental_Revenue_U_EUR__c, APAC_First_Year_Maint_U_EUR__c, '
                        + ' EMEA_Billing_Schedule_Renew_EUR__c, EMEA_Deferred_Revenue_Renew_EUR__c, EMEA_Revenue_Recognition_Renew_EUR__c, EMEA_Incremental_Revenue_U_EUR__c, EMEA_First_Year_Maint_U_EUR__c, '
                        + ' Latin_America_Billing_Schedule_Renew_EUR__c, Latin_America_Deferred_Revenue_Renew_EUR__c, Latin_America_Revenue_Recognition_R_EUR__c, Latin_America_Incremental_Revenue_U_EUR__c, Latin_America_First_Year_Maint_U_EUR__c, '
                        + ' North_America_Billing_Schedule_Renew_EUR__c, North_America_Deferred_Revenue_Renew_EUR__c, North_America_Revenue_Recognition_R_EUR__c, North_America_Incremental_Revenue_U_EUR__c, North_America_First_Year_Maint_U_EUR__c '
                        + ' FROM Genesys_Care_Forecasting_Rollup__c ';
         if(Test.isRunningTest())
            query = query + ' LIMIT 3';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc , List<sObject> scope){
       
        for(sObject so : scope){
            Genesys_Care_Forecasting_Rollup__c gfcRollup = (Genesys_Care_Forecasting_Rollup__c)so;
            
            String revenueType, region, subCategory;
            for (AggregateResult ar : [SELECT Region__c, Revenue_Type__c, Sub_category__c, SUM(Posting_Amount__c) total , 
                                            SUM(Posting_Amount_USD__c) totalInUSD, SUM(Posting_Amount_EUR__c) totalInEUR
                                                            FROM Genesys_Care_Forecasting__c 
                                                            WHERE Posting_Year_formula__c = :gfcRollup.Year__c AND Posting_Month_formula__c = :gfcRollup.Month__c 
                                                            GROUP BY Region__c, Revenue_Type__c, Sub_category__c])  {
                
                                                                
                revenueType = (ar.get('Revenue_Type__c') != NULL ? (String)ar.get('Revenue_Type__c') : '');
                region = (ar.get('Region__c') != NULL ? (String)ar.get('Region__c') : '');
                subCategory = ar.get('Sub_category__c') != NULL ? (String)ar.get('Sub_category__c') : '';

                // System.debug('Revenue type is: '+revenueType+' region is:'+region+' subCategory is: '+subCategory+' totalInUSD: '+ar.get('totalInUSD'));
                if(CONSTANTS.GCF_REGION_APAC.equalsIgnoreCase(region)){
                    if(CONSTANTS.GCF_SUBCATEGORY_FYM.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                            gfcRollup.APAC_Billing_Schedule_FYM__c = (Decimal)ar.get('totalInUSD');
                            gfcRollup.APAC_Billing_Schedule_FYM_EUR__c = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                            gfcRollup.APAC_Deferred_Revenue_FYM__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.APAC_Deferred_Revenue_FYM_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                            gfcRollup.APAC_Revenue_Recognition_FYM__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.APAC_Revenue_Recognition_FYM_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }else if(CONSTANTS.GCF_SUBCATEGORY_RENEWAL.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                            gfcRollup.APAC_Billing_Schedule_Renew__c = (Decimal)ar.get('totalInUSD');
                            gfcRollup.APAC_Billing_Schedule_Renew_EUR__c = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                            gfcRollup.APAC_Deferred_Revenue_Renew__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.APAC_Deferred_Revenue_Renew_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                            gfcRollup.APAC_Revenue_Recognition_Renew__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.APAC_Revenue_Recognition_Renew_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }else if(CONSTANTS.GCF_SUBCATEGORY_EXPECTED.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                            gfcRollup.APAC_Incremental_Revenue_E__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.APAC_Incremental_Revenue_E_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                            gfcRollup.APAC_First_Year_Maint_E__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.APAC_First_Year_Maint_E_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }else if(CONSTANTS.GCF_SUBCATEGORY_UPSIDE.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                            gfcRollup.APAC_Incremental_Revenue_U__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.APAC_Incremental_Revenue_U_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                            gfcRollup.APAC_First_Year_Maint_U__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.APAC_First_Year_Maint_U_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }

                    // Totoals where sub_category is FYM/Renewal/Expected/Upside or blank.
                    if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                        gfcRollup.APAC_Billing_Schedule__c += (Decimal)ar.get('totalInUSD');
                        gfcRollup.APAC_Billing_Schedule_EUR__c += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                        gfcRollup.APAC_Deferred_Revenue__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.APAC_Deferred_Revenue_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                        gfcRollup.APAC_Revenue_Recognition__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.APAC_Revenue_Recognition_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                        gfcRollup.APAC_Incremental_Revenue__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.APAC_Incremental_Revenue_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                        gfcRollup.APAC_First_Year_Maintenance__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.APAC_First_Year_Maintenance_EUR__c  += (Decimal)ar.get('totalInEUR');
                    }
                }
                
                if(CONSTANTS.GCF_REGION_EMEA.equalsIgnoreCase(region)){
                    if(CONSTANTS.GCF_SUBCATEGORY_FYM.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                            gfcRollup.EMEA_Billing_Schedule_FYM__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.EMEA_Billing_Schedule_FYM_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                            gfcRollup.EMEA_Deferred_Revenue_FYM__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.EMEA_Deferred_Revenue_FYM_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                            gfcRollup.EMEA_Revenue_Recognition_FYM__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.EMEA_Revenue_Recognition_FYM_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }else if(CONSTANTS.GCF_SUBCATEGORY_RENEWAL.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                            gfcRollup.EMEA_Billing_Schedule_Renew__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.EMEA_Billing_Schedule_Renew_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                            gfcRollup.EMEA_Deferred_Revenue_Renew__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.EMEA_Deferred_Revenue_Renew_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                            gfcRollup.EMEA_Revenue_Recognition_Renew__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.EMEA_Revenue_Recognition_Renew_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }else if(CONSTANTS.GCF_SUBCATEGORY_EXPECTED.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                            gfcRollup.EMEA_Incremental_Revenue_E__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.EMEA_Incremental_Revenue_E_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                            gfcRollup.EMEA_First_Year_Maint_E__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.EMEA_First_Year_Maint_E_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }else if(CONSTANTS.GCF_SUBCATEGORY_UPSIDE.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                            gfcRollup.EMEA_Incremental_Revenue_U__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.EMEA_Incremental_Revenue_U_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                            gfcRollup.EMEA_First_Year_Maint_U__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.EMEA_First_Year_Maint_U_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }

                    // Totoals where sub_category is FYM/Renewal/Expected/Upside or blank.
                    if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                        gfcRollup.EMEA_Billing_Schedule__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.EMEA_Billing_Schedule_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                        gfcRollup.EMEA_Deferred_Revenue__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.EMEA_Deferred_Revenue_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                        gfcRollup.EMEA_Revenue_Recognition__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.EMEA_Revenue_Recognition_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                        gfcRollup.EMEA_Incremental_Revenue__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.EMEA_Incremental_Revenue_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                        gfcRollup.EMEA_First_Year_Maintenance__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.EMEA_Incremental_Revenue_EUR__c  += (Decimal)ar.get('totalInEUR');
                    }
                }
    
                if(CONSTANTS.GCF_REGION_LA.equalsIgnoreCase(region)){
                    if(CONSTANTS.GCF_SUBCATEGORY_FYM.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                            gfcRollup.Latin_America_Billing_Schedule_FYM__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.Latin_America_Billing_Schedule_FYM_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                            gfcRollup.Latin_America_Deferred_Revenue_FYM__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.Latin_America_Deferred_Revenue_FYM_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                            gfcRollup.Latin_America_Revenue_Recognition_FYM__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.Latin_America_Revenue_Recognition_F_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }else if(CONSTANTS.GCF_SUBCATEGORY_RENEWAL.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                            gfcRollup.Latin_America_Billing_Schedule_Renew__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.Latin_America_Billing_Schedule_Renew_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                            gfcRollup.Latin_America_Deferred_Revenue_Renew__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.Latin_America_Deferred_Revenue_Renew_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                            gfcRollup.Latin_America_Revenue_Recognition_Renew__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.Latin_America_Revenue_Recognition_R_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } 
                    }else if(CONSTANTS.GCF_SUBCATEGORY_EXPECTED.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                            gfcRollup.Latin_America_Incremental_Revenue_E__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.Latin_America_Incremental_Revenue_E_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                            gfcRollup.Latin_America_First_Year_Maint_E__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.Latin_America_First_Year_Maint_E_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }else if(CONSTANTS.GCF_SUBCATEGORY_UPSIDE.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                            gfcRollup.Latin_America_Incremental_Revenue_U__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.Latin_America_Incremental_Revenue_U_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                            gfcRollup.Latin_America_First_Year_Maint_U__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.Latin_America_First_Year_Maint_U_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }

                    // Totoals where sub_category is FYM/Renewal/Expected/Upside or blank.
                    if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                        gfcRollup.Latin_America_Billing_Schedule__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.Latin_America_Billing_Schedule_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                        gfcRollup.Latin_America_Deferred_Revenue__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.Latin_America_Deferred_Revenue_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                        gfcRollup.Latin_America_Revenue_Recognition__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.Latin_America_Revenue_Recognition_EUR__c  += (Decimal)ar.get('totalInEUR');
                    }else if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                        gfcRollup.Latin_America_Incremental_Revenue__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.Latin_America_Incremental_Revenue_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                        gfcRollup.Latin_America_First_Year_Maintenance__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.Latin_America_First_Year_Maintenance_EUR__c  += (Decimal)ar.get('totalInEUR');
                    }
                }
    
                if(CONSTANTS.GCF_REGION_NA.equalsIgnoreCase(region)){
                    if(CONSTANTS.GCF_SUBCATEGORY_FYM.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                            gfcRollup.North_America_Billing_Schedule_FYM__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.North_America_Billing_Schedule_FYM_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                            gfcRollup.North_America_Deferred_Revenue_FYM__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.North_America_Deferred_Revenue_FYM_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                            gfcRollup.North_America_Revenue_Recognition_FYM__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.North_America_Revenue_Recognition_F_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }else if(CONSTANTS.GCF_SUBCATEGORY_RENEWAL.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                            gfcRollup.North_America_Billing_Schedule_Renew__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.North_America_Billing_Schedule_Renew_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                            gfcRollup.North_America_Deferred_Revenue_Renew__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.North_America_Deferred_Revenue_Renew_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                            gfcRollup.North_America_Revenue_Recognition_Renew__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.North_America_Revenue_Recognition_R_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } 
                    }else if(CONSTANTS.GCF_SUBCATEGORY_EXPECTED.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                            gfcRollup.North_America_Incremental_Revenue_E__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.North_America_Incremental_Revenue_E_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                            gfcRollup.North_America_First_Year_Maint_E__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.North_America_First_Year_Maint_E_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }else if(CONSTANTS.GCF_SUBCATEGORY_UPSIDE.equalsIgnoreCase(subCategory)){
                        if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                            gfcRollup.North_America_Incremental_Revenue_U__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.North_America_Incremental_Revenue_U_EUR__c  = (Decimal)ar.get('totalInEUR');
                        } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                            gfcRollup.North_America_First_Year_Maint_U__c  = (Decimal)ar.get('totalInUSD');
                            gfcRollup.North_America_First_Year_Maint_U_EUR__c  = (Decimal)ar.get('totalInEUR');
                        }
                    }

                    // Totoals where sub_category is FYM/Renewal or blank.
                    if(CONSTANTS.GCF_REVENUETYPE_BS.equalsIgnoreCase(revenueType)){
                        gfcRollup.North_America_Billing_Schedule__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.North_America_Billing_Schedule_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_DR.equalsIgnoreCase(revenueType)){
                        gfcRollup.North_America_Deferred_Revenue__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.North_America_Deferred_Revenue_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_RR1.equalsIgnoreCase(revenueType) || CONSTANTS.GCF_REVENUETYPE_RR2.equalsIgnoreCase(revenueType)){
                        gfcRollup.North_America_Revenue_Recognition__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.North_America_Revenue_Recognition_EUR__c  += (Decimal)ar.get('totalInEUR');
                    }else if(CONSTANTS.GCF_REVENUETYPE_IR.equalsIgnoreCase(revenueType)){
                        gfcRollup.North_America_Incremental_Revenue__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.North_America_Incremental_Revenue_EUR__c  += (Decimal)ar.get('totalInEUR');
                    } else if(CONSTANTS.GCF_REVENUETYPE_FYM.equalsIgnoreCase(revenueType)){
                        gfcRollup.North_America_First_Year_Maintenance__c  += (Decimal)ar.get('totalInUSD');
                        gfcRollup.North_America_First_Year_Maintenance_EUR__c  += (Decimal)ar.get('totalInEUR');
                    }
                }            
            }
        }
        Database.update(scope);
    }
    
    global void finish(Database.BatchableContext bc){
        // completed clean up ...   
    }
}