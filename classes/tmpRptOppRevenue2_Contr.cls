public with sharing class tmpRptOppRevenue2_Contr {

    public class DataMap {
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

    public class GroupDataMap {
        public List<DataMap> mDataMaps {get; private set;}
        public Decimal mTotalMaintenanceAmountDue {get; private set;}
        public Decimal mTotalBeforeTaxMaintenance {get; private set;}
        public Decimal mTotalBeforeTaxMaintenanceByRegion {get; private set;}
        public Decimal mTotalQrtTotalBeforeTaxMaintenanceByRegion {get; private set;}

        public GroupDataMap() {
            mDataMaps = new List<DataMap>();
            mTotalMaintenanceAmountDue = 0.00;
            mTotalBeforeTaxMaintenance = 0.00;
            mTotalBeforeTaxMaintenanceByRegion = 0.00;
            mTotalQrtTotalBeforeTaxMaintenanceByRegion = 0.00;
        }
    }

    public class AllTermGroupsDataMap {
        public Map<String, GroupDataMap> mTermGroupDataMap {get; private set;}
        public Decimal mAllTotalMaintenanceAmountDue {get; private set;}
        public Decimal mAllTotalBeforeTaxMaintenance {get; private set;}
        public Decimal mAllTotalBeforeTaxMaintenanceByRegion {get; private set;}
        public Decimal mAllTotalQrtTotalBeforeTaxMaintenanceByRegion {get; private set;}

        public AllTermGroupsDataMap() {
            this.clear();
        }

        public void clear() {
            mTermGroupDataMap = new Map<String, GroupDataMap>();
            mAllTotalMaintenanceAmountDue = 0.00;
            mAllTotalBeforeTaxMaintenance = 0.00;
            mAllTotalBeforeTaxMaintenanceByRegion = 0.00;
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

    private final Set<String> usernames = new Set<String>{
        'kathy.paige@genesyslab.com'
        ,'vikram.sharma@genesyslab.com'
        ,'william.smith@genesyslab.com'
        };

    public List<String> mRTIds {get; set;}
    public List<String> mOppStatuses {get; set;}
    public Opportunity mOppDateObj {get; set;}
    public Boolean mQueryData {get; set;}

    public tmpRptOppRevenue2_Contr() {
        mRTIds = new List<String>();
        mOppStatuses = new List<String>();
        mOppDateObj = new Opportunity();
        mQueryData = false;
    }

    public void setStartDate(Date d) {
        mOppDateObj.Quote_Maintenance_Start_Date__c = d;
    }

    public void setEndDate(Date d) {
        mOppDateObj.Quote_Maintenance_End_Date__c = d;
    }

    public void setOpportunityRecordIds(String[] ids) {
        mRTIds.clear();
        if ((null != ids) && (!ids.isEmpty())) {
            mRTIds.addAll(ids);
        }
    }

    public void setOpportunityStatuses(String[] statuses) {
        mOppStatuses.clear();
        if ((null != statuses) && (!statuses.isEmpty())) {
            mOppStatuses.addAll(statuses);
        }
    }

    public PageReference canAccess() {
        // only allow Sys Admin or Kathy to view this
        User usr = getUser();
        for (String username : usernames) {
            if (usr.Username.startsWith(username)) {
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

    public List<SelectOption> getOppStatuses() {
        List<SelectOption> l = new List<SelectOption>();
        Schema.DescribeFieldResult dfr = Opportunity.Opportunity_Status__c.getDescribe();
        List<Schema.PicklistEntry> ples = dfr.getPicklistValues();
        for (Schema.PicklistEntry ple : ples) {
            if (ple.isActive()) {
                l.add(new SelectOption(ple.getLabel(), ple.getValue()));
            }
        }
        return l;
    }

    public PageReference runReport() {
        mQueryData = false;
        if (isValidCriteria()) {
            mQueryData = true;
        }
        return null;
    }

    public PageReference exportReport() {
        PageReference pr = new PageReference('/apex/tmpRptOppRevenue2_csv');
        return pr;
    }

    public AllTermGroupsDataMap getQueryData() {
        // lets break this up
        AllTermGroupsDataMap atgdMap = new AllTermGroupsDataMap();
        if (mQueryData) {
            Map<Id, DataMap> dMaps = queryOpportunities(atgdMap);
            queryAccounts(dMaps);
            queryPrimaryQuotes(dMaps, atgdMap);
            queryOrders(dMaps);
            queryEndUserCountries(dMaps);
        }
        return atgdMap;
    }

    public List<Map<String, Object>> getQueryDataAsSingleList() {
        AllTermGroupsDataMap atgdMap = getQueryData();
        List<Map<String, Object>> rets = new List<Map<String, Object>>();
        for (String term : atgdMap.mTermGroupDataMapTerms) {
            Map<String, Object> termMap = new Map<String, Object>{
                    'DESCRIPTION' => 'TERMROW'
                    ,'term' => term
                    };
            rets.add(termMap);

            for (DataMap dMap : atgdMap.mTermGroupDataMap.get(term).mDataMaps) {
                Map<String, Object> dataMap = new Map<String, Object>{
                    'DESCRIPTION' => 'DATAROW'
                    ,'opp' => dMap.mOpp
                    ,'acct' => dMap.mAcct
                    ,'bmQuote' => dMap.mBMQuote
                    ,'endUserCountry' => dMap.mEndUserCountry
                    ,'ord' => dMap.mOrder
                    ,'mQrtTotalBeforeTaxMaintenanceByRegion' => dMap.mQrtTotalBeforeTaxMaintenanceByRegion
                    };
                rets.add(dataMap);
            }

            Map<String, Object> dataMap = new Map<String, Object>{
                'DESCRIPTION' => 'DATASUMMARYROW'
                ,'mTotalMaintenanceAmountDue' => atgdMap.mTermGroupDataMap.get(term).mTotalMaintenanceAmountDue
                ,'mTotalBeforeTaxMaintenance' => atgdMap.mTermGroupDataMap.get(term).mTotalBeforeTaxMaintenance
                ,'mTotalBeforeTaxMaintenanceByRegion' => atgdMap.mTermGroupDataMap.get(term).mTotalBeforeTaxMaintenanceByRegion
                ,'mTotalQrtTotalBeforeTaxMaintenanceByRegion' => atgdMap.mTermGroupDataMap.get(term).mTotalQrtTotalBeforeTaxMaintenanceByRegion
                };
            rets.add(dataMap);
        }
        Map<String, Object> dataMap = new Map<String, Object>{
            'DESCRIPTION' => 'DATATOTALROW'
            ,'mAllTotalMaintenanceAmountDue' => atgdMap.mAllTotalMaintenanceAmountDue
            ,'mAllTotalBeforeTaxMaintenance' => atgdMap.mAllTotalBeforeTaxMaintenance
            ,'mAllTotalBeforeTaxMaintenanceByRegion' => atgdMap.mAllTotalBeforeTaxMaintenanceByRegion
            ,'mAllTotalQrtTotalBeforeTaxMaintenanceByRegion' => atgdMap.mAllTotalQrtTotalBeforeTaxMaintenanceByRegion
            };
        rets.add(dataMap);
        return rets;
    }

    public String getQueryDataAsCSV() {
        String str = '';
        str = str + quoteAsString(Opportunity.Quote_Order_Payment_Terms__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Opportunity.CloseDate.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Opportunity.Quote_Big_Six__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Opportunity.Sub_Region_Maint__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Opportunity.Sub_Sub_Region_Maint__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(BigMachines__Quote__c.sObjectType.getDescribe().getLabel() + ': ' + BigMachines__Quote__c.Name.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Opportunity.Gene_Care_Specialist__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Opportunity.Name.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Opportunity.BusinessPartner__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Account.sObjectType.getDescribe().getLabel() + ':' + Account.Name.getDescribe().getLabel());
        str = str + ',' + quoteAsString(BigMachines__Quote__c.sObjectType.getDescribe().getLabel() + ': ' + BigMachines__Quote__c.Genesys_Care__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(BigMachines__Quote__c.sObjectType.getDescribe().getLabel() + ': ' + BigMachines__Quote__c.Current_Maint_Rate__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Opportunity.Quote_Maintenance_Start_Date__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Opportunity.Quote_Maintenance_End_Date__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(BigMachines__Quote__c.sObjectType.getDescribe().getLabel() + ': ' + BigMachines__Quote__c.Total_Maintenance_Amount_Due__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(BigMachines__Quote__c.sObjectType.getDescribe().getLabel() + ': ' + BigMachines__Quote__c.Total_Before_Tax_Maintenance__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(BigMachines__Quote__c.sObjectType.getDescribe().getLabel() + ': Recognized Revenue');
        str = str + ',' + quoteAsString(BigMachines__Quote__c.sObjectType.getDescribe().getLabel() + ': ' + BigMachines__Quote__c.Total_Before_Tax_Maintenance_by_Region__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Opportunity.Opportunity_Status__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(Opportunity.Invoice_Date__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(BigMachines__Quote__c.sObjectType.getDescribe().getLabel() + ': ' + BigMachines__Quote__c.Rate_Increase_Value_USD__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(BigMachines__Quote__c.sObjectType.getDescribe().getLabel() + ': ' + BigMachines__Quote__c.Annual_Increase_Value__c.getDescribe().getLabel());
        str = str + ',' + quoteAsString(BigMachines__Quote__c.sObjectType.getDescribe().getLabel() + ': ' + BigMachines__Quote__c.Decreased_Quote_Value_USD__c.getDescribe().getLabel());
        str = str + '\n';
        
        AllTermGroupsDataMap atgdMap = getQueryData();
        List<Map<String, Object>> rets = new List<Map<String, Object>>();
        for (String term : atgdMap.mTermGroupDataMapTerms) {
            for (DataMap dMap : atgdMap.mTermGroupDataMap.get(term).mDataMaps) {
                str = str + quoteAsString(dMap.mOpp.Quote_Order_Payment_Terms__c);
                str = str + ',' + quoteAsString(dMap.mOpp.CloseDate);
                str = str + ',' + quoteAsString(dMap.mOpp.Quote_Big_Six__c);
                str = str + ',' + quoteAsString(dMap.mOpp.Sub_Region_Maint__c);
                str = str + ',' + quoteAsString(dMap.mOpp.Sub_Sub_Region_Maint__c);
                str = str + ',' + quoteAsString(dMap.mBMQuote.Name);
                str = str + ',' + quoteAsString(dMap.mOpp.Gene_Care_Specialist__r.Name);
                str = str + ',' + quoteAsString(dMap.mOpp.Name);
                str = str + ',' + quoteAsString(dMap.mOpp.BusinessPartner__r.Name);
                str = str + ',' + quoteAsString(dMap.mAcct.Name);
                str = str + ',' + quoteAsString(dMap.mBMQuote.Genesys_Care__c);
                str = str + ',' + quoteAsString(dMap.mBMQuote.Current_Maint_Rate__c);
                str = str + ',' + quoteAsString(dMap.mOpp.Quote_Maintenance_Start_Date__c);
                str = str + ',' + quoteAsString(dMap.mOpp.Quote_Maintenance_End_Date__c);
                str = str + ',' + quoteAsString(dMap.mBMQuote.Total_Maintenance_Amount_Due__c);
                str = str + ',' + quoteAsString(dMap.mBMQuote.Total_Before_Tax_Maintenance__c);
                str = str + ',' + quoteAsString(dMap.mQrtTotalBeforeTaxMaintenanceByRegion);
                str = str + ',' + quoteAsString(dMap.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c);
                str = str + ',' + quoteAsString(dMap.mOpp.Opportunity_Status__c);
                str = str + ',' + quoteAsString(dMap.mOpp.Invoice_Date__c);
                str = str + ',' + quoteAsString(dMap.mBMQuote.Rate_Increase_Value_USD__c);
                str = str + ',' + quoteAsString(dMap.mBMQuote.Annual_Increase_Value__c);
                str = str + ',' + quoteAsString(dMap.mBMQuote.Decreased_Quote_Value_USD__c);
                str = str + '\n';
            }
        }
        return str;
    }

    private Map<Id, DataMap> queryOpportunities(AllTermGroupsDataMap atgdMap) {
        Map<Id, DataMap> dMap = new Map<Id, DataMap>();
        User usr = getUser();
        Set<String> userRegions = getUserRegions(usr);
        for (Opportunity[] opps :
            [select 
                AccountId
                ,convertCurrency(Amount)
                ,BusinessPartner__c
                ,BusinessPartner__r.Name
                ,CloseDate
                ,Country__c
                ,CurrencyIsoCode 
                ,ForecastStatus__c
                ,Gene_Care_Specialist__c
                ,Gene_Care_Specialist__r.Name
                ,Invoice__c
                ,Invoice_Date__c
                ,Name
                ,Opportunity_Status__c
                ,PO_Date__c
                ,Quote_Big_Six__c
                ,Quote_Maintenance_End_Date__c
                ,Quote_Maintenance_Start_Date__c
                ,Quote_Order_Payment_Terms__c
                ,Sub_Region_Maint__c
                ,Sub_Sub_Region_Maint__c
                from Opportunity
                where CloseDate >= :mOppDateObj.Quote_Maintenance_Start_Date__c
                and CloseDate <= :mOppDateObj.Quote_Maintenance_End_Date__c
                and RecordtypeId in :mRTIds
                and Opportunity_Status__c in :mOppStatuses
                and Country_Region__c in :userRegions]) {
            for (Opportunity opp : opps) {
                DataMap dm = new DataMap();
                dMap.put(opp.Id, dm);
                dm.mOpp = opp;

                String term = opp.Quote_Order_Payment_Terms__c;
                if (isBlank(term)) {
                    term = 'NULL';
                }
                GroupDataMap gdm = atgdMap.mTermGroupDataMap.get(term);
                if (null == gdm) {
                    gdm = new GroupDataMap();
                    atgdMap.mTermGroupDataMap.put(term, gdm);
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

    private void queryPrimaryQuotes(Map<Id, DataMap> dMaps, AllTermGroupsDataMap atgdMap) {
        for (BigMachines__Quote__c[] qs :
            [select
                convertCurrency(Annual_Increase_Value__c)
                ,BigMachines__Opportunity__c
                ,Big_Six__c
                ,Comment__c
                ,CurrencyIsoCode 
                ,Current_Maint_Rate__c
                ,Decreased_Quote_Value_USD__c
                ,Genesys_Care__c
                ,Name
                ,Rate_Increase_Value_USD__c
                ,Sub_Sub_Region__c
                ,convertCurrency(Total_Maintenance_Amount_Due__c)
                ,convertCurrency(Total_Before_Tax_Maintenance__c)
                ,convertCurrency(Total_Before_Tax_Maintenance_by_Region__c)
                from BigMachines__Quote__c
                where BigMachines__Opportunity__c in :dMaps.keySet()
                and BigMachines__Is_Primary__c = true]) {
            for (BigMachines__Quote__c q : qs) {
                DataMap dm = dMaps.get(q.BigMachines__Opportunity__c);
                dm.mBMQuote = q;

                String term = dm.mOpp.Quote_Order_Payment_Terms__c;
                if (isBlank(term)) {
                    term = 'NULL';
                }

                dm.mQrtTotalBeforeTaxMaintenanceByRegion = calculateQryRevenue(dm);
                GroupDataMap gdm = atgdMap.mTermGroupDataMap.get(term);
                if (null != gdm) {
                    gdm.mTotalMaintenanceAmountDue += ((!isBlank(q.Total_Maintenance_Amount_Due__c)) ? q.Total_Maintenance_Amount_Due__c : 0);
                    gdm.mTotalBeforeTaxMaintenance += ((!isBlank(q.Total_Before_Tax_Maintenance__c)) ? q.Total_Before_Tax_Maintenance__c : 0);
                    gdm.mTotalBeforeTaxMaintenanceByRegion += ((!isBlank(q.Total_Before_Tax_Maintenance_by_Region__c)) ? q.Total_Before_Tax_Maintenance_by_Region__c : 0);
                    gdm.mTotalQrtTotalBeforeTaxMaintenanceByRegion += dm.mQrtTotalBeforeTaxMaintenanceByRegion;

                    atgdMap.mAllTotalMaintenanceAmountDue += ((!isBlank(q.Total_Maintenance_Amount_Due__c)) ? q.Total_Maintenance_Amount_Due__c : 0);
                    atgdMap.mAllTotalBeforeTaxMaintenance += ((!isBlank(q.Total_Before_Tax_Maintenance__c)) ? q.Total_Before_Tax_Maintenance__c : 0);
                    atgdMap.mAllTotalBeforeTaxMaintenanceByRegion += ((!isBlank(q.Total_Before_Tax_Maintenance_by_Region__c)) ? q.Total_Before_Tax_Maintenance_by_Region__c : 0);
                    atgdMap.mAllTotalQrtTotalBeforeTaxMaintenanceByRegion += dm.mQrtTotalBeforeTaxMaintenanceByRegion;
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
                Integer numMonthsInBetween = today.monthsBetween(endDate) + 1;
                recRev = ((!isBlank(dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c)) ? dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c : 0);
                // what quarter are we in
                Integer mnt = today.month();
                Integer qrt = 1; // between 1 and 4
                if ((mnt >= 1) && (mnt <= 3)) {
                    qrt = 1;
                    recRev = (recRev / numMonthsforMaintenance) * ((numMonthsforMaintenance / 4) * 1);
                }
                else if ((mnt >= 4) && (mnt <= 6)) {
                    qrt = 2;
                    recRev = (recRev / numMonthsforMaintenance) * ((numMonthsforMaintenance / 4) * 2);
                }
                else if ((mnt >= 7) && (mnt <= 9)) {
                    qrt = 3;
                    recRev = (recRev / numMonthsforMaintenance) * ((numMonthsforMaintenance / 4) * 3);
                }
                else if ((mnt >= 10) && (mnt <= 12)) {
                    qrt = 4;
                    recRev = (recRev / numMonthsforMaintenance) * numMonthsforMaintenance;
                }
/*
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
*/
/*
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
*/
//              }
//              else if (numMonthsforMaintenance <= 3) {
/*
                    recRev = ((!isBlank(dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c)) ? dm.mBMQuote.Total_Before_Tax_Maintenance_by_Region__c : 0);
*/
//              }
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

    private User getUser() {
        User usr =
            [select username
                ,Region__c
                from User
                where Id = :UserInfo.getUserId()];
        return usr;
    }

    private Set<String> getUserRegions(User u) {
        Set<String> regions = new Set<String>();
        Schema.DescribeFieldResult dfr = User.Region__c.getDescribe();
        List<Schema.PicklistEntry> ples = dfr.getPicklistValues();
        for (Schema.PicklistEntry ple : ples) {
            if (ple.isActive()) {
                regions.add(ple.getValue());
            }
        }
        return regions;
    }

    private Boolean isValidCriteria() {
        if (validateStartAndEndDate()) {
            return true;
        }
        return false;
    }

    private Boolean validateStartAndEndDate() {
        if ((isBlank(mOppDateObj)) || (isBlank(mOppDateObj.Quote_Maintenance_Start_Date__c))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Start date cannot be null.'));
            return false;
        }
        if ((isBlank(mOppDateObj)) || (isBlank(mOppDateObj.Quote_Maintenance_End_Date__c))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'End date cannot be null.'));
            return false;
        }
        if (mOppDateObj.Quote_Maintenance_Start_Date__c >= mOppDateObj.Quote_Maintenance_End_Date__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Start date cannot be greater then end date.'));
            return false;
        }
        return true;
    }

    private Boolean isBlank(Object obj) {
        if (null == obj) {
            return true;
        }
        if (obj instanceOf String) {
            return String.isBlank((String) obj);
        }
        return false;
    }

    private String quoteAsString(Object obj) {
        if (isBlank(obj)) {
            return '""';
        }
        String s = '' + obj;
        return '"' + String.escapeSingleQuotes(s) + '"';
    }
}