global with sharing class PESSRevenueForecastCtlrView {
    
    public String selectedQuarter {get;set;}
    public String selectedWeek{get;set;}
    public String selectedOfferingType {get;set;}
    public String selectedyear{get;set;}
    public String accountId{get;set;}
    
    public List<CommentWrapper> lstCommentWrapper{get;set;}
    
    public String uname{get;set;}
    public boolean makeCheckboxReadOnly{get;set;}
    
    global PESSRevenueForecastCtlrView(){
        if(ApexPages.currentPage().getParameters().get('accountId') != null)    
            accountId = ApexPages.currentPage().getParameters().get('accountId');
        
        if(ApexPages.currentPage().getParameters().get('year') != null)    
            selectedyear = ApexPages.currentPage().getParameters().get('year');
        
        if(ApexPages.currentPage().getParameters().get('OfferingType') != null)    
            selectedOfferingType = ApexPages.currentPage().getParameters().get('OfferingType');
        
        if(ApexPages.currentPage().getParameters().get('week') != null)    
            selectedWeek = ApexPages.currentPage().getParameters().get('week');
            
        selectedQuarter = selectCurrentQuarter();
        
        system.debug('quarter = '+selectedQuarter);
        if(selectedQuarter == null ||  selectedQuarter == ''){
            selectedQuarter = '1-'+selectedyear;
        }
        uname = UserInfo.getUserId();
        /*Added in line- 12- makeCheckboxReadOnly parameter to make the forecast page read-only and the below code from line 35-43 to query the list of users having read-only access- for incident-#INC0310589- Added by Subhashree Nanda on 18/12/19*/
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
    
    @RemoteAction
    global static List<populateCSM> populateCSMOwner(String offeringType, String selectedyear, String selectedWeek){
        
        List<populateCSM> lstCSM = new List<populateCSM>();
        populateCSM csma = new populateCSM();
        csma.itemValue = 'All';
        csma.itemLabel = 'All';
        lstCSM.add(csma);
        String revenueForecastQuery = 'SELECT id, Name, CSM_Account_Owner__c, CSM_Account_Owner__r.Name FROM Account WHERE ' + 
                                        ' Id IN (SELECT Account__c FROM Account_Revenue_Forecast__c WHERE Cloud_Forecast_Quarter__c =: selectedWeek';
       
        revenueForecastQuery    += ' and  Offering_Type__c =: offeringType ) ORDER BY CSM_Account_Owner__r.Name ASC';
        List<Account> lstAccountRevenueForecast = (List<Account>)Database.query(revenueForecastQuery);
        
        Map<String, String> mapIdToName = new Map<String, String>();
        for(Account arf : lstAccountRevenueForecast){
            if(arf.CSM_Account_Owner__c != null){
                mapIdToName.put(arf.CSM_Account_Owner__c, arf.CSM_Account_Owner__r.Name);
            }
        }
        if(mapIdToName != null){
            for(String st : mapIdToName.keyset()){
                populateCSM csm = new populateCSM();
                csm.itemValue = st;
                csm.itemLabel = mapIdToName.get(st);
                lstCSM.add(csm);
            }
        }
        
        return lstCSM;
    }
    
    @RemoteAction
    global static Boolean checkCSMOwner(String offeringType, String selectedyear, String selectedWeek){
        
        Boolean checkCSM = false;
        
        List<User> lstUser = [Select Id, Is_Manager__c from User where Id =: UserInfo.getUserId()];
        String revenueForecastQuery = 'SELECT id, Name, CSM_Account_Owner__c, CSM_Account_Owner__r.Name FROM Account WHERE ' + 
                                        ' Id IN (SELECT Account__c FROM Account_Revenue_Forecast__c WHERE Cloud_Forecast_Quarter__c =: selectedWeek';
       
        revenueForecastQuery    += ' and  Offering_Type__c =: offeringType ) ORDER BY CSM_Account_Owner__r.Name ASC';
        List<Account> lstAccountRevenueForecast = (List<Account>)Database.query(revenueForecastQuery);
        
        Map<String, String> mapIdToName = new Map<String, String>();
        for(Account arf : lstAccountRevenueForecast){
            if(arf.CSM_Account_Owner__c != null && arf.CSM_Account_Owner__c ==  UserInfo.getUserId() && lstUser.size() > 0 && !lstUser[0].Is_Manager__c){
                checkCSM = true;
            }
        }
        
        return checkCSM;
    }
    
    global class populateCSM{
        global String itemValue{get;set;}
        global String itemLabel{get;set;}
    }
    
    @RemoteAction
    global  Static List<CommentWrapper> getAccountRevenueRecord(String OfferingType, String year, String quarter, String week, String accounId, String csmSelect){
        
        system.debug('Quarter ' + quarter);
        List<CommentWrapper> lstCommentWrapper = new List<CommentWrapper>();
        
        String revenueForecastQuery ='SELECT Account__c,Offering_Type__c, Account__r.Name, Account__r.Region__c, Account__r.PE_Platform__c, Account__r.CSM_Account_Owner__r.Name,Cloud_Platform_Type__c, '+
            '  Account__r.Key_Account_Group__c, Account__r.PE_Status_type__c,Account__r.PE_Status__c,Account__r.Type,   Revenue_Type__c,LOB_O__c, Cloud_Forecast_Quarter__r.Quarter__c,Partner_Account__r.Name,' +
            '  Q1_' + year + '_Low__c, Q2_' + year + '_Low__c, Q3_' + year + '_Low__c, Q4_' + year + '_Low__c,' +
            '  Q1_' + year + '_Best__c, Q2_' + year + '_Best__c, Q3_' + year + '_Best__c, Q4_' + year + '_Best__c,' +
            ' (SELECT Account_Formula__c, Amount__c, By_Whom__c, By_When__c, Comment__c,Is_Clone__c, '+
            ' Reason__c, Whats_Needed__c, Likely__c, Weight_Avg__c, Quarter__c ,Quarter_Upside_Risk__c, Is_Changed__c FROM Account_Revenue_Forecast_Comments__r ';
            
            if(quarter != 'All'){ 
                revenueForecastQuery += ' where Quarter__c =:quarter)';
            }else{
                revenueForecastQuery += ')';
            }  
            
            revenueForecastQuery += ' FROM Account_Revenue_Forecast__c' +           
                                    ' WHERE Offering_Type__c=:OfferingType and  Cloud_Forecast_Quarter__c =: week ' ;
       
       if(csmSelect != 'All'){
            revenueForecastQuery    += ' and  Account__r.CSM_Account_Owner__c =: csmSelect';
        }
        if(accounId != '' && accounId != null){
            revenueForecastQuery += ' and Account__c =:accounId ORDER BY Account__r.Name ASC ';
        }else{
            revenueForecastQuery += ' ORDER BY Account__r.Name ASC ';
        }
        
        system.debug('Query == ' +revenueForecastQuery);
        List<Account_Revenue_Forecast__c> accountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);  
        
        
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
        
        Decimal qRiskThreshold  = getThresholdValue(OfferingType, 'Risk');
        Decimal qUpsideThreshold  = getThresholdValue(OfferingType, 'Upside');
        
        Integer i = 0;
        Integer j = 0;
        // This will  print as 1-2017
        String quart = quarter;
        
        // This will print as 1
        String key = quart.substring(0,1);
        
        Boolean  isQuarter = getQuartersetting(OfferingType);
        for(Account_Revenue_Forecast__c arf : accountRevenueForecast ){
            
            Decimal q1Risk = 0;
            Decimal q2Risk = 0;
            Decimal q3Risk = 0;
            Decimal q4Risk = 0;
            
            if(arf.get('Q1_' + year + '_Low__c') != null){
                q1Risk = (Decimal)arf.get('Q1_' + year + '_Low__c');
            }
            if(arf.get('Q2_' + year + '_Low__c') != null){
                q2Risk = (Decimal)arf.get('Q2_' + year + '_Low__c');
            }
            if(arf.get('Q3_' + year + '_Low__c') != null){
                q3Risk = (Decimal)arf.get('Q3_' + year + '_Low__c');
            }
            if(arf.get('Q4_' + year + '_Low__c') != null){
                q4Risk = (Decimal)arf.get('Q4_' + year + '_Low__c');
            }
            
            Decimal q1Upside = 0;
            Decimal q2Upside = 0;
            Decimal q3Upside = 0;
            Decimal q4Upside = 0;
            
            if(arf.get('Q1_' + year + '_Best__c') != null){
                q1Upside = (Decimal)arf.get('Q1_' + year + '_Best__c');
            }
            if(arf.get('Q2_' + year + '_Best__c') != null){
                q2Upside = (Decimal)arf.get('Q2_' + year + '_Best__c');
            }
            if(arf.get('Q3_' + year + '_Best__c') != null){
                q3Upside = (Decimal)arf.get('Q3_' + year + '_Best__c');
            }
            if(arf.get('Q4_' + year + '_Best__c') != null){
                q4Upside = (Decimal)arf.get('Q4_' + year + '_Best__c');
            }
            
            if(!isQuarter){
                Decimal q1UpsideROY = q2Upside + q3Upside + q4Upside;
                Decimal q2UpsideROY = q3Upside + q4Upside;
                Decimal q3UpsideROY = q4Upside;
                
                Decimal q1RiskROY = q2Risk + q3Risk + q4Risk;
                Decimal q2RiskROY = q3Risk + q4Risk;
                Decimal q3RiskROY = q4Risk;
                
                String mapcurrentRiskKey = arf.Id + 'Risk - Q' + key + ' - ' + year;
                String mapROYRiskKey = arf.Id + 'Risk - ROY - ' + year;
                String mapCurrentUpsideKey = arf.Id + 'Upside - Q' + key + ' - ' + year;
                String mapROYUpsideKey = arf.Id + 'Upside - ROY - ' + year;
                
                if(key == '1'){
                    if(q1Risk > qRiskThreshold){
                        if(mapForecast.keyset().size() > 0  &&  mapForecast.containskey(mapcurrentRiskKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapcurrentRiskKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Risk', q1Risk , q2Risk, q3Risk, q4Risk , true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    if(q1Upside > qUpsideThreshold){
                        if(mapForecast.keyset().size() > 0  && mapForecast.containskey(mapCurrentUpsideKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapCurrentUpsideKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Upside', q1Upside , q2Upside, q3Upside, q4Upside, true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    if(q1RiskROY > qRiskThreshold){
                        if(mapForecast.keyset().size() > 0  &&  mapForecast.containskey(mapROYRiskKey)){
                            system.debug('Got RiskROY = ') ;
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapROYRiskKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Risk', q1RiskROY , q2RiskROY, q3RiskROY, 0 ,false);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    if(q1UpsideROY > qUpsideThreshold){
                        if(mapForecast.keyset().size() > 0  && mapForecast.containskey(mapROYUpsideKey)){
                            system.debug('Key Upside ROY = '+Key) ;
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapROYUpsideKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                             
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Upside', q1UpsideROY , q2UpsideROY, q3UpsideROY, 0, false);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                }
                
                if(key == '2'){
                    if(q2Risk > qRiskThreshold){
                        if(mapForecast.keyset().size() > 0  &&  mapForecast.containskey(mapcurrentRiskKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapcurrentRiskKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Risk', q1Risk , q2Risk, q3Risk, q4Risk , true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    if(q2Upside > qUpsideThreshold){
                        if(mapForecast.keyset().size() > 0  && mapForecast.containskey(mapCurrentUpsideKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapCurrentUpsideKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Upside', q1Upside , q2Upside, q3Upside, q4Upside, true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    if(q2RiskROY > qRiskThreshold){
                        if(mapForecast.keyset().size() > 0  &&  mapForecast.containskey(mapROYRiskKey)){
                            system.debug('Got RiskROY = ') ;
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapROYRiskKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Risk', q1RiskROY , q2RiskROY, q3RiskROY, 0 ,false);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    if(q2UpsideROY > qUpsideThreshold){
                        if(mapForecast.keyset().size() > 0  && mapForecast.containskey(mapROYUpsideKey)){
                            system.debug('Key Upside ROY = '+Key) ;
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapROYUpsideKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                             
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Upside', q1UpsideROY , q2UpsideROY, q3UpsideROY, 0, false);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                }
                
                if(key == '3'){
                    if(q3Risk > qRiskThreshold){
                        if(mapForecast.keyset().size() > 0  &&  mapForecast.containskey(mapcurrentRiskKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapcurrentRiskKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Risk', q1Risk , q2Risk, q3Risk, q4Risk , true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    if(q3Upside > qUpsideThreshold){
                        if(mapForecast.keyset().size() > 0  && mapForecast.containskey(mapCurrentUpsideKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapCurrentUpsideKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Upside', q1Upside , q2Upside, q3Upside, q4Upside, true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    if(q3RiskROY > qRiskThreshold){
                        if(mapForecast.keyset().size() > 0  &&  mapForecast.containskey(mapROYRiskKey)){
                            system.debug('Got RiskROY = ') ;
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapROYRiskKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Risk', q1RiskROY , q2RiskROY, q3RiskROY, 0 ,false);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    if(q3UpsideROY > qUpsideThreshold){
                        if(mapForecast.keyset().size() > 0  && mapForecast.containskey(mapROYUpsideKey)){
                            system.debug('Key Upside ROY = '+Key) ;
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapROYUpsideKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                             
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Upside', q1UpsideROY , q2UpsideROY, q3UpsideROY, 0, false);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                }
                
                if(key == '4'){
                    if(q4Risk > qRiskThreshold){
                        if(mapForecast.keyset().size() > 0  &&  mapForecast.containskey(mapcurrentRiskKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapcurrentRiskKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Risk', q1Risk , q2Risk, q3Risk, q4Risk , true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    if(q4Upside > qUpsideThreshold){
                        if(mapForecast.keyset().size() > 0  && mapForecast.containskey(mapCurrentUpsideKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(mapCurrentUpsideKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, key, quarter, 'Upside', q1Upside , q2Upside, q3Upside, q4Upside, true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                }
                
                
                
            }else{
                String q1RKey = arf.Id + 'Risk - Q1 - ' + year;
                String q2RKey = arf.Id + 'Risk - Q2 - ' + year;
                String q3RKey = arf.Id + 'Risk - Q3 - ' + year;
                String q4RKey = arf.Id + 'Risk - Q4 - ' + year;
                
                String q1UKey = arf.Id + 'Upside - Q1 - ' + year;
                String q2UKey = arf.Id + 'Upside - Q2 - ' + year;
                String q3UKey = arf.Id + 'Upside - Q3 - ' + year;
                String q4UKey = arf.Id + 'Upside - Q4 - ' + year;
                
                Boolean isQuart = false;
                if(quarter == 'All'){
                    isQuart = true;
                }
                
                if(isQuart){
                    key = '1';
                }
                
                if(key == '1'){
                    // Q1 Risk
                    if(q1Risk > qRiskThreshold){
                        if(mapForecast.keyset().size() > 0  &&  mapForecast.containskey(q1RKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(q1RKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, '1', '1-' + year, 'Risk', q1Risk , q2Risk, q3Risk, q4Risk , true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                
                    // Q1 Upside
                    if(q1Upside > qUpsideThreshold){
                        if(mapForecast.keyset().size() > 0  && mapForecast.containskey(q1UKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(q1UKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, '1', '1-' + year, 'Upside', q1Upside , q2Upside, q3Upside, q4Upside, true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                }
                
                if(isQuart){
                    key = '2';
                }
                
                if(key == '2'){
                    // Q2 Risk
                    if(q2Risk > qRiskThreshold){
                        if(mapForecast.keyset().size() > 0  &&  mapForecast.containskey(q2RKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(q2RKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else {
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, '2', '2-' + year, 'Risk', q1Risk , q2Risk, q3Risk, q4Risk , true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    // Q2 Upside
                    if(q2Upside > qUpsideThreshold){
                        if(mapForecast.keyset().size() > 0  && mapForecast.containskey(q2UKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(q2UKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, '2', '2-' + year, 'Upside', q1Upside , q2Upside, q3Upside, q4Upside, true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                
                }
                
                if(isQuart){
                    key = '3';
                }
                
                if(key == '3'){
                    // Q3 Risk
                    if(q3Risk > qRiskThreshold){
                        if(mapForecast.keyset().size() > 0  &&  mapForecast.containskey(q3RKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(q3RKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, '3', '3-' + year, 'Risk', q1Risk , q2Risk, q3Risk, q4Risk , true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    // Q3 Upside
                    if(q3Upside > qUpsideThreshold){
                        if(mapForecast.keyset().size() > 0  && mapForecast.containskey(q3UKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(q3UKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, '3', '3-' + year, 'Upside', q1Upside , q2Upside, q3Upside, q4Upside, true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                }
                
                if(isQuart){
                    key = '4';
                }
                
                if(key == '4'){
                    // Q4 Risk
                    if(q4Risk > qRiskThreshold){
                        if(mapForecast.keyset().size() > 0  &&  mapForecast.containskey(q4RKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(q4RKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, '4', '4-' + year, 'Risk', q1Risk , q2Risk, q3Risk, q4Risk , true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                    
                    // Q4 Upside
                    if(q4Upside > qUpsideThreshold){
                        if(mapForecast.keyset().size() > 0  && mapForecast.containskey(q4UKey)){
                            for(Account_Revenue_Forecast_Comment__c arfc : mapForecast.get(q4UKey)){
                                CommentWrapper current = new CommentWrapper();
                                current = getCommentWrapperExist(arf, arfc);
                                lstCommentWrapper.add(current);
                            }
                        }else{
                            CommentWrapper current = new CommentWrapper();
                            current = getCommentWrapper(arf, i , year, '4', '4-' + year, 'Upside', q1Upside , q2Upside, q3Upside, q4Upside, true);
                            lstCommentWrapper.add(current);
                            i++;
                        }
                    }
                }
            }
        }
        if(lstCommentWrapper.size() > 0){
            return lstCommentWrapper;
        }
        return null;
    }
    
    
    global static CommentWrapper getCommentWrapper(Account_Revenue_Forecast__c arf, Integer i ,String year, String key , String quarter, String reason, Decimal q1, Decimal q2, Decimal q3, Decimal q4, Boolean currentROY){
        
        if(arf != null){
            
            CommentWrapper cmentnew = new CommentWrapper();
            cmentnew.acntName = arf.Account__r.Name;
            cmentnew.partnerAccount = arf.Partner_Account__r.Name;
            cmentnew.acntType = arf.Account__r.PE_Status_type__c;
            cmentnew.acntRegion = arf.Account__r.Region__c;
            cmentnew.acntCSM = arf.Account__r.CSM_Account_Owner__r.Name;
            cmentnew.acntRType = arf.Revenue_Type__c;
            cmentnew.acntPlatformType =  arf.Cloud_Platform_Type__c;
            cmentnew.acntOfferingType = arf.Offering_Type__c;
            cmentnew.whatsNeeded = '';
            cmentnew.fromHome = '';
            //cmentnew.byWhen = String.valueOf(Date.today());
            cmentnew.likely = 0;
            cmentnew.wtAvg = 0;
            cmentnew.comment = '';
            cmentnew.arfId = arf.Id;
            cmentnew.arfcId =  '000' + '-' + i + '-' + arf.Id;
            cmentnew.arfcoId = '000' + i;
            cmentnew.isCreate = false;
            cmentnew.isChanged = false;
            cmentnew.reason = reason;
            cmentnew.isCloned = false;
            cmentnew.quarter = quarter;
            if(currentROY){
                cmentnew.riskUpside = cmentnew.reason + ' - ' + 'Q' + key + ' - '  + year;
                system.debug('AmountCurrent = q1 = ' + q1 +  ' q2 = ' + q2 +   ' q3 = ' + q3 + ' q4 = ' + q4) ;
                if(key == '1'){
                    cmentnew.amnt = q1;
                }else if(key == '2'){
                    cmentnew.amnt = q2;
                }else if(key == '3'){
                    cmentnew.amnt = q3;
                }else if(key == '4'){
                    cmentnew.amnt = q4;
                }
            }else{
                cmentnew.riskUpside = cmentnew.reason + ' - ' + 'ROY - ' + year;
                system.debug('AmountROY = q1 = ' + q1 +  ' q2 = ' + q2 +   ' q3 = ' + q3 + ' q4 = ' + q4) ;
                if(key == '1'){
                    cmentnew.amnt = q1;
                }else if(key == '2'){
                    cmentnew.amnt = q2;
                }else if(key == '3'){
                    cmentnew.amnt = q3;
                }
            }
            return cmentnew;
        }
        
        return null;
    }
    
    global static CommentWrapper getCommentWrapperExist(Account_Revenue_Forecast__c arf, Account_Revenue_Forecast_Comment__c arfc ){
        
        if(arf.Account_Revenue_Forecast_Comments__r.size() > 0){
            CommentWrapper cmentnew = new CommentWrapper();
            cmentnew.acntName = arf.Account__r.Name;
            cmentnew.partnerAccount = arf.Partner_Account__r.Name;
            cmentnew.acntType = arf.Account__r.PE_Status_type__c;
            cmentnew.acntRegion = arf.Account__r.Region__c;
            cmentnew.acntCSM = arf.Account__r.CSM_Account_Owner__r.Name;
            cmentnew.acntRType = arf.Revenue_Type__c;
            cmentnew.whatsNeeded = arfc.Whats_Needed__c;
            cmentnew.fromHome = arfc.By_Whom__c;
            cmentnew.acntPlatformType =  arf.Cloud_Platform_Type__c;
            cmentnew.acntOfferingType = arf.Offering_Type__c;
            cmentnew.comment = arfc.Comment__c;
            if(arfc.By_When__c != null){
                cmentnew.byWhen = String.valueOf(arfc.By_When__c);
            }else{
             //    cmentnew.byWhen = String.valueOf(Date.today());
            }
            if(arfc.Likely__c != null){
                cmentnew.likely = arfc.Likely__c;
            }else{
                cmentnew.likely = 0;
            }
            if(arfc.Weight_Avg__c != null){
                cmentnew.wtAvg = arfc.Weight_Avg__c;
            }else{
                cmentnew.wtAvg = 0;
            }
            if(arfc.Amount__c != null){
                //cmentnew.amnt = arfc.Amount__c; //Commented by Priyank in 14Feb2018.
                cmentnew.amnt = arfc.Account_Formula__c;
            }else{
                cmentnew.amnt = 0;
            }
            cmentnew.reason = arfc.Reason__c;
            cmentnew.quarter = arfc.Quarter__c;
            cmentnew.arfId = arf.Id;
            cmentnew.arfcId = arfc.Id + '-' +arf.Id;
            cmentnew.arfcoId = arfc.Id;
            cmentnew.riskUpside = arfc.Quarter_Upside_Risk__c;
            cmentnew.isCreate = true;
            cmentnew.isChanged = arfc.Is_Changed__c;
            cmentnew.isCloned = arfc.Is_Clone__c;
            return cmentnew;
        }
        
        return null;
    }
    
     /**
    *   Method Name :   PopulatePeriod()
    *   Description :   This method used to Populate Period
    *   Parameters  :  
    **/
    @RemoteAction
    global  Static List<populatePeriod> PopulatePeriod(String selectedyear,String OfferingType){
        system.debug('>>>> selectedyear ' +selectedyear);
        List<populatePeriod> lstString = new List<populatePeriod>();
        
        Boolean  isQuarter = getQuartersetting(OfferingType);
        if(isQuarter){
            populatePeriod pp1 = new populatePeriod();
            pp1.itemValue = 'All';
            pp1.itemLabel = 'All';
            lstString.add(pp1);
        }
        if(selectedyear != ''){
            populatePeriod pp1 = new populatePeriod();
            pp1.itemValue = '1-'+selectedyear;
            pp1.itemLabel = 'Q1-'+selectedyear;
            lstString.add(pp1);
            
            populatePeriod pp2 = new populatePeriod();
            pp2.itemValue = '2-'+selectedyear;
            pp2.itemLabel = 'Q2-'+selectedyear;
            lstString.add(pp2);
            
            populatePeriod pp3 = new populatePeriod();
            pp3.itemValue = '3-'+selectedyear;
            pp3.itemLabel = 'Q3-'+selectedyear;
            lstString.add(pp3);
            
            populatePeriod pp4 = new populatePeriod();
            pp4.itemValue = '4-'+selectedyear;
            pp4.itemLabel = 'Q4-'+selectedyear;
            lstString.add(pp4);
        }
        return lstString;        
    }
    
    global Class populatePeriod{
        global String itemValue{get;set;}
        global String itemLabel{get;set;}
    }
    
    /**
    *   Method Name :   selectCurrentQuarter()
    *   Description :   This method used to get the Current Year Quarter
    *   Parameters  :  
    **/
    
    private String selectCurrentQuarter(){
        Integer year = System.today().year();
        Integer month = System.today().month();
        Integer quarter;
        if(month >=1 && month <= 3)
            quarter = 1;
        else if(month >=4 && month<= 6)
            quarter = 2;
        else if(month >=7 && month <= 9)
            quarter = 3;
        else if(month >=10 && month <= 12)
            quarter = 4;
            
        String sQuarter = String.valueOf(quarter) + '-' + String.valueOf(year);
        
        if(Integer.valueOf(selectedyear) == year){
            return sQuarter;
        }
        return null;
    }
    
    @RemoteAction
    global  Static String saveARF(String grid ,  String setOfIds){
            system.debug('<><>> '+ setOfIds + ' GRID = '+grid);
            
            if(setOfIds != null && setOfIds != '' && grid != null){
                setOfIds = setOfIds.replace('[','').replace(']','');
                List<string> lstString = setOfIds.split(',');
                Set<String> setOfSelectedId = new Set<String>();
                
                for(String str : lstString ){
                    setOfSelectedId.add(str.replaceAll(' ', ''));
                }
            
                system.debug('Set = '+ setOfSelectedId);
                List<Account_Revenue_Forecast_Comment__c> lstARFCInsert = new List<Account_Revenue_Forecast_Comment__c>();
                List<Account_Revenue_Forecast_Comment__c> lstARFCUpdated = new List<Account_Revenue_Forecast_Comment__c>();
                
                List<CommentWrapper> response = (List<CommentWrapper>)JSON.deserialize(grid, List<CommentWrapper>.class);
                
                for(CommentWrapper cmentnew : response){
                    String str = cmentnew.arfcId;
                    
                    system.debug('key '+ cmentnew.arfcId);
                    
                    List<String> lststr = str.split('-');
                    
                    system.debug('ARFComment Id '+ lststr[0]);
                    system.debug('ARF Id '+ lststr[1]);
                    
                    if(setOfSelectedId.contains(str)){
                        
                        Account_Revenue_Forecast_Comment__c arfc = new Account_Revenue_Forecast_Comment__c();
                        
                        arfc.Whats_Needed__c =  cmentnew.whatsNeeded;
                        arfc.By_Whom__c =  cmentnew.fromHome;
                        system.debug('Date '+ cmentnew.byWhen);
                        arfc.By_When__c =  Date.valueOf(cmentnew.byWhen);
                        arfc.By_When__c = arfc.By_When__c.adddays(1);
                        arfc.Likely__c =  cmentnew.likely;
                        arfc.Amount__c =  cmentnew.amnt;
                        arfc.Quarter__c =  cmentnew.quarter;
                        arfc.Reason__c =  cmentnew.reason;
                        arfc.Comment__c =  cmentnew.comment;
                        arfc.Is_Changed__c = false;
                        arfc.Quarter_Upside_Risk__c =  cmentnew.riskUpside;
                        if(lststr[0] != '000'){
                            arfc.Id  = lststr[0];
                            arfc.Is_Changed__c = false;
                            lstARFCUpdated.add(arfc);
                        }else{
                            arfc.Account_Revenue_Forecast__c =lststr[2];
                            lstARFCInsert.add(arfc);
                        }
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
    
     
    @RemoteAction
    global  Static String Removerecord(String removeId){
        if(removeId != null){
            delete [Select Id from Account_Revenue_Forecast_Comment__c where Id=:removeId];
        }
        return null;
    }
    
    
    @RemoteAction
    global  Static String SavePopup(String insertNewRiskUpside ,  String upsertRiskUpside){
        system.debug('insertNewRiskUpside = ' + insertNewRiskUpside);
        system.debug('upsertRiskUpside = ' + upsertRiskUpside);
        if(insertNewRiskUpside != '' && upsertRiskUpside != ''){
            List<String> lstInsert = insertNewRiskUpside.split(':');
            if(lstInsert.size() == 10){
                Account_Revenue_Forecast_Comment__c arfc = new Account_Revenue_Forecast_Comment__c();
                arfc.Whats_Needed__c =  lstInsert[0];
                arfc.By_Whom__c =  lstInsert[1];
                
                if(lstInsert[2] != null && lstInsert[2] != '')
                    arfc.By_When__c =  date.parse(lstInsert[2]);
                    
                arfc.Comment__c = lstInsert[3];
                
                if(lstInsert[4] != null && lstInsert[4] != '')
                    arfc.Amount__c =  Decimal.valueOf(lstInsert[4]);
                    
                if(lstInsert[5] != null && lstInsert[5] != '')
                    arfc.Likely__c =  Decimal.valueOf(lstInsert[5]);
                    
                arfc.Account_Revenue_Forecast__c =lstInsert[6];
                arfc.Quarter__c =  lstInsert[7];
                arfc.Reason__c =  lstInsert[8];
                arfc.Quarter_Upside_Risk__c =  lstInsert[9];
                arfc.Is_Clone__c = true;
                arfc.Is_Changed__c = false;
                insert arfc;
            }
            
            // Updated the existing reocrd
            List<String> lstupsert = upsertRiskUpside.split(':');
            if(lstupsert.size() == 7){
                Account_Revenue_Forecast_Comment__c arfc = new Account_Revenue_Forecast_Comment__c();
                arfc.Whats_Needed__c =  lstupsert[0];
                arfc.By_Whom__c =  lstupsert[1];
                if(lstupsert[2] != null && lstupsert[2] != '')
                    arfc.By_When__c =  date.parse(lstupsert[2]);
                    
                arfc.Comment__c = lstupsert[3];
                
                if(lstupsert[4] != null && lstupsert[4] != '')
                    arfc.Amount__c =  Decimal.valueOf(lstupsert[4]);
                
                if(lstupsert[5] != null && lstupsert[5] != '')
                    arfc.Likely__c =  Decimal.valueOf(lstupsert[5]);
                
                arfc.Id =lstupsert[6];
                arfc.Is_Changed__c = false;
                update arfc;
            }
        }
        return null;        
    }
    
    /**
    *   Method Name :   getThresholdValue()
    *   Description :   This method used to get offeringType threshold value
    *   Parameters  :  
    **/
    
    public static Decimal getThresholdValue(String offeringType, String riskUpside){
        
        Decimal offerTypeValue = 0;
        
        if(offeringType != ''){
            Offering_Type_Settings__c offerType = Offering_Type_Settings__c.getValues(offeringType);
            if(offerType != null && offerType.Risk_Threshold_Amount__c != null && riskUpside == 'Risk'){
                offerTypeValue = (Decimal)offerType.Risk_Threshold_Amount__c;
            }else if(offerType != null && offerType.Upside_Threshold_Amount__c != null && riskUpside == 'Upside'){
                offerTypeValue = (Decimal)offerType.Upside_Threshold_Amount__c;
            }
        }
        
        return offerTypeValue;
    }
    
    /**
    *   Method Name :   getQuartersetting()
    *   Description :   This method used to get Quarter Setting 
    *   Parameters  :  
    **/
    
    public static Boolean getQuartersetting(String offeringType){
        
        Boolean isQuarter = false;
        
        if(offeringType != ''){
            Offering_Type_Settings__c offerType = Offering_Type_Settings__c.getValues(offeringType);
            if(offerType != null){
                isQuarter = offerType.Risk_Upside__c;
            }
        }
        
        return isQuarter;
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
        public String partnerAccount {get;set;}
        public String acntOfferingType{get;set;}
        public String acntType{get;set;}
        public String acntRegion{get;set;}
        public String acntCSM{get;set;}
        public String acntRType{get;set;}
        public String acntPlatformType{get;set;}
        public String reason{get;set;}
        public String quarter{get;set;}
        public String whatsNeeded{get;set;}
        public String fromHome{get;set;}
        public String byWhen{get;set;}
        public String comment{get;set;}
        public Decimal likely{get;set;}
        public Decimal wtAvg{get;set;}
        public Decimal amnt{get;set;}
        public String arfcId{get;set;}
        public String arfcoId{get;set;}
        public String arfId{get;set;}
        public Boolean isCreate{get;set;}
        public String riskUpside{get;set;}
        public Boolean isChanged{get;set;}
        public String riskUpsideShow{get;set;}
        public Boolean isCloned{get;set;}
    }
}