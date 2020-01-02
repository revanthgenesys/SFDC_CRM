global class Nro_OrderName_AutoNumber{
    webservice static Decimal getNumber(String test)
    {
     Global_Setting__c obj = new Global_Setting__c ();
     obj = Global_Setting__c.getInstance('NRO_AN');
     Decimal initString = Decimal.valueof(obj.Id__c);
     Decimal finalString = initString + 1;
     obj.Id__c = String.valueof(finalString);
     update obj; 
     return finalString;
    }
 }