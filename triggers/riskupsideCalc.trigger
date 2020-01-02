trigger riskupsideCalc on Account_Revenue_Forecast_Comment__c (After insert, After Update) {

if(Util.Bypass_Trigger_Chk)
return; 

set<id>accids = new set<id>();
list<Account_Revenue_Forecast__c> lstup = new list<Account_Revenue_Forecast__c>();
set<id>ruids = new set<id>();
//set<id>weekids = new set<id>();


for (Account_Revenue_Forecast_Comment__c irisk: Trigger.new) {

if(trigger.isinsert){
   if(irisk.Amount__c != null && irisk.Reason__c!= null && irisk.Account_Revenue_Forecast__c != null &&  irisk.Quarter__c != null)
        {
            accids.add(irisk.Account_Revenue_Forecast__c);
            ruids.add(irisk.id);            
        }
  }else if(trigger.isupdate){
  if(irisk.Amount__c != trigger.oldmap.get(irisk.id).Amount__c && irisk.Reason__c!= null  && irisk.Account_Revenue_Forecast__c != null && irisk.Quarter__c != null)
  {
  ruids.add(irisk.id);
  accids.add(irisk.Account_Revenue_Forecast__c);
  //weekids.add(irisk.Quarter_Upside_Risk__c);
  }
  
  
  }
 
}

if(ruids.size() > 0){
//system.debug('**ruids*'+ruids);
Set<String> strExclude = new Set<String>();
strExclude.add('Upside - ROY - 2017');
strExclude.add('Upside - ROY - 2018');
strExclude.add('Upside - ROY - 2019');
strExclude.add('Upside - ROY - 2020');
strExclude.add('Upside - ROY - 2021');
strExclude.add('Risk - ROY - 2017');
strExclude.add('Risk - ROY - 2018');
strExclude.add('Risk - ROY - 2019');
strExclude.add('Risk - ROY - 2020');
strExclude.add('Risk - ROY - 2021');
 //list<AggregateResult> agg = [SELECT sum(Amount__c) tot,Account_Revenue_Forecast__c,Reason__c, Quarter__c from Account_Revenue_Forecast_Comment__c WHERE id IN: ruids AND Account_Revenue_Forecast__c IN: accids group by Account_Revenue_Forecast__c,Reason__c,Quarter__c];
 list<AggregateResult> agg = [SELECT sum(Amount__c) tot,Account_Revenue_Forecast__c,Reason__c, Quarter__c from Account_Revenue_Forecast_Comment__c 
                                        WHERE Account_Revenue_Forecast__c IN: accids and Quarter_Upside_Risk__c Not in : strExclude group by Account_Revenue_Forecast__c,Reason__c,Quarter__c];
 //system.debug('**agg1*'+agg);
 List<Account_Revenue_Forecast__c> lstaddrev = [SELECT id, Account__c,Annual_Contract_Value__c,April_2016_PE__c,Apr_2016__c,Apr_2017__c,Apr_2018_BE__c,Apr_2018__c,Aug_2016_PE__c,Aug_2016__c,Aug_2017__c,Aug_2018_BE__c,Aug_2018__c,
                Aug_2019__c,Aug_2020__c,Best_Change_Q1__c,Best_Change_Q2__c,Best_Change_Q3__c,Best_Change_Q4__c,Best__c,BE_2016_PS_Best__c,BE_2016_PS_Land__c,BE_2016_PS_Low__c,
                BE_2016_Subscription_Best__c,BE_2016_Subscription_Land__c,BE_2016_Subscription_Low__c,BE_2016_Total_Land__c,BE_2016_Total_Low__c,BE_EE_Flag_2__c,BE_EE_Flag__c,BQ2_PS_Land__c,
                BQ3_PS_Land__c,BQ4_PS_Land__c,Change_Best__c,Change_Land__c,Change_Low__c,Change_PS__c,Change_Q1_2017_Subscription__c,Change_Q1_Land__c,Change_Q2_2017_Subscription__c,Change_Q2_Land__c,
                Change_Q3_2017_Subscription__c,Change_Q3_Land__c,Change_Q4_2017_Subscription__c,Change_Q4_Land__c,Change_Subscription_Land__c,Cloned_From__c,Cloud_Forecast_Quarter__c,
                CLoud_Platform_Type_Formula__c,Cloud_Platform_Type__c,Comments__c,Comment_Validation__c,Commit__c,ConnectionReceivedId,ConnectionSentId,CSM_Owner__c,
                CurrencyIsoCode,Days_to_Go_Live__c,Days_to_Steady_State__c,Dec_2016_PE__c,Dec_2016__c,Dec_2017__c,Dec_2018_BE__c,Dec_2018__c,Dec_2019__c,Feb_2016_PE__c,Feb_2016__c,Feb_2017__c,
                IsDeleted,Jan_2016_PE__c,Jan_2016__c,Jan_2017__c,Jan_2018_BE__c,Jan_2018__c,Jan_2019__c,Jan_2020__c,
                July_2016_PE__c,July_2016__c,July_2017__c,July_2018__c,July_2019__c,July_2020__c,Jul_2017_BE__c,June_2016__c,June_2017_BE__c,June_2017__c,June_2018__c,June_2019__c,June_2020__c,
                Jun_2016_PE__c,Land_Change_Q1__c,Land_Change_Q2__c,Land_Change_Q3__c,Land_Change_Q4__c,Land__c,LOB1__c,
                LOB_O__c,LOB__c,Low_Change_Q1__c,Low_Change_Q2__c,Low_Change_Q3__c,Low_Change_Q4__c,LOW_LOB__c,Manual_Update__c,Mar_2016_PE__c,Mar_2016__c,Mar_2017__c,Mar_2018_BE__c,Mar_2018__c,
                Mar_2019__c,Mar_2020__c,May_2016_PE__c,May_2016__c,May_2017__c,May_2018_BE__c,May_2018__c,May_2019__c,May_2020__c,Name,New_Logo_2016__c,New_Logo_2017__c,Nov_2016_PE__c,Nov_2016__c,
                Nov_2017__c,Nov_2018_BE__c,Nov_2018__c,Nov_2019__c,Nov_2020__c,Oct_2016_PE__c,Oct_2016__c,Oct_2017__c,Oct_2018_BE__c,Oct_2018__c,Oct_2019__c,Oct_2020__c,OwnerId,PE_OB_Flag__c,
                PE_SS_Flag__c,Previous_Week_Best__c,Previous_Week_Commit__c,Previous_Week_Land__c,Previous_Week__c,PS_Best__c,PS_Land__c,PS_Low__c,Q1_2016_Best_Diff__c,Q1_2016_Best__c,
                Q1_2016_Land_Diff__c,Q1_2016_Land__c,Q1_2016_Low_Diff__c,Q1_2016_Low__c,Q1_2016_Risk__c,Q1_2016_Target1__c,Q1_2016_Target__c,Q1_2016_Upside__c,Q1_2017_Best__c,
                Q1_2017_Land_Subscribe__c,Q1_2017_Land__c,Q1_2017_Low_Diff__c,Q1_2017_Low_Subscription__c,Q1_2017_Low__c,Q1_2017_Risk__c,Q1_2017_Set_Target__c,Q1_2017_Target1__c,Q1_2017_Upside__c,
                Q1_2018_Best__c,Q1_2018_Land_Subscribe__c,Q1_2018_Land__c,Q1_2018_Low_Subscription__c,Q1_2018_Low__c,Q1_2018_Target1__c,Q1_2019_Best__c,Q1_2019_Forecast__c,Q1_2019_Land_Subscribe__c,
                Q1_2019_Land__c,Q1_2019_Low_Subscription__c,Q1_2019_Low__c,Q1_2019_Risk__c,Q1_2019_Target__c,Q1_2019_Upside__c,Q1_2020_Best__c,Q1_2020_Land_Subscribe__c,Q1_2020_Land__c,
                Q1_2020_Low_Subscription__c,Q1_PS_Change__c,Q1_Week__c,Q2_2016_Best_Diff__c,Q2_2016_Best__c,Q2_2016_Land_Diff__c,Q2_2016_Land__c,Q2_2016_Low_Diff__c,Q2_2016_Low__c,Q2_2016_Risk__c,
                Q2_2016_Target1__c,Q2_2016_Target__c,Q2_2016_Upside__c,Q2_2017_Best_Diff__c,Q2_2017_Best__c,Q2_2017_Land_Diff__c,Q2_2017_Land_Subs__c,Q2_2017_Land__c,Q2_2017_Low_Diff__c,
                Q2_2017_Low_Subs__c,Q2_2017_Low__c,Q2_2017_Risk__c,Q2_2017_Set_Target__c,Q2_2017_Target1__c,Q2_2017_Upside__c,Q2_2018_Best__c,Q2_2018_Land_Subs__c,Q2_2018_Land__c,
                Q2_2018_Low_Subs__c,Q2_2018_Low__c,Q2_2018_Target1__c,Q2_2019_Best__c,Q2_2019_Forecast__c,Q2_2019_Land_Subs__c,Q2_2019_Land__c,Q2_2019_Low_Subs__c,Q2_2019_Low__c,
                Q2_2019_Risk__c,Q2_2019_Target__c,Q2_2019_Upside__c,Q2_2020_Best__c,Q2_2020_Land_Subs__c,Q2_2020_Land__c,Q2_2020_Low_Subs__c,Q2_2020_Low__c,Q2_Change_Land__c,
                Q2_Previous_Week_Land__c,Q2_PS_Best__c,Q2_PS_Change__c,Q2_PS_Land__c,Q2_PS_Low__c,Q2_Quota__c,Q2_Subscription_Best__c,Q2_Subscription_Land__c,Q2_Subscription_Low__c,
                Q2_Total_Best__c,Q2_Total_Land__c,Q2_Total_Low__c,Q2_Week__c,Q3_2016_Best_Diff__c,Q3_2016_Best__c,Q3_2016_Land_Diff__c,Q3_2016_Land__c,Q3_2016_Low_Diff__c,Q3_2016_Low__c,
                Q3_2016_Risk__c,Q3_2016_Target1__c,Q3_2016_Target__c,Q3_2016_Upside__c,Q3_2017_Best_Diff__c,Q3_2017_Best__c,Q3_2017_Land_Diff__c,Q3_2017_Land_Subs__c,Q3_2017_Land__c,
                Q3_2017_Low_Diff__c,Q3_2017_Low_Subs__c,Q3_2017_Low__c,Q3_2017_Risk__c,Q3_2017_Set_Target__c,Q3_2017_Target1__c,Q3_2017_Upside__c,Q3_2018_Best__c,Q3_2018_Land_Subs__c,
                Q3_2018_Land__c,Q3_2018_Low_Subs__c,Q3_2018_Low__c,Q3_2018_Target1__c,Q3_2019_Best__c,Q3_2019_Forecast__c,Q3_2019_Land_Subs__c,Q3_2019_Land__c,Q3_2019_Low_Subs__c,Q3_2019_Low__c,
                Q3_2019_Risk__c,Q3_2019_Target__c,Q3_2019_Upside__c,Q3_2020_Best__c,Q3_2020_Land_Subs__c,Q3_2020_Land__c,Q3_2020_Low_Subs__c,Q3_2020_Low__c,Q3_PS_Change__c,Q3_Week__c,
                Q4_2016_Best_Diff__c,Q4_2016_Best__c,Q4_2016_Land_Diff__c,Q4_2016_Land__c,Q4_2016_Low_Diff__c,Q4_2016_Low__c,Q4_2016_Risk__c,Q4_2016_Target1__c,Q4_2016_Target__c,Q4_2016_Upside__c,
                Q4_2017_Best_Diff__c,Q4_2017_Best__c,Q4_2017_Land_Diff__c,Q4_2017_Land_Subs__c,Q4_2017_Land__c,Q4_2017_Low_Diff__c,Q4_2017_Low_Subs__c,Q4_2017_Low__c,Q4_2017_Risk__c,
                Q4_2017_Set_Target__c,Q4_2017_Target1__c,Q4_2017_Upside__c,Q4_2018_Best__c,Q4_2018_Land_Subs__c,Q4_2018_Land__c,Q4_2018_Low_Subs__c,Q4_2018_Low__c,Q4_2018_Target1__c,
                Q4_2019_Best__c,Q4_2019_Forecast__c,Q4_2019_Land_Subs__c,Q4_2019_Land__c,Q4_2019_Low_Subs__c,Q4_2019_Low__c,Q4_2019_Risk__c,Q4_2019_Target__c,Q4_2019_Upside__c,
                Q4_2020_Best__c,Q4_2020_Land_Subs__c,Q4_2020_Land__c,Q4_2020_Low_Subs__c,Q4_2020_Low__c,Q4_PS_Change__c,Q4_Week__c,Quota__c,Revenue_2018__c,Revenue_Forecast_Target_Multiplier__c,
                Revenue__c,Sept_2016__c,Sept_2017__c,Sept_2018__c,Sept_2019__c,Sept_2020__c,Sep_2016_PE__c,Sep_2018__c,Sep_2019__c,Status__c,Steady_State__c,Subscription_Best__c,Subscription_Land__c,
                Subscription_Low__c,Subscription__c,SystemModstamp,Total_2017_BE_PS__c,Total_2017_BE_Subscription__c,Total_2017_Land_BE__c,Total_Best_Formula__c,Total_Best__c,Total_Change__c,
                Total_Land_c__c,Total_Land_Formula__c,Total_Land__c,Total_Low_Formula__c,Total_Low__c,Total_Q1_BE__c,Total_Q2_BE__c,Total_Q3_BE__c,Total_Q4_BE__c,Week_Date__c,Weight_Avg__c,X2014_Q1__c,
                X2014_Q2__c,X2014_Q3__c,X2014_Q4__c,X2014__c,X2015_Q1__c,X2015_Q2__c,X2015_Q3__c,X2015_Q4__c,X2015__c,X2016_Best__c,X2016_Land_Change__c,X2016_Land__c,X2016_Low__c,
                X2016_Q4_Land_Change__c,X2016_Quota__c,X2016_Risk__c,X2016_Target__c,X2016_Upside__c,X2017_Best__c,X2017_Change_Land__c,X2017_Land__c,X2017_Low__c,X2017_Q4_Change_Land__c,
                X2018_Best__c,X2018_Land_Change__c,X2018_Land__c,X2018_Low__c,X2019_Best__c,X2019_Land__c,X2019_Target__c,X2020_Best__c,X2020_Land__c,X2020_Low__c,X2021_Best__c, X2021_Land__c, X2021_Low__c, X2021_Target__c, Apr_2021__c, Aug_2021__c, Dec_2021__c, Feb_2021__c, Jan_2021__c, July_2021__c, June_2021__c,
                Mar_2021__c, May_2021__c, Nov_2021__c, Q1_2021_Best__c, Q1_2021_Land__c, Q1_2021_Low__c, Q1_2021_Target1__c,   Q2_2021_Best__c, Q2_2021_Land__c,
                Q2_2021_Low__c, Q2_2021_Target1__c, Q3_2021_Best__c, Q3_2021_Land__c, Q3_2021_Low__c, Q3_2021_Target1__c, Q4_2021_Best__c, Q4_2021_Land__c, Q4_2021_Low__c,
                Q4_2021_Target1__c, Sept_2021__c            FROM Account_Revenue_Forecast__c WHERE   id IN : accids];
                
                for(Account_Revenue_Forecast__c iacc: lstaddrev){
                Account_Revenue_Forecast__c updateval = new Account_Revenue_Forecast__c();
                updateval = iacc;
                for(AggregateResult ar: agg){
               // system.debug('**'+ar.get('Reason__c'));
                // system.debug('**'+ar.get('Account_Revenue_Forecast__c'));
                //  system.debug('**'+iacc.id);
                if(ar.get('Reason__c') == 'Risk'){
                    /* Insert risk for year 2018 */
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '1-2017')
                        {
                        updateval.Q1_2017_Low__c = double.valueof(ar.get('tot'));
                        }
                        
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '2-2017')
                        {
                        updateval.Q2_2017_Low__c = double.valueof(ar.get('tot'));
                        }
                        
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '3-2017')
                        {
                        updateval.Q3_2017_Low__c = double.valueof(ar.get('tot'));
                        }
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '4-2017')
                        {
                        updateval.Q4_2017_Low__c = double.valueof(ar.get('tot'));
                        
                        }
                    /* Insert risk for year 2018 */
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '1-2018')
                        {
                        updateval.Q1_2018_Low__c = double.valueof(ar.get('tot'));
                        }
                        
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '2-2018')
                        {
                        updateval.Q2_2018_Low__c = double.valueof(ar.get('tot'));
                        }
                        
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '3-2018')
                        {
                        updateval.Q3_2018_Low__c = double.valueof(ar.get('tot'));
                        }
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '4-2018')
                        {
                        updateval.Q4_2018_Low__c = double.valueof(ar.get('tot'));
                        
                        }
                        
                    /* Insert risk for year 2019*/
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '1-2019')
                        {
                        updateval.Q1_2019_Low__c = double.valueof(ar.get('tot'));
                        }
                        
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '2-2019')
                        {
                        updateval.Q2_2019_Low__c = double.valueof(ar.get('tot'));
                        }
                        
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '3-2019')
                        {
                        updateval.Q3_2019_Low__c = double.valueof(ar.get('tot'));
                        }
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '4-2019')
                        {
                        updateval.Q4_2019_Low__c = double.valueof(ar.get('tot'));
                        
                        }
                    /* Insert risk for year 2020*/
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '1-2020')
                        {
                        updateval.Q1_2020_Low__c = double.valueof(ar.get('tot'));
                        }
                        
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '2-2020')
                        {
                        updateval.Q2_2020_Low__c = double.valueof(ar.get('tot'));
                        }
                        
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '3-2020')
                        {
                        updateval.Q3_2020_Low__c = double.valueof(ar.get('tot'));
                        }
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '4-2020')
                        {
                        updateval.Q4_2020_Low__c = double.valueof(ar.get('tot'));
                        
                        }
                    /* Insert risk for year 2021 */
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '1-2021')
                        {
                        updateval.Q1_2021_Low__c = double.valueof(ar.get('tot'));
                        }
                        
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '2-2021')
                        {
                        updateval.Q2_2021_Low__c = double.valueof(ar.get('tot'));
                        }
                        
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '3-2021')
                        {
                        updateval.Q3_2021_Low__c = double.valueof(ar.get('tot'));
                        }
                     if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '4-2021')
                        {
                        updateval.Q4_2021_Low__c = double.valueof(ar.get('tot'));
                        
                        }                   
                    
                        
                    }else if(ar.get('Reason__c') == 'Upside'){
                    
                    /* Insert upside for 2017 */
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '1-2017')
                        {
                        updateval.Q1_2017_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '2-2017')
                        {
                        updateval.Q2_2017_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '3-2017')
                        {
                        updateval.Q3_2017_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '4-2017')
                        {
                        updateval.Q4_2017_Best__c = double.valueof(ar.get('tot'));
                        }
                    /* Insert upside for 2018   */
                        if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '1-2018')
                        {
                        updateval.Q1_2018_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '2-2018')
                        {
                        updateval.Q2_2018_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '3-2018')
                        {
                        updateval.Q3_2018_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '4-2018')
                        {
                        updateval.Q4_2018_Best__c = double.valueof(ar.get('tot'));
                        }
                    /* Insert upside for 2019   */
                        if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '1-2019')
                        {
                        updateval.Q1_2019_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '2-2019')
                        {
                        updateval.Q2_2019_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '3-2019')
                        {
                        updateval.Q3_2019_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '4-2019')
                        {
                        updateval.Q4_2019_Best__c = double.valueof(ar.get('tot'));
                        }
                    /* Insert upside for 2020   */
                        if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '1-2020')
                        {
                        updateval.Q1_2020_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '2-2020')
                        {
                        updateval.Q2_2020_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '3-2020')
                        {
                        updateval.Q3_2020_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '4-2020')
                        {
                        updateval.Q4_2020_Best__c = double.valueof(ar.get('tot'));
                        }
                    /* Insert upside for 2021   */
                        if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '1-2021')
                        {
                        updateval.Q1_2021_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '2-2021')
                        {
                        updateval.Q2_2021_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '3-2021')
                        {
                        updateval.Q3_2021_Best__c = double.valueof(ar.get('tot'));
                        }
                    if(ar.get('Account_Revenue_Forecast__c') == iacc.id && ar.get('Quarter__c')== '4-2021')
                        {
                        updateval.Q4_2021_Best__c = double.valueof(ar.get('tot'));
                        }
                        
                    
                    }
                    
                    
                }
                lstup.add(updateval);

}
}
 //system.debug('navaneet1' + lstup);
  if(lstup.size() > 0){
      update lstup;
  }
}