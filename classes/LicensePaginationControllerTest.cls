/* Developed By : Thiyagaraj Vijayakumar
 * Created Date: 7th Aug 2018 
 * Version 1.0 : NewPagination adds coverage to LMSHybridLicenseController, LicensePaginationController  
*/
@isTest(SeeAllData=true)
public class LicensePaginationControllerTest{
    static testMethod void NewPagnation(){
       Set<String> perpParts = new Set<String>();
        Test.startTest();
            List<LicenseSummarywrapper> summaryData = LMSHybridLicenseController.fetchSubscriptionParts('CIC',perpParts,false);
            Set<String> subscriptionParts = new Set<String>();
            for(Product2 p : [SELECT Id, Name, APN_Number__c, IsActive FROM Product2 where Name like '%Sub' and IsActive=true and OfferingType__c='PureConnect Subscription' limit 10])
                subscriptionParts.add(p.APN_Number__c);
            Map<String, Set<License_Translations__c>> temp = LMSHybridLicenseController.getSubscriptionTranslations('CIC', subscriptionParts);
            LicensePaginationController l = new LicensePaginationController();
            l.sourceKey = 'xAdasd';
            l.summaryLst = summaryData;
            Boolean hasNext = l.hasNext;
            Boolean hasPrevious = l.hasPrevious;
            l.first();
            l.next();
    }
}