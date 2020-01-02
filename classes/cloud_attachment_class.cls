public class cloud_attachment_class {

    public ID recordID;
    public Set<ID> set_OfLagacyID;
    public String objectName {
        get;
        set;
    }
    public List < Cloud_Attachment__c > atmtList;
    private ApexPages.StandardController sController;

    public cloud_attachment_class(ApexPages.StandardController controller) {
        sController = controller;
        set_OfLagacyID = new Set<Id>();
        recordID = ApexPages.CurrentPage().getParameters().get('id');
        if (recordID != null) {
            objectName = recordID.getSObjectType().getDescribe().getName();
        }
         
         System.debug(objectName);
        if (objectName == 'Account') {
            //Account acnt = [Select Legacy_Angel_ID__c from Account where id =: recordID];
            //lagacyID = acnt.Legacy_Angel_ID__c;
            for(SourceAccounts__c eachSourceAccount : [SELECT SourceAccountId__c FROM SourceAccounts__c WHERE Account__c =:recordID]){
                set_OfLagacyID.add(eachSourceAccount.SourceAccountId__c);                
            }                   
        
        } else if (objectName == 'Opportunity') {
            Opportunity opp = [Select ININ_ID__c from Opportunity where id =: recordID];
            set_OfLagacyID.add(opp.ININ_ID__c);
        } else if (objectName == 'Case') {
            Case cse = [Select LegacyID__c from Case where id =: recordID];
            set_OfLagacyID.add(cse.LegacyID__c);
        } else if (objectName == 'Contact') {
            Contact cnt = [Select LegacyId__c from Contact where id =: recordID];
            set_OfLagacyID.add(cnt.LegacyId__c);
        } else if (objectName == 'Lead') {
            Lead lead = [Select LegacyId__c from Lead where id =: recordID];
            set_OfLagacyID.add(lead.LegacyId__c);
        } else if (objectName == 'RFP_Support_Request__c') {
            RFP_Support_Request__c rr = [Select Legacy_ID__c from RFP_Support_Request__c where id =: recordID];
            set_OfLagacyID.add(rr.Legacy_ID__c);
        }



        atmtList = new List < Cloud_Attachment__c > ();
    }

    public List < Cloud_Attachment__c > getAtmtList() {
        List < Cloud_Attachment__c > atchmentResults = new List < Cloud_Attachment__c > ();
        if (!set_OfLagacyID.isEmpty()) {
            atchmentResults = [SELECT Id, Attachment_Name__c, Attachment_ID__c, Created_By__c, Created_Date__c, 
                               Parent_Id__c FROM Cloud_Attachment__c WHERE Parent_Id__c IN: set_OfLagacyID AND Is_Deleted__c = false];
        }
        return atchmentResults;
    }
}