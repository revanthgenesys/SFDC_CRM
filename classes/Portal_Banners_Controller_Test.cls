@isTest
public class Portal_Banners_Controller_Test {

    public static testmethod void testMethods(){
        List<Partner_Portal_Announcement__c> recList = new List<Partner_Portal_Announcement__c>();
        for(Integer i=0;i<5;i++){
            Partner_Portal_Announcement__c pRec = new Partner_Portal_Announcement__c();
            pRec.name = 'Test Banner'+ i;
            pRec.type__c = 'Banner';
            pRec.title__c = 'Test Title';
            pRec.description__c = ' Test Description';
            recList.add(pRec);
        }
        insert recList;
        
        //Call the Controller Constructor
        Portal_Banners_Controller pBanner = new Portal_Banners_Controller();
    }
}