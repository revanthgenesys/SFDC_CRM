//Naresh Kumar  12/04/2017
public with sharing class PESSRevForecastCommentsController2018 {
    public String selectedTab {get;set;}
    public String selectedQuarter {get;set;}
    public List<commentWrapper> listOfComments {get;set;}
    public Boolean showResult {get;set;}
    public String selectedLOB {get;set;}
    public String sortBy {get;set;}    
    public Boolean hideQ1 {get;set;}
    public Boolean hideQ2 {get;set;}
    public Boolean hideQ3 {get;set;}
    public Boolean hideQ4 {get;set;}    
    public String selectedWeek{get;set;}
    public String selectedCs{get;set;}
    public String page {get;set;}
    public PESSRevForecastCommentsController2018(){
        selectedTab = 'tabComment';
        //selectedQuarter = '1-2018';
        if(ApexPages.currentPage().getParameters().get('q') != null)    
            selectedQuarter = ApexPages.currentPage().getParameters().get('q');
        if(ApexPages.currentPage().getParameters().get('lob') != null)    
            selectedLOB = ApexPages.currentPage().getParameters().get('lob');
        if(ApexPages.currentPage().getParameters().get('sortBy') != null)    
            sortBy = ApexPages.currentPage().getParameters().get('sortBy');
        if(ApexPages.currentPage().getParameters().get('hideQ1') != null)    
            hideQ1 = Boolean.valueOf(ApexPages.currentPage().getParameters().get('hideQ1'));
        if(ApexPages.currentPage().getParameters().get('hideQ2') != null)    
            hideQ2 = Boolean.valueOf(ApexPages.currentPage().getParameters().get('hideQ2'));
        if(ApexPages.currentPage().getParameters().get('hideQ3') != null)    
            hideQ3 = Boolean.valueOf(ApexPages.currentPage().getParameters().get('hideQ3'));
        if(ApexPages.currentPage().getParameters().get('hideQ4') != null)    
            hideQ4 = Boolean.valueOf(ApexPages.currentPage().getParameters().get('hideQ4'));
        if(ApexPages.currentPage().getParameters().get('week') != null)    
            selectedWeek = ApexPages.currentPage().getParameters().get('week');
        if(ApexPages.currentPage().getParameters().get('csm') != null)    
            selectedCs = ApexPages.currentPage().getParameters().get('csm');
        page = ApexPages.currentPage().getParameters().get('page');
        init();
    }
    
    public void search(){               
        init();     
        
    }
    
    private void init(){
        showResult = false;
        List<Account_Revenue_Forecast__c> accountRevenueForecast;  
        String revenueForecastQuery = 'SELECT Account__c, Account__r.Name, Q1_2018_Low__c, Q2_2018_Low__c,' +
        ' Account__r.Region__c, Account__r.PE_Platform__c, Account__r.CSM_Account_Owner__r.Name, Account__r.Key_Account_Group__c, Account__r.PE_Status_type__c,Account__r.PE_Status__c,Account__r.Type, LOB__c, Cloud_Forecast_Quarter__r.Quarter__c,' +
            ' Q3_2018_Low__c, Q4_2018_Low__c, Q1_2018_Best__c, Q2_2018_Best__c, Q3_2018_Best__c, Q4_2018_Best__c,' +
            ' Low_Change_Q1__c, Low_Change_Q2__c, Low_Change_Q3__c, Low_Change_Q4__c, Land_Change_Q1__c, Land_Change_Q2__c, Land_Change_Q3__c, Land_Change_Q4__c,'+
            ' Best_Change_Q1__c, Best_Change_Q2__c, Best_Change_Q3__c, Best_Change_Q4__c, Q1_2016_Low_Diff__c, Q2_2016_Low_Diff__c, Q3_2016_Low_Diff__c, Q4_2016_Low_Diff__c, ' +
            ' Q1_2016_Land_Diff__c, Q2_2016_Land_Diff__c, Q3_2016_Land_Diff__c, Q4_2016_Land_Diff__c,' +
            ' Q1_2016_Best_Diff__c, Q2_2016_Best_Diff__c, Q3_2016_Best_Diff__c, Q4_2016_Best_Diff__c,' +
            ' (SELECT Account_Formula__c, Amount__c, By_Whom__c, By_When__c, Comment__c, Likely__c, Reason__c, Whats_Needed__c, Weight_Avg__c, Quarter__c FROM Account_Revenue_Forecast_Comments__r where  Account_Formula__c >= 10000 ORDER BY Weight_Avg__c DESC)' +
            ' FROM Account_Revenue_Forecast__c' +           
            ' WHERE Comment_Validation__c = true  and Cloud_Forecast_Quarter__c =:selectedWeek' + 
            ' ORDER BY Cloud_Forecast_Quarter__r.Quarter__c ASC, Weight_Avg__c DESC limit 300';
        /*
        if(selectedQuarter != null && selectedQuarter != ''){
            revenueForecastQuery += ' AND Cloud_Forecast_Quarter__r.Quarter__c =: selectedQuarter ';
        }
        */      
        System.debug(LoggingLevel.INFO, 'NKC debug selectedQuarter ['+selectedQuarter+']');
        System.debug(LoggingLevel.INFO, 'NKC debug revenueForecastQuery ['+revenueForecastQuery+']');
        accountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);
        listOfComments = new List<commentWrapper>();
        Set<String> setOfQuarter = new Set<String>();
        Integer threshold = 10000;
        Integer negatvieThreshold = -10000;
        System.debug(LoggingLevel.INFO, 'NKC debug page ['+page+']');
        
        Revenue_Forecast_User_Quarters__c quarters = Revenue_Forecast_User_Quarters__c.getInstance(UserInfo.getUserId());
        Boolean hideQ1 = quarters.Q1__c;
        Boolean hideQ2 = quarters.Q2__c;
        Boolean hideQ3 = quarters.Q3__c;
        Boolean hideQ4 = quarters.Q4__c;
        
        if(page == 'Change'){
            List<commentWrapper> listOfQ1Change = new List<commentWrapper>();
            List<commentWrapper> listOfQ2Change = new List<commentWrapper>();
            List<commentWrapper> listOfQ3Change = new List<commentWrapper>();
            List<commentWrapper> listOfQ4Change = new List<commentWrapper>();
            //Looping over each record      
            for(Account_Revenue_Forecast__c eachRecord : accountRevenueForecast){
                if(!hideQ1 && (eachRecord.Q1_2016_Low_Diff__c > threshold || eachRecord.Q1_2016_Low_Diff__c < negatvieThreshold
                    || eachRecord.Q1_2016_Land_Diff__c > threshold || eachRecord.Q1_2016_Land_Diff__c < negatvieThreshold
                    || eachRecord.Q1_2016_Best_Diff__c > threshold || eachRecord.Q1_2016_Best_Diff__c < negatvieThreshold)){
                    commentWrapper newChange = new commentWrapper();
                    newChange.isHeader = false;
                    newChange.revenueForecast = eachRecord;             
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Change', '1-2018');                    
                    newChange.comment = comment;
                    newChange.comment.Quarter_Upside_Risk__c = 'Q1 - Change';
                    /* if(eachRecord.Q1_2017_Low_Diff__c > threshold || eachRecord.Q1_2017_Low_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Low';
                      comment.Amount__c = eachRecord.Q1_2017_Low_Diff__c;
                    }
                   */
                     if(eachRecord.Q1_2016_Land_Diff__c > threshold || eachRecord.Q1_2016_Land_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Land';
                      comment.Amount__c = eachRecord.Q1_2016_Land_Diff__c;
                     listOfQ1Change.add(newChange);
                    }
                   
                   /* else if(eachRecord.Q1_2017_Best_Diff__c > threshold || eachRecord.Q1_2017_Best_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Best';
                      comment.Amount__c = eachRecord.Q1_2017_Best_Diff__c;
                    } */                     
                    
                }
                if(!hideQ2 && (eachRecord.Q2_2016_Low_Diff__c > threshold || eachRecord.Q2_2016_Low_Diff__c < negatvieThreshold
                    || eachRecord.Q2_2016_Land_Diff__c > threshold || eachRecord.Q2_2016_Land_Diff__c < negatvieThreshold
                    || eachRecord.Q2_2016_Best_Diff__c > threshold || eachRecord.Q2_2016_Low_Diff__c < negatvieThreshold)){
                    commentWrapper newChange = new commentWrapper();
                    newChange.isHeader = false;
                    newChange.revenueForecast = eachRecord;             
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Change', '2-2018');
                    comment.Amount__c = eachRecord.Low_Change_Q2__c;
                    newChange.comment = comment;
                    newChange.comment.Quarter_Upside_Risk__c = 'Q2 - Change';
                    /*if(eachRecord.Q2_2017_Low_Diff__c > threshold || eachRecord.Q2_2017_Low_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Low';
                      comment.Amount__c = eachRecord.Q2_2017_Low_Diff__c;
                    }*/
                    if(eachRecord.Q2_2016_Land_Diff__c > threshold || eachRecord.Q2_2016_Land_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Land';
                      comment.Amount__c = eachRecord.Q2_2016_Land_Diff__c;
                      listOfQ2Change.add(newChange);
                    }
                   
                   /* else if(eachRecord.Q2_2017_Best_Diff__c > threshold || eachRecord.Q2_2017_Best_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Best';
                      comment.Amount__c = eachRecord.Q2_2017_Best_Diff__c;
                    } */
                    
                }
                if(!hideQ3 && (eachRecord.Q3_2016_Low_Diff__c > threshold || eachRecord.Q3_2016_Low_Diff__c < negatvieThreshold
                    || eachRecord.Q3_2016_Land_Diff__c > threshold || eachRecord.Q3_2016_Land_Diff__c < negatvieThreshold
                    || eachRecord.Q3_2016_Best_Diff__c > threshold || eachRecord.Q3_2016_Low_Diff__c < negatvieThreshold)){
                    commentWrapper newChange = new commentWrapper();
                    newChange.isHeader = false;
                    newChange.revenueForecast = eachRecord;             
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Change', '3-2018');
                    comment.Amount__c = eachRecord.Low_Change_Q3__c;
                    newChange.comment = comment;
                    newChange.comment.Quarter_Upside_Risk__c = 'Q3 - Change';
                   /* if(eachRecord.Q3_2017_Low_Diff__c > threshold || eachRecord.Q3_2017_Low_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Low';
                      comment.Amount__c = eachRecord.Q3_2017_Low_Diff__c;
                    }*/
                    if(eachRecord.Q3_2016_Land_Diff__c > threshold || eachRecord.Q3_2016_Land_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Land';
                      comment.Amount__c = eachRecord.Q3_2016_Land_Diff__c;
                       listOfQ3Change.add(newChange);
                    }
                    /*else if(eachRecord.Q3_2017_Best_Diff__c > threshold || eachRecord.Q3_2017_Best_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Best';
                      comment.Amount__c = eachRecord.Q3_2017_Best_Diff__c;
                    }*/
                   
                }
                if(!hideQ4 && (eachRecord.Q4_2016_Low_Diff__c > threshold || eachRecord.Q4_2016_Low_Diff__c < negatvieThreshold
                    || eachRecord.Q4_2016_Land_Diff__c > threshold || eachRecord.Q4_2016_Land_Diff__c < negatvieThreshold
                    || eachRecord.Q4_2016_Best_Diff__c > threshold || eachRecord.Q4_2016_Low_Diff__c < negatvieThreshold)){
                    commentWrapper newChange = new commentWrapper();
                    newChange.isHeader = false;
                    newChange.revenueForecast = eachRecord;             
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Change', '4-2018');
                    comment.Amount__c = eachRecord.Low_Change_Q4__c;
                    newChange.comment = comment;
                    newChange.comment.Quarter_Upside_Risk__c = 'Q4 - Change';
                   /* if(eachRecord.Q4_2017_Low_Diff__c > threshold || eachRecord.Q4_2017_Low_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Low';
                      comment.Amount__c = eachRecord.Q4_2017_Low_Diff__c;
                    } */
                    if(eachRecord.Q4_2016_Land_Diff__c > threshold || eachRecord.Q4_2016_Land_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Land';
                      comment.Amount__c = eachRecord.Q4_2016_Land_Diff__c;
                       listOfQ4Change.add(newChange);
                    }
                    /*else if(eachRecord.Q4_2017_Best_Diff__c > threshold || eachRecord.Q4_2017_Best_Diff__c < negatvieThreshold){
                      newChange.changeType = 'Best';
                      comment.Amount__c = eachRecord.Q4_2017_Best_Diff__c;
                    }*/
                   
                }               
            }
            if(!listOfQ1Change.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Q1 - Change';
                newHeader.style = 'background-color:#cccccc;';      
                listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ1Change);  
            }
            if(!listOfQ2Change.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Q2 - Change';
                newHeader.style = 'background-color:#cccccc;';      
                listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ2Change);  
            }
            if(!listOfQ3Change.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Q3 - Change';
                newHeader.style = 'background-color:#cccccc;';      
                listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ3Change);  
            }
            if(!listOfQ4Change.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Q4 - Change';
                newHeader.style = 'background-color:#cccccc;';      
                listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ4Change);  
            }
            System.debug(LoggingLevel.INFO, 'NKC debug listOfComments ['+listOfComments+']');
        }
        else{
            //Integer currentYear = System.today().year();          
            //Upside
            //Risk
            List<commentWrapper> listOfQ1Upside = new List<commentWrapper>();
            List<commentWrapper> listOfQ2Upside = new List<commentWrapper>();
            List<commentWrapper> listOfQ3Upside = new List<commentWrapper>();
            List<commentWrapper> listOfQ4Upside = new List<commentWrapper>();       
            //Looping over each record      
            for(Account_Revenue_Forecast__c eachRecord : accountRevenueForecast){
                eachRecord.Q1_2018_Best__c = eachRecord.Q1_2018_Best__c == null ? 0 : eachRecord.Q1_2018_Best__c;
                eachRecord.Q2_2018_Best__c = eachRecord.Q2_2018_Best__c == null ? 0 : eachRecord.Q2_2018_Best__c;
                eachRecord.Q3_2018_Best__c = eachRecord.Q3_2018_Best__c == null ? 0 : eachRecord.Q3_2018_Best__c;
                eachRecord.Q4_2018_Best__c = eachRecord.Q4_2018_Best__c == null ? 0 : eachRecord.Q4_2018_Best__c;
                
                if(!hideQ1 && eachRecord.Q1_2018_Best__c > threshold){
                    commentWrapper newUpside = new commentWrapper();
                    newUpside.isHeader = false;
                    newUpside.revenueForecast = eachRecord;             
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Upside', '1-2018');
                    comment.Amount__c = eachRecord.Q1_2018_Best__c;
                    newUpside.comment = comment;
                    newUpside.comment.Quarter_Upside_Risk__c = 'Q1-2018 - Upside';
                    listOfQ1Upside.add(newUpside);
                }
                if(!hideQ2 && (eachRecord.Q2_2018_Best__c + eachRecord.Q3_2018_Best__c + eachRecord.Q4_2018_Best__c ) > threshold){
                    commentWrapper newUpside = new commentWrapper();
                    newUpside.isHeader = false;
                    newUpside.revenueForecast = eachRecord;             
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Upside', '2-2018');
                    comment.Amount__c = eachRecord.Q2_2018_Best__c + eachRecord.Q3_2018_Best__c + eachRecord.Q4_2018_Best__c;
                    newUpside.comment = comment;
                    newUpside.comment.Quarter_Upside_Risk__c = 'ROW-2018 - Upside';
                    listOfQ2Upside.add(newUpside);
                }
                /*
                if(!hideQ3 && eachRecord.Q3_2017_Upside__c > threshold){
                    commentWrapper newUpside = new commentWrapper();
                    newUpside.isHeader = false;
                    newUpside.revenueForecast = eachRecord;             
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Upside', '3-2018');
                    comment.Amount__c = eachRecord.Q3_2017_Upside__c;
                    newUpside.comment = comment;
                    newUpside.comment.Quarter_Upside_Risk__c = 'Q3 - Upside';
                    listOfQ3Upside.add(newUpside);
                }
                if(!hideQ4 && eachRecord.Q4_2017_Upside__c > threshold){
                    commentWrapper newUpside = new commentWrapper();
                    newUpside.isHeader = false;
                    newUpside.revenueForecast = eachRecord;             
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Upside', '4-2018');
                    comment.Amount__c = eachRecord.Q4_2017_Upside__c;
                    newUpside.comment = comment;
                    newUpside.comment.Quarter_Upside_Risk__c = 'Q4 - Upside';
                    listOfQ4Upside.add(newUpside);
                }
                */
            }
            
            if(!listOfQ1Upside.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Q1-2018 - Upside';
                newHeader.style = 'background-color:#cccccc;';      
                listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ1Upside);  
            }
            if(!listOfQ2Upside.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Rest of the year-2018 - Upside';
                newHeader.style = 'background-color:#cccccc;';      
                listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ2Upside);  
            }
            /*
            if(!listOfQ3Upside.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Q3 - Upside';
                newHeader.style = 'background-color:#cccccc;';      
                //listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ3Upside);  
            }
            if(!listOfQ4Upside.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Q4 - Upside';
                newHeader.style = 'background-color:#cccccc;';      
                //listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ4Upside);  
            }
            */
          //Risk
            List<commentWrapper> listOfQ1Risk = new List<commentWrapper>();
            List<commentWrapper> listOfQ2Risk = new List<commentWrapper>();
            List<commentWrapper> listOfQ3Risk = new List<commentWrapper>();
            List<commentWrapper> listOfQ4Risk = new List<commentWrapper>();     
            //Looping over each record      
            for(Account_Revenue_Forecast__c eachRecord : accountRevenueForecast){
                eachRecord.Q1_2018_Low__c = eachRecord.Q1_2018_Low__c == null ? 0 : eachRecord.Q1_2018_Low__c;
                eachRecord.Q2_2018_Low__c = eachRecord.Q2_2018_Low__c == null ? 0 : eachRecord.Q2_2018_Low__c;
                eachRecord.Q3_2018_Low__c = eachRecord.Q3_2018_Low__c == null ? 0 : eachRecord.Q3_2018_Low__c;
                eachRecord.Q4_2018_Low__c = eachRecord.Q4_2018_Low__c == null ? 0 : eachRecord.Q4_2018_Low__c;
                
                if(!hideQ4 && eachRecord.Q1_2018_Low__c > threshold){
                    commentWrapper newRisk = new commentWrapper();
                    newRisk.isHeader = false;
                    newRisk.revenueForecast = eachRecord;               
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Risk', '1-2018');
                    comment.Amount__c = eachRecord.Q1_2018_Low__c;
                    newRisk.comment = comment;
                    newRisk.comment.Quarter_Upside_Risk__c = 'Q1-2018 - Risk';
                    listOfQ1Risk.add(newRisk);
                }          
                if(!hideQ3 && (eachRecord.Q2_2018_Low__c + eachRecord.Q3_2018_Low__c + eachRecord.Q4_2018_Low__c) > threshold){
                    commentWrapper newRisk = new commentWrapper();
                    newRisk.isHeader = false;
                    newRisk.revenueForecast = eachRecord;               
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Risk', '2-2018');
                    comment.Amount__c =   eachRecord.Q2_2018_Low__c + eachRecord.Q3_2018_Low__c + eachRecord.Q4_2018_Low__c;
                    newRisk.comment = comment;
                    newRisk.comment.Quarter_Upside_Risk__c = 'ROW-2018 - Risk';
                    listOfQ2Risk.add(newRisk);
                }           
               /*
                if(!hideQ3 && eachRecord.Q3_2017_Risk__c > threshold){
                    commentWrapper newRisk = new commentWrapper();
                    newRisk.isHeader = false;
                    newRisk.revenueForecast = eachRecord;               
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Risk', '3-2018');
                    comment.Amount__c = eachRecord.Q3_2017_Risk__c;
                    newRisk.comment = comment;
                    newRisk.comment.Quarter_Upside_Risk__c = 'Q3 - Risk';
                    listOfQ3Risk.add(newRisk);
                }           
                if(!hideQ4 && eachRecord.Q4_2017_Risk__c > threshold){
                    commentWrapper newRisk = new commentWrapper();
                    newRisk.isHeader = false;
                    newRisk.revenueForecast = eachRecord;               
                    Account_Revenue_Forecast_Comment__c comment = populateCommentRecord(eachRecord, 'Risk', '4-2018');
                    comment.Amount__c = eachRecord.Q4_2017_Risk__c;
                    newRisk.comment = comment;
                    newRisk.comment.Quarter_Upside_Risk__c = 'Q4 - Risk';
                    listOfQ4Risk.add(newRisk);
                }           
              */  
            }
            if(!listOfQ1Risk.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Q1-2018 - Risk';
                newHeader.style = 'background-color:#cccccc;';      
                listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ1Risk);    
            }
            if(!listOfQ2Risk.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Rest of the year-2018 - Risk';
                newHeader.style = 'background-color:#cccccc;';      
                listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ2Risk);    
            }
            /*
            if(!listOfQ3Risk.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Q3 - Risk';
                newHeader.style = 'background-color:#cccccc;';      
                //listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ3Risk);    
            }
            if(!listOfQ4Risk.isEmpty()){
                commentWrapper newHeader = new commentWrapper();
                newHeader.isHeader = true;
                newHeader.quarter = 'Q4 - Risk';
                newHeader.style = 'background-color:#cccccc;';      
                //listOfComments.add(newHeader);
                listOfComments.addAll(listOfQ4Risk);   
            }
            */
        }
        Integer counter = 0;
        for(commentWrapper eachComment : listOfComments){
            if(eachComment.isHeader)
                continue;
            counter ++;
            eachComment.SrNo = counter;     
        }       
        if(!listOfComments.isEmpty())
            showResult = true;
    }
    
    private Account_Revenue_Forecast_Comment__c populateCommentRecord(Account_Revenue_Forecast__c revenueForecast, String reason, String quarter){
        Account_Revenue_Forecast_Comment__c newComment = new Account_Revenue_Forecast_Comment__c(Account_Revenue_Forecast__c = revenueForecast.id);
        newComment.Reason__c = reason;
        newComment.Quarter__c = quarter;        
        Integer noOfComments = revenueForecast.Account_Revenue_Forecast_Comments__r.size();
        if(noOfComments > 0){
            for(Account_Revenue_Forecast_Comment__c eachComment : revenueForecast.Account_Revenue_Forecast_Comments__r){
                if(reason == eachComment.Reason__c && quarter == eachComment.Quarter__c)
                    newComment = eachComment;
            }
        }       
        return newComment;              
    }
    
    public void save(){
        List<Account_Revenue_Forecast_Comment__c> commentsToBeInserted = new List<Account_Revenue_Forecast_Comment__c>();
        List<Account_Revenue_Forecast__c> revenueForecastToBeUpdated = new List<Account_Revenue_Forecast__c>();
        Set<Id> setOfARFIds = new Set<Id>();
        //Looping over each comment
        for(commentWrapper eachRecord : listOfComments){
          System.debug('NKC debug page ['+page+']');
            if(eachRecord.isHeader || (page != 'Change' && !eachRecord.isSelected))
                continue;
            Account_Revenue_Forecast_Comment__c newComment = eachRecord.comment;                         
            String currentUserId = UserInfo.getUserId().substring(0, 14);            
            
            if(page != 'Change' && !Label.PESS_Revenue_Forecast_Admins.contains(currentUserId)){
              if((eachRecord.comment.Whats_Needed__c == '' || eachRecord.comment.Whats_Needed__c == null) && !Label.PESS_Revenue_Forecast_Admins.contains(currentUserId)){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter What\'s Needed in order to save the comments.'));
                  return ;                    
              }
              if((eachRecord.comment.By_Whom__c == '' || eachRecord.comment.By_Whom__c == null) && !Label.PESS_Revenue_Forecast_Admins.contains(currentUserId)){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter From Whom in order to save the comments.'));
                  return ;                    
              }
              if(eachRecord.comment.By_When__c == null && !Label.PESS_Revenue_Forecast_Admins.contains(currentUserId)){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter By When in order to save the comments.'));
                  return ;                    
              }
              if(eachRecord.comment.Likely__c == null && !Label.PESS_Revenue_Forecast_Admins.contains(currentUserId)){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Likey in order to save the comments.'));
                  return ;                    
              }
            }
            System.debug('NKC debug page ['+page+']');
            commentsToBeInserted.add(newComment);
            if(!setOfARFIds.contains(newComment.Account_Revenue_Forecast__c)){
                Account_Revenue_Forecast__c ARFToBeUpdated = new Account_Revenue_Forecast__c(id = newComment.Account_Revenue_Forecast__c);
                //ARFToBeUpdated.Comment_Validation__c = false; 
                ARFToBeUpdated.Manual_Update__c = true;
                revenueForecastToBeUpdated.add(ARFToBeUpdated);
                setOfARFIds.add(newComment.Account_Revenue_Forecast__c);
            }
        }
        if(!commentsToBeInserted.isEmpty()){
            upsert commentsToBeInserted;
        }
        if(!revenueForecastToBeUpdated.isEmpty()){
            update revenueForecastToBeUpdated;
        }   
        init();
    }
    
    public class commentWrapper{
      public Boolean isSelected {get;set;}
        public Integer SrNo {get;set;}
        public Boolean isHeader {get;set;}
        public String quarter {get;set;}
        public String style {get;set;}
        public String changeType {get;set;}
        public Account_Revenue_Forecast__c revenueForecast {get;set;}
        public Account_Revenue_Forecast_Comment__c comment {get;set;}
    }
}