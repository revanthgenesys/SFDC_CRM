public class UpdateRampToCCDB {
     public static void updateRampEXTReasonToCCDB(List<GCR__c> newGCRList, Map<Id, GCR__c> oldMap)
    {
        system.debug('coming');
        Set<Id> set_GCRIds = new Set<Id>();
        map<id,GCR__c> mapofGCRandOpp = new map<id,GCR__c>();
        list<Subscription__c> ccdbList = new list<Subscription__c>();
        for(GCR__C objGCR : newGCRList){
            if(objGCR.status__C == '10-Completed' && objGCR.Opportunity__c != null)
            {
            	mapofGCRandOpp.put(objGCR.Opportunity__c, objGCR);    
            }	//mapofGCRandOpp.put(objGCR.Opportunity__c, objGCR);
        }
        for(Subscription__c ccdbObj : [select id,Opportunity_LookUp__c,Select_Ramp_Extension_Reason__c from Subscription__c where Opportunity_LookUp__c in: mapofGCRandOpp.keySet()])
        {
            Subscription__c CCDB = new Subscription__c();
            CCDB.Id = ccdbObj.id;
            CCDB.Select_Ramp_Extension_Reason__c = mapofGCRandOpp.get(ccdbObj.Opportunity_LookUp__c).Ramp_Extension_Reason__c;
            ccdbList.add(CCDB);
        }
        system.debug('ccdbList.size()'+ccdbList.size());
        if(ccdbList.size()>0)
        	update ccdbList;
        
    }


}