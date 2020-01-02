public class refreshTokenAllocation {
    
    public static void refreshTokenAllocationPackageMethod(ID taID,date refreshdate)
    {
        Id OrderId;
        list<Token_Allocations__c> ta = new list<Token_Allocations__c>();
        ta = [select id,Account__c,Token_Offering_Type__c,Refresh_date__c,Order__c,Order__r.Original_Parent_Order1__c,Order__r.name,Product_Group__c,Token_Status__c,Product__c,Product_Group_Item__c,Service_Contract_No__c,
              Tokens__c,Allocation_Type__c from Token_Allocations__c where id = :taID];
        Token_Allocations__c taclone =  ta[0].clone(false,false);
        //taclone.Refresh_date__c = ta[0].Refresh_date__c.addYears(1);
        taclone.Refresh_date__c = refreshdate;
        if(ta[0].Order__c!=null){
        OrderId = taclone.Token_Offering_Type__c.contains('Cloud') || taclone.Order__r.name.contains('PS') || taclone.Order__r.name.contains('PureSuccess')? ta[0].Order__r.Original_Parent_Order1__c : ta[0].Order__c;
        taclone.Tokens__c =  taclone.Allocation_Type__c == 'Subscription Token' ? calculateAvailableTokens(OrderId) : ta[0].Tokens__c;}
        else
        {
        taclone.Tokens__c =ta[0].Tokens__c;
        }
        Util.Bypass_Trigger_Chk = true;
        if(taclone.Tokens__c>0)
        {
            insert taclone;     
        }
        system.debug('taclone'+taclone);
        packageservices(taID);
        ta[0].Token_Status__c = 'Expired';
        update ta;
    }
    public static void packageservices(ID taID){
         list<Token_consumption__c> tac = new list<Token_consumption__c>();
        tac = [select id,name,Package_Services__c,Package_Services__r.Status__c,Product__c,Token_Allocation__c,Tokens__c from Token_consumption__c where Token_Allocation__c=:taID];
        if(tac[0].Package_Services__c!=null){
           list<Package_Services__c> ps = new list<Package_Services__c>();
        ps = [select id,Status__c from Package_Services__c where id=:tac[0].Package_Services__c];
            ps[0].Status__c='Expired';   
            update ps;
        } 
    }
    public static Decimal calculateAvailableTokens(ID orderID)
    {
        Decimal decACVTokenValue=0;
        Decimal decConvertToUSD=0;
        system.debug('orderID'+orderID);
        BigMachines__Quote__c quote = [select id,Order__c,Order_Type__c,Annual_Contract_Value__c,Offering_Type__c,Annual_Contract_Value_1__c,
                                       Annual_Contract_Value_2__c,New_Price_Book__c,CurrencyIsoCode,Token_Value__c,Annual_Contract_Value_Change__c,Total_Tokens_Change__c 
                                       from BigMachines__Quote__c where Order__c =:orderID];
        Decimal decACVInUSD = 0;
        
        if(quote.Offering_Type__c == 'PureCloud' || quote.Offering_Type__c == 'PureEngage Cloud' || quote.Offering_Type__c == 'PureConnect Cloud' || quote.Offering_Type__c == 'Business Edition')
        {
            decConvertToUSD = quote.Order_Type__c.contains('Amend')?quote.Annual_Contract_Value_Change__c:quote.Annual_Contract_Value__c;
            decACVInUSD = DDSCloud.converttoUSD(quote.Offering_Type__c, quote.New_Price_Book__c, quote.CurrencyIsoCode, decConvertToUSD);
            decACVTokenValue = QuoteCloudUtil.calculateTokenValue(decACVInUSD, 'Only For ACV', 'NA');   
            system.debug('decACVTokenValue'+decACVTokenValue);
        }
        else if(quote.Offering_Type__c == 'PureConnect Subscription' || quote.Offering_Type__c == 'PureEngage Subscription')
        {
            decACVInUSD = DealQualificationApprovalUtil.convertCurrency(Double.valueOf(quote.Annual_Contract_Value_1__c), quote.CurrencyIsoCode);
            decACVTokenValue = QuoteCloudUtil.calculateTokenValue(decACVInUSD, 'Only For ACV', 'NA');   
            system.debug('decACVTokenValue'+decACVTokenValue);
            
        }
        return decACVTokenValue;   
    }
    }