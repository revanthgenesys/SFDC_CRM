trigger PopulateERPCurrency on ERP_Currency_Daily_Exchange_Rate__c (before insert,before update) {

    if (Util.Bypass_Trigger_Chk) return;
    
    //Added by Priyank
    Map<Id, ERP_Currency_Daily_Exchange_Rate__c > oldMap = trigger.oldMap;
    Boolean blnBlackoutPeriod = CostCenterUtil.getBlackoutFlag();             
    for(ERP_Currency_Daily_Exchange_Rate__c eachCC : trigger.new){
        if(oldMap == null || (eachCC.Approval_Status__c == 'New' && oldMap.get(eachCC.id).Approval_Status__c != 'New')){
          eachCC.Blackout_Period__c = blnBlackoutPeriod;  
        }    
    }
    //Code Ended.
    
    //Set SFDC Record Name
    for(ERP_Currency_Daily_Exchange_Rate__c obj : trigger.new)
    {
        if(obj.Exchange_Rate_Source__c == 'User' || obj.Exchange_Rate_Source__c == 'Bloomberg')
        {
            Date d = obj.Effective_Date__c;
            String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('MMddYY');
            //obj.Effective_Date__c.format('MM/dd/yy')
            
            obj.Name = obj.EXCHANGE_RATE_TYPE__c+'_'+ dt +'_'+obj.FROM_CURRENCY_CODE__c+'_'+obj.TO_CURRENCY_CODE__c+'_'+obj.CONVERSION_RATE__c;
        } 
    }
    
    if(Trigger.isBefore ){
        if(Trigger.isUpdate){
            FinanceMDMTriggerHelper.preventRecordFromSameApprover(trigger.newMap);
            FinanceMDMTriggerHelper.populateCurrency_beforeUpdate(Trigger.oldMap,Trigger.newMap);
        }        
        if(Trigger.isInsert){
            FinanceMDMTriggerHelper.populateCurrency_beforeInsert(Trigger.new);
        }
    }
    
    
    //Unique Check
    // Exchange_Rate_Source__c != 'Xignite' condition added by Priyank (12/06/2018), request on Raj
    if(trigger.new.size() == 1 && trigger.new[0].Exchange_Rate_Source__c != 'Xignite')
    {
        ERP_Currency_Daily_Exchange_Rate__c obj = trigger.new[0];
        Date d = obj.Effective_Date__c;
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('YYYY-MM-dd');
            //obj.Effective_Date__c.format('MM/dd/yy')
            
        String UniQueKey = obj.EXCHANGE_RATE_TYPE__c+'_'+obj.FROM_CURRENCY_CODE__c+'_'+obj.TO_CURRENCY_CODE__c+'_'+dt;
         List<ERP_Currency_Daily_Exchange_Rate__c> duplicateRec = [select id from ERP_Currency_Daily_Exchange_Rate__c where Unique_Key__c =: UniQueKey  AND lastmodifieddate>2018-04-18T14:01:00-04:00 and ID != : obj.ID and owner.ID ='005U0000000fuzh'  LIMIT 1];       
          if(duplicateRec != null && duplicateRec.size() > 0)
            trigger.new[0].addError('Duplicate Record Found. Please check the comibation for Rate Type, Effective Date, From Currency and To Currency');

    }
    
    /*
    Set<String> set_RateType = new Set<String>();
    Set<String> set_FromCurr = new Set<String>();
    Set<String> set_ToCurr = new Set<String>();
    Set<Date> set_EffDate = new Set<Date>();
    Set<Id> recordId = new Set<id>();
    
    for(ERP_Currency_Daily_Exchange_Rate__c eachCC : trigger.new){
        set_RateType.add(eachCC.EXCHANGE_RATE_TYPE__c);
        set_FromCurr.add(eachCC.FROM_CURRENCY_CODE__c);
        set_ToCurr.add(eachCC.TO_CURRENCY_CODE__c);
        set_EffDate.add(eachCC.Effective_Date__c);
        if(trigger.oldMap != null){
            recordId.add(eachCC.Id);
        }
    }
    
    Set<String> set_UniqueStr = new Set<String>();
    if(trigger.oldMap != null){
        for(ERP_Currency_Daily_Exchange_Rate__c curr : [SELECT Id, EXCHANGE_RATE_TYPE__c, FROM_CURRENCY_CODE__c, TO_CURRENCY_CODE__c, Effective_Date__c 
                                                            FROM ERP_Currency_Daily_Exchange_Rate__c
                                                            WHERE EXCHANGE_RATE_TYPE__c IN: set_RateType
                                                            AND FROM_CURRENCY_CODE__c IN: set_FromCurr
                                                            AND TO_CURRENCY_CODE__c IN: set_ToCurr
                                                            AND Effective_Date__c IN: set_EffDate
                                                            AND Id NOT IN: recordId]){
            set_UniqueStr.add(curr.EXCHANGE_RATE_TYPE__c + '' + curr.Effective_Date__c + '' + curr.FROM_CURRENCY_CODE__c + '' + curr.TO_CURRENCY_CODE__c);
        }
    }
    else{
        for(ERP_Currency_Daily_Exchange_Rate__c curr : [SELECT Id, EXCHANGE_RATE_TYPE__c, FROM_CURRENCY_CODE__c, TO_CURRENCY_CODE__c, Effective_Date__c 
                                                            FROM ERP_Currency_Daily_Exchange_Rate__c
                                                            WHERE EXCHANGE_RATE_TYPE__c IN: set_RateType
                                                            AND FROM_CURRENCY_CODE__c IN: set_FromCurr
                                                            AND TO_CURRENCY_CODE__c IN: set_ToCurr
                                                            AND Effective_Date__c IN: set_EffDate]){
            set_UniqueStr.add(curr.EXCHANGE_RATE_TYPE__c + '' + curr.Effective_Date__c + '' + curr.FROM_CURRENCY_CODE__c + '' + curr.TO_CURRENCY_CODE__c);
        }
    }
    
    if(set_UniqueStr.size() > 0){
        for(ERP_Currency_Daily_Exchange_Rate__c eachCC : trigger.new){
            if(set_UniqueStr.contains(eachCC.EXCHANGE_RATE_TYPE__c + '' + eachCC.Effective_Date__c + '' + eachCC.FROM_CURRENCY_CODE__c + '' + eachCC.TO_CURRENCY_CODE__c)){
                eachCC.addError('Duplicate Record Found. Please check the comibation for Rate Type, Effective Date, From Currency and To Currency');
            }
        }
    }
    */
}