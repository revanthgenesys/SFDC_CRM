public with sharing class PESSRevenueForecastFileUploadController {
  
  public Boolean parseOnly{get;set;}
  
  public String operationType{get;set;}
    
  public List<AccountRevnueForecastErrorWrapper> accRevForErrorWrapperList{get;set;}
  
  public List<String> accRevForErrorWrapperListHeader{get;set;}
  
  
  public Blob csvFileBody{get;set;}
  public String[] accountRevForDataLines {get;set;}
  
  public boolean readSuccess {get;set;}
  
  public List<String> lstFieldNames{get;set;}
  Map<String,Integer> fieldNumberMap = new Map <String, Integer>();
  
  List<AccountRevnueForecastWrapper> accRevForWrapList;
  
  String[] csvFieldNames; 
  
 
  String accountRevForecastDataAsString;
  
  
  String fieldValue;
  Integer fieldNumber;
  
  
  
  public PESSRevenueForecastFileUploadController() {
       
       init(); 
         
  }
  
  
  private void init(){
      
      readSuccess = FALSE;
      accountRevForDataLines = new String[] {};
      accRevForWrapList = new List<AccountRevnueForecastWrapper>();
  
      lstFieldNames = new List<String>();
      
      accRevForErrorWrapperList = new List<AccountRevnueForecastErrorWrapper>();
      
  }
  
  
  
  public void processCSVFile(){
        
        init();
        
        try{
            if(csvFileBody != null){
            
                accountRevForecastDataAsString = csvFileBody.toString();
                readCSVFile();
            }else{
                
                
                readSuccess = FALSE;
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select .csv file');
                ApexPages.addMessage(errorMessage);    
                
            }
        }
        catch(Exception exp){
            readSuccess = FALSE;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading CSV file'+exp);
            ApexPages.addMessage(errorMessage);
        }
        
        
       
        
    }
    
    
    
    
  public PageReference readCSVFile() {
      
        PageReference pageRef = null;
        
        accRevForErrorWrapperListHeader = new List<String>();
        
    
        
        List<Boolean> errorIndicatorList;
        
        System.debug('@accountRevForecastDataAsString' + accountRevForecastDataAsString); 
        
        accountRevForDataLines = accountRevForecastDataAsString.split('\n');
        
        if(accountRevForDataLines.size() > 0){
        
            System.debug('accountRevForDataLines ' +accountRevForDataLines);
            
            
            /**********Creating CSV Header ******************/
            String csvFileHeader = accountRevForDataLines[0].trim() + ',' + 'Error Reason';
            
            for(String header : csvFileHeader.split(',')){
                
                accRevForErrorWrapperListHeader.add(header);
                
            }
            System.debug('accRevForErrorWrapperListHeader ' +accRevForErrorWrapperListHeader);
            
            
            /**********Creating CSV Header ******************/
            
            csvFieldNames = accountRevForDataLines[0].split(',');
            
            System.debug('csvFieldNames ' +csvFieldNames);
            
            for (Integer i = 0; i < csvFieldNames.size(); i++) {
                fieldNumberMap.put(csvFieldNames[i], i);
                lstFieldNames.add(csvFieldNames[i].trim());
            }
            
            
            
            for (Integer i = 1; i < accountRevForDataLines.size(); i++) {
                
                //System.debug('accountRevForDataLines ' +accountRevForDataLines[i]);
                
                AccountRevnueForecastWrapper accRevForWrap;
                
               
                
                    System.debug('@Before ' +errorIndicatorList);
                
                    errorIndicatorList = new List<Boolean>();
                    
                    accRevForWrap = new AccountRevnueForecastWrapper(accountRevForDataLines[i],accRevForErrorWrapperList,csvFieldNames,errorIndicatorList);
                
                    System.debug('@After ' +errorIndicatorList);
                
                    
                    //Adding accRevForecastWrap ref to List while checking errorIndicatorList
                    if(!(errorIndicatorList.size() > 0)){
                        accRevForWrapList.add(accRevForWrap);
                    
                    }
                    
                    System.debug('accRevForWrap ' +accRevForWrap);
                    
                    System.debug('accRevForWrapList ' +accRevForWrapList);
                    
            
                
                
            }
           
            
            
            if(accRevForWrapList.size() > 0 && !(accRevForErrorWrapperList.size() > 0)){
                readSuccess = TRUE;
                
                processAccRevWrapper(accRevForWrapList);
                
                
            }else{
                
                //In case of error add Sucees records also.
                for(AccountRevnueForecastWrapper accRevForWrap : accRevForWrapList){
                    AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                    accRevForErrorWrapObj.accId = accRevForWrap.accId;
                    accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                    accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                    accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                    accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                    
                }
                
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Account CSV file having parsing error,please download error file');
                ApexPages.addMessage(errorMessage);
                
                pageRef = Page.PESSRevenueForecastFileUploadErrorCSV;        
        
                
            }  
        
        }
        return pageRef;
        
        
  }
  
  
  public PageReference processAccRevWrapper(List<AccountRevnueForecastWrapper> accountRevnueWrapList){
      
      PageReference pageRef = null; 
      
      //AccountId to List of Opportunity Id Map
      Map<ID,List<ID>> accIdToOppIdListMap = new Map<ID,List<ID>>();
      
      //OpportunityId to Offerring Type Map
      Map<ID,String> oppIdToOfferringTypeMap = new Map<ID,String>();
      
      //OpportunityId to CloseDate Map
      Map<ID,String> oppIdToCloseDateMap = new Map<ID,String>();
      
      
      //AccountId to CloseDatePlus4Months Map
      Map<ID,String> accIdToCloseDatePlus4Map = new Map<ID,String>();
      
      
      //AccountId to Aggregated CMRR value Map
      Map<ID,Decimal> accIdToAggregatedCMRRMap = new Map<ID,Decimal>();
      
      
      
      //AccountId to Set of Opportunity offerring type Map
      Map<ID,Set<String>> accIdToOppOfferringTypeSetMap = new Map<ID,Set<String>>();
      
      
      //AccountId to Set of Opportunity Close Date Month Map
      Map<ID,Set<String>> accIdToSetOfOppCloseDTMonMap = new Map<ID,Set<String>>();
      
      //AccountId to Set of Telco% Map
      Map<ID,Set<Decimal>> accIdToTelcoSetMap = new Map<ID,Set<Decimal>>();
      
      
      //AccountId to List of related  AccountRevnueForecastWrapper Map
      Map<ID,List<AccountRevnueForecastWrapper>> accIdToAccRevForListMap = new Map<ID,List<AccountRevnueForecastWrapper>>();
      
      List<AccountRevnueForecastWrapper> accRevForWrapperList;
      
      
      
      List<Account_Revenue_Forecast__c> accRevForecastListToBeInserted = new List<Account_Revenue_Forecast__c>();     
      
      List<Account_Revenue_Forecast__c> accRevForecastListToBeUpdated = new List<Account_Revenue_Forecast__c>();  
      
      
      
      Set<String> oppCloseDTMonSet;
      
      
      List<ID> oppIdListAssociatedWithAcc;
      
      List<ID> oppIdList = new List<ID>();
      
      Set<ID> accIdSet = new Set<ID>();
      
      Time myTime = Time.newInstance(0, 0, 0, 0);
    
      Decimal cmrrValue = 0.0;  
      
      Set<Decimal> telcoPercentSet;
      
      List<ID> accountIdToBeProcessedForAccRevForecast = new List<ID>();
      
      
      List<String> lobListWithSubscriptionAndTelco = new List<String>{  'A - In-Force Subscription',
                                                                        'D - In-Force Telco'
                                                                    };
                                                
      
      List<String> lobList = new List<String>{  'A - In-Force Subscription',
                                                'B - In-Force Sub Overage',
                                                'C - In-Delivery Subscription',
                                                'D - In-Force Telco',
                                                'E - Telco Overage',
                                                'F - In- Delivery Telco',
                                                'G - TAM'
                                                                    };
      
      
      
      Map<Integer,String> numberToMonthMap = new Map<Integer,String>
                                                                    {1=>'Jan_',
                                                                     2=>'Feb_',    
                                                                     3=>'Mar_',    
                                                                     4=>'Apr_',    
                                                                     5=>'May_',    
                                                                     6=>'June_',    
                                                                     7=>'July_',    
                                                                     8=>'Aug_',    
                                                                     9=>'Sept_',    
                                                                     10=>'Oct_',    
                                                                     11=>'Nov_',    
                                                                     12=>'Dec_' };
      
                                                
      
      /***************************** CSV File Columns ***************************/
      String csvErrorFile;
      
      if(accountRevForDataLines.size() > 0){
           
          csvErrorFile = accountRevForDataLines[0] + ',' + 'Error Reason' + ',' + '\n'; 
      }          
      accRevForErrorWrapperList = new List<AccountRevnueForecastErrorWrapper>(); 
      
      /***************************** CSV File Columns ***************************/       
        
      
      
      for(AccountRevnueForecastWrapper accRevForWrapRec : accountRevnueWrapList){
          
        
           //Holds Opportunity id list
           oppIdList.add(accRevForWrapRec.oppId);
        
           //Holds Account id list    
           accIdSet.add(accRevForWrapRec.accId);
        
        
           
           /********************************Creating Account Id to List of AccountRevnueForecastWrapper Map Start*******************/    

           if(!accIdToAccRevForListMap.isEmpty()){
               
               //If Map contains accid
               if(accIdToAccRevForListMap.containsKey(accRevForWrapRec.accId)){
                   
                   accRevForWrapperList = accIdToAccRevForListMap.get(accRevForWrapRec.accId);
                   
                   accRevForWrapperList.add(accRevForWrapRec);
                   
                   accIdToAccRevForListMap.put(accRevForWrapRec.accId,accRevForWrapperList);
                   
                   
               }else{
                   //If Map don't have accid
                   accRevForWrapperList = new List<AccountRevnueForecastWrapper>();
                   
                   accRevForWrapperList.add(accRevForWrapRec);
                   
                   accIdToAccRevForListMap.put(accRevForWrapRec.accId,accRevForWrapperList);
                   
                   
               }
               
           
           }else{
               //Handling first element
               accRevForWrapperList = new List<AccountRevnueForecastWrapper>();
               
               accRevForWrapperList.add(accRevForWrapRec);
           
               accIdToAccRevForListMap.put(accRevForWrapRec.accId,accRevForWrapperList); 
               
               
           }
           
          /********************************Creating Account Id to List of AccountRevnueForecastWrapper Map End *****************************/    
           
           
        
        
            
           /********************************************Creating Account Id to OppIdList Map Start*******************************************/    

           if(!accIdToOppIdListMap.isEmpty()){
               
               //If Map contains accid
               if(accIdToOppIdListMap.containsKey(accRevForWrapRec.accId)){
                   
                   oppIdListAssociatedWithAcc = accIdToOppIdListMap.get(accRevForWrapRec.accId);
                   
                   oppIdListAssociatedWithAcc.add(accRevForWrapRec.oppId);
                   
                   accIdToOppIdListMap.put(accRevForWrapRec.accId,oppIdListAssociatedWithAcc);
                   
                   
               }else{
                   //If Map don't have accid
                   oppIdListAssociatedWithAcc = new List<ID>();
                   
                   oppIdListAssociatedWithAcc.add(accRevForWrapRec.oppId);
                   
                   accIdToOppIdListMap.put(accRevForWrapRec.accId,oppIdListAssociatedWithAcc);
                   
                   
               }
               
           
           }else{
               //Handling first element
               oppIdListAssociatedWithAcc = new List<ID>();
               
               oppIdListAssociatedWithAcc.add(accRevForWrapRec.oppId);
           
               accIdToOppIdListMap.put(accRevForWrapRec.accId,oppIdListAssociatedWithAcc); 
               
               
           }
           
          /********************************************Creating Account Id to OppIdList Map End *******************************************/    
          
          
          
          /********************************************Creating Account Id to Aggregated CMRR Map Start *******************************************/ 
          
          if(!accIdToAggregatedCMRRMap.isEmpty()){
               
               //If Map contains accid
               if(accIdToAggregatedCMRRMap.containsKey(accRevForWrapRec.accId)){
                   
                   Decimal aggregatedCMRRValue;
                   
                   cmrrValue = accIdToAggregatedCMRRMap.get(accRevForWrapRec.accId);
                   
                   aggregatedCMRRValue = cmrrValue + accRevForWrapRec.cmrrValue;
                   
                   accIdToAggregatedCMRRMap.put(accRevForWrapRec.accId,aggregatedCMRRValue);
                   
                   
               }else{
                   //If Map don't have accid
                   cmrrValue = accRevForWrapRec.cmrrValue;
                   
                   accIdToAggregatedCMRRMap.put(accRevForWrapRec.accId,cmrrValue);
                   
                   
               }
               
           
           }else{
               //Handling first element
               cmrrValue = accRevForWrapRec.cmrrValue;
               
               accIdToAggregatedCMRRMap.put(accRevForWrapRec.accId,cmrrValue); 
               
               
           }
          
         /********************************************Creating Account Id to Aggregated CMRR Map End *******************************************/ 
           
          
        /********************************************Creating Account Id to Set of Telco Map Start*******************************************/    

           if(!accIdToTelcoSetMap.isEmpty()){
               
               //If Map contains accid
               if(accIdToTelcoSetMap.containsKey(accRevForWrapRec.accId)){
                   
                   telcoPercentSet = accIdToTelcoSetMap.get(accRevForWrapRec.accId);
                   
                   telcoPercentSet.add(accRevForWrapRec.telcoPercent);
                   
                   accIdToTelcoSetMap.put(accRevForWrapRec.accId,telcoPercentSet);
                   
                   
               }else{
                   //If Map don't have accid
                   telcoPercentSet = new Set<Decimal>();
                   
                   telcoPercentSet.add(accRevForWrapRec.telcoPercent);
                   
                   accIdToTelcoSetMap.put(accRevForWrapRec.accId,telcoPercentSet);
                   
                   
               }
               
           
           }else{
               //Handling first element
               telcoPercentSet = new Set<Decimal>();
               
               telcoPercentSet.add(accRevForWrapRec.telcoPercent);
           
               accIdToTelcoSetMap.put(accRevForWrapRec.accId,telcoPercentSet); 
               
               
           }
           
          /********************************************Creating Account Id to Set of Telco Map End *******************************************/  
         
          
          
          
          
          
          
      }
      
      Set<ID> fetchedAccIDSet = new Set<ID>();
      
      //Fetching Accounts coressponding to accIdSet for check Account existence
      List<Account> fethedAccList = [Select Id
                                     from Account 
                                     where id in:accIdSet
                                    ];
      
      for(Account acc :fethedAccList){
          
          fetchedAccIDSet.add(acc.Id);
          
      }
      
      
      System.debug('oppIdList '+ oppIdList);
      System.debug('accIdSet '+ accIdSet);
      System.debug('accIdToSetOfOppCloseDTMonMap '+ accIdToSetOfOppCloseDTMonMap);
      System.debug('accIdToOppIdListMap '+ accIdToOppIdListMap);
      
      System.debug('accIdToTelcoSetMap '+ accIdToTelcoSetMap);
      
      System.debug('accIdToAggregatedCMRRMap '+ accIdToAggregatedCMRRMap);
      
      
      
      
      //Fetching Opportunities coressponding to oppIdList for fetching Offering Type
      List<Opportunity> oppList = [Select Id,AccountId,
                                   Lines_of_Businesses__c,
                                   CloseDate
                                   from Opportunity 
                                   where id in:oppIdList
                                   //AND
                                   //AccountId in :accIdSet
                                   //AND
                                   //Lines_of_Businesses__c = 'PureCloud'
                                   
                                   ];
                                   
      Set<String> oppOfferringTypeSet;  
      Set<String> oppCloseDateSet;  
      
      
      Set<ID> fetchedOppIdSet = new Set<ID>();  
      Set<ID> errorOppIdSet = new Set<ID>();  
      
      Set<ID> errorAccIdSet = new Set<ID>();
     
      //For Error outing non-existing opportunities
      if(oppList.size() != oppIdList.size()){
          
          
          
          
          
          
          
      }
      
      
      
      //Iterating Opportunities for fetching Offering_Type__c and close date
      for(Opportunity opp : oppList){
          
          
          fetchedOppIdSet.add(opp.Id);
          
          DateTime oppCloseDateTime = DateTime.newInstance(opp.closedate, myTime);
          
          String closeDate_MonthYear = oppCloseDateTime.format('MMM') + ':' +opp.closedate.year();
          
          System.debug('Opp Close Date Month Year' + closeDate_MonthYear);
          
           /*************************************Creating Account Id to Set of Opportunity Close Date Month Map Start *********************/
          
          if(!accIdToSetOfOppCloseDTMonMap.isEmpty()){
               
               //If Map contains accid
               if(accIdToSetOfOppCloseDTMonMap.containsKey(opp.AccountId)){
                   
                   oppCloseDTMonSet = accIdToSetOfOppCloseDTMonMap.get(opp.AccountId);
                   
                   oppCloseDTMonSet.add(closeDate_MonthYear);
                   
                   accIdToSetOfOppCloseDTMonMap.put(opp.AccountId,oppCloseDTMonSet);
                   
                   
               }else{
                   //If Map don't have accid
                   oppCloseDTMonSet = new Set<String>();
                   
                   oppCloseDTMonSet.add(closeDate_MonthYear);
                   
                   accIdToSetOfOppCloseDTMonMap.put(opp.AccountId,oppCloseDTMonSet);
                   
                   
               }
               
           
           }else{
               //Handling first element
               oppCloseDTMonSet = new Set<String>();
               
               
               oppCloseDTMonSet.add(closeDate_MonthYear);
           
               accIdToSetOfOppCloseDTMonMap.put(opp.AccountId,oppCloseDTMonSet); 
               
               
           }
          
          
           /*************************************Creating Account Id to Set of Opportunity Close Date Month Map End *********************/
          
          
          
          /*************************************Creating Account Id to Set of Opportunity Offerring Type Map Start *********************/
          
          if(!accIdToOppOfferringTypeSetMap.isEmpty()){
               
               //If Map contains accid
               if(accIdToOppOfferringTypeSetMap.containsKey(opp.AccountId)){
                   
                   oppOfferringTypeSet = accIdToOppOfferringTypeSetMap.get(opp.AccountId);
                   
                   oppOfferringTypeSet.add(opp.Lines_of_Businesses__c);
                   
                   accIdToOppOfferringTypeSetMap.put(opp.AccountId,oppOfferringTypeSet);
                   
                   
               }else{
                   //If Map don't have accid
                   oppOfferringTypeSet = new Set<String>();
                   
                   oppOfferringTypeSet.add(opp.Lines_of_Businesses__c);
                   
                   accIdToOppOfferringTypeSetMap.put(opp.AccountId,oppOfferringTypeSet);
                   
                   
               }
               
           
           }else{
               //Handling first element
               oppOfferringTypeSet = new Set<String>();
               
               
               oppOfferringTypeSet.add(opp.Lines_of_Businesses__c);
           
               accIdToOppOfferringTypeSetMap.put(opp.AccountId,oppOfferringTypeSet); 
               
               
           }
          
          
          /*************************************Creating Account Id to Set of Opportunity Offerring Type Map End *********************/
          
          
          
          
          
          //Adding 3 months and picking next month for creating AccountRevnueForecast Records
          
          //Adding 4 months as need to pick next month after adding 3 months to opportunity close date
          oppCloseDateTime = oppCloseDateTime.addMonths(Integer.valueOf(Label.AR_FileUpload_Month));
          
          String closeDate_MonthYearPlus4 = oppCloseDateTime.month() + ':' + oppCloseDateTime.format('MMM') + ':' + oppCloseDateTime.year();
          
          System.debug('closeDate_MonthYearPlus4 ' + closeDate_MonthYearPlus4);
          
          //Map that will contains Accid to Start month for Insertion/Updation of Account Revenue Records
          accIdToCloseDatePlus4Map.put(opp.AccountId, closeDate_MonthYearPlus4);
          
          
      }
      
      //Fetching Opportunities that are not exist under DB
      for(Id oppId:oppIdList){
          
          if(!fetchedOppIdSet.contains(oppId)){
              
              errorOppIdSet.add(oppId);
              
              
          }
          
          
      }
      
      
      //Creating error out AccId set that contains non-existing Opportunities.
      for(Id accId:accIdSet){
          
          if(!accIdToOppIdListMap.isEmpty()){
            
                for(Id oppId : accIdToOppIdListMap.get(accId)){
                    
                    if(errorOppIdSet.contains(oppId)){
                        
                        errorAccIdSet.add(accId);
                        
                    }
                    
                    
                    
                }
            
                
          }
          
          
          
      }
      
      
      
      
      System.debug('accIdToSetOfOppCloseDTMonMap '+  accIdToSetOfOppCloseDTMonMap);
      
      System.debug('accIdToOppOfferringTypeSetMap '+  accIdToOppOfferringTypeSetMap);
      
      System.debug('accIdToCloseDatePlus4Map '+  accIdToCloseDatePlus4Map);
      
      
      //Iterating map of accountId to Offerring type set
      for(String accId : accIdSet){
        
        //Check for invalid Accounts
        if(fetchedAccIDSet.contains(accId)){
        
        
            //Checking if invalid Opportunity under Account then Error out
            if(!errorAccIdSet.contains(accId)){
              
                
              if(!accIdToOppOfferringTypeSetMap.isEmpty() && accIdToOppOfferringTypeSetMap.get(accId).contains('PureCloud')){
              
                if(accIdToOppOfferringTypeSetMap.get(accId).size() > 1){
                    
                    //Error Records for all opp belong to accId not having Purecloud + other Offerring type
                    if(!accIdToAccRevForListMap.isEmpty()){
                        for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                            
                            AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                            accRevForErrorWrapObj.accId = accRevForWrap.accId;
                            accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                            accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                            accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                            accRevForErrorWrapObj.errReason = 'Some of the Opportunities under this account not belong to Pure Cloud Offerring Type';
                            accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                            
                            System.debug('accRevForErrorWrapperList ' +accRevForErrorWrapperList);
                                
                            //csvErrorFile += accRevForWrap.accId + ',' + accRevForWrap.oppId + ',' + accRevForWrap.cmrrValue 
                            //                +',' + accRevForWrap.oppCloseDate + ',' + accRevForWrap.telcoPercent + ','
                            //                + 'Some of the Opportunities under this account not belong to Pure Cloud Offerring Type' + ',' +  '\n'; 
                            
                            
                            
                        }
                    }
                    
                    
                }else{
                    
                    //Opportunity Close Date Check
                    if(!accIdToSetOfOppCloseDTMonMap.isEmpty() && accIdToSetOfOppCloseDTMonMap.get(accId).size() > 1){
                        
                        
                        //Error Records for all opp close date month are unequal.
                        if(!accIdToAccRevForListMap.isEmpty()){
                            for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                            
                                AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                accRevForErrorWrapObj.errReason = 'Opportunities under this account having diferent close date';
                                accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                
                                System.debug('accRevForErrorWrapperList ' +accRevForErrorWrapperList);
                                
                                //csvErrorFile += accRevForWrap.accId + ',' + accRevForWrap.oppId + ',' + accRevForWrap.cmrrValue 
                                //            +',' + accRevForWrap.oppCloseDate + ',' + accRevForWrap.telcoPercent + ','
                                //            + 'Opportunities under this account having diferent close date' + ',' +  '\n'; 
                            
                            
                            }
                        }
                        
                    }else{ 
                        
                        //Check Opportunity having closedate outside range
                        if(!accIdToSetOfOppCloseDTMonMap.isEmpty() && accIdToSetOfOppCloseDTMonMap.get(accId).size() > 0){
                        
                            List<String> oppCloseDTList = new List<String>(accIdToSetOfOppCloseDTMonMap.get(accId));
                            String[] closeDTMonYear = oppCloseDTList[0].split(':');
                            if(closeDTMonYear.size() > 0){
                                
                                if(Integer.valueOf(closeDTMonYear[1]) < 2016 || Integer.valueOf(closeDTMonYear[1]) > 2021){
                                    
                                   //Error Records for all Opportunity having closedate outside range
                                    if(!accIdToAccRevForListMap.isEmpty()){
                                        for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                        
                                            AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                            accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                            accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                            accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                            accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                            accRevForErrorWrapObj.errReason = 'Opportunity having closedate outside range(year>2015 or year<2022)';
                                            accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                            
                                            System.debug('accRevForErrorWrapperList ' +accRevForErrorWrapperList);
                                            
                                            //csvErrorFile += accRevForWrap.accId + ',' + accRevForWrap.oppId + ',' + accRevForWrap.cmrrValue 
                                            //            +',' + accRevForWrap.oppCloseDate + ',' + accRevForWrap.telcoPercent + ','
                                            //            + 'Opportunities under this account having diferent close date' + ',' +  '\n'; 
                                        
                                        
                                        }
                                    } 
                                    
                                    
                                    
                                }else{
                                    
                                    
                                    //Telco Check
                                    if(!accIdToTelcoSetMap.isEmpty() && accIdToTelcoSetMap.get(accId).size() > 1){ 
                
                                        //Error Records for all Acconts having unequal Telco%.
                                        if(!accIdToAccRevForListMap.isEmpty()){
                                            for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                            
                                                AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                                accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                                accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                                accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                                accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                                accRevForErrorWrapObj.errReason = 'Account having unequal Telco%';
                                                accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                                
                                                System.debug('accRevForErrorWrapperList ' +accRevForErrorWrapperList);
                                                
                                                //csvErrorFile += accRevForWrap.accId + ',' + accRevForWrap.oppId + ',' + accRevForWrap.cmrrValue 
                                                //            +',' + accRevForWrap.oppCloseDate + ',' + accRevForWrap.telcoPercent + ','
                                                //            + 'Opportunities under this account having diferent close date' + ',' +  '\n'; 
                                            
                                            
                                            }
                                        }
                
                                    }else{
                                        
                                        //Process Further
                                        accountIdToBeProcessedForAccRevForecast.add(accId);
                                    
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                }
                                
                                
                                
                            }
                           
                        
                        }
                        
                        
                    
                        
                    }
                    
                    
                    
                    
                }
                
              }else{
                  
                 //Error Records for all opp belong to accId not having Purecloud Offerring type 
                 
                    //csvErrorFile += objG.id + ',' + objG.End_Customer_Name__c + ',' + '\n'; 
                    if(!accIdToAccRevForListMap.isEmpty()){
                        for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                            
                            AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                            accRevForErrorWrapObj.accId = accRevForWrap.accId;
                            accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                            accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                            accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                            accRevForErrorWrapObj.errReason = 'All Opportunities under this account not belong to Pure Cloud Offerring Type';
                            accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                            
                            //csvErrorFile += accRevForWrap.accId + ',' + accRevForWrap.oppId + ',' + accRevForWrap.cmrrValue 
                            //                +',' + accRevForWrap.oppCloseDate + ',' + accRevForWrap.telcoPercent + ','
                            //                + 'All Opportunities under this account not belong to Pure Cloud Offerring Type' + ',' +  '\n'; 
                            
                            
                            
                        }
                    }
                  
              }    
             
            }else{
                
                //Error out Accounts whose Opportunity not exist under DB
                if(!accIdToAccRevForListMap.isEmpty()){
                    for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                
                           AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                           accRevForErrorWrapObj.accId = accRevForWrap.accId;
                           accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                           accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                           accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                           accRevForErrorWrapObj.errReason = 'Opportunity under this account not Exist';
                           accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                
                   }
                
                }
                
                
                
            } 
        
        
        }else{
                
                //Error out Accounts for not exist under DB
                if(!accIdToAccRevForListMap.isEmpty()){
                    for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                
                           AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                           accRevForErrorWrapObj.accId = accRevForWrap.accId;
                           accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                           accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                           accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                           accRevForErrorWrapObj.errReason = 'Account not Exist';
                           accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                
                   }
                
                }
                
                
                
         } 
            
      } 
      
      
      
      System.debug('accountIdToBeProcessedForAccRevForecast ' +accountIdToBeProcessedForAccRevForecast);
      
      
      List<ID> accountIdListToBeProcessedLOB = new List<ID>();
      
      Set<ID> accRevForWithAccountOnlySet = new Set<ID>();
      
      
      List<Account_Revenue_Forecast__c> accRevenueForecastListCorrespToAcc = [SELECT Id, account__c, Revenue_Type__c
                                                                              FROM Account_Revenue_Forecast__c 
                                                                              WHERE 
                                                                              account__c in :accountIdToBeProcessedForAccRevForecast];
      
      //For New Logo
      List<Account_Revenue_Forecast__c> accRevenueForecastListCorrespToAccWithOfferringType = [SELECT Id, account__c, Revenue_Type__c
                                                                              FROM Account_Revenue_Forecast__c 
                                                                              WHERE 
                                                                              account__c in :accountIdToBeProcessedForAccRevForecast
                                                                              AND
                                                                              Offering_Type__c = 'PureCloud'];
      
      
      for(Account_Revenue_Forecast__c accRevForecastRec : accRevenueForecastListCorrespToAcc){
          
          
          accRevForWithAccountOnlySet.add(accRevForecastRec.account__c);
          
          
      }
      
      
      
      
      
      
      //Process Refined Account for Account Revenue Forecast
      
      //Fetching current Week for fetching Account Revenue Forecast Records
      Cloud_Forecast_Quarter__c cloudForecastQuartRec = [SELECT id from Cloud_Forecast_Quarter__c
                                                                where 
                                                                Current_Week__c  = true 
                                                                Limit 1];
                                                                
      List<Account_Revenue_Forecast__c> accRevenueForecastList = null;                                                                    
                                                                
      if(cloudForecastQuartRec != null){
             //Fetching Account Revenue Forecast Records for refined account ids and current week.
             String logoType = 'Processed';
             
             
             
             String revenueForecastQuery = 'SELECT Id, account__c, Revenue_Type__c,';
             
             for(Integer i=2016; i<2022; i++){

                revenueForecastQuery = revenueForecastQuery + 'Jan_' + i + '__c' + ', ';
                revenueForecastQuery = revenueForecastQuery + 'Feb_' + i + '__c' + ', ';
                revenueForecastQuery = revenueForecastQuery + 'Mar_' + i + '__c' + ', ';
                revenueForecastQuery = revenueForecastQuery + 'Apr_' + i + '__c' + ', ';
                revenueForecastQuery = revenueForecastQuery + 'May_' + i + '__c' + ', ';
                revenueForecastQuery = revenueForecastQuery + 'June_' + i + '__c' + ', ';
                revenueForecastQuery = revenueForecastQuery + 'July_' + i + '__c' + ', ';
                revenueForecastQuery = revenueForecastQuery + 'Aug_' + i + '__c' + ', ';
                revenueForecastQuery = revenueForecastQuery + 'Sept_' + i + '__c' + ', ';
                revenueForecastQuery = revenueForecastQuery + 'Oct_' + i + '__c' + ', ';
                revenueForecastQuery = revenueForecastQuery + 'Nov_' + i + '__c' + ', ';
                revenueForecastQuery = revenueForecastQuery + 'Dec_' + i + '__c'+ ', ';
                
            }
            
            System.debug('revenueForecastQuery up to month year' + revenueForecastQuery);
            
            revenueForecastQuery = revenueForecastQuery.substring(0,revenueForecastQuery.length()-2);
            
            revenueForecastQuery = revenueForecastQuery + ' FROM Account_Revenue_Forecast__c WHERE '
                                    + 'Cloud_Forecast_Quarter__c = ' +  '\''  +  cloudForecastQuartRec.id + '\'' 
                                   // + ' AND Is_New_Logo__c = ' + '\''  + logoType + '\'' 
                                    + ' AND account__c in : accountIdToBeProcessedForAccRevForecast'
                                    + ' AND Revenue_Type__c in  : lobListWithSubscriptionAndTelco'; 
                                    
            
            
            
            System.debug('revenueForecastQuery ' + revenueForecastQuery);
            
            accRevenueForecastList = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);
             
           /* List<Account_Revenue_Forecast__c> accRevenueForecastList = [SELECT Id, account__c, Revenue_Type__c
                                                                          FROM Account_Revenue_Forecast__c 
                                                                          WHERE 
                                                                          account__c in :accountIdToBeProcessedForAccRevForecast
                                                                          and 
                                                                          Is_New_Logo__c ='Processed'
                                                                          AND
                                                                          Cloud_Forecast_Quarter__c  = :cloudForecastQuartRec.id];  */
            }//End of Quarter If
            
             System.debug('operationType ' + operationType);
             
             
             System.debug('accRevenueForecastList Result ' + accRevenueForecastList);
            
            
              if(operationType.equals('Addon')){
                  
                 //Check for Account only 
                 if(accRevenueForecastListCorrespToAcc.size() > 0){
                     
                   //Check for Account with current week
                   if(accRevenueForecastList.size() > 0){
                      
                        
                      
                               
                        
                  
                         System.debug('accRevenueForecastList ' +accRevenueForecastList);        
                     
                         //Error out those account records that don't have coressponding account revenue forecast records.
                         //And process exiting account records
                         
                         //Iterating Account_Revenue_Forecast list for findoug out account records that don't have 
                         //coressponding account revenue forecast records. 
                         
                         Set<ID> accRevenueForecastAccIdSet = new Set<ID>();
                         
                        
                         
                         
                         
                         //AccountId to List of Account_Revenue_Forecast__c records Map
                         Map<ID,List<Account_Revenue_Forecast__c>> accIDToListOfAccRevForecastMap = new Map<ID,List<Account_Revenue_Forecast__c>>();
                         
                         //Account Revenue Forecast List
                         List<Account_Revenue_Forecast__c> accRevForecastList;
                         
                         
                         
                         
                         for(Account_Revenue_Forecast__c accRevRec : accRevenueForecastList){
                             
                             //Creating set of Account Ids
                             accRevenueForecastAccIdSet.add(accRevRec.account__c);
                             
                             
                         /*************************************Creating Account Id to List of Account_Revenue_Forecast__c records Map Start *********************/
          
                              if(!accIDToListOfAccRevForecastMap.isEmpty()){
                                   
                                   //If Map contains accid
                                   if(accIDToListOfAccRevForecastMap.containsKey(accRevRec.account__c)){
                                       
                                       accRevForecastList = accIDToListOfAccRevForecastMap.get(accRevRec.account__c);
                                       
                                       accRevForecastList.add(accRevRec);
                                       
                                       accIDToListOfAccRevForecastMap.put(accRevRec.account__c,accRevForecastList);
                                       
                                       
                                   }else{
                                       //If Map don't have accid
                                       accRevForecastList = new List<Account_Revenue_Forecast__c>();
                                       
                                       accRevForecastList.add(accRevRec);
                                       
                                       accIDToListOfAccRevForecastMap.put(accRevRec.account__c,accRevForecastList);
                                       
                                       
                                   }
                                   
                               
                               }else{
                                   //Handling first element
                                   accRevForecastList = new List<Account_Revenue_Forecast__c>();
                                   
                                   accRevForecastList.add(accRevRec);
                               
                                   accIDToListOfAccRevForecastMap.put(accRevRec.account__c,accRevForecastList); 
                                   
                                   
                               }
                              
                          
                           /*************************************Creating Account Id to List of Account_Revenue_Forecast__c records Map End *********************/
                             
                             
                             
                         }
                         
                         
                         System.debug('accIDToSetOfRevenueTypeMap ' +accIDToListOfAccRevForecastMap);
                         
                         
                         //Check passed Account id with queried AccountRevenueForecast records
                         for(ID accId : accountIdToBeProcessedForAccRevForecast){
                             
                            //Check for Account only for any week 
                            if(accRevForWithAccountOnlySet.contains(accId)){ 
                             
                              if(accRevenueForecastAccIdSet.contains(accId)){
                                 
                                 
                                 
                                //Process Further for Revenue Types
                                
                                if(!accIDToListOfAccRevForecastMap.isEmpty()){
                                    
                                  
                                  //Checking if Account revenue Forecast having data for lob(In-Force Subscription,In-Force Telco)  
                                  if(accIDToListOfAccRevForecastMap.get(accId).size() > 1){
                                        
                                         
                                    
                                    
                                    
                                    for(Account_Revenue_Forecast__c accRevForRec : accIDToListOfAccRevForecastMap.get(accId)){
                                        
                                        //Update the Account Revenue Forecast Record for Revenue_Type__c = A - In-Force Subscription
                                        if(accRevForRec.Revenue_Type__c.equals('A - In-Force Subscription')){
                                        
                                            System.debug('In-Force Subscription');
                                            
                                            Boolean errorInProcessing = false;
                                            
                                            if(!accIdToCloseDatePlus4Map.isEmpty() && accIdToCloseDatePlus4Map.get(accId) != null){
                                                
                                                Decimal aggregateCMMRValueForAccount = 0.0;
                                                            
                                                if(!accIdToAggregatedCMRRMap.isEmpty()){ 
                                                                
                                                    aggregateCMMRValueForAccount = accIdToAggregatedCMRRMap.get(accId);
                                                }    
                                                System.debug('aggregateCMMRValueForAccount '+aggregateCMMRValueForAccount);
                                                
                                                String[] startMonthYearArray = accIdToCloseDatePlus4Map.get(accId).split(':');
                                                
                                                System.debug('startMonthYearArray ' +startMonthYearArray);
                                                    
                                                if(startMonthYearArray.size() > 0){
                                                    
                                                    System.debug('startMonthYearArray[0] ' +startMonthYearArray[0]);
                                                    
                                                    System.debug('startMonthYearArray[1] ' +startMonthYearArray[1]);
                                                    
                                                    System.debug('startMonthYearArray[2] ' +startMonthYearArray[2]);
                                                    
                                                    
                                                   
                                                        
                                                        
                                                    
                                                        for(Integer year = Integer.valueOf(startMonthYearArray[2]); year<2022; year++){
                                                            
                                                            
                                                            
                                                            if(!numberToMonthMap.isEmpty()){
                                                                
                                                                
                                                                if(year == Integer.valueOf(startMonthYearArray[2])){
                                                                    for(Integer month = Integer.valueOf(startMonthYearArray[0]); month<13; month++){
                                                                        
                                                                        //System.debug('col Value ' + numberToMonthMap.get(month) + year + '__c');
                                                                        
                                                                        //System.debug('Month Value ' + (Decimal)accRevForRec.get(numberToMonthMap.get(month) + year + '__c'));
                                                                        
                                                                        Decimal monthValue = 0.0;
                                                                        if(accRevForRec.get(numberToMonthMap.get(month) + year + '__c') != null){
                                                                            monthValue = (Decimal)accRevForRec.get(numberToMonthMap.get(month) + year + '__c') + aggregateCMMRValueForAccount;
                                                                        
                                                                        }else{
                                                                            monthValue = aggregateCMMRValueForAccount;
                                                                            
                                                                        }
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',monthValue);
                                                                        //System.debug('monthValue for current year'+monthValue );
                                                                    
                                                                    
                                                                    }
                                                                    
                                                                }else{
                                                                    for(Integer month = 1; month<13; month++){
                                                                    
                                                                        Decimal monthValue = 0.0;
                                                                        if(accRevForRec.get(numberToMonthMap.get(month) + year + '__c') != null){
                                                                            monthValue = (Decimal)accRevForRec.get(numberToMonthMap.get(month) + year + '__c') + aggregateCMMRValueForAccount;
                                                                        
                                                                        }else{
                                                                            monthValue = aggregateCMMRValueForAccount;
                                                                            
                                                                        }
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',monthValue);
                                                                        System.debug('monthValue for  year'+ year + ':' +monthValue );
                                                                    
                                                                    
                                                                    }
                
                
                
                                                                }   
                                                                    
                                                                
                                                                
                                                            } 
                                                            
                                                            
                                                            
                                                        }
                                                    
                                                    
                                                    
                                                    /*}else{
                                                           
                                                           errorInProcessing = true;
                                                           //Error out this accountid for Opp closedate not between 2016 and 2021
                                                           if(!accIdToAccRevForListMap.isEmpty()){
                                                                        for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                                                        
                                                                            AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                                                            accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                                                            accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                                                            accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                                                            accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                                                            accRevForErrorWrapObj.errReason = 'Opportunity close date year should be greater than 2015 and less than 2022';
                                                                            accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                                                            System.debug('accRevForErrorWrapperList ' +accRevForErrorWrapperList);
                                                                        
                                                                        } 
                                                           }
                                                        
                                                        
                                                        
                                                        
                                                    }*/
                                                    
                                                }    

                                                
                                                
                                                
                                                
                                                
                                            }
                                            
                                           
                                        
                                        
                                            if(!errorInProcessing){
                                                accRevForecastListToBeUpdated.add(accRevForRec);
                                            }
                                        
                                        
                                        
                                        }else if(accRevForRec.Revenue_Type__c.equals('D - In-Force Telco')){
                                        
                                            System.debug('D - In-Force Telco');
                                            
                                            Boolean errorInProcessing = false;
                                            
                                            if(!accIdToCloseDatePlus4Map.isEmpty() && accIdToCloseDatePlus4Map.get(accId) != null){
                                                
                                                Decimal aggregateCMMRValueForAccount = 0.0;
                                                
                                                Decimal telcoPrecent = 0.0;
                                                
                                                Decimal telcoValue = 0.0;
                                                
                                                
                                                            
                                                if(!accIdToAggregatedCMRRMap.isEmpty() && accIdToAggregatedCMRRMap.get(accId) != null){ 
                                                                
                                                    aggregateCMMRValueForAccount = accIdToAggregatedCMRRMap.get(accId);
                                                } 
                                                
                                                if(!accIdToTelcoSetMap.isEmpty() && accIdToTelcoSetMap.get(accId) != null && accIdToTelcoSetMap.get(accId).size() > 0){
                                                    
                                                    List<Decimal> telcoSet = new List<Decimal>(accIdToTelcoSetMap.get(accId));
                                                    telcoPrecent = telcoSet[0];
                                                        
                                                }    
                                                
                                                System.debug('aggregateCMMRValueForAccount '+aggregateCMMRValueForAccount);
                                                
                                                //System.debug('telcoPrecent '+telcoPrecent);
                                                
                                                
                                                telcoValue = aggregateCMMRValueForAccount * (telcoPrecent/100);
                                                
                                                //System.debug('telcoValue '+telcoValue);
                                                
                                                String[] startMonthYearArray = accIdToCloseDatePlus4Map.get(accId).split(':');
                                                    
                                                if(startMonthYearArray.size() > 0){
                                                    
                                                    
                                                    
                                                    
                                                        for(Integer year = Integer.valueOf(startMonthYearArray[2]); year<2022; year++){
                                                            
                                                            
                                                            
                                                            if(!numberToMonthMap.isEmpty()){
                                                                
                                                                
                                                                if(year == Integer.valueOf(startMonthYearArray[2])){
                                                                    for(Integer month = Integer.valueOf(startMonthYearArray[0]); month<13; month++){
                                                                        
                                                                        Decimal monthValue = 0.0;
                                                                        if(accRevForRec.get(numberToMonthMap.get(month) + year + '__c') != null){
                                                                            monthValue = (Decimal)accRevForRec.get(numberToMonthMap.get(month) + year + '__c') + telcoValue;
                                                                        
                                                                        }else{
                                                                            monthValue = telcoValue;
                                                                            
                                                                        }
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',monthValue);
                                                                        
                                                                    
                                                                    
                                                                    }
                                                                    
                                                                }else{
                                                                    for(Integer month = 1; month<13; month++){
                                                                    
                                                                        Decimal monthValue = 0.0;
                                                                        if(accRevForRec.get(numberToMonthMap.get(month) + year + '__c') != null){
                                                                            monthValue = (Decimal)accRevForRec.get(numberToMonthMap.get(month) + year + '__c') + telcoValue;
                                                                        
                                                                        }else{
                                                                            monthValue = telcoValue;
                                                                            
                                                                        }
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',monthValue);
                                                                    
                                                                    
                                                                    
                                                                    }
                
                
                
                                                                }   
                                                                    
                                                                
                                                                
                                                            } 
                                                            
                                                            
                                                            
                                                        }    
                                                    
                                                    
                                                    
                                                    
                                                }    

                                                
                                                
                                                
                                                
                                                
                                            }
                                            
                                            
                                            
                                            
                                            
                                            if(!errorInProcessing){
                                                accRevForecastListToBeUpdated.add(accRevForRec);
                                            }
                                        
                                        }else{
                                            
                                            //Error for In-Force Telco for this accid
                                            
                                            
                                            
                                            
                                        }
                                        
                                        
                                        
                                        }//End of for loop
                                    
                                    }else{
                                         //Error out the both Account_Revenue_Forecast records
                                        
                                         Account_Revenue_Forecast__c accRevForRecord = (Account_Revenue_Forecast__c)accIDToListOfAccRevForecastMap.get(accId)[0];
                                         
                                         System.debug('accRevForRecord ' +accRevForRecord);
                                         
                                         if(accRevForRecord.Revenue_Type__c.equals('A - In-Force Subscription')){
                                             
                                            //error out Account accId for Revenue Type:-  D - In-Force Telco 
                     
                                            if(!accIdToAccRevForListMap.isEmpty()){
                                                for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                                
                                                    AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                                    accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                                    accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                                    accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                                    accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                                    accRevForErrorWrapObj.errReason = 'Account Revenue Forecast record not exist for Revenue Type:-  D - In-Force Telco';
                                                    accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                                    
                                                    //csvErrorFile += accRevForWrap.accId + ',' + accRevForWrap.oppId + ',' + accRevForWrap.cmrrValue 
                                                    //            +',' + accRevForWrap.oppCloseDate + ',' + accRevForWrap.telcoPercent + ','
                                                    //            + 'Account Revenue Forecast record not exist for Revenue Type:-  D - In-Force Telco' + ',' +  '\n'; 
                                                
                                                }
                                                
                                            }
                                             
                                             
                                             
                                             
                                             
                                         }else if(accRevForRecord.Revenue_Type__c.equals('D - In-Force Telco')){
                                             
                                             //error out Account accId for Revenue Type:-  A - In-Force Subscription
                                             if(!accIdToAccRevForListMap.isEmpty()){
                                                for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                                
                                                    AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                                    accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                                    accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                                    accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                                    accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                                    accRevForErrorWrapObj.errReason = 'Account Revenue Forecast record not exist for Revenue Type:-  A - In-Force Subscription';
                                                    accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                                    
                                                   // csvErrorFile += accRevForWrap.accId + ',' + accRevForWrap.oppId + ',' + accRevForWrap.cmrrValue 
                                                   //             +',' + accRevForWrap.oppCloseDate + ',' + accRevForWrap.telcoPercent + ','
                                                    //            + 'Account Revenue Forecast record not exist for Revenue Type:-  A - In-Force Subscription' + ',' +  '\n'; 
                                                
                                                
                                                } 
                                            }
                                         }
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                    }
                                    
                                    
                                    System.debug('accRevForecastListToBeUpdated' +accRevForecastListToBeUpdated);
                                    

                                 }
                                
                               }else{
                                   
                                   //Error out this accountid that AccountRevenueForecast record not exist
                                   if(!accIdToAccRevForListMap.isEmpty()){
                                                for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                                
                                                    AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                                    accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                                    accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                                    accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                                    accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                                    accRevForErrorWrapObj.errReason = 'Account Revenue Forecast record not exist for this Account for current week';
                                                    accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                                    System.debug('accRevForErrorWrapperList ' +accRevForErrorWrapperList);
                                                    
                                                    //csvErrorFile += accRevForWrap.accId + ',' + accRevForWrap.oppId + ',' + accRevForWrap.cmrrValue 
                                                     //           +',' + accRevForWrap.oppCloseDate + ',' + accRevForWrap.telcoPercent + ','
                                                      //          + 'Account Revenue Forecast record not exist for this Account' + ',' +  '\n'; 
                                                
                                                
                                                } 
                                   }
                                   
                               }
                               
                              }else{
                                  
                                  //Error out all rows corresponding to this Account for all weeks
                                  if(!accIdToAccRevForListMap.isEmpty()){
                                                for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                                
                                                    AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                                    accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                                    accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                                    accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                                    accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                                    accRevForErrorWrapObj.errReason = 'Account Revenue Forecast record not exist for this Account for all weeks';
                                                    accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                                    
                                                    
                                                
                                                } 
                                   }
                                  
                                  
                                  
                              }
                                
                              //accountIdListToBeProcessedLOB.add(accId); 
                             
                             
                             }//End of accountIdToBeProcessedForAccRevForecast for loop
                            
                            }else{
                                 
                                 
                                 
                                 //Error out all Accords that are passed for Current week
                                 //accountIdToBeProcessedForAccRevForecast passed Account id list
                                 for(ID accId : accountIdToBeProcessedForAccRevForecast){
                                    if(!accIdToAccRevForListMap.isEmpty()){
                                                for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                                
                                                    AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                                    accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                                    accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                                    accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                                    accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                                    accRevForErrorWrapObj.errReason = 'Account Revenue Forecast record not exist for this Account for current weeks';
                                                    accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                                    
                                                    
                                                
                                                } 
                                   }  
                                     
                                 }         
                                 
                                 
                             }
                             
                           }else{
                               
                               //Error out for Account only
                               for(ID accId : accountIdToBeProcessedForAccRevForecast){
                                    if(!accIdToAccRevForListMap.isEmpty()){
                                                for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                                
                                                    AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                                    accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                                    accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                                    accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                                    accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                                    accRevForErrorWrapObj.errReason = 'Account Revenue Forecast record not exist for this Account for all weeks';
                                                    accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                                    
                                                    
                                                
                                                } 
                                   }  
                                     
                                 }        
                               
                               
                               
                               
                               
                               
                               
                           } //End of Account only check    
                             
                             
                         }else if(operationType.equals('NewLogo')){
                  
                  
                              //Check for Account only 
                             if(accRevenueForecastListCorrespToAccWithOfferringType.size() > 0){
                                 
                                //Check for Account with current week
                                //if(accRevenueForecastList.size() > 0){
                                  
                                    
                                  
                                        
                                    
                              
                                     System.debug('accRevenueForecastList ' +accRevenueForecastList);        
                                 
                                     //Error out those account records that have coressponding account revenue forecast records.
                                     //And process exiting account records
                                     
                                     //Iterating Account_Revenue_Forecast list for findoug out account records that have 
                                     //coressponding account revenue forecast records. 
                                     
                                     Set<ID> accRevenueForecastAccIdSet = new Set<ID>();
                                    
                                     
                                     //Account Revenue Forecast List
                                     List<Account_Revenue_Forecast__c> accRevForecastList;
                                     
                                     
                                     
                                     
                                     for(Account_Revenue_Forecast__c accRevRec : accRevenueForecastList){
                                         
                                         //Creating set of Account Ids
                                         accRevenueForecastAccIdSet.add(accRevRec.account__c);
                                         
                                         
                                     
                                         
                                         
                                         
                                     }
                                     
                                     
                                     //Check passed Account id with queried AccountRevenueForecast records
                                     for(ID accId : accountIdToBeProcessedForAccRevForecast){
                                         
                                        //Check for Account only for any week 
                                        if(!accRevForWithAccountOnlySet.contains(accId)){ 
                                         
                                          if(!accRevenueForecastAccIdSet.contains(accId)){
                                             
                                             
                                             
                                            //Process Further for Revenue Types
                                                
                                            //Insert the Account Revenue Forecast Record for Revenue_Type__c = A - In-Force Subscription
                                            
                                            
                                            //Check passed Account id with queried AccountRevenueForecast records
                                            
                                                
                                            insertLobs(lobList,accId,accIdToCloseDatePlus4Map,accIdToAggregatedCMRRMap,
                                                        numberToMonthMap,accIdToTelcoSetMap,accRevForecastListToBeInserted,
                                                        cloudForecastQuartRec,accIdToAccRevForListMap);
                    
                                                
                                                 
                                                    
                                                    
                                                
                                                
                                            System.debug('accRevForecastListToBeInserted' +accRevForecastListToBeInserted);
                                                
            
                                            
                                            
                                           }else{
                                               
                                               //Error out this accountid that AccountRevenueForecast record not exist
                                               if(!accIdToAccRevForListMap.isEmpty()){
                                                            for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                                            
                                                                AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                                                accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                                                accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                                                accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                                                accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                                                accRevForErrorWrapObj.errReason = 'Account Revenue Forecast record exist for this Account for current week';
                                                                accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                                                System.debug('accRevForErrorWrapperList ' +accRevForErrorWrapperList);
                                                                
                                                                //csvErrorFile += accRevForWrap.accId + ',' + accRevForWrap.oppId + ',' + accRevForWrap.cmrrValue 
                                                                 //           +',' + accRevForWrap.oppCloseDate + ',' + accRevForWrap.telcoPercent + ','
                                                                  //          + 'Account Revenue Forecast record not exist for this Account' + ',' +  '\n'; 
                                                            
                                                            
                                                            } 
                                               }
                                               
                                           }
                                           
                                          }else{
                                              
                                              //Error out all rows corresponding to this Account for all weeks
                                              if(!accIdToAccRevForListMap.isEmpty()){
                                                            for(AccountRevnueForecastWrapper accRevForWrap : accIdToAccRevForListMap.get(accId)){
                                                            
                                                                AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
                                                                accRevForErrorWrapObj.accId = accRevForWrap.accId;
                                                                accRevForErrorWrapObj.oppId = accRevForWrap.oppId;
                                                                accRevForErrorWrapObj.cmrrValue = String.valueOf(accRevForWrap.cmrrValue);
                                                                accRevForErrorWrapObj.telcoPercent = String.valueOf(accRevForWrap.telcoPercent);
                                                                accRevForErrorWrapObj.errReason = 'Account already exists in Account Revenue Forecast';
                                                                accRevForErrorWrapperList.add(accRevForErrorWrapObj);
                                                                
                                                                
                                                            
                                                            } 
                                               }
                                              
                                              
                                              
                                          }
                                            
                                          //accountIdListToBeProcessedLOB.add(accId); 
                                         
                                         
                                         }//End of accountIdToBeProcessedForAccRevForecast for loop
                                        
                                        /*}else{
                                             
                                             //Check passed Account id with queried AccountRevenueForecast records
                                            for(ID accId : accountIdToBeProcessedForAccRevForecast){
                                                
                                                insertLobs(lobList,accId,accIdToCloseDatePlus4Map,accIdToAggregatedCMRRMap, numberToMonthMap,accIdToTelcoSetMap,accRevForecastListToBeInserted,
                                                cloudForecastQuartRec);
                    
                                            }   
                                             
                                             
                                             
                                        }*/
                                        
                                      }else{
                                      
                                        
                                            //Check passed Account id with queried AccountRevenueForecast records
                                            for(ID accId : accountIdToBeProcessedForAccRevForecast){
                                                
                                                insertLobs(lobList,accId,accIdToCloseDatePlus4Map,accIdToAggregatedCMRRMap, numberToMonthMap,accIdToTelcoSetMap,accRevForecastListToBeInserted,
                                                cloudForecastQuartRec,accIdToAccRevForListMap);
                    
                                            }       
                                        
                                      
                                      }   
                             
                       }//End of NewLogo 
                
                                    
      
     // }//End of Quarter
     
     
    System.debug('@accRevForecastListToBeUpdated ' + accRevForecastListToBeUpdated);
    System.debug('@accRevForecastListToBeInserted ' + accRevForecastListToBeInserted);
    
    
      
      System.debug('CSV File ' +csvErrorFile);
      
      if(accRevForErrorWrapperList.size() > 0){
          
          System.debug('accRevForErrorWrapperList ' +accRevForErrorWrapperList);
          //pageRef = Page.PESSRevenueForecastFileUploadErrorCSV;
          //pageRef.setRedirect(true);
          
          if(accRevForecastListToBeUpdated.size() > 0 || accRevForecastListToBeInserted.size() > 0){
              
              ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Some accounts having processing errors while remaining are processed successfully, please download error file');
              ApexPages.addMessage(errorMessage);
              
          }else{
          
              ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'All accounts having processing errors, please download error file');
              ApexPages.addMessage(errorMessage);
          }    
          
      }else{
          
          ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO,'All accounts are processed successfully');
          ApexPages.addMessage(errorMessage);
          
          
      }
      
      //Addon
      if(!parseOnly && accRevForecastListToBeUpdated.size() > 0){
          
          try{
              
              System.debug('Inside Update');
              update accRevForecastListToBeUpdated;
              
          }catch(DMLException exp){
              
          }
          
          
      }
      
      //New 
      if(!parseOnly && accRevForecastListToBeInserted.size() > 0){
          
          try{
              System.debug('Inside Insert');
              insert accRevForecastListToBeInserted;
              
          }catch(DMLException exp){
              
          }
          
          
      }
      
      
      
      
      return null;
      
  }
  
  
  
  //This method will insert 7 different in case of NewLogo
  private void insertLobs(List<String> lobList,ID accId,Map<ID,String> accIdToCloseDatePlus4Map,Map<ID,Decimal> accIdToAggregatedCMRRMap,
                        Map<Integer,String> numberToMonthMap, Map<ID,Set<Decimal>> accIdToTelcoSetMap,
                        List<Account_Revenue_Forecast__c> accRevForecastListToBeInserted,Cloud_Forecast_Quarter__c cloudForecastQuartRec,
                        Map<ID,List<AccountRevnueForecastWrapper>> accIdToAccRevForListMap){
        
            //Iterating LOB List
                                
            for(String lob : lobList){
                                
                                    if(lob.equals('A - In-Force Subscription')){
                                            Account_Revenue_Forecast__c accRevForRec = new Account_Revenue_Forecast__c();
                                            
                                            accRevForRec.account__c = accId;
                                            accRevForRec.LOB_O__c = 'A - In-Force Subscription';
                                            accRevForRec.Offering_Type__c = 'PureCloud';
                                            accRevForRec.Cloud_Forecast_Quarter__c = cloudForecastQuartRec.id;
                                            
                                            
                                            System.debug('In-Force Subscription');
                                            
                                            Boolean errorInProcessing = false;
                                            
                                            if(!accIdToCloseDatePlus4Map.isEmpty() && accIdToCloseDatePlus4Map.get(accId) != null){
                                                
                                                Decimal aggregateCMMRValueForAccount = 0.0;
                                                            
                                                if(!accIdToAggregatedCMRRMap.isEmpty()){ 
                                                                
                                                    aggregateCMMRValueForAccount = accIdToAggregatedCMRRMap.get(accId);
                                                }    
                                                System.debug('aggregateCMMRValueForAccount '+aggregateCMMRValueForAccount);
                                                
                                                String[] startMonthYearArray = accIdToCloseDatePlus4Map.get(accId).split(':');
                                                
                                                System.debug('startMonthYearArray ' +startMonthYearArray);
                                                    
                                                if(startMonthYearArray.size() > 0){
                                                    
                                                    System.debug('startMonthYearArray[0] ' +startMonthYearArray[0]);
                                                    
                                                    System.debug('startMonthYearArray[1] ' +startMonthYearArray[1]);
                                                    
                                                    System.debug('startMonthYearArray[2] ' +startMonthYearArray[2]);
                                                    
                                                    
                                                    
                                                        for(Integer year = Integer.valueOf(startMonthYearArray[2]); year<2022; year++){
                                                            
                                                            
                                                            
                                                            if(!numberToMonthMap.isEmpty()){
                                                                
                                                                
                                                                if(year == Integer.valueOf(startMonthYearArray[2])){
                                                                    for(Integer month = Integer.valueOf(startMonthYearArray[0]); month<13; month++){
                                                                        
                                                                        //System.debug('col Value ' + numberToMonthMap.get(month) + year + '__c');
                                                                        
                                                                        //System.debug('Month Value ' + (Decimal)accRevForRec.get(numberToMonthMap.get(month) + year + '__c'));
                                                                            
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',aggregateCMMRValueForAccount);
                                                                        //System.debug('monthValue for current year'+aggregateCMMRValueForAccount );
                                                                    
                                                                    
                                                                    }
                                                                    
                                                                }else{
                                                                    for(Integer month = 1; month<13; month++){
                                                                        
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',aggregateCMMRValueForAccount);
                                                                        
                                                                    
                                                                    
                                                                    }
                
                
                
                                                                }   
                                                                    
                                                                
                                                                
                                                            } 
                                                            
                                                            
                                                            
                                                        }  
                                                    
                                                    
                                                    
                                                    
                                                    
                                                }    

                                                
                                                
                                                
                                                
                                                
                                            }
                                            
                                            if(!errorInProcessing){
                                                    accRevForecastListToBeInserted.add(accRevForRec);
                                            }
                                        
                                        
                                        }else if(lob.equals('D - In-Force Telco')){
                                        
                                            System.debug('D - In-Force Telco');
                                            
                                            Boolean errorInProcessing = false;
                                            
                                            Account_Revenue_Forecast__c accRevForRec = new Account_Revenue_Forecast__c();
                                            
                                            accRevForRec.account__c = accId;
                                            accRevForRec.LOB_O__c = 'D - In-Force Telco';
                                            accRevForRec.Offering_Type__c = 'PureCloud';
                                            accRevForRec.Cloud_Forecast_Quarter__c = cloudForecastQuartRec.id;
                                            
                                            
                                            if(!accIdToCloseDatePlus4Map.isEmpty() && accIdToCloseDatePlus4Map.get(accId) != null){
                                                
                                                Decimal aggregateCMMRValueForAccount = 0.0;
                                                
                                                Decimal telcoPrecent = 0.0;
                                                
                                                Decimal telcoValue = 0.0;
                                                
                                                
                                                            
                                                if(!accIdToAggregatedCMRRMap.isEmpty() && accIdToAggregatedCMRRMap.get(accId) != null){ 
                                                                
                                                    aggregateCMMRValueForAccount = accIdToAggregatedCMRRMap.get(accId);
                                                } 
                                                
                                                if(!accIdToTelcoSetMap.isEmpty() && accIdToTelcoSetMap.get(accId) != null && accIdToTelcoSetMap.get(accId).size() > 0){
                                                    
                                                    List<Decimal> telcoSet = new List<Decimal>(accIdToTelcoSetMap.get(accId));
                                                    telcoPrecent = telcoSet[0];
                                                        
                                                }    
                                                
                                                System.debug('aggregateCMMRValueForAccount '+aggregateCMMRValueForAccount);
                                                
                                                //System.debug('telcoPrecent '+telcoPrecent);
                                                
                                                
                                                telcoValue = aggregateCMMRValueForAccount * (telcoPrecent/100);
                                                
                                                //System.debug('telcoValue '+telcoValue);
                                                
                                                String[] startMonthYearArray = accIdToCloseDatePlus4Map.get(accId).split(':');
                                                    
                                                if(startMonthYearArray.size() > 0){
                                                    
                                                    
                                                        for(Integer year = Integer.valueOf(startMonthYearArray[2]); year<2022; year++){
                                                            
                                                            
                                                            
                                                            if(!numberToMonthMap.isEmpty()){
                                                                
                                                                
                                                                if(year == Integer.valueOf(startMonthYearArray[2])){
                                                                    for(Integer month = Integer.valueOf(startMonthYearArray[0]); month<13; month++){
                                                                        
                                                                        
                                                                                                                                                                                                
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',telcoValue);
                                                                        
                                                                    
                                                                    
                                                                    }
                                                                    
                                                                }else{
                                                                    for(Integer month = 1; month<13; month++){
                                                                    
                                                                        
                                                                        
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',telcoValue);
                                                                    
                                                                    
                                                                    
                                                                    }
                
                
                
                                                                }   
                                                                    
                                                                
                                                                
                                                            } 
                                                            
                                                            
                                                            
                                                        } 
                                                    
                                                     
                                                    
                                                }    

                                                
                                                
                                                
                                                
                                                
                                            }
                                            
                                        
                                            if(!errorInProcessing){
                                                    accRevForecastListToBeInserted.add(accRevForRec);
                                            }
                                        
                                        
                                        }else if(lob.equals('B - In-Force Sub Overage')){
                                            Account_Revenue_Forecast__c accRevForRec = new Account_Revenue_Forecast__c();
                                            
                                            Boolean errorInProcessing = false;
                                            
                                            System.debug('In-Force Sub Overage');
                                            
                                            accRevForRec.account__c = accId;
                                            accRevForRec.LOB_O__c = 'B - In-Force Sub Overage';
                                            accRevForRec.Offering_Type__c = 'PureCloud';
                                            accRevForRec.Cloud_Forecast_Quarter__c = cloudForecastQuartRec.id;
                                            
                                            if(!accIdToCloseDatePlus4Map.isEmpty() && accIdToCloseDatePlus4Map.get(accId) != null){
                                                
                                                
                                                String[] startMonthYearArray = accIdToCloseDatePlus4Map.get(accId).split(':');
                                                
                                                System.debug('startMonthYearArray ' +startMonthYearArray);
                                                    
                                                if(startMonthYearArray.size() > 0){
                                                    
                                                    System.debug('startMonthYearArray[0] ' +startMonthYearArray[0]);
                                                    
                                                    System.debug('startMonthYearArray[1] ' +startMonthYearArray[1]);
                                                    
                                                    System.debug('startMonthYearArray[2] ' +startMonthYearArray[2]);
                                                    
                                                    
                                                    
                                                        for(Integer year = Integer.valueOf(startMonthYearArray[2]); year<2022; year++){
                                                            
                                                            
                                                            
                                                            if(!numberToMonthMap.isEmpty()){
                                                                
                                                                
                                                                if(year == Integer.valueOf(startMonthYearArray[2])){
                                                                    for(Integer month = Integer.valueOf(startMonthYearArray[0]); month<13; month++){
                                                                        
                                                                        //System.debug('col Value ' + numberToMonthMap.get(month) + year + '__c');
                                                                        
                                                                        //System.debug('Month Value ' + (Decimal)accRevForRec.get(numberToMonthMap.get(month) + year + '__c'));
                                                                            
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',0.0);
                                                                        //System.debug('monthValue for current year'+aggregateCMMRValueForAccount );
                                                                    
                                                                    
                                                                    }
                                                                    
                                                                }else{
                                                                    for(Integer month = 1; month<13; month++){
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',0.0);
                                                                    }
                                                                }   
                                                            } 
                                                        }
                                                }    
                                            }
                                            
                                            if(!errorInProcessing){
                                                
                                                    accRevForecastListToBeInserted.add(accRevForRec);
                                            }
                                        
                                        
                                        
                                        }else if(lob.equals('C - In-Delivery Subscription')){
                                            Account_Revenue_Forecast__c accRevForRec = new Account_Revenue_Forecast__c();
                                            System.debug('In-Delivery Subscription');
                                            
                                            Boolean errorInProcessing = false;
                                            
                                            accRevForRec.account__c = accId;
                                            accRevForRec.LOB_O__c = 'C - In-Delivery Subscription';
                                            accRevForRec.Offering_Type__c = 'PureCloud';
                                            accRevForRec.Cloud_Forecast_Quarter__c = cloudForecastQuartRec.id;
                                            
                                            if(!accIdToCloseDatePlus4Map.isEmpty() && accIdToCloseDatePlus4Map.get(accId) != null){
                                                
                                                
                                                String[] startMonthYearArray = accIdToCloseDatePlus4Map.get(accId).split(':');
                                                
                                                System.debug('startMonthYearArray ' +startMonthYearArray);
                                                    
                                                if(startMonthYearArray.size() > 0){
                                                    
                                                    System.debug('startMonthYearArray[0] ' +startMonthYearArray[0]);
                                                    
                                                    System.debug('startMonthYearArray[1] ' +startMonthYearArray[1]);
                                                    
                                                    System.debug('startMonthYearArray[2] ' +startMonthYearArray[2]);
                                                    
                                                        
                                                        for(Integer year = Integer.valueOf(startMonthYearArray[2]); year<2022; year++){
                                                            
                                                            
                                                            
                                                            if(!numberToMonthMap.isEmpty()){
                                                                
                                                                
                                                                if(year == Integer.valueOf(startMonthYearArray[2])){
                                                                    for(Integer month = Integer.valueOf(startMonthYearArray[0]); month<13; month++){
                                                                        
                                                                        //System.debug('col Value ' + numberToMonthMap.get(month) + year + '__c');
                                                                        
                                                                        //System.debug('Month Value ' + (Decimal)accRevForRec.get(numberToMonthMap.get(month) + year + '__c'));
                                                                            
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',0.0);
                                                                        //System.debug('monthValue for current year'+aggregateCMMRValueForAccount );
                                                                    
                                                                    
                                                                    }
                                                                    
                                                                }else{
                                                                    for(Integer month = 1; month<13; month++){
                                                                        
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',0.0);
                                                                        
                                                                    
                                                                    
                                                                    }
                
                
                
                                                                }   
                                                                    
                                                                
                                                                
                                                            } 
                                                            
                                                            
                                                            
                                                        }  
                                                    
                                                    
                                                
                                                    
                                                }    

                                                
                                                
                                                
                                                
                                                
                                            }
                                            
                                            if(!errorInProcessing){
                                                    accRevForecastListToBeInserted.add(accRevForRec);
                                                }
                                        
                                        
                                        
                                        }else if(lob.equals('E - Telco Overage')){
                                            Account_Revenue_Forecast__c accRevForRec = new Account_Revenue_Forecast__c();
                                            System.debug('Telco Overage');
                                            
                                            Boolean errorInProcessing = false;
                                            
                                            accRevForRec.account__c = accId;
                                            accRevForRec.LOB_O__c = 'E - Telco Overage';
                                            accRevForRec.Offering_Type__c = 'PureCloud';
                                            accRevForRec.Cloud_Forecast_Quarter__c = cloudForecastQuartRec.id;
                                            
                                            if(!accIdToCloseDatePlus4Map.isEmpty() && accIdToCloseDatePlus4Map.get(accId) != null){
                                                
                                                
                                                String[] startMonthYearArray = accIdToCloseDatePlus4Map.get(accId).split(':');
                                                
                                                System.debug('startMonthYearArray ' +startMonthYearArray);
                                                    
                                                if(startMonthYearArray.size() > 0){
                                                    
                                                    System.debug('startMonthYearArray[0] ' +startMonthYearArray[0]);
                                                    
                                                    System.debug('startMonthYearArray[1] ' +startMonthYearArray[1]);
                                                    
                                                    System.debug('startMonthYearArray[2] ' +startMonthYearArray[2]);
                                                    
                                                    
                                                        for(Integer year = Integer.valueOf(startMonthYearArray[2]); year<2022; year++){
                                                            
                                                            
                                                            
                                                            if(!numberToMonthMap.isEmpty()){
                                                                
                                                                
                                                                if(year == Integer.valueOf(startMonthYearArray[2])){
                                                                    for(Integer month = Integer.valueOf(startMonthYearArray[0]); month<13; month++){
                                                                        
                                                                        //System.debug('col Value ' + numberToMonthMap.get(month) + year + '__c');
                                                                        
                                                                        //System.debug('Month Value ' + (Decimal)accRevForRec.get(numberToMonthMap.get(month) + year + '__c'));
                                                                            
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',0.0);
                                                                        //System.debug('monthValue for current year'+aggregateCMMRValueForAccount );
                                                                    
                                                                    
                                                                    }
                                                                    
                                                                }else{
                                                                    for(Integer month = 1; month<13; month++){
                                                                        
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',0.0);
                                                                        
                                                                    
                                                                    
                                                                    }
                
                
                
                                                                }   
                                                                    
                                                                
                                                                
                                                            } 
                                                            
                                                            
                                                            
                                                        }
                                                    
                                                
                                                    
                                                }    

                                                
                                                
                                                
                                                
                                                
                                            }
                                            
                                            if(!errorInProcessing){
                                                    accRevForecastListToBeInserted.add(accRevForRec);
                                                }
                                        
                                        
                                        
                                        }else if(lob.equals('F - In- Delivery Telco')){
                                            Account_Revenue_Forecast__c accRevForRec = new Account_Revenue_Forecast__c();
                                            System.debug('In- Delivery Telco');
                                            
                                            Boolean errorInProcessing = false;
                                            
                                            accRevForRec.account__c = accId;
                                            accRevForRec.LOB_O__c = 'F - In- Delivery Telco';
                                            accRevForRec.Offering_Type__c = 'PureCloud';
                                            accRevForRec.Cloud_Forecast_Quarter__c = cloudForecastQuartRec.id;
                                            
                                            if(!accIdToCloseDatePlus4Map.isEmpty() && accIdToCloseDatePlus4Map.get(accId) != null){
                                                
                                                
                                                String[] startMonthYearArray = accIdToCloseDatePlus4Map.get(accId).split(':');
                                                
                                                System.debug('startMonthYearArray ' +startMonthYearArray);
                                                    
                                                if(startMonthYearArray.size() > 0){
                                                    
                                                    System.debug('startMonthYearArray[0] ' +startMonthYearArray[0]);
                                                    
                                                    System.debug('startMonthYearArray[1] ' +startMonthYearArray[1]);
                                                    
                                                    System.debug('startMonthYearArray[2] ' +startMonthYearArray[2]);
                                                        for(Integer year = Integer.valueOf(startMonthYearArray[2]); year<2022; year++){
                                                            
                                                            
                                                            
                                                            if(!numberToMonthMap.isEmpty()){
                                                                
                                                                
                                                                if(year == Integer.valueOf(startMonthYearArray[2])){
                                                                    for(Integer month = Integer.valueOf(startMonthYearArray[0]); month<13; month++){
                                                                        
                                                                        //System.debug('col Value ' + numberToMonthMap.get(month) + year + '__c');
                                                                        
                                                                        //System.debug('Month Value ' + (Decimal)accRevForRec.get(numberToMonthMap.get(month) + year + '__c'));
                                                                            
                                                                        
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',0.0);
                                                                       
                                                                    
                                                                    
                                                                    }
                                                                    
                                                                }else{
                                                                    for(Integer month = 1; month<13; month++){
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',0.0);
                                                                    }
                                                                }  
                                                            } 
                                                        } 
                                                }  
                                            }
                                            
                                            if(!errorInProcessing){
                                                accRevForecastListToBeInserted.add(accRevForRec);
                                            }
                                        }else if(lob.equals('G - TAM')){
                                            Account_Revenue_Forecast__c accRevForRec = new Account_Revenue_Forecast__c();
                                            System.debug('G - TAM');
                                            
                                            Boolean errorInProcessing = false;
                                            
                                            accRevForRec.account__c = accId;
                                            accRevForRec.LOB_O__c = 'G - TAM';
                                            accRevForRec.Offering_Type__c = 'PureCloud';
                                            accRevForRec.Cloud_Forecast_Quarter__c = cloudForecastQuartRec.id;                                            
                                            if(!accIdToCloseDatePlus4Map.isEmpty() && accIdToCloseDatePlus4Map.get(accId) != null){          
                                                String[] startMonthYearArray = accIdToCloseDatePlus4Map.get(accId).split(':');                                                
                                                System.debug('startMonthYearArray ' +startMonthYearArray);                                                    
                                                if(startMonthYearArray.size() > 0){                                                    
                                                    System.debug('startMonthYearArray[0] ' +startMonthYearArray[0]);                                                    
                                                    System.debug('startMonthYearArray[1] ' +startMonthYearArray[1]);                                                    
                                                    System.debug('startMonthYearArray[2] ' +startMonthYearArray[2]); 
                                                        for(Integer year = Integer.valueOf(startMonthYearArray[2]); year<2022; year++){
                                                            if(!numberToMonthMap.isEmpty()){
                                                                if(year == Integer.valueOf(startMonthYearArray[2])){
                                                                    for(Integer month = Integer.valueOf(startMonthYearArray[0]); month<13; month++){                                                                        
                                                                        //System.debug('col Value ' + numberToMonthMap.get(month) + year + '__c');                                                                        
                                                                        //System.debug('Month Value ' + (Decimal)accRevForRec.get(numberToMonthMap.get(month) + year + '__c'));  
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',0.0);                                                                    
                                                                    }                                                                    
                                                                }else{
                                                                    for(Integer month = 1; month<13; month++){
                                                                        accRevForRec.put(numberToMonthMap.get(month) + year + '__c',0.0);
                                                                    }
                                                                }  
                                                            } 
                                                        }
                                                }  
                                            }
                                            
                                           if(!errorInProcessing){
                                                accRevForecastListToBeInserted.add(accRevForRec);
                                            }
                                        }
        }//lob For loop
  }
  
  
  
  public PageReference openReport(){
    
        Pagereference pageRef = Page.PESSRevenueForecastFileUploadErrorCSV;        
        return pageRef;
    
    
    }
  
  
  
    public class AccountRevnueForecastWrapper{
      
        String accId{get;set;}
        String oppId{get;set;}
        Decimal cmrrValue{get;set;}
        //Date oppCloseDate{get;set;}
        Decimal telcoPercent{get;set;}      
      
        public AccountRevnueForecastWrapper(String accRevdata,List<AccountRevnueForecastErrorWrapper> accRevForErrorWrapperList,String[] csvFieldNames,List<Boolean> errorIndicatorList){
            Boolean errorFlag = false;
            String[] csvRecordData = accRevdata.split(',');

            AccountRevnueForecastErrorWrapper accRevForErrorWrapObj = new AccountRevnueForecastErrorWrapper();
            accRevForErrorWrapObj.errReason = '';
            accRevForErrorWrapObj.accId = csvRecordData[0];
            accRevForErrorWrapObj.oppId = csvRecordData[1];
            accRevForErrorWrapObj.cmrrValue = csvRecordData[2];
            accRevForErrorWrapObj.telcoPercent = csvRecordData[3];
            try{
                ID accountID = csvRecordData[0];
                accId = csvRecordData[0];
            }catch(TypeException Exp){
                        //Adding data to .csv file        
                accRevForErrorWrapObj.errReason = accRevForErrorWrapObj.errReason + Exp.getMessage() + '(' + csvFieldNames[0] + ')' + ',';
                errorFlag = true;                   
                //accRevForErrorWrapperList.add(accRevForErrorWrapObj);                 
            }catch(StringException Exp){
                //Adding data to .csv file        
                accRevForErrorWrapObj.errReason = accRevForErrorWrapObj.errReason + Exp.getMessage() + '(' + csvFieldNames[0] + ')' + ',';
                errorFlag = true;           
                //accRevForErrorWrapperList.add(accRevForErrorWrapObj);                 
            }

            try{            
                ID opportunityID = csvRecordData[1];            
                oppId = csvRecordData[1];
            }catch(TypeException Exp){
                //Adding data to .csv file        
                accRevForErrorWrapObj.errReason = accRevForErrorWrapObj.errReason + Exp.getMessage() + '(' + csvFieldNames[1] + ')' + ',';
                errorFlag = true;
                //accRevForErrorWrapperList.add(accRevForErrorWrapObj);                 
            }catch(StringException Exp){
                //Adding data to .csv file        
                accRevForErrorWrapObj.errReason = accRevForErrorWrapObj.errReason + Exp.getMessage() + '(' + csvFieldNames[1] + ')' + ',';
                errorFlag = true;                   
                //accRevForErrorWrapperList.add(accRevForErrorWrapObj);                 
            }

            try{
                cmrrValue = csvRecordData[2] != ''?decimal.valueOf(csvRecordData[2].trim()) : 0.0;
            }catch(TypeException Exp){
                //Adding data to .csv file        
                accRevForErrorWrapObj.errReason = accRevForErrorWrapObj.errReason + Exp.getMessage() + '(' + csvFieldNames[2] + ')' + ',';
                errorFlag = true;           
                //accRevForErrorWrapperList.add(accRevForErrorWrapObj);                 
            }catch(StringException Exp){
                //Adding data to .csv file        
                accRevForErrorWrapObj.errReason = accRevForErrorWrapObj.errReason + Exp.getMessage() + '(' + csvFieldNames[2] + ')' + ',';
                errorFlag = true;                   
                //accRevForErrorWrapperList.add(accRevForErrorWrapObj);                 
            }

            try{
                telcoPercent = csvRecordData[3] != ''?Decimal.valueOf(csvRecordData[3].trim()) : 0.0;
            }catch(TypeException Exp){
                //Adding data to .csv file        
                accRevForErrorWrapObj.errReason = accRevForErrorWrapObj.errReason + Exp.getMessage() + '(' + csvFieldNames[3] + ')' + ',';
                errorFlag = true;
                //accRevForErrorWrapperList.add(accRevForErrorWrapObj);
            }catch(StringException Exp){
                //Adding data to .csv file        
                accRevForErrorWrapObj.errReason = accRevForErrorWrapObj.errReason + Exp.getMessage() + '(' + csvFieldNames[3] + ')' + ',';
                errorFlag = true;
                
                //accRevForErrorWrapperList.add(accRevForErrorWrapObj); 
            }
            
            if(errorFlag){
                if(accRevForErrorWrapObj.errReason.length() > 2){             
                    accRevForErrorWrapObj.errReason = accRevForErrorWrapObj.errReason.substring(0,accRevForErrorWrapObj.errReason.length()-1);
                }
                errorIndicatorList.add(true);         
                accRevForErrorWrapperList.add(accRevForErrorWrapObj);
            }
        } 
      
    }
  
  
    public class AccountRevnueForecastErrorWrapper{      
        public String accId{get;set;}
        public String oppId{get;set;}
        public String cmrrValue{get;set;}
        public String telcoPercent{get;set;}
        public String errReason{get;set;}      
    }
}