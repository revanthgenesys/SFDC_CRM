public without sharing class CaseService {
	   
   public class caseInstance {
   	   public Case cs;
   	   public List<SelectOption> priorOpts;
   	   
   	   public caseInstance(String recTypeId)  {
   	   	   cs = new Case();		   
		   cs.RecordTypeId = recTypeId;
		   
		   if ( ContactUtil.isPortalUser() )  {
		   	   cs.Origin='WEB';
		   	   getPortalPriorityOpts();
		   	   cs.Priority = '4-Low';
		   }
	               	               		   
		   setDefaultsByType(recTypeId);
		   
   	   }  	
  
  	   private void setDefaultsByType(String recTypeId)  {
          //might need this in future
	    //  String caseType = CaseUtil.getAllTScaseTypesMap().get(recTypeId).DeveloperName;
	          
	         cs.OS__c = 'N/A';         
	         cs.Environment_Type__c = 'Production';   
  	    }
  	    
  	    private void getPortalPriorityOpts() {
  	    	priorOpts = new List<Selectoption>();
            priorOpts.add(new SelectOption('2-High','2-High'));
            priorOpts.add(new SelectOption('3-Medium','3-Medium'));
            priorOpts.add(new SelectOption('4-Low','4-Low'));  	    	
  	    }
   }
   
   public class caseInstanceRecTypeUpd {
   	   public Case cs;
   	   
   	   public caseInstanceRecTypeUpd(String target, String recTypeId)  {
   	   	   String caseType = CaseUtil.getAllTScaseTypesMap().get(recTypeId).DeveloperName;
   	   	   
   	   	   cs = new Case();		   
		   cs.RecordTypeId = recTypeId;
		   cs.Problem_Sub_Type__c = null;
		//   cs.Status = caseType.contains('Feature') ? 'Open - Customer Care' : 'Open'; 
		//   cs.Sub_Status__c = 'New';
		   	   
		   if (target == 'toPremise')  
		      clearCloudFields();
		   else if ( target == 'toCloud' )
		      clearPremiseFields();
   	   }
   	   
   	   private void clearCloudFields() {
   	   	    cs.Cloud_Deployment__c = null;
   	   	    cs.Cloud_service__c = null;
   	   	    cs.End_User_Account__c = null;
            cs.Sold_To_Account__c = null;   
   	   }
   	   
   	    private void clearPremiseFields() {
   	   	   cs.End_User_Account__c = null;
           cs.Sold_To_Account__c = null;                      
           cs.Support_Product__c = null;
		   cs.Major_Release1__c = null;	
		   cs.Component__c = null;
		   cs.Product_Version__c = null;
   	   }   	
   }

}