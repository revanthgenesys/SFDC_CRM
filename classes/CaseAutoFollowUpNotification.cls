public virtual class CaseAutoFollowUpNotification {
    Case caseToNotify;
    String  templateBody;
    String  updateType;
   
    //Genesys_Case_Updates__c caseUpdate = null;
    FeedItem caseUpdate = null;

    static final String FOLLOW_UP_1 = 'Auto Follow-Up #1';  
    static final String FOLLOW_UP_2 = 'Auto Follow-Up #2'; 
    static final String FOLLOW_UP_3 = 'Auto Follow-Up #3'; 
        
    static Map<String, String> templateBodyMap;
    
    public CaseAutoFollowUpNotification (Case caseIn) {
        caseToNotify = caseIn;   
    }
    
    public static String populateTemplateBodyMap () {
            String errorMsg = '';   

            List<Folder> folderList = [SELECT Id, Name FROM Folder WHERE Name = 'Case Auto Follow-Ups'];
            if (folderList.size()==0)
                return 'Case AutoFollowup job failed: Template folder Case_Auto_Follow_Ups was not found.';

            templateBodyMap = new Map<String, String>();
                        
            templateBodyMap.put('Awaiting_Info_First_Follow_Up',null);
            templateBodyMap.put('Awaiting_Info_Second_Follow_Up',null);
            templateBodyMap.put('Awaiting_Info_Third_Follow_Up',null);
        
            templateBodyMap.put('Solution_Proposed_First_Follow_Up',null);
            templateBodyMap.put('Solution_Proposed_Second_Follow_Up',null);
            templateBodyMap.put('Solution_Proposed_Third_Follow_Up',null);
                                    
            List<EmailTemplate> emTmpl = [SELECT Id, DeveloperName, Body 
                                          FROM EmailTemplate 
                                          WHERE FolderId = :folderList[0].Id
                                            AND DeveloperName IN :templateBodyMap.keySet()];
                                                        
            for ( EmailTemplate eachTmpl : emTmpl) {
                if (templateBodyMap.containsKey(eachTmpl.DeveloperName)) {
                    templateBodyMap.put(eachTmpl.DeveloperName, eachTmpl.Body);
                }
            }           
            for (String key : templateBodyMap.keySet()) {
                if (templateBodyMap.get(key) == null) {
                    errorMsg += '\n Template ' + key + ' was not found.';
                }
            }   
            return errorMsg;         
    }
            
    private void setUpdatedCaseDate() {
       caseToNotify.New_Updates__c = false;
       /* MS - 9/14/2017 commented out
        caseToNotify.Last_Public_Care_Update__c = System.now();
        caseToNotify.Last_Public_Case_Update_Description__c = templateBody;
       */       
        return;
    }
    
    public Case getUpdatedCase() {
        return caseToNotify;
    }
    
     private void createCaseUpdate() {
        caseUpdate = new FeedItem();
         caseUpdate.Title = 'Auto-Follow Up';
        caseUpdate.ParentId = caseToNotify.Id;
        caseUpdate.Visibility = 'AllUsers';   
        caseUpdate.Body = templateBody;
        return;
    }   
        
    public FeedItem getCaseUpdate() {
        return caseUpdate;
    }
    
/* MS - 9/14/2017 moved to FeedItem
    private void createCaseUpdate() {
        caseUpdate = new Genesys_Case_Updates__c();
        caseUpdate.Case__c = caseToNotify.Id;
        caseUpdate.Make_Public__c = true;   
        caseUpdate.Type__c = updateType;
        caseUpdate.Description__c = templateBody;
        return;
    }   
        
    public Genesys_Case_Updates__c getCaseUpdate() {
        return caseUpdate;
    }
 */       
    public class CaseAFAwInfoFirst extends CaseAutoFollowUpNotification {
         public CaseAFAwInfoFirst (Case caseIn) {
            super(caseIn);
            templateBody = templateBodyMap.get('Awaiting_Info_First_Follow_Up');
            updateType = FOLLOW_UP_1;
            createCaseUpdate();
            setUpdatedCaseDate();
         }      
    }

    public class CaseAFAwInfoSecond extends CaseAutoFollowUpNotification {
         public CaseAFAwInfoSecond (Case caseIn) {
            super(caseIn);
            templateBody = templateBodyMap.get('Awaiting_Info_Second_Follow_Up'); 
            updateType = FOLLOW_UP_2;
            createCaseUpdate();
            setUpdatedCaseDate();
         }       
    }

    public class CaseAFAwInfoThird extends CaseAutoFollowUpNotification {
         public CaseAFAwInfoThird (Case caseIn) {
            super(caseIn);
            templateBody = templateBodyMap.get('Awaiting_Info_Third_Follow_Up'); 
            updateType = FOLLOW_UP_3;
            createCaseUpdate();
            setUpdatedCaseDate();
            populateUpdatedCaseFields();
         }  

         private void populateUpdatedCaseFields() {      
            caseToNotify.Status = 'Closed';
            caseToNotify.Sub_Status__c = 'Auto Follow-Up';
            caseToNotify.Closure_Category__c = 'Customer Closure'; 
            caseToNotify.Closure_Reason_Code__c = 'No Response from Customer';
            return;
         } 
    }

    public class CaseAFSolPrpFirst extends CaseAutoFollowUpNotification {
         public CaseAFSolPrpFirst (Case caseIn) {
            super(caseIn);
            templateBody = templateBodyMap.get('Solution_Proposed_First_Follow_Up'); 
            updateType = FOLLOW_UP_1;
            createCaseUpdate();
            setUpdatedCaseDate();
         }      
    }

    public class CaseAFSolPrpSecond extends CaseAutoFollowUpNotification {
         public CaseAFSolPrpSecond (Case caseIn) {
            super(caseIn);
            templateBody = templateBodyMap.get('Solution_Proposed_Second_Follow_Up'); 
            updateType = FOLLOW_UP_2;
            createCaseUpdate();
            setUpdatedCaseDate();
         }
    }

    public class CaseAFSolPrpThird extends CaseAutoFollowUpNotification {
         public CaseAFSolPrpThird (Case caseIn) {
            super(caseIn);
            templateBody = templateBodyMap.get('Solution_Proposed_Third_Follow_Up'); 
            updateType = FOLLOW_UP_3;
            createCaseUpdate();
            setUpdatedCaseDate();
            populateUpdatedCaseFields();
         }

         private void populateUpdatedCaseFields() {      
            caseToNotify.Status = 'Closed';
            caseToNotify.Sub_Status__c = 'Auto Follow-Up';
            return;
         } 
    }
}