//Naresh Kumar  06/26/2015
public without sharing class MDMUtil {
    
    public static final String SELLABLE_STATUS_SELLABLE_ITEM_READY = 'Sellable Item Ready';
    public static final String SELLABLE_STATUS_TO_BE_UPDATED = 'To Be Updated';
    public static final String SELLABLE_STATUS_DRAFT = 'Draft';
    public static final String SELLABLE_STATUS_PRICING_FROZEN = 'Pricing Frozen';
    public static final String SELLABLE_STATUS_SUBMITTED_TO_SAP = 'Submitted to ERP';
    public static final String SELLABLE_STATUS_SAP_PROFILE_COMPLETE = 'ERP Profile Complete';
    public static final String SELLABLE_STATUS_SI_ATTRIBUTES_FROZEN = 'SI Attributes Frozen';
    public static final String SELLABLE_STATUS_RETIRED = 'Retired';
    public static final String SELLABLE_STATUS_Submitted_to_Finance = 'Submitted to Finance'; //New flow
    public static final String SELLABLE_STATUS_Submitted_to_Tax = 'Submitted to Tax'; //New flow
    
    public static final String SELLABLE_AVAILABILITY_STATUS_EOL = 'EOL';
    public static final String SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE = 'BOM Update';
    public static final String SELLABLE_AVAILABILITY_STATUS_ACTIVE = 'Active';
    public static final String SELLABLE_AVAILABILITY_STATUS_MARKED_FOR_DELETION_IN_SAP = 'Marked for deletion in ERP';
    public static final String SELLABLE_AVAILABILITY_STATUS_NAME_CHANGE = 'Name Change';
    public static final String SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS = 'In Progress';  
    public static final String SELLABLE_AVAILABILITY_STATUS_ERP_HOLD = 'ERP Hold';     
    public static final String NEW_PRICING = 'New Pricing';
    public static final String OLD_PRICING = 'Old Pricing';
    public static final String BOTH_PRICING = 'Both';
    public static final String SELLABLE_TYPE_GU = 'GU';
    public static final String SELLABLE_TYPE_PS = 'PS';
    public static final String SELLABLE_TYPE_CLOUD = 'Cloud';
    public static final String SELLABLE_TYPE_CARE = 'Care';
    public static final String SELLABLE_TYPE_Product = 'Product';
    public static final String GROUP_MML_PRICING_MANAGEMENT = 'MML_Pricing_Management';
    public static final String GROUP_MML_PRODUCT_MANAGEMENT = 'MML_Product_Management';
    public static final String GROUP_MML_PROJECT_MANAGEMENT = 'MML_Project_Management';
    public static final String GROUP_MML_SOFTWARE_DELIVERY = 'MML_Software_Delivery';
    public static final String GROUP_MML_Finance_Management = 'MML_Finance_Management';//New flow
    public static final string GROUP_MML_Tax_Management = 'MML_Tax_Management';
    public static final String ACTION_UP_REV = 'Up-rev';
    public static final String ACTION_PLANNED_EOL = 'Planned EOL';
    public static final String ACTION_NO_CHANGE = 'No Change';
    public static final String DEFAULT_ECCN_US = 'EAR99';
    public static final String DEFAULT_ECCN_GB = 'ECL99';
    public static final String DEFAULT_ECCN_NL = 'ECL99';
    
    
    public static Sellable_Item_Product__c getSellableItem(String sellableItemId){
        return [SELECT id, Status__c, Availability__c, Type__c, Number_of_BOM_Updates__c, 
            Number_of_Predecessors__c, Nothing_shipped_license_only__c, 
            Entitlement__c, APN_Number__c FROM Sellable_Item_Product__c WHERE id =: sellableItemId];
    }
    
    public static Set<String> getCurrentUserGroup(){//new flow
        Map<Id, Group> mapIdVsGroup = new Map<Id, Group>([SELECT id, DeveloperName FROM Group WHERE 
            (DeveloperName =: GROUP_MML_PRICING_MANAGEMENT OR DeveloperName =: GROUP_MML_PRODUCT_MANAGEMENT
            OR DeveloperName =: GROUP_MML_PROJECT_MANAGEMENT OR DeveloperName =: GROUP_MML_SOFTWARE_DELIVERY OR 
             DeveloperName =:GROUP_MML_Finance_Management OR DeveloperName=: GROUP_MML_Tax_Management )]);
        List<GroupMember> groupMembers = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN : mapIdVsGroup.keyset() 
            AND UserOrGroupId =: UserInfo.getUserId()];
        Set<String> setOfGroups = new Set<String>(); 
        //Looping over each group
        for(GroupMember eachRecord : groupMembers){
            setOfGroups.add(mapIdVsGroup.get(eachRecord.GroupId).DeveloperName);
        }
        return setOfGroups;
    }
    
    public static String cloneSellableItem(String sellableItemId){
        return cloneSellableItem(sellableItemId, null, null);
    }
    
    public static String cloneSellableItem(String sellableItemId, String newFamily, String newFamilyVesion){
        //Sellable Item     
        String sellableItemQuery = getAllFieldsSOQL('Sellable_Item_Product__c', ' id = \''+ sellableItemId + '\'');  
        sellableItemQuery = sellableItemQuery.replace(' FROM ', ',SI_Version_Number__r.Name FROM ');    
        System.debug('NKC debug sellableItemQuery ['+sellableItemQuery+']');
        Sellable_Item_Product__c sellableItemToClone = (Sellable_Item_Product__c)Database.query(sellableItemQuery);     
        Sellable_Item_Product__c newSellableItem = sellableItemToClone.clone(false, true, false, false);
        newSellableItem.APN_Number__c = null;
        newSellableItem.Status__c = MDMUtil.SELLABLE_STATUS_TO_BE_UPDATED;
        newSellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS;
        newSellableItem.APN_Number__c = null;         
        newSellableItem.New_Family__c = null;
        newSellableItem.Locked__c = false;
        newSellableItem.Stage__c = false;
        newSellableItem.Action__c = null;
        newSellableItem.Publish_Date__c = null;
        newSellableItem.Price_Effective_Date__c = null;
        newSellableItem.Publish_in_Quote__c = false;
        newSellableItem.Pricing_Approved__c = false;
        String newSellableItemVersionNo;
        if(newFamily != null){
            newSellableItem.Cloned_From__c = sellableItemId;
            newSellableItem.Family__c = newFamily;
            newFamilyVesion = newFamilyVesion.replace('.',',');
            if(newFamilyVesion.split(',').size() > 2){
                String SIVersionNo = newFamilyVesion.split(',')[0] + '.' + newFamilyVesion.split(',')[1];
                String itemName;
                if(newSellableItem.Name != null && newSellableItem.Name.contains('-'))
                    itemName = newSellableItem.Name.split('-')[1];
                newSellableItem.Name = 'v' + SIVersionNo + ' - ' + itemName;
                List<Sellable_Item_SI_Version_Number__c> siVersion = [SELECT id, Name FROM Sellable_Item_SI_Version_Number__c WHERE Name =: SIVersionNo];
                if(!siVersion.isEmpty()){
                    newSellableItem.SI_Version_Number__c = siVersion[0].id;         
                    newSellableItemVersionNo = siVersion[0].Name;       
                }
            }
        }
        if(Test.isRunningTest())
            newSellableItem.Name += ' - Clone';      
        insert newSellableItem;
        String shippableItemName;
        //Sellable shippable item
        List<Sellable_Shippable_Items__c> bomItemsToClone = [SELECT Sellable_Item_Product__c, Shippable_Item_Product__c, Shippable_Item_Product__r.Name 
            FROM Sellable_Shippable_Items__c WHERE Sellable_Item_Product__c =: sellableItemId];     
        List<Sellable_Shippable_Items__c> bomItemsToInsert = new List<Sellable_Shippable_Items__c>();
        for(Sellable_Shippable_Items__c eachItem : bomItemsToClone){
            Sellable_Shippable_Items__c newRecord = new Sellable_Shippable_Items__c();
            newRecord.Sellable_Item_Product__c = newSellableItem.id;
            newRecord.Shippable_Item_Product__c = eachItem.Shippable_Item_Product__c;   
            bomItemsToInsert.add(newRecord);
            if(shippableItemName == null)
                shippableItemName = eachItem.Shippable_Item_Product__r.Name;        
        }       
        
        if(newFamily != null){
            String shippableItemNameToMatch = newSellableItem.Name;         
            System.debug('NKC debug bomItemsToInsert ['+bomItemsToInsert+']');
            if(shippableItemName != null){
                shippableItemNameToMatch = shippableItemName;
                System.debug('NKC debug shippableItemNameToMatch ['+shippableItemNameToMatch+']');
                System.debug('NKC debug sellableItemToClone.SI_Version_Number__r.Name ['+sellableItemToClone.SI_Version_Number__r.Name+']');
                System.debug('NKC debug newSellableItemVersionNo ['+newSellableItemVersionNo+']');
                if(shippableItemNameToMatch != null && newSellableItemVersionNo != null){
                    shippableItemNameToMatch = shippableItemNameToMatch.replace(sellableItemToClone.SI_Version_Number__r.Name, newSellableItemVersionNo);
                    shippableItemNameToMatch = shippableItemNameToMatch;
                }
            }
            System.debug('NKC debug shippableItemNameToMatch ['+shippableItemNameToMatch+']');
            System.debug('NKC debug newSellableItem.Family__r.Name ['+newSellableItem.Family__r.Name+']');
            List<Shippable_Item__c> matchingShippableItemTo = [SELECT id FROM Shippable_Item__c WHERE Name =: shippableItemNameToMatch];
            if(!matchingShippableItemTo.isEmpty()){
                bomItemsToInsert.clear();
                for(Shippable_Item__c eachItem : matchingShippableItemTo){
                    Sellable_Shippable_Items__c newRecord = new Sellable_Shippable_Items__c();
                    newRecord.Sellable_Item_Product__c = newSellableItem.id;
                    newRecord.Shippable_Item_Product__c = eachItem.id;   
                    bomItemsToInsert.add(newRecord);        
                }  
            }
        }
        
        if(!bomItemsToInsert.isEmpty()){
            insert bomItemsToInsert;
        }
        
        
        if(newFamily == null){      
            //Predecessors
            List<Product_Relationship__c> predsToClone = [SELECT Predecessors__c, Successors__c 
                FROM Product_Relationship__c WHERE Predecessors__c =: sellableItemId];      
            List<Product_Relationship__c> predToInsert = new List<Product_Relationship__c>();
            for(Product_Relationship__c eachItem : predsToClone){
                Product_Relationship__c newRecord = new Product_Relationship__c();
                newRecord.Predecessors__c = newSellableItem.id;
                newRecord.Successors__c = eachItem.Successors__c;   
                predToInsert.add(newRecord);        
            }
            if(!predToInsert.isEmpty()){
                insert predToInsert;
            }       
            //Successors
            List<Product_Relationship__c> successorsToClone = [SELECT Predecessors__c, Successors__c 
                FROM Product_Relationship__c WHERE Successors__c =: sellableItemId];        
            List<Product_Relationship__c> successorsToInsert = new List<Product_Relationship__c>();
            for(Product_Relationship__c eachItem : successorsToClone){
                Product_Relationship__c newRecord = new Product_Relationship__c();
                newRecord.Successors__c = newSellableItem.id;
                newRecord.Predecessors__c = eachItem.Predecessors__c;   
                successorsToInsert.add(newRecord);      
            }
            if(!successorsToInsert.isEmpty()){
                insert successorsToInsert;
            }
        }
        else{
            //Predecessor
            Product_Relationship__c newRecord = new Product_Relationship__c();
            newRecord.Predecessors__c = newSellableItem.id;
            newRecord.Successors__c = sellableItemId;   
            insert newRecord;                   
        }
        //Pricing       
        String pricingQuery = getAllFieldsSOQL('Sellable_Item_Pricing__c', ' Sellable_Item_Product__c = \''+ sellableItemId + '\'');        
        List<Sellable_Item_Pricing__c> pricingItemsToClone = (List<Sellable_Item_Pricing__c>)Database.query(pricingQuery);
        List<Sellable_Item_Pricing__c> pricingItemsToInsert = new List<Sellable_Item_Pricing__c>();
        for(Sellable_Item_Pricing__c eachItem : pricingItemsToClone){
            Sellable_Item_Pricing__c newRecord = eachItem.clone(false, true, false, false);
            newRecord.Sellable_Item_Product__c = newSellableItem.id;
            pricingItemsToInsert.add(newRecord);
        }
        if(!pricingItemsToInsert.isEmpty()){
            insert pricingItemsToInsert;
        }
        return newSellableItem.id;
    }
    
    public static string getAllFieldsSOQL(String objectName, String whereClause){
        String selects = '';
        if (whereClause == null || whereClause == ''){ return null; }         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                selectFields.add(fd.getName());                
            }
        }         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}             
        }         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;         
    } 
}