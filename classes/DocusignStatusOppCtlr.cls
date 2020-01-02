global with sharing class DocusignStatusOppCtlr {
    
    global static String docuId{get;set;}
    
    global DocusignStatusOppCtlr(ApexPages.Standardcontroller controller){
        Opportunity opp = (Opportunity)controller.getRecord();
        docuId =  opp.id;    
    }
}