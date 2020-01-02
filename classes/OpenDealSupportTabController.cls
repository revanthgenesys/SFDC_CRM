public class OpenDealSupportTabController {

    public boolean dsListVisible{get;set;}
    private list<Deal_Support__c> recentDS = new list<Deal_Support__c>();

    public OpenDealSupportTabController(ApexPages.StandardSetController controller) {
        dsListVisible = false;
    }
    
    public list<Deal_Support__c> getrecentDS(){
        //recentView = new list<RecentlyViewed>();
        //recentView = [SELECT Id, Name FROM RecentlyViewed  WHERE Type ='Opportunity' ORDER BY LastViewedDate DESC];
        set<Id> recentDSIDs = new set<Id>();
        for(RecentlyViewed rvRec:[SELECT Id, Name FROM RecentlyViewed  WHERE Type ='Deal_Support__c' ORDER BY LastViewedDate DESC]){
            recentDSIDs.add(rvRec.Id);
        }
        if(recentDSIDs.size()>0){
            recentDS = [Select Id,Name from Deal_Support__c where Id IN:recentDSIDs];
        }
        return recentDS;
    }

}