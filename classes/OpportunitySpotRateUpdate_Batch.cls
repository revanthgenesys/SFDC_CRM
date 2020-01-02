global  class OpportunitySpotRateUpdate_Batch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        Id cloudRenewalRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cloud Renewal').getRecordTypeId();
        Id genRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
        List<string> lstRecordTypes = new List<string>{genRecordTypeId,genRecordTypeId};
        List<string> lstWinorLosss = new List<string>{'Lost','Merged/Dup Opp'};
        date dt = date.today()-30;
        date dt1 = date.today();
        String country = '\''+ 'USD' + '\'';String testID = '0060d00001uUTFe';
        String query = 'SELECT id,name,CloseDate,CurrencyIsoCode,Spot_Rate_from_Order__c,Spot_Rate__c' 
                        +' FROM opportunity where'
            			+' CurrencyIsoCode !='+country 
                        +' AND closedate != null' 
                        +' AND closedate >:dt and closedate <:dt1'
                        +' AND Win_Loss_Status__c  NOT IN :lstWinorLosss'
                        +' AND Spot_Rate__c = null'
                        +' AND Has_PS__c =false'
                        +' AND Cloud_Renewal__c =false'
                        +' AND amount !=0'
                        +' AND recordtypeId IN :lstRecordTypes'; 
        system.debug('query**** '+Database.query(query));
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<opportunity> oppList) {
       
        set<string> periodSet = new set<string>();
        set<string> currencyIsoSet = new set<string>();
        Map<string,ERP_Currency_Daily_Exchange_Rate__c> exchangeRateMap = new Map<string,ERP_Currency_Daily_Exchange_Rate__c>();
		
        for(opportunity objOpp :oppList){
           String strPeriod = objOpp.CloseDate.Month() + '-' + objOpp.CloseDate.Year();  
            periodSet.add(strPeriod);
            currencyIsoSet.add(objOpp.CurrencyIsoCode);
        }
        List<ERP_Currency_Daily_Exchange_Rate__c> listOfExchangeRate = [SELECT id,Period_Month_Year__c FROM ERP_Currency_Daily_Exchange_Rate__c
                                                                        WHERE Period_Month_Year__c IN : periodSet 
                                                                        AND FROM_CURRENCY_CODE__c IN: currencyIsoSet
                                                                        AND TO_CURRENCY_CODE__c = 'USD' 
                                                                        AND EXCHANGE_RATE_TYPE__c = 'FORECAST' 
                                                                        AND lastmodifieddate>2018-04-18T14:01:00-04:00];
     
        system.debug('listOfExchangeRate*****'+listOfExchangeRate);
        for(ERP_Currency_Daily_Exchange_Rate__c ECDER : listOfExchangeRate){
            exchangeRateMap.put(ECDER.Period_Month_Year__c,ECDER);
        }
        List<Opportunity> lstResultedOpps = new List<opportunity>();
        for(opportunity opp : oppList){
            String strPeriod = opp.CloseDate.Month() + '-' + opp.CloseDate.Year();
            if(exchangeRateMap.containsKey(strPeriod)){
                if(exchangeRateMap.get(strPeriod).Period_Month_Year__c == strPeriod){
                    opp.Spot_Rate__c=exchangeRateMap.get(strPeriod).Id;
                    lstResultedOpps.add(opp);
                }
            }
        }
        system.debug('lstResultedOpps***** '+lstResultedOpps);
        if(!lstResultedOpps.isEmpty()){
            update lstResultedOpps;
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
    	// execute any post-processing operations
  }

}