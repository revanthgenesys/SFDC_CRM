/*
Created By: Mukunthan Koothan
Created On: 01-FEB-2018
Purpose: Controller behind PartnerACVDetails VF page.
*/

public class PartnerACVDetailsController {
    
    public string selectedYear{get;set;}
    private string recordTpId;
    private string currUserAccId;
    public string curcyCd{get;set;}
    private List<opportunity> optyList = new list<opportunity>();
    private List<DatedConversionRate> datedCurrencies = new List<DatedConversionRate>();
    private list<string> TNnPostYrs = new list<string>();
    public boolean displayPreTwentyEighteen{get;set;}
    private string GenOptyRT;
    public List<DatedConversionRate> getdatedCurrencies(){
        return datedCurrencies;
    }
    
    public PartnerACVDetailsController(){
        selectedYear = ApexPages.currentPage().getParameters().get('syr');
        recordTpId = ApexPages.currentPage().getParameters().get('recTp');
        currUserAccId = ApexPages.currentPage().getParameters().get('uAccId');
        curcyCd = ApexPages.currentPage().getParameters().get('curcyCd');
        
        datedCurrencies = [SELECT Id, IsoCode, ConversionRate, nextStartDate, startDate from DatedConversionRate ORDER BY IsoCode, StartDate];
        TNnPostYrs = (Global_Setting__c.getInstance('Performance Dash 2019').Information__c).split(',');
        GenOptyRT = Global_Setting__c.getinstance('GEN - Opportunity Record Type').ID__c;
        displayPreTwentyEighteen = false;
    }
    
    public list<opportunity> getoptyList(){
        try{
            if(!TNnPostYrs.contains(selectedYear)){
                for(opportunity opty:[Select Id,ACV_Subscription_Only__c,Closedate,CurrencyIsoCode,Account.Name,Closing_Fiscal_Quarter__c,BusinessPartner__r.CurrencyIsoCode
                                                from Opportunity where Bookings_Validation_Flag__c = true
                                                AND Lines_of_Businesses__c='PureCloud' AND BusinessPartner__c =: currUserAccId AND 
                                                BusinessPartner__r.Partner_Offering_Type__c includes ('PureCloud','PureCloud Reseller') AND 
                                                recordtypeid NOT IN (:recordTpId)
                                                order by CloseDate asc]){
                    if(string.valueof(opty.Closedate.year()) == selectedYear){
                        System.Debug('1--->'+opty.ACV_Subscription_Only__c);
                        opty.ACV_Subscription_Only__c = convertCurrencyToSpecDate(opty.ACV_Subscription_Only__c, opty.CurrencyIsoCode, curcyCd,opty.CloseDate);
                        System.Debug('2--->'+opty.ACV_Subscription_Only__c);
                        optyList.add(opty);
                    }
                }
                System.Debug('optyList--->'+optyList);
                /*for(opportunity op:optyList){
                    op.ACV_Subscription_Only__c = CurrencyConversionUtil.convertCurrency(op.ACV_Subscription_Only__c, op.CurrencyIsoCode , op.BusinessPartner__r.CurrencyIsoCode);
                }
                System.Debug('optyList2--->'+optyList);*/
            }
            else{
                for(Opportunity opty:[select id, ACV_Subscription_Only__c, Name,account.name,CurrencyIsoCode,CloseDate from opportunity where BusinessPartner__c = :currUserAccId AND StageName = '6.Closed' 
                                        AND recordtypeid =:GenOptyRT AND Win_Loss_Status__c = 'Won' 
                                        AND CALENDAR_YEAR(closedate) =:integer.valueof(selectedYear) AND Lead_Offer__c != NULL AND Lead_Offer__c like '%PureCloud%']){
                    opty.ACV_Subscription_Only__c = convertCurrencyToSpecDate(opty.ACV_Subscription_Only__c, opty.CurrencyIsoCode, curcyCd,opty.CloseDate);
                    optyList.add(opty);
                }
                displayPreTwentyEighteen = true;
            }
            return optyList;
        }
        catch(exception e){
            System.Debug('Error Message--->'+e.getMessage()+';'+e.getLineNumber());
            return null;
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