public class PartnerRevenueDetailsController {
    public boolean isSolutionMultiplier {get; set;}  
    public String revenueYear {get; set;}  
    public String revenueType {get; set;} 
    public string revTpPostTE{get;set;} 
    public String accountId {get; set;}
    public string curcyCd{get;set;} 
    public string offeringType {get;set;}
    public string allRevTp{get;set;}
    private string revTp;
    private String userId;
    public boolean displayPostTE{get;set;}
    private list<string> TNnPostYrs = new list<string>();
    private list<opportunity> optyList = new list<opportunity>();
    public list<opportunity> getoptyList(){return optyList;}
    public Account pAccount {get; set;}
    public User pUser {get; set;}
    public string offTp{get;set;}
    private List<DatedConversionRate> datedCurrencies = new List<DatedConversionRate>();
    public List<DatedConversionRate> getdatedCurrencies(){
        return datedCurrencies;
    }

    public List<Partner_EndUser_Data__c> revenueData {get; set;}
    
    public PartnerRevenueDetailsController(){
        try{
            isSolutionMultiplier = false;
            userId = UserInfo.getUserId();
            displayPostTE = false;
            datedCurrencies = [SELECT Id, IsoCode, ConversionRate, nextStartDate, startDate from DatedConversionRate ORDER BY IsoCode, StartDate];
            TNnPostYrs = (Global_Setting__c.getInstance('Performance Dash 2019').Information__c).split(',');
            revenueYear = ApexPages.currentPage().getParameters().get('ry');
            revenueType = ApexPages.currentPage().getParameters().get('rt');
            offeringType = ApexPages.currentPage().getParameters().get('ot');
            accountId = ApexPages.currentPage().getParameters().get('lua');
            curcyCd = ApexPages.currentPage().getParameters().get('ccd');
            offTp = offeringType=='revwisetotal'?'PureEngage; PureConnect; PureCloud':offeringType;
            if(ApexPages.currentPage().getParameters().get('sm') != NULL)
                isSolutionMultiplier = true;
            
            System.Debug('offeringType--->'+offeringType);
            revenueData = new List<Partner_EndUser_Data__c>();
            
            if(isSolutionMultiplier){
            revenueData = [SELECT End_User_Name__c,Product_Name__c,Quarter__c,Revenue_Type__c,Revenue_Year__c, Revenue_Amount__c,CurrencyIsoCode, Solutions_Multiplier__c 
                           FROM Partner_EndUser_Data__c 
                           WHERE Account__c  = :accountId AND Revenue_Year__c = :revenueYear AND Solutions_Multiplier__c != NULL ];
            }
            else{
                if(TNnPostYrs.contains(revenueYear)){
                    displayPostTE = true;
                    string GenOptyRT = Global_Setting__c.getinstance('GEN - Opportunity Record Type').ID__c;
                    string optyQuery1 = 'select id,License_Amount__c,ACV_Subscription_Only__c,Lead_Offer__c, Name,account.name,CurrencyIsoCode,CloseDate from opportunity where BusinessPartner__c =\''+accountId+'\'';
                    string optyQuery2 = ' AND StageName = \'6.Closed\' AND recordtypeid =\''+GenOptyRT+'\' AND Win_Loss_Status__c = \'Won\' AND CALENDAR_YEAR(closedate) ='+integer.valueof(revenueYear);
                    string finaloptyQuery = optyQuery1 + optyQuery2;
                    if(revenueType == 'Total'){
                        allRevTp = 'Revenue - Cloud;Revenue - License';
                        if(offeringType == 'revwisetotal'){
                            finaloptyQuery += ' AND Lead_Offer__c != NULL';
                        }
                        else{
                            finaloptyQuery += ' AND Lead_Offer__c LIKE \'%'+offeringType+'%\'';
                        }
                    }
                    else{
                            //string cldPCld = Global_setting__c.getinstance('Cloud PureCloud').Information__c;
                            string cldPCon = Global_setting__c.getinstance('Cloud PureConnect').Information__c;
                            string cldPEng = Global_setting__c.getinstance('Cloud PureEngage').Information__c;
                            string licPCon = Global_setting__c.getinstance('License PureConnect').Information__c;
                            string licPEng = Global_setting__c.getinstance('License PureEngage').Information__c;

                            if(revenueType == 'Revenue - Cloud'){
                                if(offeringType == 'pureCloud'){
                                    finaloptyQuery += ' AND Lead_Offer__c = \'PureCloud\'';
                                }
                                else if(offeringType == 'pureConnect'){
                                    finaloptyQuery += ' AND Lead_Offer__c IN ('+cldPCon+')';
                                }
                                else if(offeringType == 'pureEngage'){
                                    finaloptyQuery += ' AND Lead_Offer__c IN ('+cldPEng+')';
                                }
                                else{
                                    finaloptyQuery += ' AND Lead_Offer__c IN ('+cldPEng+','+cldPCon+',\'PureCloud\')';
                                }
                            }
                            else{
                                if(offeringType == 'pureEngage'){
                                    finaloptyQuery += ' AND Lead_Offer__c IN ('+licPEng+')';
                                }
                                else if(offeringType == 'pureConnect'){
                                    finaloptyQuery += ' AND Lead_Offer__c IN ('+licPCon+')';
                                }
                                else{
                                    finaloptyQuery += ' AND Lead_Offer__c IN ('+licPCon+','+licPEng+')';
                                }
                            }
                            if(revenueType == 'Revenue - Cloud'){
                                revTpPostTE = 'Booking - Cloud';
                            }else{
                                revTpPostTE = 'Booking - License';
                            }
                    }
                    System.Debug('finaloptyQuery--->'+finaloptyQuery);
                    list<string> cldBookingTp = (Global_setting__c.getinstance('Cloud Booking Type').Information__c).split(',');
                    list<string> licBookingTp = (Global_setting__c.getinstance('License Booking Type').Information__c).split(',');
                    optyList = Database.query(finaloptyQuery);
                    for(Opportunity tnOpty:optyList){
                        if(licBookingTp.contains(tnOpty.Lead_Offer__c)){
                            tnOpty.ACV_Subscription_Only__c = convertCurrencyToSpecDate(tnOpty.License_Amount__c, tnOpty.CurrencyIsoCode, curcyCd,tnOpty.CloseDate);
                        }
                        else{
                            tnOpty.ACV_Subscription_Only__c = convertCurrencyToSpecDate(tnOpty.ACV_Subscription_Only__c, tnOpty.CurrencyIsoCode, curcyCd,tnOpty.CloseDate);
                        }
                    }
                }
                else{
                    string queryString1 = 'SELECT End_User_Name__c,Product_Name__c,Quarter__c,Revenue_Amount__c,Revenue_Year__c,CurrencyIsoCode FROM Partner_EndUser_Data__c WHERE Account__c  =\''+accountId+'\'';
                    string querystring2 = ' AND Revenue_Year__c = \''+revenueYear+'\'';
                    string querystring3;
                    if(revenueType == 'Total'){
                        map<string,Partner_Revenue_Reporting__c> revTypeCS = Partner_Revenue_Reporting__c.getAll();
                        for(string type:revTypeCS.keyset()){
                            if(type != 'Revenue - Cloud Partner'){
                            allRevTp = string.isBlank(allRevTp)?type:allRevTp+';'+type;}
                            revTp = string.isBlank(revTp)?'\''+type+'\'':revTp+',\''+type+'\'';
                        }
                        querystring3 = queryString1 + querystring2 + 'AND Revenue_Type__c IN ('+revTp+')';
                    }
                    else{
                            if(revenueType=='Revenue - Cloud'){
                                string revTpCloud = revenueType+'\', \'Revenue - Cloud Partner';
                                querystring3 = queryString1 + querystring2 + 'AND Revenue_Type__c IN (\''+revTpCloud+'\')';
                            }
                            else{
                                querystring3 = queryString1 + querystring2 + 'AND Revenue_Type__c IN (\''+revenueType+'\')';
                            }
                    }
                    string finalQuery;
                    if(offeringType == 'pureEngage')
                        finalQuery = querystring3 + ' AND (Offering_Type__c = \''+offeringType+'\' OR Offering_Type__c = null OR Offering_Type__c = \'\')';
                    else if(offeringType == 'revwisetotal')
                        finalQuery = querystring3;
                    else
                        finalQuery = querystring3 + ' AND Offering_Type__c =\''+offeringType+'\'';
                    
                    System.Debug('finalQuery--->'+finalQuery);
                    
                    revenueData = Database.query(finalQuery);
                    System.DEbug('revenueData-pre--->'+revenueData);
                    for(Partner_EndUser_Data__c eachRevRec:revenueData){
                        date convDate = Date.newInstance(integer.valueof(eachRevRec.Revenue_Year__c), 1, 1);
                        eachRevRec.Revenue_Amount__c = convertCurrencyToSpecDate(eachRevRec.Revenue_Amount__c,eachRevRec.CurrencyIsoCode,curcyCd,convDate);
                    }
                    System.DEbug('revenueData-post--->'+revenueData);
                }
            }
        }
        catch(exception e){
            System.debug('Error--->'+e.getMessage());
            System.debug('ErrorInLine--->'+e.getLineNumber());
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

}