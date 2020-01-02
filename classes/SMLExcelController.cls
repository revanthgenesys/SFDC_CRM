//Naresh Kumar  01/21/2016
public with sharing class SMLExcelController {
    public List<dataWrapper> smlRecords {get;set;}
    public Set<String> solutionCategories {get;set;}
    public Set<String> solutionCategories1 {get;set;}
    public Map<String, String> mapCategoryHTMLVsCategory {get;set;}
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
    public Boolean showNaStatus {get;set;}
    @TestVisible
    private String initialStatus {get;set;}
    public SMLExcelController(){   
        init();
    }
    
    @TestVisible
    private void init(){
        pageLoadFilter = true;
        showResult = false;
        smlFlag = false;
        key = false;
        must = false;
        mapCategoryVsScoreColor = new Map<String, String>();
        mapCategoryHTMLVsCategory = new Map<String, String>();
        isNonManager = true;
        viewId = ApexPages.currentPage().getParameters().get('viewId');
        accId = ApexPages.currentPage().getParameters().get('accId');        
        availableStatus = new List<SelectOption>();
        //Populating Industry       
        verticalOptions = new List<SelectOption>();
        //NM: added loadFilters to initialisation as the values were not being passed over for the Excel output filtering (iTrack #24233)
        loadFilters();                 
        filter();        
    }
    
    @TestVisible
    private void loadFilters(){
        accountName = ApexPages.currentPage().getParameters().get('accName');
        accountType = ApexPages.currentPage().getParameters().get('accountType');
        
        if(ApexPages.currentPage().getParameters().get('vertical')!=null){
            vertical = ApexPages.currentPage().getParameters().get('vertical').replace('-','&');
            System.debug('>>>'+vertical);
        }
        
        territory = ApexPages.currentPage().getParameters().get('territory');
        region = ApexPages.currentPage().getParameters().get('region');
        subRegion = ApexPages.currentPage().getParameters().get('subRegion');
        selectedFilter = ApexPages.currentPage().getParameters().get('selectedFilter');
        System.debug('>>>>>>' +selectedFilter);
        if(ApexPages.currentPage().getParameters().get('must') != null)
            must = true;
        if(ApexPages.currentPage().getParameters().get('key') != null)
            key = true;
        selectedAE = ApexPages.currentPage().getParameters().get('selectedAE');             
    }
    
    public void filter(){ 
        //Getting All SML Data
        String query = 'SELECT Account__c, Solution_Category__r.Name, Solution_Category__r.Solution_Name__c, Account__r.Key__c, Account__r.Must__c,' 
            + ' Status__c, Status1__c, Account__r.Name, Account__r.Parent_Account__r.Name, Account__r.Region__c, Account__r.Country__r.Name, Notes__c,' 
            + ' Account__r.Owner.Name, Account__r.Owner.Sub_Region__c, Order_Info__c, Account__r.Type, Whitespace_Days__c, Whitespace_over_Threshold__c,'
            + ' Technical_Profile_Competitor__r.Technical_Profile__c, Competitors__c, Under_Maintenance__c, Cell_Color__c, Confidence_Level_Formula__c '
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
                query += ' AND Account__r.Country__r.SubRU__c = \'' + subRegion + '\'';                 
            }
            
            if(selectedAE != '' && selectedAE != 'null' && selectedAE != null)
                query += ' AND Account__r.OwnerId = \'' + selectedAE + '\'';              
            if(key && must){
                query += ' AND (Account__r.Key__c = true';
                query += ' OR Account__r.New_Logo__c = true)';
            }
            else if(key)
                query += ' AND Account__r.Key__c = true';
            else if(must)
                query += ' AND Account__r.New_Logo__c = true';
            System.debug('NKC debug selectedFilter [' + selectedFilter + ']'); 
            if(selectedFilter == 'Customer Crosssell'){
                //Getting current user's region
                User currentUser = [SELECT Employee_Region__c FROM User WHERE id =: UserInfo.getUserId()];
                String userRegion = 'North America';
                if(currentUser.Employee_Region__c != null)
                    userRegion = currentUser.Employee_Region__c;
                //Cross sell
                query += ' AND Account__r.Key__c = true';
                //Customer
                query += ' AND Account__r.Type = \'Customer\'' ;
                //Region
                query += ' AND Account__r.Region__c = \'' + userRegion + '\'';
            }  
            else if(selectedFilter == 'My Accounts'){
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
                
                //NM: 04-May-2016: added to allow filtering for a specific AE in the My Team general filter for the Excel output  (iTrack #24233)
                if(selectedAE != '' && selectedAE != 'null' && selectedAE != null)
                query += ' AND Account__r.OwnerId = \'' + selectedAE + '\'';
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
            query += ' ) AND Account__r.Status__c NOT IN (\'Merged\') ORDER BY Account__r.Name, Solution_Category__r.Name LIMIT 14000';

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
        List<SML_Account_Engagement_Score__c> accountEngagementScores = [SELECT Account__c, Score__c, Last_Change__c FROM SML_Account_Engagement_Score__c WHERE Account__c IN : mapOfAccountVsSMLData.keyset()];    
        Map<String, SML_Account_Engagement_Score__c> mapOfAccountVsScore = new Map<String, SML_Account_Engagement_Score__c>();
        for(SML_Account_Engagement_Score__c eachScore : accountEngagementScores){
            mapOfAccountVsScore.put(eachScore.Account__c, eachScore);        
        } 
        //Looping over each account record
        for(String eachAccountId : mapOfAccountVsSMLData.keyset()){
            SML_Account_Engagement_Score__c score = mapOfAccountVsScore.get(eachAccountId);
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
            newRecord.accountName = (accName.length() > 14 ? accName.substring(0, 13) + ' ...' : accName); 
            newRecord.accountNameFull = accName;
            newRecord.accountType = smlRecords1[0].Account__r.Type;
            newRecord.accountId = smlRecords1[0].Account__c;
            if(smlRecords1[0].Account__r.Key__c)
                newRecord.orgClass = 'Cross Sell';
            else if(smlRecords1[0].Account__r.Must__c)
                newRecord.orgClass = 'New Logo';
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
        //Map<String, String> mapCategoryVsScoreColor = new Map<String, String>();
        //Map<String, Integer> mapCategoryVsScores;
        //Map<String, Integer> mapCategoryVsScores1 = new Map<String, Integer>();
        mapCategoryVsScores = SMLHelper.getSolutionCategoryEngagementScore(mapCategoryVsData, mapOfAccountVsSMLData.keyset().size(), solutionCategories1, mapCategoryVsScoreColor);             
        pageLoadFilter = false;
        /*
        for(String key : mapCategoryVsScoreColor.keyset()){
            key = key.replace('<br/>',' ');
            mapCategoryVsScoreColor1.put(key, mapCategoryVsScoreColor.get(key));    
        }
        
        for(String key : mapCategoryVsScores.keyset()){
            key = key.replace('<br/>',' ');
            mapCategoryVsScores1.put(key, mapCategoryVsScores.get(key));    
        }
        */
        for(String eachCategory : solutionCategories1){
            mapCategoryHTMLVsCategory.put(eachCategory, SMLHelper.updateCategoryToSingleline(eachCategory));
        }
        
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