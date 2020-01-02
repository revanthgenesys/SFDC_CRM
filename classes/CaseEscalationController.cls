public class CaseEscalationController {
    
    public Case_Escalation__c escl {get; set;}
    public String caseId {get; set;}
    public String caseNum {get; set;}
    
    public CaseEscalationController(ApexPages.StandardController contr) {
        
        caseId = ApexPages.currentPage().getParameters().get('csid');       
        escl = new Case_Escalation__c();  
        setDefauls();           
    }
    
    public PageReference setDefauls() {
        
        if ( String.isBlank(caseId) )  {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Case not Found.' );
            ApexPages.addMessage(errorMessage);  
            return null; 
        }
        
        List<Case> cs = [SELECT CaseNumber, RecordType.Name, Cloud_Deployment__c, End_User_Account__c, 
                                Cloud_Deployment__r.CXM__c, Cloud_Deployment__r.CXM__r.Name, OwnerId,
                                Back_Office_Account__c, Back_Office_Account__r.TAM__c, Back_Office_Account__r.TAM__r.Name
                         FROM Case WHERE Id = :caseId];
        
        if ( cs.isEmpty() ) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Case not Found.' );
            ApexPages.addMessage(errorMessage);  
            return null; 
        }
            
        caseNum = cs[0].CaseNumber;
        
        if ( cs[0].End_User_Account__c != null )
             escl.End_User_Account__c = cs[0].End_User_Account__c;
       
        /* 
        if ( cs[0].RecordType.Name.startswith('Cloud') && cs[0].Cloud_Deployment__c != null && cs[0].Cloud_Deployment__r.CXM__c != null )  {
             escl.Account_Escalation_Owner__c = cs[0].Cloud_Deployment__r.CXM__c;           
        }
        else if ( cs[0].Back_Office_Account__c != null && cs[0].Back_Office_Account__r.TAM__c != null )  {
             escl.Account_Escalation_Owner__c = cs[0].Back_Office_Account__r.TAM__c;
        }
        */
        escl.Account_Escalation_Owner__c = UserInfo.getUserId();
        
        if ( cs[0].OwnerId != null && cs[0].OwnerId.getSobjectType() == Schema.User.SObjectType )
            escl.Tech_Escalation_Owner__c = cs[0].OwnerId; 
        
        escl.Description__c = System.Label.CaseEscalationDescriptionTemplate;
        escl.Case__c = caseId;
        escl.Status__c = 'Open';
        
        return null;
    }
        
    public PageReference saveEscl() {
         try {
             insert escl;    
         }  
         catch(Exception ex) {          
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() );
            ApexPages.addMessage(errorMessage);  
            return null; 
         }
         return new PageReference('/' + escl.Id);       
    }
    
}