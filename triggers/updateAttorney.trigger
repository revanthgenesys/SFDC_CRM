trigger updateAttorney on GCR__c (before insert,before update) {
    Map<String,Attorney_User_Detail__c> attorneyNameDetailMap = Attorney_User_Detail__c.getAll();
    
    for(GCR__c GCRObj : Trigger.new){
        if(GCRObj.Attorney_Name__c != null && GCRObj.Attorney_Name__c != ''){
            Attorney_User_Detail__c attorneyUserDetail = attorneyNameDetailMap.get(GCRObj.Attorney_Name__c);
            if(attorneyUserDetail !=null && attorneyUserDetail.Attorney_Id__c!=null && attorneyUserDetail.Attorney_Id__c != ''){
                GCRObj.Assigned_to_Attorney__c = attorneyUserDetail.Attorney_Id__c;
            }
            else{
                GCRObj.Assigned_to_Attorney__c = null;                
            }
        }
        else{
            GCRObj.Assigned_to_Attorney__c = null;                
        }
    }
}