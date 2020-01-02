trigger FR_FieldUpdate on Case (before insert,before update) {
/******	
MS - 6/13/13 commented out, as a duplicate code. This functionality is implemented in trigger CaseMain and FR_FieldUpdate	

case  cas = trigger.new[0]; 
 
boolean exec=false; 
    //// MS-6/12/13 added case type
    private RecordType recType;
    private String caseType='';
    
    try {
      recType = [SELECT Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND Id= :cas.RecordTypeId];
      caseType = recType.DeveloperName;
    } catch (DMLException e) {
        caseType = '';
    }
    
    if(trigger.isinsert){
        if(cas.Component__c != null){
            Support_product__c sp = [Select id,PM_Owner__c,PM_Owner__r.firstname,PM_Owner__r.lastname,Tier_3_Manager__r.firstname,Tier_3_Manager__r.lastname ,Tier_3_Queue__c from Support_product__c where id=: cas.component__c];
             if(cas.Tier_3_Manager__c == null)
                cas.Tier_3_Manager__c = sp.Tier_3_Manager__r.firstname+ ' '+ sp.Tier_3_Manager__r.lastname;
             if(cas.Tier_3_Queue__c == null)
                cas.Tier_3_Queue__c = sp.Tier_3_Queue__c;
             if(cas.PMOwnerNew__c == null  && cas.Status == 'Open – Product Management'){
                cas.PMOwnerNew__c = sp.PM_Owner__c;
                //cas.PM_Owner__c = sp.PM_Owner__r.firstname + ' ' + sp.PM_Owner__r.lastname;
                }
        } 
    }else {
            if(cas.Support_Product__c != null){
                    Support_product__c sp = [Select id,PM_Owner__c,PM_Owner__r.firstname,PM_Owner__r.lastname,Tier_3_Manager__r.firstname,Tier_3_Manager__r.lastname ,Tier_3_Queue__c from Support_product__c where id=: cas.Support_Product__c];
                    if(cas.Tier_3_Manager__c == null)
                        cas.Tier_3_Manager__c = sp.Tier_3_Manager__r.firstname+ ' '+ sp.Tier_3_Manager__r.lastname;
                    if(cas.Tier_3_Queue__c == null)
                        cas.Tier_3_Queue__c = sp.Tier_3_Queue__c;
                   if(cas.PMOwnerNew__c == null && cas.Status == 'Open – Product Management'){
                        cas.PMOwnerNew__c = sp.PM_Owner__c;
                        //cas.PM_Owner__c = sp.PM_Owner__r.firstname + ' ' + sp.PM_Owner__r.lastname;
                    }
            }
    }

if(trigger.isupdate){
if(cas.Component__c != null){ 
    Support_product__c sp = [Select id,PM_Owner__c,PM_Owner__r.firstname,PM_Owner__r.lastname,Tier_3_Manager__r.firstname,Tier_3_Manager__r.lastname ,Tier_3_Queue__c from Support_product__c where id=: cas.component__c];
    // MS- 6/12/13 if(trigger.old[0].Status == 'Open – Customer Care' && cas.Status == 'Open – Product Management'){
     if(trigger.old[0].RecordTypeId != cas.RecordTypeId && caseType == 'Genesys_Feature_Request_Case') {
                cas.PMOwnerNew__c = sp.PM_Owner__c;
     }
    if(trigger.new[0].Component__c != trigger.old[0].Component__c){
            //if(cas.Tier_3_Manager__c == null)Tier_3_Manager__r
            cas.Tier_3_Manager__c = sp.Tier_3_Manager__r.firstname+ ' '+ sp.Tier_3_Manager__r.lastname;
            //if(cas.Tier_3_Queue__c == null && trigger.new[0].Component__c != trigger.old[0].Component__c)
            cas.Tier_3_Queue__c = sp.Tier_3_Queue__c;
            //if(cas.PMOwnerNew__c == null || (trigger.old[0].Status == 'Open – Customer Care' && cas.Status == 'Open – Product Management'))
    	    //MS 6/12/13 if (cas.Status == 'Open – Product Management') {
    	    if (caseType == 'Genesys_Feature_Request_Case') {
	            cas.PMOwnerNew__c = sp.PM_Owner__c;
    	        //cas.PM_Owner__c = sp.PM_Owner__r.firstname + ' ' + sp.PM_Owner__r.lastname;
    	    }
    	}
	} else {
            if(cas.Support_Product__c != null){
                Support_product__c sp = [Select id,PM_Owner__r.firstname,PM_Owner__r.lastname,PM_Owner__c,Tier_3_Manager__r.firstname,Tier_3_Manager__r.lastname ,Tier_3_Queue__c from Support_product__c where id=: cas.Support_Product__c];
                // MS 6/12/13 if(trigger.old[0].Status == 'Open – Customer Care' && cas.Status == 'Open – Product Management'){
                 if(trigger.old[0].RecordTypeId != cas.RecordTypeId && caseType == 'Genesys_Feature_Request_Case') {
                    cas.PMOwnerNew__c = sp.PM_Owner__c;
                    //cas.PM_Owner__c = sp.PM_Owner__r.firstname + ' ' + sp.PM_Owner__r.lastname;
                }
                
                if(trigger.new[0].Support_Product__c != trigger.old[0].Support_Product__c){
                        //if(cas.Tier_3_Manager__c == null)
                        cas.Tier_3_Manager__c = sp.Tier_3_Manager__r.firstname+ ' '+ sp.Tier_3_Manager__r.lastname;
                        //if(cas.Tier_3_Queue__c == null)
                        cas.Tier_3_Queue__c = sp.Tier_3_Queue__c;
                        //if (cas.Status == 'Open – Product Management') {
                        if (caseType == 'Genesys_Feature_Request_Case') {
                        	//if(cas.PMOwnerNew__c == null || (trigger.old[0].Status == 'Open – Customer Care' && cas.Status == 'Open – Product Management'))
                        	cas.PMOwnerNew__c = sp.PM_Owner__c;
                        }
                }
                
            }
        }
    }
****/
}