global with sharing class PESSRevenueForecastChangesCtlr {
    
    public String selectedWeek{get;set;}
    public String selectedOfferingType {get;set;}
    public String selectedyear{get;set;}
    public String accountId{get;set;}
    public String selectedWeekCompare{get;set;}
    public String uname{get;set;}
    public boolean makeCheckboxReadOnly{get;set;}
    
    public List<CommentWrapper> lstCommentWrapper{get;set;}
    
    global PESSRevenueForecastChangesCtlr(){
        if(ApexPages.currentPage().getParameters().get('accountId') != null)    
            accountId = ApexPages.currentPage().getParameters().get('accountId');
            
        if(ApexPages.currentPage().getParameters().get('year') != null)    
            selectedyear = ApexPages.currentPage().getParameters().get('year');
        
        if(ApexPages.currentPage().getParameters().get('OfferingType') != null)    
            selectedOfferingType = ApexPages.currentPage().getParameters().get('OfferingType');
        
        if(ApexPages.currentPage().getParameters().get('week') != null)    
            selectedWeek = ApexPages.currentPage().getParameters().get('week');
        
        if(selectedWeek != null){
            List<Cloud_Forecast_Quarter__c> cfq = [Select Id, Previous_Week__c from Cloud_Forecast_Quarter__c where Id =:selectedWeek];
            if(cfq.size() > 0){
                selectedWeekCompare = cfq[0].Previous_Week__c;
            }
        }
        /*Added in lines- 8&9- makeCheckboxReadOnly and user parameters to make the forecast page read-only and the below code from line 33-42 to query the list of users having read-only access- for incident-#INC0310589- Added by Subhashree Nanda on 18/12/19*/
        uname = UserInfo.getUserId();
        List<PermissionSetAssignment> checkboxReadonlyIds =[SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'View_Cloud_Revenue_Forecast'];
        makeCheckboxReadOnly=false;
        for(PermissionSetAssignment u: checkboxReadonlyIds)
        {
          if(uname==u.AssigneeId)
          {
           makeCheckboxReadOnly=true;
           }
        }
        
          
    }
    
      /**
    *   Method Name :   PopulatePeriod()
    *   Description :   This method used to Populate Period
    *   Parameters  :  
    **/
    @RemoteAction
    global  Static List<populatePeriod> PopulatePeriod(String selectedyear){
        List<populatePeriod> lstString = new List<populatePeriod>();
        
        if(selectedyear != ''){
            populatePeriod pp1 = new populatePeriod();
            pp1.itemValue = '1-'+selectedyear+'';
            pp1.itemLabel = 'Q1-'+selectedyear+'';
            lstString.add(pp1);
            
            populatePeriod pp2 = new populatePeriod();
            pp2.itemValue = '2-'+selectedyear+'';
            pp2.itemLabel = 'Q2-'+selectedyear+'';
            lstString.add(pp2);
            
            populatePeriod pp3 = new populatePeriod();
            pp3.itemValue = '3-'+selectedyear+'';
            pp3.itemLabel = 'Q3-'+selectedyear+'';
            lstString.add(pp3);
            
            populatePeriod pp4 = new populatePeriod();
            pp4.itemValue = '4-'+selectedyear+'';
            pp4.itemLabel = 'Q4-'+selectedyear+'';
            lstString.add(pp4);
        }
        return lstString;        
    }
    
    global Class populatePeriod{
        global String itemValue{get;set;}
        global String itemLabel{get;set;}
    }
    
     @RemoteAction
    global  Static List<CommentWrapper> getAccountRevenueRecordCompare(String OfferingType, String year, String week, String accounId, Boolean inval, String weekcompare){
      
        String rea = 'Change';
        List<CommentWrapper> lstCommentWrapper = new List<CommentWrapper>();
        
        // Current Week records
        String revenueForecastQuery = '  SELECT Account__c, Account__r.Name,  Account__r.PE_Platform__c, Account__r.CSM_Account_Owner__r.Name, Cloud_Platform_Type__c,Account__r.Region__c , ' +
                                      '  Account__r.Key_Account_Group__c, Account__r.PE_Status_type__c,Account__r.PE_Status__c,Account__r.Type, Partner_Account__c, Revenue_Type__c, LOB1__c, '+ 
                                      '  Cloud_Forecast_Quarter__r.Quarter__c,' +
                                      '  Q1_' + year + '_Land__c, Q2_' + year + '_Land__c, Q3_' + year + '_Land__c, Q4_' + year + '_Land__c,' +
                                      '  (SELECT Amount__c, Comment__c, Reason__c, Quarter__c, Quarter_Upside_Risk__c  FROM Account_Revenue_Forecast_Comments__r '+  
                                      '  where Reason__c =: rea )' +
                                          '  FROM Account_Revenue_Forecast__c' +           
                                      '  WHERE Offering_Type__c=:OfferingType and  Cloud_Forecast_Quarter__c =: week  and Account__c != null and LOB1__c != null ';
                                      
        if(accounId != '' && accounId != null){
            revenueForecastQuery += ' and Account__c =:accounId ORDER BY Account__r.Name ASC ';
        }else{
            revenueForecastQuery += ' ORDER BY Account__r.Name ASC ';
        }
        
        List<Account_Revenue_Forecast__c> accountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);  
        system.debug('accountRevenueForecast ' + accountRevenueForecast.size());
        
        // Compare week records
        String revenueForecastQueryCompare =  '  SELECT Account__c, Revenue_Type__c, Cloud_Forecast_Quarter__r.Quarter__c,LOB1__c,' +
                                              '  Q1_' + year + '_Land__c, Q2_' + year + '_Land__c, Q3_' + year + '_Land__c, Q4_' + year + '_Land__c' +
                                              '  FROM Account_Revenue_Forecast__c' +           
                                              '  WHERE Offering_Type__c=:OfferingType and  Cloud_Forecast_Quarter__c =: weekcompare and Account__c != null and LOB1__c != null ';
                                      
        if(accounId != '' && accounId != null){
            revenueForecastQueryCompare += ' and Account__c =:accounId ORDER BY Account__r.Name ASC ';
        }else{
            revenueForecastQueryCompare += ' ORDER BY Account__r.Name ASC ';
        }
        
        List<Account_Revenue_Forecast__c> accountRevenueForecastCompare = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQueryCompare);  
        
        Map<String, Account_Revenue_Forecast__c> mapKeyToARF = new Map<String, Account_Revenue_Forecast__c>();
        
        for(Account_Revenue_Forecast__c arf : accountRevenueForecastCompare){
            String key = arf.Account__c + arf.LOB1__c ;
            mapKeyToARF.put(key, arf);
        }
        system.debug('accountRevenueForecastCompare ' + accountRevenueForecastCompare.size());
        system.debug('accountRevenueForecastCompare ' + accountRevenueForecastCompare.size() + ' map Size ' + mapKeyToARF.keySet().Size());
        
        Map<String, List<Account_Revenue_Forecast_Comment__c>> mapForecast = new Map<String, List<Account_Revenue_Forecast_Comment__c>>();
        
        for(Account_Revenue_Forecast__c arf : accountRevenueForecast ){
            if(arf.Account_Revenue_Forecast_Comments__r.size() > 0){
                for(Account_Revenue_Forecast_Comment__c arfc : arf.Account_Revenue_Forecast_Comments__r){
                    String key = arf.Id + arfc.Quarter_Upside_Risk__c;
                    
                    if(mapForecast.containskey(key)){
                        List<Account_Revenue_Forecast_Comment__c> lstRec = mapForecast.get(key);
                        lstRec.add(arfc);
                        mapForecast.put(key, lstRec);
                    }else{
                        List<Account_Revenue_Forecast_Comment__c> lstRec = new List<Account_Revenue_Forecast_Comment__c>();
                        lstRec.add(arfc);
                        mapForecast.put(key, lstRec);
                    }
                }
            }
        }
        
        Decimal differThreshold  = getThresholdValue(OfferingType);
        
        if(inval){
            differThreshold = 1;
        }
        Integer i = 0;
        for(Account_Revenue_Forecast__c arf : accountRevenueForecast ){
            
            String keyval = arf.Account__c + arf.LOB1__c;
            
            if(mapKeyToARF.containsKey(keyval)){
                system.debug('IN PUT  ' + keyval);
                Account_Revenue_Forecast__c arfPrev = mapKeyToARF.get(keyval);
                
                Decimal q1Land = 0;
                Decimal q2Land = 0;
                Decimal q3Land = 0;
                Decimal q4Land = 0;
                
                Decimal q1LandPw = 0;
                Decimal q2LandPw = 0;
                Decimal q3LandPw = 0;
                Decimal q4LandPw = 0;
                
               
                if(arf.get('Q1_' + year + '_Land__c') != null){
                    q1Land = (Decimal)arf.get('Q1_' + year + '_Land__c');
                }
                if(arf.get('Q2_' + year + '_Land__c') != null){
                    q2Land = (Decimal)arf.get('Q2_' + year + '_Land__c');
                }
                if(arf.get('Q3_' + year + '_Land__c') != null){
                    q3Land = (Decimal)arf.get('Q3_' + year + '_Land__c');
                }
                if(arf.get('Q4_' + year + '_Land__c') != null){
                    q4Land = (Decimal)arf.get('Q4_' + year + '_Land__c');
                }
                
                if(arfPrev.get('Q1_' + year + '_Land__c') != null){
                    q1LandPw = (Decimal)arfPrev.get('Q1_' + year + '_Land__c');
                }
                if(arfPrev.get('Q2_' + year + '_Land__c') != null){
                    q2LandPw = (Decimal)arfPrev.get('Q2_' + year + '_Land__c');
                }
                if(arfPrev.get('Q3_' + year + '_Land__c') != null){
                    q3LandPw = (Decimal)arfPrev.get('Q3_' + year + '_Land__c');
                }
                if(arfPrev.get('Q4_' + year + '_Land__c') != null){
                    q4LandPw = (Decimal)arfPrev.get('Q4_' + year + '_Land__c');
                }
                
                
                Decimal q1LandDiff = (q1Land - q1LandPw).abs();
                Decimal q2LandDiff = (q2Land - q2LandPw).abs();
                Decimal q3LandDiff = (q3Land - q3LandPw).abs();
                Decimal q4LandDiff = (q4Land - q4LandPw).abs();
                
                // Q1 Land Change
                String mapKey1 = arf.Id + 'Change - Q1 - '+  year;
                if(q1Land != q1LandPw && q1LandDiff > differThreshold &&  !mapForecast.containskey(mapKey1)){
                    CommentWrapper cmentWrap = new CommentWrapper();
                    cmentWrap = getCommentWrapper(arf , i, '1-'+ year  , '1', year, q1LandPw, q1Land);
                    lstCommentWrapper.add(cmentWrap);
                    i++;
                }else if(mapForecast.containskey(mapKey1) && q1LandDiff > differThreshold ){
                    for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapKey1)){
                        CommentWrapper cmentWrap = new CommentWrapper();
                        cmentWrap = getCommentWrapperExist(arf , arfc, q1LandPw, q1Land);
                        lstCommentWrapper.add(cmentWrap);
                    }
                }
                
                // Q2 Land Change
                String mapKey2 = arf.Id + 'Change - Q2 - '+  year;
                if(q2Land != q2LandPw && q2LandDiff > differThreshold && !mapForecast.containskey(mapKey2)){
                    CommentWrapper cmentWrap = new CommentWrapper();
                    cmentWrap = getCommentWrapper(arf , i, '2-'+ year, '2', year, q2LandPw, q2Land);
                    lstCommentWrapper.add(cmentWrap);
                    i++;
                }else if(mapForecast.containskey(mapKey2) && q2LandDiff > differThreshold){
                    for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapKey2)){
                        CommentWrapper cmentWrap = new CommentWrapper();
                        cmentWrap = getCommentWrapperExist(arf , arfc, q2LandPw, q2Land);
                        lstCommentWrapper.add(cmentWrap);
                    }
                }
                
                // Q3 Land Change
                String mapKey3 = arf.Id + 'Change - Q3 - '+  year;
                if(q3Land != q3LandPw && q3LandDiff > differThreshold && !mapForecast.containskey(mapKey3)){
                    CommentWrapper cmentWrap = new CommentWrapper();
                    cmentWrap = getCommentWrapper(arf , i, '3-'+ year, '3', year, q3LandPw, q3Land);
                    lstCommentWrapper.add(cmentWrap);
                    i++;
                }else if(mapForecast.containskey(mapKey3) && q3LandDiff > differThreshold){
                    for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapKey3)){
                        CommentWrapper cmentWrap = new CommentWrapper();
                        cmentWrap = getCommentWrapperExist(arf , arfc, q3LandPw, q3Land);
                        lstCommentWrapper.add(cmentWrap);
                    }
                }
                
                // Q4 Land Change
                String mapKey4 = arf.Id + 'Change - Q4 - '+  year;
                
                if(q4Land != q4LandPw && q4LandDiff > differThreshold && !mapForecast.containskey(mapKey4)){
                    CommentWrapper cmentWrap = new CommentWrapper();
                    cmentWrap = getCommentWrapper(arf , i, '4-'+ year, '4', year, q4LandPw, q4Land);
                    lstCommentWrapper.add(cmentWrap);
                    i++;
                }else if(mapForecast.containskey(mapKey4) && q4LandDiff > differThreshold){
                    for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapKey4)){
                        CommentWrapper cmentWrap = new CommentWrapper();
                        cmentWrap = getCommentWrapperExist(arf , arfc, q4LandPw, q4Land);
                        lstCommentWrapper.add(cmentWrap);
                    }
                }
            }
        }
        
        if(lstCommentWrapper.size() > 0){
            return lstCommentWrapper;
        }
            
        return null;
    }
    
    
   /*@RemoteAction
    global  Static List<CommentWrapper> getAccountRevenueRecord(String OfferingType, String year, String week, String accounId, Boolean inval){
      
        String rea = 'Change';
        List<CommentWrapper> lstCommentWrapper = new List<CommentWrapper>();
        
        String revenueForecastQuery = '  SELECT Account__c, Account__r.Name,  Account__r.PE_Platform__c, Account__r.CSM_Account_Owner__r.Name, Cloud_Platform_Type__c,Account__r.Region__c, ' +
                                      '  Account__r.Key_Account_Group__c, Account__r.PE_Status_type__c,Account__r.PE_Status__c,Account__r.Type,   Revenue_Type__c, LOB1__c, '+ 
                                      '  Cloud_Forecast_Quarter__r.Quarter__c,' +
                                      '  Q1_' + year + '_Land__c, Q2_' + year + '_Land__c, Q3_' + year + '_Land__c, Q4_' + year + '_Land__c,' +
                                      '  Previous_Week__r.Q1_' + year + '_Land__c , Previous_Week__r.Q2_' + year + '_Land__c, Previous_Week__r.Q3_' + year + '_Land__c,'+
                                      '  Previous_Week__r.Q4_' + year + '_Land__c,' +
                                      '  (SELECT Amount__c, Comment__c, Reason__c, Quarter__c, Quarter_Upside_Risk__c  FROM Account_Revenue_Forecast_Comments__r '+  
                                      '  where Reason__c =: rea )' +
                                      '  FROM Account_Revenue_Forecast__c' +           
                                      '  WHERE Offering_Type__c=:OfferingType and  Cloud_Forecast_Quarter__c =: week '+
                                      '  and  Account__c != null and LOB1__c != null';
        
        if(accounId != '' && accounId != null){
            revenueForecastQuery += ' and Account__c =:accounId ORDER BY Account__r.Name ASC ';
        }else{
            revenueForecastQuery += ' ORDER BY Account__r.Name ASC ';
        }
        
        List<Account_Revenue_Forecast__c> accountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);  
        
        system.debug('accountRevenueForecast ' + accountRevenueForecast.size());
        
        Map<String, List<Account_Revenue_Forecast_Comment__c>> mapForecast = new Map<String, List<Account_Revenue_Forecast_Comment__c>>();
        
        for(Account_Revenue_Forecast__c arf : accountRevenueForecast ){
            if(arf.Account_Revenue_Forecast_Comments__r.size() > 0){
                for(Account_Revenue_Forecast_Comment__c arfc : arf.Account_Revenue_Forecast_Comments__r){
                    String key = arf.Id + arfc.Quarter_Upside_Risk__c;
                    
                    if(mapForecast.containskey(key)){
                        List<Account_Revenue_Forecast_Comment__c> lstRec = mapForecast.get(key);
                        lstRec.add(arfc);
                        mapForecast.put(key, lstRec);
                    }else{
                        List<Account_Revenue_Forecast_Comment__c> lstRec = new List<Account_Revenue_Forecast_Comment__c>();
                        lstRec.add(arfc);
                        mapForecast.put(key, lstRec);
                    }
                }
            }
        }
        
        Decimal differThreshold  = getThresholdValue(OfferingType);
        
        if(inval){
            differThreshold = 1;
        }
        Integer i = 0;
        
        for(Account_Revenue_Forecast__c arf : accountRevenueForecast ){
            
            Decimal q1Land = 0;
            Decimal q2Land = 0;
            Decimal q3Land = 0;
            Decimal q4Land = 0;
            
            Decimal q1LandPw = 0;
            Decimal q2LandPw = 0;
            Decimal q3LandPw = 0;
            Decimal q4LandPw = 0;
            
           
            if(arf.get('Q1_' + year + '_Land__c') != null){
                q1Land = (Decimal)arf.get('Q1_' + year + '_Land__c');
            }
            if(arf.get('Q2_' + year + '_Land__c') != null){
                q2Land = (Decimal)arf.get('Q2_' + year + '_Land__c');
            }
            if(arf.get('Q3_' + year + '_Land__c') != null){
                q3Land = (Decimal)arf.get('Q3_' + year + '_Land__c');
            }
            if(arf.get('Q4_' + year + '_Land__c') != null){
                q4Land = (Decimal)arf.get('Q4_' + year + '_Land__c');
            }
            
            
            if(arf.getSobject('Previous_Week__r').get('Q1_' + year + '_Land__c') != null){
                q1LandPw = (Decimal)arf.getSobject('Previous_Week__r').get('Q1_' + year + '_Land__c');
            }
            if(arf.getSobject('Previous_Week__r').get('Q2_' + year + '_Land__c') != null){
                q2LandPw = (Decimal)arf.getSobject('Previous_Week__r').get('Q2_' + year + '_Land__c');
            }
            if(arf.getSobject('Previous_Week__r').get('Q3_' + year + '_Land__c') != null){
                q3LandPw = (Decimal)arf.getSobject('Previous_Week__r').get('Q3_' + year + '_Land__c');
            }
            if(arf.getSobject('Previous_Week__r').get('Q4_' + year + '_Land__c') != null){
                q4LandPw = (Decimal)arf.getSobject('Previous_Week__r').get('Q4_' + year + '_Land__c');
            }
            
            Decimal q1LandDiff = (q1Land - q1LandPw).abs();
            Decimal q2LandDiff = (q2Land - q2LandPw).abs();
            Decimal q3LandDiff = (q3Land - q3LandPw).abs();
            Decimal q4LandDiff = (q4Land - q4LandPw).abs();
            
            // Q1 Land Change
            String mapKey1 = arf.Id + 'Change - Q1 - '+  year;
            if(q1Land != q1LandPw && q1LandDiff > differThreshold &&  !mapForecast.containskey(mapKey1)){
                system.debug('Q1 - Change New= '+mapKey1) ;
                CommentWrapper cmentWrap = new CommentWrapper();
                cmentWrap = getCommentWrapper(arf , i, '1-'+ year  , '1', year, q1LandPw, q1Land);
                lstCommentWrapper.add(cmentWrap);
                i++;
            }else if(mapForecast.containskey(mapKey1) && q1LandDiff > differThreshold ){
                system.debug('Q1 - Change Old= '+mapKey1) ;
                for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapKey1)){
                    CommentWrapper cmentWrap = new CommentWrapper();
                    cmentWrap = getCommentWrapperExist(arf , arfc, q1LandPw, q1Land);
                    lstCommentWrapper.add(cmentWrap);
                }
            }
            
            // Q2 Land Change
            String mapKey2 = arf.Id + 'Change - Q2 - '+  year;
            system.debug('Q2 - Change = '+mapKey2) ;
            if(q2Land != q2LandPw && q2LandDiff > differThreshold && !mapForecast.containskey(mapKey2)){
                system.debug('Q2 - Change New= '+mapKey2) ;
                CommentWrapper cmentWrap = new CommentWrapper();
                cmentWrap = getCommentWrapper(arf , i, '2-'+ year, '2', year, q2LandPw, q2Land);
                lstCommentWrapper.add(cmentWrap);
                i++;
            }else if(mapForecast.containskey(mapKey2) && q2LandDiff > differThreshold){
                system.debug('Q2 - Change Old= '+mapKey2) ;
                for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapKey2)){
                    CommentWrapper cmentWrap = new CommentWrapper();
                    cmentWrap = getCommentWrapperExist(arf , arfc, q2LandPw, q2Land);
                    lstCommentWrapper.add(cmentWrap);
                }
            }
            
            // Q3 Land Change
            String mapKey3 = arf.Id + 'Change - Q3 - '+  year;
            system.debug('Q3 - Change = '+mapKey3) ;
            if(q3Land != q3LandPw && q3LandDiff > differThreshold && !mapForecast.containskey(mapKey3)){
                system.debug('Q3 - Change New= '+mapKey3) ;
                CommentWrapper cmentWrap = new CommentWrapper();
                cmentWrap = getCommentWrapper(arf , i, '3-'+ year, '3', year, q3LandPw, q3Land);
                lstCommentWrapper.add(cmentWrap);
                i++;
            }else if(mapForecast.containskey(mapKey3) && q3LandDiff > differThreshold){
                system.debug('Q3 - Change Old= '+mapKey3) ;
                for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapKey3)){
                    CommentWrapper cmentWrap = new CommentWrapper();
                    cmentWrap = getCommentWrapperExist(arf , arfc, q3LandPw, q3Land);
                    lstCommentWrapper.add(cmentWrap);
                }
            }
            
            // Q4 Land Change
            String mapKey4 = arf.Id + 'Change - Q4 - '+  year;
            
            if(q4Land != q4LandPw && q4LandDiff > differThreshold && !mapForecast.containskey(mapKey4)){
                system.debug('Q4 - Change New = '+mapKey4) ;
                CommentWrapper cmentWrap = new CommentWrapper();
                cmentWrap = getCommentWrapper(arf , i, '4-'+ year, '4', year, q4LandPw, q4Land);
                lstCommentWrapper.add(cmentWrap);
                i++;
            }else if(mapForecast.containskey(mapKey4) && q4LandDiff > differThreshold){
                system.debug('Q4 - Change Old= '+mapKey4) ;
                for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapKey4)){
                    CommentWrapper cmentWrap = new CommentWrapper();
                    cmentWrap = getCommentWrapperExist(arf , arfc, q4LandPw, q4Land);
                    lstCommentWrapper.add(cmentWrap);
                }
            }
        }
        
        if(lstCommentWrapper.size() > 0){
            return lstCommentWrapper;
        }
        return null;
    }
    */
    public static CommentWrapper getCommentWrapper(Account_Revenue_Forecast__c arf, Integer i,  String quarter, String key, String year, Decimal oldval, Decimal newval ){
        CommentWrapper cment  = new CommentWrapper();
        cment.acntName = arf.Account__r.Name;
        cment.acntType = arf.Account__r.PE_Status_type__c;
        cment.acntCSM = arf.Account__r.CSM_Account_Owner__r.Name;
        cment.acntRType = arf.Revenue_Type__c;
        cment.actnPlatForm = arf.Cloud_Platform_Type__c;
        cment.acntRegion = arf.Account__r.Region__c;
        cment.lob = arf.LOB1__c;
        cment.comment = '';
        cment.oldChange = oldval;
        cment.newChange = newval;
        cment.amnt =  newval - oldval;
        cment.arfId = arf.Id;
        cment.arfcId =  '000' + '-' + i + '-' + arf.Id;
        cment.arfcoId = '000' + i;
        cment.isCreate = false;
        cment.reason = 'Change';
        cment.quarter = quarter;
        cment.riskUpsideShow = cment.reason +  ' - '+ 'Q' + Key + ' - ' +  year;
        //cment.changeShow = 'Q' + Key + ' - '+ cment.reason + ' - '+ year;
        
        return cment;
    }
    
    public static CommentWrapper getCommentWrapperExist(Account_Revenue_Forecast__c arf, Account_Revenue_Forecast_Comment__c arfc, Decimal oldval, Decimal newval){
        CommentWrapper cment  = new CommentWrapper();
        cment.acntName = arf.Account__r.Name;
        cment.acntType = arf.Account__r.PE_Status_type__c;
        cment.acntCSM = arf.Account__r.CSM_Account_Owner__r.Name;
        cment.acntRType = arf.Revenue_Type__c;
        cment.comment = arfc.Comment__c;
        cment.actnPlatForm = arf.Cloud_Platform_Type__c;
        cment.lob = arf.LOB1__c;
        cment.amnt = newval - oldval;
        cment.reason = arfc.Reason__c;
        cment.quarter = arfc.Quarter__c;
        cment.oldChange = oldval;
        cment.newChange = newval;
        cment.arfId = arf.Id;
        cment.arfcId = arfc.Id + '-' +arf.Id;
        cment.arfcoId = arfc.Id;
        cment.acntRegion = arf.Account__r.Region__c;
        cment.isCreate = true;
        cment.riskUpsideShow = arfc.Quarter_Upside_Risk__c;
        return cment;
    }
    
    /**
    *   Method Name :   getThresholdValue()
    *   Description :   This method used to get offeringType threshold value
    *   Parameters  :  
    **/
    
    public static Decimal getThresholdValue(String offeringType){
        
        Decimal offerTypeValue = 0;
        
        if(offeringType != ''){
            Offering_Type_Settings__c offerType = Offering_Type_Settings__c.getValues(offeringType);
            if(offerType != null && offerType.Land_Diff_Amount__c != null){
                offerTypeValue = (Decimal)offerType.Land_Diff_Amount__c;
            }
        }
        
        return offerTypeValue;
    }
    
    @RemoteAction
    global  Static String saveARF(String grid ,  String setOfIds){
        system.debug('<><>> '+ setOfIds);
        system.debug('<><>>GRID '+ grid);   
            if(grid != null){
                List<Account_Revenue_Forecast_Comment__c> lstARFCInsert = new List<Account_Revenue_Forecast_Comment__c>();
                List<Account_Revenue_Forecast_Comment__c> lstARFCUpdated = new List<Account_Revenue_Forecast_Comment__c>();
                
                List<CommentWrapper> response = (List<CommentWrapper>)JSON.deserialize(grid, List<CommentWrapper>.class);
                
                for(CommentWrapper cmentnew : response){
                    
                    String str = cmentnew.arfcId;
                    List<String> lststr = str.split('-');
                    system.debug('ARFComment Id '+ lststr[0]);
                    system.debug('ARF Id '+ lststr[1]);
                    
                    Account_Revenue_Forecast_Comment__c arfc = new Account_Revenue_Forecast_Comment__c();
                    arfc.Amount__c =  cmentnew.amnt;
                    arfc.Quarter__c =  cmentnew.quarter;
                    arfc.Reason__c =  cmentnew.reason;
                    arfc.Comment__c =  cmentnew.comment;
                    arfc.Quarter_Upside_Risk__c =  cmentnew.riskUpsideShow;
                    if(lststr[0] != '000'){
                        arfc.Id  = lststr[0];
                        lstARFCUpdated.add(arfc);
                    }else{
                        arfc.Account_Revenue_Forecast__c =lststr[2];
                        lstARFCInsert.add(arfc);
                    }
                }
                
                system.debug('lstARFCUpdated ='+ lstARFCUpdated.size());
                if(lstARFCUpdated.size() > 0){
                    update  lstARFCUpdated;
                }
                system.debug('lstARFCInsert ='+ lstARFCInsert.size());
                if(lstARFCInsert.size() > 0){
                    insert  lstARFCInsert;
                    system.debug('lstARFCInsert ='+ lstARFCInsert[0].Id);
                }
            }
        return null;        
    }
    
    /**
    *   Method Name :   populateWeek()
    *   Description :   This method used to Populate Period
    *   Parameters  :  
    **/
    @RemoteAction
    global  Static List<populateWeekWrapper> populateWeek(){
        
        List<populateWeekWrapper> lstwrapper = new List<populateWeekWrapper>();
        populateWeekWrapper pp1 = new populateWeekWrapper();
        pp1.itemValue = '';
        pp1.itemLabel = '-- Week --';
        lstwrapper.add(pp1);   
        List<Cloud_Forecast_Quarter__c> forecastWeeks = [SELECT name,quarter__c,week_date__c,order__c, 
                                                                active__c FROM Cloud_Forecast_Quarter__c WHERE active__c = TRUE ORDER BY End_Date__c DESC limit 12]; 
        for(Cloud_Forecast_Quarter__c eachforecastWeek : forecastWeeks){
            populateWeekWrapper pp = new populateWeekWrapper();
            pp.itemValue = eachforecastWeek.id;
            pp.itemLabel = eachforecastWeek.name;
            lstwrapper.add(pp);
         }
        return lstwrapper;        
    }
    
    global Class populateWeekWrapper{
        global String itemValue{get;set;}
        global String itemLabel{get;set;}
    }
    
    global class CommentWrapper {
        public String acntName{get;set;}
        public String acntType{get;set;}
        public String acntCSM{get;set;}
        public String acntRType{get;set;}
        public String actnPlatForm{get;set;}
        public String reason{get;set;}
        public String quarter{get;set;}
        public String comment{get;set;}
        public Decimal amnt{get;set;}
        public Decimal oldChange{get;set;}
        public Decimal newChange{get;set;}
        public String arfcId{get;set;}
        public String arfcoId{get;set;}
        public String arfId{get;set;}
        public Boolean isCreate{get;set;}
        public String riskUpsideShow{get;set;}
        public String acntRegion{get;set;}
        public String lob{get;set;}
    }
}