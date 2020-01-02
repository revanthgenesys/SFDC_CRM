//Naresh Kumar 04/04/2014
public with sharing class DocuSignMainTriggerHelper {
    
    public static void generateServiceContract(Map<id, dsfs__DocuSign_Status__c> newMap, Map<id, dsfs__DocuSign_Status__c> oldMap){
        Set<Id> quoteIds = new Set<Id>();
        for(dsfs__DocuSign_Status__c eachDSStatus : newMap.values()){
            if(eachDSStatus.dsfs__Envelope_Status__c == 'Completed' 
                && (oldMap == null || oldMap.get(eachDSStatus.id).dsfs__Envelope_Status__c != 'Completed')){
                quoteIds.add(eachDSStatus.Quote__c);
            }
        }   
        if(!quoteIds.isEmpty()) {
            //CloudQuoteUtil.createServiceContract(quoteIds); 
           }
    }
    
    public static void updateGCRContentDocument(Attachment newAttachment){
        System.debug('NKC debug newAttachment.Name ['+newAttachment.Name+']');
        if(  newAttachment.Name.startsWith('Services Order') || newAttachment.Name.startsWith(GCRContentDocumentDetailsContHelper.NDA) 
            || newAttachment.Name.startsWith(GCRContentDocumentDetailsContHelper.MSLSA) ){
            Id docuSignStatusRecordId = newAttachment.parentId;
            Schema.SObjectType token = docuSignStatusRecordId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            System.debug('NKC debug dr.getName() ['+dr.getName()+']');
            if(dr.getName() == 'dsfs__DocuSign_Status__c'){
                dsfs__DocuSign_Status__c currentDocuSignStatusRecord =  [SELECT dsfs__Company__c,GCR_Content_Document__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE id =: docuSignStatusRecordId ];
                if(currentDocuSignStatusRecord.dsfs__Envelope_Status__c == 'Completed'){
                    List<GCR_Content_Document_Folder__c> masterAgreementFolder = [SELECT id FROM GCR_Content_Document_Folder__c 
                    WHERE Name =: GCRContentDocumentDetailsContHelper.MASTER_AGREEMENT_FOLDER];             
                    GCR_Content_Document_Detail__c gcrDocumentToBeUpdated;
                     dsfs__DocuSign_Status__c currentDocuSignStatusRecordToUpdate;
                    if(currentDocuSignStatusRecord.GCR_Content_Document__c != null && currentDocuSignStatusRecord.GCR_Content_Document__c <>'')  {
                     gcrDocumentToBeUpdated = new GCR_Content_Document_Detail__c(id = currentDocuSignStatusRecord.GCR_Content_Document__c);
                    }
                    else  {
                     gcrDocumentToBeUpdated = new GCR_Content_Document_Detail__c();
                     currentDocuSignStatusRecordToUpdate = new  dsfs__DocuSign_Status__c(id = docuSignStatusRecordId);
                     currentDocuSignStatusRecordToUpdate.GCR_Content_Document__c =  gcrDocumentToBeUpdated.id;
                     System.debug('VIK' + gcrDocumentToBeUpdated.id);
                    }
                   
                    
                    gcrDocumentToBeUpdated.Document_Name__c = newAttachment.Name;               
                    gcrDocumentToBeUpdated.Effective_Date__c = System.today();
                    if(!masterAgreementFolder.isEmpty())
                        gcrDocumentToBeUpdated.Folder__c = masterAgreementFolder[0].id; 
                    gcrDocumentToBeUpdated.Expiration_Renewal_Date__c = System.today().addMonths(12);
                    if(newAttachment.Name == GCRContentDocumentDetailsContHelper.MSLSA)
                        gcrDocumentToBeUpdated.Contract_Type__c = GCRContentDocumentDetailsContHelper.MSLSA_DEF;
                    else if(newAttachment.Name == GCRContentDocumentDetailsContHelper.NDA)
                        gcrDocumentToBeUpdated.Contract_Type__c = GCRContentDocumentDetailsContHelper.NDA_DEF;
                    gcrDocumentToBeUpdated.SLA__c = 'N/A';
                    gcrDocumentToBeUpdated.Maint_SLA__c = 'Standard';
                    gcrDocumentToBeUpdated.Pricing_Terms__c = 'N/A';
                    gcrDocumentToBeUpdated.Shipping_Terms__c = 'None';
                    gcrDocumentToBeUpdated.Penalties__c = 'None';
                    gcrDocumentToBeUpdated.Warranty_Period_Start__c = 'Software Delivery';
                    gcrDocumentToBeUpdated.Product_Services_Covered_by_Contract1__c = 'Software;Professional Services;';
                    gcrDocumentToBeUpdated.Maintenance_Type__c = 'None';
                    gcrDocumentToBeUpdated.Payment_Terms__c = 'Net 30';
                    gcrDocumentToBeUpdated.Maintenance_Rate__c = '';
                    gcrDocumentToBeUpdated.Finance_Comments__c = 'Generated from Quote Approval';
                    gcrDocumentToBeUpdated.Account_Name__c= currentDocuSignStatusRecord.dsfs__Company__c; 
                    gcrDocumentToBeUpdated.Active__c = true;
                     
                    Database.upsertResult srList = Database.upsert(gcrDocumentToBeUpdated, false);
                                        
                    Id newUpsertId;
                
                      if(srList.isSuccess()){
                        newUpsertId= srList.getId();
                        
                     }
                   
                    System.debug('VIKNEUPSERT' + newUpsertId);
                                        
                    if((currentDocuSignStatusRecord.GCR_Content_Document__c == null || currentDocuSignStatusRecord.GCR_Content_Document__c == '') && newUpsertId!= null ) {
                     currentDocuSignStatusRecordToUpdate = new  dsfs__DocuSign_Status__c(id = docuSignStatusRecordId);
                     currentDocuSignStatusRecordToUpdate.GCR_Content_Document__c =  newUpsertId;
                     System.debug('VIKSSS' + newUpsertId + ' TTTT' + currentDocuSignStatusRecordToUpdate.id );
                     update currentDocuSignStatusRecordToUpdate;
                    }
                    
                   
                    
                }
            }       
        }
    }
    /*
    public static void updateGCRContentDocument(Map<id, dsfs__DocuSign_Status__c> newMap, Map<id, dsfs__DocuSign_Status__c> oldMap){
        dsfs__DocuSign_Status__c currentDocuSignStatusRecord;
        for(dsfs__DocuSign_Status__c eachDSStatus : newMap.values()){
            if(eachDSStatus.dsfs__Envelope_Status__c == 'Completed' 
                && (oldMap == null || oldMap.get(eachDSStatus.id).dsfs__Envelope_Status__c != 'Completed')){
                currentDocuSignStatusRecord = eachDSStatus;
                break;
            }
        }
        if(currentDocuSignStatusRecord == null || currentDocuSignStatusRecord.GCR_Content_Document__c == null)
            return;
        List<Attachment> atts = [SELECT id, Name FROM Attachment WHERE parentId =: currentDocuSignStatusRecord.id];
        if(atts.isEmpty())
            return;
        
        List<GCR_Content_Document_Folder__c> masterAgreementFolder = [SELECT id FROM GCR_Content_Document_Folder__c 
            WHERE Name =: GCRContentDocumentDetailsContHelper.MASTER_AGREEMENT_FOLDER]; 
        
        GCR_Content_Document_Detail__c gcrDocumentToBeUpdated = new GCR_Content_Document_Detail__c(id = currentDocuSignStatusRecord.GCR_Content_Document__c);
        gcrDocumentToBeUpdated.Document_Name__c = atts[0].Name;             
        gcrDocumentToBeUpdated.Effective_Date__c = System.today();
        if(!masterAgreementFolder.isEmpty())
            gcrDocumentToBeUpdated.Folder__c = masterAgreementFolder[0].id; 
        gcrDocumentToBeUpdated.Expiration_Renewal_Date__c = System.today().addMonths(12);
        if(atts[0].Name == GCRContentDocumentDetailsContHelper.MSLSA)
            gcrDocumentToBeUpdated.Contract_Type__c = GCRContentDocumentDetailsContHelper.MSLSA_DEF;
        else if(atts[0].Name == GCRContentDocumentDetailsContHelper.NDA)
            gcrDocumentToBeUpdated.Contract_Type__c = GCRContentDocumentDetailsContHelper.NDA_DEF;
        update gcrDocumentToBeUpdated;
        
    }
    */
}