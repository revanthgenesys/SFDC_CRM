global with sharing class DocusignStatusOrderCtlr {
    
    global static String docuId{get;set;}
    
    global DocusignStatusOrderCtlr(ApexPages.Standardcontroller controller){
        Order__c opp = (Order__c)controller.getRecord();
        List<Order__c> lstOrd = [Select id, Opportunity__c from Order__c where Id=:opp.id];
        if(lstOrd.size() > 0){
            docuId = lstOrd[0].Opportunity__c;
        }
    }
}