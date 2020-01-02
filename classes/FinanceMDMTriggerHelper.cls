public class FinanceMDMTriggerHelper {
	
    public static void updateReferenceData(List<Reference_Data__c> newList, Map<Id, Reference_Data__c> oldMap){
        Boolean blnBlackoutPeriod = CostCenterUtil.getBlackoutFlag();             
        for(Reference_Data__c eachCC : newList){
            //eachCC.Name = eachCC.Data_Element_ID__c+'-'+ eachCC.Data_Element_ID_Description__c;
            
             string strdigits;
            if(string.valueOf(eachCC.Data_Element_ID__c).length()<= 1)
                strdigits = '1000';
            else
                strdigits = '100';
            
            eachCC.Name = strdigits + eachCC.Data_Element_ID__c+'-'+ eachCC.Data_Element_ID_Description__c;
        
            if(oldMap == null || (eachCC.Approval_Status__c == 'New' && oldMap.get(eachCC.id).Approval_Status__c != 'New')){
              eachCC.Blackout_Period__c = blnBlackoutPeriod;  
            }    
        }
    }
    
    
    public static void updateGlAccount(List<GL_Account__c> newList, Map<Id, GL_Account__c> oldMap){     
        Boolean blnBlackoutPeriod = CostCenterUtil.getBlackoutFlag();
        
        for(GL_Account__c obj : newList) {
            obj.Name = obj.Proposed_GL_Account_ID__c +'-'+ obj.Description__c;
   
            if(oldMap == null || (obj.Approval_Status__c == 'New' && oldMap.get(obj.id).Approval_Status__c != 'New')){
              obj.Blackout_Period__c = blnBlackoutPeriod;  
            }
        }
    }
    
    
    public static void updateHierarchy(List<Hierarchy__c> newList, Map<Id, Hierarchy__c> oldMap){
        
        Map<string,Hierarchy__c> objTopNodeID = new Map<string,Hierarchy__c>();
        Map<String, List<Hierarchy__c>> map_HierarchyIdUniqueNode = new Map<String, List<Hierarchy__c>>();
        
        //Set Top Node ID
        List<Hierarchy__c> objHierarchy = [SELECT Id, Node_ID1__c, Hierarchy_Description__c FROM Hierarchy__c WHERE level__c = 1];      
        for(Hierarchy__c obj : objHierarchy)
            objTopNodeID.put(obj.Hierarchy_Description__c,obj);     
        
        //Check Unique Hierarchy
        
        for(Hierarchy__c obj : newList){
            String topNodeId = '';
            if(objTopNodeID.containsKey(obj.Hierarchy_Description__c)){
                topNodeId = objTopNodeID.get(obj.Hierarchy_Description__c).Node_ID1__c;
            }
            string strUniqueHierarchy = topNodeId + obj.Node_ID1__c;
            if(!map_HierarchyIdUniqueNode.containsKey(strUniqueHierarchy)){
                map_HierarchyIdUniqueNode.put(strUniqueHierarchy, new List<Hierarchy__c>());
            }
            map_HierarchyIdUniqueNode.get(strUniqueHierarchy).add(obj);
        }
        
        //Check Unique Hierarchy
        
        if(map_HierarchyIdUniqueNode.size() > 0){
            List<Hierarchy__c> lstAllHierarchy = new List<Hierarchy__c>();
            if(oldMap != null)
                lstAllHierarchy = [SELECT Id, Unique_Hierarchy_ID1__c FROM Hierarchy__c WHERE Unique_Hierarchy_ID1__c IN : map_HierarchyIdUniqueNode.keySet() AND ID NOT IN :newList];
            else
                lstAllHierarchy = [SELECT Id, Unique_Hierarchy_ID1__c FROM Hierarchy__c WHERE Unique_Hierarchy_ID1__c IN : map_HierarchyIdUniqueNode.keySet()];
                
            if(lstAllHierarchy != null && lstAllHierarchy.size()>0){
                for(Hierarchy__c hierObj : lstAllHierarchy){
                    for(Hierarchy__c hierarchyObj : map_HierarchyIdUniqueNode.get(hierObj.Unique_Hierarchy_ID1__c)){
                        hierarchyObj.addError('Duplicate Record Found!! Please check Top Node ID and Node ID, combination should be Unique.');
                    }
                }
            }
        }
        
        for(Hierarchy__c obj : newList) {
            //Set SFDC Record Name
            obj.Name = obj.Node_ID1__C +'-'+ obj.Node_Description__c;
            
            //Set Top Node ID
            if(obj.Level__C != 1)
                obj.Top_Node_ID1__c = objTopNodeID.get(obj.Hierarchy_Description__c).Id;
        }
    }
    
    
    public static void checkDuplicateGLIdOrDescription(List<GL_Account__c> listOfNewRecords){
        Map<String, List<GL_Account__c>> map_ObjectRecordNId = new Map<String, List<GL_Account__c>>();
        Map<String, List<GL_Account__c>> map_ObjectRecordNDesc = new Map<String, List<GL_Account__c>>();
        for(GL_Account__c obj : listOfNewRecords){
            if(!map_ObjectRecordNId.containsKey(obj.Proposed_GL_Account_ID__c)){
                map_ObjectRecordNId.put(obj.Proposed_GL_Account_ID__c, new List<GL_Account__c>());
            }
            if(!map_ObjectRecordNDesc.containsKey(obj.Description__c)){
                map_ObjectRecordNDesc.put(obj.Description__c, new List<GL_Account__c>());
            }
            map_ObjectRecordNId.get(obj.Proposed_GL_Account_ID__c).add(obj);
            map_ObjectRecordNDesc.get(obj.Description__c).add(obj);
        }
        List<GL_Account__c> exsitingRecords = [SELECT id, Proposed_GL_Account_ID__c FROM GL_Account__c WHERE Proposed_GL_Account_ID__c IN: map_ObjectRecordNId.keySet()
                                                  AND id NOT IN: listOfNewRecords];
        if(!exsitingRecords.isEmpty()){
            for(GL_Account__c obj : exsitingRecords){
                for(GL_Account__c objNew : map_ObjectRecordNId.get(obj.Proposed_GL_Account_ID__c)){
                    objNew.addError('GL Number already exists. Please use different GL Number.');
                }
            }                   
            return;
        }
        
        exsitingRecords = [SELECT id, Description__c FROM GL_Account__c WHERE Description__c IN: map_ObjectRecordNDesc.keySet()
                              AND id NOT IN: listOfNewRecords];
        if(!exsitingRecords.isEmpty()){
            for(GL_Account__c obj : exsitingRecords){
                for(GL_Account__c objNew : map_ObjectRecordNDesc.get(obj.Description__c)){
                    objNew.addError('Description already exists. Please use different Description.');
                }
            }
            return;
        }
    }
    
    
    public static void checkDuplicateLegalIdOrDescription(List<Legal_Entity__c> listOfNewRecords){
        Map<String, List<Legal_Entity__c>> map_ObjectRecordNId = new Map<String, List<Legal_Entity__c>>();
        Map<String, List<Legal_Entity__c>> map_ObjectRecordNDesc = new Map<String, List<Legal_Entity__c>>();
        for(Legal_Entity__c obj : listOfNewRecords){
            if(!map_ObjectRecordNId.containsKey(obj.Legal_Entity_ID__c)){
                map_ObjectRecordNId.put(obj.Legal_Entity_ID__c, new List<Legal_Entity__c>());
            }
            if(!map_ObjectRecordNDesc.containsKey(obj.Name_No_Hierarchy__c)){
                map_ObjectRecordNDesc.put(obj.Name_No_Hierarchy__c, new List<Legal_Entity__c>());
            }
            map_ObjectRecordNId.get(obj.Legal_Entity_ID__c).add(obj);
            map_ObjectRecordNDesc.get(obj.Name_No_Hierarchy__c).add(obj);
        }
        List<Legal_Entity__c> exsitingRecords = [SELECT id, Legal_Entity_ID__c FROM Legal_Entity__c WHERE Legal_Entity_ID__c IN: map_ObjectRecordNId.keySet()
                                                  AND id NOT IN: listOfNewRecords];
        if(!exsitingRecords.isEmpty()){
            for(Legal_Entity__c obj : exsitingRecords){
                for(Legal_Entity__c objNew : map_ObjectRecordNId.get(obj.Legal_Entity_ID__c)){
                    objNew.addError('Legal Entity ID already exists. Please use different Legal Entity ID.');
                }
            }                   
            return;
        }
        
        exsitingRecords = [SELECT id, Name_No_Hierarchy__c FROM Legal_Entity__c WHERE Name_No_Hierarchy__c IN: map_ObjectRecordNDesc.keySet()
                              AND id NOT IN: listOfNewRecords];
        if(!exsitingRecords.isEmpty()){
            for(Legal_Entity__c obj : exsitingRecords){
                for(Legal_Entity__c objNew : map_ObjectRecordNDesc.get(obj.Name_No_Hierarchy__c)){
                    objNew.addError('Legal Entity Name already exists. Please use different Legal Entity Name.');
                }
            }
            return;
        }
    }
    
    
    public static void checkDuplicateCurrencyIdOrDescription(List<Currencies__c> listOfNewRecords){
        Map<String, List<Currencies__c>> map_ObjectRecordNId = new Map<String, List<Currencies__c>>();
        Map<String, List<Currencies__c>> map_ObjectRecordNDesc = new Map<String, List<Currencies__c>>();
        for(Currencies__c obj : listOfNewRecords){
            if(!map_ObjectRecordNId.containsKey(obj.Currency_ISO_Code__c)){
                map_ObjectRecordNId.put(obj.Currency_ISO_Code__c, new List<Currencies__c>());
            }
            if(!map_ObjectRecordNDesc.containsKey(obj.Currency_Key__c)){
                map_ObjectRecordNDesc.put(obj.Currency_Key__c, new List<Currencies__c>());
            }
            map_ObjectRecordNId.get(obj.Currency_ISO_Code__c).add(obj);
            map_ObjectRecordNDesc.get(obj.Currency_Key__c).add(obj);
        }
        List<Currencies__c> exsitingRecords = [SELECT id, Currency_ISO_Code__c FROM Currencies__c WHERE Currency_ISO_Code__c IN: map_ObjectRecordNId.keySet()
                                                  AND id NOT IN: listOfNewRecords];
        if(!exsitingRecords.isEmpty()){
            for(Currencies__c obj : exsitingRecords){
                for(Currencies__c objNew : map_ObjectRecordNId.get(obj.Currency_ISO_Code__c)){
                    objNew.addError('Currency ISO Code already exists. Please use different Currency ISO Code.');
                }
            }                   
            return;
        }
        
        exsitingRecords = [SELECT id, Currency_Key__c FROM Currencies__c WHERE Currency_Key__c IN: map_ObjectRecordNDesc.keySet()
                              AND id NOT IN: listOfNewRecords];
        if(!exsitingRecords.isEmpty()){
            for(Currencies__c obj : exsitingRecords){
                for(Currencies__c objNew : map_ObjectRecordNDesc.get(obj.Currency_Key__c)){
                    objNew.addError('Currency Key already exists. Please use different Currency Key.');
                }
            }
            return;
        }
    }
    
    
    public static void populateBlackoutNRecordNameOnCurrency(List<Currencies__c> newList, Map<Id, Currencies__c> oldMap){
        Boolean blnBlackoutPeriod = CostCenterUtil.getBlackoutFlag();             
        for(Currencies__c obj : newList){
            obj.Name = obj.Currency_Key__c+'-'+ obj.Description__c;
            if(oldMap == null || (obj.Approval_Status__c == 'New' && oldMap.get(obj.id).Approval_Status__c != 'New')){
              obj.Blackout_Period__c = blnBlackoutPeriod;  
            }    
        }
    }
    
    
    public static void onBeforeInsertBR(List<Business_Region__c> listOfNewRecords){        
        checkDuplicateIdOrDescription(listOfNewRecords);
        popualateBlackoutFlag(listOfNewRecords, null);
    }
    
    public static void onBeforeUpdateBR(List<Business_Region__c> listOfNewRecords, Map<Id, Business_Region__c> oldMap){ 
        checkDuplicateIdOrDescription(listOfNewRecords);
        popualateBlackoutFlag(listOfNewRecords, oldMap);
    }
    
    private static void popualateBlackoutFlag(List<Business_Region__c> listOfNewRecords, Map<Id, Business_Region__c> oldMap){        
        Boolean blnBlackoutPeriod = CostCenterUtil.getBlackoutFlag();             
        for(Business_Region__c eachRegion : listOfNewRecords){
            if(oldMap == null || (eachRegion.Approval_Status__c == 'New' && oldMap.get(eachRegion.id).Approval_Status__c != 'New')){
                eachRegion.Blackout_Period__c = blnBlackoutPeriod;  
            }    
        }        
    }
    
    private static void checkDuplicateIdOrDescription(List<Business_Region__c> listOfNewRecords){
        Map<String, List<Business_Region__c>> map_ObjectRecordNId = new Map<String, List<Business_Region__c>>();
        Map<String, List<Business_Region__c>> map_ObjectRecordNDesc = new Map<String, List<Business_Region__c>>();
        for(Business_Region__c obj : listOfNewRecords){
            if(!map_ObjectRecordNId.containsKey(obj.Region_ID__c)){
                map_ObjectRecordNId.put(obj.Region_ID__c, new List<Business_Region__c>());
            }
            if(!map_ObjectRecordNDesc.containsKey(obj.Description__c)){
                map_ObjectRecordNDesc.put(obj.Description__c, new List<Business_Region__c>());
            }
            map_ObjectRecordNId.get(obj.Region_ID__c).add(obj);
            map_ObjectRecordNDesc.get(obj.Description__c).add(obj);
        }
        List<Business_Region__c> exsitingRecords = [SELECT id, Region_ID__c FROM Business_Region__c WHERE Region_ID__c IN: map_ObjectRecordNId.keySet()
                                                  AND id NOT IN: listOfNewRecords];
        if(!exsitingRecords.isEmpty()){
            for(Business_Region__c obj : exsitingRecords){
                for(Business_Region__c objNew : map_ObjectRecordNId.get(obj.Region_ID__c)){
                    objNew.addError('Business Region ID already exists. Please use different Business Region ID.');
                }
            }                   
            return;
        }
        
        exsitingRecords = [SELECT id, Description__c FROM Business_Region__c WHERE Description__c IN: map_ObjectRecordNDesc.keySet()
                              AND id NOT IN: listOfNewRecords];
        if(!exsitingRecords.isEmpty()){
            for(Business_Region__c obj : exsitingRecords){
                for(Business_Region__c objNew : map_ObjectRecordNDesc.get(obj.Description__c)){
                    objNew.addError('Description already exists. Please use different Description.');
                }
            }
            return;
        }
    }
    
    public static void onBeforeInsertBS(List<Business_Segment__c> listOfNewRecords){        
        checkDuplicateIdOrDescription(listOfNewRecords);
        popualateBlackoutFlag(listOfNewRecords, null);
    }
    
    public static void onBeforeUpdateBS(List<Business_Segment__c> listOfNewRecords, Map<Id, Business_Segment__c> oldMap){ 
        checkDuplicateIdOrDescription(listOfNewRecords);
        popualateBlackoutFlag(listOfNewRecords, oldMap);
    }
    
    private static void popualateBlackoutFlag(List<Business_Segment__c> listOfNewRecords, Map<Id, Business_Segment__c> oldMap){        
        Boolean blnBlackoutPeriod = CostCenterUtil.getBlackoutFlag();             
        for(Business_Segment__c eachRegion : listOfNewRecords){
            if(oldMap == null || (eachRegion.Approval_Status__c == 'New' && oldMap.get(eachRegion.id).Approval_Status__c != 'New')){
                eachRegion.Blackout_Period__c = blnBlackoutPeriod;  
            }    
        }        
    }
    
    private static void checkDuplicateIdOrDescription(List<Business_Segment__c> listOfNewRecords){
        Map<String, List<Business_Segment__c>> map_ObjectRecordNId = new Map<String, List<Business_Segment__c>>();
        Map<String, List<Business_Segment__c>> map_ObjectRecordNDesc = new Map<String, List<Business_Segment__c>>();
        for(Business_Segment__c obj : listOfNewRecords){
            if(!map_ObjectRecordNId.containsKey(obj.Business_Segment_ID__c)){
                map_ObjectRecordNId.put(obj.Business_Segment_ID__c, new List<Business_Segment__c>());
            }
            if(!map_ObjectRecordNDesc.containsKey(obj.Description__c)){
                map_ObjectRecordNDesc.put(obj.Description__c, new List<Business_Segment__c>());
            }
            map_ObjectRecordNId.get(obj.Business_Segment_ID__c).add(obj);
            map_ObjectRecordNDesc.get(obj.Description__c).add(obj);
        }
        List<Business_Segment__c> exsitingRecords = [SELECT id, Business_Segment_ID__c FROM Business_Segment__c WHERE Business_Segment_ID__c IN: map_ObjectRecordNId.keySet()
                                                  AND id NOT IN: listOfNewRecords];
        if(!exsitingRecords.isEmpty()){
            for(Business_Segment__c obj : exsitingRecords){
                for(Business_Segment__c objNew : map_ObjectRecordNId.get(obj.Business_Segment_ID__c)){
                    objNew.addError('Business Segment ID already exists. Please use different Business Segment ID.'); 
                }
            }                   
            return;
        }
        
        exsitingRecords = [SELECT id, Description__c FROM Business_Segment__c WHERE Description__c IN: map_ObjectRecordNDesc.keySet()
                              AND id NOT IN: listOfNewRecords];
        if(!exsitingRecords.isEmpty()){
            for(Business_Segment__c obj : exsitingRecords){
                for(Business_Segment__c objNew : map_ObjectRecordNDesc.get(obj.Description__c)){
                    objNew.addError('Description already exists. Please use different Description.'); 
                }
            }
            return;
        }
    }
    
    
    public static void onBeforeInsertCC(List<Cost_Center__c> listOfNewRecords){        
        populateCostCenterID(listOfNewRecords);
        checkDuplicateForCCIdOrDescription(listOfNewRecords);
        popualateBlackoutFlag(listOfNewRecords, null);
        resetApprovalCounterOnInsert(listOfNewRecords);
    }
    
    public static void onBeforeUpdateCC(List<Cost_Center__c> listOfNewRecords, Map<Id, Cost_Center__c> oldMap){        
        populateCostCenterID(listOfNewRecords);
        checkDuplicateForCCIdOrDescription(listOfNewRecords);
        popualateBlackoutFlag(listOfNewRecords, oldMap);        
    }
    
    private static void resetApprovalCounterOnInsert(List<Cost_Center__c> listOfNewRecords){         
        for(Cost_Center__c eachCC : listOfNewRecords){
            eachCC.Approval_Counter__c = 0;
        }        
    }
    
    private static void populateCostCenterID(List<Cost_Center__c> listOfNewRecords){         
        for(Cost_Center__c eachCC : listOfNewRecords){
            eachCC.Cost_Center_ID__c = eachCC.Function_ID__c + eachCC.Region_ID__c;
        }        
    }
    
    private static void checkDuplicateForCCIdOrDescription(List<Cost_Center__c> listOfNewRecords){
        Cost_Center__c objNewCC = listOfNewRecords[0];
        List<Cost_Center__c> exsitingCostCenter = [SELECT id FROM Cost_Center__c WHERE Cost_Center_ID__c =: objNewCC.Cost_Center_ID__c
                                                  AND id !=: objNewCC.id];
        if(!exsitingCostCenter.isEmpty()){
            objNewCC.addError('Cost Center ID already exists. Please make Cost Center Id is unique.');        
            return;
        }
        exsitingCostCenter = [SELECT id FROM Cost_Center__c WHERE Description__c =: objNewCC.Description__c
                              AND id !=: objNewCC.id];
        if(!exsitingCostCenter.isEmpty()){
            objNewCC.addError('Description already exists. Please make sure Description is unique.');        
            return;
        }
    }
    
    private static void popualateBlackoutFlag(List<Cost_Center__c> listOfNewRecords, Map<Id, Cost_Center__c> oldMap){        
        Boolean blnBlackoutPeriod = CostCenterUtil.getBlackoutFlag();             
        for(Cost_Center__c eachCC : listOfNewRecords){
            if(oldMap == null || (eachCC.Approval_Status__c == 'New' && oldMap.get(eachCC.id).Approval_Status__c != 'New')){
              eachCC.Blackout_Period__c = blnBlackoutPeriod;  
            }    
        }        
    }
    
    
    
    public static void onBeforeInsertHI(List<Hierarchy__c> listOfNewRecords){        
        popualateBlackoutFlag(listOfNewRecords, null);
    }
    
    public static void onBeforeUpdateHI(List<Hierarchy__c> listOfNewRecords, Map<Id, Hierarchy__c> oldMap){ 
        popualateBlackoutFlag(listOfNewRecords, oldMap);
    }
    
    private static void popualateBlackoutFlag(List<Hierarchy__c> listOfNewRecords, Map<Id, Hierarchy__c> oldMap){        
        Boolean blnBlackoutPeriod = CostCenterUtil.getBlackoutFlag();             
        for(Hierarchy__c eachRegion : listOfNewRecords){
            if(oldMap == null || (eachRegion.Approval_Status__c == 'New' && oldMap.get(eachRegion.id).Approval_Status__c != 'New')){
              eachRegion.Blackout_Period__c = blnBlackoutPeriod;  
            }    
        }        
    }
    
    
    public static void checkParentNode_beforeUpdate(Map<ID,Hierarchy__c> oldMap, List<Hierarchy__c> newList){   
        List<ID> parentNodeIDList = new List<ID>();
        Map<ID,Decimal> parentNodeToLevelMap = new Map<ID,Decimal>();
         
        for(Hierarchy__c hier: newList){
            parentNodeIDList.add(hier.Parent_Node_ID1__c);
        }
         
        List<Hierarchy__c> hierRecList = [SELECT Id, Level__c FROM Hierarchy__c WHERE id = :parentNodeIDList];
                                    
        for(Hierarchy__c hireRec :hierRecList){
            if(hireRec.Level__c != null){
            parentNodeToLevelMap.put(hireRec.Id,hireRec.Level__c);
            }
        }

        for(Hierarchy__c hier : newList) {
            Hierarchy__c oldHier = oldMap.get(hier.Id);
            if(hier.Parent_Node_ID1__c != null){
                System.debug('hier.Parent_Node_ID1__r.Level__c ** ' + hier.Parent_Node_ID1__c);
                Decimal parentLevel = 0.0;    
                
                if(!parentNodeToLevelMap.isEmpty() && parentNodeToLevelMap.get(hier.Parent_Node_ID1__c) != null){    
                    parentLevel = parentNodeToLevelMap.get(hier.Parent_Node_ID1__c); 
                }
                
                if(oldHier.Parent_Node_ID1__c != null){             
                    if(oldHier.Parent_Node_ID1__c != hier.Parent_Node_ID1__c){              
                        hier.Level__c = parentLevel + 1;
                    }
                }else{
                    hier.Level__c = parentLevel + 1;                
                }
            }
        }
     }
    
    
    public static void checkParentNode_beforeInsert(List<Hierarchy__c> newHier){
        List<ID> parentNodeIDList = new List<ID>();
        Map<ID,Decimal> parentNodeToLevelMap = new Map<ID,Decimal>();
        
        for(Hierarchy__c hier: newHier){         
            parentNodeIDList.add(hier.Parent_Node_ID1__c);
        }

        List<Hierarchy__c> hierRecList = [SELECT Id, Level__c FROM Hierarchy__c WHERE id = :parentNodeIDList];
                                        
        for(Hierarchy__c hireRec :hierRecList){      
            if(hireRec.Level__c != null){
                parentNodeToLevelMap.put(hireRec.Id,hireRec.Level__c);
            }
        }                                   
         
        for (Hierarchy__c hier: newHier) {                
            if(hier.Parent_Node_ID1__c != null){
                Decimal parentLevel = 0.0;    
                
                if(!parentNodeToLevelMap.isEmpty() && parentNodeToLevelMap.get(hier.Parent_Node_ID1__c) != null){    
                    parentLevel = parentNodeToLevelMap.get(hier.Parent_Node_ID1__c); 
                    
                    System.debug('parentLevel  ' + parentLevel );
                }
                hier.Level__c = parentLevel + 1;
            }
        }
    }        
    
    
    
    //Before Update method
    public static void populateCurrency_beforeUpdate(Map<ID,ERP_Currency_Daily_Exchange_Rate__c> oldMap,Map<ID,ERP_Currency_Daily_Exchange_Rate__c> newMap){         
        List<String> currencyCodeList = new List<String>();
        List<String> currencyCodeLookList = new List<String>();         
        Map<String,ID> isoCodeToIdMap = new Map<String,ID>();         
        Map<ID,String> idToisoCodeMapForLookup = new Map<ID,String>();         

        for(ERP_Currency_Daily_Exchange_Rate__c erp: newMap.values()){             
            if(erp.FROM_CURRENCY_CODE__c != null)
                currencyCodeList.add(erp.FROM_CURRENCY_CODE__c);
            if(erp.TO_CURRENCY_CODE__c != null)
                currencyCodeList.add(erp.TO_CURRENCY_CODE__c);
            if(erp.From_Currency_Name__c != null)
                currencyCodeLookList.add(erp.From_Currency_Name__c);
            if(erp.To_Currency_Name__c != null)
                currencyCodeLookList.add(erp.To_Currency_Name__c);             
        }    
         
        //Quering Curreny Object
        List<Currencies__c> currencyTypeList = [SELECT id,Currency_ISO_Code__c FROM Currencies__c 
                                                    WHERE Currency_ISO_Code__c in : currencyCodeList];
         
         //Creating map of isocode to Currency id
        for(Currencies__c currTypeRec : currencyTypeList){
            isoCodeToIdMap.put(currTypeRec.Currency_ISO_Code__c,currTypeRec.id);
        } 

        //Quering Curreny Object
        List<Currencies__c> currencyTypeListForLookup = [SELECT id,Currency_ISO_Code__c FROM Currencies__c 
                                                            WHERE id in : currencyCodeLookList];
        
        //Creating map of Currency id to isocode
        for(Currencies__c currTypeRec : currencyTypeListForLookup){
            idToisoCodeMapForLookup.put(currTypeRec.id,currTypeRec.Currency_ISO_Code__c);
        } 
         
         //Iterating ERP_Currency_Daily_Exchange_Rate__c records
         for(ERP_Currency_Daily_Exchange_Rate__c erp: newMap.values()){
             
            // Access the "old" record by its ID in Trigger.oldMap
            ERP_Currency_Daily_Exchange_Rate__c oldErp = oldMap.get(erp.Id);
         
            if(erp.Exchange_Rate_Source__c == 'Xignite'){                    
                if(!isoCodeToIdMap.isEmpty()){
                    if(erp.FROM_CURRENCY_CODE__c != null && isoCodeToIdMap.get(erp.FROM_CURRENCY_CODE__c) != null){                            
                        if(oldErp.FROM_CURRENCY_CODE__c != erp.FROM_CURRENCY_CODE__c){
                            erp.From_Currency_Name__c = isoCodeToIdMap.get(erp.FROM_CURRENCY_CODE__c);
                        }    
                    }                        
                    if(erp.TO_CURRENCY_CODE__c != null && isoCodeToIdMap.get(erp.TO_CURRENCY_CODE__c) != null){                            
                       if(oldErp.TO_CURRENCY_CODE__c != erp.TO_CURRENCY_CODE__c){
                            erp.To_Currency_Name__c = isoCodeToIdMap.get(erp.TO_CURRENCY_CODE__c); 
                       }
                    }
                }
            }
        
            if(erp.Exchange_Rate_Source__c == 'User' || erp.Exchange_Rate_Source__c == 'Bloomberg'){
                if(!idToisoCodeMapForLookup.isEmpty()){                        
                    if(erp.From_Currency_Name__c != null && idToisoCodeMapForLookup.get(erp.From_Currency_Name__c) != null){                            
                       if(oldErp.From_Currency_Name__c != erp.From_Currency_Name__c){                                
                            erp.FROM_CURRENCY_CODE__c = idToisoCodeMapForLookup.get(erp.From_Currency_Name__c);
                        }
                    }
                    if(erp.To_Currency_Name__c != null && idToisoCodeMapForLookup.get(erp.To_Currency_Name__c) != null){                            
                       if(oldErp.To_Currency_Name__c != erp.To_Currency_Name__c){                                
                            erp.TO_CURRENCY_CODE__c = idToisoCodeMapForLookup.get(erp.To_Currency_Name__c);                            
                       }
                    }
                }
            }
        }
    }
     
     
    //Before Insert method
    public static void populateCurrency_beforeInsert(List<ERP_Currency_Daily_Exchange_Rate__c> newList){  
        List<String> currencyCodeList = new List<String>();
        List<String> currencyCodeLookList = new List<String>();
        Map<String,ID> isoCodeToIdMap = new Map<String,ID>();
        Map<ID,String> idToisoCodeMapForLookup = new Map<ID,String>();

        for(ERP_Currency_Daily_Exchange_Rate__c erp: newList){       
            if(erp.FROM_CURRENCY_CODE__c != null)
                currencyCodeList.add(erp.FROM_CURRENCY_CODE__c);
            if(erp.TO_CURRENCY_CODE__c != null)
                currencyCodeList.add(erp.TO_CURRENCY_CODE__c);
            if(erp.From_Currency_Name__c != null)
                currencyCodeLookList.add(erp.From_Currency_Name__c);
            if(erp.To_Currency_Name__c != null)
                currencyCodeLookList.add(erp.To_Currency_Name__c);       
        }    

        List<Currencies__c> currencyTypeList = [SELECT id,Currency_ISO_Code__c FROM Currencies__c 
                                                    WHERE Currency_ISO_Code__c in : currencyCodeList];
        //Creating map of isocode to Currency id 
        for(Currencies__c currTypeRec : currencyTypeList){
            isoCodeToIdMap.put(currTypeRec.Currency_ISO_Code__c,currTypeRec.id);
        } 

        List<Currencies__c> currencyTypeListForLookup = [SELECT id,Currency_ISO_Code__c FROM Currencies__c 
                                                            WHERE id in : currencyCodeLookList];
        //Creating map of Currency id to isocode
        for(Currencies__c currTypeRec : currencyTypeListForLookup){
            idToisoCodeMapForLookup.put(currTypeRec.id,currTypeRec.Currency_ISO_Code__c);
        } 

        //Iterating ERP_Currency_Daily_Exchange_Rate__c records
        for(ERP_Currency_Daily_Exchange_Rate__c erp: newList){
            if(erp.Exchange_Rate_Source__c == 'Xignite'){
                if(!isoCodeToIdMap.isEmpty()){
                    if(erp.FROM_CURRENCY_CODE__c != null && isoCodeToIdMap.get(erp.FROM_CURRENCY_CODE__c) != null){                         
                        erp.From_Currency_Name__c = isoCodeToIdMap.get(erp.FROM_CURRENCY_CODE__c);                             
                    }                   
                    if(erp.TO_CURRENCY_CODE__c != null && isoCodeToIdMap.get(erp.TO_CURRENCY_CODE__c) != null){                     
                        erp.To_Currency_Name__c = isoCodeToIdMap.get(erp.TO_CURRENCY_CODE__c);                     
                    }
                }
            }

            if(erp.Exchange_Rate_Source__c == 'User' || erp.Exchange_Rate_Source__c == 'Bloomberg'){
                if(!idToisoCodeMapForLookup.isEmpty()){                 
                    if(erp.From_Currency_Name__c != null && idToisoCodeMapForLookup.get(erp.From_Currency_Name__c) != null){                        
                        erp.FROM_CURRENCY_CODE__c = idToisoCodeMapForLookup.get(erp.From_Currency_Name__c);                        
                    }
                    if(erp.To_Currency_Name__c != null && idToisoCodeMapForLookup.get(erp.To_Currency_Name__c) != null){                        
                        erp.TO_CURRENCY_CODE__c = idToisoCodeMapForLookup.get(erp.To_Currency_Name__c);                        
                    }
                }
            }
        }
    }
    
    
    public static void preventRecordFromSameApprover(Map<Id, sObject> newMap)
    {
        set<Id> sObjectId = new set<Id>();
        for(sObject s: newMap.values()) {
            System.debug('-------Ashish-------'+s.get('Approval_Status__c'));
            if(s.get('Approval_Status__c') == 'Submitted' || s.get('Approval_Status__c') == 'Pending L1 Approval' || s.get('Approval_Status__c') == 'Pending L2 Approval') {
                sObjectId.add(s.id);         
            }
        }

        if(sObjectId.size()>0) {
            for(ProcessInstance procc : [SELECT LastActorId,SubmittedById, TargetObjectId, SubmittedBy.Name ,
                                           (SELECT Id FROM StepsAndWorkitems WHERE StepStatus != 'Started' )
                                                FROM ProcessInstance where TargetObjectId IN: sObjectId order by SystemModstamp desc limit 1]) {
                System.debug('----procc.SubmittedBy-----'+procc.SubmittedBy.Name);
                if(procc.StepsAndWorkitems.size() > 0 && procc.SubmittedById == UserInfo.getUserId()){
                    newMap.get(procc.TargetObjectId).addError('Requester can not approve the same record by himself/herself.');
                }                                                          
            }
        }
    }
    
    public static void synchCostCenterHierarchies(Map<id, Cost_Center__c> oldMap, Map<id, Cost_Center__c> newMap) {
    	Map<id, Cost_Center__c> approved = new Map<id, Cost_Center__c>();
    	
    	for( Id key  : oldMap.keySet() ) {
    		if ( oldMap.get(key).Approval_Status__c != 'Approved' && newMap.get(key).Approval_Status__c == 'Approved' )
    		      approved.put(key, newMap.get(key));
    	}

        try {
	    	if ( !approved.isEmpty() ) {
	    		List<Hierarchy__c> hierInsList = new List<Hierarchy__c>();
	    		List<Hierarchy__c> hierUpdList = new List<Hierarchy__c>();
	    		
	    		List<Hierarchy__c> existHier = [SELECT Id, Name, Node_ID1__c, Node_Description__c, Cost_Center__c,
	    		                                      Parent_Node_ID1__c, Hierarchy_Description__c, Status__c
	    		                                FROM Hierarchy__c WHERE Cost_Center__c IN : approved.keySet()];
	    		//Updates                                
	    		for ( Hierarchy__c hr : existHier) {
	    			Hierarchy__c updHier = new Hierarchy__c( id = hr.Id );
	    			Boolean upd = false;
	    			if ( hr.Name != newMap.get(hr.Cost_Center__c).Name ) {
	    				updHier.Name = newMap.get(hr.Cost_Center__c).Name;
	    				updHier.Node_Description__c = newMap.get(hr.Cost_Center__c).Description__c;
	    				updHier.Node_ID1__c = newMap.get(hr.Cost_Center__c).Cost_Center_ID1__c;
	    				upd = true;
	    			}
	   
	    			if ( hr.Hierarchy_Description__c != null && hr.Hierarchy_Description__c == 'Function Cost Center GAAP Reporting Hierarchy' &&   			     
	    			    ! equalStr(newMap.get(hr.Cost_Center__c).Cost_Center_GAAP_Reporting_Hierarchy__c, hr.Parent_Node_ID1__c) ) {
	    			         	
	    			     updHier.Parent_Node_ID1__c = newMap.get(hr.Cost_Center__c).Cost_Center_GAAP_Reporting_Hierarchy__c;
	    			     upd = true;	
	    			}
	
	    			if ( hr.Hierarchy_Description__c != null && hr.Hierarchy_Description__c == 'Function Cost Center Management Reporting Hierarchy' &&   			     
	    			    ! equalStr(newMap.get(hr.Cost_Center__c).Cost_Center_Management_Hierarchy__c, hr.Parent_Node_ID1__c) ) {
	 			         	
	    			     updHier.Parent_Node_ID1__c = newMap.get(hr.Cost_Center__c).Cost_Center_Management_Hierarchy__c;
	    			     upd = true;	
	    			}
	    			
	    			if ( hr.Status__c != newMap.get(hr.Cost_Center__c).Status__c ) {
	    				updHier.Status__c = newMap.get(hr.Cost_Center__c).Status__c;
	    				upd = true;
	    			}
	    			
	    			if ( upd )  
	    			   hierUpdList.add(updHier); 
	    		}
	    		//inserts
	    		for ( Id key : approved.keySet() ) {
	    			Boolean gaapFound = false;
	    			Boolean mgmtFound = false;
	    			Boolean gaapNeed = approved.get(key).Cost_Center_GAAP_Reporting_Hierarchy__c != null ? true : false;
	    			Boolean mgmtNeed = approved.get(key).Cost_Center_Management_Hierarchy__c != null ? true : false;
	
	    			for (Hierarchy__c hr : existHier )   {
	    			   if ( key == hr.Cost_Center__c && hr.Hierarchy_Description__c == 'Function Cost Center GAAP Reporting Hierarchy') 
	    			   	  gaapFound = true;
	    			   
	    			   if ( key == hr.Cost_Center__c && hr.Hierarchy_Description__c == 'Function Cost Center Management Reporting Hierarchy' ) 
	    			   	 mgmtFound = true;    			   
	    			}
	    			
	    			//insert GAAP hierarchy
	    			if ( gaapNeed && !gaapFound ) {
	    			   Hierarchy__c insHier = new Hierarchy__c();
	    			   insHier.Name = approved.get(key).Cost_Center_ID1__c + '-' + approved.get(key).Description__c;
	    			   insHier.Node_Description__c = approved.get(key).Description__c;
	    			   insHier.Node_ID1__c = approved.get(key).Cost_Center_ID1__c;
	    			   insHier.Top_Node_ID1__c = Global_Setting__c.getInstance('MDMHierarchyIdTotalFunction').ID__c;
	    			   insHier.Status__c = approved.get(key).Status__c;		   
	    			   insHier.Parent_Node_ID1__c = approved.get(key).Cost_Center_GAAP_Reporting_Hierarchy__c;
	    			   insHier.Cost_Center__c = key;
	    			   insHier.Hierarchy_Description__c = 'Function Cost Center GAAP Reporting Hierarchy';
	    			   insHier.Node_Type__c = 'Master Data';
	    			   insHier.Domain__c = 'Cost Center';
	    			   insHier.Data_Storage__c = 'Store';
	    			   insHier.Approval_Status__c = 'Approved';
	
	                   hierInsList.add(insHier);
	    			}
	    			
	    			//insert Managment hierarchy
	    			if ( mgmtNeed && !mgmtFound ) {
	    			   Hierarchy__c insHier = new Hierarchy__c();
	    			   insHier.Name = approved.get(key).Cost_Center_ID1__c + '-' + approved.get(key).Description__c;
	    			   insHier.Node_Description__c = approved.get(key).Description__c;
	    			   insHier.Node_ID1__c = approved.get(key).Cost_Center_ID1__c;
	    			   insHier.Top_Node_ID1__c = Global_Setting__c.getInstance('MDMHierarchyIdTotalFunctionOrg').ID__c;	    			   
	    			   insHier.Status__c = approved.get(key).Status__c;   			   
	    			   insHier.Parent_Node_ID1__c = approved.get(key).Cost_Center_Management_Hierarchy__c;
	    			   insHier.Cost_Center__c = key;
	    			   insHier.Hierarchy_Description__c = 'Function Cost Center Management Reporting Hierarchy';
	    			   insHier.Node_Type__c = 'Master Data';
	    			   insHier.Domain__c = 'Cost Center';
	    			   insHier.Data_Storage__c = 'Shared';
	    			   insHier.Approval_Status__c = 'Approved';
	
	                   hierInsList.add(insHier);
	    			}    			
	    		} // end for loop
	    		
	    		///update / insert 
	    		if ( !hierUpdList.isEmpty() )  {
	    			   update hierUpdList;
	    			   
	    			   ///set approval status again after it was reset in workflow to New
	    			   for (Hierarchy__c hr : hierUpdList)
	    			      hr.Approval_Status__c = 'Approved';
	    			      
	    			   //second update
	    			   update hierUpdList;
	    		}	   
	    		if ( !hierInsList.isEmpty() )
	    			   insert hierInsList;
	    			   
	    	} //end if ( !approved.isEmpty() )
    	
        }
        catch (Exception e) {
            ErrorLogUtil.insertLog('MDM: FinanceMDMTriggerHelper', 'Error Creating/Updating Hierarchy for Cost Center ' +  newMap.keySet() +
			       '\n  ' + e.getMessage() + '\n Line number: ' + e.getLineNumber() + '\n Stack trace: ' + e.getStackTraceString(), 
			       'FinanceMDMTriggerHelper.synchCostCenterHierarchies');    
        } 
        	
    }
    
    ////GL Accont hierarchy
   public static void synchGLAccountHierarchies(Map<id, GL_Account__c> newMap) {
 
        try {
	    		List<Hierarchy__c> hierInsList = new List<Hierarchy__c>();
	    		List<Hierarchy__c> hierUpdList = new List<Hierarchy__c>();
	    		
	    		List<Hierarchy__c> existHier = [SELECT Id, Name, Node_ID1__c, Node_Description__c, GL_Account__c,
	    		                                      Parent_Node_ID1__c, Hierarchy_Description__c, Status__c
	    		                                FROM Hierarchy__c WHERE GL_Account__c IN : newMap.keySet()];
	    		                                               
	    		//Updates                                
	    		for ( Hierarchy__c hr : existHier) {	    		
	    			Hierarchy__c updHier = new Hierarchy__c( id = hr.Id );
	    			Boolean upd = false;
	    			if ( hr.Name != newMap.get(hr.GL_Account__c).Name ) {
	    				updHier.Name = newMap.get(hr.GL_Account__c).Name;
	    				updHier.Node_Description__c = newMap.get(hr.GL_Account__c).Description__c;
	    				updHier.Node_ID1__c = newMap.get(hr.GL_Account__c).Proposed_GL_Account_ID__c;
	    				upd = true;
	    			}
	   
	    			if ( hr.Hierarchy_Description__c != null && hr.Hierarchy_Description__c == 'Planning GL Account GAAP Hierarchy' &&   			     
	    			    ! equalStr(newMap.get(hr.GL_Account__c).Planning_GL_Account_GAAP_Hierarchy__c, hr.Parent_Node_ID1__c) ) {
	    			         	
	    			     updHier.Parent_Node_ID1__c = newMap.get(hr.GL_Account__c).Planning_GL_Account_GAAP_Hierarchy__c;
	    			     upd = true;	
	    			}
	
	    			if ( hr.Hierarchy_Description__c != null && hr.Hierarchy_Description__c == 'GL Account Management Hierarchy' &&   			     
	    			    ! equalStr(newMap.get(hr.GL_Account__c).GL_Account_Management_Hierarchy__c, hr.Parent_Node_ID1__c) ) {
	 			         	
	    			     updHier.Parent_Node_ID1__c = newMap.get(hr.GL_Account__c).GL_Account_Management_Hierarchy__c;
	    			     upd = true;	
	    			}
	    			
	    			if ( hr.Hierarchy_Description__c != null && hr.Hierarchy_Description__c == 'GL Account Management w Proforma Hierarchy' &&   			     
	    			    ! equalStr(newMap.get(hr.GL_Account__c).GL_Account_Management_w_Proforma__c, hr.Parent_Node_ID1__c) ) {
	 			         	
	    			     updHier.Parent_Node_ID1__c = newMap.get(hr.GL_Account__c).GL_Account_Management_w_Proforma__c;
	    			     upd = true;	
	    			}
	    			
	    			if ( hr.Hierarchy_Description__c != null && hr.Hierarchy_Description__c == 'GL Account Lender Hierarchy' &&   			     
	    			    ! equalStr(newMap.get(hr.GL_Account__c).GL_Account_Lender_Hierarchy__c, hr.Parent_Node_ID1__c) ) {
	 			         	
	    			     updHier.Parent_Node_ID1__c = newMap.get(hr.GL_Account__c).GL_Account_Lender_Hierarchy__c;
	    			     upd = true;	
	    			}
	    			
	    			if ( hr.Hierarchy_Description__c != null && hr.Hierarchy_Description__c == 'Statistical Account Hierarchy' &&   			     
	    			    ! equalStr(newMap.get(hr.GL_Account__c).Statistical_Account_Hierarchy__c, hr.Parent_Node_ID1__c) ) {
	 			         	
	    			     updHier.Parent_Node_ID1__c = newMap.get(hr.GL_Account__c).Statistical_Account_Hierarchy__c;
	    			     upd = true;	
	    			}
	    			
	    			if ( hr.Status__c != newMap.get(hr.GL_Account__c).Status__c ) {
	    				updHier.Status__c = newMap.get(hr.GL_Account__c).Status__c;
	    				upd = true;
	    			}
	    			
	    			if ( upd )  
	    			   hierUpdList.add(updHier); 
	    		}

	    		
	    		//inserts               	    		
	    		for ( Id key : newMap.keySet() ) {	 	   			
	    			Boolean gaapFound = false;
	    			Boolean mgmtFound = false;
	    			Boolean profrmFound = false;
	    			Boolean lendrFound = false;
	    			Boolean statistFound = false;
	    			
	    			Boolean gaapNeed = newMap.get(key).Planning_GL_Account_GAAP_Hierarchy__c != null ? true : false;
	    			Boolean mgmtNeed = newMap.get(key).GL_Account_Management_Hierarchy__c != null ? true : false;
	    			Boolean profrmNeed = newMap.get(key).GL_Account_Management_w_Proforma__c != null ? true : false;
	    			Boolean lendrNeed = newMap.get(key).GL_Account_Lender_Hierarchy__c != null ? true : false;
	    			Boolean statistNeed = newMap.get(key).Statistical_Account_Hierarchy__c != null ? true : false;
	
	    			for (Hierarchy__c hr : existHier )   {
	    			   if ( key == hr.GL_Account__c && hr.Hierarchy_Description__c == 'Planning GL Account GAAP Hierarchy') 
	    			   	  gaapFound = true;
	    			   
	    			   if ( key == hr.GL_Account__c && hr.Hierarchy_Description__c == 'GL Account Management Hierarchy' ) 
	    			   	  mgmtFound = true;  
	    			   	 
	    			   if (  key == hr.GL_Account__c && hr.Hierarchy_Description__c == 'GL Account Management w Proforma Hierarchy' )
	    			      profrmFound = true;
	    			      
	    			   if (  key == hr.GL_Account__c && hr.Hierarchy_Description__c == 'GL Account Lender Hierarchy' )
	    			      lendrFound = true;
	    			      
	    			   if (  key == hr.GL_Account__c && hr.Hierarchy_Description__c == 'Statistical Account Hierarchy' )
	    			       statistFound = true;			   
	    			}
    			
	    			//insert GAAP hierarchy
	    			if ( gaapNeed && !gaapFound ) {
	    			   Hierarchy__c insHier = new GLAccountHierarInstance( newMap.get(key) ).hier;	    			   
	    			   inshier.Top_Node_ID1__c = Global_Setting__c.getInstance('MDMPlanningGLAccountGAAPHierarchy').ID__c;
	    			   insHier.Hierarchy_Description__c = 'Planning GL Account GAAP Hierarchy';
	    			   insHier.Data_Storage__c = 'Store';	      
	       	           inshier.Parent_Node_ID1__c = newMap.get(key).Planning_GL_Account_GAAP_Hierarchy__c;	       	           
	                   hierInsList.add(insHier);
	    			}
	    			
 	    			//insert Managment hierarchy
	    			if ( mgmtNeed && !mgmtFound ) {
	    			   Hierarchy__c insHier = new GLAccountHierarInstance( newMap.get(key) ).hier;	    			   
	    			   inshier.Top_Node_ID1__c = Global_Setting__c.getInstance('MDMGLAccountManagementHierarchy').ID__c;
	    			   insHier.Hierarchy_Description__c = 'GL Account Management Hierarchy';    
	       	           inshier.Parent_Node_ID1__c = newMap.get(key).GL_Account_Management_Hierarchy__c;	       	           
	                   hierInsList.add(insHier);
	    			} 
	    			
	    		    //insert Managment w/t Proforma hierarchy
	    			if ( profrmNeed && !profrmFound ) {
	    			   Hierarchy__c insHier = new GLAccountHierarInstance( newMap.get(key) ).hier;	    			   
	    			   inshier.Top_Node_ID1__c = Global_Setting__c.getInstance('MDMGLAccountMngmtProformaHierarchy').ID__c;
	    			   insHier.Hierarchy_Description__c = 'GL Account Management w Proforma Hierarchy';    
	       	           inshier.Parent_Node_ID1__c = newMap.get(key).GL_Account_Management_w_Proforma__c;	       	           
	                   hierInsList.add(insHier);
	    			} 
	    			
	    			//insert Lender hierarchy
	    			if ( lendrNeed && !lendrFound ) {
	    			   Hierarchy__c insHier = new GLAccountHierarInstance( newMap.get(key) ).hier;	    			   
	    			   inshier.Top_Node_ID1__c = Global_Setting__c.getInstance('MDMGLAccountLenderHierarchy').ID__c;
	    			   insHier.Hierarchy_Description__c = 'GL Account Lender Hierarchy';    
	       	           inshier.Parent_Node_ID1__c = newMap.get(key).GL_Account_Lender_Hierarchy__c;	       	           
	                   hierInsList.add(insHier);
	    			} 
	    			
	    			//insert Statistical hierarchy
	    			if ( statistNeed && !statistFound ) {
	    			   Hierarchy__c insHier = new GLAccountHierarInstance( newMap.get(key) ).hier;	    			   
	    			   inshier.Top_Node_ID1__c = Global_Setting__c.getInstance('MDMStatisticalAccountHierarchy').ID__c;
	    			   insHier.Hierarchy_Description__c = 'Statistical Account Hierarchy';
	    			   insHier.Data_Storage__c = 'Store';    
	       	           inshier.Parent_Node_ID1__c = newMap.get(key).Statistical_Account_Hierarchy__c;	       	           
	                   hierInsList.add(insHier);
	    			}     
	    			  			
	    		} // end for each GL Account loop
	    		
	    		///update / insert 
	    		if ( !hierUpdList.isEmpty() )  {
	    			   update hierUpdList;
	    			   
	    			   ///set approval status again after it was reset in workflow to New
	    			   for (Hierarchy__c hr : hierUpdList)
	    			      hr.Approval_Status__c = 'Approved';
	    			      
	    			   //second update
	    			   update hierUpdList;
	    		}	   
	    		if ( !hierInsList.isEmpty() )
	    			   insert hierInsList;
	   			      	
        } 
        catch (Exception e) {
            ErrorLogUtil.insertLog('MDM: FinanceMDMTriggerHelper', 'Error Creating/Updating Hierarchy for GL Account ' +  newMap.keySet() +
			       '\n  ' + e.getMessage() + '\n Line number: ' + e.getLineNumber() + '\n Stack trace: ' + e.getStackTraceString(), 
			       'FinanceMDMTriggerHelper.synchGLAccountHierarchies');    
        } 
    }
    
    public class GLAccountHierarInstance {
    	public Hierarchy__c hier;    	
    	public GLAccountHierarInstance(GL_Account__c acct) {
    		hier = new Hierarchy__c();  		
    		hier.Name = acct.Name;
	    	hier.Node_Description__c = acct.Description__c;
	    	hier.Node_ID1__c = acct.Proposed_GL_Account_ID__c; 		    	    			   
	        hier.Status__c = acct.Status__c;   			   	  
	    	hier.GL_Account__c = acct.Id;
	        hier.Node_Type__c = 'Master Data';
	    	hier.Domain__c = 'GL Account';	
	    	hier.Data_Storage__c = 'Shared';	   
	        hier.Approval_Status__c = 'Approved';
    	}
    }
    
    public static Boolean equalStr (String val1, String val2) {
    	Boolean ret = false;
    	
    	if ( val1 == null && val2 == null )
    	   ret = true;
    	else if ( val1 != null && val2 != null && val1 == val2 )
    	   ret = true;
    	   
        return ret;
    }
}