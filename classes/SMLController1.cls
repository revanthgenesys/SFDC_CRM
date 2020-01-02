//Naresh Kumar
public with sharing class SMLController1 {

    public  List<dataWrapper> smlRecords {get;set;}
    public  Set<String> solutionCategories {get;set;}
    public  Set<String> solutionCategories1 {get;set;}
    public Boolean showPopupFlag {get;set;}
    public SML_Data__c smlDataRow {get;set;}
    public String smlDataId {get;set;}
    public String vertical {get;set;}
    public String region {get;set;}
    public String subRegion {get;set;}
    public String orgName {get;set;}
    public String territory {get;set;}
    public String accountName {get;set;}
    public String category {get;set;}
    public String accountType {get;set;}
    public Boolean positiveChange {get;set;}
    public Boolean negativeChange {get;set;}    
    public Boolean key {get;set;}   
    public Boolean must {get;set;}        
    public Map<String, Integer> mapCategoryVsScores {get;set;}
    public Map<String, String> mapCategoryVsScoreColor {get;set;}
    public Boolean showResult {get;set;}
    public List<SelectOption> accountFilters {get;set;}
    public List<SelectOption> verticalOptions {get;set;}
    public String selectedFilter {get;set;}
    public Boolean smlFlag {get;set;}
    public String viewId {get;set;}
    public List<SelectOption> countries {get;set;}
    public Boolean showCLIs {get;set;}
    public Boolean showOLIs {get;set;}
    public Boolean showQPs {get;set;}
    public Boolean showOpps {get;set;}
    public Boolean hideAnalytics {get;set;}
    public Boolean hideCustomerEngagement {get;set;}
    public Boolean hideBussOpt {get;set;}
    public Boolean hideEmpEngagement {get;set;}
    public Boolean hideOmni {get;set;}
    public Boolean hideMultimediaCommunication {get;set;}
    public Boolean showHidePopup {get;set;}
    public List<SelectOption> regionList {get;set;}
    public List<SelectOption> subRegionList {get;set;}
    public List<SelectOption> aeList {get;set;}
    public String selectedAE {get;set;}    
    public Boolean pageLoadFilter {get;set;}
    public Integer pageSize {get;set;}
    public Integer pageNo {get;set;}
    public Integer pageStart {get;set;}
    public Integer pageEnd {get;set;}
    public Integer pages {get;set;}
    public String accId {get;set;}
    public Map<String, String> mapCategoryVsColor  {get;set;}
    public String selectedTab {get;set;}
    public Boolean resultSizeExceeded {get;set;}
    public Boolean pageClick {get;set;}
    public Boolean hideSelfService {get;set;}    
    public Boolean hidePlateFormService {get;set;}
    public Boolean hideAssistedService {get;set;}
    public List<SelectOption> availableStatus {get;set;}
    public Boolean isNonManager {get;set;}
    public SML_Feedback_Comments__c feedback {get;set;}
    public transient List<SML_Feedback_Comments__c> feedbacks {get;set;}
    public transient List<Engagement_Map_Product_Doc_Links__c> GenieDocLinks {get;set;}
    public transient List<Engagement_Map_NBA_Reasons__c> NBAReasonTextFull {get;set;}
    public List<OpportunityLineItem> smlDataRowOppLines {get;set;}
    public Boolean showNaStatus {get;set;}
    private String initialStatus {get;set;}
    public SMLController1(){   
        init();
    }
    
    private void init(){
        positiveChange = false;
        negativeChange = false;
        resultSizeExceeded = false;
        selectedTab = 'name2';
        pageSize = 50;
        pageNo = 1;
        pageLoadFilter = true;
        showResult = false;
        smlFlag = false;
        key = false;
        must = false;
        hideAnalytics = false;
        hideCustomerEngagement = false;
        hideBussOpt = false;
        hideEmpEngagement = false;
        hideOmni = false;
        hideMultimediaCommunication = false;
        showHidePopup = false;
        pageClick = false;
        isNonManager = false;
        mapCategoryVsScoreColor= new Map<String, String>();
        List<User> users = [SELECT id FROM User WHERE ManagerId =: UserInfo.getUserId() AND (Termination_Date__c = null OR Termination_Date__c > TODAY)];
        if(users.isEmpty())
            isNonManager = true;
        accountFilters = SMLHelper.populateAccountFilters(isNonManager);
        viewId = ApexPages.currentPage().getParameters().get('viewId');
        regionList = new List<SelectOption>();
        SelectOption newOption = new SelectOption('','--Select--');
        regionList.add(newOption);
        newOption = new SelectOption('North America','North America');
        regionList.add(newOption);
        newOption = new SelectOption('APAC','APAC');
        regionList.add(newOption);
        newOption = new SelectOption('LATAM','LATAM');
        regionList.add(newOption);
        newOption = new SelectOption('EMEA','EMEA');
        regionList.add(newOption);
        
        if(selectedFilter == null || selectedFilter == '')
            selectedFilter = 'My Accounts';
        countries = SMLHelper.populateCountries();
        subRegionList = new List<SelectOption>();
        subRegionList.add(new SelectOption('', '--Select--'));
        accId = ApexPages.currentPage().getParameters().get('accId');        
        showNaStatus = false;
        List<String> hideNAIds = Label.SML_Status_NA_Available_Users.split(';');
        List<User> hideNaUsers = [SELECT id FROM User WHERE id =: UserInfo.getUserId() AND (id IN : hideNAIds OR profileId =: hideNAIds)];
        if(!hideNaUsers.isEmpty()){
            showNaStatus = true;
        }        
        availableStatus = new List<SelectOption>();
        availableStatus.add(new SelectOption('Blocked', 'Blocked'));
        if(showNaStatus)
            availableStatus.add(new SelectOption('NA', 'NA'));
        availableStatus.add(new SelectOption('Planning Underway', 'Planning Underway'));
        availableStatus.add(new SelectOption('Whitespace', 'Whitespace'));
        availableStatus.add(new SelectOption('Next Best Action', 'Next Best Action'));
        //Populating Industry       
        verticalOptions = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Account.Industry.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        verticalOptions.add(new SelectOption('', '--Select--'));
        for(Schema.PicklistEntry f : ple){
            verticalOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        } 
        filter();
        populateMyTeam();
    }
    
    public void onLoad(){       
        SMLHelperWTS.insertSMLActivity(null, SMLHelper.SML_ACTIVITY_STATUS_OPENED_SML);
    }
    
    private String addViewQuery(String query, Boolean showViewData, Set<Id> setOfAccountIds){
        if(!pageLoadFilter || viewId == null)
            viewId = selectedFilter;
         List<SML_Search_View_Account__c> smlAccs = [SELECT Account__c FROM SML_Search_View_Account__c WHERE SML_Search_View__c  =: viewId];                     
         for(SML_Search_View_Account__c eachRecord : smlAccs){    
             setOfAccountIds.add(eachRecord.Account__c);             
         }
         System.debug('NKC debug setOfAccountIds [' + setOfAccountIds + ']');
         if(!setOfAccountIds.isEmpty()){
             query += ' AND Account__c IN : setOfAccountIds';
             showViewData = true;
         }
         return query;
    }
    
    
    public void populateSubRegion(){
        subRegionList = SMLHelperWTS.populateSubRegion(subRegionList, region);  
    }
    
    
    public void filterBtn(){
        accId = null;
        pageClick = false;
        filter();
    }
    
    public void filter(){ 
        if(!pageClick)
            pageNo = 1;        
        
        //Getting All SML Data
        String query = 'SELECT Account__c, Solution_Category__r.Name, Solution_Category__r.Solution_Name__c, Account__r.Key__c, Account__r.Must__c, Account__r.Account_Segmentation__c,' 
            + ' Status__c, Status1__c, Account__r.Name, Account__r.Parent_Account__r.Name, Account__r.Region__c, Account__r.Country__r.Name, Account__r.Genesys_Care_Offering__c, Notes__c,' 
            + ' Account__r.Owner.Name, Account__r.Owner.Sub_Region__c, Order_Info__c, Account__r.Type, Whitespace_Days__c, Whitespace_over_Threshold__c,'
            + ' Technical_Profile_Competitor__r.Technical_Profile__c, Competitors__c, Under_Maintenance__c, Confidence_Level__c, Confidence_Level_Formula__c, Cell_Color__c, NBA_Reason_Text__c  '
            + ' FROM SML_Data__c WHERE (Account__r.Name != null AND Account__r.RecordType.Name != \'Enterprise - Business Partner\' ';
        Boolean showViewData = false;
        Set<Id> setOfAccountIds = new Set<Id>();
        if(viewId != null){
            query = addViewQuery(query, showViewData, setOfAccountIds);
            selectedFilter = viewId;
        }
        if(accId != null){
            query += ' AND Account__c = \'' + accId + '\''; 
        }
        else if(!showViewData){
            if(accountName != '' && accountName != 'null' && accountName != null)
                query += ' AND Account__r.Name LIKE \'%' + accountName + '%\''; 
            if(accountType != '' && accountType != null)
                query += ' AND Account__r.Type = \'' + accountType + '\'';            
            if(vertical != '' && vertical != 'null' && vertical != null)
                query += ' AND Account__r.Industry = \'' + vertical + '\''; 
            if(territory != '' && territory != 'null' && territory != null)
                query += ' AND Account__r.Country__c = \'' + territory + '\''; 
            if(region != null && subRegion == null){
                query += ' AND Account__r.Region__c = \'' + region + '\'';
            }
            else if(region == 'North America' && subRegion != null){
                query += ' AND Account__r.Owner.Owner_Sub_Region__c = \'' + subRegion + '\'';  
            }
            else if(region != 'North America' && subRegion != null){
                query += ' AND Account__r.Region__c = \'' + region + '\''; 
                query += ' AND Account__r.Country__r.RU__c = \'' + subRegion + '\'';                 
            }
            
            if(selectedAE != '' && selectedAE != 'null' && selectedAE != null)
                query += ' AND Account__r.OwnerId = \'' + selectedAE + '\'';
            // NM: 05-Jul-2016: Updated to use new account segmentation field for filtering focus new logo and focus cross sell
            // Focus New Logo and Cross Sell filters are both selected, so either can match              
            if(key && must){
                query += ' AND (Account__r.Account_Segmentation__c = \'Focus Cross-sell\'';
                query += ' OR Account__r.Account_Segmentation__c = \'Focus New Logo\')';
            }
            else if(key) // Focus Cross Sell filter
                query += ' AND Account__r.Account_Segmentation__c = \'Focus Cross-sell\'';
            else if(must) // Focus New Logo filter
                query += ' AND Account__r.Account_Segmentation__c = \'Focus New Logo\'';
            System.debug('NKC debug selectedFilter [' + selectedFilter + ']'); 
              
            if(selectedFilter == 'My Accounts'){
                query += ' AND Account__r.OwnerId = \'' + UserInfo.getUserId() + '\'';
            }     
            else if(selectedFilter == 'My Team'){
                Id currentUserId = UserInfo.getUserId();
                Set<Id> setOfUserIds = new Set<Id>();
                setOfUserIds.add(currentUserId);            
                for(User eachUser : [SELECT id FROM User WHERE ManagerId =: currentUserId AND (Termination_Date__c = null OR Termination_Date__c > TODAY)]){
                    setOfUserIds.add(eachUser.id);
                }            
                Set<Id> setOfUserIds1 = new Set<Id>();
                for(User eachUser : [SELECT id FROM User WHERE ManagerId =: setOfUserIds AND ManagerId !=: currentUserId AND (Termination_Date__c = null OR Termination_Date__c > TODAY)]){
                    setOfUserIds.add(eachUser.id);
                    setOfUserIds1.add(eachUser.id);            
                }
                for(User eachUser : [SELECT id FROM User WHERE ManagerId =: setOfUserIds1 AND (Termination_Date__c = null OR Termination_Date__c > TODAY)]){
                    setOfUserIds.add(eachUser.id);           
                }
                           
                String q = '(';
                for(Id eachUserId : setOfUserIds){
                    q += '\'' + eachUserId + '\',';
                }
                q = q.removeEnd(',');
                q += ')';
                query += ' AND Account__r.OwnerId IN ' + q;
            }
            else if(selectedFilter != 'All Accounts'){
                query = addViewQuery(query, showViewData, setOfAccountIds);
            }
            if(smlFlag){
                query += ' ) OR (Account__r.SML_Flag__c =true';
            }
        }
            System.debug('NKC debug query [' + query + ']');

    // 26-Jul-2016: NM: Removed Inactive from the query string so that the inactive accounts can be included in the EngMap now (iTrack# 28470)            
            query += ' ) AND Account__r.Status__c NOT IN (\'Merged\') ORDER BY Account__r.Name, Solution_Category__r.Name LIMIT 13000';

        List<SML_Data__c> smlData = (List<SML_Data__c>)Database.query(query);
        if(smlData.size() > 14000)
            resultSizeExceeded = true;
        else
            resultSizeExceeded = false;
        Map<String, Map<String, SML_Data__c>> mapOfAccountVsSMLData = new Map<String, Map<String, SML_Data__c>>();
        solutionCategories = new Set<String>();
        solutionCategories1 = new Set<String>();
        smlRecords = new List<dataWrapper>();
        Map<String, List<SML_Data__c>> mapCategoryVsData = new Map<String, List<SML_Data__c>>(); 
        List<Solution_Category__c> solutionCategoriesRecords = [SELECT Name, Solution_Name__c  FROM Solution_Category__c WHERE Active__c = true ORDER BY Solution_Name__c, Name ASC];
        //Looping over each category record
        for(Solution_Category__c eachCategory : solutionCategoriesRecords){
           
            if(  hideBussOpt && eachCategory.Solution_Name__c == 'Business Optimization'
              || hideCustomerEngagement  && eachCategory.Solution_Name__c == 'Customer Engagement'
              || hideEmpEngagement && eachCategory.Solution_Name__c == 'Employee Engagement'
              || hideMultimediaCommunication && eachCategory.Solution_Name__c == 'Multimedia Communications'                
              || hideAnalytics && eachCategory.Solution_Name__c == 'Omnichannel Analytics'
                || hideOmni && eachCategory.Solution_Name__c == 'Omnichannel Journey Management'){                                
                continue;
            }
            String category = SMLHelper.updateCategoryToMultiline(eachCategory.Name);
            solutionCategories1.add(category);
            solutionCategories.add(eachCategory.Name);
        }
        //Looping over each reocrd
        for(SML_Data__c eachRecord : smlData){
         
            String categoryName = SMLHelper.updateCategoryToMultiline(eachRecord.Solution_Category__r.Name);
            System.debug('NKC debug categoryName ['+categoryName+']');
            if(mapOfAccountVsSMLData.get(eachRecord.Account__c) == null){               
                Map<String, SML_Data__c> newMap = new Map<String, SML_Data__c>();
                newMap.put(categoryName, eachRecord);
                mapOfAccountVsSMLData.put(eachRecord.Account__c, newMap);
            }
            else{
                Map<String, SML_Data__c> existingMap = mapOfAccountVsSMLData.get(eachRecord.Account__c); 
                existingMap.put(categoryName, eachRecord);
                mapOfAccountVsSMLData.put(eachRecord.Account__c, existingMap);
            }
            if(mapCategoryVsData.get(categoryName) == null){
                List<SML_Data__c> newList = new List<SML_Data__c>();
                newList.add(eachRecord);
                mapCategoryVsData.put(categoryName, newList);
            }
            else{
                mapCategoryVsData.get(categoryName).add(eachRecord);
            }
        }        
        Integer counter = 0;
        pageStart = pageNo * pageSize;
        
        //pageSize = 5;
        //pageNo = 1;
        pageStart = ((pageNo * pageSize) - pageSize) + 1;
        pageEnd = (pageStart + pageSize) - 1;
        pages = 1;
        System.debug('NKC debug mapOfAccountVsSMLData.keyset().size() ['+mapOfAccountVsSMLData.keyset().size()+']');
        System.debug('NKC debug pageSize ['+pageSize+']');
        if(mapOfAccountVsSMLData.keyset().size() > pageSize){
            pages = (mapOfAccountVsSMLData.keyset().size() / pageSize);
        }
        
        Integer reminder = 0;
        if(mapOfAccountVsSMLData.keyset().size() > pageSize)
            reminder = math.mod(mapOfAccountVsSMLData.keyset().size(), pageSize);
        System.debug('NKC debug reminder ['+reminder+']');
        System.debug('NKC debug pages ['+pages+']');
        if(reminder > 0){
            pages ++;
        }    
        
        List<SML_Account_Engagement_Score__c> accountEngagementScores = [SELECT Account__c, Score__c, Last_Change__c FROM SML_Account_Engagement_Score__c 
            WHERE Account__c IN : mapOfAccountVsSMLData.keyset() ORDER BY CreatedDate ASC];    
        Map<String, SML_Account_Engagement_Score__c> mapOfAccountVsScore = new Map<String, SML_Account_Engagement_Score__c>();
        for(SML_Account_Engagement_Score__c eachScore : accountEngagementScores){
            if(!mapOfAccountVsScore.keyset().contains(eachScore.Account__c))
                mapOfAccountVsScore.put(eachScore.Account__c, eachScore);        
        } 
        //Looping over each account record
        for(String eachAccountId : mapOfAccountVsSMLData.keyset()){
            SML_Account_Engagement_Score__c score = mapOfAccountVsScore.get(eachAccountId);
            counter++;
            if(counter < pageStart)
                continue;
            if(counter > pageEnd)
                break;
            Map<String, SML_Data__c> smlCategoryVsData = mapOfAccountVsSMLData.get(eachAccountId);            
            for(String eachCategory : solutionCategories){
              String categoryName = SMLHelper.updateCategoryToMultiline(eachCategory);                
                if(smlCategoryVsData.get(categoryName) == null){
                  System.debug('NKC debug eachCategory [' + eachCategory + ']');
                    SML_Data__c newSMLData = new SML_Data__c();
                    smlCategoryVsData.put(categoryName, newSMLData); 
                }
            }
            System.debug('NKC debug smlCategoryVsData [' + smlCategoryVsData + ']');
            //List<Integer> scores = SMLHelper.getAccountEngagementScore(smlCategoryVsData);
            List<SML_Data__c> smlRecords1 = smlCategoryVsData.values();
            dataWrapper newRecord = new dataWrapper();
            String accName = smlRecords1[0].Account__r.Name;
            String GenCareOffering = smlRecords1[0].Account__r.Genesys_Care_Offering__c;
            newRecord.accountName = (accName.length() > 14 ? accName.substring(0, 13) + ' ...' : accName);
            if (GenCareOffering == null || GenCareOffering == '')
            {
                newRecord.accountNameFull = accName;
                }
            else{
                newRecord.accountNameFull = accName + ', Genesys Care: ' + GenCareOffering;
            }
            newRecord.accountType = smlRecords1[0].Account__r.Type;
            newRecord.accountId = smlRecords1[0].Account__c;
            if(smlRecords1[0].Account__r.Account_Segmentation__c =='Focus Cross-sell')
                newRecord.orgClass = 'Cross<br/>Sell';
            else if(smlRecords1[0].Account__r.Account_Segmentation__c == 'Focus New Logo')
                newRecord.orgClass = 'New<br/>Logo';
            newRecord.logoName = smlRecords1[0].Account__r.Parent_Account__r.Name;
            newRecord.territory = smlRecords1[0].Account__r.Region__c;
            newRecord.country = smlRecords1[0].Account__r.Country__r.Name;
            // NM: 02-Dec: Updated to allow for full and truncated AE Names to resolve AE Name wrapping issue in EM grid
            String aeName = smlRecords1[0].Account__r.Owner.Name;
            newRecord.assignedAE = (aeName.length() > 15 ? aeName.substring(0, 14) + ' ...' : aeName);
            newRecord.assignedAEFull = aeName;
            newRecord.smlCategoryData = smlCategoryVsData ; 
            if(score != null){
                newRecord.engagementScore = Integer.valueOf(score.Score__c);
                newRecord.scoreType = score.Last_Change__c;
            }
            //newRecord.whiteSpaceScore = scores[1];                       
            smlRecords.add(newRecord);
            
        }
        if(!smlRecords.isEmpty()){
            showResult = true;            
        }
        mapCategoryVsScores = SMLHelper.getSolutionCategoryEngagementScore(mapCategoryVsData, mapOfAccountVsSMLData.keyset().size(), solutionCategories1, mapCategoryVsScoreColor);             
        pageLoadFilter = false;
        
    }
    
    
    public void openHidePopup(){
        showHidePopup = true;
    }
    
    public void closeHidePopup(){        
        showHidePopup = false;
        filter();   
    }
    
    public void populateMyTeam(){
        aeList = new List<SelectOption>();
        aeList.add(new SelectOption('', '--Select--'));
        Id currentUserId = UserInfo.getUserId();
        Set<Id> setOfUserIds = new Set<Id>();
        Map<String, String> mapOfNameVsId = new Map<String, String>();
        List<String> listOfUsers = new List<String>();
        setOfUserIds.add(currentUserId);            
        for(User eachUser : [SELECT id, Name FROM User WHERE ManagerId =: currentUserId AND IsActive = true]){
            setOfUserIds.add(eachUser.id);
            listOfUsers.add(eachUser.Name);
            mapOfNameVsId.put(eachUser.Name, eachUser.id);
        }            
        Set<Id> setOfUserIds1 = new Set<Id>();
        for(User eachUser : [SELECT id, Name FROM User WHERE ManagerId =: setOfUserIds AND ManagerId !=: currentUserId AND IsActive = true]){
            setOfUserIds.add(eachUser.id);
            setOfUserIds1.add(eachUser.id);            
            mapOfNameVsId.put(eachUser.Name, eachUser.id);
            listOfUsers.add(eachUser.Name);
        }
        for(User eachUser : [SELECT id, Name FROM User WHERE ManagerId =: setOfUserIds1 AND IsActive = true]){
            setOfUserIds.add(eachUser.id);           
            mapOfNameVsId.put(eachUser.Name, eachUser.id);            
            listOfUsers.add(eachUser.Name);
        }   
        listOfUsers.sort();
        for(String eachUser : listOfUsers){            
            aeList.add(new SelectOption(mapOfNameVsId.get(eachUser), eachUser));         
        }
        
    }
    
    public void showPopup(){         
        //showPopupFlag = true;
        smlDataRowOppLines = new List<OpportunityLineItem>();
        smlDataRow = SMLHelperWTS.populateSMLRecord(smlDataId);
        smlDataRowOppLines = SMLHelperWTS.populateOppLines(smlDataRow.Account__c, smlDataRow.Solution_Category__c);   
        System.debug(LoggingLevel.INFO, 'NKC debug smlDataRowOppLines ['+smlDataRowOppLines+']');     
        initialStatus = smlDataRow.Status__c;
        showCLIs = false;
        if(!smlDataRow.Contract_Line_Items__r.isEmpty()){
            showCLIs = true;    
        }
        showOLIs = false;
        if(!smlDataRow.Order_Line_Items__r.isEmpty()){
            showOLIs = TRUE;
        }
        showQPs = false;        
        if(!smlDataRow.BigMachines_Quote_Products__r.isEmpty()){
            showQPs = true;    
        } 
        showOpps = false;
        if(!smlDataRowOppLines.isEmpty() && !showQPs){
            showOpps = true;    
        }
        smlDataRow.Comments__c = null;
        SMLHelperWTS.insertSMLActivity(smlDataId, SMLHelper.SML_ACTIVITY_STATUS_CLICKED_CELL);
        feedback = new SML_Feedback_Comments__c(SML_Data__c = smlDataRow.id);
        feedbacks = SMLHelperWTS.populateFeedbacks(smlDataRow.id);
        GenieDocLinks = SMLHelperWTS.populateGenieDocLinks(smlDataRow.Solution_Category__r.Name);
        NBAReasonTextFull = SMLHelperWTS.populateNBAReasonText(smlDataRow.Solution_Category__r.Name);
        
    }
    public void saveFeedback(){
        insert feedback;
        feedback = new SML_Feedback_Comments__c(SML_Data__c = smlDataRow.id);
        feedbacks = SMLHelperWTS.populateFeedbacks(smlDataRow.id);
    }
    
    public void goToPage(){
        pageClick = true;
        if(pageNo > pages)
            pageNo = pages;
        filter();
    }
    
    public void next(){
        pageClick = true;
        if(pageNo < pages)
            pageNo ++;
        filter();
    }
    
    public void previous(){
        pageClick = true;
        if(pageNo > 1)
            pageNo --;
        filter();
    }
    
    public void savePopup(){
      if(initialStatus != smlDataRow.Status__c)
        smlDataRow.Status_Overridden_Manually__c = true;
        update smlDataRow;
        filter();
    }
    
    public void closePopup(){
        //showPopupFlag = false;
    }
    
    public void refresh(){
        filter();
    }
    
    public void hidePopup(){  
        savePopup();
        closePopup();      
    }
    /*
    public PageReference filter(){
        String params = '';
        params += '&accountName=' + accountName;
        params += '&orgName=' + orgName;
        params += '&territory=' + territory;
        System.debug('NKC debug positiveChange [' + positiveChange + ']');
        System.debug('NKC debug negativeChange [' + negativeChange + ']');
        params += '&positiveChange=' + positiveChange;
        params += '&negativeChange=' + negativeChange;  
        params += '&key=' + key;  
        params += '&must=' + must;      
        if(selectedFilter.startsWith('My') || selectedFilter.startsWith('All')){
            params += '&selectedFilter=' + selectedFilter;
        }
        else{
            params += '&viewId=' + selectedFilter;
        }
        params += '&smlFlag=' + smlFlag;                
        PageReference pg = new PageReference('/apex/sml1?' + params);
        pg.setRedirect(true);            
        return pg;
    }
    */
    public class dataWrapper{
        public String accountName {get;set;}
        public String accountNameFull {get;set;}
        public String accountId {get;set;}
        public String accountType {get;set;}
        public String orgClass {get;set;}
        public String logoName {get;set;}
        public String territory {get;set;}
        public String country {get;set;}
        public String assignedAE {get;set;}
        public String assignedAEFull {get;set;}  
        public Integer engagementScore {get;set;}  
        public Integer whiteSpaceScore {get;set;} 
        public String scoreType {get;set;}          
        public Boolean hideColumn {get;set;}
        public Map<String, SML_Data__c> smlCategoryData {get;set;}
    }
    
}