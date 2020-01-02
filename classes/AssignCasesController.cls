/*
Class : AssignCasesController

Revision History : 4/26/2013 Vinay L 
				   Added code to assing cases on Cases page.
*/

public with sharing class AssignCasesController {
	public String releasePhaseId {get;set;}
	public String caseId;
	public String endUAcc;
	public String endUAccName;
 	public List<Util.Wrappers> cases {get;set;}	
	public AssignCasesController(){
		releasePhaseId = Apexpages.currentPage().getParameters().get('rphaseId');
		caseId = Apexpages.currentPage().getParameters().get('caId');
		endUAcc = Apexpages.currentPage().getParameters().get('enUA');
		endUAccName = Apexpages.currentPage().getParameters().get('enuAName');
		if(releasePhaseId != null){
			List<Release_Phase__c> rphases = [Select Id, Project_Management__r.End_User_Account__c, Project_Management__r.End_User_Account__r.Name, Project_Management__c from Release_Phase__c where Id=:releasePhaseId];
			if(rphases != null && !rphases.isEmpty()){
				String query = 'Select Id, AccountId, CaseNumber, Subject from Case where Release_Phase__c = null and IsClosed=false and AccountId=\'' + rphases[0].Project_Management__r.End_User_Account__c + '\'' ;
				system.debug(query);
				Pagination p = new Pagination(query, 10);
				cases = new List<Util.Wrappers>();
				cases = p.getWrappers();	
				if( cases == null || cases.IsEmpty() ){
					ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.Warning, 'There are no open cases for the End User Account : ' + rphases[0].Project_Management__r.End_User_Account__r.Name));
				}
			}
		}
		
		if(caseId != null && caseId != ''){
			String query = 'Select Id, AccountId, CaseNumber, Subject from Case where IsClosed=false and Parent_Escalation__c = null and End_User_Account__c != null and End_User_Account__c=\'' + endUAcc + '\' and id != \''+caseId +'\'';
			system.debug(query);
			Pagination p = new Pagination(query, 10);
			cases = new List<Util.Wrappers>();
			cases = p.getWrappers();
			if( cases == null || cases.IsEmpty() ){
				ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.Warning, 'There are no open cases for the End User Account : ' + endUAccName));
			}
		}
	}
	
	public PageReference cancel(){
		if(caseId != null && caseId != ''){
			return new PageReference('/'+caseId);
		}
        return new PageReference('/'+releasePhaseId);
    }
    
    public PageReference assignCases(){
    	List<Case> casesToUpdate = new List<Case>();
    	for(Util.Wrappers w : cases){
    		if(w.isSelected){
    			Case c =(Case)w.obj;
    			if(caseId != null && caseId != ''){
    				c.Parent_Escalation__c = caseId;
    			}else{
    				c.Release_Phase__c = releasePhaseId;
    			}
    			casesToUpdate.add(c);
    		}
    	}
    	try{
	    	if(!casesToUpdate.isEmpty())
	    		update casesToUpdate;
    	}catch(DmlException ex){
    		ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.Error, 'There was an error assigning Cases' + ex.getMessage()));
    		return null;
    	}
    	if(caseId != null && caseId != ''){
			return new PageReference('/'+caseId);
		}
	    return new PageReference('/'+releasePhaseId);
    }
}