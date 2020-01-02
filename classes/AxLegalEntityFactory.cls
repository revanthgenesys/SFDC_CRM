@isTest
public class AxLegalEntityFactory {
    public static AX_Legal_Entity__c CreateDefaultEntity()
    {
		return new AX_Legal_Entity__c(Name = 'II Administration', AX_ID__c = '110', CurrencyIsoCode = 'USD', Active__c = true, Display_name__c = 'Interactive Intelligence US');        
    }
    
    public static AX_Legal_Entity__c CreateCANEntity()
    {
		return new AX_Legal_Entity__c(Name = 'II Canada', AX_ID__c = '505', CurrencyIsoCode = 'CAD', Active__c = true, display_name__c = 'Interactive Intelligence Canada');        
    }
    
    public static AX_Legal_Entity__c CreateGEREntity()
    {
		return new AX_Legal_Entity__c(Name = 'II Germany GmbH', AX_ID__c = '825', CurrencyIsoCode = 'EUR', Active__c = true, display_name__c = 'Interactive Intelligence Europe');        
    }
}