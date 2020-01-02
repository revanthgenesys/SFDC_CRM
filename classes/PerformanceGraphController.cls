/*
Modification Log:
Mukunthan Koothan, 02/02/2018 - updated to inlcude PureCloud Dashboard in Performance tab in Partner portal

*/

public without sharing class PerformanceGraphController{

    public Boolean displayPureEngageKPI1Exists {get; set;}
    //public Boolean displayPureConnectKPI1Exists {get; set;}
    
    public String selectedRevenueYear{get;set;}
    private Map<String,map<string,PartnerRevenue>> partnerRevenueMap{get;set;}
    private map<string,list<PartnerRevenue>> partnerRevMapFinal = new map<string,list<PartnerRevenue>>();
    public map<string,list<PartnerRevenue>> getpartnerRevMapFinal() {return partnerRevMapFinal;}
    public map<string,partnerRevTarget> revTargetMap{get;set;}
    private string ccCode;
    private map<string,decimal> solutionMultiplierToYr = new map<string,decimal>();
    private list<string> TNnPostYrs = new list<string>();
    public list<string> getTNnPostYrs(){return TNnPostYrs;}
    public boolean displayPreTwentyEighteen{get;set;}
    private Map<String,Partner_MLB_Target_Data__c> partnerMLBMap = new Map<String,Partner_MLB_Target_Data__c>();
    
    public String selectedRebateYear{get;set;}
    private Map<String,List<PartnerRebate>> partnerRebateMap{get;set;}
    //public String selectedKPI1Period{get;set;}
    //private Map<String,List<PartnerKPI1>> partnerKPI1Map{get;set;}
    // public String selectedKPI2Period{get;set;}
    // private Map<String,List<PartnerKPI1>> partnerKPI2Map{get;set;}
    
    private map<string,pureCloudWrapper> pcWrap = new map<string,pureCloudWrapper>();
    public map<string,pureCloudWrapper> getpcWrap(){return pcWrap;}
    private list<opportunity> pureCloudOptyList = new list<opportunity>();
    public list<opportunity> getpureCloudOptyList(){return pureCloudOptyList;}
    public boolean isPCYearlyBookingReqDataEmpty{get;set;}
    public string renewalRecTpId{get;set;}
    public String selectedFiscalYear{get;set;}
    private map<string,PureCloud_Yearly_Bookings_Requirement__c> yearlyBookingReq = new map<string,PureCloud_Yearly_Bookings_Requirement__c>();
    private map<string,PureCloud_Yearly_Bookings_Requirement__c> getyearlyBookingReq(){return yearlyBookingReq;}
    public boolean isPureCloudOffering{get;set;}
    private List<DatedConversionRate> datedCurrencies = new List<DatedConversionRate>();
    public List<DatedConversionRate> getdatedCurrencies(){return datedCurrencies;}
    public list<Partner_Discount__c> partnerDiscount = new list<Partner_Discount__c>();
    private list<PureCloud_Partner_Margin__c> pureCldMargins = new list<PureCloud_Partner_Margin__c>();

    private list<opportunity> revOpPostTwentyNineteen = new list<opportunity>();
    public list<opportunity> getrevOpPostTwentyNineteen(){return revOpPostTwentyNineteen;}
    private map<string,list<PartnerRevenue>> prMapPostTwentyNineteen = new map<string,list<PartnerRevenue>>();
    public map<string,list<PartnerRevenue>> getprMapPostTwentyNineteen(){return prMapPostTwentyNineteen;}
    
    public Boolean isDesignatedContact{get;set;}
    
    public List<Survey_Response__c> surveyList{get;set;}
    
    /*
    public List<ContentDocWrapper> rebateContents;
    //Variables for sorting the columns of the table   
    public static String sortExpression {get; set;}
    public static String sortDirection {get; set;}
    public static String sortExp {get; set;}
    public static String sortDir {get; set;}
    */
    public List<SelectOption> activePeriods;
    public String currentQuarter;
    List<Partner_KPI_Periods__c> SortedKPIPeriodsList;
    List<String> periods = new List<String>();
    public List<PieWedgeData> npsData{get;set;}
    public Double detractorCount=0.0;
    public Double PromoterCount=0.0;
    public Double PassiveCount=0.0;
    public Integer npsScore {get; set;}
    
    // Added for Earned Partner Rebate Enhancements 
    public String currentUserAccountId {get; set;}
    
    // Added for Cases Closed By Default Enhancements
    public String selectedCCBDPeriod {get; set;}
    public List<SelectOption> CCBDPeriods {get; set;}
    public List<CCBDGaugeData> CCBDHeaders {get; set;}

    public PerformanceGraphController(){

        User user = [SELECT AccountId,Contact.Account.TM_Acc_Country_Region__c,Contact.AccountId, Contact.Account.Partner_Tier__c,ContactId,
                        Contact.Designated_Partner_Contact__c, Contact.Account.PartnerType__c,Contact.Account.Country__r.Region__c,Contact.Account.Partner_Offering_Type__c  
                        FROM User WHERE Id =: UserInfo.getUserId()];
        
        displayPreTwentyEighteen = false;
        datedCurrencies = [SELECT Id, IsoCode, ConversionRate, nextStartDate, startDate from DatedConversionRate ORDER BY IsoCode, StartDate];
        TNnPostYrs = (Global_Setting__c.getInstance('Performance Dash 2019').Information__c).split(',');
        //TNnPostYrs = Global_Setting__c.getInstance('Performance Dash 2019').Information__c;
        currentUserAccountId = user.AccountId;
        //displayPureEngageKPI1Exists = [SELECT count() FROM Partner_Quarterly_KPI__c WHERE Account__c = :user.Contact.AccountId AND Platform__c = 'PureEngage On Premise'] > 0 ? true : false;
        //displayPureConnectKPI1Exists = [SELECT count() FROM Partner_Quarterly_KPI__c WHERE Account__c = :user.Contact.AccountId AND Platform__c = 'PureConnect On Premise'] > 0 ? true : false;
        displayPureEngageKPI1Exists = [SELECT count() FROM Partner_Quarterly_KPI__c WHERE Account__c = :user.Contact.AccountId] > 0 ? true : false;
        
        isDesignatedContact = user.Contact.Designated_Partner_Contact__c;
        String partnerRegion = user.Contact.Account.Country__r.Region__c !=null?user.Contact.Account.Country__r.Region__c :'';
        pureCloudRevenue(user);
        partnerRevenue(user);
        partnerRebate(user);
        activePeriods = new List<SelectOption>();
        currentQuarter = '';
        activePeriods =  PartnerKPIHelper.getPopulatedPeriods();
        currentQuarter = PartnerKPIHelper.getCurrentQuarter();
        for(SelectOption option : activePeriods) {
            periods.add(option.getLabel());    
        }
        SortedKPIPeriodsList = PartnerKPIHelper.getAndSortPopulatedPeriods();
        //partnerKPI1(user);
        //partnerKPI2(user);
        getRebateContents(user.Contact.Designated_Partner_Contact__c,user.AccountId,partnerRegion);
        populateNPSList(user);
        initCasesClosedByDefault(user,'');
    }
    
    public void pureCloudRevenue(User currentUser){
        
        try{
        
            if(currentUser.Contact.Designated_Partner_Contact__c){
                isPCYearlyBookingReqDataEmpty = false;
                for(RecordType recTp : [Select Id,Developername from RecordType where SobjectType = 'Opportunity']){
                    if(recTp.developername == System.Label.Opportunity_Renewal_Record_Type){
                        renewalRecTpId = recTp.Id;
                    }
                }
                
                isPureCloudOffering = (currentUser.Contact.Account.Partner_Offering_Type__c).containsIgnoreCase('PureCloud')?true:false;
                
                pureCloudOptyList = [Select Id,ACV_Subscription_Only__c,CloseDate,CurrencyIsoCode,BusinessPartner__r.CurrencyIsoCode
                    from Opportunity where Bookings_Validation_Flag__c = true
                    AND Lines_of_Businesses__c='PureCloud' AND BusinessPartner__c =: currentUser.AccountId AND 
                    BusinessPartner__r.Partner_Offering_Type__c includes ('PureCloud','PureCloud Reseller') AND 
                    recordtypeid NOT IN (:renewalRecTpId) AND CALENDAR_YEAR(closedate) < 2019];
                    
                System.Debug('pureCloudOptyList--->'+pureCloudOptyList);
                
                for(PureCloud_Yearly_Bookings_Requirement__c ybr:[Select Year__c,Tier_Minimum__c,CurrencyIsoCode from PureCloud_Yearly_Bookings_Requirement__c
                                                                    where Partner__c=:currentUser.AccountId order by Year__c desc]){
                    yearlyBookingReq.put(ybr.Year__c,ybr);
                }
                 
                if(yearlyBookingReq.size()==0){
                    isPCYearlyBookingReqDataEmpty = true;
                }
                else{
                    selectedFiscalYear = yearlyBookingReq.values()[0].Year__c;
                    
                    for(PureCloud_Yearly_Bookings_Requirement__c bYear:yearlyBookingReq.values()){
                        if(pureCloudOptyList.size()==0){
                            if(!pcWrap.containsKey(bYear.Year__c)){
                                pcWrap.put(bYear.Year__c,new pureCloudWrapper(0,bYear.Tier_Minimum__c,bYear.CurrencyIsoCode,''));
                            }
                        }
                        else{
                            for(opportunity opty:pureCloudOptyList){
                                decimal tierMin = bYear.Tier_Minimum__c == null?0:bYear.Tier_Minimum__c;
                                if(bYear.Year__c == string.valueof(opty.Closedate.year())){
                                    //System.Debug('Before-->'+opty.ACV_Subscription_Only__c);
                                    opty.ACV_Subscription_Only__c = convertCurrencyToSpecDate(opty.ACV_Subscription_Only__c, opty.CurrencyIsoCode, bYear.CurrencyIsoCode,opty.CloseDate);
                                    //System.Debug('After-->'+opty.ACV_Subscription_Only__c);
                                    if(pcWrap.containsKey(bYear.Year__c)){
                                        if(opty.ACV_Subscription_Only__c!=null)
                                        pcWrap.put(bYear.Year__c,new pureCloudWrapper((pcWrap.get(bYear.Year__c).annualVal + opty.ACV_Subscription_Only__c),tierMin,bYear.CurrencyIsoCode,''));
                                    }
                                    else{
                                        if(opty.ACV_Subscription_Only__c == null)
                                            pcWrap.put(bYear.Year__c,new pureCloudWrapper(0,tierMin,bYear.CurrencyIsoCode,''));
                                        else
                                            pcWrap.put(bYear.Year__c,new pureCloudWrapper(opty.ACV_Subscription_Only__c,tierMin,bYear.CurrencyIsoCode,''));
                                    }
                                }
                                else{
                                    if(!pcWrap.containsKey(bYear.Year__c)){
                                        pcWrap.put(bYear.Year__c,new pureCloudWrapper(0,tierMin,bYear.CurrencyIsoCode,''));
                                    }
                                }
                            }
                        }
                    }
                }
                System.Debug('pcWrap.values()--->'+pcWrap);
            }
        }
        catch(exception e){
            System.Debug('Error Message--->'+e.getMessage()+';'+e.getLineNumber());
            System.Debug('pcWrap--->'+pcWrap);
        }
    }
    
    
    public class pureCloudWrapper{
        public decimal annualVal{get;set;}
        public decimal tierMinimum{get;set;}
        public string currencyCode{get;set;}
        public string tier{get;set;}
        pureCloudWrapper(decimal acv,decimal tm,string curcyCd,string tier){
            this.annualVal = acv;
            this.tierMinimum = tm;
            this.tier = tier;
            this.currencyCode = curcyCd;
        }
    }
    
    public List<SelectOption> getFiscalYears(){
        
        List<SelectOption> options = new List<SelectOption>();
        
        for(string year : pcWrap.keySet()){
            options.add(new SelectOption(year,year));
        }
        return options;
    }
    
    public List<pureCloudWrapper> getPureCloudChart(){
        if(pcWrap.size()==0){
            return new List<pureCloudWrapper>();
        }
        else{
            return new List<pureCloudWrapper>{pcWrap.get(selectedFiscalYear)};
        }
    }
    
    public decimal convertCurrencyToSpecDate(Decimal amount, String sourceCurrencyISOCode, String targetCurrencyISOCode,Date conversionDate){
        Decimal returnAmount;
        Decimal srcAmountinUSD;
        if(sourceCurrencyISOCode == targetCurrencyISOCode){
            returnAmount = amount != NULL ? amount : 0.0;                    
        }  else {
            Decimal srcConversionRate = 0.0;
            Decimal targetConversionRate = 0.0;
            for(DatedConversionRate dtr: datedCurrencies){
                if(dtr.IsoCode == sourceCurrencyISOCode && conversionDate >= dtr.startDate && conversionDate < dtr.nextStartDate){
                    srcConversionRate = dtr.ConversionRate;   
                }
                if(dtr.IsoCode == targetCurrencyISOCode && conversionDate >= dtr.startDate && conversionDate < dtr.nextStartDate){
                    targetConversionRate = dtr.ConversionRate;
                }
            }
            
            srcAmountinUSD = (amount != NULL ? amount : 0.0)/srcConversionRate;
            
            returnAmount = (srcAmountinUSD != NULL ? srcAmountinUSD : 0.0)*targetConversionRate;
        }
        return returnAmount;
    }
    
    public void partnerRevenue(User usr){
        try{
            partnerRevenueMap = new Map<String,map<string,PartnerRevenue>>();
            revTargetMap = new map<string,partnerRevTarget>();
            Map<string,Decimal> partnerACVMap = new map<string,decimal>();
            
            Map<String,Partner_Revenue_Reporting__c> partnerRevenueTypeMap = Partner_Revenue_Reporting__c.getAll();
            
            set<string> revTypes = new set<string>();
            for(Partner_Revenue_Reporting__c prm:partnerRevenueTypeMap.values()){
                revTypes.add(prm.Name);
            }
            
            System.Debug('revTypes--->'+revTypes);
            
            Portal_Manager_Roles__c partnerRole = (new PartnerRoles()).getPMRole();
            
            for(Partner_MLB_Target_Data__c mlbData : [SELECT MLB_Year__c,MLB__c,currencyisocode
                                                FROM  Partner_MLB_Target_Data__c
                                                WHERE Account__c =: usr.AccountId]){
                partnerMLBMap.put(mlbData.MLB_Year__c,mlbData);
            }
            System.Debug('partnerMLBMap--->'+partnerMLBMap);
            list<string> optyRecTp = System.Label.Opty_AppFoundry_and_GEN_Opportunity_RT.split(',');
            System.Debug('optyRecTp--->'+optyRecTp);
            for(opportunity opp:[Select Id,ACV_Subscription_Only__c,closedate from Opportunity where Direct_Sales__c = false 
                                    AND recordtypeid IN:optyRecTp AND Win_Loss_Status__c = 'Won' AND StageName = '6.Closed' 
                                    AND (NOT Owner.Name Like '%WW-Sales Operations%') AND (NOT Owner.Name Like '%System Administrator%') 
                                    AND (NOT Owner.Name Like '%MKG%') AND Cloud_Renewal__c = false AND (Not Name like '%CMRR%') 
                                    AND (Not Name like '%$0%') AND (Not Name like '%test%') 
                                    AND (Not Name like '%talker%') AND (Not Name like '%renew%') AND (Not Name like '%PPU%') AND Primary_Line_of_Business__c = 'Cloud' 
                                    AND Lines_of_Businesses__c IN ('PureCloud','PureConnect','PureEngage') AND BusinessPartner__c =: usr.AccountId]){
                if(partnerACVMap.containsKey(string.valueof(opp.closedate.year()))){
                    decimal acvVal1 = opp.ACV_Subscription_Only__c== null?0:opp.ACV_Subscription_Only__c;
                    decimal acvVal = partnerACVMap.get(string.valueof(opp.closedate.year())) + acvVal1;
                    partnerACVMap.put(string.valueof(opp.closedate.year()),acvVal);
                }
                else{
                    decimal acvVal2 = opp.ACV_Subscription_Only__c == null?0:opp.ACV_Subscription_Only__c;
                    partnerACVMap.put(string.valueof(opp.closedate.year()),acvVal2);
                }
            }
            
            for(Partner_EndUser_Data__c revData : [SELECT End_User_Name__c,Product_Name__c,Quarter__c,Offering_Type__c,Revenue_Type__c,Revenue_Year__c,
                                                    Revenue_Amount__c,CurrencyIsoCode, Solutions_Multiplier__c
                                                    FROM Partner_EndUser_Data__c 
                                                    WHERE Account__c  =:usr.AccountId order by Revenue_Year__c asc]){
                if(!TNnPostYrs.contains(revData.Revenue_Year__c)){
                    String revenueYear     = revData.Revenue_Year__c;
                    date convDate      = Date.newInstance(integer.valueof(revenueYear), 1, 1);
                    String revenueType     = revData.Revenue_Type__c;
                    String currencyCode    = partnerMLBMap.get(revenueYear) != null? partnerMLBMap.get(revenueYear).Currencyisocode:revData.CurrencyIsoCode;
                    string offeringType    = revData.Offering_Type__c;
                    Decimal revenueAmount  = revData.Revenue_Amount__c == null?0:convertCurrencyToSpecDate(revData.Revenue_Amount__c, revData.CurrencyIsoCode,currencyCode,convDate);
                    selectedRevenueYear    = revenueYear;
                    ccCode                 = revData.CurrencyIsoCode;
                    decimal SolutionMultiplier = revData.Solutions_Multiplier__c != NULL ? revData.Solutions_Multiplier__c:0.0;
                    
                    if(partnerRevenueMap.containsKey(revenueYear)){
                        if(partnerRevenueMap.get(revenueYear).containsKey(revenueType)){
                            PartnerRevenue partRev2 = new PartnerRevenue();
                            partRev2 = partnerRevenueMap.get(revenueYear).get(revenueType);
                            //partRev2.solutionMultiplier += SolutionMultiplier1;
                            if(offeringType == 'PureEngage' || offeringType == null || offeringType == ''){
                                partRev2.pureEngage += revenueAmount;
                            }
                            else if(offeringType == 'PureConnect'){
                                partRev2.pureConnect += revenueAmount;
                            }
                            else if(offeringType == 'PureCloud'){
                                partRev2.pureCloud += revenueAmount;
                            }
                            partRev2.revTpWiseTot += revenueAmount;
                        }
                        
                        else if(revenueType == 'Revenue - Cloud Partner' && partnerRevenueMap.get(revenueYear).containsKey('Revenue - Cloud')){
                            PartnerRevenue partRev3 = new PartnerRevenue();
                            //System.Debug('revenueType--->'+revenueType);
                            partRev3 = partnerRevenueMap.get(revenueYear).get('Revenue - Cloud');
                            //System.Debug('partRev1.revenueType--->'+partRev3.revenueType);
                            //partRev2.solutionMultiplier += SolutionMultiplier1;
                            if(offeringType == 'PureEngage' || offeringType == null || offeringType == ''){
                                partRev3.pureEngage += revenueAmount;
                            }
                            else if(offeringType == 'PureConnect'){
                                partRev3.pureConnect += revenueAmount;
                            }
                            else if(offeringType == 'PureCloud'){
                                partRev3.pureCloud += revenueAmount;
                            }
                            partRev3.revTpWiseTot += revenueAmount;
                        }                       
                        
                        else{
                            if(revTypes.contains(revenueType)){
                                PartnerRevenue partRev1 = new PartnerRevenue();
                                //System.Debug('revenueType--->'+revenueType);
                                partRev1.revenueType = revenueType=='Revenue - Cloud Partner'?'Revenue - Cloud':revenueType;
                                //System.Debug('partRev1.revenueType--->'+partRev1.revenueType);
                                partRev1.currencyCode = currencyCode;
                                //partRev1.solutionMultiplier = SolutionMultiplier1;
                                if(offeringType == 'PureEngage' || offeringType == null || offeringType == ''){
                                    partRev1.pureEngage = revenueAmount;
                                }
                                else if(offeringType == 'PureConnect'){
                                    partRev1.pureConnect = revenueAmount;
                                }
                                else if(offeringType == 'PureCloud'){
                                    partRev1.pureCloud = revenueAmount;
                                }
                                partRev1.revTpWiseTot += revenueAmount;
                                partnerRevenueMap.get(revenueYear).put(partRev1.revenueType,partRev1);
                            }
                        }
                    }
                    else{
                        if(revTypes.contains(revenueType)){
                            PartnerRevenue partRev = new PartnerRevenue();
                            //System.Debug('revenueTypeelse1--->'+revenueType);
                            partRev.revenueType = revenueType=='Revenue - Cloud Partner'?'Revenue - Cloud':revenueType;
                            //System.Debug('partRev.revenueType--->'+partRev.revenueType);
                            partRev.currencyCode = currencyCode;
                            //partRev.solutionMultiplier = SolutionMultiplier1;
                            if(offeringType == 'PureEngage' || offeringType == null || offeringType == ''){
                                partRev.pureEngage = revenueAmount;
                            }
                            else if(offeringType == 'PureConnect'){
                                partRev.pureConnect = revenueAmount;
                            }
                            else if(offeringType == 'PureCloud'){
                                partRev.pureCloud = revenueAmount;
                            }
                            partRev.revTpWiseTot += revenueAmount;
                            map<string,PartnerRevenue> prMap = new map<string,PartnerRevenue>();
                            prMap.put(partRev.revenueType,partRev);
                            partnerRevenueMap.put(revenueYear,prMap);
                        }
                    }
                    
                    //solution multiplier for Rebate Dashboard
                    if(solutionMultiplierToYr.containsKey(revenueYear)){
                        decimal sm = solutionMultiplierToYr.get(revenueYear);
                        solutionMultiplierToYr.put(revenueYear,SolutionMultiplier+sm);
                    }
                    else{
                        solutionMultiplierToYr.put(revenueYear,SolutionMultiplier);
                    }
                }
            }
            System.Debug('solutionMultiplierToYr--->'+solutionMultiplierToYr);
            System.Debug('partnerRevenueMap--->'+partnerRevenueMap);
            //add the revenue types that are not present
            for(string yr:partnerRevenueMap.keyset()){
                for(string rt:revTypes){
                    if(rt != 'Revenue - Cloud Partner' && !partnerRevenueMap.get(yr).containskey(rt)){
                        PartnerRevenue pr = new PartnerRevenue();
                        pr.revenueType = rt;
                        pr.currencyCode = ccCode;
                        partnerRevenueMap.get(yr).put(rt,pr);
                    }
                }
            }
            
            //convert map<year,map<revenueType,PartnerRevenue>> to map<year,PartnerRevenue>
            for(string revYear:partnerRevenueMap.keySet()){
                for(string rType:partnerRevenueMap.get(revYear).keySet()){
                    if(partnerRevMapFinal.containsKey(revYear)){
                        (partnerRevMapFinal.get(revYear)).add((partnerRevenueMap.get(revYear)).get(rType));
                    }
                    else{
                        partnerRevMapFinal.put(revYear,new list<PartnerRevenue>{(partnerRevenueMap.get(revYear)).get(rType)});
                    }
                }
            }
            
            System.Debug('partnerRevMapFinal--->'+partnerRevMapFinal);
            

            /*-------------post 2019 logic change on Revenue Chart and PureCloud Bookings chart------------------------------------------*/
            /*---------------------------------------------------------------------------------------------------------------------------*/
            /*---------------------------------------------------------------------------------------------------------------------------*/
            /*---------------------------------------------------------------------------------------------------------------------------*/
            string GenOptyRT = Global_Setting__c.getinstance('GEN - Opportunity Record Type').ID__c;
            revOpPostTwentyNineteen = [select id, License_Amount__c,ACV_Subscription_Only__c, StageName, Win_Loss_Status__c, closedate, Lead_Offer__c, 
                                        account.name,currencyisocode from opportunity where BusinessPartner__c = :usr.AccountId AND StageName = '6.Closed' 
                                        AND recordtypeid =:GenOptyRT AND Win_Loss_Status__c = 'Won' 
                                        AND CALENDAR_YEAR(closedate) >= 2019 AND Lead_Offer__c != NULL ORDER BY closedate ASC];
            //map<string,set<string>> currencyCodeOp = new map<string,set<string>>();
            System.Debug('revOpPostTwentyNineteen--->'+revOpPostTwentyNineteen);                                                                    
            list<string> cldBookingTp = (Global_setting__c.getinstance('Cloud Booking Type').Information__c).split(',');
            list<string> licBookingTp = (Global_setting__c.getinstance('License Booking Type').Information__c).split(',');
            for(opportunity optyRecs:revOpPostTwentyNineteen){
                string mlbYr = string.valueof(optyRecs.closedate.year());
                string mlbCurcy =  partnerMLBMap.get(mlbYr) != null? partnerMLBMap.get(mlbYr).Currencyisocode:optyRecs.currencyisocode;
                selectedRevenueYear = mlbYr;
                if(prMapPostTwentyNineteen.containsKey(mlbYr)){
                   PartnerRevenue partnerRev6 = new PartnerRevenue();
                    partnerRev6.currencyCode = mlbCurcy;
                    partnerRev6.conversionDate = optyRecs.closedate;
                    decimal licOrACVVal1 = 0.0;
                    if(cldBookingTp.contains(optyRecs.Lead_Offer__c)){
                        partnerRev6.revenueType = 'Revenue - Cloud';
                        licOrACVVal1 = optyRecs.ACV_Subscription_Only__c;
                    }
                    else if(licBookingTp.contains(optyRecs.Lead_Offer__c)){
                        partnerRev6.revenueType = 'Revenue - License';
                        licOrACVVal1 = optyRecs.License_Amount__c;
                    }
                    if(!string.isBlank(partnerRev6.revenueType)){
                        if(optyRecs.Lead_Offer__c.contains('PureEngage')){
                            partnerRev6.pureEngage = convertCurrencyToSpecDate(licOrACVVal1, optyRecs.currencyisocode,mlbCurcy,optyRecs.closedate);
                        }
                        else if(optyRecs.Lead_Offer__c.contains('PureConnect')){
                            partnerRev6.pureConnect = convertCurrencyToSpecDate(licOrACVVal1, optyRecs.currencyisocode,mlbCurcy,optyRecs.closedate);
                        }
                        else if(optyRecs.Lead_Offer__c.contains('PureCloud')){
                            partnerRev6.pureCloud = convertCurrencyToSpecDate(licOrACVVal1, optyRecs.currencyisocode,mlbCurcy,optyRecs.closedate);
                        }
                        prMapPostTwentyNineteen.get(mlbYr).add(partnerRev6);
                        /*if(currencyCodeOp.containsKey(string.valueof(optyRecs.closedate.year()))){
                            currencyCodeOp.get(string.valueof(optyRecs.closedate.year())).add(optyRecs.currencyisocode);
                        }*/
                    }
                }
                else{
                    PartnerRevenue partnerRev5 = new PartnerRevenue();
                    partnerRev5.currencyCode = mlbCurcy;
                    partnerRev5.conversionDate = optyRecs.closedate;
                    decimal licOrACVVal = 0.0;
                    if(cldBookingTp.contains(optyRecs.Lead_Offer__c)){
                        partnerRev5.revenueType = 'Revenue - Cloud';
                        licOrACVVal = optyRecs.ACV_Subscription_Only__c;
                    }
                    else if(licBookingTp.contains(optyRecs.Lead_Offer__c)){
                        partnerRev5.revenueType = 'Revenue - License';
                        licOrACVVal = optyRecs.License_Amount__c;
                    }
                    if(!string.isBlank(partnerRev5.revenueType)){
                        if(optyRecs.Lead_Offer__c.contains('PureEngage')){
                            partnerRev5.pureEngage = convertCurrencyToSpecDate(licOrACVVal, optyRecs.currencyisocode,mlbCurcy,optyRecs.closedate);
                        }
                        else if(optyRecs.Lead_Offer__c.contains('PureConnect')){
                            partnerRev5.pureConnect = convertCurrencyToSpecDate(licOrACVVal, optyRecs.currencyisocode,mlbCurcy,optyRecs.closedate);
                        }
                        else if(optyRecs.Lead_Offer__c.contains('PureCloud')){
                            partnerRev5.pureCloud = convertCurrencyToSpecDate(licOrACVVal, optyRecs.currencyisocode,mlbCurcy,optyRecs.closedate);
                        }
                        prMapPostTwentyNineteen.put(mlbYr,new list<PartnerRevenue>{partnerRev5});
                        //add a dummy record for both Revenue - Cloud and Revenue - License types
                        for(integer i=1;i<=2;i++){
                            PartnerRevenue partnerRev8 = new PartnerRevenue();
                            partnerRev8.pureCloud = 0;
                            partnerRev8.pureConnect = 0;
                            partnerRev8.pureEngage = 0;
                            partnerRev8.conversionDate = optyRecs.closedate;
                            partnerRev8.currencyCode = mlbCurcy;
                            partnerRev8.revTpWiseTot = 0;
                            if(i==1){
                                partnerRev8.revenueType = 'Revenue - Cloud';
                            }
                            else{
                                partnerRev8.revenueType = 'Revenue - License';
                            }
                            prMapPostTwentyNineteen.get(mlbYr).add(partnerRev8);
                        }
                        //currencyCodeOp.put(string.valueof(optyRecs.closedate.year()),new set<string>{optyRecs.currencyisocode});
                    }
                }
            }

            System.Debug('prMapPostTwentyNineteen--->'+prMapPostTwentyNineteen);
            if(prMapPostTwentyNineteen.size()>0){
                for(string eacStr:prMapPostTwentyNineteen.keyset()){
                    //System.Debug('prMapPostTwentyNineteen.get(eacStr)--->'+prMapPostTwentyNineteen.get(eacStr));
                    /*if(currencyCodeOp.get(eacStr).size()>0){
                        list<PartnerRevenue> tmpConvLst = new list<PartnerRevenue>();
                        tmpConvLst.addAll(convertAllCurcyToUSD(prMapPostTwentyNineteen.get(eacStr)));
                        prMapPostTwentyNineteen.get(eacStr).clear();
                        prMapPostTwentyNineteen.get(eacStr).addAll(tmpConvLst);
                        System.Debug('tmpConvLst--->'+tmpConvLst);
                        System.Debug('CurrcyConv--->');
                    }*/
                    //System.Debug('prMapPostTwentyNineteen.get(eacStr)--->'+prMapPostTwentyNineteen.get(eacStr));
                    map<string,PartnerRevenue> tmpLst = new  map<string,PartnerRevenue>();
                    for(partnerRevenue prTmp:prMapPostTwentyNineteen.get(eacStr)){
                        if(tmpLst.containsKey(prTmp.revenueType)){
                            PartnerRevenue partnerRev7 = new PartnerRevenue();
                            partnerRev7 = tmpLst.get(prTmp.revenueType);
                            partnerRev7.pureCloud = partnerRev7.pureCloud == 0?prTmp.pureCloud:partnerRev7.pureCloud+prTmp.pureCloud;
                            partnerRev7.pureConnect = partnerRev7.pureConnect == 0?prTmp.pureConnect:partnerRev7.pureConnect+prTmp.pureConnect;
                            partnerRev7.pureEngage = partnerRev7.pureEngage == 0?prTmp.pureEngage:partnerRev7.pureEngage+prTmp.pureEngage;
                            partnerRev7.conversionDate = prTmp.conversionDate;
                            partnerRev7.currencyCode = prTmp.currencyCode;
                            partnerRev7.revTpWiseTot = prTmp.revTpWiseTot;
                            partnerRev7.revenueType = prTmp.revenueType;
                            tmpLst.put(prTmp.revenueType,partnerRev7);
                        }
                        else{
                            tmpLst.put(prTmp.revenueType,prTmp);
                        }
                    }
                    //System.Debug('tmpLst--->'+tmpLst);
                    prMapPostTwentyNineteen.remove(eacStr);
                    for(string tmpStr:tmpLst.keyset()){
                        if(prMapPostTwentyNineteen.containsKey(eacStr)){
                            prMapPostTwentyNineteen.get(eacStr).add(tmpLst.get(tmpStr));
                        }
                        else{
                            prMapPostTwentyNineteen.put(eacStr,new list<PartnerRevenue>{tmpLst.get(tmpStr)});
                        }
                    }
                }
            }
            System.Debug('post-prMapPostTwentyNineteen--->'+prMapPostTwentyNineteen);
            
            //add prMapPostTwentyNineteen to partnerRevMapFinal and pureCloud bookings to pcWrap
            if(prMapPostTwentyNineteen.size()>0){
                for(string eachYr:prMapPostTwentyNineteen.keySet()){
                    for(PartnerRevenue prVal:prMapPostTwentyNineteen.get(eachYr)){
                        if(prVal.revenueType == 'Revenue - Cloud'){
                            if(yearlyBookingReq.containsKey(eachYr)){
                                decimal tmpTM = yearlyBookingReq.get(eachYr).Tier_Minimum__c == null?0:yearlyBookingReq.get(eachYr).Tier_Minimum__c;
                                string tmpcurcyCd = yearlyBookingReq.get(eachYr).CurrencyIsoCode!=prVal.currencyCode?yearlyBookingReq.get(eachYr).CurrencyIsoCode:prVal.currencyCode;
                                decimal pCldConverted = prVal.pureCloud;
                                if(yearlyBookingReq.get(eachYr).CurrencyIsoCode!=prVal.currencyCode){
                                    pCldConverted = convertCurrencyToSpecDate(prVal.pureCloud, prVal.currencyCode, yearlyBookingReq.get(eachYr).CurrencyIsoCode,prVal.conversionDate);
                                } 
                                pcWrap.put(eachYr,new pureCloudWrapper(pCldConverted,tmpTM,yearlyBookingReq.get(eachYr).CurrencyIsoCode,''));                                
                            }
                        }
                        prVal.revTpWiseTot = prVal.pureCloud + prVal.pureConnect + prVal.pureEngage;
                    }
                    //decimal mlbVal = partnerMLBMap.get(eachYr) == null || !partnerRole.MLB__c?0:partnerMLBMap.get(eachYr);
                    //revTargetMap.put(eachYr,new partnerRevTarget('rev',mlbVal,grnTot,rt,acv+revLicense,partnerRevMapFinal.get(eachYr)[0].currencyCode,0));
                }
                partnerRevMapFinal.putAll(prMapPostTwentyNineteen);
            }


            //Calculate total for each revenue year
            for(string revYr:partnerRevMapFinal.keyset()){
                partnerRevenue totalPR = new partnerRevenue();
                totalPR.revenueType = 'Total';
                for(partnerRevenue prRevTot:partnerRevMapFinal.get(revYr)){
                    totalPR.pureEngage += prRevTot.pureEngage;
                    totalPR.pureConnect += prRevTot.pureConnect;
                    totalPR.pureCloud += prRevTot.pureCloud;
                    totalPR.revTpWiseTot += prRevTot.revTpWiseTot;
                    totalPR.currencyCode = prRevTot.currencyCode;
                }
                partnerRevMapFinal.get(revYr).add(totalPR);
            }

            System.Debug('2019partnerRevMapFinal--->'+partnerRevMapFinal);
            System.Debug('pcWrap.values()--->'+pcWrap);

            //create map to store MLB, GrandTotal, RuleTarget and RuleActual against each revenue year for pre 2019 logic
            //populate revTargetMap for post 2018 logic
            for(string mlbYr:partnerRevMapFinal.keyset()){
                decimal grnTot = 0;
                decimal pureConnect = 0;
                decimal pureEngage = 0;
                decimal pureCloud = 0;
                for(partnerRevenue prRevTot:partnerRevMapFinal.get(mlbYr)){
                    if(prRevTot.revenueType == 'Total'){
                        grnTot = prRevTot.pureConnect + prRevTot.pureEngage;//prRevTot.pureCloud +
                        grnTot = TNnPostYrs.contains(mlbYr)?grnTot:grnTot + prRevTot.pureCloud;                                                                                            
                        pureConnect = prRevTot.pureConnect;
                        pureEngage = prRevTot.pureEngage;
                        pureCloud = prRevTot.pureCloud;
                    }
                }
                decimal mlb = partnerMLBMap.get(mlbYr) == null || !partnerRole.MLB__c?0:partnerMLBMap.get(mlbYr).MLB__c;
                string curcyIsoCode = partnerMLBMap.get(mlbYr) == null?'':partnerMLBMap.get(mlbYr).currencyIsoCode;
                if(TNnPostYrs.contains(mlbYr)){
                    decimal tmpPCLTarget = 0;
                    if(yearlyBookingReq.get(mlbYr) != null){
                        tmpPCLTarget = convertCurrencyToSpecDate(yearlyBookingReq.get(mlbYr).Tier_Minimum__c,yearlyBookingReq.get(mlbYr).CurrencyIsoCode,partnerRevMapFinal.get(mlbYr)[0].currencyCode,Date.newInstance(integer.valueof(mlbYr),1,1));
                    }                                    
                    revTargetMap.put(mlbYr,new partnerRevTarget('rev',mlb,grnTot,pureConnect,pureEngage,curcyIsoCode,pureCloud,tmpPCLTarget));
                }
                else{
                    decimal rt = mlb == 0?0:(mlb/2);
                    decimal revLicense = partnerRevenueMap.get(mlbYr).get('Revenue - License').pureCloud + partnerRevenueMap.get(mlbYr).get('Revenue - License').pureConnect
                                            + partnerRevenueMap.get(mlbYr).get('Revenue - License').pureEngage;
                    decimal acv = partnerACVMap.get(mlbYr)!=null?partnerACVMap.get(mlbYr):0;
                    revTargetMap.put(mlbYr,new partnerRevTarget('rev',mlb,grnTot,rt,acv+revLicense,curcyIsoCode,0,0));
                }
            }

            System.Debug('revTargetMap-post2019--->'+revTargetMap);

        }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
        }
    }
    
    public List<partnerRevTarget> getRevenueChart(){
            if(revTargetMap.size()==0){
                return new List<partnerRevTarget>();
            }
            else{
                if(TNnPostYrs.contains(selectedRevenueYear)){
                    displayPreTwentyEighteen = false;
                }
                else{
                     displayPreTwentyEighteen = true;
                }
                return new List<partnerRevTarget>{revTargetMap.get(selectedRevenueYear)};
            }
    }
    
    public List<PartnerRevenue> getRevenue(){
        try{
            list<PartnerRevenue> sortedRevenue;
            if(!TNnPostYrs.contains(selectedRevenueYear)){
                list<string> revTPSortOrdr = System.Label.Partner_Revenue_Types_Sorting.split(',');
                sortedRevenue = new list<PartnerRevenue>(revTPSortOrdr.size());
                for(PartnerRevenue prRec:partnerRevMapFinal.get(selectedRevenueYear)){

                    sortedRevenue[revTPSortOrdr.indexOf(prRec.revenueType)] = prRec;
                }
                return sortedRevenue;      
            }
            else{
                list<string> revTpTN = (Global_Setting__c.getInstance('Revenue Types 2019 Dash').Information__c).split(',');
                sortedRevenue = new list<PartnerRevenue>(revTpTN.size());
                for(PartnerRevenue prRec1:partnerRevMapFinal.get(selectedRevenueYear)){
                    sortedRevenue[revTpTN.indexOf(prRec1.revenueType)] = prRec1;
                }
                return sortedRevenue;
            }
        }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
            return partnerRevMapFinal.get(selectedRevenueYear);
        }
    }
    
    public List<SelectOption> getRevenueYears(){
        
        List<SelectOption> options = new List<SelectOption>();
        
        for(String year : partnerRevMapFinal.keySet()){
                options.add(new SelectOption(year,year));
        }
        
        List<SelectOption> sortedOptions = new List<SelectOption>();
        for(Integer i = options.size()-1; i>=0;i--) {
            sortedOptions.add(options.get(i));
        }
        
        return sortedOptions;
    }
    
    public class partnerRevTarget{
        public decimal MLB{get;set;} //bookings target
        public decimal grandTotal{get;set;} //actuals
        public decimal ruleTarget{get;set;} //pureConnect value post 2019
        public decimal ruleActual{get;set;} //pureEngage value post 2019
        public decimal pureCloud{get;set;} //pureCloud value post 2019
        public string currencyCd{get;set;}
        public string type{get;set;}
        public decimal pCldTarget{get;set;}                               
        public partnerRevTarget(string tp,decimal MLB,decimal gt,decimal rt,decimal ra,string cd,decimal pcl,decimal pclt){
            this.MLB = MLB;
            this.grandTotal = gt;
            this.ruleTarget = rt;
            this.ruleActual = ra;
            this.currencyCd = cd;
            this.type = '';
            this.pureCloud = pcl;
            this.pCldTarget = pclt;                    
        }
    }
    
    public class PartnerRevenue{
        
        public string revenueType{get;set;}
        public string currencyCode{get; set;}
        public decimal pureEngage{get;set;}
        public decimal pureConnect{get;set;}
        public decimal pureCloud{get;set;}
        public decimal revTpWiseTot{get;set;}
        public date conversionDate{get;set;}
        //public decimal solutionMultiplier{get;set;}
        public PartnerRevenue(){
            this.pureEngage = 0;
            this.pureConnect = 0;
            this.pureCloud = 0;
            this.revTpWiseTot = 0;
            //this.solutionMultiplier = 0;
        }
        
    }
    
    public static String currencySymbol(String iso) { 
        String symbol = null;  
        
        if (iso=='USD') { symbol='$'; }
        else if (iso=='AUD') { symbol='$'; }
        else if (iso=='BRL') { symbol='R$'; }
        else if (iso=='CAD') { symbol='$'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='GBP') { symbol='£'; }
        else if (iso=='JPY') { symbol='¥'; }
        else if (iso=='INR') { symbol='₹'; }
        else if (iso=='KRW') { symbol='₩'; }
        else if (iso=='EGP') { symbol='£'; }
        else if (iso=='SGD') { symbol='$'; }
        
        return symbol; 
    }

    public list<Partner_Discount__c> getpartnerDiscount(){
        partnerDiscount = [Select Id,Category__c,Discount__c,Type__c from Partner_Discount__c where account__c =:currentUserAccountId];
        return partnerDiscount;
    }
    
    public list<PureCloud_Partner_Margin__c> getpureCldMargins(){
        pureCldMargins = [Select Id,Margin_Type__c,Percent__c,From_Date__c,To_Date__c from PureCloud_Partner_Margin__c where Account__c =:currentUserAccountId];
        return pureCldMargins;
    }
    
    public void partnerRebate(User usr){
                                                
        partnerRebateMap = new Map<String,List<PartnerRebate>>();

        List<PartnerRebate> rebateList;
        System.debug('usr.Contact.AccountId = ' + usr.Contact.AccountId);   
        for(Partner_Rebate__c rebate : [SELECT id, Rebate_Name__c,Rebate_Year__c,Start_Date__c,End_Date__c,Earned_Genesys_Care_Amount__c,
                                                Earned_License_Amount__c,Earned_SaaS_Amount__c,Publish_Earned_Amounts_to_Partner_Portal__c,
                                                Amount__c,License_Amount__c,SaaS_Amount__c,Agree_Disagree_Flag__c,CurrencyIsoCode,
                                                Published_to_Partner_Portal__c
                                                FROM  Partner_Rebate__c 
                                                WHERE Partner_Name__c = :usr.Contact.AccountId
                                                AND Agree_Disagree_Flag__c = true ORDER BY Rebate_Year__c ASC]){
        
            String rebateYear = rebate.Rebate_Year__c;
            String rebateName = rebate.Rebate_Name__c;
            selectedRebateYear = rebateYear;
            
            Decimal totalActualGenesysRebate = 0; 
            Decimal totalActualLicenseRebate = 0;
            Decimal totalActualSaaSRebate = 0;
            Decimal totalTargetGenesysRebate = 0;
            Decimal totalTargetLicenseRebate = 0;
            Decimal totalTargetSaaSRebate = 0;
            Decimal totalEarnedGenesysRebate = 0;
            Decimal totalEarnedLicenseRebate = 0;
            Decimal totalEarnedSaaSRebate = 0;
            Decimal solutionMultiplier = 0;
                                                    
            if(partnerRevenueMap.get(selectedRebateYear) != null){
                //totalActualGenesysRebate = chartRecord(partnerRevenueMap.get(selectedRebateYear)[4].totalRevenue); 
                //totalActualLicenseRebate =  chartRecord(partnerRevenueMap.get(selectedRebateYear)[3].totalRevenue);
                //totalActualSaaSRebate =  chartRecord(partnerRevenueMap.get(selectedRebateYear)[5].totalRevenue);
                totalActualGenesysRebate = chartRecord(partnerRevenueMap.get(selectedRebateYear).get('Revenue - Maintenance').pureEngage +
                                                        partnerRevenueMap.get(selectedRebateYear).get('Revenue - Maintenance').pureConnect+
                                                        partnerRevenueMap.get(selectedRebateYear).get('Revenue - Maintenance').pureCloud); 
                totalActualLicenseRebate =  chartRecord(partnerRevenueMap.get(selectedRebateYear).get('Revenue - License').pureEngage +
                                                        partnerRevenueMap.get(selectedRebateYear).get('Revenue - License').pureConnect +
                                                        partnerRevenueMap.get(selectedRebateYear).get('Revenue - License').pureCloud);
                totalActualSaaSRebate =  chartRecord(partnerRevenueMap.get(selectedRebateYear).get('Revenue - Cloud').pureEngage+
                                                    partnerRevenueMap.get(selectedRebateYear).get('Revenue - Cloud').pureConnect+
                                                    partnerRevenueMap.get(selectedRebateYear).get('Revenue - Cloud').pureCloud);
                solutionMultiplier = solutionMultiplierToYr.get(selectedRebateYear);
            }

            if(rebate.Published_to_Partner_Portal__c == true){
                totalTargetGenesysRebate = chartRecord(rebate.Amount__c);
                totalTargetLicenseRebate = chartRecord(rebate.License_Amount__c); 
                totalTargetSaaSRebate = chartRecord(rebate.SaaS_Amount__c); 
            }
            
            if(rebate.Publish_Earned_Amounts_to_Partner_Portal__c == true){
                totalEarnedGenesysRebate = chartRecord(rebate.Earned_Genesys_Care_Amount__c);
                totalEarnedLicenseRebate = chartRecord(rebate.Earned_License_Amount__c); 
                totalEarnedSaaSRebate = chartRecord(rebate.Earned_SaaS_Amount__c); 
            }
            rebateList = new List<PartnerRebate>();
            if(totalTargetGenesysRebate <= 0){
               totalActualGenesysRebate = 0;                                         
            }
            rebateList.add(new PartnerRebate(rebate.Id, 'Genesys Care Rebate', rebateYear, totalActualGenesysRebate,totalTargetGenesysRebate,totalEarnedGenesysRebate,rebateName,rebate.Start_Date__c,rebate.End_Date__c,rebate.CurrencyIsoCode, rebate.Published_to_Partner_Portal__c, rebate.Publish_Earned_Amounts_to_Partner_Portal__c, 0));
            rebateList.add(new PartnerRebate(rebate.Id,'License Rebate', rebateYear, totalActualLicenseRebate,totalTargetLicenseRebate,totalEarnedLicenseRebate, rebateName,rebate.Start_Date__c,rebate.End_Date__c,rebate.CurrencyIsoCode, rebate.Published_to_Partner_Portal__c, rebate.Publish_Earned_Amounts_to_Partner_Portal__c, solutionMultiplier));
            rebateList.add(new PartnerRebate(rebate.Id,'SaaS Rebate', rebateYear, totalActualSaaSRebate,totalTargetSaaSRebate,totalEarnedSaaSRebate, rebateName,rebate.Start_Date__c,rebate.End_Date__c,rebate.CurrencyIsoCode, rebate.Published_to_Partner_Portal__c, rebate.Publish_Earned_Amounts_to_Partner_Portal__c, 0));

            partnerRebateMap.put(rebateYear,rebateList);
        }
    }
    
    private Decimal chartRecord(Decimal amount){
        Decimal totalRebate = amount == null ? 0 : amount;  
        return totalRebate;
    }
    
    public List<PartnerRebate> getRebate(){
        return partnerRebateMap.get(selectedRebateYear);
    }
    
    public List<SelectOption> getRebateYears(){
        
        List<String> years = new List<String>(partnerRebateMap.keySet());
        years.sort();
        
        List<SelectOption> options = new List<SelectOption>();
        // for(String year : partnerRebateMap.keySet()){
         
        for(Integer i=years.size(); i>0; i--){
            options.add(new SelectOption(years[i-1],years[i-1]));
        }
        return options;
    }
    
    // Wrapper class Partner Rebate
    public class PartnerRebate{  
        public String recordId {get; set;}    
        
        public String type {get; set;}   
        public Decimal totalActualRebate{ get; set; }
        public Decimal totalTargetRebate{ get; set; } 
        public String rebateName{get; set;}
        public String currencyCode{get; set;}  
        public Date startDate{get; set;} 
        public Date endDate{get; set;} 
        
        // **** RAO -- Added fields for Earned Rebate
        public Decimal totalEarnedRebate{ get; set; } 
        public Boolean publishEarnedRebate {get; set;}
        public Boolean publishTargetRebate {get; set;}
        public Boolean earnedRebateExpired {get; set;}
        public Decimal solutionMultiplier {get; set;}
        public Decimal totalActualRebateForGraph {get; set;}
        
        // **** RAO -- Modified constructor for passing Earned Rebate fields
        public PartnerRebate(String recordId, String type, String rebateYear, Decimal totalActualRebate, Decimal totalTargetRebate, Decimal totalEarnedRebate, String rebateName,Date startDate,
                                Date endDate, String currencyCode, Boolean publishTargetRebate, Boolean publishEarnedRebate,
                                Decimal solutionMultiplier){ 
            this.recordId = recordId;
            this.type = type; 
            this.totalActualRebate = totalActualRebate;
            this.totalTargetRebate = totalTargetRebate;
            this.rebateName = rebateName; 
            this.startDate = startDate; 
            this.endDate = endDate;
            this.currencyCode= currencyCode;
            // **** RAO -- new fields for Earned Rebate
            this.totalEarnedRebate = totalEarnedRebate;
            this.publishTargetRebate = publishTargetRebate;                                    
            this.publishEarnedRebate = publishEarnedRebate;
            this.solutionMultiplier = solutionMultiplier;   
            this.totalActualRebateForGraph = totalActualRebate + solutionMultiplier;

                                    
            Integer yearSelected = Integer.valueOf(rebateYear);
            Integer intDays =  Date.newInstance(yearSelected + 1, 1, 1).daysBetween(Date.today());
            if( (Date.isLeapYear(yearSelected) && intDays > 366) || (!Date.isLeapYear(yearSelected) && intDays > 365) )
                earnedRebateExpired = true;
            else
                earnedRebateExpired = false;

                                                
        }
    }
    
   
    public void getRebateContents(Boolean isDesignatedContact, Id AccId,String userRegion) {
        
        String contentfields = 'Id,ContentDocumentId,Description,Title,ContentSize,'
                              +'Legacy_Author__c,CreatedBy.Name,LastModifiedDate,Content_Type__c,Services_Programs__c,Region__c,Account__c';
        String internalUsage = 'Partners';
        String contentType = '';
        /*
        if(userRegion != '')  {
            //To Check condition for Rebate Record
            if(isDesignatedContact) {
                List<ContentVersion> rebateContentList = new List<ContentVersion>();
                contentType = 'Rebate Record';
                rebateContentList = Database.query('SELECT ' + contentfields + ' FROM ContentVersion where ((Account__c =: AccId and Region__c =: userRegion) or (Account__c = null and Region__c =: userRegion)) and Content_Type__c =: contentType and Internal_and_Partner_Usage__c includes (\'' +internalUsage +'\')' + 'order by lastmodifieddate desc');
                rebateContents = new List<ContentDocWrapper>();
                for (ContentVersion cv : rebateContentList) { 
                    rebateContents.add(new ContentDocWrapper(cv));
                }
            }
        } */
    }
    
    
    
     // Wrapper class
    public class PieWedgeData {

        public String name { get; set; }
        public Double data { get; set; }

        public PieWedgeData(String name, Double data) {
            this.name = name;
            this.data = data;
        }
    } 
    
    
    public void populateNPSList (User usr) {
        surveyList = new List<Survey_Response__c>();
        npsData = new List<PieWedgeData>();
        system.debug('USER ACCOUNT ID: ' + usr.AccountId);
        surveyList = [select id,Name,NPS_Recommend_Rating__c,Contact__r.Name,Survey_Type__c,
                      Partner_Response_Type__c,Deployment_Type1__c,End_User_Account_Name__c
                      from Survey_Response__c
                      where Survey_Type__c = 'Relationship' and Partner_Account__c =: usr.AccountId];
        system.debug('SURVEY LIST SIZE: ' + surveyList.size());
        if(!surveyList.isEmpty()) {
            calculateNPS();   
            calculateNpsScore();
        }
    }
    
    public void calculateNPS() {
        for(Survey_Response__c sr : surveyList) {
            if(sr.Partner_Response_Type__c == 'Detractor') {
                detractorCount++;           
            }
            else if(sr.Partner_Response_Type__c == 'Promoter') {
                PromoterCount++;            
            }
            else if(sr.Partner_Response_Type__c == 'Passive') {
                PassiveCount++;         
            }
        }
        if(detractorCount > 0.0)
            npsData.add(new PieWedgeData('Detractor', detractorCount));
        if(PromoterCount > 0.0)
            npsData.add(new PieWedgeData('Promoter', PromoterCount));
        if(PassiveCount > 0.0)
            npsData.add(new PieWedgeData('Passive', PassiveCount));
        System.debug('npsData-->'+npsData);
    }
    
    public void calculateNpsScore() {
        npsScore = 0;
        System.debug('PromoterCount-->'+PromoterCount);
        System.debug('detractorCount-->'+detractorCount);
        System.debug('surveyList.size()-->'+surveyList.size());
        if(PromoterCount+detractorCount > 0.0) {
            npsScore =  Integer.valueOf((PromoterCount/(PromoterCount+detractorCount+PassiveCount)*100) - ((detractorCount/(PromoterCount+detractorCount+PassiveCount)*100)));
        }
        System.debug('npsScore-->'+npsScore);
    }

    public PageReference refreshCCBD(){
        User user = [SELECT AccountId,Contact.Account.TM_Acc_Country_Region__c,Contact.Account.Partner_Tier__c,ContactId,
                        Contact.Designated_Partner_Contact__c, Contact.Account.PartnerType__c,Contact.Account.Country__r.Region__c  
                        FROM User WHERE Id =: UserInfo.getUserId()];
        initCasesClosedByDefault(user, selectedCCBDPeriod);
        return null;
    }
    
    public void initCasesClosedByDefault(User usr, String selectedCCBDP){
        CCBDPeriods = new List<SelectOption>();
        // 001U000000VPjdzIAD
        String accId = usr.Contact.AccountId;
        System.debug('accId = ' + accId);
        for(Cases_Closed_By_Default_Header__c ccdbHeader :  [SELECT Period__c FROM Cases_Closed_By_Default_Header__c WHERE Partner_Account__c = :accId Order BY Year__c DESC, Period_Order__c DESC]) {
            CCBDPeriods.add(new SelectOption(ccdbHeader.Period__c,ccdbHeader.Period__c));       
        }
        if(CCBDPeriods.size() > 0 && selectedCCBDP == '')
            selectedCCBDPeriod = CCBDPeriods[0].getValue();

        CCBDHeaders = new List<CCBDGaugeData>();
        //for(Cases_Closed_By_Default_Header__c ccbdRecord : [SELECT Period__c, Closed_By_Default__c, YTD_Closed_By_Default__c FROM Cases_Closed_By_Default_Header__c WHERE (Account__c = :accId OR Account__c = :accId.substring(0,15)) AND Period__c = :selectedCCBDPeriod]){
        for(Cases_Closed_By_Default_Header__c ccbdRecord : [SELECT Period__c, Closed_By_Default__c, YTD_Closed_By_Default__c FROM Cases_Closed_By_Default_Header__c WHERE Partner_Account__c = :accId AND Period__c = :selectedCCBDPeriod]){
               // CCBDHeaders.add(new CCBDGaugeData(ccbdRecord.Period__c, (ccbdRecord.Closed_By_Default__c * 100).intValue(),  (ccbdRecord.YTD_Closed_By_Default__c * 100).intValue()));         
               CCBDHeaders.add(new CCBDGaugeData(ccbdRecord.Period__c, 
                                                 ccbdRecord.Closed_By_Default__c != NULL ? (ccbdRecord.Closed_By_Default__c).intValue() : 0,  
                                                 ccbdRecord.YTD_Closed_By_Default__c != NULL ? (ccbdRecord.YTD_Closed_By_Default__c).intValue() : 0 
                                                ) 
                              );         
        }   
        
    }
    
    public class CCBDGaugeData {
        public String name { get; set; }
        public Integer count { get; set; }
        public Integer ytdCount { get; set; }
        public CCBDGaugeData(String name, Integer count, Integer ytdCount) {
            this.name = name;
            this.count = count;
            this.ytdCount = ytdCount;
        }
    }
}