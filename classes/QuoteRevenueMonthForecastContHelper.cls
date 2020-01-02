//Naresh Kumar  02/23/2015
public without sharing class QuoteRevenueMonthForecastContHelper {

    public static List<QuoteRevenueMonthForecastController.lineItemsWrapper> getAccountSummary(String selectedQuarter, String selectedWeek,String selectedCs){
        List<QuoteRevenueMonthForecastController.lineItemsWrapper> lineItems = new List<QuoteRevenueMonthForecastController.lineItemsWrapper>();
        Integer year = Integer.valueOf(selectedQuarter.split('-')[1]);
        Integer quarter = Integer.valueOf(selectedQuarter.split('-')[0]);
        AggregateResult[] groupedResults;
        groupedResults = [SELECT Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Account__c, SUM(Month_Revenue__c) Revenue FROM Cloud_Forecast_Month__c 
                WHERE CALENDAR_YEAR(Cloud_Billing_Phase__r.End_Date__c) =: year 
                AND Month_Quarter__c =: quarter GROUP BY Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Account__c];
        
  
        Set<Id> accountIds = new Set<Id>();
        for (AggregateResult ar : groupedResults)  {
            accountIds.add(String.valueOf(ar.get('Account__c')));
        }
        
        Map<Id, Account> mapAccountIdVsName = new Map<Id, Account>([SELECT id, Name, CSM_Account_Owner__r.Name FROM Account WHERE id IN : accountIds OR Cloud_Flag__c = true order by CSM_Account_Owner__r.Name]);
        Map<Id, Account_Revenue_Forecast__c> mapAccountIdVsRevenueForecast = new Map<Id, Account_Revenue_Forecast__c>(); 
        
      if(selectedCs != null && selectedCs <> '') {
       mapAccountIdVsName = new Map<Id, Account>([SELECT id, Name, CSM_Account_Owner__r.Name FROM Account WHERE (id IN : accountIds OR Cloud_Flag__c = true) AND  CSM_Account_Owner__r.Name=: selectedCs order by CSM_Account_Owner__r.Name]);      
      
      }
        
        String weekDate, previousWeekDate;
        
        if(selectedWeek != null){
            //weekDate = date.valueOf(selectedWeek);
            //peviousWeekDate = weekDate.addDays(-7);
           weekDate = selectedWeek;
           previousWeekDate = '';
       
        
        }
          List<Account_Revenue_Forecast__c> accountRevForecast = [SELECT id, Account__c, Status__c, Revenue__c, Commit__c, Land__c, Best__c,
            LastModifiedBy.Name,Previous_Week__r.Land__c,Previous_Week__r.Commit__c,Previous_Week__r.Best__c,Previous_Week__c, 
            Subscription_Land__c, PS_Land__c, New_Logo_2016__c, Cloud_Platform_Type__c, Q1_2017_Low_Subscription__c, Q2_2017_Low_Subs__c,Q2_2017_Land_Subs__c,BQ2_PS_Land__c,
            Q3_2017_Low_Subs__c,Q3_2017_Land_Subs__c,BQ3_PS_Land__c, Previous_Week__r.Q3_2017_Land_Subs__c,Previous_Week__r.BQ3_PS_Land__c,
            PS_Low__c, Subscription_Low__c, Total_Low__c, Total_Land__c,Total_Change__c,PS_Best__c, Subscription_Best__c, Total_Best__c,Quota__c, Q1_2017_Land_Subscribe__c, 
            Previous_Week__r.Q1_2017_Land_Subscribe__c, Previous_Week__r.Q2_2017_Land_Subs__c,Previous_Week__r.BQ2_PS_Land__c,Previous_Week__r.PS_Land__c,Previous_Week__r.Total_Land__c,Previous_Week__r.Total_Change__c
            
            
             ,Q4_2017_Low_Subs__c,Q4_2017_Land_Subs__c,  Previous_Week__r.Q4_2017_Low_Subs__c, Previous_Week__r.Q4_2017_Land_Subs__c,Previous_Week__r.BQ4_PS_Land__c,BQ4_PS_Land__c FROM Account_Revenue_Forecast__c 
            
            WHERE PE_SS_Flag__c = false AND Cloud_Forecast_Quarter__c =: weekDate  and Low_LOB__c = true];        
        
        
        if(selectedCs != null && selectedCs <> '') {
         selectedCs = selectedCs.toLowerCase();
         accountRevForecast = [SELECT id, Account__c, Status__c, Revenue__c, Commit__c, Land__c, Best__c,
            LastModifiedBy.Name,Previous_Week__r.Land__c,Previous_Week__r.Commit__c,Previous_Week__r.Best__c,Previous_Week__c,
            Subscription_Land__c, PS_Land__c, New_Logo_2016__c, Cloud_Platform_Type__c,Total_Best__c,Quota__c, Q1_2017_Land_Subscribe__c,Q2_2017_Low_Subs__c,Q2_2017_Land_Subs__c,BQ2_PS_Land__c,
            PS_Low__c, Subscription_Low__c, Total_Low__c,Total_Land__c,Total_Change__c, PS_Best__c, Subscription_Best__c, Q1_2017_Low_Subscription__c,
             Q3_2017_Low_Subs__c,Q3_2017_Land_Subs__c,BQ3_PS_Land__c, Previous_Week__r.Q3_2017_Land_Subs__c,Previous_Week__r.BQ3_PS_Land__c,
            Previous_Week__r.Q1_2017_Land_Subscribe__c, Previous_Week__r.Q2_2017_Land_Subs__c, Previous_Week__r.PS_Land__c,Previous_Week__r.BQ2_PS_Land__c,Previous_Week__r.Total_Land__c,Previous_Week__r.Total_Change__c 
                    ,Q4_2017_Low_Subs__c,Q4_2017_Land_Subs__c,  Previous_Week__r.Q4_2017_Low_Subs__c, Previous_Week__r.Q4_2017_Land_Subs__c,Previous_Week__r.BQ4_PS_Land__c,BQ4_PS_Land__c
              
              FROM Account_Revenue_Forecast__c 
            WHERE PE_SS_Flag__c = false AND Cloud_Forecast_Quarter__c =: weekDate and CSM_Owner__c =: selectedCs and Low_Lob__c = true ];        
        }
        
        
        for(Account_Revenue_Forecast__c eachARF : accountRevForecast){
            mapAccountIdVsRevenueForecast.put(eachARF.Account__c, eachARF); 
        }
       
     List <Cloud_Forecast_Quarter__c> currentWeek = [Select id,previous_week__c from Cloud_Forecast_Quarter__c where 
            id =:selectedWeek];
       
       for(Cloud_Forecast_Quarter__c eachWeek: currentWeek) 
         previousWeekDate = eachWeek.previous_week__c;        
       
            
        List<Account_Revenue_Forecast__c> accountRevForecastPreviousWeek = [SELECT id, Account__c, Status__c, Revenue__c, Commit__c, Land__c, Best__c,
            LastModifiedBy.Name, New_Logo_2016__c, Cloud_Platform_Type__c, Q1_2017_Land_Subscribe__c ,Q2_2017_Land_Subs__c ,Q3_2017_Land_Subs__c,Q4_2017_Land_Subs__c
            FROM Account_Revenue_Forecast__c WHERE PE_SS_Flag__c = false AND Cloud_Forecast_Quarter__c =: previousWeekDate AND (Commit__c != 0 OR Land__c != 0 OR Best__c != 0)];
        
        
        
        
        Map<Id, Account_Revenue_Forecast__c> mapAccIdVsPrevWeekForecast = new Map<Id, Account_Revenue_Forecast__c>();
       
        for(Account_Revenue_Forecast__c eachARF : accountRevForecastPreviousWeek ){
            mapAccIdVsPrevWeekForecast.put(eachARF.Account__c, eachARF); 
            System.debug('NKC debug eachARF.Account__c [' + eachARF.Account__c + ']');                
        }
       
       
        Double total = 0, commitQuantity = 0, landQuantity = 0, bestQuantity = 0,totalLowQuantity=0,totalLandQuantity=0,totalBestQuantity=0;
        Double totalChangeLowQuantity=0,totalChangeLandQuantity=0,totalChangeBestQuantity=0, totalSubLand=0, totalPSLand=0, totalTotalLand=0;
        Double totalQuota = 0, totalPSLow = 0, totalSubscriptionLow = 0, totalTotalLow = 0, totalPSBest = 0, totalSubscriptionBest = 0, totalTotalBest = 0;
        Double totalLastWeekLand = 0, totalChange = 0;
        Integer count = 0;
        for (AggregateResult ar : groupedResults)  {
            if(ar.get('Account__c') == null)
                continue;
            QuoteRevenueMonthForecastController.lineItemsWrapper newItem = new QuoteRevenueMonthForecastController.lineItemsWrapper();
            newItem.account = mapAccountIdVsName.get(String.valueOf(ar.get('Account__c'))).Name;
            newItem.accountId = mapAccountIdVsName.get(String.valueOf(ar.get('Account__c'))).id;
            newItem.csmOwner = mapAccountIdVsName.get(String.valueOf(ar.get('Account__c'))).CSM_Account_Owner__r.Name;
            newItem.revenue = Double.valueOf(ar.get('Revenue'));
            total += newItem.revenue; 
            newItem.record = mapAccountIdVsRevenueForecast.get(newItem.accountId);    
            System.debug('NKC debug record ['+newItem.record+']'); 
            if(mapAccountIdVsRevenueForecast.get(newItem.accountId) != null){
                newItem.commitQuantity = mapAccountIdVsRevenueForecast.get(newItem.accountId).Commit__c; 
                newItem.lastWeekLand = mapAccountIdVsRevenueForecast.get(newItem.accountId).Previous_Week__r.Total_Land__c;
                newItem.change = mapAccountIdVsRevenueForecast.get(newItem.accountId).Total_Change__c;                               
                newItem.landQuantity = mapAccountIdVsRevenueForecast.get(newItem.accountId).Land__c;
                newItem.bestQuantity = mapAccountIdVsRevenueForecast.get(newItem.accountId).Best__c;    
                newItem.subscriptionLand = mapAccountIdVsRevenueForecast.get(newItem.accountId).Q4_2017_Land_Subs__c ;
                newItem.psLand = mapAccountIdVsRevenueForecast.get(newItem.accountId).BQ2_PS_Land__c;      
                newItem.psLow = mapAccountIdVsRevenueForecast.get(newItem.accountId).PS_Low__c;      
                newItem.subscriptionLow = mapAccountIdVsRevenueForecast.get(newItem.accountId).Q4_2017_Low_Subs__c;      
                newItem.totalLow = mapAccountIdVsRevenueForecast.get(newItem.accountId).Total_Low__c;      
                newItem.psBest = mapAccountIdVsRevenueForecast.get(newItem.accountId).PS_Best__c;      
                newItem.subscriptionBest = mapAccountIdVsRevenueForecast.get(newItem.accountId).Subscription_Best__c;      
                newItem.totalBest = mapAccountIdVsRevenueForecast.get(newItem.accountId).Total_Best__c;     
                newItem.quota = mapAccountIdVsRevenueForecast.get(newItem.accountId).Quota__c;  
               
               
                if(mapAccountIdVsRevenueForecast.get(newItem.accountId).Previous_Week__r != null) {
                 newItem.previousLandQuantity = mapAccountIdVsRevenueForecast.get(newItem.accountId).Previous_Week__r.Q4_2017_Land_Subs__c;                
                 newItem.previousBestQuantity = mapAccountIdVsRevenueForecast.get(newItem.accountId).Previous_Week__r.Best__c;                
                 newItem.previousLowQuantity = mapAccountIdVsRevenueForecast.get(newItem.accountId).Previous_Week__r.Commit__c;
                }
            }   
            
            
            
            newItem.commitQuantity = (newItem.commitQuantity == null ? 0 : newItem.commitQuantity);
            newItem.lastWeekLand = (newItem.lastWeekLand == null ? 0 : newItem.lastWeekLand); 
            newItem.change = (newItem.change  == null ? 0 : newItem.change); 
            
            newItem.landQuantity = (newItem.landQuantity == null ? 0 : newItem.landQuantity );
            newItem.bestQuantity = (newItem.bestQuantity == null ? 0 : newItem.bestQuantity );
            newItem.previousLandQuantity = (newItem.previousLandQuantity == null ? 0 : newItem.previousLandQuantity );
            newItem.previousLowQuantity = (newItem.previousLowQuantity == null ? 0 : newItem.previousLowQuantity );
            newItem.previousBestQuantity = (newItem.previousBestQuantity == null ? 0 : newItem.previousBestQuantity );
            
            newItem.subscriptionLand = (newItem.subscriptionLand == null ? 0 : newItem.subscriptionLand );
            newItem.psLand = (newItem.psLand == null ? 0 : newItem.psLand );
            newItem.totalLand = newItem.subscriptionLand + newItem.psLand;
            
            newItem.changeLowQuantity = newItem.commitQuantity -newItem.previousLowQuantity; 
            newItem.changeLandQuantity = newItem.subscriptionLand -newItem.previousLandQuantity; 
            newItem.changeBestQuantity = newItem.bestQuantity -newItem.previousBestQuantity; 
            
            newItem.psLow = newItem.psLow == null ? 0 : newItem.psLow;
            newItem.subscriptionLow = newItem.subscriptionLow == null ? 0 : newItem.subscriptionLow;
            newItem.totalLow = newItem.totalLow == null ? 0 : newItem.totalLow;
            newItem.psBest = newItem.psBest == null ? 0 : newItem.psBest;
            newItem.quota = newItem.quota == null ? 0 : newItem.quota;
            
            newItem.subscriptionBest = newItem.subscriptionBest == null ? 0 : newItem.subscriptionBest;
            newItem.totalBest = newItem.totalBest == null ? 0 : newItem.totalBest;
            
            
            
            System.debug('NKC debug newItem.accountId [' + newItem.accountId + ']');                
            
            if(mapAccIdVsPrevWeekForecast.get(newItem.accountId) != null &&
                newItem.commitQuantity == 0 && newItem.landQuantity == 0 && newItem.bestQuantity == 0){                     
                    newItem.previousLowQuantity = mapAccIdVsPrevWeekForecast.get(newItem.accountId).Commit__c;                
                    newItem.previousLandQuantity = mapAccIdVsPrevWeekForecast.get(newItem.accountId).Q4_2017_Land_Subs__c;
                    newItem.previousBestQuantity = mapAccIdVsPrevWeekForecast.get(newItem.accountId).Best__c;
            }   
           
           
            commitQuantity += (newItem.commitQuantity == null ? 0 : newItem.commitQuantity);
            landQuantity += (newItem.landQuantity == null ? 0 : newItem.landQuantity );
            bestQuantity += (newItem.bestQuantity == null ? 0 : newItem.bestQuantity );
            
            totalLastWeekLand += (newItem.lastWeekLand == null ? 0 : newItem.lastWeekLand); 
            totalChange += (newItem.change == null ? 0 : newItem.change); 

            totalLowQuantity += (newItem.previousLowQuantity == null ? 0 : newItem.previousLowQuantity);
            totalLandQuantity += (newItem.previousLandQuantity == null ? 0 : newItem.previousLandQuantity );
            totalBestQuantity += (newItem.previousBestQuantity == null ? 0 : newItem.previousBestQuantity );

            totalChangeLowQuantity += (newItem.changeLowQuantity == null ? 0 : newItem.changeLowQuantity);
            totalChangeLandQuantity += (newItem.changeLandQuantity == null ? 0 : newItem.changeLandQuantity );
            totalChangeBestQuantity += (newItem.changeBestQuantity == null ? 0 : newItem.changeBestQuantity );
            totalSubLand += (newItem.subscriptionLand == null ? 0 : newItem.subscriptionLand );
            totalPSLand += (newItem.psLand == null ? 0 : newItem.psLand );
            totalTotalLand += (newItem.totalLand == null ? 0 : newItem.totalLand );
            
            totalQuota += newItem.quota;
            totalPSLow += newItem.psLow;
            totalSubscriptionLow += newItem.subscriptionLow;
            totalTotalLow += newItem.totalLow;
            totalPSBest += newItem.psBest;
            totalSubscriptionBest += newItem.subscriptionBest;
            totalTotalBest += newItem.totalBest;
                
            
            //newItem.quantity = 1000;
            //newItem.price = 15;
            newItem.isTotal = false;
            newItem.counter = count ++;
            lineItems.add(newItem);
        }
        for(Account eachAcc : mapAccountIdVsName.values()){
            if(accountIds.contains(eachAcc.id))
                continue;
            QuoteRevenueMonthForecastController.lineItemsWrapper newItem = new QuoteRevenueMonthForecastController.lineItemsWrapper();
            newItem.account = eachAcc.Name;
            newItem.accountId = eachAcc.id;
            newItem.csmOwner = eachAcc.CSM_Account_Owner__r.Name;
            newItem.revenue = 0;    
            newItem.record = mapAccountIdVsRevenueForecast.get(newItem.accountId); 
            newItem.commitQuantity = newItem.record.Commit__c;            
            newItem.lastWeekLand = newItem.record.Previous_Week__r.Total_Land__c;
            newItem.change = newItem.record.Total_Change__c;                                         
            newItem.landQuantity = newItem.record.Land__c;
            newItem.bestQuantity = newItem.record.Best__c;                
            newItem.subscriptionLand = (newItem.record.Q4_2017_Land_Subs__c == null ? 0 : newItem.record.Q4_2017_Land_Subs__c );
            newItem.psLand = (newItem.record.BQ3_PS_Land__c == null ? 0 : newItem.record.BQ3_PS_Land__c);
            newItem.totalLand = newItem.subscriptionLand + newItem.psLand; 
            newItem.psLow = newItem.record.PS_Low__c;
            newItem.subscriptionLow = newItem.record.Q4_2017_Low_Subs__c ;
            newItem.totalLow = newItem.record.Total_Low__c;
            newItem.psBest = newItem.record.PS_Best__c;
            newItem.subscriptionBest = newItem.record.Subscription_Best__c;
            newItem.totalBest = newItem.record.Total_Best__c;
            newItem.quota = newItem.record.quota__c;
            
            newItem.previousLowQuantity = newItem.record.Previous_Week__r.Commit__c;
             newItem.previousLandQuantity =newItem.record.Previous_Week__r.Q4_2017_Land_Subs__c;
               newItem.previousBestQuantity =newItem.record.Previous_Week__r.Best__c;
            
             if(mapAccIdVsPrevWeekForecast.get(eachAcc.id) != null 
                ){                     
                    newItem.previousLowQuantity = mapAccIdVsPrevWeekForecast.get(newItem.accountId).Commit__c;                
                    newItem.previousLandQuantity = mapAccIdVsPrevWeekForecast.get(newItem.accountId).Q4_2017_Land_Subs__c;
                    newItem.previousBestQuantity = mapAccIdVsPrevWeekForecast.get(newItem.accountId).Best__c;
            }   
           
           
           
                 
           
           
            newItem.changeLandQuantity = (newItem.previousLandQuantity == null || newItem.totalLand == null ? 0 : newItem.totalLand -newItem.previousLandQuantity );
            newItem.changeLowQuantity = (newItem.previousLowQuantity == null || newItem.commitQuantity == null ? 0 : newItem.commitQuantity -newItem.previousLowQuantity );
            newItem.changeBestQuantity = (newItem.previousBestQuantity == null || newItem.bestQuantity == null? 0 : newItem.bestQuantity -newItem.previousBestQuantity );
            
               
                      
            newItem.isTotal = false;
           
           
            commitQuantity += (newItem.commitQuantity == null ? 0 : newItem.commitQuantity);            
            landQuantity += (newItem.landQuantity == null ? 0 : newItem.landQuantity );
            bestQuantity += (newItem.bestQuantity == null ? 0 : newItem.bestQuantity );
            
            totalLastWeekLand += (newItem.lastWeekLand == null ? 0 : newItem.lastWeekLand); 
            totalChange += (newItem.change == null ? 0 : newItem.change);
                       
            totalLowQuantity += (newItem.previousLowQuantity == null ? 0 : newItem.previousLowQuantity);
            totalLandQuantity += (newItem.previousLandQuantity == null ? 0 : newItem.previousLandQuantity );
            totalBestQuantity += (newItem.previousBestQuantity == null ? 0 : newItem.previousBestQuantity );
       
            totalChangeLowQuantity += (newItem.changeLowQuantity == null ? 0 : newItem.changeLowQuantity);
            totalChangeLandQuantity += (newItem.changeLandQuantity == null ? 0 : newItem.changeLandQuantity );
            totalChangeBestQuantity += (newItem.changeBestQuantity == null ? 0 : newItem.changeBestQuantity );
            totalSubLand += (newItem.subscriptionLand == null ? 0 : newItem.subscriptionLand );
            totalPSLand += (newItem.psLand == null ? 0 : newItem.psLand );
            totalTotalLand += (newItem.totalLand == null ? 0 : newItem.totalLand );
            
            totalQuota += newItem.quota == null ? 0 : newItem.quota;
            totalPSLow += newItem.psLow == null ? 0 : newItem.psLow;
            totalSubscriptionLow += newItem.subscriptionLow == null ? 0 : newItem.subscriptionLow;
            totalTotalLow += newItem.totalLow == null ? 0 : newItem.totalLow;            
            totalPSBest += newItem.psBest == null ? 0 : newItem.psBest;
            totalSubscriptionBest += newItem.subscriptionBest == null ? 0 : newItem.subscriptionBest;
            totalTotalBest += newItem.totalBest == null ? 0 : newItem.totalBest;
             
           
            newItem.counter = count ++;
            lineItems.add(newItem);
        }
        QuoteRevenueMonthForecastController.lineItemsWrapper newItem = new QuoteRevenueMonthForecastController.lineItemsWrapper();
        newItem.revenue = total;         
        newItem.rowStyle = 'font-weight:bold;background-color:#CCCCCC;';
        newItem.isTotal = true;
        newItem.commitQuantity = commitQuantity;                
        newItem.landQuantity = landQuantity;
        newItem.bestQuantity = bestQuantity;
        newItem.previousLandQuantity = totalLandQuantity;
        newItem.previousLowQuantity = totalLowQuantity;
        newItem.previousBestQuantity = totalBestQuantity;
        newItem.changeLandQuantity = totalChangeLandQuantity;
        newItem.changeLowQuantity = totalChangeLowQuantity;
        newItem.changeBestQuantity = totalChangeBestQuantity;
        newitem.quota = totalQuota;
        newItem.subscriptionLand = totalSubLand;
        newItem.psLand = totalPSLand;
        newItem.totalLand = totalTotalLand;
        newItem.psLow = totalPSLow;
        newItem.subscriptionLow = totalSubscriptionLow;
        newItem.totalLow = totalTotalLow;
        newItem.psBest = totalPSBest;
        newItem.subscriptionBest = totalSubscriptionBest;
        newItem.totalBest = totalTotalBest;
        newItem.lastWeekLand = totalLastWeekLand;
        newItem.change = totalChange;
        lineItems.add(newItem);
        return lineItems;
    }
    
    public static List<QuoteRevenueMonthForecastController.forecastWrapper> populateAccountPhaseLine(String accountId, String selectedQuarter, String selectedWeek){
        Integer year = Integer.valueOf(selectedQuarter.split('-')[1]);
        Integer quarter = Integer.valueOf(selectedQuarter.split('-')[0]);
        List<Cloud_Phase_Line_Items__c> accountLineItems = [SELECT Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__c,
            Cloud_Billing_Phase__r.Phase_Status__c, 
            Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__r.Name, Product_Name__c, Cloud_Billing_Phase__r.Phase_Number__c, Quantity__c, PS_Total__c, Revenue__c 
            FROM Cloud_Phase_Line_Items__c WHERE CALENDAR_QUARTER(Cloud_Billing_Phase__r.End_Date__c) =: quarter
            AND CALENDAR_YEAR(Cloud_Billing_Phase__r.End_Date__c) =: year AND Account__c =: accountId ORDER BY Cloud_Billing_Phase__r.Phase_Number__c ASC];
        List<QuoteRevenueMonthForecastController.forecastWrapper> forecastLineItems = new List<QuoteRevenueMonthForecastController.forecastWrapper>();
        for(Cloud_Phase_Line_Items__c eachPhaseLineItem : accountLineItems){
            QuoteRevenueMonthForecastController.forecastWrapper newLineItem = new QuoteRevenueMonthForecastController.forecastWrapper();
            newLineItem.phase = 'Phase ' + eachPhaseLineItem.Cloud_Billing_Phase__r.Phase_Number__c;
            newLineItem.product = eachPhaseLineItem.Product_Name__c;
            newLineItem.quantity = eachPhaseLineItem.Quantity__c;
            newLineItem.revenue = eachPhaseLineItem.Revenue__c; 
            newLineItem.phaseLine = eachPhaseLineItem;      
            forecastLineItems.add(newLineItem);
        }
        return forecastLineItems;       
    }
    
    public static String getCurrentWeek(String period){
        List<Cloud_Forecast_Quarter__c> forecastWeeks = [Select id from Cloud_Forecast_Quarter__c 
            where active__c = true and quarter__c = :period AND Current_Week__c = true order by order__c desc];
        if(!forecastWeeks.isEmpty())
            return forecastWeeks[0].id;
        return null;
    }
    
    public static List<SelectOption> getWeeksForQuarter(String period){
        List<SelectOption> weeks = new List<SelectOption>();
        SelectOption newWeek = new SelectOption('','--None--');
        weeks.add(newWeek);
                
        if(period == null || period == '')
            return weeks;
        
        List<Cloud_Forecast_Quarter__c> forecastWeeks = [SELECT name,quarter__c,week_date__c,order__c, 
                                        active__c FROM Cloud_Forecast_Quarter__c WHERE active__c = TRUE AND quarter__c = :period ORDER BY Start_Date__c DESC]; 
        for(Cloud_Forecast_Quarter__c eachforecastWeek : forecastWeeks){
         
            String sDate = String.valueOf(eachforecastWeek.week_date__c);
            newWeek = new SelectOption(eachforecastWeek.id,eachforecastWeek.name);
            weeks.add(newWeek);
         }
        /*

        
        Integer quarter = Integer.valueOf(period.split('-')[0]);
        Integer year = Integer.valueOf(period.split('-')[1]);
        Integer month = 1;
        Integer year1 = year;
        Integer month1 = 4;
        if(quarter == 2){
            month = 4;
            month1 = 7;
        }
        else if(quarter == 3){
            month = 7;
            month1 = 10;
        }
        else if(quarter == 4){
            month = 10;
            month1 = 1;
            year1 ++;
        }
        Date startDate = Date.newInstance(year, month, 1);
        Date endDate = Date.newInstance(year1, month1, 1);
        System.debug('NKC debug startDate [' + startDate + ']');
        System.debug('NKC debug endDate [' + endDate + ']');    
        
        for(Date d = startDate ; d < endDate ; d = d.addDays(7)){
            
          String sDate = String.valueOf(d);
       
       
       /* } */
        return weeks;
    }
  
  
  public static List<SelectOption> getCSM(){
        List<SelectOption> csm = new List<SelectOption>();
        SelectOption newCsm = new SelectOption('','--None--');
        csm.add(newCsm);
                
        
        
        List<Account> csmWeek = [Select id,CSM_Account_Owner__r.Name from account where cloud_flag__c = true and CSM_Account_Owner__r.Name != null   order by CSM_Account_Owner__r.Name desc]; 
        
        for(Account  eachforecastWeek : csmWeek){
         
            newCsm = new SelectOption(eachforecastWeek.CSM_Account_Owner__r.Name,eachforecastWeek.CSM_Account_Owner__r.Name);
            csm.add(newCsm);
        
        
         }
  
     return csm;
     
    }
  
  
  
  
    
    public static void save(List<QuoteRevenueMonthForecastController.lineItemsWrapper> lineItems, String selectedWeek){
        //Date weekDate = date.valueOf(selectedWeek);
        String  weekDate = selectedWeek;
        String previousWeek = '';  
                 
        List <Cloud_Forecast_Quarter__c> currentWeek = [Select id,previous_week__c from Cloud_Forecast_Quarter__c where 
            id =:selectedWeek];
       
       for(Cloud_Forecast_Quarter__c eachWeek: currentWeek) 
         previousWeek = eachWeek.previous_week__c;        
        
        List<Account_Revenue_Forecast__c> accountRevForecastPreviousWeek = [SELECT id, Account__c, Status__c, Revenue__c, Commit__c, Land__c, Best__c,
           LastModifiedBy.Name, New_Logo_2016__c, Cloud_Platform_Type__c  
            FROM Account_Revenue_Forecast__c WHERE PE_SS_Flag__c = false AND Cloud_Forecast_Quarter__c =:previousWeek AND (Commit__c != 0 OR Land__c != 0 OR Best__c != 0)];
       
        Map<Id, Account_Revenue_Forecast__c> mapAccIdVsPrevWeekForecast = new Map<Id, Account_Revenue_Forecast__c>();
        for(Account_Revenue_Forecast__c eachARF : accountRevForecastPreviousWeek ){
            mapAccIdVsPrevWeekForecast.put(eachARF.Account__c, eachARF); 
            System.debug('NKC debug eachARF.Account__c [' + eachARF.Account__c + ']');                
        }
                
        //List<Account_Revenue_Forecast__c> accRevenueForecastsToBeDeleted = [SELECT id FROM Account_Revenue_Forecast__c WHERE PE_SS_Flag__c = false AND Week_Date__c =: weekDate ];
        //if(!accRevenueForecastsToBeDeleted.isEmpty())
        //   delete accRevenueForecastsToBeDeleted;
        List<Account_Revenue_Forecast__c> accRevenueForecastsToBeInserted = new List<Account_Revenue_Forecast__c>();
        Double commitQuantity = 0, landQuantity = 0, bestQuantity = 0;
        Double totalChangeLowQuantity=0,totalChangeLandQuantity=0,totalChangeBestQuantity=0, totalLastWeekLand=0,totalChange=0;
      
        QuoteRevenueMonthForecastController.lineItemsWrapper totalRecord;
        for(QuoteRevenueMonthForecastController.lineItemsWrapper eachLineItem : lineItems){            
            if(eachLineItem.isTotal){
                totalRecord = eachLineItem; 
                continue;
            }
            
            Account_Revenue_Forecast__c newARF;
            if(eachLineItem.record == null || eachLineItem.record.id == null)
                newARF = new Account_Revenue_Forecast__c();
            else
                newARF = new Account_Revenue_Forecast__c(id = eachLineItem.record.id);
            System.debug('NKC debug newARF.id ['+newARF.id+']');
            newARF.Account__c = eachLineItem.accountId;
            newARF.Revenue__c = eachLineItem.revenue;
            newARF.Commit__c = eachLineItem.commitQuantity;
            newARF.Land__c = eachLineItem.totalLand;
            newARF.Best__c = eachLineItem.bestQuantity;
            newARF.Cloud_Forecast_quarter__c = weekDate ;
            newARF.Status__c = eachLineItem.record.Status__c;
            newARF.New_Logo_2016__c = eachLineItem.record.New_Logo_2016__c;
            newARF.quota__c = eachLineItem.record.quota__c;
            newARF.Cloud_Platform_Type__c = eachLineItem.record.Cloud_Platform_Type__c;
            System.debug('NKC debug eachLineItem.subscriptionLand ['+eachLineItem.subscriptionLand+']');
            System.debug('NKC debug eachLineItem.psLand; ['+eachLineItem.psLand+']');
            newARF.Q4_2017_Land_Subs__c = eachLineItem.subscriptionLand;
            newARF.BQ3_PS_Land__c = eachLineItem.psLand;
            newARF.PS_Low__c = eachLineItem.psLow;
            newARF.Q4_2017_Low_Subs__c = eachLineItem.subscriptionLow;
            newARF.PS_Best__c = eachLineItem.psBest;
            newARF.Subscription_Best__c = eachLineItem.subscriptionBest;
            
            if(mapAccIdVsPrevWeekForecast.get(eachLineItem.accountId) != null)
              newARF.Previous_Week__c =  mapAccIdVsPrevWeekForecast.get(eachLineItem.accountId).id;
           
            eachLineItem.changeLandQuantity = (eachLineItem.previousLandQuantity == null || eachLineItem.landQuantity == null ? 0 : eachLineItem.landQuantity -eachLineItem.previousLandQuantity );
            eachLineItem.changeLowQuantity = (eachLineItem.previousLowQuantity == null || eachLineItem.commitQuantity == null ? 0 : eachLineItem.commitQuantity -eachLineItem.previousLowQuantity );
            eachLineItem.changeBestQuantity = (eachLineItem.previousBestQuantity == null || eachLineItem.bestQuantity == null? 0 : eachLineItem.bestQuantity -eachLineItem.previousBestQuantity );
                  
            commitQuantity += (eachLineItem.commitQuantity == null ? 0 : eachLineItem.commitQuantity);
            landQuantity += (eachLineItem.landQuantity == null ? 0 : eachLineItem.landQuantity);
            bestQuantity += (eachLineItem.bestQuantity == null ? 0 : eachLineItem.bestQuantity);

            totalChangeLowQuantity += eachLineItem.changeLowQuantity;
            totalChangeLandQuantity += eachLineItem.changeLandQuantity;
            totalChangeBestQuantity += eachLineItem.changeBestQuantity;
            totalLastWeekLand += eachLineItem.lastWeekLand;
            totalChange += eachLineItem.change;
            
            if(eachLineItem.selected)                
                accRevenueForecastsToBeInserted.add(newARF);
            eachLineItem.selected = false;
        }   
        totalRecord.commitQuantity = commitQuantity;
        totalRecord.landQuantity = landQuantity;
        totalRecord.bestQuantity = bestQuantity; 
    
    
        totalRecord.changeBestQuantity = totalChangeBestQuantity;  
        totalRecord.changeLowQuantity = totalChangeLowQuantity;    
        totalRecord.changeLandQuantity = totalChangeLandQuantity;  
        totalRecord.lastWeekLand = totalLastWeekLand;
        totalRecord.change = totalChange;
                
        if(!accRevenueForecastsToBeInserted.isEmpty()){
            upsert accRevenueForecastsToBeInserted;
        }
    }
}