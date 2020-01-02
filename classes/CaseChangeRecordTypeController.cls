public class CaseChangeRecordTypeController {

    public List<SelectOption> rectypes {get; set;}
    public String selectedRecTypeId {get; set;}
    public String currentRecType {get; set;}
    public Case cs {get; set;}
    public Case dummyCase {get; set;}
    private Map<Id, RecordType> types;
    private String fromType;
    private String toType;
    
    public CaseChangeRecordTypeController(ApexPages.StandardController stdController)  {
         String csId = ApexPages.currentPage().getParameters().get('Id');
          
          cs = [SELECT Id, CaseNumber, RecordType.Name, RecordTypeId, Priority, RecordType.DeveloperName FROM Case WHERE id = :csId];
          fromType = cs.RecordType.DeveloperName.startswith('Genesys_Cloud_') ? 'cloud' : 'prem';
          currentRecType = CaseUtil.casePageTitleByType(cs.RecordTypeId);
          
          List<RecordType> caseTypeLst = CaseUtil.getTScaseTypes(); 
          
          types = new Map<Id, RecordType>(caseTypeLst) ;
          rectypes = new List<SelectOption>();
               
          if ( !caseTypeLst.isEmpty() ) {
              for ( RecordType rt : caseTypeLst ) {
                 
                  if ( cs.RecordType.DeveloperName == rt.DeveloperName )
                       continue;
                  rectypes.add( new SelectOption( rt.Id, CaseUtil.casePageTitleByType(rt.Id) ) );
              }              
               selectedRecTypeId = rectypes[0].getValue();  
               setTargetType(); 
               setCaseSubTypes();         
          }
    }
    
   public String btnLabel {
   	  get {
   	  	   setTargetType();
   	       if ( (fromType == 'prem' && toType == 'cloud') || (fromType == 'cloud' && toType == 'prem') )
   	           return 'Continue';
   	       else
   	           return 'Save';
   	  }
   	  set;
   }
   
   public void setCaseSubTypes() {
   	   dummyCase = new Case (RecordTypeId = selectedRecTypeId);
   }
    
   public PageReference nextPage() {
   	   if ( dummyCase.Problem_Sub_Type__c == null && !types.get(selectedRecTypeId).DeveloperName.contains('_Feature_') ) {
   	   	   ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify the Case Sub Type.' );
           ApexPages.addMessage(msg); 
           return null;
   	   }
   	
       setTargetType();
       if ( fromType == 'prem' && toType == 'cloud' )
            return gotoCldPage();
       else if ( fromType == 'cloud' && toType == 'prem' )
            return gotoPremPage();
       else
            return saveCase();
            
       return null;
    }
    
  public PageReference gotoCldPage() {
    	PageReference pr; 
    	pr = new PageReference('/apex/CaseCloudDeplProductSelection');
    	pr.getParameters().put('RecordType', selectedRecTypeId); 
        pr.getParameters().put('Id', cs.Id); 
        pr.getParameters().put('updRecTp', '1');
        pr.getParameters().put('prty', cs.Priority == 'Prod Down' ? 'crit' : '');
        pr.getParameters().put('subtp', dummyCase.Problem_Sub_Type__c); 
        return pr;
    }
    
   public PageReference gotoPremPage() {
    	PageReference pr; 
    	pr = new PageReference('/apex/CasePremiseContactProductSelection');
    	pr.getParameters().put('RecordType', selectedRecTypeId); 
        pr.getParameters().put('Id', cs.Id); 
        pr.getParameters().put('updRecTp', '1');
        pr.getParameters().put('subtp', dummyCase.Problem_Sub_Type__c); 
        return pr;
    }
    
  public PageReference saveCase() {   
  	  CaseService.caseInstanceRecTypeUpd caseinst = new CaseService.caseInstanceRecTypeUpd(null, selectedRecTypeId);
  	  Case csupd = caseinst.cs;
  	  csupd.Id = cs.Id;
  	  csupd.Problem_Sub_Type__c = dummyCase.Problem_Sub_Type__c;
  
      try {
   	   	  update csupd;   	   	 
   	   }
   	   catch(Exception ex) {  
		   ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating the Case. Additional details: ' + ex.getMessage() );
           ApexPages.addMessage(msg); 
           return null;
	  }      

       return new PageReference('/'+ cs.Id);
    }
    
  public void setTargetType() {
  	  if ( types.get(selectedRecTypeId).DeveloperName.startswith('Genesys_Cloud_') )
  	      toType = 'cloud';
  	  else if ( types.get(selectedRecTypeId).DeveloperName.startswith('Genesys_Admin_') )
  	      toType = 'admin';
  	  else
  	      toType = 'prem'; 
  }  

}