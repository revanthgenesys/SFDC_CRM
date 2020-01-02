//Nik Mills: 20-Jan-2017
public class PSDSRDocumentController{
    public List<wrapperDocs> documents {get;set;}
    public String dsrId {get;set;}
    public PS_DSR_Document__c docRecord {get;set;}
    public Deal_Support__c dsrRec {get;set;}
    public Attachment att{get;set;}    
    public String selectedAttId {get;set;}
    public Boolean showGrid {get;set;}
    public Boolean customPage {get;set;}
    public Boolean DSRParentFound {get;set;}
    public Boolean isFromCreateNewDSR {get;set;}
    public PageReference objRef;
    //public PSDSRDocumentController(ApexPages.StandardController stdController)
    public PSDSRDocumentController()
    {
        dsrId = ApexPages.currentPage().getParameters().get('dsrid');
        isFromCreateNewDSR = false;
        if (ApexPages.currentPage().getParameters().get('fromCreateNewDSR') != null)
            isFromCreateNewDSR = true;
        DSRParentFound = false;
        customPage = false;
        if(ApexPages.currentPage().getParameters().get('customPage') != null)
            customPage = true;
        init();     
    }
    
    private void init(){        
        showGrid = false;
        documents = new List<wrapperDocs>();
        list<PS_DSR_Document__c> atts;
        system.debug('++++dsrID++++'+dsrId);
        if(dsrId != null && dsrId != '')
        {
            getDSRRecordDetails(dsrId);
            DSRParentFound=true;
            docRecord = new PS_DSR_Document__c(Deal_Support__c = dsrId);
            atts = [SELECT id, Deal_Support__c, Date_Reviewed__c, Is_Reviewed__c,
                Initial_Upload_Date__c, Doc_Type__c, File_Name__c,
                (SELECT id, Name FROM Attachments) FROM PS_DSR_Document__c WHERE Deal_Support__c =: dsrId];
        }
        att = new Attachment();
       
        if (DSRParentFound)
        {
            //Looping over each attachement
            for(PS_DSR_Document__c eachAtt : atts)
            {
                wrapperDocs newRecord = new wrapperDocs();
                newRecord.record = eachAtt;
                if(!eachAtt.Attachments.isEmpty())
                {
                    newRecord.att = eachAtt.Attachments[0];
                }
                documents.add(newRecord);
            }
        }
        if(!documents.isEmpty())
            showGrid = true;
    }
    
    public void save()
    {
        if(att.body == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please upload the PS DSR attachment first.'));
            return;
        }
        upsert docRecord;
        if(att.parentId == null)
            att.parentId = docRecord.id;        
        upsert att;
        docRecord.File_Name__c = att.Name;  
        init();   
    }
    
    public void selectAtt(){}
    
    public void deleteAtt()
    {
        system.debug('++++Attachment ID to Delete++++'+selectedAttId);
        if (selectedAttId != null)
        {
            PS_DSR_Document__c itemToBeDeleted = new PS_DSR_Document__c(id = selectedAttId);
            delete itemToBeDeleted;
            init();
        }
    }
    
    public class wrapperDocs
    {
        public PS_DSR_Document__c record {get;set;}
        public Attachment att {get;set;}
    }
    
    private void getDSRRecordDetails(String dsrId)
    {
        dsrRec = [SELECT Id, Name, Subject__c, PS_Project_Application__c, Deployment_Type__c, Status__c, Request_Type__c FROM Deal_Support__c WHERE Id =: dsrId];
    }
    
    public PageReference CompleteAttachments()
    {
        if (isFromCreateNewDSR)
        {
            String sPageUrl = '';
        
            sPageUrl = '/apex/PSDealSupportQuery?psDSRId='+dsrRec.Id+'&isFromPSAttachments=yes';
            system.debug('++++Return Page URL+++'+sPageUrl);
      
            objRef = new PageReference(sPageUrl); 
            return objRef;
            }
        else
        {
            return null;
        }
       
    }
}