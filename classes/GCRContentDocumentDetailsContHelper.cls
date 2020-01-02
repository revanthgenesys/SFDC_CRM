//Naresh Kumar  10/24/2014
public without sharing class GCRContentDocumentDetailsContHelper {
    public final static string GCR_STATUS_INITIAL = '';
    public final static string GCR_STATUS_NEW = '1-New';
    public final static string GCR_STATUS_ASSIGNED_TO_ATTORNEY = '2-Assigned to Attorney';
    public final static string GCR_STATUS_IN_PROGRESS = '3-In Progress';
    public final static string GCR_STATUS_APPROVED_BY_LEGAL = '4-Approved By Legal';
    public final static string GCR_STATUS_PENDING_FINANCE_APPROVAL = '5-Pending Finance Approval';
    public final static string GCR_STATUS_APPROVED_BY_FINANCE = '6-Approved by Finance';
    public final static string GCR_STATUS_REJECTED_BY_FINANCE = '7-Rejected by Finance';
    public final static string GCR_STATUS_METADATA_COMPLETED = '8-Metadata Complete';
    public final static string GCR_STATUS_SIGNED_BY_GENESYS = '9-Signed by Genesys';
    public final static string GCR_STATUS_SIGNED_BY_CUSTOMER = '10-Signed by Customer';
    public final static string GCR_STATUS_COMPLETED = '11-Completed';
    public final statiC string NDA_FOLDER_NAME = 'Other';
    public static final String MASTER_AGREEMENT_FOLDER = 'Master Agreement';
    public static final String MSLSA = 'MSLSA';
    public static final String NDA = 'NDA';    
    public static final String MSLSA_DEF = 'Master Software License Software Agreement';
    public static final String NDA_DEF = 'Non Disclosure / Confidentiality Agreement';
    
    public static GCR_Content_Document_Detail__c populateCurrentRecord(Id recordId){
        /*
        * @author: Ashish Goyal
        * @desc: Added some field (Contract_Category__c, Opportunity__c,Zuora_Quote__c, GCR__r.CCDB_Subscription__c, GCR__r.Contract_Type__c) in query
        * @desc: Added some field (Free_Product_or_Service_not_Quoted__c, Details_1__c,Material_Right_1__c, Description_1__c, Value_1__c, Probability_of_Occurring_1__c, Material_Right_2__c,
                                   Description_2__c,Value_2__c,Probability_of_Occurring_2__c,Material_Right_3__c,Description_3__c,Value_3__c,Probability_of_Occurring_3__c,Contract_Combination__c,
                                   Details_2__c,Varaible_Consideration__c,Details_3__c,PureBridge_Opportunity__c,Levers_Included__c) -- by Liam 8.21.2019
        */
        
        return [SELECT id, Name, Acceptance__c, Account_Name__c, Comments__c, Contract_Document_Type__c, Contract_Sub_Type__c,Legal_Exceptions__c, Free_Product_or_Service_not_Quoted__c, Details_1__c,
            Material_Right_1__c, Description_1__c, Value_1__c, Probability_of_Occurring_1__c, Material_Right_2__c,Description_2__c,Value_2__c,Probability_of_Occurring_2__c,Material_Right_3__c,
            Description_3__c,Value_3__c,Probability_of_Occurring_3__c,Contract_Combination__c,Details_2__c,Varaible_Consideration__c,Details_3__c,PureBridge_Opportunity__c,Levers_Included__c,            
            Contract_Type__c, Document_Name__c, Effective_Date__c, Expiration_Renewal_Date__c, GCR__c, Genesys_Entity__c, Contract_Category__c, Opportunity__c,
            MA_Rate__c, Folder__c, Payment_Terms__c, Pricing_End_Date__c, Pricing_Start_Date__c, Pricing_with_Termed_Discount_Period__c, Is_Governing_Contract__c,
            Revenue_Contract_Class__c, Shipping_Terms__c,Status__c,GCR__r.Subscription_Sub_Type__c,GCR__r.Opportunity__c,GCR__r.CCDB_Subscription__r.Legal_Exceptions__c,GCR__r.CCDB_Subscription__r.Opportunity_LookUp__c,
            SLA__c, Warranty_Period__c, Visibility_Status__c, Final_Attachment_Id__c, GCR__r.Offering_Type__c, Zuora_Quote__c, GCR__r.CCDB_Subscription__c, GCR__r.Contract_Type__c, 
            Completion_of_Work__c, Completion_of_Work_Other__c, Delivery__c, Delivery_Other__c, Limitation_of_Liability__c, GCR__r.CCDB_Subscription__r.Contract_Expiration_Date__c,
            Penalties__c, Penalties_Description__c, Product_Services_Other__c, Product_Services_Covered_by_Contract1__c, GCR__r.Status__c, 
            Service_Level_Agreement__c, Service_Level_Agreement_S_N__c, Warranty_Period_Start__c, GCR__r.CCDB_Subscription__r.Contract_Effective_Date__c,
            Warranty_Period_Start_Other__c, Warranty_Period_Type__c, Payment_Terms_Other__c, Approval_Status__c,
            Account_Name__r.Country__r.Region__c,Acceptance_Other__c,SLA_Other__c,Maint_SLA__c,Maint_SLA_Other__c,Shipping_Terms_Opt__c, 
            Warranty__c, Warranty_other__c,Maintenance_type__c,Maintenance_type_other__c,Maintenance_Rate__c,Finance_Comments__c,Pricing_Terms__c, 
            Pricing__c, Auto_Renew__c, Auto_Renew_For_Period__c, Contractual_Discounts__c, Agreement_Type__c, Amendments__c, Customer_Signed__c, 
            Territory_ies__c, Current_Partner_Agreement__c, Legal_Approval_Signature_Configuration__c, Partner_Agreement_Type_Other__c FROM GCR_Content_Document_Detail__c WHERE id =: recordId];
    }
    
    public static List<GCR_Content_Document_Detail__c> getDocumentsForFolder(String folderId, String accountId){
        return [SELECT id, Name, Effective_Date__c, Contract_Document_Type__c, Legal_Approval_Signature_Configuration__c FROM GCR_Content_Document_Detail__c 
            WHERE Folder__c =: folderId AND Account_Name__c =: accountId];  
    }
    
    public static GCR_Content_Document_Folder__c populateFolderRecord(String recordId){
        return [SELECT Name, Account__c, GCR__c, Parent_Folder__c FROM GCR_Content_Document_Folder__c 
            WHERE id =: recordId];
    }
    
    public static GCR__c populateGCR(String gcrId){
        return [SELECT Status__c, Attorney_Name__c,Partner_Contract_Type__c,Partner_Contract_Type_Other__c,Partner_Application__c,Contract_Type__c FROM GCR__c WHERE id =: gcrId];
    }
    
    public static Account populateCurrentAccount(Id accountId){
        return [SELECT Name FROM Account WHERE id =: accountId];
    }
    
    public static String getURLParams(String accountId, String gcrId, Boolean hideHeader, Boolean embedded, Boolean showAll, Boolean isAdminUser, Boolean showFromCurrentGCR){
        return '&accId='+accountId+'&showAll='+showAll+'&embedded='+embedded+'&hideHeader='+hideHeader+'&gcrId='+gcrId+'&isAdminUser='+isAdminUser + '&showFromCurrentGCR=' + showFromCurrentGCR;
    }
    
    private static List<GCRContentDocumentDetailsController.treeNodes> populateChildRecords(Id currentRecordId, Map<Id, GCR_Content_Document_Folder__c> mapFolderIdVsRecord,
        Map<Id, List<Id>> mapParentIdVsFolderIds, Map<Id, GCR_Content_Document_Detail__c> mapDocumentIdVsRecord, Map<Id, List<Id>> mapParentFolderIdVsDocumentIds, String accountId, 
        String gcrId, String currentDocumentId, Boolean hideHeader, Boolean embedded, Boolean showAll, Boolean showFromCurrentGCR){
            
        List<GCRContentDocumentDetailsController.treeNodes> treeNodes = new List<GCRContentDocumentDetailsController.treeNodes>();
        //Child folders
        List<Id> childFolderIds = mapParentIdVsFolderIds.get(currentRecordId);  
        System.debug('NKC debug childFolderIds ['+childFolderIds+']');
        System.debug('NKC debug mapParentIdVsFolderIds ['+mapParentIdVsFolderIds+']');
        System.debug('NKC debug currentRecordId ['+currentRecordId+']');
                
        if(childFolderIds != null){
            for(Id eachFolderId : childFolderIds){
                //Child Folders
                Boolean isFolder = true;                
                
                String deleteFolderLink = '&nbsp;<a href="#" onclick="location.href=\'/apex/GCRContentDocumentDetails?accId='+accountId+'&gcrId='+gcrId+'&showAll='+showAll+'&embedded='+embedded+'&hideHeader='+hideHeader + '&showFromCurrentGCR=' + showFromCurrentGCR+'&folderId='+ eachFolderId +'\'">[View]</a>';
                String record = mapFolderIdVsRecord.get(eachFolderId).Name + deleteFolderLink;
                List<GCRContentDocumentDetailsController.treeNodes> childRecords = populateChildRecords(eachFolderId, mapFolderIdVsRecord, mapParentIdVsFolderIds,
                    mapDocumentIdVsRecord, mapParentFolderIdVsDocumentIds, accountId, gcrId, currentDocumentId, hideHeader, embedded, showAll, showFromCurrentGCR); 
                GCRContentDocumentDetailsController.treeNodes newNode = new GCRContentDocumentDetailsController.treeNodes(record, childRecords, isFolder, eachFolderId);
                treeNodes.add(newNode);
            }           
        }       
        //Child documents
        List<Id> childDocumentIds = mapParentFolderIdVsDocumentIds.get(currentRecordId);
        if(childDocumentIds != null){
            for(Id eachDocumentId : childDocumentIds){
                Boolean isFolder = false;
                Date expDate = mapDocumentIdVsRecord.get(eachDocumentId).Expiration_Renewal_Date__c;
                String expirationDate = expDate == null ? '' : ' - ' + expDate.format();
                String currentDocumentStyle = ';';
                if(eachDocumentId == currentDocumentId){
                    currentDocumentStyle = 'font-weight:bold;background-color:#8a9ebe;color:#ffffff;';
                }
                String title = '<a href="#" style="'+currentDocumentStyle+';text-decoration:none;" onclick="location.href=\'/apex/GCRContentDocumentDetails?id=' + mapDocumentIdVsRecord.get(eachDocumentId).id  + '&accId='+accountId+'&showAll='+showAll+'&embedded='+embedded+'&hideHeader='+hideHeader + '&showFromCurrentGCR=' + showFromCurrentGCR+'&gcrId='+gcrId+'\'; return false;"> &nbsp;' + mapDocumentIdVsRecord.get(eachDocumentId).Document_Name__c + expirationDate + ' &nbsp;</a>';
                String record = title;
                GCRContentDocumentDetailsController.treeNodes newNode = new GCRContentDocumentDetailsController.treeNodes(record, null, isFolder, eachDocumentId);
                newNode.isDocument = true;
                treeNodes.add(newNode);
            }       
        }
        /*
        //Add New Folder
        String addNewStr = getAddNewDocumentString(currentRecordId, accountId, gcrId);
        GCRContentDocumentDetailsController.treeNodes newNode = new GCRContentDocumentDetailsController.treeNodes(addNewStr, null, false, currentRecordId);
        newNode.isAddFolder = true;
        treeNodes.add(newNode);
        //Add New Document
        addNewStr = '<a href="#" onclick="location.href=\'/apex/GCRContentDocumentDetails?addNewDocument=true&accId='+accountId+'&gcrId='+gcrId+'&parentId='+currentRecordId+'\'; return false;" style="text-decoration:none; color:green;"> Add Document </a>';
        newNode = new GCRContentDocumentDetailsController.treeNodes(addNewStr, null, false, currentRecordId);
        newNode.isAddDocument = true;
        treeNodes.add(newNode);
        */
        return treeNodes;
    }
    
    private static String getAddNewDocumentString(String parentId, String accountId, String gcrId, Boolean hideHeader, Boolean embedded, Boolean showAll, Boolean showFromCurrentGCR){
        
        //String addNewStr = '<a href="#" onclick="location.href=\'/apex/GCRContentDocumentDetails?accId='+accountId+'&gcrId='+gcrId+'&addNewFolder=true&showAll='+showAll+'&embedded='+embedded+'&hideHeader='+hideHeader+'&parentId='+parentId+'\'; return false;" style="text-decoration:none; color:green;"> Add Folder1 </a>';
        String addNewStr = '<a href="#" onclick="location.href=\'/apex/GCRContentDocumentDetails?&accId='+accountId+'&showAll='+showAll+'&embedded='+embedded+'&hideHeader='+hideHeader + '&showFromCurrentGCR=' + showFromCurrentGCR+'&gcrId='+gcrId+'&addNewDocument=true\'; return false;"> Add New Document </a>';
        return addNewStr;
    }
    
    public static List<SelectOption> getFoldersAsListItems(String accountId){
        List<SelectOption> folderList = new List<SelectOption>();
        List<GCR_Content_Document_Folder__c> folders = [SELECT id, Name FROM GCR_Content_Document_Folder__c WHERE Active__c = true 
            AND (Account__c =: accountId OR Account__c = NULL) ORDER BY Name ASC];
        for(GCR_Content_Document_Folder__c eachFolder : folders){
            folderList.add(new SelectOption(eachFolder.id, eachFolder.Name));   
        }   
        return folderList;
    }

    public static List<GCRContentDocumentDetailsController.treeNodes> populateTreeItems(String accountId, String gcrId, Boolean isAdminUser, 
        String currentDocumentId, Boolean hideHeader, Boolean embedded, Boolean showAll,  Boolean showFromCurrentGCR){
        
        List<GCR_Content_Document_Detail__c> childRecords;
        String query = 'SELECT id, Folder__c, Document_Name__c, Account_Name__r.Name, '
                + 'Folder__r.Parent_Folder__c, '
                + 'Folder__r.Parent_Folder__r.Parent_Folder__c, '
                + 'Folder__r.Parent_Folder__r.Parent_Folder__r.Parent_Folder__c, '
                + 'Folder__r.Parent_Folder__r.Parent_Folder__r.Parent_Folder__r.Parent_Folder__c, '                      
                + 'Expiration_Renewal_Date__c FROM GCR_Content_Document_Detail__c WHERE Account_Name__c =: accountId AND Active__c = true '; 
                
        if(!isAdminUser)
            query += ' AND Visibility_Status__c = \'Visible\'';
        
        if(!showAll)
            query += ' AND ( Expiration_Renewal_Date__c >= TODAY OR Expiration_Renewal_Date__c = NULL) ';
            
        if(showFromCurrentGCR != null && showFromCurrentGCR && gcrId != null && gcrId != 'null')
            query += ' AND GCR__c = \'' + gcrId + '\' ';
            
        query += ' ORDER BY CreatedDate DESC ';
        System.debug('NKC debug query ['+query+']');
        childRecords = (List<GCR_Content_Document_Detail__c>)Database.query(query);
        Set<Id> folderIds = new Set<Id>();
        //Looping over each document to get folder id
        for(GCR_Content_Document_Detail__c eachDocument : childRecords){
            folderIds.add(eachDocument.Folder__c);
            if(eachDocument.Folder__r.Parent_Folder__c != null)
                folderIds.add(eachDocument.Folder__r.Parent_Folder__c);
            if(eachDocument.Folder__r.Parent_Folder__r.Parent_Folder__c != null)
                folderIds.add(eachDocument.Folder__r.Parent_Folder__r.Parent_Folder__c);
            if(eachDocument.Folder__r.Parent_Folder__r.Parent_Folder__r.Parent_Folder__c != null)
                folderIds.add(eachDocument.Folder__r.Parent_Folder__r.Parent_Folder__r.Parent_Folder__c);
            if(eachDocument.Folder__r.Parent_Folder__r.Parent_Folder__r.Parent_Folder__r.Parent_Folder__c != null)
                folderIds.add(eachDocument.Folder__r.Parent_Folder__r.Parent_Folder__r.Parent_Folder__r.Parent_Folder__c);
        }
        List<GCR_Content_Document_Folder__c> folders = [SELECT Name, Parent_Folder__c 
            FROM GCR_Content_Document_Folder__c WHERE Active__c = true AND (id IN : folderIds OR (Account__c =: accountId AND Parent_Folder__c != NULL)) ORDER BY CreatedDate DESC];
        //Map of id vs folder record
        Map<Id, GCR_Content_Document_Folder__c> mapFolderIdVsRecord = new Map<Id, GCR_Content_Document_Folder__c>();
        //Map of id vs parent id
        Map<Id, List<Id>> mapParentIdVsFolderIds = new Map<Id, List<Id>>();     
        //Looping over all folders
        for(GCR_Content_Document_Folder__c eachFolder : folders){
            mapFolderIdVsRecord.put(eachFolder.id, eachFolder);
            if(eachFolder.Parent_Folder__c != null){
                if(mapParentIdVsFolderIds.get(eachFolder.Parent_Folder__c) == null){
                    List<Id> newList = new List<Id>();
                    newList.add(eachFolder.id);
                    mapParentIdVsFolderIds.put(eachFolder.Parent_Folder__c, newList);
                }
                else
                    mapParentIdVsFolderIds.get(eachFolder.Parent_Folder__c).add(eachFolder.id);
            }               
        }                 
        //Map of id vs document record
        Map<Id, GCR_Content_Document_Detail__c> mapDocumentIdVsRecord = new Map<Id, GCR_Content_Document_Detail__c>();
        //Map of document id vs parent folder id
        Map<Id, List<Id>> mapParentFolderIdVsDocumentIds = new Map<Id, List<Id>>();
        //Looping over all documents
        for(GCR_Content_Document_Detail__c eachDocument : childRecords){
            mapDocumentIdVsRecord.put(eachDocument.id, eachDocument);
            if(mapParentFolderIdVsDocumentIds.get(eachDocument.Folder__c) == null){
                List<Id> newList = new List<Id>();
                newList.add(eachDocument.id);
                mapParentFolderIdVsDocumentIds.put(eachDocument.Folder__c, newList);                
            }
            else
                mapParentFolderIdVsDocumentIds.get(eachDocument.Folder__c).add(eachDocument.id);            
        }
        //Contains whole tree
        List<GCRContentDocumentDetailsController.treeNodes> treeItems = new List<GCRContentDocumentDetailsController.treeNodes>();
        for(Id eachFolderId : mapFolderIdVsRecord.keyset()){
            if(mapFolderIdVsRecord.get(eachFolderId).Parent_Folder__c != null)
                continue;
            Boolean isFolder = true;
            
            String deleteFolderLink = '&nbsp;<a href="#" onclick="location.href=\'/apex/GCRContentDocumentDetails?accId='+accountId+'&gcrId='+gcrId+'&showAll='+showAll+'&embedded='+embedded+'&hideHeader='+hideHeader + '&showFromCurrentGCR=' + showFromCurrentGCR+'&folderId='+ eachFolderId +'\'">[View]</a>';
            String record = mapFolderIdVsRecord.get(eachFolderId).Name + deleteFolderLink;
            List<GCRContentDocumentDetailsController.treeNodes> childRecords1 = populateChildRecords(eachFolderId, mapFolderIdVsRecord, mapParentIdVsFolderIds,
                mapDocumentIdVsRecord, mapParentFolderIdVsDocumentIds, accountId, gcrId, currentDocumentId, hideHeader, embedded, showAll, showFromCurrentGCR); 
            GCRContentDocumentDetailsController.treeNodes newNode = new GCRContentDocumentDetailsController.treeNodes(record, childRecords1, isFolder, eachFolderId);
            treeItems.add(newNode);         
        }
        //Add New Document (top level)
        if(isAdminUser){
            String addNewStr = getAddNewDocumentString('', accountId, gcrId, hideHeader, embedded, showAll, showFromCurrentGCR);
            GCRContentDocumentDetailsController.treeNodes newNode = new GCRContentDocumentDetailsController.treeNodes(addNewStr, null, false, null);
            newNode.isAddDocumentTop = true;            
            treeItems.add(newNode);
        }
        return treeItems;       
    }
    
    public static List<SelectOption> populateAccounts(){
        List<SelectOption> accountOptions = new List<SelectOption>();
        List<Account> accounts = [SELECT id, Name FROM Account WHERE RecordType.DeveloperName = 'Party_Account' ORDER BY Name LIMIT 500];
        for(Account eachAccount : accounts){
            accountOptions.add(new SelectOption(eachAccount.id, eachAccount.Name));
        }
        return accountOptions;
    }
    
    public static Boolean checkForAdminUser(){
        List<String> profileNames = Label.GCR_Admin_Profiles.split(',');
        Map<Id, Profile> profiles = new Map<Id, Profile>([SELECT id FROM Profile WHERE Name IN : profileNames]);
        if(profiles.keyset().contains(UserInfo.getProfileId()))         
            return true;
        else
            return false;
    }
    
    public static Boolean checkForAdminDeleteUser(){
        List<String> profileNames = Label.GCR_Admin_Delete_Profiles.split(',');
        Map<Id, Profile> profiles = new Map<Id, Profile>([SELECT id FROM Profile WHERE Name IN : profileNames]);
        if(profiles.keyset().contains(UserInfo.getProfileId()))         
            return true;
        else
            return false;
    }
    
    public static List<SelectOption> getApprovers(){
        List<SelectOption> approversOptions = new List<SelectOption>();
        approversOptions.add(new SelectOption('', '--Select--'));
        for(Legal_Approval_Configuration__c eachConfig : [SELECT id,label__c FROM Legal_Approval_Configuration__c]){
            approversOptions.add(new SelectOption(eachConfig.id, eachConfig.label__c));
        }
        return approversOptions;
    }
}