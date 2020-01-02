//Naresh Kumar  10/11/2019
public with sharing class PESSRevenueForecastController2019 {   
    public List<wrapperRecords> records {get;set;}
    public String selectedQuarter {get;set;}
    public String selectedWeek{get;set;}
    public String selectedCs{get;set;}
    public Integer pageSize {get;set;}
    public Integer pageNo {get;set;}
    public Integer pageStart {get;set;}
    public Integer pageEnd {get;set;}
    public Integer pages {get;set;}
    public List<SelectOption> csmList {get;set;}
    public List<SelectOption> weeks {get;set;}
    public Boolean isPageLoad {get;set;}
    public Boolean showCommentValidation {get;set;}
    public String selectedLOB {get;set;}
    public String sortBy {get;set;}
    public String selectedTab {get;set;}
    public Boolean hideQ1 {get;set;}
    public Boolean hideQ2 {get;set;}
    public Boolean hideQ3 {get;set;}
    public Boolean hideQ4 {get;set;}
    public Boolean lockJan {get;set;}
    public Boolean lockFeb {get;set;}
    public Boolean lockMar {get;set;}
    public Boolean lockQ12019Risk {get;set;}
    public Boolean lockQ12019Upside {get;set;}
    public Boolean lockApr {get;set;}
    public Boolean lockMay {get;set;}
    public Boolean lockJun {get;set;}
    public Boolean lockQ22019Risk {get;set;}
    public Boolean lockQ22019Upside {get;set;}
    public Boolean lockJul{get;set;}
    public Boolean lockAug {get;set;}
    public Boolean lockSep {get;set;}
    public Boolean lockQ32019Risk {get;set;}
    public Boolean lockQ32019Upside {get;set;}
    public Boolean lockOct {get;set;}
    public Boolean lockNov {get;set;}
    public Boolean lockDec {get;set;}
    public Boolean lockQ42019Risk {get;set;}
    public Boolean lockQ42019Upside {get;set;}
    public Boolean hideProfessionalServices {get;set;}
    public PESSRevenueForecastController2019(){
        pageSize = 50;
        pageNo = 1;
        isPageLoad = true;
        showCommentValidation = false;
        selectedLOB = 'All';
        selectedTab = 'tabRevenueForecast2019';
        sortBy = 'Company Name';
        hideProfessionalServices = false;
        /*
        Integer currentMonth = Date.today().month();
        Integer currentQ = ((currentMonth-1)/3) + 1;    
        selectedQuarter = currentQ + '-' + Date.today().year();
        */
        selectedQuarter = selectCurrentQuarter();
        System.debug(LoggingLevel.INFO, 'NKC debug selectedQuarter ['+selectedQuarter+']');
        if(ApexPages.currentPage().getParameters().get('q') != null && ApexPages.currentPage().getParameters().get('q') != '')    
            selectedQuarter = ApexPages.currentPage().getParameters().get('q');    
        if(ApexPages.currentPage().getParameters().get('lob') != null && ApexPages.currentPage().getParameters().get('lob') != '')    
            selectedLOB = ApexPages.currentPage().getParameters().get('lob');
        if(ApexPages.currentPage().getParameters().get('sortBy') != null && ApexPages.currentPage().getParameters().get('sortBy') != '')    
            sortBy = ApexPages.currentPage().getParameters().get('sortBy');
        if(ApexPages.currentPage().getParameters().get('hideQ1') != null && ApexPages.currentPage().getParameters().get('hideQ1') != '')    
            hideQ1 = Boolean.valueOf(ApexPages.currentPage().getParameters().get('hideQ1'));
        if(ApexPages.currentPage().getParameters().get('hideQ2') != null && ApexPages.currentPage().getParameters().get('hideQ2') != '')    
            hideQ2 = Boolean.valueOf(ApexPages.currentPage().getParameters().get('hideQ2'));
        if(ApexPages.currentPage().getParameters().get('hideQ3') != null && ApexPages.currentPage().getParameters().get('hideQ3') != '')    
            hideQ3 = Boolean.valueOf(ApexPages.currentPage().getParameters().get('hideQ3'));
        if(ApexPages.currentPage().getParameters().get('hideQ4') != null && ApexPages.currentPage().getParameters().get('hideQ4') != '')    
            hideQ4 = Boolean.valueOf(ApexPages.currentPage().getParameters().get('hideQ4'));        
        if(ApexPages.currentPage().getParameters().get('csm') != null && ApexPages.currentPage().getParameters().get('csm') != '')    
            selectedCs = ApexPages.currentPage().getParameters().get('csm');            
        populateWeeks();
        if(ApexPages.currentPage().getParameters().get('week') != null && ApexPages.currentPage().getParameters().get('week') != '')    
            selectedWeek = ApexPages.currentPage().getParameters().get('week');
        init();
        populateSelectedQuarters();
        setMonthsLocking();
    }
    
    private void setMonthsLocking(){
        String lockMonths = Label.PESS_Revenue_Forecast_Locked_Month_2019;
        lockJan = false;
        lockFeb = false;
        lockMar = false;
        lockApr = false;
        lockMay = false;
        lockJun = false;
        lockJul = false;
        lockAug = false;
        lockSep = false;
        lockOct = false;
        lockNov = false;
        lockDec = false;
        lockQ12019Risk = false;
        lockQ12019Upside = false;
        lockQ22019Risk = false;
        lockQ22019Upside = false;
        lockQ32019Risk = false;
        lockQ32019Upside = false;
        lockQ42019Risk = false;
        lockQ42019Upside = false;
        
        if(!Label.PESS_Revenue_Forecast_Admins.contains(UserInfo.getUserId().left(15))){
            if(lockMonths.containsIgnoreCase('Jan'))
                lockJan = true;
            if(lockMonths.containsIgnoreCase('Feb'))
                lockFeb = true;
            if(lockMonths.containsIgnoreCase('Mar'))
                lockMar = true;
            if(lockMonths.containsIgnoreCase('Q12019Risk'))
                lockQ12019Risk = true;
            if(lockMonths.containsIgnoreCase('Q12019Upside'))
                lockQ12019Upside = true;          
            if(lockMonths.containsIgnoreCase('Mar'))
                lockMar = true;         
            if(lockMonths.containsIgnoreCase('Apr'))
                lockApr = true;
            if(lockMonths.containsIgnoreCase('May'))
                lockMay = true;
            if(lockMonths.containsIgnoreCase('Q22019Risk'))
                lockQ22019Risk = true;
            if(lockMonths.containsIgnoreCase('Q22019Upside'))
                lockQ22019Upside = true;
            if(lockMonths.containsIgnoreCase('Jun'))
                lockJun = true;
            if(lockMonths.containsIgnoreCase('Jul'))
                lockJul = true;
            if(lockMonths.containsIgnoreCase('Aug'))
                lockAug = true;
            if(lockMonths.containsIgnoreCase('Sep'))
                lockSep = true;
            if(lockMonths.containsIgnoreCase('Q32019Risk'))
                lockQ32019Risk = true;
            if(lockMonths.containsIgnoreCase('Q32019Upside'))
                lockQ32019Upside = true;
            if(lockMonths.containsIgnoreCase('Oct'))
                lockOct = true;
            if(lockMonths.containsIgnoreCase('Nov'))
                lockNov = true;
            if(lockMonths.containsIgnoreCase('Dec'))
                lockDec = true;
            if(lockMonths.containsIgnoreCase('Q42019Risk'))
                lockQ42019Risk = true;
            if(lockMonths.containsIgnoreCase('Q42019Upside'))
                lockQ42019Upside = true;
        }
    }
    
    private void populateSelectedQuarters(){
        Revenue_Forecast_User_Quarters__c quarters = Revenue_Forecast_User_Quarters__c.getInstance(UserInfo.getUserId());
        hideQ1 = quarters.Q1__c;
        hideQ2 = quarters.Q2__c;
        hideQ3 = quarters.Q3__c;
        hideQ4 = quarters.Q4__c;
    }
    private void saveSelectedQuarters(){
        Revenue_Forecast_User_Quarters__c quarters = Revenue_Forecast_User_Quarters__c.getInstance(UserInfo.getUserId());
        if(quarters == null){
            quarters = new Revenue_Forecast_User_Quarters__c(SetupOwnerId = UserInfo.getUserId());
        }
        System.debug(LoggingLevel.INFO, 'NKC debug quarters ['+quarters+']');
        quarters.Q1__c = hideQ1;
        quarters.Q2__c = hideQ2;
        quarters.Q3__c = hideQ3;
        quarters.Q4__c = hideQ4;        
        upsert quarters;
        System.debug(LoggingLevel.INFO, 'NKC debug quarters ['+quarters+']');       
    }
    
    public void init(){
        
        Map<Id, Account> accountIdVsAccount = new Map<Id, Account>();
        System.debug('NKC debug selectedCs ['+selectedCs+']');
        String accountQuery = 'SELECT id, Name, CSM_Account_Owner__c, CSM_Account_Owner__r.Name, OwnerId, Total_CMRR__c, Renewal_Date__c ' 
                + 'FROM Account WHERE PE_SS_Flag__c = true';
        
        if(selectedCs != null && selectedCs != '')
            accountQuery += ' AND CSM_Account_Owner__c =: selectedCs' ;
        if(selectedWeek != null)
            accountQuery += ' AND id IN (SELECT Account__c FROM Account_Revenue_Forecast__c WHERE Cloud_Forecast_Quarter__c =: selectedWeek)';
        
        System.debug(LoggingLevel.INFO, 'NKC debug accountQuery ['+accountQuery+']');
        List<Account> accounts = (List<Account>)Database.query(accountQuery);
        //Paging
        Integer counter = 0;
        pageStart = ((pageNo * pageSize) - pageSize) + 1;
        pageEnd = (pageStart + pageSize) - 1;
        System.debug('NKC debug accRevenueRecords.size() ['+accounts.size()+']');
        System.debug('NKC debug pageSize ['+pageSize+']');
        pages = 1;
        if(selectedWeek != null && accounts.size() > pageSize){
            pages = (accounts.size() / pageSize);
            Integer reminder = 0;
            if(accounts.size() > pageSize)
                reminder = math.mod(accounts.size(), pageSize);
            System.debug('NKC debug reminder ['+reminder+']');
            System.debug('NKC debug pages ['+pages+']');
            if(reminder > 0){
                pages ++;
            }
        }
        SelectOption newItem = new SelectOption('', '-- All CSM --');
        Set<Id> setOfOwnersIds = new Set<Id>();        
        if(isPageLoad){
            csmList = new List<SelectOption>();         
            csmList.add(newItem);
        }        
        for(Account eachAccount : accounts){            
            accountIdVsAccount.put(eachAccount.id, eachAccount);            
            if(isPageLoad && eachAccount.CSM_Account_Owner__c != null && !setOfOwnersIds.contains(eachAccount.CSM_Account_Owner__c)){
                newItem = new SelectOption(eachAccount.CSM_Account_Owner__c, eachAccount.CSM_Account_Owner__r.Name);
                csmList.add(newItem);
                setOfOwnersIds.add(eachAccount.CSM_Account_Owner__c);       
            }
        }
        List<Account_Revenue_Forecast__c> accRevenueRecords = new List<Account_Revenue_Forecast__c>();
        List<Id> accountIds = new List<Id>();
        accountIds.addAll(accountIdVsAccount.keyset());
        String revenueForecastQuery = 'SELECT Account__c, LOB__c, X2019_Upside__c, X2019_Forecast__c, Apr_2019__c,'
                + 'Aug_2019__c, Dec_2019__c, Feb_2019__c, Jan_2019__c, July_2019__c, June_2019__c, Land__c, Mar_2019__c, May_2019__c, Nov_2019__c,'
                + 'Oct_2019__c, Q1_2019_Upside__c, Q1_2019_Forecast__c, Q1_2019_Risk__c, Q2_2019_Upside__c, Q2_2019_Forecast__c, Q2_2019_Risk__c,' 
                + 'Q3_2019_Upside__c, Q3_2019_Forecast__c, Q3_2019_Risk__c, Q4_2019_Upside__c, Q4_2019_Forecast__c, Q4_2019_Risk__c,' 
                + 'Sept_2019__c, X2019_Risk__c, Comment_Validation__c, Account__r.Revenue_Forecast_Target_Multiplier__c, LOB1__c,'
                + 'X2019_Target__c, Q1_2019_Target__c, Q2_2019_Target__c, Q3_2019_Target__c, Q4_2019_Target__c FROM Account_Revenue_Forecast__c'
                + ' WHERE PE_SS_Flag__c = true AND Account__c IN : accountIds';
        if(selectedWeek != null && selectedWeek != ''){
            revenueForecastQuery += ' AND Cloud_Forecast_Quarter__c =: selectedWeek';
            if(selectedLOB != null && selectedLOB != 'All'){
                revenueForecastQuery += ' AND LOB__c = \'' + selectedLOB + '\'' ;
            }
            String currentUserId = UserInfo.getUserId().substring(0, 14);
            if(!Label.PESS_Revenue_Forecast_Admins.contains(currentUserId)){
                accountQuery += ' AND Account__r.CSM_Account_Owner__c = \'' + UserInfo.getUserId() + '\'' ;    
            }
            System.debug(LoggingLevel.INFO, 'NKC debug accountIds ['+accountIds+']');
            System.debug(LoggingLevel.INFO, 'NKC debug selectedWeek ['+selectedWeek+']');
            System.debug(LoggingLevel.INFO, 'NKC debug sortBy ['+sortBy+']');
            if(sortBy == 'Company Name')            
                revenueForecastQuery += ' ORDER BY Account__r.Name ASC';   
            if(sortBy == 'CSM')
                revenueForecastQuery += ' ORDER BY Account__r.CSM_Account_Owner__r.Name ASC';
            else if(sortBy == '2019 Low - high to low')
                revenueForecastQuery += ' ORDER BY X2019_Low__c DESC';
            else if(sortBy == '2019 Forecast - high to low')
                revenueForecastQuery += ' ORDER BY X2019_Forecast__c DESC';
            else if(sortBy == '2019 Upside - high to low')
                revenueForecastQuery += ' ORDER BY X2019_Upside__c DESC';            
            else if(sortBy == '2019 Target - high to low')
                revenueForecastQuery += ' ORDER BY X2019_Target__c DESC';
                
            System.debug(LoggingLevel.INFO, 'NKC debug revenueForecastQuery ['+revenueForecastQuery+']');
            accRevenueRecords = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);
        }
        /*
        else{
            accRevenueRecords = [SELECT Account__c, LOB__c, X2019_Upside__c, X2019_Forecast__c, X2019_Target__c, Apr_2019__c,
                Aug_2019__c, Dec_2019__c, Feb_2019__c, Jan_2019__c, July_2019__c, June_2019__c, Land__c, Mar_2019__c, May_2019__c, Nov_2019__c,
                Oct_2019__c, Q1_2019_Upside__c, Q1_2019_Forecast__c, Q1_2019_Risk__c, Q1_2019_Target1__c, Q2_2019_Upside__c, Q2_2019_Forecast__c, Q2_2019_Risk__c, 
                Q2_2019_Target1__c, Q3_2019_Upside__c, Q3_2019_Forecast__c, Q3_2019_Risk__c, Q3_2019_Target1__c, Q4_2019_Upside__c, Q4_2019_Forecast__c, Q4_2019_Risk__c, 
                Q4_2019_Target1__c, Sept_2019__c, X2019_Risk__c, Comment_Validation__c  FROM Account_Revenue_Forecast__c WHERE PE_SS_Flag__c = true AND Account__c IN : accountIdVsAccount.keyset()];
        }
        */
        
        Map<String, Account_Revenue_Forecast__c> mapOfAccountLOBVsRecord = new Map<String, Account_Revenue_Forecast__c>();
        Set<Id> accountIdsSorted = new Set<Id>();
        //Creating map for each row
        for(Account_Revenue_Forecast__c eachRecord : accRevenueRecords){            
            mapOfAccountLOBVsRecord.put(eachRecord.Account__c + eachRecord.LOB__c, eachRecord);
            accountIdsSorted.add(eachRecord.Account__c);    
        }   
        //Initializing the list     
        records = new List<wrapperRecords>();
        Schema.DescribeFieldResult fieldResult = Account_Revenue_Forecast__c.LOB__c.getDescribe();
        List<Schema.PicklistEntry> listOfLOBValues = fieldResult.getPicklistValues();
        //Total Record
        wrapperRecords totalRecord = new wrapperRecords();      
        Account_Revenue_Forecast__c totalARFRecord = new Account_Revenue_Forecast__c(Apr_2019__c = 0,
            Aug_2019__c = 0, Dec_2019__c = 0, Feb_2019__c = 0, Jan_2019__c = 0, July_2019__c = 0, June_2019__c = 0, Land__c = 0, Mar_2019__c = 0, May_2019__c = 0, Nov_2019__c = 0,
            Oct_2019__c = 0, Q1_2019_Upside__c = 0, Q1_2019_Risk__c = 0, Q2_2019_Upside__c = 0, Q2_2019_Risk__c = 0, 
            Q3_2019_Upside__c = 0, Q3_2019_Risk__c = 0, Q4_2019_Upside__c = 0, Q4_2019_Risk__c = 0, 
            Sept_2019__c = 0);
        Integer recordCount = 0;
        String backColorRight = '#D7DBDD';
        String backColorLeft = '#cce7ff';
        String backColorTarget = '#D7BDE2';
        
        
        Integer accountCounter = 0;
        showCommentValidation = false;
        //Looping over each account and populating wrapper records
        for(Id eachAccountId : accountIdsSorted){
            Account eachAccount = accountIdVsAccount.get(eachAccountId);
            counter++;
            if(counter < pageStart)
                continue;
            if(counter > pageEnd)
                break;
            //Looping over each LOB value
            for(Schema.PicklistEntry eachLOB : listOfLOBValues){
                if(selectedLOB != null && selectedLOB != 'All' && eachLOB.getValue() != selectedLOB 
                   || (hideProfessionalServices && eachLOB.getValue() == 'C - Professional Services'))
                    continue;
                wrapperRecords newRecord = new wrapperRecords();
                newRecord.backColorLeft = backColorLeft;
                newRecord.backColorRight = backColorRight;     
                newRecord.backColorTarget = backColorTarget;         
                newRecord.account = eachAccount;
                newRecord.accountCounter = accountCounter;
                String key = eachAccount.id + eachLOB.getValue();
                Account_Revenue_Forecast__c ARFRecord = mapOfAccountLOBVsRecord.get(key);
                
                if(ARFRecord == null){
                    ARFRecord = new Account_Revenue_Forecast__c(LOB__c = eachLOB.getValue(), PE_SS_Flag__c = true);
                    ARFRecord.Account__c = eachAccount.id;
                    newRecord.accountRevForecast = ARFRecord;                   
                }
                else{
                    newRecord.accountRevForecast = ARFRecord;
                }
                /*
                if(ARFRecord.Comment_Validation__c){
                    newRecord.backColorRight = '#E5E7E9';
                    showCommentValidation = true;
                }
                */
                populateValidationErrors(newRecord);
                records.add(newRecord);
                newRecord.counter = recordCount;
                recordCount ++ ;                
                //Total
                totalARFRecord.Jan_2019__c += ARFRecord.Jan_2019__c == null ? 0 : ARFRecord.Jan_2019__c;
                totalARFRecord.Feb_2019__c += ARFRecord.Feb_2019__c == null ? 0 : ARFRecord.Feb_2019__c;
                totalARFRecord.Mar_2019__c += ARFRecord.Mar_2019__c == null ? 0 : ARFRecord.Mar_2019__c;
                totalARFRecord.Apr_2019__c += ARFRecord.Apr_2019__c == null ? 0 : ARFRecord.Apr_2019__c;
                totalARFRecord.May_2019__c += ARFRecord.May_2019__c == null ? 0 : ARFRecord.May_2019__c;
                totalARFRecord.June_2019__c += ARFRecord.June_2019__c == null ? 0 : ARFRecord.June_2019__c;
                totalARFRecord.July_2019__c += ARFRecord.July_2019__c == null ? 0 : ARFRecord.July_2019__c;
                totalARFRecord.Aug_2019__c += ARFRecord.Aug_2019__c == null ? 0 : ARFRecord.Aug_2019__c;
                totalARFRecord.Sept_2019__c += ARFRecord.Sept_2019__c == null ? 0 : ARFRecord.Sept_2019__c;
                totalARFRecord.Oct_2019__c += ARFRecord.Oct_2019__c == null ? 0 : ARFRecord.Oct_2019__c;
                totalARFRecord.Nov_2019__c += ARFRecord.Nov_2019__c == null ? 0 : ARFRecord.Nov_2019__c;
                totalARFRecord.Dec_2019__c += ARFRecord.Dec_2019__c == null ? 0 : ARFRecord.Dec_2019__c;
                totalARFRecord.Q1_2019_Upside__c += ARFRecord.Q1_2019_Upside__c == null ? 0 : ARFRecord.Q1_2019_Upside__c;
                totalARFRecord.Q1_2019_Risk__c += ARFRecord.Q1_2019_Risk__c == null ? 0 : ARFRecord.Q1_2019_Risk__c;
                //totalARFRecord.Q1_2019_Target1__c += ARFRecord.Q1_2019_Target1__c == null ? 0 : ARFRecord.Q1_2019_Target1__c;
                totalARFRecord.Q2_2019_Upside__c += ARFRecord.Q2_2019_Upside__c == null ? 0 : ARFRecord.Q2_2019_Upside__c;
                totalARFRecord.Q2_2019_Risk__c += ARFRecord.Q2_2019_Risk__c == null ? 0 : ARFRecord.Q2_2019_Risk__c;
                //totalARFRecord.Q2_2019_Target1__c += ARFRecord.Q2_2019_Target1__c == null ? 0 : ARFRecord.Q2_2019_Target1__c;
                totalARFRecord.Q3_2019_Upside__c += ARFRecord.Q3_2019_Upside__c == null ? 0 : ARFRecord.Q3_2019_Upside__c;
                totalARFRecord.Q3_2019_Risk__c += ARFRecord.Q3_2019_Risk__c == null ? 0 : ARFRecord.Q3_2019_Risk__c;
                //totalARFRecord.Q3_2019_Target1__c += ARFRecord.Q3_2019_Target1__c == null ? 0 : ARFRecord.Q3_2019_Target1__c;
                totalARFRecord.Q4_2019_Upside__c += ARFRecord.Q4_2019_Upside__c == null ? 0 : ARFRecord.Q4_2019_Upside__c;
                totalARFRecord.Q4_2019_Risk__c += ARFRecord.Q4_2019_Risk__c == null ? 0 : ARFRecord.Q4_2019_Risk__c;
                //totalARFRecord.Q4_2019_Target1__c += ARFRecord.Q4_2019_Target1__c == null ? 0 : ARFRecord.Q4_2019_Target1__c;
                totalRecord.totalQ12019Forecast += ARFRecord.Q1_2019_Forecast__c == null ? 0 : ARFRecord.Q1_2019_Forecast__c;
                totalRecord.totalQ22019Forecast += ARFRecord.Q2_2019_Forecast__c == null ? 0 : ARFRecord.Q2_2019_Forecast__c;
                totalRecord.totalQ32019Forecast += ARFRecord.Q3_2019_Forecast__c == null ? 0 : ARFRecord.Q3_2019_Forecast__c;
                totalRecord.totalQ42019Forecast += ARFRecord.Q4_2019_Forecast__c == null ? 0 : ARFRecord.Q4_2019_Forecast__c;
                totalRecord.total2019Risk += ARFRecord.X2019_Risk__c == null ? 0 : ARFRecord.X2019_Risk__c;
                totalRecord.total2019Forecast += ARFRecord.X2019_Forecast__c == null ? 0 : ARFRecord.X2019_Forecast__c;
                totalRecord.total2019Upside += ARFRecord.X2019_Upside__c == null ? 0 : ARFRecord.X2019_Upside__c;
                //totalRecord.total2019Target += ARFRecord.X2019_Target__c == null ? 0 : ARFRecord.X2019_Target__c;               
            }   
            accountCounter ++;
            if(backColorRight == '#D7DBDD'){
                backColorRight = '#E5E7E9';
               backColorLeft = '#F0F8FF';
               backColorTarget= '#D7BDE2';
                
            }
            else{
               
               backColorRight = '#D7DBDD';
               backColorLeft = '#cce7ff';
               backColorTarget= '#EBDEF0  ';
                
            }
            if(eachAccount.Name != null && eachAccount.Name.length() > 19){
                eachAccount.Name = eachAccount.Name.substring(0, 18) + '...';
            }
        }
        totalRecord.isTotal = true;
        Account tempAccount = new Account();
        tempAccount.Name = 'Total';
        totalRecord.account = tempAccount;      
        totalRecord.accountRevForecast = totalARFRecord;
        totalRecord.backColorLeft = '#99cfff';
        totalRecord.backColorRight = '#E5E7E9  ';
        records.add(totalRecord);   
    }
    
    private void populateValidationErrors(wrapperRecords eachRecord){
         String errorMessage = '';
         if(eachRecord.accountRevForecast.Q1_2019_Risk__c > eachRecord.accountRevForecast.Q1_2019_Forecast__c || eachRecord.accountRevForecast.Q1_2019_Risk__c > eachRecord.accountRevForecast.Q1_2019_Upside__c) {
            errorMessage += 'Risk can not be higher than Forecast or Upside (Q1). ';
         }
         if(eachRecord.accountRevForecast.Q2_2019_Risk__c > eachRecord.accountRevForecast.Q2_2019_Forecast__c || eachRecord.accountRevForecast.Q2_2019_Risk__c > eachRecord.accountRevForecast.Q2_2019_Upside__c) {
            errorMessage += 'Risk can not be higher than Forecast or Upside (Q2). ';
         }
         if(eachRecord.accountRevForecast.Q3_2019_Risk__c > eachRecord.accountRevForecast.Q3_2019_Forecast__c || eachRecord.accountRevForecast.Q3_2019_Risk__c > eachRecord.accountRevForecast.Q3_2019_Upside__c) {
            errorMessage += 'Risk can not be higher than Forecast or Upside (Q3). ';
         }
         if(eachRecord.accountRevForecast.Q4_2019_Risk__c > eachRecord.accountRevForecast.Q4_2019_Forecast__c || eachRecord.accountRevForecast.Q4_2019_Risk__c > eachRecord.accountRevForecast.Q4_2019_Upside__c) {
            errorMessage += 'Risk can not be higher than Forecast or Upside. (Q4). ';
         }
         if(eachRecord.accountRevForecast.Q1_2019_Forecast__c > eachRecord.accountRevForecast.Q1_2019_Upside__c) {
            errorMessage += 'Forecast can not be higher than Upside (Q1). ';
         }
         if(eachRecord.accountRevForecast.Q2_2019_Forecast__c > eachRecord.accountRevForecast.Q2_2019_Upside__c) {
            errorMessage += 'Forecast can not be higher than Upside (Q2). ';
         }
         if(eachRecord.accountRevForecast.Q3_2019_Forecast__c > eachRecord.accountRevForecast.Q3_2019_Upside__c) {
            errorMessage += 'Forecast can not be higher than Upside (Q3). ';
         }
         if(eachRecord.accountRevForecast.Q4_2019_Forecast__c > eachRecord.accountRevForecast.Q4_2019_Upside__c) {
            errorMessage += 'Forecast can not be higher than Upside (Q4). ';
         }
         if(errorMessage != ''){
            eachRecord.isError = true;
            eachRecord.errorDescription = errorMessage;
         }
    }
    
    public void populateWeeks(){
        System.debug(LoggingLevel.INFO,'NKC debug selectedWeek [' + selectedWeek + ']');
        weeks = new List<SelectOption>();
        weeks = QuoteRevenueMonthForecastContHelper.getWeeksForQuarter(selectedQuarter);
        selectedWeek = QuoteRevenueMonthForecastContHelper.getCurrentWeek(selectedQuarter);
        System.debug(LoggingLevel.INFO,'NKC debug selectedWeek [' + selectedWeek + ']');
    }
    
    public void save(){     
        List<Account_Revenue_Forecast__c> recordsToBeUpserted = new List<Account_Revenue_Forecast__c>();
        Boolean isValidationError = false;
        System.debug('NKC debug records ['+records+']');
        for(wrapperRecords eachRecord : records){
            System.debug('NKC debug eachRecord.isSelected ['+eachRecord.isSelected+']');
            
            if(eachRecord.isSelected){
                /*
                Decimal targetMultiplier = (eachRecord.Account__r.Revenue_Forecast_Target_Multiplier__c == null ? 1 : eachRecord.Account__r.Revenue_Forecast_Target_Multiplier__c);                
                if(eachRecord.Q1_2019_Forecast__c != null)
                    eachRecord.Q1_2019_Target1__c = (eachRecord.Q1_2019_Forecast__c * targetMultiplier).setScale(2);
                if(eachRecord.Q2_2019_Forecast__c != null)
                    eachRecord.Q2_2019_Target1__c = (eachRecord.Q2_2019_Forecast__c * targetMultiplier).setScale(2);
                if(eachRecord.Q3_2019_Forecast__c != null)
                    eachRecord.Q3_2019_Target1__c = (eachRecord.Q3_2019_Forecast__c * targetMultiplier).setScale(2);
                if(eachRecord.Q4_2019_Forecast__c != null)
                    eachRecord.
                    Q4_2019_Target1__c = (ARFRecord.Q4_2019_Forecast__c * targetMultiplier).setScale(2);
                */   
                populateValidationErrors(eachRecord);
                if(eachRecord.isError)
                    isValidationError = true;
                eachRecord.accountRevForecast.Cloud_Forecast_Quarter__c = selectedWeek;
                if(eachRecord.account.CSM_Account_Owner__c == null)
                    eachRecord.accountRevForecast.ownerId = Label.Default_CSM_Owner;
                else
                    eachRecord.accountRevForecast.ownerId = eachRecord.account.CSM_Account_Owner__c;
                
                recordsToBeUpserted.add(eachRecord.accountRevForecast);
            }
        }
        
        if(isValidationError){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There are some validation error(s). Please hover on red exclamation mark to see error details.'));   
            
        }        
        System.debug('NKC debug recordsToBeUpserted ['+recordsToBeUpserted+']');
        if(!recordsToBeUpserted.isEmpty())
            upsert recordsToBeUpserted;     
        init();     
        saveSelectedQuarters();
    }
    
    
    
    public void goToPage(){     
        System.debug(LoggingLevel.INFO,'NKC debug pageNo ['+pageNo+']');   
        if(pageNo > pages)
            pageNo = pages;
        init();
    }
    
    public void next(){
        if(pageNo < pages)
            pageNo ++;
        init();
    }
    
    public void previous(){
        if(pageNo > 1)
            pageNo --;
        init();
    }
    
    public void populateData(){
        pageNo = 1;
        isPageLoad = false;
        init();
        saveSelectedQuarters();
    }
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
        return sQuarter;
    }
    
    public class wrapperRecords{
        public Boolean isSelected {get;set;}
        public Account account {get;set;}
        public Account_Revenue_Forecast__c accountRevForecast {get;set;}
        public Boolean isTotal {get;set;}
        public Integer counter {get;set;}
        public Integer accountCounter {get;set;}
        public Double totalQ12019Forecast {get;set;}
        public Double totalQ22019Forecast {get;set;}
        public Double totalQ32019Forecast {get;set;}
        public Double totalQ42019Forecast {get;set;}
        public Double total2019Risk {get;set;}
        public Double total2019Forecast {get;set;}
        public Double total2019Upside {get;set;}
        public Double total2019Target {get;set;}
        public String backColorRight {get;set;}
        public String backColorTarget {get;set;}
        
        public String backColorLeft {get;set;}
        public Boolean isError {get;set;}
        public String errorDescription {get;set;}
        public wrapperRecords(){
            this.isSelected = false;
            this.isTotal = false;
            this.totalQ12019Forecast = 0;
            this.totalQ22019Forecast = 0;
            this.totalQ32019Forecast = 0;
            this.totalQ42019Forecast = 0;
            this.total2019Risk = 0;
            this.total2019Forecast = 0;
            this.total2019Upside = 0;
            this.total2019Target = 0;
            this.isError = false;
        }       
    }   
}