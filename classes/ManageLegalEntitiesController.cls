/************************************************************************************
Purpose :  Show list of legal entities including selected for a particular cost center where user can add/remove.
Written By :  Naresh Kumar  08/26/2018
Test Classes :  MDMFunctionality_Test
*************************************************************************************/
public without sharing class ManageLegalEntitiesController {

    public List<LegalEntityWrapper> listOfLegalEntitiesWrapper {get; set;}
    public List<GLLegalEntityWrapper> list_GLLegalEntitiesWrapper {get; set;}
    public List<BSLegalEntitiesWrapper> listOfBSLegalEntitiesWrapper {get; set;}
    public List<CCLegalEntitiesWrapper> listOfCCLegalEntitiesWrapper {get; set;}
    public Cost_Center__c objCC {get; private set;}
    public Business_Segment__c objBS {get; private set;} 
    public GL_Account__c objGLA {get; private set;} 
    public String strTitle {get; private set;}
    public String objectName {get; private set;}
    Id recordId;
    
    
    public ManageLegalEntitiesController(){
        recordId = (Id)ApexPages.currentPage().getParameters().get('id');
        String objectType = String.valueOf(recordId.getSObjectType());
        if(objectType == 'Cost_Center__c'){
            objCC = [SELECT id, Name, Cost_Center_ID__c, Approval_Status__c FROM Cost_Center__c WHERE id =: recordId];
            strTitle = 'Cost Center ID: ' + objCC.Cost_Center_ID__c;
            objectName = 'Cost Center';
            populateWrapperCC();    
        }
        else if(objectType == 'Business_Segment__c'){
            objBS = [SELECT id, Name, Approval_Status__c FROM Business_Segment__c WHERE id =: recordId];
            strTitle = 'Business Segment: ' + objBS.Name;
            objectName = 'Business Segment';
            populateWrapperBS();
        }
        else if(objectType == 'GL_Account__c'){
            objGLA = [SELECT id, Name, Approval_Status__c, Netsuite_Type__c FROM GL_Account__c WHERE id =: recordId];
            strTitle = 'GL Account: ' + objGLA.Name;
            objectName = 'GL Account';
            populateWrapperGLA();
        }
    }
    
    
    public ManageLegalEntitiesController(ApexPages.StandardController stdCtrl){
        recordId = stdCtrl.getId();
        String objectType = String.valueOf(recordId.getSObjectType());
        if(objectType == 'Business_Segment__c'){     
            objBS = [SELECT id, Name, Approval_Status__c FROM Business_Segment__c WHERE id =: recordId];
            popualteSegmentLegalEntitiesList();    
        }
        else if(objectType == 'Cost_Center__c'){
            objCC = [SELECT id, Name, Cost_Center_ID__c, Approval_Status__c FROM Cost_Center__c WHERE id =: recordId];
            popualteCostLegalEntitiesList();    
        }
        else if(objectType == 'GL_Account__c'){
            objGLA = [SELECT id, Name, Approval_Status__c, Netsuite_Type__c FROM GL_Account__c WHERE id =: recordId];
            popualteGLAccountLegalEntitiesList();    
        }
    }
    
    
    public PageReference updateStatusOfRecord(){
        Id recId = (Id)ApexPages.currentPage().getParameters().get('id');
        String objectType = String.valueOf(recId.getSObjectType());
        PageReference pg = new PageReference('/apex/ManageLegalEntities?id='+recId);
        boolean isUpdate = false;
        if(objectType == 'Cost_Center__c'){
            Cost_Center__c obj = [SELECT id, Approval_Status__c FROM Cost_Center__c WHERE id =: recId];
            if(obj.Approval_Status__c == 'Approved'){
                obj.Approval_Status__c = 'New';
                update obj;
                isUpdate = true;
            }
        }
        else if(objectType == 'Business_Segment__c'){
            Business_Segment__c obj = [SELECT id, Approval_Status__c FROM Business_Segment__c WHERE id =: recId];
            if(obj.Approval_Status__c == 'Approved'){
                obj.Approval_Status__c = 'New';
                update obj;
                isUpdate = true;
            }
        }
        else if(objectType == 'GL_Account__c'){
            GL_Account__c obj = [SELECT id, Approval_Status__c FROM GL_Account__c WHERE id =: recId];
            if(obj.Approval_Status__c == 'Approved'){
                obj.Approval_Status__c = 'New';
                update obj;
                isUpdate = true;
            }
        }
        if(isUpdate)
            return pg;
        return null;
    }
    
    private void popualteSegmentLegalEntitiesList(){
        /* */
        List<Business_Segment_Legal_Entity__c> listOfLegalEntities = [SELECT Legal_Entity__c, Legal_Entity_Name__c, Status__c, Region__c, Legal_Entity_ID__c, Legal_Entity__r.Country__c, LastModifiedDate 
                                                                FROM Business_Segment_Legal_Entity__c 
                                                                WHERE Business_Segment__c =: recordId order by Legal_Entity_ID__c, LastModifiedDate DESC];
        listOfBSLegalEntitiesWrapper = new List<BSLegalEntitiesWrapper>();        
        for(Business_Segment_Legal_Entity__c eachEntity : listOfLegalEntities){
            BSLegalEntitiesWrapper objNewWrapper = new BSLegalEntitiesWrapper(eachEntity, false, false);     
            listOfBSLegalEntitiesWrapper.add(objNewWrapper);

    /*
        List<Legal_Entity__c> listOfLegalEntities = [SELECT Name, Legal_Entity_ID__c, Status__c, Country__c, Region__c FROM Legal_Entity__c
                                                    WHERE id IN (SELECT Legal_Entity__c FROM Business_Segment_Legal_Entity__c 
                                                    WHERE Business_Segment__c =: recordId) ];
        listOfLegalEntitiesWrapper = new List<LegalEntityWrapper>();        
        for(Legal_Entity__c eachEntity : listOfLegalEntities){
            LegalEntityWrapper objNewWrapper = new LegalEntityWrapper(eachEntity, false, false);     
            listOfLegalEntitiesWrapper.add(objNewWrapper);
    */
        } 
    }
    
    
    private void popualteCostLegalEntitiesList(){

         List<Cost_Center_Legal_Entity__c> listOfLegalEntities = [SELECT Legal_Entity__c, Legal_Entity_Name__c, Status__c, Region__c, Legal_Entity_ID__c, Legal_Entity__r.Country__c, LastModifiedDate 
                                                                FROM Cost_Center_Legal_Entity__c 
                                                                WHERE Cost_Center__c =: recordId order by Legal_Entity_ID__c, LastModifiedDate DESC];
        listOfCCLegalEntitiesWrapper = new List<CCLegalEntitiesWrapper>();        
        for(Cost_Center_Legal_Entity__c eachEntity : listOfLegalEntities){
            CCLegalEntitiesWrapper objNewWrapper = new CCLegalEntitiesWrapper(eachEntity, false, false);     
            listOfCCLegalEntitiesWrapper.add(objNewWrapper);
        
        /*
        List<Legal_Entity__c> listOfLegalEntities = [SELECT Name, Legal_Entity_ID__c, Status__c, Country__c, Region__c FROM Legal_Entity__c
                                                    WHERE id IN (SELECT Legal_Entity__c FROM Cost_Center_Legal_Entity__c 
                                                    WHERE Cost_Center__c =: recordId) order by Legal_Entity_ID__c];
        listOfLegalEntitiesWrapper = new List<LegalEntityWrapper>();        
        for(Legal_Entity__c eachEntity : listOfLegalEntities){
            LegalEntityWrapper objNewWrapper = new LegalEntityWrapper(eachEntity, false, false);     
            listOfLegalEntitiesWrapper.add(objNewWrapper); */
        }
    }
    
    
    private void popualteGLAccountLegalEntitiesList(){
        List<GL_Account_Legal_Entity__c> listOfLegalEntities = [SELECT Legal_Entity__c, Legal_Entity_Name__c, Status__c, Region__c, Legal_Entity_ID__c, Legal_Entity__r.Country__c, LastModifiedDate 
                                                                FROM GL_Account_Legal_Entity__c 
                                                                WHERE GL_Account__c =: recordId order by Legal_Entity_ID__c, LastModifiedDate DESC];
        list_GLLegalEntitiesWrapper = new List<GLLegalEntityWrapper>();        
       
        for(GL_Account_Legal_Entity__c eachEntity : listOfLegalEntities){
            GLLegalEntityWrapper objNewWrapper = new GLLegalEntityWrapper(eachEntity, false, false);     
            list_GLLegalEntitiesWrapper.add(objNewWrapper);
        }
    }
    
    
    public PageReference redirectToCC(){
        PageReference pr = new PageReference('/' + objCC.id);
        return pr;
    }
    
    
    public PageReference redirectToBS(){
        PageReference pr = new PageReference('/' + objBS.id);
        return pr;
    }
    
    
    public PageReference redirectToGLA(){
        PageReference pr = new PageReference('/' + objGLA.id);
        return pr;
    }
    
    private void populateWrapperCC(){        
        List<Legal_Entity__c> listOfLegalEntities = [SELECT Name, Legal_Entity_ID__c, Status__c, Country__c, Region__c FROM Legal_Entity__c order by Legal_Entity_ID__c];
        
        List<Cost_Center_Legal_Entity__c> listOfCCLegalEntities = [SELECT Legal_Entity__c, Status__c, CreatedDate, Record_Locked__c 
                                                                   FROM Cost_Center_Legal_Entity__c 
                                                                   WHERE Cost_Center__c =: objCC.id];
        
        Map<Id, Cost_Center_Legal_Entity__c> mapOfLegalEntityIdVsCCLegalEntity = new Map<Id, Cost_Center_Legal_Entity__c>();
        for(Cost_Center_Legal_Entity__c eachCCLegalEntity : listOfCCLegalEntities){
            mapOfLegalEntityIdVsCCLegalEntity.put(eachCCLegalEntity.Legal_Entity__c, eachCCLegalEntity);
        }
        
        listOfLegalEntitiesWrapper = new List<LegalEntityWrapper>();        
        for(Legal_Entity__c eachEntity : listOfLegalEntities){
            Cost_Center_Legal_Entity__c objCCLE = mapOfLegalEntityIdVsCCLegalEntity.get(eachEntity.id);
            Boolean blnSelected = false;
            Boolean blnRecordLocked = false;
            if(objCCLE != null){
                blnSelected = true; 
                blnRecordLocked = objCCLE.Record_Locked__c;
                //blnRecordLocked = objCC.Approval_Counter__c > objCCLE.Approval_Counter__c;
            }
            LegalEntityWrapper objNewWrapper = new LegalEntityWrapper(eachEntity, blnSelected, blnRecordLocked);     
            listOfLegalEntitiesWrapper.add(objNewWrapper);
        }
    }
    
    private void populateWrapperBS(){        
        List<Legal_Entity__c> listOfLegalEntities = [SELECT Name, Legal_Entity_ID__c, Status__c, Country__c, Region__c FROM Legal_Entity__c order by Legal_Entity_ID__c];
        
        List<Business_Segment_Legal_Entity__c> listOfBSLegalEntities = [SELECT Legal_Entity__c, Record_Locked__c
                                                                        FROM Business_Segment_Legal_Entity__c 
                                                                        WHERE Business_Segment__c =: objBS.id];
        
        Map<Id, Business_Segment_Legal_Entity__c> mapOfLegalEntityIdVsBSLegalEntity = new Map<Id, Business_Segment_Legal_Entity__c>();
        for(Business_Segment_Legal_Entity__c eachBSLegalEntity : listOfBSLegalEntities){
            mapOfLegalEntityIdVsBSLegalEntity.put(eachBSLegalEntity.Legal_Entity__c, eachBSLegalEntity);
        }
        
        listOfLegalEntitiesWrapper = new List<LegalEntityWrapper>();        
        for(Legal_Entity__c eachEntity : listOfLegalEntities){
            Business_Segment_Legal_Entity__c objBSLE = mapOfLegalEntityIdVsBSLegalEntity.get(eachEntity.id);
            Boolean blnSelected = false;
            Boolean blnRecordLocked = false;
            if(objBSLE != null){
                blnSelected = true;
                blnRecordLocked = objBSLE.Record_Locked__c; 
               // blnRecordLocked = objBS.Approval_Counter__c > objBSLE.Approval_Counter__c;
            }
            LegalEntityWrapper objNewWrapper = new LegalEntityWrapper(eachEntity, blnSelected, blnRecordLocked);     
            listOfLegalEntitiesWrapper.add(objNewWrapper);
        }
    }
    
    
    private void populateWrapperGLA(){        
        List<Legal_Entity__c> listOfLegalEntities = [SELECT Id, Name, Legal_Entity_ID__c, Status__c, Country__c, Region__c FROM Legal_Entity__c order by Legal_Entity_ID__c];
        
        Set<Id> set_InactiveGLEntity = new Set<Id>();
        List<GL_Account_Legal_Entity__c> listOfBSLegalEntities = [SELECT Legal_Entity__c, Legal_Entity_Name__c, status__c, Record_Locked__c 
                                                                  FROM GL_Account_Legal_Entity__c 
                                                                   WHERE GL_Account__c =: objGLA.id];
        
        Map<Id, GL_Account_Legal_Entity__c> mapOfLegalEntityIdVsBSLegalEntity = new Map<Id, GL_Account_Legal_Entity__c>();
        for(GL_Account_Legal_Entity__c eachBSLegalEntity : listOfBSLegalEntities){
            mapOfLegalEntityIdVsBSLegalEntity.put(eachBSLegalEntity.Legal_Entity__c, eachBSLegalEntity);
            if(eachBSLegalEntity.Status__c == 'Inactive'){
                set_InactiveGLEntity.add(eachBSLegalEntity.Legal_Entity__c);
            }
        }
        
        listOfLegalEntitiesWrapper = new List<LegalEntityWrapper>();        
        for(Legal_Entity__c eachEntity : listOfLegalEntities){
            GL_Account_Legal_Entity__c objBSLE = mapOfLegalEntityIdVsBSLegalEntity.get(eachEntity.id);
            Boolean blnSelected = false;
            Boolean blnRecordLocked = false;
            if(objBSLE != null){
                blnSelected = true; 
                blnRecordLocked = objBSLE.Record_Locked__c; 
               // blnRecordLocked = objGLA.Approval_Counter__c > objBSLE.Approval_Counter__c;
            }
            if(set_InactiveGLEntity.contains(eachEntity.Id)){
                eachEntity.Status__c = 'Inactive';
            }
            LegalEntityWrapper objNewWrapper = new LegalEntityWrapper(eachEntity, blnSelected, blnRecordLocked);     
            listOfLegalEntitiesWrapper.add(objNewWrapper);
        }
    }
    
    
    public void saveGLA(){
        Map<Id, Integer> mapOfLegalEntityIdVsApprovalCounter = new Map<Id, Integer>();      
        List<GL_Account_Legal_Entity__c> listOfCCLE = [SELECT id, Legal_Entity__c, GL_Account__r.Netsuite_Type__c 
                                                       FROM GL_Account_Legal_Entity__c 
                                                       WHERE GL_Account__c =: objGLA.id AND Record_Locked__c = false];        
       /*
        for(GL_Account_Legal_Entity__c eachCCLE :listOfCCLE){
            mapOfLegalEntityIdVsApprovalCounter.put(eachCCLE.Legal_Entity__c, Integer.valueOf(eachCCLE.Approval_Counter__c));           
        }
        */
        if( !listOfCCLE.isEmpty() ) {
            if ( objGLA.Netsuite_Type__c == 'Bank' ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You can select Only One Legal Entity.'));
                return;
            }   
            else
                delete listOfCCLE;    
        }
        List<GL_Account_Legal_Entity__c> listOfRecordsToBeInserted = new List<GL_Account_Legal_Entity__c>();        
        for(LegalEntityWrapper eachWrapper : listOfLegalEntitiesWrapper){
            if(eachWrapper.blnSelected && !eachWrapper.blnRecordLocked){
                GL_Account_Legal_Entity__c objNewCLE = new GL_Account_Legal_Entity__c();
                objNewCLE.GL_Account__c = objGLA.id;
                objNewCLE.Legal_Entity__c = eachWrapper.objLegalEntity.id;
                objNewCLE.Status__c = eachWrapper.objLegalEntity.Status__c;
                /*
                if(mapOfLegalEntityIdVsApprovalCounter.get(objNewCLE.Legal_Entity__c) == null)
                    objNewCLE.Approval_Counter__c = objGLA.Approval_Counter__c == null ? 0 : objGLA.Approval_Counter__c;                
                else
                    objNewCLE.Approval_Counter__c = mapOfLegalEntityIdVsApprovalCounter.get(objNewCLE.Legal_Entity__c);  
                */
                listOfRecordsToBeInserted.add(objNewCLE);
            }
        }

        if( objGLA.Netsuite_Type__c == 'Bank' && listOfRecordsToBeInserted.size() > 1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You can select Only One Legal Entity.'));
            return;
        }
        if(!listOfRecordsToBeInserted.isEmpty())
            insert listOfRecordsToBeInserted;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Legal Entities updated successfully !'));        
    }
    
    
    public void saveCC(){
        Map<Id, Integer> mapOfLegalEntityIdVsApprovalCounter = new Map<Id, Integer>();
        List<Cost_Center_Legal_Entity__c> listOfCCLE = [SELECT id, Legal_Entity__c FROM Cost_Center_Legal_Entity__c 
                                                        WHERE Cost_Center__c =: objCC.id AND Record_Locked__c = false];        
        /*
        for(Cost_Center_Legal_Entity__c eachCCLE :listOfCCLE){
            mapOfLegalEntityIdVsApprovalCounter.put(eachCCLE.Legal_Entity__c, Integer.valueOf(eachCCLE.Approval_Counter__c));
        } */

        if( !listOfCCLE.isEmpty() ){
            delete listOfCCLE;    
        }
        List<Cost_Center_Legal_Entity__c> listOfRecordsToBeInserted = new List<Cost_Center_Legal_Entity__c>();        
        for(LegalEntityWrapper eachWrapper : listOfLegalEntitiesWrapper){
            if(eachWrapper.blnSelected && !eachWrapper.blnRecordLocked){
                Cost_Center_Legal_Entity__c objNewCLE = new Cost_Center_Legal_Entity__c();
                objNewCLE.Cost_Center__c = objCC.id;
                objNewCLE.Legal_Entity__c = eachWrapper.objLegalEntity.id;
                objNewCLE.Status__c = 'Active';
                /*
                if(mapOfLegalEntityIdVsApprovalCounter.get(objNewCLE.Legal_Entity__c) == null)
                    objNewCLE.Approval_Counter__c = objCC.Approval_Counter__c == null ? 0 : objCC.Approval_Counter__c;                
                else
                    objNewCLE.Approval_Counter__c = mapOfLegalEntityIdVsApprovalCounter.get(objNewCLE.Legal_Entity__c);
                */
                listOfRecordsToBeInserted.add(objNewCLE);
            }
        }
        if(!listOfRecordsToBeInserted.isEmpty())
            insert listOfRecordsToBeInserted;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Legal Entities updated successfully !'));        
    }
    
    
    public void saveBS(){
        Map<Id, Integer> mapOfLegalEntityIdVsApprovalCounter = new Map<Id, Integer>();
        List<Business_Segment_Legal_Entity__c> listOfBSLE = [SELECT id, Legal_Entity__c
                                                             FROM Business_Segment_Legal_Entity__c 
                                                             WHERE Business_Segment__c =: objBS.id AND Record_Locked__c = false];        
        /*
        for(Business_Segment_Legal_Entity__c eachBSLE :listOfBSLE){
            mapOfLegalEntityIdVsApprovalCounter.put(eachBSLE.Legal_Entity__c, Integer.valueOf(eachBSLE.Approval_Counter__c));
        } */

        if(!listOfBSLE.isEmpty()){
            delete listOfBSLE;    
        }
        List<Business_Segment_Legal_Entity__c> listOfRecordsToBeInserted = new List<Business_Segment_Legal_Entity__c>();        
        for(LegalEntityWrapper eachWrapper : listOfLegalEntitiesWrapper){
            if(eachWrapper.blnSelected && !eachWrapper.blnRecordLocked){
                Business_Segment_Legal_Entity__c objNewBSLE = new Business_Segment_Legal_Entity__c();
                objNewBSLE.Business_Segment__c = objBS.id;
                objNewBSLE.Legal_Entity__c = eachWrapper.objLegalEntity.id;
                /*
                if(mapOfLegalEntityIdVsApprovalCounter.get(objNewBSLE.Legal_Entity__c) == null)
                    objNewBSLE.Approval_Counter__c = objBS.Approval_Counter__c == null ? 0 : objBS.Approval_Counter__c;                
                else
                    objNewBSLE.Approval_Counter__c = mapOfLegalEntityIdVsApprovalCounter.get(objNewBSLE.Legal_Entity__c);
                */
                listOfRecordsToBeInserted.add(objNewBSLE);
            }
        }
        if(!listOfRecordsToBeInserted.isEmpty())
            insert listOfRecordsToBeInserted;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Legal Entities updated successfully !'));        
    }
    
    
    public class LegalEntityWrapper{
        public Boolean blnSelected {get; set;}
        public Legal_Entity__c objLegalEntity {get; set;}
        public Boolean blnRecordLocked {get; set;}
        public LegalEntityWrapper(Legal_Entity__c objLegalEntity, Boolean blnSelected, Boolean blnRecordLocked){
            this.objLegalEntity = objLegalEntity;
            this.blnSelected = blnSelected;
            this.blnRecordLocked = blnRecordLocked;
        }
    }

    public class BSLegalEntitiesWrapper{
        public Boolean blnSelected {get; set;}
        public Business_Segment_Legal_Entity__c objLegalEntity {get; set;}
        public Boolean blnRecordLocked {get; set;}
        public BSLegalEntitiesWrapper(Business_Segment_Legal_Entity__c objLegalEntity, Boolean blnSelected, Boolean blnRecordLocked){
            this.objLegalEntity = objLegalEntity;
            this.blnSelected = blnSelected;
            this.blnRecordLocked = blnRecordLocked;
        }
    }

    public class CCLegalEntitiesWrapper{
        public Boolean blnSelected {get; set;}
        public Cost_Center_Legal_Entity__c objLegalEntity {get; set;}
        public Boolean blnRecordLocked {get; set;}
        public CCLegalEntitiesWrapper(Cost_Center_Legal_Entity__c objLegalEntity, Boolean blnSelected, Boolean blnRecordLocked){
            this.objLegalEntity = objLegalEntity;
            this.blnSelected = blnSelected;
            this.blnRecordLocked = blnRecordLocked;
        }
    }
       
    public class GLLegalEntityWrapper{
        public Boolean blnSelected {get; set;}
        public GL_Account_Legal_Entity__c objLegalEntity {get; set;}
        public Boolean blnRecordLocked {get; set;}
        public GLLegalEntityWrapper(GL_Account_Legal_Entity__c objLegalEntity, Boolean blnSelected, Boolean blnRecordLocked){
            this.objLegalEntity = objLegalEntity;
            this.blnSelected = blnSelected;
            this.blnRecordLocked = blnRecordLocked;
        }
    }
}