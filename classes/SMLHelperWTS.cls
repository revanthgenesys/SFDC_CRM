//Naresh Kumar  12/10/2012
public without sharing class SMLHelperWTS {
    
    public static SML_Data__c populateSMLRecord(String smlDataId){      
        return [SELECT id, Account__c, Account__r.Name, Competitors__c, Solution_Category__c, Status__c, Status1__c, Comments__c, Notes__c, Technical_Profile_Competitor__c, 
         Technical_Profile_Competitor__r.Technical_Profile__c, Solution_Category__r.Name, Solution_Category__r.Solution_Name__c, Under_Maintenance__c,      
         (SELECT id, Product__r.Description, Product__r.Name, BigMachines_Quantity__c, Sales_Price__c, Order__r.Invoice_Date__c, Order__c, Extended_Net_Price__c,
         Total_Price__c, Order__r.Name, Product__r.Type__c FROM Order_Line_Items__r ORDER BY Order__r.Invoice_Date__c DESC LIMIT 50),
         (SELECT id, PricebookEntry.Product2.Description, PricebookEntry.Product2.Name, Quantity, Revised_Net_License_value__c, CreatedDate, ServiceContractId, 
         ServiceContract.Name, PricebookEntry.Product2.Type__c FROM Contract_Line_Items__r ORDER BY CreatedDate DESC LIMIT 50),         
         (SELECT id, BigMachines__Product__r.Description, BigMachines__Product__r.Name, BigMachines__Quantity__c, BigMachines__Sales_Price__c, Ext_Net_Price__c,
         BigMachines__Quote__r.BigMachines__Opportunity__c, BigMachines__Quote__r.BigMachines__Opportunity__r.StageName, 
         BigMachines__Quote__r.BigMachines__Opportunity__r.NextStep, BigMachines__Quote__c, BigMachines__Quote__r.Name,
         BigMachines__Quote__r.BigMachines__Opportunity__r.CloseDate, BigMachines__Quote__r.BigMachines__Opportunity__r.ForecastStatus__c,
         BigMachines__Quote__r.BigMachines__Opportunity__r.Name, BigMachines__Product__r.Type__c FROM BigMachines_Quote_Products__r ORDER BY CreatedDate DESC LIMIT 50),         
         (SELECT id, New_Status__c, Comments__c, CreatedDate, CreatedBy.Name, Created_By__c FROM Account_Trends__r ORDER BY CreatedDate DESC LIMIT 5)
         //(SELECT id, Opportunity__c, Opportunity__r.Name, Opportunity__r.StageName, Opportunity__r.NextStep, Opportunity__r.CloseDate, 
         //  Opportunity__r.ForecastStatus__c  FROM Opportunity_SML_Data__r ORDER BY CreatedDate DESC LIMIT 5)
         FROM SML_Data__c WHERE id =: smlDataId];
    } 
    
    public static void deleteEngagementDataForDuplicateAccount(Set<Id> accountIds){
        List<SML_Account_Engagement_Score__c> scoreHistoryToBeDeleted = [SELECT id FROM SML_Account_Engagement_Score__c WHERE Account__c =: accountIds];
        if(!scoreHistoryToBeDeleted.isEmpty())
            delete scoreHistoryToBeDeleted;
        List<SML_Data__c> smlDataToBeDeleted = [SELECT id FROM SML_Data__c WHERE Account__c IN : accountIds];
        if(!smlDataToBeDeleted.isEmpty())
            delete smlDataToBeDeleted;
    }
    
    public static List<OpportunityLineItem> populateOppLines(String accountId, String productCategory){     
        //Getting opportunity line items
        List<OpportunityLineItem> oppLineItems = [SELECT OpportunityId, Opportunity.Name, Opportunity.StageName, Opportunity.NextStep, 
            Opportunity.CloseDate, Opportunity.ForecastStatus__c, PriceBookentry.Product2.Environment__c, PriceBookentry.Product2.Description, 
            PriceBookentry.Product2.Name, Quantity, UnitPrice, PriceBookentry.Product2.Type__c 
            FROM OpportunityLineItem WHERE Opportunity.AccountId =: accountId
            AND Opportunity.StageName != : SMLHelper.OPP_STAGE_CLOSED 
            AND Opportunity.RecordType.DeveloperName = 'GEN_Opportunity_Record_Type_New'            
            AND PriceBookentry.Product2.Solution_Category1__c =: productCategory];
        List<OpportunityLineItem> oppLineItems1 = new List<OpportunityLineItem>();
        //Looping over each line
        for(OpportunityLineItem eachLine : oppLineItems){
            if(SMLBatchHelper.doExcludeProduct(eachLine.PriceBookentry.Product2.Environment__c))
                continue;
            oppLineItems1.add(eachLine);
        }   
        return oppLineItems1;           
    }
    
    public static void runSMLUpdateForOrder(List<Order_Line_Item__c> ordersLineItems){
        Set<String> setOfOrderIds = new Set<String>();
        //Looping over each line item
        for(Order_Line_Item__c eachItem : ordersLineItems){
            setOfOrderIds.add(eachItem.Order__c);
        }       
        List<Order__c> orders = [SELECT End_User_Name__c FROM Order__c WHERE ID IN : setOfOrderIds];
        Set<Id> setOfAccountIds = new Set<Id>();
        //Looping over each Order
        for(Order__c eachOrder : orders){
            setOfAccountIds.add(eachOrder.End_User_Name__c);
        }
        if(!setOfAccountIds.isEmpty() && TriggerFlowManager.START_SML_FUTURE_UPDATE){
          TriggerFlowManager.START_SML_FUTURE_UPDATE = false;        
          updateSMLRealTimeF(setOfAccountIds);
        }
    }
    
    public static void updateSMLForAccount(Id accountId){
      Set<Id> accIds = new Set<Id>();
      accIds.add(accountId);
      updateSMLRealTimeF(accIds);
    }
    
    @future
    public static void updateSMLRealTimeF(Set<Id> accIds){
      SMLBatchHelper.updateSMLRealTime(accIds);
    }
    
    public static void runSMLUpdateForOpportunityStageChange(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap){
      Set<Id> setOfAccountIds = new Set<Id>();
      //Looping over each opportunity
      for(Opportunity eachOpp : opportunities){
        Opportunity oldOpp = oldMap.get(eachOpp.id);
        if((eachOpp.StageName == SMLHelper.OPP_STAGE_CLOSED && oldOpp.StageName != SMLHelper.OPP_STAGE_CLOSED)
          || (eachOpp.StageName != SMLHelper.OPP_STAGE_CLOSED && oldOpp.StageName == SMLHelper.OPP_STAGE_CLOSED))
          setOfAccountIds.add(eachOpp.accountId);
      }
      if(!setOfAccountIds.isEmpty() && TriggerFlowManager.START_SML_FUTURE_UPDATE){
          TriggerFlowManager.START_SML_FUTURE_UPDATE = false;        
          updateSMLRealTimeF(setOfAccountIds);
        }
    }
    
    public static void runSMLUpdateForOrderStatusChange(List<Order__c> orders, Map<Id, Order__c> oldMap){
      Set<Id> setOfAccountIds = new Set<Id>();
      //Looping over each opportunity
      for(Order__c eachOrder : orders){
        Order__c oldOrder = oldMap.get(eachOrder.id);
        if(eachOrder.Status__c == SMLHelper.ORDER_STATUS_APPROVED && eachOrder.Status__c != oldOrder.Status__c)
          setOfAccountIds.add(eachOrder.End_User_Name__c);
      }
      if(!setOfAccountIds.isEmpty() && TriggerFlowManager.START_SML_FUTURE_UPDATE){
          TriggerFlowManager.START_SML_FUTURE_UPDATE = false;        
          updateSMLRealTimeF(setOfAccountIds);
        }
    }
    
    
    
    public static void runSMLUpdateForBlocked(List<Technical_Profile_Competitors__c> competitors){
      Set<Id> setOfTechnichalProfileIds = new Set<Id>();
      //Looping over each record
      for(Technical_Profile_Competitors__c eachRecord : competitors){
        setOfTechnichalProfileIds.add(eachRecord.Technical_Profile__c);
      }
      List<Technical_Profile__c> technichalProfiles = [SELECT Account__c FROM Technical_Profile__c WHERE id IN : setOfTechnichalProfileIds];
      Set<Id> setOfAccountIds = new Set<Id>();
      for(Technical_Profile__c eachProfile : technichalProfiles){
        setOfAccountIds.add(eachProfile.Account__c);
      }
      if(!setOfAccountIds.isEmpty() && TriggerFlowManager.START_SML_FUTURE_UPDATE){
          TriggerFlowManager.START_SML_FUTURE_UPDATE = false;        
          updateSMLRealTimeF(setOfAccountIds);
        }
    }
    
    public static void runSMLUpdateForQuote(List<BigMachines__Quote__c> quotes, Map<Id, BigMachines__Quote__c> oldMap){
      Set<Id> setOfAccountIds = new Set<Id>();
      //Looping over each quote
      for(BigMachines__Quote__c eachQuote : quotes){
        if(eachQuote.BigMachines__Is_Primary__c != oldMap.get(eachQuote.id).BigMachines__Is_Primary__c){
          setOfAccountIds.add(eachQuote.End_User_ID__c);  
        }
      }
      if(!setOfAccountIds.isEmpty() && TriggerFlowManager.START_SML_FUTURE_UPDATE){
          TriggerFlowManager.START_SML_FUTURE_UPDATE = false;        
          updateSMLRealTimeF(setOfAccountIds);
        }
    }
    
    public static void runSMLUpdateForQuote(List<BigMachines__Quote_Product__c> quoteProducts){
        Set<String> setOfQuoteIds = new Set<String>();
        //Looping over each line item
        for(BigMachines__Quote_Product__c eachItem : quoteProducts){
            setOfQuoteIds.add(eachItem.BigMachines__Quote__c);
        }
        List<BigMachines__Quote__c> quotes = [SELECT End_User_ID__c FROM BigMachines__Quote__c WHERE id IN : setOfQuoteIds AND BigMachines__Is_Primary__c = true];
        Set<Id> setOfAccountIds = new Set<Id>();
        //Looping over each Quote
        for(BigMachines__Quote__c eachQuote : quotes){
            setOfAccountIds.add(eachQuote.End_User_ID__c);
        }                
        if(!setOfAccountIds.isEmpty() && TriggerFlowManager.START_SML_FUTURE_UPDATE){
          TriggerFlowManager.START_SML_FUTURE_UPDATE = false;        
          updateSMLRealTimeF(setOfAccountIds);
        }
    }    
    
    public static void runSMLUpdateForOpportunity(List<OpportunityLineItem> newOppLineItemList){
      Set<Id> setOfOpportunityIds = new Set<Id>();
      //Loop over each line item
      for(OpportunityLineItem eachLineItem : newOppLineItemList){
        setOfOpportunityIds.add(eachLineItem.opportunityId);
      }
      Set<Id> setOfAccountIds = new Set<Id>();
      List<Opportunity> opportunities = [SELECT AccountId FROM Opportunity WHERE id IN : setOfOpportunityIds];        
      //Looping oer each Opportunity
      for(Opportunity eachOpp : opportunities){
        setOfAccountIds.add(eachOpp.AccountId);        
      }
      if(!setOfAccountIds.isEmpty() && TriggerFlowManager.START_SML_FUTURE_UPDATE){
          TriggerFlowManager.START_SML_FUTURE_UPDATE = false;        
          updateSMLRealTimeF(setOfAccountIds);
        }
    }
    
    public static void runSMLUpdateForServiceContract(List<ContractLineItem> contractLineItem){
        Set<String> setOfServiceContractIds = new Set<String>();
        //Looping over each line item
        for(ContractLineItem eachItem : contractLineItem){
            setOfServiceContractIds.add(eachItem.ServiceContractId);
        }
        List<ServiceContract> serviceContracts = [SELECT End_User_Name__c FROM ServiceContract WHERE ID IN : setOfServiceContractIds];
        Set<Id> setOfAccountIds = new Set<Id>();
        //Looping over each Order
        for(ServiceContract eachSC : serviceContracts){
            setOfAccountIds.add(eachSc.End_User_Name__c);
        }
        if(!setOfAccountIds.isEmpty() && TriggerFlowManager.START_SML_FUTURE_UPDATE){
          TriggerFlowManager.START_SML_FUTURE_UPDATE = false;        
          updateSMLRealTimeF(setOfAccountIds);
        }
    }
    
    public static void initializeSML(Set<Id> accountIds, Map<Id, Account> oldMap, Boolean isInsert){
      List<Account> accounts = [SELECT RecordType.DeveloperName, New_Logo__c FROM Account WHERE id IN : accountIds];
      Set<Id> setOfAccountIds = new Set<Id>();
      //Looping over each account
      for(Account eachAccount : accounts){
        if((eachAccount.New_Logo__c && (oldMap == null || !oldMap.get(eachAccount.id).New_Logo__c))
          || (isInsert && eachAccount.RecordType.DeveloperName == 'EMGProspectRecordType') )
          setOfAccountIds.add(eachAccount.id);
      }
      if(!setOfAccountIds.isEmpty()){
        SMLBatchHelper.initializeSMLData(setOfAccountIds);
      }
    }
    
    public static List<SelectOption> populateSubRegion(List<SelectOption> subRegionList, String region){
        subRegionList = new List<SelectOption>();
        subRegionList.add(new SelectOption('', '--Select--'));
        Set<String> setOfSubRegion = new Set<String>();
        if(region == 'North America'){
            subRegionList.add(new SelectOption('BE Cloud', 'BE Cloud'));
      subRegionList.add(new SelectOption('BE Cloud CSM','BE Cloud CSM'));
      subRegionList.add(new SelectOption('Canada','Canada'));
      subRegionList.add(new SelectOption('Central','Central'));
      subRegionList.add(new SelectOption('Corporate Sales','Corporate Sales'));
      subRegionList.add(new SelectOption('Corporate Sales CSM', 'Corporate Sales CSM'));
      subRegionList.add(new SelectOption('CSM','CSM'));
      subRegionList.add(new SelectOption('East','East'));
      subRegionList.add(new SelectOption('Global Accounts','Global Accounts'));
      subRegionList.add(new SelectOption('Government','Government'));
      subRegionList.add(new SelectOption('NA Outbound Engagement','NA Outbound Engagement'));
      subRegionList.add(new SelectOption('NA Strategic Accounts','NA Strategic Accounts'));
      subRegionList.add(new SelectOption('North America Partners','North America Partners'));
      subRegionList.add(new SelectOption('Outbound Engagement CSM','Outbound Engagement CSM'));
      subRegionList.add(new SelectOption('West','West'));            
        }
        else{       
            System.debug('NKC debug region [' + region + ']');     
            List<Country__c> countries = [SELECT RU__c FROM Country__c WHERE Region__c =: region AND RU__c != null];                
            //Looping over each country
            for(Country__c eachCountry : countries){
                if(!setOfSubRegion.contains(eachCountry.RU__c)){
                    setOfSubRegion.add(eachCountry.RU__c);            
                    subRegionList.add(new SelectOption(eachCountry.RU__c, eachCountry.RU__c));
                }
            }
        }
        return subRegionList;      
    }
    
    public static void populateAccountSCKey(List<Technical_Profile_Competitors__c > profileCompetitors){
      //Looping over each competitor
      for(Technical_Profile_Competitors__c eachItem : profileCompetitors){
        eachItem.TechnichalProfileSC_Key__c = String.valueOf(eachItem.Technical_Profile__c) + String.valueOf(eachItem.Product_Category__c);
      }
    }
    
    public static void populateTechnichalProfileCompetitors(List<Technical_Profile__c> technichalProfiles){
      //Querying all solutions categories
       String competitor;
        List<Solution_Category__c> solutionCategories = [SELECT Name, Technical_Profile_Field_Name__c FROM Solution_Category__c 
          WHERE Active__c = true];
        List<Technical_Profile_Competitors__c> technichalProfilesToBeUpserted = new List<Technical_Profile_Competitors__c>();
        //Looping overr each technichal profile
        for(Technical_Profile__c eachTechnichalProfile : technichalProfiles){
          //Looping over each solution category
          for(Solution_Category__c eachSolutionCategory : solutionCategories){
            Technical_Profile_Competitors__c newCompetitor = new Technical_Profile_Competitors__c();            
            newCompetitor.Technical_Profile__c = eachTechnichalProfile.id;
            newCompetitor.Product_Category__c = eachSolutionCategory.id;
            newCompetitor.TechnichalProfileSC_Key__c = String.valueOf(newCompetitor.Technical_Profile__c) + String.valueOf(newCompetitor.Product_Category__c);  
            if(eachSolutionCategory.Technical_Profile_Field_Name__c !=null) //added by swastika(Rsystems) on 14-Apr-2016 to remove the Null exception error        
                competitor = (String)eachTechnichalProfile.get(eachSolutionCategory.Technical_Profile_Field_Name__c);
            List<String> excludeCompetitors = Label.SML_TFC_Excluded.split(';');
            Boolean isCompetitorNull = false;
            for(String eachValue : excludeCompetitors){
              if(competitor != null && competitor.contains(eachValue)){
                isCompetitorNull = true;
                break;
              }                
            }
            if(isCompetitorNull)
              newCompetitor.Competitor__c = null;
            else
              newCompetitor.Competitor__c = (competitor == null ? null : competitor.replace('-','')); 
            technichalProfilesToBeUpserted.add(newCompetitor);
          }          
        }
        if(!technichalProfilesToBeUpserted.isEmpty())
          upsert technichalProfilesToBeUpserted TechnichalProfileSC_Key__c;
    }
    
    @future
    public static void insertSMLActivity(String smlId, String activityType){
        if(smlId == null){
            List<SML_Data__c> smlData = [SELECT id FROM SML_Data__c LIMIT 1];
            if(!smlData.isEmpty())
                smlId = smlData[0].id;
        }
        SML_Activity__c newActivity = new SML_Activity__c();
        newActivity.Status__c = activityType;     
        newActivity.SML_Data__c = smlId;
        insert newActivity;
    }
    
    public static void SMLDataAfterInsertUpdate(List<SML_Data__c> newList, Map<Id, SML_Data__c> oldMap){
        List<Account_Trends__c> accountTrendsToBeInserted = new List<Account_Trends__c>();
        List<SML_Data__c> smlsDataToBeUpdated = new List<SML_Data__c>();
        Set<Id> setOfAccountIds = new Set<Id>();
        //Looping over each record
        for(SML_Data__c eachRecord : newList){
            System.debug('NKC debug eachRecord.Status__c [' + eachRecord.Status__c + ']');
            SML_Data__c oldRecord = (oldMap != null ? oldMap.get(eachRecord.id) : null);
            if(oldRecord == null || eachRecord.Status__c != oldRecord.Status__c || eachRecord.Comments__c != oldRecord.Comments__c || eachRecord.Notes__c != oldRecord.Notes__c){                
                Account_Trends__c newTrend = new Account_Trends__c();
                if(oldRecord != null && eachRecord.Notes__c != oldRecord.Notes__c)
                    newTrend.Comments__c = eachRecord.Notes__c;
                else
                    newTrend.Comments__c = eachRecord.Comments__c;
                if(oldRecord != null)
                    newTrend.Old_Status__c = oldRecord.Status__c;
                else
                    newTrend.Comments__c = 'New record created';                    
                newTrend.New_Status__c = eachRecord.Status__c;                
                newTrend.SML_Data__c = eachRecord.id;                
                accountTrendsToBeInserted.add(newTrend);
                SML_Data__c smlDataToBeUpdated = new SML_Data__c( id = eachRecord.id);  
                if(oldRecord != null && eachRecord.Status__c == SMLHelper.BLOCKED && oldRecord.Status__c != null){
                    smlDataToBeUpdated.Last_Change__c = SMLHelper.NEGATIVE;
                }                
                else{
                    smlDataToBeUpdated.Last_Change__c = SMLHelper.POSITIVE;
                }
                if((eachRecord.Status__c == SMLHelper.SOLD && oldRecord.Status__c == SMLHelper.ACTIVE)){
                    //Naresh  12/09/2015
                    // || (eachRecord.Status__c == ACTIVE && oldRecord.Status__c == SOLD)){
                    smlDataToBeUpdated.Status__c = SMLHelper.ACTIVEANDSOLD;
                }
                if(oldRecord != null && eachRecord.Status__c != oldRecord.Status__c){
                    smlDataToBeUpdated.Whitespace_Date__c = System.today();
                } 
                if(eachRecord.Status__c == SMLHelper.PLANNING_UNDERWAY && (oldRecord == null || oldRecord.Status__c != SMLHelper.PLANNING_UNDERWAY)){
                    smlDataToBeUpdated.Planning_Underway_Date__c = System.today();
                }
                if(eachRecord.Account__c != null)
                    setOfAccountIds.add(eachRecord.Account__c);
                smlsDataToBeUpdated.add(smlDataToBeUpdated);
            }            
        }
        if(!accountTrendsToBeInserted.isEmpty() && !SMLHelper.isCurrentUserAdminToBeSkipped()){
            insert accountTrendsToBeInserted;
        }
        if(!smlsDataToBeUpdated .isEmpty()){
            update smlsDataToBeUpdated ;
        }
        if(!setOfAccountIds.isEmpty()){
            SMLBatchHelper.calculateEngagementScore(setOfAccountIds);
        }
    }
   
   public static void insertBatchLog(String accountId, String actionType, String errorDescription){
        SML_Batch_Log__c newLog = new SML_Batch_Log__c();
        newLog.Account__c = accountId;
        newLog.Action_Type__c = actionType;
        newLog.Error_Descripiton__c = errorDescription;
        insert newLog;        
    }
    
    public static void addInsertBatchLog(List<SML_Batch_Log__c> logsToBeInserted, String accountId, String actionType, String errorDescription){
        SML_Batch_Log__c newLog = new SML_Batch_Log__c();
        newLog.Account__c = accountId;
        newLog.Action_Type__c = actionType;
        newLog.Error_Descripiton__c = errorDescription;
        logsToBeInserted.add(newLog);        
    }  
    
    public static void updateAccountEngScorePositiveNegativeStatus(List<SML_Account_Engagement_Score__c> newList, Map<Id, SML_Account_Engagement_Score__c> oldMap){
        List<SML_Account_Engagement_Score_History__c> scoreHistoryToBeInserted = new List<SML_Account_Engagement_Score_History__c>();
        //Looping over each record
        for(SML_Account_Engagement_Score__c newRecord : newList){
            SML_Account_Engagement_Score__c oldRecord = oldMap.get(newRecord.id);
            
                //newRecord.Account__c = oldRecord.Account__c;
            if(newRecord.Score__c != null && oldRecord.Score__c != null){
            // NM: Added the following line to enable update of previous score for reporting
                newRecord.Previous_Score__c = oldRecord.Score__c;

                if(newRecord.Score__c == oldRecord.Score__c)
                    newRecord.Last_Change__c = null;
                else if(newRecord.Score__c > oldRecord.Score__c)
                    newRecord.Last_Change__c = 'Positive';
                else
                    newRecord.Last_Change__c = 'Negative';
            }
            if(newRecord.Score__c != null || oldRecord.Score__c != null && (newRecord.Score__c != oldRecord.Score__c)){
                SML_Account_Engagement_Score_History__c newScoreHistory = new SML_Account_Engagement_Score_History__c();    
                newScoreHistory.SML_Account_Engagement_Score__c = newRecord.id;
                newScoreHistory.Old_Score__c = oldRecord.Score__c;
                newScoreHistory.New_Score__c = newRecord.Score__c;
                scoreHistoryToBeInserted.add(newScoreHistory);
            }            
        }
        if(!scoreHistoryToBeInserted.isEmpty() && !SMLHelper.isCurrentUserAdminToBeSkipped())
            insert scoreHistoryToBeInserted;    
    }
    
    public static List<SML_Feedback_Comments__c> populateFeedbacks(String smlId){
        return [SELECT SML_Data__c, Comments__c, CreatedBy.Name, CreatedDate FROM SML_Feedback_Comments__c WHERE SML_Data__c =: smlId ORDER BY CreatedDate DESC LIMIT 5];
    }
    
    /*Added 23-Mar-2016 to support retrieval of document links for inclusion in the detailed view popup */
    public static List<Engagement_Map_Product_Doc_Links__c> populateGenieDocLinks(String SMLProductName){
        return [SELECT Name, Document_Link_URL__c FROM Engagement_Map_Product_Doc_Links__c WHERE EngMap_Product_Name__c =: smlProductName AND Doc_Link_Type__c = 'Genie' ORDER BY Name LIMIT 5];
    }    
    
    /*Added 24-Oct-2016 to support retrieval of Next Best Action Reason text for inclusion in the detailed view popup */
    public static List<Engagement_Map_NBA_Reasons__c> populateNBAReasonText(String SMLProductName){
        return [SELECT Name, NBA_Reason_Text__c FROM Engagement_Map_NBA_Reasons__c WHERE EngMap_Product_Name__c =: smlProductName ORDER BY Name LIMIT 5];
    }  
    
    public static void runSMLBatch(){    
        String batjobId = Database.executeBatch(new SMLBatch('SELECT id, Name FROM Account WHERE Engagement_Map__c = true LIMIT 50'),10);
    } 
    
    /*
    public static void runSMLUpdateForServiceContract(List<ServiceContract> serviceContract){
        Set<String> setOfOrderIds = new Set<String>();
        //Looping over each line item
        for(Order_Line_Item__c eachItem : ordersLineItems){
            setOfOrderIds.add(eachItem.Order__c);
        }
        List<Order__c> orders = [SELECT End_User_Name__c FROM Order__c WHERE ID IN : setOfOrderIds];
        String accIds = '(';
        //Looping over each Order
        for(Order__c eachOrder : orders){
            accIds += '\'' + eachOrder.End_User_Name__c + '\',';
        }
        accIds = accIds.removeEnd(',');
        accIds += ')';
        upsertSMLForOrdersF(accIds);
    }
    public static void runSMLUpdateBatch(String accIds){                
        String batjobId = Database.executeBatch(new SMLBatch('SELECT id, Name FROM Account WHERE ID IN ' + accIds), 10);
    }
    */
}