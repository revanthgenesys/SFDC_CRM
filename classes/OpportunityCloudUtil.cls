/************************************************************************************
Purpose : Util Class for Opportunity related to Cloud Functionality
Written By : Rony Joseph
Test Classes :OpportunityCloudUtilTest
*************************************************************************************/
public class OpportunityCloudUtil {
    
    Public Static Id activeRecordOwnerId;
    
    //Update Legal Deal Review on Subscription when Opportunity changes
    //Fetch Matching GSRelationship record for account
    public static Map<String,JBCXM__GSRelationship__c> FetchGSRelationship(Set<Id> set_AccountIds)
    {
        Map<String,JBCXM__GSRelationship__c> map_AccountGSRelationship = new Map<String,JBCXM__GSRelationship__c>();
        for(JBCXM__GSRelationship__c objGSRelationship : [SELECT JBCXM__GSCSM__c,JBCXM__Account__c,Offerings_Type__c,Relationship_Type__c,PureEngage_Cloud_Stage__c
                                                          FROM JBCXM__GSRelationship__c 
                                                          WHERE JBCXM__Account__c IN :set_AccountIds 
                                                          //AND PureEngage_Cloud_Stage__c NOT IN('Will Churn','Churned','Migrated')])
                                                          AND PureEngage_Cloud_Stage__c NOT IN('Churned','Migrated')])
        {
            map_AccountGSRelationship.put(objGSRelationship.JBCXM__Account__c + ':' + objGSRelationship.Relationship_Type__c, objGSRelationship);
        }                                                  
        return map_AccountGSRelationship;  
    }
    
    
    //Update run rate on opportunity based on Account Revenue forecast
    
    //Update run rate on opportunity based on Account Revenue forecast
    
