/*
Class : QuoteProductUtil
Usage : Utility Class For Quote Triggers and QuoteProduct Triggers
Author : Rashmi K - Cleartask 3/27/2013
*/
public without sharing class QuoteProductUtil {
    
    public final static String QUOTE_CLOSE_CANCELLED = '7.Closed Quote Cancelled';
    public static String getMonth( Integer mon ){
        if(mon == 1)
            return 'January';
        if(mon == 2)
            return 'February';
        if(mon == 3)
            return 'March';
        if(mon == 4)
            return 'April';
        if(mon == 5)
            return 'May';
        if(mon == 6)
            return 'June';
        if(mon == 7)
            return 'July';
        if(mon == 8)
            return 'August';
        if(mon == 9)
            return 'September';
        if(mon == 10)
            return 'October';
        if(mon == 11)
            return 'November';
        if(mon == 12)
            return 'December';
        return null;
    }
    
    public static String getFiscalQuarter( Integer mon ){
        Set<Integer> q1 = new Set<Integer>{1, 2, 3};
        Set<Integer> q2 = new Set<Integer>{4, 5, 6};
        Set<Integer> q3 = new Set<Integer>{7, 8, 9};
        Set<Integer> q4 = new Set<Integer>{10, 11, 12};
        if( q1.contains(mon))
            return 'Q1';
        if( q2.contains(mon))
            return 'Q2';
        if( q3.contains(mon))
            return 'Q3';
        if( q4.contains(mon))
            return 'Q4';
        return 'Remainder';
    }
    
    public static void createContractLineSplits(List<BigMachines__Quote_Product__c> productsToSplit){
        // split only non-maintenance records
        List<BigMachines__Quote_Product__c> products = [Select Id, Service_Contract_Line_ID__c, BigMachines__Quote__c, Current_Qty__c,
                                                               Contract_Line_Update_Status__c, Revised_Net_License_Value__c, BigMachines__Quantity__c,
                                                               BigMachines__Description__c
                                                        from BigMachines__Quote_Product__c 
                                                        where ID IN :productsToSplit and 
                                                            BigMachines__Product__r.Type__c != : ServiceContractUtil.MAINTENANCE and 
                                                            BigMachines__Product__r.Type__c != :ServiceContractUtil.GENESYS_CARE];
                                                            
        List< Split_Contract_Line__c> splitsToInsert = new List< Split_Contract_Line__c>();
        for(BigMachines__Quote_Product__c qp : products){
        if(qp.BigMachines__Quantity__c > 0 && qp.Service_Contract_Line_ID__c != null){
                Split_Contract_Line__c spc = new Split_Contract_Line__c();
                spc.Contract_Line_Item__c = qp.Service_Contract_Line_ID__c;
                spc.Quantity__c = qp.Current_Qty__c;
                spc.TopQuote__c = qp.BigMachines__Quote__c;
                spc.Quote_Product__c = qp.Id;
                spc.Status__c = qp.Contract_Line_Update_Status__c;
                spc.Revised_Net_License_Value__c = qp.Revised_Net_License_Value__c;
                spc.Product_Description__c = qp.BigMachines__Description__c;
                splitsToInsert.add(spc);
            }
        }
        if(!splitsToInsert.isEmpty())
            insert splitsToInsert;
    }
    
    public static void updateOpportunities( Map<Id, BigMachines__Quote__c> oppIdsToQuotes ){
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([Select ID, StageName 
                                                              from Opportunity 
                                                              where ID IN: oppIdsToQuotes.keySet() 
                                                                    and RecordType.DeveloperName =:ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME] );
        for(Id oppId : oppIdsToQuotes.keySet()){
            
            Opportunity opp = oppsMap.get(oppId);
            BigMachines__Quote__c q = oppIdsToQuotes.get(oppId);
            
            if(opp != null && !opp.StageName.contains('Closed')) {
                opp.Primary_Quote__c = q.id;
                opp.Quote_Amount__c = q.BigMachines__Total_Amount__c;
                opp.Quote_Genesys_Care_Rate__c = q.Genesys_Care_Rate__c;
                opp.Quote_Decreased_Quote_Reason__c = q.Decreased_Quote_Reason__c;
                opp.Quote_Cancelled_Quote_Reason__c = q.Cancelled_Quote_Reason__c;
                opp.Quote_Cancelled_Reason__c = q.Cancellation_Reason__c;
                opp.Quote_Cancelled_Date__c = q.Cancelled_Date__c;
                opp.Quote_USD_Equivalent__c = q.USD_Equivalent__c;
                opp.Quote_Quote_Created_Date__c = q.Quote_Created_Date__c;
                opp.Quote_Quote_Status__c = q.BigMachines__Status__c;
                opp.Quote_Comment__c = q.Comment__c;
                //opp.Quote_End_User_ID__c = q.End_User_ID__c;
                opp.Quote_Support_Owner_ID__c = q.Support_Owner_ID__c;
                
                opp.Quote_Genesys_Care__c = q.Genesys_Care__c;
                opp.Quote_Maintenance_Start_Date__c = q.Maintenance_Start_Date__c;
                opp.Quote_Maintenance_End_Date__c = q.Maintenance_End_Date__c;
                opp.Quote_Order_Payment_Terms__c = q.Order_Payment_Terms__c;
                opp.Quote_Quote_Version__c = q.Quote_Version__c;
                opp.Quote_Sales_org__c = q.Sales_org__c;
                opp.Quote_Big_Six__c = q.Big_Six__c;
                opp.Quote_SG2_Region__c = q.SG2_Region__c;
                opp.Support_Owner__c = q.Support_Owner__c;
                opp.Quote_Last_Modified_Date__c = String.valueof(q.LastModifiedDate);
                opp.Quote_Annual_Increase__c = q.Annual_Increase__c;
                opp.Quote_Total_Net_License_Value__c = String.valueof(q.Total_Net_License_Value__c);
                opp.Quote_Negotiated_Rate_Increase__c = q.Rate_Increase_Value_USD__c;
                opp.Quote_Reinstated_Date__c = q.Reinstated_Date__c;
                opp.Quote_Total_Revised_Net_License__c = String.valueof(q.Total_Revised_Net_License_Value__c);
                opp.Quote_Annual_Increase_Value__c = q.Annual_Increase_Value__c; 
                opp.Current_Maint_Rate__c = q.Current_Maint_Rate__c;               
              
               
                
                
                DateTime Dt = q.CreatedDate;
                Date D = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());  
                opp.Quote_Quote_Created_Date__c = D;
                if(q.Total_Software__c!= null)
                opp.Quote_Total_Net_License_Value__c = q.Total_Software__c.toPlainString();
       
                opp.Maintenance_Amount__c = q.Total_Genesys_Care__c;
            
                oppsToUpdate.add( opp );
            
            }
        }
        
        if(!oppsToUpdate.isEmpty())
            update oppsToUpdate;    
    }
    
    public static void updateOppStages(Set<Id> oppIds){
        List<Opportunity> opps = new LisT<Opportunity>();
        for(Id oppId : oppIds){
            opps.add(new Opportunity(Id=oppId, StageName=QUOTE_CLOSE_CANCELLED));
        }
        if(!opps.isEmpty())
            update opps;    
    }
    
    public static void updateQuotes(Set<Id> quoteIds){
        Map<Id, List<BigMachines__Quote_Product__c>> quoteIdToQps = new Map<Id, List<BigMachines__Quote_Product__c>>();
        List<BigMachines__Quote_Product__c> quoteProducts = [Select Id, Maintenance_End_Date__c, Maintenance_Start_Date__c, BigMachines__Quote__c 
                                                             from BigMachines__Quote_Product__c 
                                                             where BigMachines__Quote__c IN:quoteIds];
        for(BigMachines__Quote_Product__c qp : quoteProducts){
            if(!quoteIdToQps.containsKey(qp.BigMachines__Quote__c))
                quoteIdToQps.put(qp.BigMachines__Quote__c, new List<BigMachines__Quote_Product__c>{qp});
            else
                quoteIdToQps.get(qp.BigMachines__Quote__c).add(qp);
        }
        
        List<BigMachines__Quote__c> quotesToUpdate = new List<BigMachines__Quote__c>();
        for(Id quoteId : quoteIdToQps.keyset()){
            Date startDate ;
            Date endDate ;
            for(BigMachines__Quote_Product__c qp : quoteIdToQps.get(quoteId)){
                if(qp.Maintenance_End_Date__c != null){
                    if(startDate == null)
                        startDate = qp.Maintenance_Start_Date__c;
                    else{
                        if(startDate > qp.Maintenance_Start_Date__c)
                            startDate = qp.Maintenance_Start_Date__c;
                    }
                }
                if(qp.Maintenance_End_Date__c != null){
                        endDate = qp.Maintenance_End_Date__c;
                }
            }
            if( startDate != null && endDate != null){
                quotesToUpdate.add(new BigMachines__Quote__c(Id=quoteId, Maintenance_End_Date__c=endDate, Maintenance_Start_Date__c=startDate));
            }
        }
        if(!quotesToUpdate.isEmpty())
            update quotesToUpdate;
    }
    
    public static void updateNoOfQuotesOnOpp(Set<Id> oppIds){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(AggregateResult ar : [Select COUNT(Id) quoteCount, BigMachines__Opportunity__c 
                              from BigMachines__Quote__c 
                              where BigMachines__Opportunity__c IN : oppIds Group by BigMachines__Opportunity__c])
        {
            Id idOppty = (Id) ar.get('BigMachines__Opportunity__c');
            if(idOppty != null)
        		oppsToUpdate.add( new Opportunity( Id = idOppty, Number_of_associated_Quotes__c =(Decimal) ar.get('quoteCount') ));
        }
        if(!oppsToUpdate.isEmpty())
            update oppsToUpdate;                      
    }
    //Commented by Naresh K on 04/30/2013, Both the below functions are not used anywhere.
    /*
    public static void createRevenueDistributions( List<BigMachines__Quote_Product__c> products ){
        List<Maintenance_Revenue_Distribution__c> revenueDists = new List<Maintenance_Revenue_Distribution__c>();
        for(BigMachines__Quote_Product__c qp : products){
            if( qp.Maintenance_End_Date__c != null && qp.Maintenance_Start_Date__c != null){
                Integer numOfMonths = qp.Maintenance_Start_Date__c.monthsBetween(qp.Maintenance_End_Date__c) + 1;
                Decimal amount = qp.BigMachines__Total_Price__c/numOfMonths;
                Integer currentMonth = qp.Maintenance_Start_Date__c.month();
                for(Integer i=0; i<numOfMonths; i++){
                    Maintenance_Revenue_Distribution__c mrd = new Maintenance_Revenue_Distribution__c();
                    mrd.Quote_Product__c = qp.Id;
                    mrd.Revenue_Distribution__c = QuoteProductUtil.getFiscalQuarter(currentMonth + i);
                    system.debug('currentMonth + i'+ currentMonth + i);
                    if(currentMonth + i <= 12 )
                    {
                        system.debug('in i< 12');
                        mrd.Amount__c = amount;
                        mrd.Month__c = QuoteProductUtil.getMonth( currentMonth + i );
                        mrd.Fiscal_Year__c = string.valueof(qp.Maintenance_Start_Date__c.year());
                        revenueDists.add( mrd );
                    }else{
                        mrd.Amount__c = qp.BigMachines__Total_Price__c - (amount * i);
                        mrd.Fiscal_Year__c = string.valueof(qp.Maintenance_End_Date__c.year());
                        revenueDists.add( mrd );
                        break;
                    }
                    
                }
            }
        }
        if(!revenueDists.isEmpty())
            insert revenueDists;
    }
    
    public static void createOrderRevenueDistributions( Set<Order__c> orders ){
        List<Order_Revenue_Distribution__c> revenueDists = new List<Order_Revenue_Distribution__c>();
        for(Order__c o : orders){
            if( o.Maintenance_End__c != null && o.Maintenance_Start__c != null && o.Net_Maint__c != null){
                Integer numOfMonths = o.Maintenance_Start__c.monthsBetween(o.Maintenance_End__c) + 1;
                Decimal amount = o.Net_Maint__c/numOfMonths;
                Integer currentMonth = o.Maintenance_Start__c.month();
                for(Integer i=0; i<numOfMonths; i++){
                    Order_Revenue_Distribution__c ord = new Order_Revenue_Distribution__c();
                    ord.Order__c = o.Id;
                    ord.Revenue_Distribution__c = QuoteProductUtil.getFiscalQuarter(currentMonth + i);
                    system.debug('currentMonth + i'+ currentMonth + i);
                    if(currentMonth + i <= 12 )
                    {
                        system.debug('in i< 12');
                        ord.Amount__c = amount;
                        ord.Month__c = QuoteProductUtil.getMonth( currentMonth + i );
                        ord.Fiscal_Year__c = string.valueof(o.Maintenance_Start__c.year());
                        revenueDists.add( ord );
                    }else{
                        ord.Amount__c = o.Net_Maint__c - (amount * i);
                        ord.Fiscal_Year__c = string.valueof(o.Maintenance_End__c.year());
                        revenueDists.add( ord );
                        break;
                    }
                    
                }
            } else o.addError('Please ensure the order Maint. Start, Maint. End and Net Maint. fields are filled before approving the order');
        }
        if(!revenueDists.isEmpty())
            insert revenueDists;
    }
    */
}