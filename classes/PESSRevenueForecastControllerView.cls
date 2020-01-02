/***************************************************************************************************
* 
*  Class Name      :   PESSRevenueForecastControllerView
*  Description     :   This class is used to control the PESSRevenueForecastControllerOutboundView
*  Auther          :   R Systems
* 
****************************************************************************************************/
global class PESSRevenueForecastControllerView {
  
    public List<System.SelectOption> weeks {get;set;}
    public List<Account_Revenue_Forecast__c> lstAccountRevenueForecast{get;set;}
    
    public String syear{get;set;}
    public String sOfferingType{get;set;}
    public String sWeek {get;set;}
    public String pWeek {get;set;}
    
    public String selectedWeek {get;set;}
    public String selectedOfferingType {get;set;}
    public String selectedYear  {get;set;}
    public String selectedQuarter {get;set;}
    
    public String currentQuart{get;set;}
    public String currentYear{get;set;}
    
    public Boolean hideQ1 {get;set;}
    public Boolean hideQ2 {get;set;}
    public Boolean hideQ3 {get;set;}
    public Boolean hideQ4 {get;set;}
    
    public String baseUrl {get;set;}
    public Map<String, Boolean> mapOfferType{get;set;}
    
    public Decimal upsidethresholdVal{get;set;}
    public Decimal riskthresholdVal{get;set;}
    
    public String uname{get;set;}
    public String usname{get;set;}
    public boolean makeCheckboxReadOnly{get;set;}
    public Map<String, String> mapYearOfferType{get;set;}
    /**
     * Default Constructor
     **/
     
    public PESSRevenueForecastControllerView(){
        hideQ1 = false;
        hideQ2 = false;
        hideQ3 = false;
        hideQ4 = false;
        mapOfferType = new Map<String, Boolean>();
        mapYearOfferType = new Map<String,String>();
        baseUrl = 'https://' + URL.getSalesforceBaseUrl().getHost() + '/apex/PESSRevenueForecastCommentsView';
        system.debug('baseUrl '+ baseUrl );
        populateSelectedQuarters();
        selectedQuarter = selectCurrentQuarter();
        mapOfferType = getQuarterLocking();
        
        mapYearOfferType = getYearLocking();
        if(ApexPages.currentPage().getParameters().get('year') != null){    
            syear = ApexPages.currentPage().getParameters().get('year');
        }else{
            syear = selectedQuarter.substring(2,6);
        }
        
        if(ApexPages.currentPage().getParameters().get('OfferingType') != null){    
            sOfferingType = ApexPages.currentPage().getParameters().get('OfferingType');
        }else{
            List<User> userInfolst = [Select Id, CSM_Offering__c from User where Id=:UserInfo.getUserId()];
            
            if(userInfolst.size() > 0 && userInfolst[0].CSM_Offering__c != null){
                sOfferingType = userInfolst[0].CSM_Offering__c;
            }else{
                sOfferingType = 'PureEngage';
            }
        }
        
        if(ApexPages.currentPage().getParameters().get('week') != null){    
            sWeek = ApexPages.currentPage().getParameters().get('week');
        }else{
            sWeek = sWeek = QuoteRevenueMonthForecastContHelper.getCurrentWeek(selectedQuarter);
        }
        
        if(sWeek != null){
            List<Cloud_Forecast_Quarter__c> cfq = [Select Id, Previous_Week__c from Cloud_Forecast_Quarter__c where Id =:sWeek];
            if(cfq.size() > 0){
                pWeek = cfq[0].Previous_Week__c;
            }
        }
        
        upsidethresholdVal = getThresholdValue(sOfferingType, 'Upside');
        riskthresholdVal = getThresholdValue(sOfferingType, 'Risk');
        if(selectedQuarter != null){
            currentQuart = selectedQuarter.substring(0,1);
        }
        currentYear = String.valueOf(System.today().year());
        
        uname = UserInfo.getUserId().substring(0,15);
        /*Added in line- 38- makeCheckboxReadOnly parameter to make the forecast page read-only and the below code from line 98-106 to query the list of users having read-only access- for incident-#INC0310589- Added by Subhashree Nanda on 17/12/19*/
        List<PermissionSetAssignment> checkboxReadonlyIds =[SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'View_Cloud_Revenue_Forecast'];
        makeCheckboxReadOnly=false;
        usname=UserInfo.getUserId();
        for(PermissionSetAssignment u: checkboxReadonlyIds)
        {
          if(usname==u.AssigneeId)
          {
           makeCheckboxReadOnly=true;
           }
        }
    }       
   
    /**
    *   Method Name :   selectCurrentQuarter()
    *   Description :   This method used to get the Current Year Quarter
    **/
    
    global static String selectCurrentQuarter(){
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
    
    /**
    *   Method Name :   getYearLocking()
    *   Description :   This method used to get the Year from Custom Setting and this year data will be editable on UI.
    **/
    
    public Map<String, String>  getYearLocking(){
        List<Offering_Type_Settings__c> lstofferType = Offering_Type_Settings__c.getall().values();
        
        for(Offering_Type_Settings__c  offerType : lstofferType){
            if(offerType.Year__c != NULL){
                mapYearOfferType.put(offerType.Name,offerType.Year__c);
            }
        }
        
        return mapYearOfferType;
    }
    
    @RemoteAction
    global static String getAccoutnId(String offeringType, String selectedWeek, String accountName){
        system.debug('accountName = '+accountName);
        String acntName = '';
        String revenueForecastQuery = 'SELECT Account__c FROM Account_Revenue_Forecast__c WHERE Cloud_Forecast_Quarter__c =: selectedWeek';
       
        revenueForecastQuery    += ' and  Offering_Type__c =: offeringType  and Account__r.Name =:accountName limit 1';
        
        List<Account_Revenue_Forecast__c> lstAccountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);
        
        if(lstAccountRevenueForecast.size() > 0){
            acntName = lstAccountRevenueForecast[0].Account__c;
        }
        
        return acntName;
    }
    
    
    @RemoteAction
    global static List<populateCSM> populateCSMOwner(String offeringType, String selectedyear, String selectedWeek){
        
        List<populateCSM> lstCSM = new List<populateCSM>();
        populateCSM csma = new populateCSM();
        csma.itemValue = 'All';
        csma.itemLabel = 'All';
        lstCSM.add(csma);
        /*String revenueForecastQuery = 'SELECT id, Name, CSM_Account_Owner__c, CSM_Account_Owner__r.Name, Temp_CSM_Owner__r.Name FROM Account WHERE ' + 
                                        ' Id IN (SELECT Account__c FROM Account_Revenue_Forecast__c WHERE Cloud_Forecast_Quarter__c =: selectedWeek';
       
        revenueForecastQuery    += ' and  Offering_Type__c =: offeringType ) ORDER BY CSM_Account_Owner__r.Name ASC';*/
        //Priyank commented above query and added new query below.
        String revenueForecastQuery = 'SELECT CSM_Account_Owner__c, Account__r.Name, CSM_Account_Owner_ID__c FROM Account_Revenue_Forecast__c WHERE ' +
                                        ' Cloud_Forecast_Quarter__c =: selectedWeek';
        revenueForecastQuery    += ' and  Offering_Type__c =: offeringType ORDER BY CSM_Account_Owner__c ASC';
        
        List<Account_Revenue_Forecast__c> lstAccountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);
        
        Map<String, String> mapIdToName = new Map<String, String>();
        /*for(Account arf : lstAccountRevenueForecast){
            if(arf.CSM_Account_Owner__c != null){
                mapIdToName.put(arf.CSM_Account_Owner__c, arf.CSM_Account_Owner__r.Name);
            }
            if(arf.Temp_CSM_Owner__c != null && offeringType == 'Outbound'){
                mapIdToName.put(arf.Temp_CSM_Owner__c, arf.Temp_CSM_Owner__r.Name);
            }
        }*/
        for(Account_Revenue_Forecast__c arf : lstAccountRevenueForecast){
            if(arf.CSM_Account_Owner__c != null){
                mapIdToName.put(arf.CSM_Account_Owner_ID__c, arf.CSM_Account_Owner__c);
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
        /*String revenueForecastQuery = 'SELECT id, Name, CSM_Account_Owner__c, CSM_Account_Owner__r.Name FROM Account WHERE ' + 
                                        ' Id IN (SELECT Account__c FROM Account_Revenue_Forecast__c WHERE Cloud_Forecast_Quarter__c =: selectedWeek';
       
        revenueForecastQuery    += ' and  Offering_Type__c =: offeringType ) ORDER BY CSM_Account_Owner__r.Name ASC';*/
        //Priyank commented above query and added new query below.
        String revenueForecastQuery = 'SELECT CSM_Account_Owner__c, CSM_Account_Owner_ID__c FROM Account_Revenue_Forecast__c WHERE ';
        if(selectedWeek != '-- Week --'){
            revenueForecastQuery += ' Cloud_Forecast_Quarter__c =: selectedWeek';
        }
        revenueForecastQuery    += ' and  Offering_Type__c =: offeringType ORDER BY CSM_Account_Owner__c ASC';
        List<Account_Revenue_Forecast__c> lstAccountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);
        
        Map<String, String> mapIdToName = new Map<String, String>();
        for(Account_Revenue_Forecast__c arf : lstAccountRevenueForecast){
            if(arf.CSM_Account_Owner__c != null && arf.CSM_Account_Owner__c ==  UserInfo.getName() && lstUser.size() > 0 && !lstUser[0].Is_Manager__c){
                checkCSM = true;
            }
        }
        
        return checkCSM;
    }
    
    @RemoteAction
    global static List<changesReport> getchangesReport(String offeringType, String selectedyear, String selectedWeek, String selectedCompareWeek, Boolean changesOnly){
        
        Set<String> setSub = getSubscription(offeringType);
        
        List<changesReport> newChangeReport = new List<changesReport>();
        String revenueForecastQuery = '';
        
        system.debug(offeringType + ' ' + selectedyear + ' ' +  selectedWeek + ' ' + selectedCompareWeek + ' ' + setSub );
        if(selectedyear != ''){
             revenueForecastQuery    =  ' SELECT Id, Account__c, Account__r.Name, Account__r.SAP_Account_Code__c, Account__r.Region__c, Account__r.Annual_Contract_Value__c,LOB1__c,'+
                                        ' Account__r.CSM_Account_Owner_Name__c, Account__r.CSM_Account_Owner__c, Cloud_Platform_Type__c, Partner_Account__r.Name, '+
                                        ' Previous_Week__r.Q1_'+ selectedyear +'_Land__c, Q1_'+ selectedyear +'_Land__c, '+  
                                        ' Previous_Week__r.Q2_'+ selectedyear +'_Land__c, Q2_'+ selectedyear +'_Land__c, '+  
                                        ' Previous_Week__r.Q3_'+ selectedyear +'_Land__c, Q3_'+ selectedyear +'_Land__c, '+  
                                        ' Previous_Week__r.Q4_'+ selectedyear +'_Land__c, Q4_'+ selectedyear +'_Land__c, '+  
                                        ' Revenue_Type__c '+
                                        ' FROM Account_Revenue_Forecast__c' + 
                                        ' WHERE account__c !=null and LOB1__c != null ';
        }
       
       revenueForecastQuery    += ' and  Offering_Type__c =: offeringType';
       
        if(selectedWeek != null && selectedWeek != ''){
            revenueForecastQuery += ' AND Cloud_Forecast_Quarter__c  =: selectedWeek ' ;
        }
        if(!setSub.contains('All')){
            revenueForecastQuery += 'and Revenue_Type__c IN : setSub ORDER BY account__r.Name ASC';
        }else{
            revenueForecastQuery += ' ORDER BY account__r.Name ASC';
        }
        
        system.debug('query = '+ revenueForecastQuery);
        List<Account_Revenue_Forecast__c> lstAccountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);
        
        String revenueForecastQueryCompare = '';
        
        if(selectedyear != ''){
             revenueForecastQueryCompare    =  ' SELECT Id, Account__c, Account__r.Name, Account__r.SAP_Account_Code__c, Account__r.Region__c, Account__r.Annual_Contract_Value__c,LOB1__c,'+
                                        ' Account__r.CSM_Account_Owner_Name__c, Account__r.CSM_Account_Owner__c, Cloud_Platform_Type__c, Partner_Account__r.Name,'+
                                        ' Q1_'+ selectedyear +'_Land__c, '+  
                                        ' Q2_'+ selectedyear +'_Land__c, '+  
                                        ' Q3_'+ selectedyear +'_Land__c, '+  
                                        ' Q4_'+ selectedyear +'_Land__c, '+  
                                        ' Revenue_Type__c '+
                                        ' FROM Account_Revenue_Forecast__c' + 
                                        ' WHERE account__c !=null and LOB1__c != null ';
        }
       
       revenueForecastQueryCompare    += ' and  Offering_Type__c =: offeringType';
       
        if(selectedWeek != null && selectedWeek != ''){
            revenueForecastQueryCompare += ' AND Cloud_Forecast_Quarter__c  =: selectedCompareWeek ' ;
        }
        if(!setSub.contains('All')){
            revenueForecastQueryCompare += 'and Revenue_Type__c IN : setSub ORDER BY account__r.Name ASC';
        }else{
            revenueForecastQueryCompare += ' ORDER BY account__r.Name ASC';
        }
        
        List<Account_Revenue_Forecast__c> lstAccountRevenueForecastCompare = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQueryCompare);
        
        Map<String, Account_Revenue_Forecast__c> mapKeyToARF = new Map<String, Account_Revenue_Forecast__c>();
        
        for(Account_Revenue_Forecast__c arf : lstAccountRevenueForecastCompare){
            String key = arf.Account__c + arf.LOB1__c ;
            mapKeyToARF.put(key, arf);
        }
        
        Map<Id, List<Account_Revenue_Forecast__c>> mapNew = new Map<Id, List<Account_Revenue_Forecast__c>>();
        
        for(Account_Revenue_Forecast__c arfc : lstAccountRevenueForecast){
            if(mapNew.containsKey(arfc.Account__c)){
                List<Account_Revenue_Forecast__c> lstarfc = mapNew.get(arfc.Account__c);
                lstarfc.add(arfc);
                mapNew.put(arfc.Account__c, lstarfc);
            }else{
                List<Account_Revenue_Forecast__c> lstarfc = new List<Account_Revenue_Forecast__c>();
                lstarfc.add(arfc);
                mapNew.put(arfc.Account__c, lstarfc);
            }
        }
        
        for(Id ids : mapNew.keyset()){
            
            changesReport cr = new changesReport();
            cr.q1Sub = 0; 
            cr.q2Sub = 0;
            cr.q3Sub = 0;
            cr.q4Sub = 0;
            cr.q1PrevSub = 0;
            cr.q2PrevSub = 0;
            cr.q3PrevSub = 0;
            cr.q4PrevSub = 0; 
            system.debug('AccountId ' + Ids);
            for(Account_Revenue_Forecast__c arf : mapNew.get(ids)){
                String keyval = arf.Account__c + arf.LOB1__c;
                system.debug('keyval= ' + keyval);
                if(mapKeyToARF.containsKey(keyval)){
                    system.debug('mapKeyFound ' + keyval + '  ' + arf.Id);
                    Account_Revenue_Forecast__c arfPrev = new Account_Revenue_Forecast__c();
                    arfPrev = mapKeyToARF.get(keyval);
                    
                    cr.acntName = arf.Account__r.Name; 
                    cr.partnerAccount = arf.Partner_Account__r.Name;   
                    cr.acntGranCode = arf.Account__r.SAP_Account_Code__c;
                    cr.acntContractValue = arf.Account__r.Annual_Contract_Value__c;
                    cr.acntRevType = 'Subscription';
                    cr.acntCountryRegion = arf.Account__r.Region__c;
                    cr.acntCSMOwner = arf.Account__r.CSM_Account_Owner_Name__c;
                    cr.cloudPlatformtype = arf.Cloud_Platform_Type__c;
                    
                    
                    if(arf.get('Q1_' + selectedyear + '_Land__c') != null){
                        if(cr.q1Sub != null)
                            cr.q1Sub += (Decimal)arf.get('Q1_' + selectedyear + '_Land__c');
                        else{
                            cr.q1Sub = (Decimal)arf.get('Q1_' + selectedyear + '_Land__c');   
                        }
                    }
                    
                    if(arfPrev.get('Q1_' + selectedyear + '_Land__c') != null){
                        if(cr.q1PrevSub != null){
                            cr.q1PrevSub += (Decimal)arfPrev.get('Q1_' + selectedyear + '_Land__c');
                        }else{
                            cr.q1PrevSub = (Decimal)arfPrev.get('Q1_' + selectedyear + '_Land__c');
                        }
                    }
                    
                    if(arf.get('Q2_' + selectedyear + '_Land__c') != null){
                        if(cr.q2Sub != null)
                            cr.q2Sub += (Decimal)arf.get('Q2_' + selectedyear + '_Land__c');
                        else{
                            cr.q2Sub = (Decimal)arf.get('Q2_' + selectedyear + '_Land__c');   
                        }
                    }
                    
                    if(arfPrev.get('Q2_' + selectedyear + '_Land__c') != null){
                        if(cr.q2PrevSub != null){
                            cr.q2PrevSub += (Decimal)arfPrev.get('Q2_' + selectedyear + '_Land__c');
                        }else{
                            cr.q2PrevSub = (Decimal)arfPrev.get('Q2_' + selectedyear + '_Land__c');
                        }
                    }
                    
                    if(arf.get('Q3_' + selectedyear + '_Land__c') != null){
                        if(cr.q3Sub != null)
                            cr.q3Sub += (Decimal)arf.get('Q3_' + selectedyear + '_Land__c');
                        else{
                            cr.q3Sub = (Decimal)arf.get('Q3_' + selectedyear + '_Land__c');   
                        }
                    }
                    
                    if(arfPrev.get('Q3_' + selectedyear + '_Land__c') != null){
                        if(cr.q3PrevSub != null){
                            cr.q3PrevSub += (Decimal)arfPrev.get('Q3_' + selectedyear + '_Land__c');
                        }else{
                            cr.q3PrevSub = (Decimal)arfPrev.get('Q3_' + selectedyear + '_Land__c');
                        }
                    }
                    
                    if(arf.get('Q4_' + selectedyear + '_Land__c') != null){
                        if(cr.q4Sub != null)
                            cr.q4Sub += (Decimal)arf.get('Q4_' + selectedyear + '_Land__c');
                        else{
                            cr.q4Sub = (Decimal)arf.get('Q4_' + selectedyear + '_Land__c');   
                        }
                    }
                    
                    if(arfPrev.get('Q4_' + selectedyear + '_Land__c') != null){
                        if(cr.q4PrevSub != null){
                            cr.q4PrevSub += (Decimal)arfPrev.get('Q4_' + selectedyear + '_Land__c');
                        }else{
                            cr.q4PrevSub = (Decimal)arfPrev.get('Q4_' + selectedyear + '_Land__c');
                        }
                    }
                }
            }
            cr.q1ChangeSub = cr.q1Sub - cr.q1PrevSub;
            cr.q2ChangeSub = cr.q2Sub - cr.q2PrevSub;
            cr.q3ChangeSub = cr.q3Sub - cr.q3PrevSub;
            cr.q4ChangeSub = cr.q4Sub - cr.q4PrevSub;
            cr.total = cr.q1Sub + cr.q2Sub + cr.q3Sub + cr.q4Sub;
            cr.totalChanges = cr.q1ChangeSub + cr.q2ChangeSub + cr.q3ChangeSub + cr.q4ChangeSub ; 
            
            if(cr.q1ChangeSub == 0 && cr.q2ChangeSub == 0 && cr.q3ChangeSub == 0 && cr.q4ChangeSub == 0 && changesOnly){
                
            }else{
                newChangeReport.add(cr);
            }
        }
        return newChangeReport;
    }
    
    global class changesReport{
        global String acntName{get;set;}
        global String partnerAccount{get;set;}
        global String acntGranCode{get;set;}
        global Decimal acntContractValue{get;set;}
        global String acntRevType{get;set;}
        global String acntCountryRegion{get;set;}
        global String acntCSMOwner{get;set;}
        global String cloudPlatformtype{get;set;}
        global Decimal q1Sub{get;set;}
        global Decimal q1PrevSub{get;set;}
        global Decimal q1ChangeSub{get;set;}
        global Decimal q2Sub{get;set;}
        global Decimal q2PrevSub{get;set;}
        global Decimal q2ChangeSub{get;set;}
        global Decimal q3Sub{get;set;}
        global Decimal q3PrevSub{get;set;}
        global Decimal q3ChangeSub{get;set;}
        global Decimal q4Sub{get;set;}
        global Decimal q4PrevSub{get;set;}
        global Decimal q4ChangeSub{get;set;}
        global Decimal totalChanges{get;set;}
        global Decimal total{get;set;}
    }
    
    global class populateCSM{
        global String itemValue{get;set;}
        global String itemLabel{get;set;}
    }
    
    private void populateSelectedQuarters(){
        Revenue_Forecast_User_Quarters__c quarters = Revenue_Forecast_User_Quarters__c.getInstance(UserInfo.getUserId());
        hideQ1 = quarters.Q1__c;
        hideQ2 = quarters.Q2__c;
        hideQ3 = quarters.Q3__c;
        hideQ4 = quarters.Q4__c;
    }
    
    /**
    *   Method Name :   getCSMSearchRecord()
    *   Description :   This method used to search Csm and calculate the count of offering type added By Priyank.
    **/
    
    @RemoteAction
    public static List<OfferringTypeCountWrapper> getCSMSearchRecord(String offeringType, String selectedyear, String selectedWeek, String csmSelect , List<String> lstIds, Boolean exp){
        
        Set<String> offeringTypeSet = new Set<String>();
        List<Account_Revenue_Forecast__c> lstAccountRevenueForecast = new List<Account_Revenue_Forecast__c>();
        Set<String> pureEngageSet = new Set<String>();
        Set<String> pureCloudSet = new Set<String>();
        Set<String> premierSet = new Set<String>();
        Set<String> pureConnectSet = new Set<String>();
        Set<String> outboundSet = new Set<String>();
        Set<String> cloudSolutionPartner = new Set<String>();
        
        List<OfferringTypeCountWrapper> offerringTypeCountList = new List<OfferringTypeCountWrapper>();
        
        Set<Id> filterIds = new Set<Id>();
        if(lstIds.size() > 0){
            for(String st : lstIds){
                filterIds.add(st);
            }
        }
        
        List<Account_Revenue_Forecast__c> arfList = [SELECT CSM_Account_Owner__c, Offering_Type__c, CSM_Account_Owner_ID__c 
                                                       FROM Account_Revenue_Forecast__c WHERE CSM_Account_Owner__c =: csmSelect AND Cloud_Forecast_Quarter__c =:  selectedWeek];
        if(arfList.size()>0){
            for(Account_Revenue_Forecast__c arf : arfList){
                offeringTypeSet.add(arf.Offering_Type__c);
            }
        }
        if(selectedyear != '' && selectedWeek != null && selectedWeek != ''){                                       
            String revenueForecastQuery    = 'SELECT Id,Offering_Type__c, CSM_Account_Owner__c, CSM_Account_Owner_ID__c , Account__r.Name, Account__r.SAP_Account_Code__c, Account__r.CSM_Account_Owner_Name__c, Account__r.CSM_Account_Owner__c, Account__r.Total_CMRR__c,Account__r.Temp_CSM_Owner__c, Cloud_Forecast_Quarter__c, Account__r.Cloud_Flag__c,  '
                                            + 'Account__c, LOB__c,LOB1__c,LOB_O__c, X'+selectedyear+'_Best__c, X'+selectedyear+'_Land__c, Apr_'+selectedyear+'__c,'
                                            + 'Aug_'+selectedyear+'__c, Dec_'+selectedyear+'__c, Feb_'+selectedyear+'__c, Jan_'+selectedyear+'__c, July_'+selectedyear+'__c, June_'+selectedyear+'__c, Land__c, Mar_'+selectedyear+'__c, May_'+selectedyear+'__c, Nov_'+selectedyear+'__c,'
                                            + 'Oct_'+selectedyear+'__c, Q1_'+selectedyear+'_Best__c, Q1_'+selectedyear+'_Land__c, Q1_'+selectedyear+'_Low__c, Q2_'+selectedyear+'_Best__c, Q2_'+selectedyear+'_Land__c, Q2_'+selectedyear+'_Low__c,' 
                                            + 'Q3_'+selectedyear+'_Best__c, Q3_'+selectedyear+'_Land__c, Q3_'+selectedyear+'_Low__c, Q4_'+selectedyear+'_Best__c, Q4_'+selectedyear+'_Land__c, Q4_'+selectedyear+'_Low__c,' 
                                            + 'Sept_'+selectedyear+'__c, X'+selectedyear+'_Low__c, Comment_Validation__c, Account__r.Revenue_Forecast_Target_Multiplier__c,Revenue_Type__c,'
                                            + 'X'+selectedyear+'_Target__c, Q1_'+selectedyear+'_Target1__c, Q2_'+selectedyear+'_Target1__c, Q3_'+selectedyear+'_Target1__c, Q4_'+selectedyear+'_Target1__c FROM Account_Revenue_Forecast__c'
                                            + ' WHERE Offering_Type__c =: offeringTypeSet AND CSM_Account_Owner__c =: csmSelect';  
            revenueForecastQuery += ' AND Cloud_Forecast_Quarter__c =:  selectedWeek ' ;
            revenueForecastQuery += ' ORDER BY account__r.Name ASC limit 7000';
            system.debug('-- '+ revenueForecastQuery );
            lstAccountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);
            for(Account_Revenue_Forecast__c accRevForRec : lstAccountRevenueForecast){
                if(accRevForRec.Offering_Type__c == 'PureEngage'){
                    pureEngageSet.add(accRevForRec.Account__c);
                }else if(accRevForRec.Offering_Type__c == 'PureCloud'){
                    pureCloudSet.add(accRevForRec.Account__c);
                }else if(accRevForRec.Offering_Type__c == 'Outbound'){
                    outboundSet.add(accRevForRec.Account__c);
                }else if(accRevForRec.Offering_Type__c == 'Premier'){
                    premierSet.add(accRevForRec.Account__c);
                }else if(accRevForRec.Offering_Type__c == 'PureConnect'){
                    pureConnectSet.add(accRevForRec.Account__c);
                }else if(accRevForRec.Offering_Type__c == 'Cloud Solution Partner (PPU)'){
                    cloudSolutionPartner.add(accRevForRec.Account__c);
                }
            }
            system.debug('pureEngageCount: ' +pureEngageSet.size());
            system.debug('pureCloudCount: ' +pureCloudSet.size());
            system.debug('outboundCount: ' +outboundSet.size());
            system.debug('premierCount: ' +premierSet.size());
            system.debug('pureConnectCount: ' +pureConnectSet.size());
            if(pureEngageSet.size() > 0){
                OfferringTypeCountWrapper offerTyCountObj = new OfferringTypeCountWrapper('PureEngage',pureEngageSet.size());
                offerringTypeCountList.add(offerTyCountObj);
            }
            if(pureCloudSet.size() > 0){
                OfferringTypeCountWrapper offerTyCountObj = new OfferringTypeCountWrapper('PureCloud',pureCloudSet.size());
                offerringTypeCountList.add(offerTyCountObj);
            }
            
            if(outboundSet.size() > 0){
                OfferringTypeCountWrapper offerTyCountObj = new OfferringTypeCountWrapper('Outbound',outboundSet.size());
                offerringTypeCountList.add(offerTyCountObj);
            }
            if(premierSet.size() > 0){
                OfferringTypeCountWrapper offerTyCountObj = new OfferringTypeCountWrapper('Premier',premierSet.size());
                offerringTypeCountList.add(offerTyCountObj);
            }
            if(pureConnectSet.size() > 0){
                OfferringTypeCountWrapper offerTyCountObj = new OfferringTypeCountWrapper('PureConnect',pureConnectSet.size());
                offerringTypeCountList.add(offerTyCountObj);
            }
            if(cloudSolutionPartner.size() > 0){
                OfferringTypeCountWrapper offerTyCountObj = new OfferringTypeCountWrapper('Cloud Solution Partner (PPU)',cloudSolutionPartner.size());
                offerringTypeCountList.add(offerTyCountObj);
            }
        }
        return offerringTypeCountList;
    }
    
    public class OfferringTypeCountWrapper{
        public String offeringType{get;set;}
        public Integer offeringTypeCount{get;set;}
        
        public OfferringTypeCountWrapper(String offType,Integer count){
            offeringType = offType;
            offeringTypeCount = count;
        }
    }
    
    /**
    *   Method Name :   getAccountRevenueRecord()
    *   Description :   This method used to display the ARF for selected offering type when the user will click on link of offering type.
    *   Parameters  :  
    **/
    @RemoteAction
    global  Static List<Account_Revenue_Forecast__c> getAccountRevenueRecordForCSM(String offeringType, String selectedyear, String selectedWeek, String csmSelect , List<String> lstIds, Boolean exp){
        Set<Id> filterIds = new Set<Id>();
        Set<String> setSub = getSubscription(offeringType);
        List<Account_Revenue_Forecast__c> lstAccountRevenueForecast = new List<Account_Revenue_Forecast__c>();
        if(lstIds.size() > 0){
            for(String st : lstIds){
                filterIds.add(st);
            }
        }
        if(selectedyear != ''){
            String revenueForecastQuery    = 'SELECT Id, Account__r.Name, Account__r.SAP_Account_Code__c, CSM_Account_Owner__c, Account__r.CSM_Account_Owner_Name__c, Account__r.CSM_Account_Owner__c, Account__r.Total_CMRR__c,Account__r.Temp_CSM_Owner__c, Cloud_Forecast_Quarter__c, Account__r.Cloud_Flag__c,Partner_Account__c,Offering_Type__c,Partner_Account__r.Name, '
                                        + 'Account__c, LOB__c,LOB1__c,LOB_O__c, X'+selectedyear+'_Best__c, X'+selectedyear+'_Land__c, Apr_'+selectedyear+'__c,'
                                        + 'Aug_'+selectedyear+'__c, Dec_'+selectedyear+'__c, Feb_'+selectedyear+'__c, Jan_'+selectedyear+'__c, July_'+selectedyear+'__c, June_'+selectedyear+'__c, Land__c, Mar_'+selectedyear+'__c, May_'+selectedyear+'__c, Nov_'+selectedyear+'__c,'
                                        + 'Oct_'+selectedyear+'__c, Q1_'+selectedyear+'_Best__c, Q1_'+selectedyear+'_Land__c, Q1_'+selectedyear+'_Low__c, Q2_'+selectedyear+'_Best__c, Q2_'+selectedyear+'_Land__c, Q2_'+selectedyear+'_Low__c,' 
                                        + 'Q3_'+selectedyear+'_Best__c, Q3_'+selectedyear+'_Land__c, Q3_'+selectedyear+'_Low__c, Q4_'+selectedyear+'_Best__c, Q4_'+selectedyear+'_Land__c, Q4_'+selectedyear+'_Low__c,' 
                                        + 'Sept_'+selectedyear+'__c, X'+selectedyear+'_Low__c, Comment_Validation__c, Account__r.Revenue_Forecast_Target_Multiplier__c,Revenue_Type__c,'
                                        + 'X'+selectedyear+'_Target__c, Q1_'+selectedyear+'_Target1__c, Q2_'+selectedyear+'_Target1__c, Q3_'+selectedyear+'_Target1__c, Q4_'+selectedyear+'_Target1__c FROM Account_Revenue_Forecast__c';
            revenueForecastQuery    += ' WHERE Offering_Type__c =: offeringType AND CSM_Account_Owner__c =: csmSelect ';
           
           
            if(selectedWeek != null && selectedWeek != ''){
                revenueForecastQuery += ' AND Cloud_Forecast_Quarter__c  =: selectedWeek ' ;
                if(!setSub.contains('All')){
                    revenueForecastQuery += ' and Revenue_Type__c IN : setSub';
                }
                if(exp){
                    if(filterIds.size() > 0 ){
                        revenueForecastQuery += ' AND Id not in :  filterIds ORDER BY account__r.Name ASC limit 7000' ;
                    }else{
                        revenueForecastQuery += ' ORDER BY account__r.Name ASC limit 7000' ;
                    }
                }else{
                    revenueForecastQuery += ' ORDER BY account__r.Name ASC limit 7000' ;
                }
                system.debug('Query + ' +revenueForecastQuery);
                lstAccountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);
                Set<String> quarter = new Set<String>();
                quarter.add('Q1_');
                quarter.add('Q2_');
                quarter.add('Q3_');
                quarter.add('Q4_');
                for(Account_Revenue_Forecast__c arf : lstAccountRevenueForecast){
                    for(String q : quarter){
                        if(arf.get(q + selectedyear + '_Land__c') == null){
                            arf.put(q + selectedyear + '_Land__c',0);
                        }
                        if(arf.get( q + selectedyear + '_Low__c') == null){
                            arf.put(q + selectedyear + '_Low__c',0);
                        }
                        if(arf.get(q + selectedyear + '_Best__c') == null){
                            arf.put(q + selectedyear + '_Best__c',0);
                        }
                    }
                    
                    if(arf.get('X'+ selectedyear+'_Best__c') == null){
                        arf.put('X' + selectedyear + '_Best__c',0);
                    }
                    if(arf.get('X'+ selectedyear+'_Land__c') == null){
                        arf.put('X' + selectedyear + '_Land__c',0);
                    }
                    if(arf.get('X'+ selectedyear+'_Target__c') == null){
                        arf.put('X' + selectedyear + '_Target__c',0);
                    }
                    if(arf.get('X'+ selectedyear+'_Low__c') == null){
                        arf.put('X' + selectedyear + '_Low__c',0);
                    }
                    
                    if(arf.get('Jan_'+ selectedyear+'__c') == null){
                        arf.put('Jan_' + selectedyear + '__c',0);
                    }
                    if(arf.get('Feb_'+ selectedyear+'__c') == null){
                        arf.put('Feb_' + selectedyear + '__c',0);
                    }
                    if(arf.get('Mar_'+ selectedyear+'__c') == null){
                        arf.put('Mar_' + selectedyear + '__c',0);
                    }
                    if(arf.get('Apr_'+ selectedyear+'__c') == null){
                        arf.put('Apr_' + selectedyear + '__c',0);
                    }
                    
                    if(arf.get('May_'+ selectedyear+'__c') == null){
                        arf.put('May_' + selectedyear + '__c',0);
                    }
                    if(arf.get('June_'+ selectedyear+'__c') == null){
                        arf.put('June_' + selectedyear + '__c',0);
                    }
                    if(arf.get('July_'+ selectedyear+'__c') == null){
                        arf.put('July_' + selectedyear + '__c',0);
                    }
                    if(arf.get('Aug_'+ selectedyear+'__c') == null){
                        arf.put('Aug_' + selectedyear + '__c',0);
                    }
                    
                    if(arf.get('Sept_'+ selectedyear+'__c') == null){
                        arf.put('Sept_' + selectedyear + '__c',0);
                    }
                    if(arf.get('Oct_'+ selectedyear+'__c') == null){
                        arf.put('Oct_' + selectedyear + '__c',0);
                    }
                    if(arf.get('Nov_'+ selectedyear+'__c') == null){
                        arf.put('Nov_' + selectedyear + '__c',0);
                    }
                    if(arf.get('Dec_'+ selectedyear+'__c') == null){
                        arf.put('Dec_' + selectedyear + '__c',0);
                    }
                }
            }
         
        }
        if(lstAccountRevenueForecast.size() > 0){
            return lstAccountRevenueForecast;
        }
        return null;
    }
    
    /**
    *   Method Name :   getAccountRevenueRecord()
    *   Description :   This method used to get the description based on Header and Module
    *   Parameters  :  
    **/
    @RemoteAction
    global  Static List<Account_Revenue_Forecast__c> getAccountRevenueRecord(String offeringType, String selectedyear, String selectedWeek, String csmSelect , List<String> lstIds, Boolean exp){
        
         system.debug('<><><> ' +lstIds );
        
        Set<Id> filterIds = new Set<Id>();
        if(lstIds.size() > 0){
            for(String st : lstIds){
                String ss = st;
                filterIds.add(ss);
            }
        }
        
        
        List<Account_Revenue_Forecast__c> lstAccountRevenueForecast = new List<Account_Revenue_Forecast__c>();
        String revenueForecastQuery = '';
        
        String userID = Label.UserId;
        if(selectedyear != ''){
             revenueForecastQuery    = 'SELECT Id, Account__r.Name,Account__r.SAP_Account_Code__c, Account__r.CSM_Account_Owner_Name__c, CSM_Account_Owner__c, Account__r.Total_CMRR__c,Account__r.Temp_CSM_Owner__c, Cloud_Forecast_Quarter__c, Account__r.Cloud_Flag__c,Partner_Account__c,Offering_Type__c,Partner_Account__r.Name, '
                                        + 'Account__c, LOB__c,LOB1__c,LOB_O__c, X'+selectedyear+'_Best__c, X'+selectedyear+'_Land__c, Apr_'+selectedyear+'__c,'
                                        + 'Aug_'+selectedyear+'__c, Dec_'+selectedyear+'__c, Feb_'+selectedyear+'__c, Jan_'+selectedyear+'__c, July_'+selectedyear+'__c, June_'+selectedyear+'__c, Land__c, Mar_'+selectedyear+'__c, May_'+selectedyear+'__c, Nov_'+selectedyear+'__c,'
                                        + 'Oct_'+selectedyear+'__c, Q1_'+selectedyear+'_Best__c, Q1_'+selectedyear+'_Land__c, Q1_'+selectedyear+'_Low__c, Q2_'+selectedyear+'_Best__c, Q2_'+selectedyear+'_Land__c, Q2_'+selectedyear+'_Low__c,' 
                                        + 'Q3_'+selectedyear+'_Best__c, Q3_'+selectedyear+'_Land__c, Q3_'+selectedyear+'_Low__c, Q4_'+selectedyear+'_Best__c, Q4_'+selectedyear+'_Land__c, Q4_'+selectedyear+'_Low__c,' 
                                        + 'Sept_'+selectedyear+'__c, X'+selectedyear+'_Low__c, Comment_Validation__c, Account__r.Revenue_Forecast_Target_Multiplier__c,Revenue_Type__c,'
                                        + 'X'+selectedyear+'_Target__c, Q1_'+selectedyear+'_Target1__c, Q2_'+selectedyear+'_Target1__c, Q3_'+selectedyear+'_Target1__c, Q4_'+selectedyear+'_Target1__c FROM Account_Revenue_Forecast__c'
                                        + ' WHERE CSM_Account_Owner__c !=null ';
        }
       
        revenueForecastQuery    += ' and  Offering_Type__c =: offeringType';
       
       
         if(selectedWeek != null && selectedWeek != ''){
            if(csmSelect != 'All'){
                if(offeringType != 'Outbound'){
                    revenueForecastQuery    += ' and  CSM_Account_Owner__c =: csmSelect';
                }else{
                    revenueForecastQuery    += ' and  ( CSM_Account_Owner__c =: csmSelect  OR Account__r.Temp_CSM_Owner__c =: csmSelect ) ';
                }
            }/*else{
                revenueForecastQuery    += ' and  CSM_Account_Owner__c !=: userID'; 
            }*/
            revenueForecastQuery += ' AND Cloud_Forecast_Quarter__c  =: selectedWeek ' ;
            
            Set<String> setSub = getSubscription(offeringType);            
            if(!setSub.contains('All')){
                revenueForecastQuery += ' and Revenue_Type__c IN : setSub';
            }
            if(exp){
                if(filterIds.size() > 0 ){
                    revenueForecastQuery += ' AND Account__c != NULL AND Id not in :  filterIds ORDER BY account__r.Name ASC limit 7000' ;
                }else{
                    revenueForecastQuery += ' AND Account__c != NULL ORDER BY account__r.Name ASC limit 7000' ;
                }
            }else{
                revenueForecastQuery += ' AND Account__c != NULL ORDER BY account__r.Name ASC' ;
            }
            
            lstAccountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);
            
            system.debug('<><> + ' +revenueForecastQuery);
            Set<String> quarter = new Set<String>();
            quarter.add('Q1_');
            quarter.add('Q2_');
            quarter.add('Q3_');
            quarter.add('Q4_');
            
            lstAccountRevenueForecast = (List<Account_Revenue_Forecast__c>)Database.query(revenueForecastQuery);
            
            for(Account_Revenue_Forecast__c arf : lstAccountRevenueForecast){
                
                for(String q : quarter){
                    if(arf.get(q + selectedyear + '_Land__c') == null){
                        arf.put(q + selectedyear + '_Land__c',0);
                    }
                    if(arf.get( q + selectedyear + '_Low__c') == null){
                        arf.put(q + selectedyear + '_Low__c',0);
                    }
                    if(arf.get(q + selectedyear + '_Best__c') == null){
                        arf.put(q + selectedyear + '_Best__c',0);
                    }
                }
                
                if(arf.get('X'+ selectedyear+'_Best__c') == null){
                    arf.put('X' + selectedyear + '_Best__c',0);
                }
                if(arf.get('X'+ selectedyear+'_Land__c') == null){
                    arf.put('X' + selectedyear + '_Land__c',0);
                }
                if(arf.get('X'+ selectedyear+'_Target__c') == null){
                    arf.put('X' + selectedyear + '_Target__c',0);
                }
                if(arf.get('X'+ selectedyear+'_Low__c') == null){
                    arf.put('X' + selectedyear + '_Low__c',0);
                }
                
                if(arf.get('Jan_'+ selectedyear+'__c') == null){
                    arf.put('Jan_' + selectedyear + '__c',0);
                }
                if(arf.get('Feb_'+ selectedyear+'__c') == null){
                    arf.put('Feb_' + selectedyear + '__c',0);
                }
                if(arf.get('Mar_'+ selectedyear+'__c') == null){
                    arf.put('Mar_' + selectedyear + '__c',0);
                }
                if(arf.get('Apr_'+ selectedyear+'__c') == null){
                    arf.put('Apr_' + selectedyear + '__c',0);
                }
                
                if(arf.get('May_'+ selectedyear+'__c') == null){
                    arf.put('May_' + selectedyear + '__c',0);
                }
                if(arf.get('June_'+ selectedyear+'__c') == null){
                    arf.put('June_' + selectedyear + '__c',0);
                }
                if(arf.get('July_'+ selectedyear+'__c') == null){
                    arf.put('July_' + selectedyear + '__c',0);
                }
                if(arf.get('Aug_'+ selectedyear+'__c') == null){
                    arf.put('Aug_' + selectedyear + '__c',0);
                }
                
                if(arf.get('Sept_'+ selectedyear+'__c') == null){
                    arf.put('Sept_' + selectedyear + '__c',0);
                }
                if(arf.get('Oct_'+ selectedyear+'__c') == null){
                    arf.put('Oct_' + selectedyear + '__c',0);
                }
                if(arf.get('Nov_'+ selectedyear+'__c') == null){
                    arf.put('Nov_' + selectedyear + '__c',0);
                }
                if(arf.get('Dec_'+ selectedyear+'__c') == null){
                    arf.put('Dec_' + selectedyear + '__c',0);
                }
            }
        }
        if(lstAccountRevenueForecast.size() > 0){
            return lstAccountRevenueForecast;
        }
        
        return null;
    }  
    
     /**
    *   Method Name :   PopulatePeriod()
    *   Description :   This method used to Populate Period
    *   Parameters  :  
    **/
    @RemoteAction
    global  Static List<populatePeriod> PopulatePeriod(String selectedyear){
        system.debug('>>>> selectedyear ' +selectedyear);
        List<populatePeriod> lstString = new List<populatePeriod>();
        populatePeriod pp = new populatePeriod();
        pp.itemValue = '';
        pp.itemLabel = '-- Period --';
        lstString.add(pp); 
        
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
    
    
    /**
    *   Method Name :   getThresholdValue()
    *   Description :   This method used to get offeringType threshold value
    *   Parameters  :  
    **/
    
    public Decimal getThresholdValue(String offeringType, String riskUpside){
        
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
    *   Method Name :   getSubscription()
    *   Description :   This method used to get offeringType threshold value
    *   Parameters  :  
    **/
    
    public static Set<String> getSubscription(String offeringType){
        
        Set<String> setSubscription  = new Set<String>();
        
        if(offeringType != ''){
            Offering_Type_Settings__c offerType = Offering_Type_Settings__c.getValues(offeringType);
            if(offerType != null && offerType.Risk_Threshold_Amount__c != null && offerType.Subscription__c != null){
                
                for(String st : offerType.Subscription__c.split(';')){
                    setSubscription.add(st);
                }
            }
        }
        
        return setSubscription;
    }
    
     /**
    *   Method Name :   getQuarterLocking()
    *   Description :   This method used to get quarter Selection
    *   Parameters  :  
    **/
    
    public Map<String, Boolean> getQuarterLocking(){
        
        Map<String, Boolean> mapNew  = new Map<String, Boolean>();
        
        List<Offering_Type_Settings__c> lstofferType = Offering_Type_Settings__c.getall().values();
        
        for(Offering_Type_Settings__c  offerType : lstofferType){
            mapNew.put(offerType.Name, offerType.Quarter_Selection__c);
        }
        
        return mapNew;
    }
    
     /**
    *   Method Name :   getMonthLocking()
    *   Description :   This method used to get Month Selection
    *   Parameters  :  
    **/
    @RemoteAction
    public static Map<Integer, Boolean> getMonthLocking(String offerTypes){
        
        Map<Integer, Boolean> mapNew  = new Map<Integer, Boolean>();
        
        List<Offering_Type_Settings__c> lstofferType = [Select Jan__c, Feb__c, March__c, April__c, May__c, June__c, July__c, August__c, Sept__c, Oct__c, Nov__c, Dec__c from Offering_Type_Settings__c where Name=:offerTypes];
        
        for(Offering_Type_Settings__c  offerType : lstofferType){
            mapNew.put(1, offerType.Jan__c);
            mapNew.put(2, offerType.Feb__c);
            mapNew.put(3, offerType.March__c);
            mapNew.put(4, offerType.April__c);
            
            mapNew.put(5, offerType.May__c);
            mapNew.put(6, offerType.June__c);
            mapNew.put(7, offerType.July__c);
            mapNew.put(8, offerType.August__c);
            
            mapNew.put(9, offerType.Sept__c);
            mapNew.put(10, offerType.Oct__c);
            mapNew.put(11, offerType.Nov__c);
            mapNew.put(12, offerType.Dec__c);
        }
        
        return mapNew;
    }
    
    
    /**
    *   Method Name :   getAccountRevenueRecord()
    *   Description :   This method used to get the description based on Header and Module
    *   Parameters  :  
    **/
    @RemoteAction
    global  Static String saveARF(String grid, Boolean q1, Boolean q2, Boolean q3, Boolean q4, String syear){
        system.debug('>>>> '+ grid);
        List<Account_Revenue_Forecast__c> toUdpate = new List<Account_Revenue_Forecast__c>();
        if(grid != null){
            List<Account_Revenue_Forecast__c> response = (List<Account_Revenue_Forecast__c>)JSON.deserialize(grid, List<Account_Revenue_Forecast__c>.class);
            Set<Id> setArfIds =new Set<Id>();
            for(Account_Revenue_Forecast__c arf : response){
                toUdpate.add(arf);
                setArfIds.add(arf.Id);
            }
            update toUdpate;
            
            
            List<Account_Revenue_Forecast_Comment__c> lstCmnetUpside = [Select Id, Amount__c,Reason__c, Quarter__c,Quarter_Upside_Risk__c, Account_Revenue_Forecast__c, Account_Revenue_Forecast__r.Revenue_Type__c
                                                                    from Account_Revenue_Forecast_Comment__c 
                                                                    where Account_Revenue_Forecast__c In :setArfIds
                                                                    and Year__c = :syear
                                                                    and (Reason__c = :'Upside' OR Reason__c=:'Risk')];
                                                                    
            Map<String, List<Account_Revenue_Forecast_Comment__c>> mapARFRU = new Map<String, List<Account_Revenue_Forecast_Comment__c>>();
            
            Map<String, Decimal> mapARFRUAmount = new Map<String, Decimal>();
            
            for(Account_Revenue_Forecast_Comment__c arfc : lstCmnetUpside){
               
                String key = arfc.Account_Revenue_Forecast__c + arfc.Quarter__c + arfc.Reason__c + arfc.Account_Revenue_Forecast__r.Revenue_Type__c + arfc.Quarter_Upside_Risk__c;
                if(mapARFRU.containsKey(key)){
                    List<Account_Revenue_Forecast_Comment__c> lstarfc = mapARFRU.get(key);
                    lstarfc.add(arfc);
                    mapARFRU.put(key, lstarfc);
                }else{
                    List<Account_Revenue_Forecast_Comment__c> lstarfc = new List<Account_Revenue_Forecast_Comment__c>();
                    lstarfc.add(arfc);
                    mapARFRU.put(key, lstarfc);
                }
                
                if(mapARFRUAmount.containsKey(key)){
                    Decimal val = mapARFRUAmount.get(key);
                    val += arfc.Amount__c;
                    mapARFRUAmount.put(key, val);
                }else{
                    Decimal val = 0;
                    val += arfc.Amount__c;
                    mapARFRUAmount.put(key, val);
                }
                
            }
            
            List<Account_Revenue_Forecast_Comment__c> lstCmnetupdate =  new List<Account_Revenue_Forecast_Comment__c>();
            
            for(Account_Revenue_Forecast__c arf : response){
                String keyR1 = arf.Id + '1-' + syear + 'Risk' + arf.Revenue_Type__c + 'Risk - Q1 - ' + syear;
                String keyR2 = arf.Id + '2-' + syear + 'Risk' + arf.Revenue_Type__c + 'Risk - Q2 - ' + syear;
                String keyR3 = arf.Id + '3-' + syear + 'Risk' + arf.Revenue_Type__c + 'Risk - Q3 - ' + syear;
                String keyR4 = arf.Id + '4-' + syear + 'Risk' + arf.Revenue_Type__c + 'Risk - Q4 - ' + syear;
                
                if(mapARFRU.containsKey(keyR1) && mapARFRUAmount.containsKey(keyR1) && (Decimal)arf.get('Q1_' + syear + '_Low__c') != mapARFRUAmount.get(keyR1)){
                    List<Account_Revenue_Forecast_Comment__c> lstarc = mapARFRU.get(keyR1);
                    system.debug('><><>1 '+ arf.get('Q1_' + syear + '_Low__c'));
                    if(arf.get('Q1_' + syear + '_Low__c') != null){
                        Decimal riskval1 = (Decimal)arf.get('Q1_' + syear + '_Low__c') / lstarc.size();
                        for(Account_Revenue_Forecast_Comment__c arff :lstarc){
                            Account_Revenue_Forecast_Comment__c arf1 = new Account_Revenue_Forecast_Comment__c();
                            arf1.Amount__c = riskval1;
                            arf1.Id = arff.Id;
                            lstCmnetupdate.add(arf1);
                        }
                    }
                }
                if(mapARFRU.containsKey(keyR2) && mapARFRUAmount.containsKey(keyR2) && (Decimal)arf.get('Q2_' + syear + '_Low__c') != mapARFRUAmount.get(keyR2)){
                    List<Account_Revenue_Forecast_Comment__c> lstarc = mapARFRU.get(keyR2);
                    system.debug('><><>2 '+ arf.get('Q2_' + syear + '_Low__c'));
                    if(arf.get('Q2_' + syear + '_Low__c') != null){
                        Decimal riskval1 = (Decimal)arf.get('Q2_' + syear + '_Low__c') / lstarc.size();
                        for(Account_Revenue_Forecast_Comment__c arff :lstarc){
                            Account_Revenue_Forecast_Comment__c arf1 = new Account_Revenue_Forecast_Comment__c();
                            arf1.Amount__c = riskval1;
                            arf1.Id = arff.Id;
                            lstCmnetupdate.add(arf1);
                        }
                     }
                }
                if(mapARFRU.containsKey(keyR3) && mapARFRUAmount.containsKey(keyR3) && (Decimal)arf.get('Q3_' + syear + '_Low__c') != mapARFRUAmount.get(keyR3)){
                    List<Account_Revenue_Forecast_Comment__c> lstarc = mapARFRU.get(keyR3);
                    if(arf.get('Q3_' + syear + '_Low__c') != null){
                        Decimal riskval1 = (Decimal)arf.get('Q3_' + syear + '_Low__c') / lstarc.size();
                        for(Account_Revenue_Forecast_Comment__c arff :lstarc){
                            Account_Revenue_Forecast_Comment__c arf1 = new Account_Revenue_Forecast_Comment__c();
                            arf1.Amount__c = riskval1;
                            arf1.Id = arff.Id;
                            lstCmnetupdate.add(arf1);
                        }
                    }
                }
                if(mapARFRU.containsKey(keyR4) && mapARFRUAmount.containsKey(keyR4) && (Decimal)arf.get('Q4_' + syear + '_Low__c') != mapARFRUAmount.get(keyR4)){
                    List<Account_Revenue_Forecast_Comment__c> lstarc = mapARFRU.get(keyR4);
                    if(arf.get('Q4_' + syear + '_Low__c') != null){
                        Decimal riskval1 = (Decimal)arf.get('Q4_' + syear + '_Low__c') / lstarc.size();
                        for(Account_Revenue_Forecast_Comment__c arff :lstarc){
                            Account_Revenue_Forecast_Comment__c arf1 = new Account_Revenue_Forecast_Comment__c();
                            arf1.Amount__c = riskval1;
                            arf1.Id = arff.Id;
                            lstCmnetupdate.add(arf1);
                        }
                    }
                }
                
                String keyU1 = arf.Id + '1-' + syear + 'Upside' + arf.Revenue_Type__c + 'Upside - Q1 - ' + syear;
                String keyU2 = arf.Id + '2-' + syear + 'Upside' + arf.Revenue_Type__c + 'Upside - Q1 - ' + syear;
                String keyU3 = arf.Id + '3-' + syear + 'Upside' + arf.Revenue_Type__c + 'Upside - Q1 - ' + syear;
                String keyU4 = arf.Id + '4-' + syear + 'Upside' + arf.Revenue_Type__c + 'Upside - Q1 - ' + syear;
                
                if(mapARFRU.containsKey(keyU1) && mapARFRUAmount.containsKey(keyU1) && (Decimal)arf.get('Q1_' + syear + '_Best__c') != mapARFRUAmount.get(keyU1)){
                    List<Account_Revenue_Forecast_Comment__c> lstarc = mapARFRU.get(keyU1);
                    if(arf.get('Q1_' + syear + '_Best__c') != null){
                        Decimal riskval1 = (Decimal)arf.get('Q1_' + syear + '_Best__c') / lstarc.size();
                        for(Account_Revenue_Forecast_Comment__c arff :lstarc){
                            Account_Revenue_Forecast_Comment__c arf1 = new Account_Revenue_Forecast_Comment__c();
                            arf1.Amount__c = riskval1;
                            arf1.Id = arff.Id;
                            lstCmnetupdate.add(arf1);
                        }
                    }
                }
                if(mapARFRU.containsKey(keyU2) && mapARFRUAmount.containsKey(keyU2) && (Decimal)arf.get('Q2_' + syear + '_Best__c') != mapARFRUAmount.get(keyU2)){
                    List<Account_Revenue_Forecast_Comment__c> lstarc = mapARFRU.get(keyU2);
                    if(arf.get('Q2_' + syear + '_Best__c') != null){
                        Decimal riskval1 = (Decimal)arf.get('Q2_' + syear + '_Best__c') / lstarc.size();
                        for(Account_Revenue_Forecast_Comment__c arff :lstarc){
                            Account_Revenue_Forecast_Comment__c arf1 = new Account_Revenue_Forecast_Comment__c();
                            arf1.Amount__c = riskval1;
                            arf1.Id = arff.Id;
                            lstCmnetupdate.add(arf1);
                        }
                    }
                }
                if(mapARFRU.containsKey(keyU3) && mapARFRUAmount.containsKey(keyU3) && (Decimal)arf.get('Q3_' + syear + '_Best__c') != mapARFRUAmount.get(keyU3)){
                    List<Account_Revenue_Forecast_Comment__c> lstarc = mapARFRU.get(keyU3);
                    if(arf.get('Q3_' + syear + '_Best__c') != null){
                        Decimal riskval1 = (Decimal)arf.get('Q3_' + syear + '_Best__c') / lstarc.size();
                        for(Account_Revenue_Forecast_Comment__c arff :lstarc){
                            Account_Revenue_Forecast_Comment__c arf1 = new Account_Revenue_Forecast_Comment__c();
                            arf1.Amount__c = riskval1;
                            arf1.Id = arff.Id;
                            lstCmnetupdate.add(arf1);
                        }
                     }
                }
                if(mapARFRU.containsKey(keyU4) && mapARFRUAmount.containsKey(keyR4) && (Decimal)arf.get('Q4_' + syear + '_Best__c') != mapARFRUAmount.get(keyR4)){
                    List<Account_Revenue_Forecast_Comment__c> lstarc = mapARFRU.get(keyU4);
                    if(arf.get('Q4_' + syear + '_Best__c') != null){
                        Decimal riskval1 = (Decimal)arf.get('Q4_' + syear + '_Best__c') / lstarc.size();
                        for(Account_Revenue_Forecast_Comment__c arff :lstarc){
                            Account_Revenue_Forecast_Comment__c arf1 = new Account_Revenue_Forecast_Comment__c();
                            arf1.Amount__c = riskval1;
                            arf1.Id = arff.Id;
                            lstCmnetupdate.add(arf1);
                        }
                    }
                }
            }
            
            if(lstCmnetupdate.size() > 0){
                update lstCmnetupdate;
            }
            Revenue_Forecast_User_Quarters__c quarters = Revenue_Forecast_User_Quarters__c.getInstance(UserInfo.getUserId());
            if(quarters == null){
                quarters = new Revenue_Forecast_User_Quarters__c(SetupOwnerId = UserInfo.getUserId());
            }
            System.debug(LoggingLevel.INFO, 'NKC debug quarters ['+quarters+']');
            quarters.Q1__c = q1;
            quarters.Q2__c = q2;
            quarters.Q3__c = q3;
            quarters.Q4__c = q4;        
            upsert quarters;
            
        }
        return null;        
    }
    
     /**
    *   Method Name :   submitForecast()
    *   Description :   This method used to insert the Submit Forecast Record
    *   Parameters  :  
    **/
    @RemoteAction
    global  Static String submitForecast(String weekId){
        if(weekId != ''){
            Cloud_Forecast_Submit__c cfs = new Cloud_Forecast_Submit__c();
            cfs.Cloud_Forecast_Quarter__c = weekId;
            cfs.Submitted_Date__c = Datetime.now();
            cfs.User__c = Userinfo.getUserId();
            insert cfs;
        }
    
        return null;        
    }
}