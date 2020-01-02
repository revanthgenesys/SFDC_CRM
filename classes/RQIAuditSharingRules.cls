public with sharing class RQIAuditSharingRules {


    List <RQI_Audit__c> newauditList;
    
    public RQIAuditSharingRules(List <RQI_Audit__c> newaudit){
        newauditList = newaudit;
    }
    
    
    public void shareAuditWithAuthor(){
    	

    	List<RQI_Audit__Share> jobShrs = new List<RQI_Audit__Share>();
    	
    	Map <String,RQI_Audit__Share> auditshr = new Map <String,RQI_Audit__Share>();
    	Set<ID> setWithIds = new  Set<ID>();
        for(RQI_Audit__c audit:newauditList){ 
        	setWithIds.add(audit.Id);
        }
    	
    	
    	List<RQI_Audit__Share> allShares = [Select Id, UserOrGroupId from RQI_Audit__Share where ParentId IN: setWithIds];
    	for(RQI_Audit__Share shr:allShares){
    		if(shr.UserOrGroupId!=null){
				auditshr.put(shr.UserOrGroupId,shr);    			
    		}
    	}
    	
    	
    	for (RQI_Audit__c audit:newauditList) { 
    		if(audit.Author__c!=null){
    			RQI_Audit__Share theShr = auditshr.get(audit.Author__c);
    			if(theShr == null && audit.Author__c != Userinfo.getUserId()){
		            RQI_Audit__Share SCauditShr = new RQI_Audit__Share();
					SCauditShr.ParentId = audit.Id;
					SCauditShr.UserOrGroupId = audit.Author__c;
					SCauditShr.AccessLevel = 'Read';
					jobShrs.add(SCauditShr);
    			}
    		}
        }
        
        
		Database.SaveResult[] lsr = Database.insert(jobShrs,false);
			
		Integer i=0;
		for(Database.SaveResult sr : lsr){
			if(!sr.isSuccess()){
				Database.Error err = sr.getErrors()[0];
				if(!(err.getStatusCode() == StatusCode.FIELD_INTEGRITY_EXCEPTION &&
					err.getMessage().contains('AccessLevel'))){
						 newauditList[0].addError( ' You need to be the Coach in order to initiate the audit.');
				}
			}
			i++;
		}
    	
    	
    }
    
    
    

}