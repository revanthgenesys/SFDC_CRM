//Naresh Kumar    11/12/2015
public class SMLAccountAttachmentController{
    public List<wrapperAtts> attachments {get;set;}
    public String accountId {get;set;}
    public String opportunityId {get;set;}
    public SML_Account_Attachments__c attRecord {get;set;}
    public Attachment att{get;set;}    
    public String selectedAttId {get;set;}
    public Boolean showGrid {get;set;}
    public Boolean customPage {get;set;}
    public SMLAccountAttachmentController(ApexPages.StandardController stdController){
        accountId = ApexPages.currentPage().getParameters().get('id');
        opportunityId  = ApexPages.currentPage().getParameters().get('oppid');
        customPage = false;
        if(ApexPages.currentPage().getParameters().get('customPage') != null)
            customPage = true;
        init();     
    }
    private void init(){        
        showGrid = false;
        attachments = new List<wrapperAtts>();
        list<SML_Account_Attachments__c> atts;
        if(opportunityId != null && opportunityId != ''){
	        attRecord = new SML_Account_Attachments__c(Account__c = accountId,opportunity__c = opportunityId);
	        atts = [SELECT id, Account__c, Product_Category__c, Product_Category__r.Name,
	            Product_Category__r.Solution_Name__c, Type__c,
	            (SELECT id, Name FROM Attachments) FROM SML_Account_Attachments__c WHERE opportunity__c =: opportunityId];
            }
        else{
	        attRecord = new SML_Account_Attachments__c(Account__c = accountId);
	        atts = [SELECT id, Account__c, Product_Category__c, Product_Category__r.Name,
	            Product_Category__r.Solution_Name__c, Type__c,
	            (SELECT id, Name FROM Attachments) FROM SML_Account_Attachments__c WHERE Account__c =: accountId];
        }
        att = new Attachment();
       
        //Looping over each attachement
        for(SML_Account_Attachments__c eachAtt : atts){
            wrapperAtts newRecord = new wrapperAtts();
            newRecord.record = eachAtt;
            if(!eachAtt.Attachments.isEmpty()){
                newRecord.att = eachAtt.Attachments[0];
            }
            attachments.add(newRecord);
        }
        if(!attachments.isEmpty())
            showGrid = true;
    }
    
    public void save(){
    	if(att.body == null){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please upload the attachment first.'));
            return;
        }
        upsert attRecord;
        if(att.parentId == null)
            att.parentId = attRecord.id;        
        upsert att;  
        init();   
    }
    
    public void selectAtt(){}
    
    public void deleteAtt(){
        SML_Account_Attachments__c itemToBeDeleted = new SML_Account_Attachments__c(id = selectedAttId);
        delete itemToBeDeleted;
        init();
    }
    
    public class wrapperAtts{
        public SML_Account_Attachments__c record {get;set;}
        public Attachment att {get;set;}
    }
    
}