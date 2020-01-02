/************************************************************************************
Purpose : Utility class for methods related to PureCloud Project object
Written By : Ranjith Punneli
Test Classes : PureCloudProjectTest
*************************************************************************************/

public without sharing class PureCloudProjectUtil {

    public static Set<String> getServicePackagesPicklistVals()  {
        Set<String> set_ServicePackages = new Set<String>();
        DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('PureCloud_Trial__c').getDescribe().fields.getMap().get('Service_Packages__c').getDescribe();
        List<Schema.PicklistEntry> list_ServicePackages = fieldResult.getPicklistValues();
           
        for(Schema.PicklistEntry plSrvPackage : list_ServicePackages)  {
            set_ServicePackages.add((plSrvPackage.getValue().toLowerCase()));
        }   
        return set_ServicePackages;
    }
}