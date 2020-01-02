public class MyOutputTextController 
{
    public Decimal decCurrencyValue {get; set;}
    public Boolean blnIsHideDecimals {get; set;}
    public String strCurrencyCode {get; set;}
    
    public String getFormattedValue()
    {
        if(decCurrencyValue == null)
            decCurrencyValue = 0;
        if(strCurrencyCode == null)
            strCurrencyCode = '';
        
        String strThousandSeparator,strDecimalSeparator;
        Integer intDecimalPlaces;
        
        if(strCurrencyCode == 'BRL')
        {
            strThousandSeparator = '.';
            strDecimalSeparator = ',';
        }
        else
        {
            strThousandSeparator = ',';
            strDecimalSeparator = '.';
        }
        
        if(blnIsHideDecimals)
            intDecimalPlaces = 0;
        else
            intDecimalPlaces = 2;
        
        String strAmount = doFormatting(decCurrencyValue,intDecimalPlaces,strThousandSeparator,strDecimalSeparator);
        return (getCurrencySymbolFromIso(strCurrencyCode) + ' ' + strAmount);
    }
    
    public static String getCurrencySymbolFromIso(String Iso) 
    {
         String currencySymbol = 
           ('USD' == Iso ? '$' : 
           ('CAD' == Iso ? '$' : 
           ('EUR' == Iso ? '€' : 
           ('GBP' == Iso ? '£' : 
           ('JPY' == Iso ? '¥' : 
           ('AUD' == Iso ? '$' : 
           ('BRL' == Iso ? 'R$' : 
           ('CHF' == Iso ? 'Fr' : 
           ('NZD' == Iso ? '$' : 
           ('VEF' == Iso ? 'Bs' : 
           ('ZAR' == Iso ? 'R' : 
           Iso)))))))))));
           return currencySymbol;
    }
    
    public static String doFormatting(Decimal val, integer dec, String tSep, String dSep) 
    {
        String s, tmp;
        Integer i = 4 + dec;
     
        // If the number of decimals is zero (0)... prevents the first 1000s seperator from being set at the 4th.
        if(dec==0){
            i--;
        }
     
        s = val.setScale(dec).toPlainString().replace(tSep, dSep);
        while(s.length() > i) {
            tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
            s = tmp;
            i += 4;
        }
     
        // If the number is negative and has a number non-decimal digits divisible by 3, it prevents putting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
        if (s.substring(0,1) == '-') {
            if (s.substring(1,2) == tSep) {
                s = '-' + s.substring(2);
            }
        }
     
        return s;
    }
}