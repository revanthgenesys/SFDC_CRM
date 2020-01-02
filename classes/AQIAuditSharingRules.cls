public with sharing class AQIAuditSharingRules {


    List <AQI_Audit__c> newauditList;
    
    public AQIAuditSharingRules(List <AQI_Audit__c> newaudit){
        newauditList = newaudit;
    }
    
    
    public void shareAuditWithAuthor(){
    	

    	List<AQI_Audit__Share> jobShrs = new List<AQI_Audit__Share>();
    	
    	Map <String,AQI_Audit__Share> auditshr = new Map <String,AQI_Audit__Share>();
    	Set<ID> setWithIds = new  Set<ID>();
        for(AQI_Audit__c audit:newauditList){ 
        	setWithIds.add(audit.Id);
        }
    	
    	
    	List<AQI_Audit__Share> allShares = [Select Id, UserOrGroupId from AQI_Audit__Share where ParentId IN: setWithIds];
    	for(AQI_Audit__Share shr:allShares){
    		if(shr.UserOrGroupId!=null){
				auditshr.put(shr.UserOrGroupId,shr);    			
    		}
    	}
    	
    	
    	for (AQI_Audit__c audit:newauditList) { 
    		if(audit.Author__c!=null){
    			AQI_Audit__Share theShr = auditshr.get(audit.Author__c);
    			if(theShr == null && audit.Author__c != Userinfo.getUserId()){
		            AQI_Audit__Share SCauditShr = new AQI_Audit__Share();
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