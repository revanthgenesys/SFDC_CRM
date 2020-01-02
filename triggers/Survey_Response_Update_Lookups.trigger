//Naresh Kumar    02/05/2014    Updating logic to populate fields, now populate using casetext__c field which is case no.
trigger Survey_Response_Update_Lookups on Survey_Response__c(before insert,before update)
{
    Set<String> setCases = new Set<String>();//Set to hold all case nos of the surveys
    for(Survey_Response__c sr:trigger.new){
        if(sr.Casetext__c!=null)
            setCases.add(sr.Casetext__c);//Collect all case ids so that we can query later
    }

    //Now query cases to which these surveys belong
    Map<String,Case> mapCases = new Map<String,Case>();
    for(Case eachCase: [SELECT id,Accountid,contactid, CaseNumber FROM case where CaseNumber IN :setCases])
        mapCases.put(eachCase.CaseNumber, eachCase);    
    //For each Survey response, fill in the account and contact lookups using the case id
    for(Survey_Response__c sr:trigger.new){
        if(mapCases.containsKey(sr.Casetext__c))        {
            sr.Account__c = mapCases.get(sr.Casetext__c).Accountid;
            sr.Contact__c = mapCases.get(sr.Casetext__c).contactid;
            sr.Case__c = mapCases.get(sr.Casetext__c).id;
        }
    }
}