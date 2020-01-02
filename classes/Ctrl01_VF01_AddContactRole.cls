public with sharing class Ctrl01_VF01_AddContactRole {

private OQM_Form__c OQMF {get; set;}
private List<OpportunityContactRole> lstOpptyContactRole = new List<OpportunityContactRole>();
private List<Opportunity> OpptyRelated = new List<Opportunity>();
private String OCRToDelete = null;
public boolean ListNotEmpty {get; set;}

public Ctrl01_VF01_AddContactRole (ApexPages.StandardController stdController) {
        Util.MyLog('###Ctrl01_VF01_AddContactRole Start');
        this.OQMF = (OQM_Form__c)stdController.getRecord();
        Util.MyLog('###OQMF =' + this.OQMF);
    }

public List<OpportunityContactRole> getlstOpptyContactRole() {
    Util.MyLog('###getlstOpptyContactRole Start');
    Util.MyLog('###OpptyRelated =' + OpptyRelated);
    OpptyRelated = [SELECT Id, 
                           (SELECT Id, Contact.name, Contact.Account.name, Contact.Phone , Role, Contact.Email, IsPrimary, OpportunityId 
                            FROM OpportunityContactRoles
                            WHERE OpportunityID = : this.OQMF.OpportunityName__c) 
                    FROM Opportunity
                    WHERE ID = : this.OQMF.OpportunityName__c
                    LIMIT 1];
    for(Opportunity o : OpptyRelated){
        if(o.OpportunityContactRoles.size() != 0){
            lstOpptyContactRole.addAll(o.OpportunityContactRoles);         
            Util.MyLog('###getlstOpptyContactRole End1'); 
            ListNotEmpty = true;
            return lstOpptyContactRole;
        }
        else {
            Util.MyLog('###getlstOpptyContactRole End2'); 
            ListNotEmpty = false;
            return lstOpptyContactRole;
        }
    }
    return null;
}   

public PageReference OQMAddContactRole() {
    Util.MyLog('###OQMAddContactRole Start');
    
    ApexPages.Pagereference page = new PageReference('/p/opp/ContactRoleEditUi/e?oppid='+ this.OQMF.opportunityName__c + '&retURL=' + this.OQMF.Id);
    return page;
    } 

public PageReference OQMDeleteContactRole() {
    Util.MyLog('###OQMDeleteContactRole Start');
     //delete new OpportunityContactRole(Id = OCRToDelete);
    OpportunityContactRole OCR = new OpportunityContactRole(Id = OCRToDelete);
    
    Util.MyLog('###OQMDeleteContactRole = ' + OCR);
    delete OCR;
    ApexPages.StandardController sc = new ApexPages.StandardController(this.OQMF);
    return sc.view();
    } 
    
public String getOCRToDelete() {
        return OCRToDelete;
    }
    
public void setOCRToDelete(String n) {
        Util.MyLog('###OCRToDelete = ' + OCRToDelete);
        OCRToDelete = n;    
    }
}