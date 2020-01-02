public with sharing class tmpRptOppRevenue_Contr {

    class DataMap {
        public Opportunity mOpp {get; private set;}
        public Account mAcct {get; private set;}
        public BigMachines__Quote__c mBMQuote {get; private set;}
        public Country__c mEndUserCountry {get; private set;}
        public Order__c mOrder {get; private set;}
        public Decimal mQrtTotalBeforeTaxMaintenanceByRegion {get; private set;}

        public DataMap() {
            mOpp = new Opportunity();
            mAcct = new Account();
            mBMQuote = new BigMachines__Quote__c();
            mEndUserCountry = new Country__c();
            mOrder = new Order__c();
            mQrtTotalBeforeTaxMaintenanceByRegion = 0.00;
        }
    }

    class GroupDataMap {
        public List<DataMap> mDataMaps {get; private set;}
        public Decimal mTotalMaintenanceAmountDue {get; private set;}
        public Decimal mTotalBeforeTaxMaintenance {get; private set;}
        public Decimal mTotalBeforeTaxMaintenanceByRegion {get; private set;}
        public Decimal mTotalNegotiatedRateIncreaseValue {get; private set;}
        public Decimal mTotalIncreasePriceCapValue {get; private set;}
        public Decimal mTotalDecreasedQuoteValue {get; private set;}
        public Decimal mTotalQrtTotalBeforeTaxMaintenanceByRegion {get; private set;}

        public GroupDataMap() {
            mDataMaps = new List<DataMap>();
            mTotalMaintenanceAmountDue = 0.00;
            mTotalBeforeTaxMaintenance = 0.00;
            mTotalBeforeTaxMaintenanceByRegion = 0.00;
            mTotalNegotiatedRateIncreaseValue = 0.00;
            mTotalIncreasePriceCapValue = 0.00;
            mTotalDecreasedQuoteValue = 0.00;
            mTotalQrtTotalBeforeTaxMaintenanceByRegion = 0.00;
        }
    }

    class AllTermGroupsDataMap {
        public Map<String, GroupDataMap> mTermGroupDataMap {get; private set;}
        public Decimal mAllTotalMaintenanceAmountDue {get; private set;}
        public Decimal mAllTotalBeforeTaxMaintenance {get; private set;}
        public Decimal mAllTotalBeforeTaxMaintenanceByRegion {get; private set;}
        public Decimal mAllTotalNegotiatedRateIncreaseValue {get; private set;}
        public Decimal mAllTotalIncreasePriceCapValue {get; private set;}
        public Decimal mAllTotalDecreasedQuoteValue {get; private set;}
        public Decimal mAllTotalQrtTotalBeforeTaxMaintenanceByRegion {get; private set;}

        public AllTermGroupsDataMap() {
            this.clear();
        }

        public void clear() {
            mTermGroupDataMap = new Map<String, GroupDataMap>();
            mAllTotalMaintenanceAmountDue = 0.00;
            mAllTotalBeforeTaxMaintenance = 0.00;
            mAllTotalBeforeTaxMaintenanceByRegion = 0.00;
            mAllTotalNegotiatedRateIncreaseValue = 0.00;
            mAllTotalIncreasePriceCapValue = 0.00;
            mAllTotalDecreasedQuoteValue = 0.00;
            mAllTotalQrtTotalBeforeTaxMaintenanceByRegion = 0.00;
        }

        public List<String> mTermGroupDataMapTerms {
            get {
                if (mTermGroupDataMap.isEmpty()) {
                    return new List<String>();
                }
                List<String> l = new List<String>(mTermGroupDataMap.keySet());
                l.sort();
                return l;
            }
            private set;
        }

    }

    private static final String HTML_SPACE = '&#160';

    private final Set<String> usernames = new Set<String>{
        'kathy.paige@genesyslab.com'
        ,'vikram.sharma@genesyslab.com'
        ,'william.smith@genesyslab.com'
        };

    public String[] rtIds {get; set;}
    public Opportunity startDateObj {get; set;}
    public Opportunity endDateObj {get; set;}

    public AllTermGroupsDataMap mAllTermGroupsDataMap {get; private set;}

    public tmpRptOppRevenue_Contr() {
        rtIds = new String[]{};
        startDateObj = new Opportunity();
        endDateObj = new Opportunity();
        mAllTermGroupsDataMap = new AllTermGroupsDataMap();
    }

    public PageReference canAccess() {
        // only allow Sys Admin or Kathy to view this
        User u =
            [select username
                //,(select name
                //  from Profile)
                from User
                where Id = :UserInfo.getUserId()];
        for (String username : usernames) {
            if (u.Username.startsWith(username)) {
                return null;
            }
        }
        PageReference pr = Page.Unauthorized;
        pr.setRedirect(true);
        return pr;
    }
    
    public List<SelectOption> getRecordTypes() {
        List<SelectOption> l = new List<SelectOption>();
        Map<String, RecordType> RECORDTYPEMAP = Opportunity_H.RECORDTYPEMAP;
        for (RecordType rt : RECORDTYPEMAP.values()) {
            l.add(new SelectOption(rt.Id, rt.Name));
        }
        return l;
    }

    public PageReference runReport() {
        if (isValidCriteria()) {
            queryData();
        }
        return null;
    }

    public PageReference exportReport() {
        PageReference pr = new PageReference('/apex/tmpRptOppRevenue_xls');
        return pr;
    }

    private void queryData() {
        // lets break this up since we do not have to worry about governor limits
        mAllTermGroupsDataMap.clear();
        Map<Id, DataMap> dMaps = queryOpportunities();
        queryAccounts(dMaps);
        queryPrimaryQuotes(dMaps);
        queryOrders(dMaps);
        queryEndUserCountries(dMaps);
    }

    private Boolean isValidCriteria() {
        if (validateStartAndEndDate()) {
            return true;
        }
        return false;
    }

    private Boolean validateStartAndEndDate() {
        if ((isBlank(startDateObj)) || (isBlank(startDateObj.CloseDate))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Start date cannot be null.'));
            return false;
        }
        if ((isBlank(endDateObj)) || (isBlank(endDateObj.CloseDate))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'End date cannot be null.'));
            return false;
        }
        if (startDateObj.CloseDate >= endDateObj.CloseDate) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Start date cannot be greater then end date.'));
            return false;
        }
        return true;
    }

    private Map<Id, DataMap> queryOpportunities() {
        Map<Id, DataMap> dMap = new Map<Id, DataMap>();
        for (Opportunity[] opps :
            [select 
                AccountId
                ,Amount
                ,BusinessPartner__c
                ,CloseDate
                ,Country__c
                ,ForecastStatus__c
                ,Gene_Care_Specialist__c
                ,Invoice__c
                ,Invoice_Date__c
                ,Name
                ,PO_Date__c
                ,Quote_Big_Six__c
                ,Quote_Maintenance_End_Date__c
                ,Quote_Maintenance_Start_Date__c
                ,Quote_Order_Payment_Terms__c
                ,StageName
                ,Sub_Region_Maint__c
                ,Sub_Sub_Region_Maint__c
                from Opportunity
                where CloseDate >= :startDateObj.CloseDate
                and CloseDate <= :endDateObj.CloseDate
                and RecordtypeId in :rtIds]) {
            for (Opportunity opp : opps) {
                DataMap dm = new DataMap();
                dMap.put(opp.Id, dm);
                dm.mOpp = opp;
                String term = opp.Quote_Order_Payment_Terms__c;
                if (isBlank(term)) {
                    term = 'NULL';
                }
                GroupDataMap gdm = mAllTermGroupsDataMap.mTermGroupDataMap.get(term);
                if (null == gdm) {
                    gdm = new GroupDataMap();
                    mAllTermGroupsDataMap.mTermGroupDataMap.put(term, gdm);
                }
                gdm.mDataMaps.add(dm);
            }
        }
        return dMap;
    }

    private void queryAccounts(Map<Id, DataMap> dMaps) {
        // potentially many opps to one account
        Map<Id, Set<Id>> acctOppIdMap = new Map<Id, Set<Id>>();
        for (DataMap dm : dMaps.values()) {
            if ((null != dm.mOpp) && (null != dm.mOpp.AccountId)) {
                Set<Id> oppIds = acctOppIdMap.get(dm.mOpp.AccountId);
                if (null == oppIds) {
                    oppIds = new Set<Id>();
                    acctOppIdMap.put(dm.mOpp.AccountId, oppIds);
                }
                oppIds.add(dm.mOpp.Id);
            }
        }

        for (Account[] accts :
            [select
                Name
                from Account
                where Id in :acctOppIdMap.keyset()]) {
            for (Account acct : accts) {
                Set<Id> oppIds = acctOppIdMap.get(acct.Id);
                for (Id oppId : oppIds) {
                    DataMap dm = dMaps.get(oppId);
                    if (dm != null) {
                        dm.mAcct = acct;
                    }
                }
            }
        }
    }

    private void queryPrimaryQuotes(Map<Id, DataMap> dMaps) {
        for (BigMachines__Quote__c[] qs :
            [select
                Annual_Increase_Value__c
                ,BigMachines__Opportunity__c
                ,Big_Six__c
                ,Comment__c
                ,Current_Maint_Rate__c
                ,Decreased_Quote_Value_USD__c
                ,Genesys_Care__c
                ,Name
                ,Rate_Increase_Value_USD__c
                ,Sub_Sub_Region__c
                ,Total_Maintenance_Amount_Due__c
                ,Total_Before_Tax_Maintenance__c
                ,Total_Before_Tax_Maintenance_by_Region__c
                from BigMachines__Quote__c
                where BigMachines__Opportunity__c in :dMaps.keySet()
                and BigMachines__Is_Primary__c = true]) {
            for (BigMachines__Quote__c q : qs) {
                DataMap dm = dMaps.get(q.BigMachines__Opportunity__c);
                dm.mBMQuote = q;

                dm.mQrtTotalBeforeTaxMaintenanceByRegion = calculateQryRevenue(dm);

                String term = dm.mOpp.Quote_Order_Payment_Terms__c;
                if (isBlank(term)) {
                    term = 'NULL';
                }
                GroupDataMap gdm = mAllTermGroupsDataMap.mTermGroupDataMap.get(term);
                if (null != gdm) {
                    gdm.mTotalMaintenanceAmountDue += ((!isBlank(q.Total_Maintenance_Amount_Due__c)) ? q.Total_Maintenance_Amount_Due__c : 0);
                    gdm.mTotalBeforeTaxMaintenance += ((!isBlank(q.Total_Before_Tax_Maintenance__c)) ? q.Total_Before_Tax_Maintenance__c : 0);
                    gdm.mTotalBeforeTaxMaintenanceByRegion += ((!isBlank(q.Total_Before_Tax_Maintenance_by_Region__c)) ? q.Total_Before_Tax_Maintenance_by_Region__c : 0);
                    gdm.mTotalNegotiatedRateIncreaseValue += ((!isBlank(q.Rate_Increase_Value_USD__c)) ? q.Rate_Increase_Value_USD__c : 0);
                    gdm.mTotalIncreasePriceCapValue += ((!isBlank(q.Annual_Increase_Value__c)) ? q.Annual_Increase_Value__c : 0);
                    gdm.mTotalDecreasedQuoteValue += ((!isBlank(q.Decreased_Quote_Value_USD__c)) ? Decimal.valueOf(q.Decreased_Quote_Value_USD__c) : 0);
                    gdm.mTotalQrtTotalBeforeTaxMaintenanceByRegion += dm.mQrtTotalBeforeTaxMaintenanceByRegion;
                    mAllTermGroupsDataMap.mAllTotalMaintenanceAmountDue += ((!isBlank(q.Total_Maintenance_Amount_Due__c)) ? q.Total_Maintenance_Amount_Due__c : 0);
                    mAllTermGroupsDataMap.mAllTotalBeforeTaxMaintenance += ((!isBlank(q.Total_Before_Tax_Maintenance__c)) ? q.Total_Before_Tax_Maintenance__c : 0);
                    mAllTermGroupsDataMap.mAllTotalBeforeTaxMaintenanceByRegion += ((!isBlank(q.Total_Before_Tax_Maintenance_by_Region__c)) ? q.Total_Before_Tax_Maintenance_by_Region__c : 0);
                    mAllTermGroupsDataMap.mAllTotalNegotiatedRateIncreaseValue += ((!isBlank(q.Rate_Increase_Value_USD__c)) ? q.Rate_Increase_Value_USD__c : 0);
                    mAllTermGroupsDataMap.mAllTotalIncreasePriceCapValue += ((!isBlank(q.Annual_Increase_Value__c)) ? q.Annual_Increase_Value__c : 0);
                    mAllTermGroupsDataMap.mAllTotalDecreasedQuoteValue += ((!isBlank(q.Decreased_Quote_Value_USD__c)) ? Decimal.valueOf(q.Decreased_Quote_Value_USD__c) : 0);
                    mAllTermGroupsDataMap.mAllTotalQrtTotalBeforeTaxMaintenanceByRegion += dm.mQrtTotalBeforeTaxMaintenanceByRegion;
                }
            }
        }
    }

    private void queryOrders(Map<Id, DataMap> dMaps) {
        // is invoiced only one per opportunity?
        for (Order__c[] ords :
            [select
                Invoice_Date__c
                ,Invoiced__c
                ,Opportunity__c
                from Order__c
                where Opportunity__c in :dMaps.keyset()
                and Invoiced__c = true]) {
            for (Order__c ord : ords) {
                DataMap dm = dMaps.get(ord.Opportunity__c);
                dm.mOrder = ord;
            }
        }
    }

    private void queryEndUserCountries(Map<Id, DataMap> dMaps) {
        Map<Id, Id> countryOppIdMap = new Map<Id, Id>();
        for (DataMap dm : dMaps.values()) {
            if ((null != dm.mOpp) && (null != dm.mOpp.Country__c)) {
                countryOppIdMap.put(dm.mOpp.Country__c, dm.mOpp.Id);
            }
        }

        for (Country__c[] cnts :
            [select
                Big_Six__c
                ,Country__c
                ,Region__c
                ,SubRegion__c
                ,SubRU__c
                from Country__c
                where Id in :countryOppIdMap.keySet()]) {
            for (Country__c cnt : cnts) {
                Id oppId = countryOppIdMap.get(cnt.Id);
                DataMap dm = dMaps.get(oppId);
                dm.mEndUserCountry = cnt;
            }
        }
    }

    public Decimal calculateQryRevenue(DataMap dm) {
        Decimal recRev = 0.00;
        Date today = Date.today();
        Date startDate = dm.mOpp.Quote_Maintenance_Start_Date__c;
        Date endDate = dm.mOpp.Quote_Maintenance_End_Date__c;
        if ((null != startDate) && (null != endDate)) {
            if (today <= startDate) {
                // if current date is before start date .. leave as 0
                recRev = 0.00;
            }
            else if (today >= endDate) {
                // if current date is after end date give all
                recRev = ((!isBlank(dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c)) ? dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c : 0);
            }
            else {
                // plus 1 since same num is 0 months for date1.monthsBetween(date2)
                Integer numMonthsforMaintenance = startDate.monthsBetween(endDate) + 1;
                if (numMonthsforMaintenance >= 10) {
                    // plus 1 since same num is 0 months for date1.monthsBetween(date2)
                    Integer numMonthsInBetween = today.monthsBetween(endDate) + 1;
                    recRev = ((!isBlank(dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c)) ? dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c : 0);
                    if (numMonthsInBetween <= 3) {
                        // if current date is within 3 months of end date give all
                    }
                    else if ((numMonthsInBetween >= 4) && (numMonthsInBetween <= 6)){
                        recRev = (recRev / 12) * 9;
                    }
                    else if ((numMonthsInBetween >= 7) && (numMonthsInBetween <= 9)){
                        recRev = (recRev / 12) * 6;
                    }
                    else if ((numMonthsInBetween >= 10) && (numMonthsInBetween <= 12)){
                        recRev = (recRev / 12) * 3;
                    }
                }
                else if (numMonthsforMaintenance <= 3) {
                    recRev = ((!isBlank(dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c)) ? dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c : 0);
                }
                /*
                else if ((numMonthsforMaintenance >= 4) && (numMonthsforMaintenance <= 6)) {
                    recRev = ((!isBlank(dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c)) ? dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c : 0);
                    Integer numMonthsInBetween = today.monthsBetween(endDate) + 1;
                    if (numMonthsInBetween <= 3) {
                        // if current date is within 3 months of end date give all
                    }
                    else if ((numMonthsInBetween >= 4) && (numMonthsInBetween <= 6)){
                        recRev = (recRev / numMonthsforMaintenance) * 3;
                    }
                }
                else if ((numMonthsforMaintenance >= 7) && (numMonthsforMaintenance <= 9)) {
                    recRev = ((!isBlank(dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c)) ? dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c : 0);
                    Integer numMonthsInBetween = today.monthsBetween(endDate) + 1;
                    if (numMonthsInBetween <= 3) {
                        // if current date is within 3 months of end date give all
                        recRev = (recRev / numMonthsforMaintenance) * numMonthsforMaintenance;
                    }
                    else if ((numMonthsInBetween >= 4) && (numMonthsInBetween <= 6)){
                        recRev = (recRev / numMonthsforMaintenance) * 3;
                    }
                }
                */
            }
        }
        return recRev;
    }

    private Boolean isBlank(Object obj) {
        if (null == obj) {
            return true;
        }
        if (obj instanceOf String) {
            String str = (String) obj;
            str = str.trim();
            return (str.length() == 0);
        }
        return false;
    }

}