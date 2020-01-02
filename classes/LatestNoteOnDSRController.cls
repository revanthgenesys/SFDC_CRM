public class LatestNoteOnDSRController 
{
    public String DealSupportId {
        get;
        set
        {
            DealSupportId = value;
            List<Deal_Support__c> list_DS = [SELECT Id,Name,Account__r.Name,Account__c,Opportunity__r.Name,Opportunity__c,
					Request_Type__c,Support_Area__c,Region__c,Subject__c,Createddate,Priority__c,Status__c,Description__c,
                    Solution_Category__c,Product__c,Tool__c,Sub_Region__c,Request_Due_Date__c,
					(SELECT Title,Body,CreatedBy.Name FROM Notes ORDER BY CreatedDate DESC LIMIT 1) FROM Deal_Support__c WHERE Id = :value];
            if(list_DS.size() > 0)
            {
                ObjDS = list_DS[0];
                if(ObjDS.Notes.size() > 0)
                	ObjNote = ObjDS.Notes[0];
            }
            else
                ObjDS = new Deal_Support__c();
            
            if(ObjNote == null)
                ObjNote = new Note();
        }
    }
    public Deal_Support__c ObjDS {get; private set;}
    public Note ObjNote {get; private set;}
}