    public static void updateRunRate(Set<Id> set_OppIds)
    {        
        try{
            String strOppQuery = 'Select Id, AccountId, Lines_of_Businesses__c, RecordTypeid, Createddate,ForecastStatus__c , Run_Rate_USD__c, Renewal_Change_v_Run_Rate_USD__c, CurrencyIsoCode, Primary_Quote__c, Primary_Quote__r.Annual_Contract_Value__c,Lead_Offer__c,StageName from Opportunity where id  in :set_OppIds';
            List<Opportunity> list_Opportunities= Database.query(strOppQuery);
            System.debug('list_Opportunities'+list_Opportunities);
            //Create Account - opportunity map
            Map<Id,List<Opportunity>> map_AccountOpportunity = new Map<Id,List<Opportunity>>(); 
            for(Opportunity objOpp:list_Opportunities){
                objOpp.Run_Rate_USD__c = 0.0;
            }
            for(Opportunity objOpp : list_Opportunities) {
                if(map_AccountOpportunity.containskey(objOpp.accountId))
                    map_AccountOpportunity.get(objOpp.accountId).add(objOpp);
                else
                    map_AccountOpportunity.put(objOpp.accountId, new List<Opportunity> { objOpp }); 
            }
            
            //Find out run rate for account from forecast
            Set<Id> set_AccountIds = new Set<Id>();
            set_AccountIds.addall(map_AccountOpportunity.keyset());
            String strQuery = 'SELECT Id,';
            List<Schema.FieldSetMember> gridFields = SObjectType.Account_Revenue_Forecast__c.FieldSets.Cloud_Renewal_Fields.getFields();
            for(Schema.FieldSetMember field : gridFields)
                strQuery += field.getFieldPath() + ', ';
            strQuery = strQuery.removeEnd(', ');
            strQuery += ' FROM Account_Revenue_Forecast__c WHERE Account__c in :set_AccountIds AND Cloud_Forecast_Quarter__r.Current_Week__c = True AND Cloud_Forecast_Quarter__r.Active__c = True AND LOB__c in  (\'A - In-Force Subscription\',\'D - In-Force Telco\')';
            system.debug(strQuery);
            
            Map<Integer,String> map_MonthFieldPCC = new Map<Integer,String>{
                1 => 'Dec_PREVYEAR;Jan_LASTYEAR;Feb_LASTYEAR;Mar_LASTYEAR;Apr_LASTYEAR;May_LASTYEAR;June_LASTYEAR;July_LASTYEAR;Aug_LASTYEAR;Sept_LASTYEAR;Oct_LASTYEAR;Nov_LASTYEAR',
                    2 => 'Jan_LASTYEAR;Feb_LASTYEAR;Mar_LASTYEAR;Apr_LASTYEAR;May_LASTYEAR;June_LASTYEAR;July_LASTYEAR;Aug_LASTYEAR;Sept_LASTYEAR;Oct_LASTYEAR;Nov_LASTYEAR;Dec_LASTYEAR',
                    3 => 'Feb_LASTYEAR;Mar_LASTYEAR;Apr_LASTYEAR;May_LASTYEAR;June_LASTYEAR;July_LASTYEAR;Aug_LASTYEAR;Sept_LASTYEAR;Oct_LASTYEAR;Nov_LASTYEAR;Dec_LASTYEAR;Jan_THISYEAR',
                    4 => 'Mar_LASTYEAR;May_LASTYEAR;June_LASTYEAR;July_LASTYEAR;Aug_LASTYEAR;Sept_LASTYEAR;Oct_LASTYEAR;Nov_LASTYEAR;Dec_LASTYEAR;Jan_THISYEAR;Feb_THISYEAR;Feb_THISYEAR',
                    5 => 'Apr_LASTYEAR;June_LASTYEAR;July_LASTYEAR;Aug_LASTYEAR;Sept_LASTYEAR;Oct_LASTYEAR;Nov_LASTYEAR;Dec_LASTYEAR;Jan_THISYEAR;Feb_THISYEAR;Mar_THISYEAR;Mar_THISYEAR', 
                    6 => 'May_LASTYEAR;June_LASTYEAR;July_LASTYEAR;Aug_LASTYEAR;Sept_LASTYEAR;Oct_LASTYEAR;Nov_LASTYEAR;Dec_LASTYEAR;Jan_THISYEAR;Feb_THISYEAR;Mar_THISYEAR;Apr_THISYEAR',
                    7 => 'June_LASTYEAR;July_LASTYEAR;Aug_LASTYEAR;Sept_LASTYEAR;Oct_LASTYEAR;Nov_LASTYEAR;Dec_LASTYEAR;Jan_THISYEAR;Feb_THISYEAR;Mar_THISYEAR;Apr_THISYEAR;May_THISYEAR',
                    8 => 'July_LASTYEAR;Aug_LASTYEAR;Sept_LASTYEAR;Oct_LASTYEAR;Nov_LASTYEAR;Dec_LASTYEAR;Jan_THISYEAR;Feb_THISYEAR;Mar_THISYEAR;Apr_THISYEAR;May_THISYEAR;June_THISYEAR',
                    9 => 'Aug_LASTYEAR;Sept_LASTYEAR;Oct_LASTYEAR;Nov_LASTYEAR;Dec_LASTYEAR;Jan_THISYEAR;Feb_THISYEAR;Mar_THISYEAR;Apr_THISYEAR;May_THISYEAR;June_THISYEAR;July_THISYEAR',
                    10 => 'Sept_LASTYEAR;Oct_LASTYEAR;Nov_LASTYEAR;Dec_LASTYEAR;Jan_THISYEAR;Feb_THISYEAR;Mar_THISYEAR;Apr_THISYEAR;May_THISYEAR;June_THISYEAR;July_THISYEAR;Aug_THISYEAR',
                    11 => 'Oct_LASTYEAR;Nov_LASTYEAR;Dec_LASTYEAR;Jan_THISYEAR;Feb_THISYEAR;Mar_THISYEAR;Apr_THISYEAR;May_THISYEAR;June_THISYEAR;July_THISYEAR;Aug_THISYEAR;Sept_THISYEAR',
                    12 => 'Nov_LASTYEAR;Dec_LASTYEAR;Jan_THISYEAR;Feb_THISYEAR;Mar_THISYEAR;Apr_THISYEAR;May_THISYEAR;June_THISYEAR;July_THISYEAR;Aug_THISYEAR;Sept_THISYEAR;Oct_THISYEAR'
                    };           
                        System.debug('Database.query(strQuery)'+ Database.query(strQuery));    
            for(Account_Revenue_Forecast__c objForecast : Database.query(strQuery)) {
                for(Opportunity objOpp : map_AccountOpportunity.get(objForecast.Account__c)) {
                    System.debug(objOpp.Lines_of_Businesses__c);
                    if (objOpp.Lines_of_Businesses__c.contains(objForecast.Offering_Type__c)) {
                        if(objOpp.Lead_Offer__C == SubscriptionUtil.OFFERING_TYPE_PC && objForecast.LOB__c == 'A - In-Force Subscription'){
                            DateTime dtOppCreatedDate;
                            system.debug('objOpp.RecordTypeid' + objOpp.RecordTypeid);
                            system.debug('objOpp.RecordTypeid' + Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cloud Renewal').getRecordTypeId());
                            if(objOpp.RecordTypeid == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cloud Renewal').getRecordTypeId()){
                                
                                dtOppCreatedDate = Date.today();
                                //objOpp.CloseDate = Date.today();
                                system.debug('dtOppCreatedDate1' + dtOppCreatedDate);
                                system.debug('objOpp.RecordTypeid' + objOpp.RecordTypeid);
                            }else{
                                dtOppCreatedDate = objOpp.createddate;
                                system.debug('dtOppCreatedDate1' + dtOppCreatedDate);
                                system.debug('objOpp.RecordTypeid' + objOpp.RecordTypeid);
                            }
                            
                            
                            Integer intMonth = dtOppCreatedDate.month();
                            System.debug('intMonth1'+ intMonth);
                            If(objOpp.StageName == 'Closed' && objOpp.RecordTypeid == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cloud Renewal').getRecordTypeId()){
                                intMonth++;
                                if(intMonth > 12) 
                                    intMonth = 1;
                                System.debug('intMonth2'+ intMonth);
                            }
                            System.debug('intMonth2.1'+ intMonth);
                            System.debug('map_MonthFieldPCC.get(intMonth)1.0' +map_MonthFieldPCC.get(intMonth));
                            Decimal decForecastSum = 0;
                            String strMonth1 = map_MonthFieldPCC.get(intMonth).split(';')[0].replace('PREVYEAR',String.valueof(dtOppCreatedDate.Year() -2)).replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth2 = map_MonthFieldPCC.get(intMonth).split(';')[1].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth3 = map_MonthFieldPCC.get(intMonth).split(';')[2].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth4 = map_MonthFieldPCC.get(intMonth).split(';')[3].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth5 = map_MonthFieldPCC.get(intMonth).split(';')[4].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth6 = map_MonthFieldPCC.get(intMonth).split(';')[5].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth7 = map_MonthFieldPCC.get(intMonth).split(';')[6].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth8 = map_MonthFieldPCC.get(intMonth).split(';')[7].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth9 = map_MonthFieldPCC.get(intMonth).split(';')[8].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth10 = map_MonthFieldPCC.get(intMonth).split(';')[9].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth11 = map_MonthFieldPCC.get(intMonth).split(';')[10].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth12 = map_MonthFieldPCC.get(intMonth).split(';')[11].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            
                            System.debug(strMonth1+'Value'+String.valueof((Decimal)objForecast.get(strMonth1+'__c')));
                            System.debug(strMonth2+'Value'+String.valueof((Decimal)objForecast.get(strMonth2+'__c')));
                            System.debug(strMonth3+'Value'+String.valueof((Decimal)objForecast.get(strMonth3+'__c')));
                            System.debug(strMonth4+'Value'+String.valueof((Decimal)objForecast.get(strMonth4+'__c')));
                            System.debug(strMonth5+'Value'+String.valueof((Decimal)objForecast.get(strMonth5+'__c')));
                            System.debug(strMonth6+'Value'+String.valueof((Decimal)objForecast.get(strMonth6+'__c'))); 
                            System.debug(strMonth7+'Value'+String.valueof((Decimal)objForecast.get(strMonth7+'__c')));
                            System.debug(strMonth8+'Value'+String.valueof((Decimal)objForecast.get(strMonth8+'__c')));
                            System.debug(strMonth9+'Value'+String.valueof((Decimal)objForecast.get(strMonth9+'__c')));
                            System.debug(strMonth10+'Value'+String.valueof((Decimal)objForecast.get(strMonth10+'__c')));
                            System.debug(strMonth11+'Value'+String.valueof((Decimal)objForecast.get(strMonth11+'__c')));
                            System.debug(strMonth12+'Value'+String.valueof((Decimal)objForecast.get(strMonth12+'__c')));
                            
                            list<String> list_Months = new List<String>{strMonth1,strMonth2,strMonth3,strMonth4,strMonth5,strMonth6,strMonth7,strMonth8,strMonth9,strMonth10,strMonth11,strMonth12};
                                for(integer i=0;i<12;i++){
                                    
                                    decForecastSum += ((Decimal)objForecast.get(String.valueof(list_Months[i])+'__c') != null)?(Decimal)objForecast.get(String.valueof(list_Months[i])+'__c'):0.00;
                                }
                            //Decimal decForecastSum = (Decimal)objForecast.get(strMonth1+'__c') + (Decimal)objForecast.get(strMonth2+'__c') + (Decimal)objForecast.get(strMonth3+'__c') + (Decimal)objForecast.get(strMonth4+'__c') + (Decimal)objForecast.get(strMonth5+'__c') + (Decimal)objForecast.get(strMonth6+'__c') + (Decimal)objForecast.get(strMonth7+'__c') + (Decimal)objForecast.get(strMonth8+'__c') + (Decimal)objForecast.get(strMonth9+'__c') + (Decimal)objForecast.get(strMonth10+'__c') + (Decimal)objForecast.get(strMonth11+'__c') + (Decimal)objForecast.get(strMonth12+'__c');                             
                            System.debug('decForecastSum1' + decForecastSum);
                            System.debug('objOpp.Run_Rate_USD__c1'+ objOpp.Run_Rate_USD__c);
                            objOpp.Run_Rate_USD__c += decForecastSum;
                        }
                        else if(objOpp.Lead_Offer__C == SubscriptionUtil.OFFERING_TYPE_PCC ||objOpp.Lead_Offer__C == SubscriptionUtil.OFFERING_TYPE_PEC)
                        {
                            //DateTime dtOppCreatedDate = objOpp.createddate;
                            System.debug('test one navaneetha');
                            DateTime dtOppCreatedDate;
                            if(objOpp.RecordTypeid == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cloud Renewal').getRecordTypeId()){
                                
                                dtOppCreatedDate = Date.today();
                                //objOpp.CloseDate = Date.today();
                            }else{
                                dtOppCreatedDate = objOpp.createddate;
                            }
                            Integer intMonth = dtOppCreatedDate.month();
                            If(objOpp.StageName == 'Closed' && objOpp.RecordTypeid == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cloud Renewal').getRecordTypeId()){
                                intMonth++;
                                if(intMonth >= 12) 
                                    intMonth = 1;
                            }
                            Decimal decForecastSum = 0;
                            System.debug('intMonth3'+ intMonth);
                            System.debug('map_MonthFieldPCC.get(intMonth)1' +map_MonthFieldPCC.get(intMonth));
                            
                            String strMonth1 = map_MonthFieldPCC.get(intMonth).split(';')[0].replace('PREVYEAR',String.valueof(dtOppCreatedDate.Year() -2)).replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth2 = map_MonthFieldPCC.get(intMonth).split(';')[1].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth3 = map_MonthFieldPCC.get(intMonth).split(';')[2].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth4 = map_MonthFieldPCC.get(intMonth).split(';')[3].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth5 = map_MonthFieldPCC.get(intMonth).split(';')[4].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth6 = map_MonthFieldPCC.get(intMonth).split(';')[5].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth7 = map_MonthFieldPCC.get(intMonth).split(';')[6].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth8 = map_MonthFieldPCC.get(intMonth).split(';')[7].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth9 = map_MonthFieldPCC.get(intMonth).split(';')[8].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth10 = map_MonthFieldPCC.get(intMonth).split(';')[9].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth11 = map_MonthFieldPCC.get(intMonth).split(';')[10].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            String strMonth12 = map_MonthFieldPCC.get(intMonth).split(';')[11].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                            System.debug('STRM!'+ strMonth1+'Value'+String.valueof((Decimal)objForecast.get(strMonth1+'__c')));
                            System.debug('STRM!'+ strMonth2+'Value'+String.valueof((Decimal)objForecast.get(strMonth2+'__c')));
                            System.debug('STRM!'+ strMonth3+'Value'+String.valueof((Decimal)objForecast.get(strMonth3+'__c')));
                            System.debug('STRM!'+ strMonth4+'Value'+String.valueof((Decimal)objForecast.get(strMonth4+'__c')));
                            System.debug('STRM!'+ strMonth5+'Value'+String.valueof((Decimal)objForecast.get(strMonth5+'__c')));
                            System.debug('STRM!'+ strMonth6+'Value'+String.valueof((Decimal)objForecast.get(strMonth6+'__c'))); 
                            System.debug('STRM!'+ strMonth7+'Value'+String.valueof((Decimal)objForecast.get(strMonth7+'__c')));
                            System.debug('STRM!'+ strMonth8+'Value'+String.valueof((Decimal)objForecast.get(strMonth8+'__c')));
                            System.debug('STRM!'+ strMonth9+'Value'+String.valueof((Decimal)objForecast.get(strMonth9+'__c')));
                            System.debug('STRM!'+ strMonth10+'Value'+String.valueof((Decimal)objForecast.get(strMonth10+'__c')));
                            System.debug('STRM!'+ strMonth11+'Value'+String.valueof((Decimal)objForecast.get(strMonth11+'__c')));
                            System.debug('STRM!'+ strMonth12+'Value'+String.valueof((Decimal)objForecast.get(strMonth12+'__c')));
                            list<String> list_Months = new List<String>{strMonth1,strMonth2,strMonth3,strMonth4,strMonth5,strMonth6,strMonth7,strMonth8,strMonth9,strMonth10,strMonth11,strMonth12};
                                
                                for(integer i=0;i<12;i++){
                                    
                                    decForecastSum += ((Decimal)objForecast.get(String.valueof(list_Months[i])+'__c') != null)?(Decimal)objForecast.get(String.valueof(list_Months[i])+'__c'):0.00;
                                }
                            //Decimal decForecastSum = (Decimal)objForecast.get(strMonth1+'__c') + (Decimal)objForecast.get(strMonth2+'__c') + (Decimal)objForecast.get(strMonth3+'__c') + (Decimal)objForecast.get(strMonth4+'__c') + (Decimal)objForecast.get(strMonth5+'__c') + (Decimal)objForecast.get(strMonth6+'__c') + (Decimal)objForecast.get(strMonth7+'__c') + (Decimal)objForecast.get(strMonth8+'__c') + (Decimal)objForecast.get(strMonth9+'__c') + (Decimal)objForecast.get(strMonth10+'__c') + (Decimal)objForecast.get(strMonth11+'__c') + (Decimal)objForecast.get(strMonth12+'__c');                             
                            
                            System.debug('decForecastSum' + decForecastSum);
                            System.debug('objOpp.Run_Rate_USD__c'+ objOpp.Run_Rate_USD__c);
                            objOpp.Run_Rate_USD__c += decForecastSum;
                            
                            System.debug('objOpp.Run_Rate_USD__c123'+ objOpp.Run_Rate_USD__c);
                        }
                    }     
                    
                }
            }
            
            for(Opportunity objOpp : list_Opportunities) {
                If(objOpp.StageName != 'Closed'  && objOpp.RecordTypeid != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cloud Renewal').getRecordTypeId())
                {
                    //Adding bypass for Triggers of Users - Rony Joseph - July 30 2019 
                    Util.Bypass_Trigger_Chk = true;          
                    User objuser=[select BypassValidationRules__c from user where id =: userinfo.getuserid() ];
                    objuser.BypassValidationRules__c = true;
                    update objuser;
                    Util.Bypass_Trigger_Chk = false;
                    
                    update list_Opportunities; 
                    Util.Bypass_Trigger_Chk = true;
                    objuser.BypassValidationRules__c = false;
                    update objuser;  
                    Util.Bypass_Trigger_Chk =  false;
                }
                else If(objOpp.StageName != 'Closed'  && objOpp.RecordTypeid != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cloud Renewal').getRecordTypeId()){
                    //objOpp.CloseDate = Date.today();  
                    update list_Opportunities; }
                else{update list_Opportunities; }
                
            }
            
        }catch(Exception e){
            If(CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage != null){CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage+= ExceptionHandling.ExceptionHandling(e);}
            System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
        }    
    }
    
    
    //Fetch Matching GSRelationship record for account
    public static Map<String,JBCXM__GSRelationship__c> fetchGSRelationship(Id accountId)
    {
        Map<String,JBCXM__GSRelationship__c> map_AccountGSRelationship = new Map<String,JBCXM__GSRelationship__c>();
        for(JBCXM__GSRelationship__c objGSRelationship : [SELECT Id,JBCXM__GSCSM__c,JBCXM__Account__c,Offerings_Type__c,Relationship_Type__c,PureEngage_Cloud_Stage__c
                                                          FROM JBCXM__GSRelationship__c 
                                                          WHERE JBCXM__Account__c = :accountId 
                                                          /*   AND PureEngage_Cloud_Stage__c NOT IN ('Will Churn','Churned','Migrated')*/])
            map_AccountGSRelationship.put(objGSRelationship.Relationship_Type__c, objGSRelationship);
        return map_AccountGSRelationship;  
    }
    
    
    public static void updateLegalExceptiononOnOpportunity(Opportunity objOppToUpdate,Id IdSubscriptionId){
        try{
            Subscription__c objSub = [Select Legal_Exceptions__c,Contract_Effective_Date__c,Contract_Expiration_Date__c,Contract_Type__c,Business_Partner__r.Owner.Email from Subscription__c where id = :IdSubscriptionId];    
            objOppToUpdate.Contract_Expiration_Date__c = objOppToUpdate.Contract_Expiration_Date__c == null ? objSub.Contract_Expiration_Date__c : objOppToUpdate.Contract_Expiration_Date__c;
            objOppToUpdate.Contract_Effective_Date__c = objOppToUpdate.Contract_Expiration_Date__c == null ? objSub.Contract_Effective_Date__c : objOppToUpdate.Contract_Effective_Date__c;
            objOppToUpdate.Contract_Type__c = objOppToUpdate.Contract_Type__c == null ? objSub.Contract_Type__c : objOppToUpdate.Contract_Type__c;
            objOppToUpdate.Legal_Exceptions__c = objOppToUpdate.Legal_Exceptions__c == null ? objSub.Legal_Exceptions__c : objOppToUpdate.Legal_Exceptions__c;
        }catch(Exception e){System.debug('Error has occurred:'+e.getMessage()+'\n'+ e.getStackTraceString());}
    }
    
    //--Rony Joseph-September 4 2018 -Start---
    // Generate Renewal Opportunity from Subscriptions
public static Opportunity createRenewalOpportunity(Subscription__c objSubs, string value){
        try{            
            Id oppId = null;
            Opportunity objClonedOpportunity = new Opportunity();
            Opportunity objOpp = new Opportunity();
            List<Opportunity> list_SourceOpps = new List<Opportunity>();
            Map<String, JBCXM__GSRelationship__c> map_AccountGSRelationship = fetchGSRelationship(objSubs.Account__c) == null? new Map<String, JBCXM__GSRelationship__c>():fetchGSRelationship(objSubs.Account__c) ;
            System.debug('Test0'+ map_AccountGSRelationship);
            System.debug('Test0v'+ map_AccountGSRelationship.size());
            //  system.debug('test01'+ Label.Status_that_prevent_Renewal.contains(map_AccountGSRelationship.get(objSubs.Offering_Type__c).PureEngage_Cloud_Stage__c));
            //if((!Label.Status_that_prevent_Renewal.contains(map_AccountGSRelationship.get(objSubs.Offering_Type__c).PureEngage_Cloud_Stage__c)))
            if( map_AccountGSRelationship.size() == 0 || 
               (map_AccountGSRelationship.size() > 0 &&
                (map_AccountGSRelationship.containskey(objSubs.Offering_Type__c) &&
                 ((map_AccountGSRelationship.get(objSubs.Offering_Type__c).PureEngage_Cloud_Stage__c == null) || 
                  (!Label.Status_that_prevent_Renewal.contains(map_AccountGSRelationship.get(objSubs.Offering_Type__c).PureEngage_Cloud_Stage__c) )|| !map_AccountGSRelationship.containskey(objSubs.Offering_Type__c))))) {
                      
                      if( map_AccountGSRelationship.size() == 0 || 
                         (map_AccountGSRelationship.size() > 0 &&
                          (map_AccountGSRelationship.containskey(objSubs.Offering_Type__c) &&
                           (((map_AccountGSRelationship.get(objSubs.Offering_Type__c).PureEngage_Cloud_Stage__c == null)||!Label.Status_that_prevent_Renewal.contains(map_AccountGSRelationship.get(objSubs.Offering_Type__c).PureEngage_Cloud_Stage__c)) || 
                             !map_AccountGSRelationship.containskey(objSubs.Offering_Type__c))))) {
                                oppId = objSubs.Opportunity_LookUp__c != null ? objSubs.Opportunity_LookUp__c : 
                                objSubs.Quote__c != null ? objSubs.Quote__r.BigMachines__Opportunity__c : 
                                objSubs.Order__c != null ? objSubs.Order__r.Opportunity__c : null;                                
                                String strObjName = 'Opportunity';
                                String strWhereCondition = 'Id  = :oppId';
                                System.debug('Query'+CloneUtility.getCreatableFieldsSOQL(strObjName,strWhereCondition));
                                list_SourceOpps = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));  
                                system.debug('Test1' + map_AccountGSRelationship);             
                            }
                      if(list_SourceOpps.size() > 0) {
                          objOpp = list_SourceOpps[0];
                          objClonedOpportunity = objOpp.Clone(false,true,false,false);
                          objClonedOpportunity.OwnerId = objOpp.OwnerId;
                          system.debug('Test2' + map_AccountGSRelationship);  
                      }  
                      else
                      {
                          objClonedOpportunity.OwnerId = objSubs.Account__r.Ownerid;
                          objClonedOpportunity.AccountId = objSubs.Account__c;
                          objClonedOpportunity.Direct_Indirect_Sale__c = objSubs.Sale_Type__c;
                          objClonedOpportunity.Gainsight_Relationship_Type__c = objSubs.Offering_Type__c;
                          system.debug('Test3' + map_AccountGSRelationship);  
                      }    
                      if((map_AccountGSRelationship.containskey(objClonedOpportunity.Lines_of_Businesses__c) 
                          && map_AccountGSRelationship.get(objClonedOpportunity.Lines_of_Businesses__c).JBCXM__GSCSM__c != null)) {
                              objClonedOpportunity.OwnerId = map_AccountGSRelationship.get(objClonedOpportunity.Lines_of_Businesses__c).JBCXM__GSCSM__c;
                              system.debug('Test4' + map_AccountGSRelationship);  } 
                      else if(objSubs.Account__r.CSM_Account_Owner__c != null) {
                          objClonedOpportunity.OwnerId = objSubs.Account__r.CSM_Account_Owner__c;    
                          system.debug('Test5' + map_AccountGSRelationship);                  
                      }
                      system.debug('Test6' + map_AccountGSRelationship);  
                      objClonedOpportunity.Primary_solution__C = '';
                      objClonedOpportunity.Sold_To_Country__c = (objClonedOpportunity.Sold_To_Country__c != null)?objClonedOpportunity.Sold_To_Country__c:objSubs.Business_Partner__r.Country__c;
                      objClonedOpportunity.Country__c = (objClonedOpportunity.Country__c != null)?objClonedOpportunity.Country__c:objSubs.Account__r.Country__c;
                      objClonedOpportunity.CSM_GA_Opportunity_Owner__c = objClonedOpportunity.OwnerId;
                      objClonedOpportunity.Lead_Offer__c = objSubs.Offering_Type__c;
                      if(objClonedOpportunity.Lines_of_Businesses__c  == '' ||objClonedOpportunity.Lines_of_Businesses__c == null ){objClonedOpportunity.Lines_of_Businesses__c = (objClonedOpportunity.Lead_Offer__c ==  SubscriptionUtil.OFFERING_TYPE_PC)? 'PureCloud':'PureConnect';}
                      objClonedOpportunity.Cloud_Renewal__c =  (objClonedOpportunity.Lead_Offer__c ==  SubscriptionUtil.OFFERING_TYPE_PEC || objClonedOpportunity.Lead_Offer__c ==  SubscriptionUtil.OFFERING_TYPE_PCC)? true:false;
                      objClonedOpportunity.Direct_Indirect_Sale__c = objSubs.Sale_Type__c;
                      objClonedOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cloud Renewal').getRecordTypeId();
                      System.debug(objSubs.Account__r.Name+objSubs.Name);
                      objClonedOpportunity.Name = 'Cloud Renewal - '+ objSubs.Account__r.Name.left(90)+' - '+ objSubs.Name;
                      objClonedOpportunity.CloseDate = objSubs.Subscription_End_Date__c;
                      objClonedOpportunity.Contract_Term_End_Date__c = objSubs.Subscription_End_Date__c;
                      objClonedOpportunity.ParentOpportunity__c = (objSubs.Original_Subscription__c != null) ? 
                          [SELECT Opportunity_LookUp__c FROM Subscription__c WHERE Id =: objSubs.Original_Subscription__c].Opportunity_LookUp__c : 
                      objSubs.Opportunity_LookUp__c;
                      objClonedOpportunity.StageName = 'New';
                      objClonedOpportunity.Type = 'Renewal Only';
                      objClonedOpportunity.ForecastStatus__c = '5.Pipeline';
                      if(objSubs.Sale_Type__c == 'Indirect'){objClonedOpportunity.BusinessPartner__c = objSubs.Business_Partner__c;}
                      objClonedOpportunity.Sold_To_Business_Partner_Mail__c = objSubs.Business_Partner__r.Owner.Email; // Added by Navaneetha
                      objClonedOpportunity.Primary_Line_of_Business__c = 'Cloud';
                      objClonedOpportunity.Offering_Detail__c = objOpp.Offering_Detail__c == 'Cloud Partner (PPU)' ? objOpp.Offering_Detail__c : null;
                      objClonedOpportunity.Probability = null;
                      objClonedOpportunity.Competitor__c = '';
                      objClonedOpportunity.Win_Loss_Status__c = '';
                      objClonedOpportunity.WonLostCancelledComments__c = '';
                      objClonedOpportunity.WonLostCancelledReason__c = '';
                      objClonedOpportunity.Detail_on_Won_Lost_Reason__c = '';
                      objClonedOpportunity.Is_Solution_Consulting_Engaged__c = '';
                      objClonedOpportunity.Is_Business_Consulting_Engaged__c = '';
                      objClonedOpportunity.Business_Consultant__c = null;
                      objClonedOpportunity.Solution_Consultant__c = null;
                      objClonedOpportunity.Reason_for_Discount__c = '';
                      objClonedOpportunity.Next_Step_New__c = '';
                      objClonedOpportunity.By_When__c = null;
                      objClonedOpportunity.From_Whom__c = '';
                      objClonedOpportunity.GeneralComments__c= '';
                      objClonedOpportunity.EPGGroup__c = '';
                      //Clear totals
                      objClonedOpportunity.ACV_Year_2__c = null;
                      objClonedOpportunity.ACV_Subscription_Only__c = 0.00;
                      objClonedOpportunity.Total_Annual_Contract_Value__c =  null;
                      objClonedOpportunity.Hardware_Total__c = 0;
                      objClonedOpportunity.License_Amount__c = null;
                      objClonedOpportunity.Primary_Quote__c = null;  
                      objClonedOpportunity.Opportunity_Status__c = 'In Progress';
                      objClonedOpportunity.Quote_Mtce_Ops__c = objSubs.Account__r.Genesys_Care_Ops__c != null ? objSubs.Account__r.Genesys_Care_Ops__c:null;
                      objClonedOpportunity.Gene_Care_Specialist__c = objSubs.Account__r.Genesys_Care_specialist__c != null ? objSubs.Account__r.Genesys_Care_specialist__c:null;
                      objClonedOpportunity.Buyer_Interview_Confirm_Primary_Contact__c=''; 
                      objClonedOpportunity.Reason_for_Decline__c=''; 
                      objClonedOpportunity.Outgoing_Platform_Migration__c=''; 
                      objClonedOpportunity.Pricebook2Id = Label.Standard_Pricebook_Id;
                      if(value == 'true'){
                      objClonedOpportunity.CCDB_Manual__c =true;}
                      if(objClonedOpportunity.Lead_Offer__c == SubscriptionUtil.OFFERING_TYPE_PEC ){objClonedOpportunity.NumberofAgents__c = null;} 
                      System.debug('objClonedOpportunity'+ objClonedOpportunity);
                      return objClonedOpportunity;     
                  }
            else{
                CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage+= 'There is no associated Gainsight record for this Subscription for the associated offering type.';
                return null;
                
                
            }
        }catch(Exception e){
            System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
            If(CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage != null){CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage+= ExceptionHandling.ExceptionHandling(e);}                  
            System.debug('Error has occurred:'+e.getLineNumber()); 
            return null;}
    }
    //--Rony Joseph-September 4 2018 -Ends---
    //Method to update Renewal ACV v Run Rate on Opportunity 
    public static void updateRenewalRunRate( Map<Id,Opportunity> map_OppsToProcess){
        try{
            if(Limits.getLimitQueries() >= 3 ){
                List<Currency_Configuration__c> list_CurrencyConvertorRate = [Select id,Offering_Type__c,Price_Book__c,Conversion_Rate__c from Currency_Configuration__c where Offering_Type__c in ('PureCloud','PureEngage Cloud','PureConnect Cloud') ];
                Map<String,Map<String,Decimal>> map_OfferingTypeToConversionRatePC =  new Map<String,Map<String,Decimal>>(); 
                Map<String,Map<String,Decimal>> map_OfferingTypeToConversionRatePCC =  new Map<String,Map<String,Decimal>>(); 
                Map<String,Map<String,Decimal>> map_OfferingTypeToConversionRatePEC =  new Map<String,Map<String,Decimal>>(); 
                for(Currency_Configuration__c objCurrecyConfig : list_CurrencyConvertorRate) {
                    if(objCurrecyConfig.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC ){
                        if(map_OfferingTypeToConversionRatePC.containskey(objCurrecyConfig.Offering_Type__c))
                            map_OfferingTypeToConversionRatePC.get(objCurrecyConfig.Price_Book__c).put(objCurrecyConfig.Offering_Type__c,objCurrecyConfig.Conversion_Rate__c);
                        else
                            map_OfferingTypeToConversionRatePC.put(objCurrecyConfig.Price_Book__c, new Map<String,Decimal> { objCurrecyConfig.Offering_Type__c => objCurrecyConfig.Conversion_Rate__c }); 
                    }
                    else if (objCurrecyConfig.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC ){
                        if(map_OfferingTypeToConversionRatePCC.containskey(objCurrecyConfig.Offering_Type__c))
                            map_OfferingTypeToConversionRatePCC.get(objCurrecyConfig.Price_Book__c).put(objCurrecyConfig.Offering_Type__c,objCurrecyConfig.Conversion_Rate__c);
                        else
                            map_OfferingTypeToConversionRatePCC.put(objCurrecyConfig.Price_Book__c, new Map<String,Decimal> { objCurrecyConfig.Offering_Type__c => objCurrecyConfig.Conversion_Rate__c }); 
                    }
                    else if(objCurrecyConfig.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC ){
                        if(map_OfferingTypeToConversionRatePEC.containskey(objCurrecyConfig.Offering_Type__c))
                            map_OfferingTypeToConversionRatePEC.get(objCurrecyConfig.Price_Book__c).put(objCurrecyConfig.Offering_Type__c,objCurrecyConfig.Conversion_Rate__c);
                        else
                            map_OfferingTypeToConversionRatePEC.put(objCurrecyConfig.Price_Book__c, new Map<String,Decimal> { objCurrecyConfig.Offering_Type__c => objCurrecyConfig.Conversion_Rate__c }); 
                    }
                }
                System.debug(map_OfferingTypeToConversionRatePC);
                System.debug(map_OfferingTypeToConversionRatePCC);
                System.debug(map_OfferingTypeToConversionRatePEC);
                Map<String, String> map_CurrencyToPriceBook = new Map<String, String>
                {'USD'=>'NG5_NA_USD','CAD'=>'NG5_NA_CAD','AUD'=>'NG1_APAC_ANZ_AUD','NZD'=>'NG5_NZD','GBP'=>'NG3_EMEA_GBP','EUR'=>'NG3_EMEA_EUR','BRL'=>'NG2_BRAZIL_BRL','JPY'=>'NG4_APAC_JAPAN_YEN','ZAR'=>'NG5_ZAR'};
                    for(Opportunity objOpp:map_OppsToProcess.values()){
                        if (objOpp.Annual_Contract_Value__c != null && objOpp.Run_Rate_USD__c != null) {
                            if(objOpp.Lead_Offer__c ==  SubscriptionUtil.OFFERING_TYPE_PC)  {
                                Decimal decACV = objOpp.Annual_Contract_Value__c/map_OfferingTypeToConversionRatePC.get(map_CurrencyToPriceBook.get(objOpp.CurrencyIsoCode)).get(objOpp.Lead_Offer__c);
                                objOpp.Renewal_Change_v_Run_Rate_USD__c = (decACV - objOpp.Run_Rate_USD__c) > 0 ?
                                    decACV - objOpp.Run_Rate_USD__c : 0;
                            }
                            else if(objOpp.Lead_Offer__c ==  SubscriptionUtil.OFFERING_TYPE_PCC || objOpp.Lead_Offer__c ==  SubscriptionUtil.OFFERING_TYPE_PEC){
                                if (objOpp.Annual_Contract_Value__c != null && objOpp.Run_Rate_USD__c != null) {
                                    System.debug(objOpp.CurrencyIsoCode); System.debug(map_OfferingTypeToConversionRatePCC);
                                    System.debug(objOpp.Annual_Contract_Value__c); System.debug(map_OfferingTypeToConversionRatePCC.get(map_CurrencyToPriceBook.get(objOpp.CurrencyIsoCode)).get(objOpp.Lead_Offer__c));
                                    Decimal decACV = objOpp.Annual_Contract_Value__c/map_OfferingTypeToConversionRatePCC.get(map_CurrencyToPriceBook.get(objOpp.CurrencyIsoCode)).get(objOpp.Lead_Offer__c);
                                    objOpp.Renewal_Change_v_Run_Rate_USD__c = (decACV - objOpp.Run_Rate_USD__c) > 0 ?
                                        decACV - objOpp.Run_Rate_USD__c : 0;
                                }
                            }
                            // added by navaneetha for PEC Runrate. 06-08-2019
                            else if(objOpp.Lead_Offer__c ==  SubscriptionUtil.OFFERING_TYPE_PEC){
                                if (objOpp.Annual_Contract_Value__c != null && objOpp.Run_Rate_USD__c != null) {
                                    System.debug(objOpp.CurrencyIsoCode); System.debug(map_OfferingTypeToConversionRatePEC);
                                    System.debug('12345677'+objOpp.Annual_Contract_Value__c); 
                                    System.debug(map_OfferingTypeToConversionRatePEC.get(map_CurrencyToPriceBook.get(objOpp.CurrencyIsoCode)).get(objOpp.Lead_Offer__c));
                                    Decimal decACV = objOpp.Annual_Contract_Value__c/map_OfferingTypeToConversionRatePEC.get(map_CurrencyToPriceBook.get(objOpp.CurrencyIsoCode)).get(objOpp.Lead_Offer__c);
                                    objOpp.Renewal_Change_v_Run_Rate_USD__c = (decACV - objOpp.Run_Rate_USD__c) > 0 ?
                                        decACV - objOpp.Run_Rate_USD__c : 0;
                                }
                            }
                        }
                    }       
            }
        }catch(Exception e){System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());}
     
    }
    //--Rony Joseph-May 6th 2019 -Starts---
    //Method to clone and create Opportunity for AppFoundry Trial Automation 
    public static Opportunity cloneSubscriptionOpportunity( String  SubscriptionId){
        try{
            
            Id IdSubscriptionId = (Id) SubscriptionId;
            Id IdSubsOppId = [Select Opportunity_LookUp__c from Subscription__C where Id =: IdSubscriptionId ].Opportunity_LookUp__c;
            String strObjName = 'Subscription__c';
            String strWhereCondition = 'Id = :SubscriptionId';
            List<Subscription__c> list_Subscription = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
            Id IdSubOppId = (Id) list_Subscription[0].Opportunity_LookUp__c;
            strObjName = 'Opportunity';
            strWhereCondition = 'Id = :IdSubOppId';
            List<Opportunity> list_SubscriptionOpps = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
            Opportunity objAppFoundryTrialOpp =  list_SubscriptionOpps[0].clone(false, true, false, false);
            activeRecordOwnerId = QuotecloudUtil.checkActiveUser(list_SubscriptionOpps[0].OwnerId);
            objAppFoundryTrialOpp.OwnerId = activeRecordOwnerId;
            objAppFoundryTrialOpp.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();  
            objAppFoundryTrialOpp.StageName = '6.Closed';
            insert  objAppFoundryTrialOpp;   
            return objAppFoundryTrialOpp;
        }catch(Exception e){System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
                            CreationofTrialRecords.Res.failureMessages.add(e.getMessage()+'\n'+e.getStackTraceString());
                            ErrorLogUtil.insertLog('OpportunityCloudUtil', 'Error from method cloneSubscriptionOpportunity: ' +  e.getMessage()+'\n'+e.getStackTraceString(), 'OpportunityCloudUtil.cloneSubscriptionOpportunity'); 
                            return null;}  
    }  
    //--Rony Joseph-May 6th 2019 -Ends---
}