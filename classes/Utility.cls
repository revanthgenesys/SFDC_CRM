/*
    Class : TestUserAdminService 
    Description : Class is used to have a collection of utility functions that could be used across the application.
    Developed by : Chad VanHorn
    CreatedDate : 2013.01.17
*/
public with sharing class Utility {
    
	public static Boolean IsSandboxEnvironment()
	{
		String url = System.Url.getSalesforceBaseUrl().getHost();
        boolean isSandbox = (Pattern.matches('(.*\\.)?cs[0-9]*(-api)?\\..*force.com', url)); 
        System.debug('IsSandbox: ' + isSandbox);
		return isSandbox;
	}
    
    public static String GetRequiredGeneralCustomSetting(string customSettingKey)
    {
        String value = GetGeneralCustomSetting(customSettingKey);
        if (String.isBlank(value))
        {
            throw new ApplicationException('The value for custom setting ' + customSettingKey + ' cannot be found.');
        }
        return value;
    }
    
    public static String GetGeneralCustomSetting(string customSettingKey)
    {
        General_Custom_Settings__c setting = General_Custom_Settings__c.getValues(customSettingKey);
        if (setting != null)
        {
       		return setting.Value__c;
        }
        else
        {
            return '';
        }
    }
    
    public static Boolean IsSyncedAccountType(string type)
    {
        Set<string> validTypes = new Set<string>();
        validTypes.add('Partner');
        validTypes.add('Consultant');
        validTypes.add('Customer');
        validTypes.add('Alliance');
        
        return validTypes.contains(type);        
    }
}