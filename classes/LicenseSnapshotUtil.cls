/*
 * Class            : LicenseSnapshotUtil
 * Description      : Util class for all UTIL Methods used in LMS ST EU Combinations Capture and Summary Capture.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Jan 5, 2018
 * Test Class       : LicenseSnapshotTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Modified BY        Modified Date    Changes/ Notes
 * ChandraMouli N     Oct 10, 2019     For 'NV' Products assigning version as '4.0'
 * ----------------------------------------------------------------------------------------------
 *
 */ 
 public class LicenseSnapshotUtil {
    
    public static List<CustomerProduct> getContractLineItemsByEU(String soldToAccountId, String endUserAccountId) {
        
        
        Set<String> productTypesToExclude = new Set<String>();
        for(LMS_Product_Types_To_Exclude__c pType : [SELECT id, Name FROM LMS_Product_Types_To_Exclude__c]){
            productTypesToExclude.add(pType.Name);  
        }
                
        List<CustomerProduct> prdlines = new  List<CustomerProduct>();
        
        /* "Shelved" contracts line items included only for 18 months after the line item End Date
        "In Negotiation" contracts all lines included based on the contract header start/end dates
        "Active" contracts lines are included based on the line item start/end date
        */       
        /// STEP -1. check for upgrades in the upgrade requests pending list for the EndUser. If found, replace old (current) version with a new version
        // based on product upgrade mapping list stored in Pure_Connect_Version_Upgrade__c. Mirror type contracts are excluded.
        /// including only products with offering type 'PureConnect On Premise' (formula field isPureConnectPrem)
        List<Pure_Connect_Version_Upgrade__c> pendingUpgrProds = pendingUpgradeProducts(endUserAccountId);
        
        AggregateResult[] agrRes = [SELECT  Upgraded_Product__c productId,
                                            Upgraded_Product__r.APN_Number__c productNumber, 
                                            Upgraded_Product__r.Name productName,
                                            ServiceContract.Service_Contract_Type__c scType, 
                                            SUM(Current_Quantity__c) quantity
                                    FROM ContractLineItem
                                    WHERE isPureConnectPrem__c = true 
                                            AND ServiceContract.Service_Contract_Type__c != 'Hardware'
                                            AND ServiceContract.Service_Contract_Type__c != 'Mirror'
                                            AND ServiceContract.Sold_To_Name__c = :soldToAccountId
                                            AND ServiceContract.End_User_Name__c = :endUserAccountId
                                            AND (
                                                ( ServiceContract.Agreement_Status__c = 'Active'                                           
                                                 AND Maintenance_Start_Date__c <= :System.today()
                                                 AND Maintenance_End_Date__c >= :System.today() )
                                                OR 
                                                ( ServiceContract.Agreement_Status__c = 'In Negotiation'                                           
                                                 AND ServiceContract.StartDate <= :System.today()
                                                 AND ServiceContract.EndDate >= :System.today() )
                                            )
                                            AND Upgraded_Product__r.Type__c NOT IN :productTypesToExclude
                                    GROUP BY Upgraded_Product__c,
                                            Upgraded_Product__r.APN_Number__c, 
                                            Upgraded_Product__r.Name, 
                                            ServiceContract.Service_Contract_Type__c];
        
        for (AggregateResult ar : agrRes ) {
            String productId = String.valueOf(ar.get('productId'));
            String productNumber = String.valueOf(ar.get('productNumber'));
            String productName = String.valueOf(ar.get('productName'));
            String scType = String.valueOf(ar.get('scType'));
            Integer quantity = Integer.valueOf(ar.get('quantity'));
            
            /// replace upgraded products with a new product values,
            /// upgrade of one product can add additional products based on the product upgrade metrix 
            Boolean upgrade = false;
            for ( Pure_Connect_Version_Upgrade__c upgr : pendingUpgrProds ) {   
                System.debug('productNumber = ' + productNumber);
                 System.debug('upgr.Old_Product_APN_Number__c = ' + upgr.Old_Product_APN_Number__c);
                if ( productNumber == upgr.Old_Product_APN_Number__c) {
                    upgrade = true;
                    if(upgr.New_Product__c != NULL){
                        String productIdUpgr = upgr.New_Product__c;
                        String productNumberUpgr = upgr.New_Product_APN_Number__c;
                        String productNameUpgr = upgr.New_Product__r.Name;
                        prdlines.add( new CustomerProduct(productIdUpgr, productNumberUpgr, productNameUpgr, scType, quantity, '', '' ) );  
                    }                                                           
                }
            }
            
            /// add non-upgrade products 
            if ( ! upgrade )                                    
                prdlines.add( new CustomerProduct(productId, productNumber, productName, scType, quantity, '', '' ) );
        }
        
        ///STEP - 2. Process Mirror contracts. Mirror products are not subject to Upgrades, they show up in LMS exactly as is, even if
        // there is a pending Upgrade request 
        
        AggregateResult[] agrResMirr = [SELECT  Upgraded_Product__c productId,
                                                Upgraded_Product__r.APN_Number__c productNumber, 
                                                Upgraded_Product__r.Name productName,
                                                ServiceContract.Service_Contract_Type__c scType, 
                                                SUM(Current_Quantity__c) quantity
                                        FROM ContractLineItem
                                        WHERE isPureConnectPrem__c = true 
                                            AND ServiceContract.Service_Contract_Type__c != 'Hardware'
                                            AND ServiceContract.Service_Contract_Type__c = 'Mirror'
                                            AND ServiceContract.Sold_To_Name__c = :soldToAccountId
                                            AND ServiceContract.End_User_Name__c = :endUserAccountId
                                            AND ServiceContract.Agreement_Status__c = 'Active'                                         
                                            AND Maintenance_Start_Date__c <= :System.today()
                                            AND Maintenance_End_Date__c >= :System.today()
                                            AND Upgraded_Product__r.Type__c NOT IN :productTypesToExclude
                                        GROUP BY Upgraded_Product__c, 
                                            Upgraded_Product__r.APN_Number__c, 
                                            Upgraded_Product__r.Name, 
                                            ServiceContract.Service_Contract_Type__c];
        
        for (AggregateResult ar : agrResMirr ) {
            String productId = String.valueOf(ar.get('productId')); 
            String productNumber = String.valueOf(ar.get('productNumber'));
            String productName = String.valueOf(ar.get('productName'));
            String scType = String.valueOf(ar.get('scType'));
            Integer quantity = Integer.valueOf(ar.get('quantity'));
            prdlines.add( new CustomerProduct(productId, productNumber, productName, scType, quantity, '', '') );
        }   
        
        // Code to populate Product Category and Product Version
        Map<String, String> itemCategories = new Map<String, String>();
        for(LMS_ItemCategory__c lic : [SELECT id, Category_Id__c, Short_Name__c FROM LMS_ItemCategory__c]){
            itemCategories.put(lic.Category_Id__c, lic.Short_Name__c);  
        }
        
        for(CustomerProduct cp : prdlines){
            String[] splitCodes = cp.partNumber.split('-'); 
            if(splitCodes.size() > 2){
                cp.productCategory = itemCategories.get(splitCodes[1]);
                if(splitCodes[2] == 'NV'){
                    cp.productVersion = '4.0';
                }else{
                    cp.productVersion = splitCodes[2];
                }
            }
        }
        return prdlines;
    }
    
    public static List<Pure_Connect_Version_Upgrade__c> pendingUpgradeProducts(String accntId) {
         List<Pure_Connect_Version_Upgrade__c> upgrProdsMapping = new List<Pure_Connect_Version_Upgrade__c>();
         List<Product_Upgrade_Request__c> upgrReqst = [SELECT Product__c FROM Product_Upgrade_Request__c 
                                                        WHERE Account__c = :accntId
                                                        AND Type__c = 'Version' AND Processed__c = false];
         if ( ! upgrReqst.isEmpty() )   {
            Set<String> prodIds = new Set<String>();
            
            for (Product_Upgrade_Request__c r : upgrReqst)
                prodIds.add(String.ValueOf(r.Product__c));
            
            upgrProdsMapping = [SELECT Old_Product_APN_Number__c, New_Product_APN_Number__c, New_Product__r.Name, New_Product__c, New_Product__r.Product_Group__c
                                FROM Pure_Connect_Version_Upgrade__c
                                
                                WHERE Old_Product__c IN : prodIds];
         }                                             
         return upgrProdsMapping;
    }
    
    public class CustomerProduct {
        public String productId;
        public String partNumber;
        public String partDescription;
        public String scType;
        public Integer quantity;
        public String productCategory;
        public String productVersion;
        
        public CustomerProduct(String productId, String partNumber, String partDescription, string scType, Integer quantity, String productCategory, String productVersion) {
            this.productId = productId;
            this.partNumber = partNumber;
            this.partDescription = partDescription;
            this.scType = scType;
            this.quantity = quantity;
            this.productCategory = productCategory;
            this.productVersion = productVersion;
        }
    }
    
    public static void generateSnapshot(String soldTo, String endUser, String snapshotReason){
        
        License_Snapshot_Sold_To_End_User__c lsseRecord = new License_Snapshot_Sold_To_End_User__c(Sold_To__c = soldTo, 
                                                                                                    End_User__c = endUser,
                                                                                                    Sold_To_End_User__c = soldTo + endUser,
                                                                                                    Regenerate_Snapshot__c = true,
                                                                                                    Snapshot_Reason__c = snapshotReason
                                                                                                   );
        Database.upsert(lsseRecord, Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c, false);
        
    }
    
    public static void generateSnapshot(String[] soldToAccountIds, String endUser, String snapshotReason){
        List<License_Snapshot_Sold_To_End_User__c> lsseRecords = [SELECT Id, Sold_To__c, End_User__c, Sold_To_End_User__c, Last_Processed_Date__c, Snapshot_Generated__c, Regenerate_Snapshot__c, Snapshot_Reason__c 
                                                                  FROM License_Snapshot_Sold_To_End_User__c 
                                                                  WHERE End_User__c = :endUser AND Sold_To__c IN :soldToAccountIds];
        for(License_Snapshot_Sold_To_End_User__c lsseRecord: lsseRecords){
            lsseRecord.Regenerate_Snapshot__c = true;
            lsseRecord.Snapshot_Reason__c = snapshotReason;
        }                                                                  
        
        Database.update(lsseRecords, false);
        
    }
    
    public static void generateSnapshot(String endUser, String snapshotReason){
        
        List<License_Snapshot_Sold_To_End_User__c> lsseRecords = [SELECT Id, Sold_To__c, End_User__c, Sold_To_End_User__c, Last_Processed_Date__c, Snapshot_Generated__c, Regenerate_Snapshot__c, Snapshot_Reason__c 
                                                                  FROM License_Snapshot_Sold_To_End_User__c 
                                                                  WHERE End_User__c = :endUser];
        for(License_Snapshot_Sold_To_End_User__c lsseRecord: lsseRecords){
            lsseRecord.Regenerate_Snapshot__c = true;
            lsseRecord.Snapshot_Reason__c = snapshotReason;
        }                                                                  
        
        Database.update(lsseRecords, false);
        
    }
    
    public static void refreshSnapshot(String endUserAccountId){
        System.debug('@@@refresh started');
        // Regenerate Snapshot ...
        List<License_Snapshot_Sold_To_End_User__c> lsseRecords = [SELECT Id, Sold_To__c, End_User__c, Sold_To_End_User__c, Last_Processed_Date__c, Snapshot_Generated__c, Regenerate_Snapshot__c, Snapshot_Reason__c 
                                                                  FROM License_Snapshot_Sold_To_End_User__c 
                                                                  WHERE End_User__c = :endUserAccountId AND (Snapshot_Generated__c = false OR Regenerate_Snapshot__c = true)];
                                                                    
        Set<String> soldToAccountIds = new Set<String>();
        List<License_Snapshot__c> snapshotRecordsNEW = new List<License_Snapshot__c>();
                                                                        
        for(License_Snapshot_Sold_To_End_User__c lsseRecord : lsseRecords){
            String soldToAccountId = lsseRecord.Sold_To__c;
            soldToAccountIds.add(soldToAccountId);
            System.debug('@@calling generatesnapshot method');
            snapshotRecordsNEW.addAll(generateSnapshotRecords(soldToAccountId, endUserAccountId));
            
            lsseRecord.Last_Processed_Date__c = Date.today();
            lsseRecord.Snapshot_Generated__c = true;
            lsseRecord.Regenerate_Snapshot__c = false;
            lsseRecord.Snapshot_Reason__c = '';
        }
        
        // InActive all existing records first
        List<License_Snapshot__c> existingSnapShotData = [SELECT id, IsActive__c FROM License_Snapshot__c WHERE Sold_To__c IN :soldToAccountIds AND End_User__c = :endUserAccountId];
        for(License_Snapshot__c lp : existingSnapShotData){
            lp.IsActive__c = false;
        }
        Database.update(existingSnapShotData);
        
        // Insert new Snapshot data
        Database.upsert(snapshotRecordsNEW, Schema.License_Snapshot__c.Sold_To_End_User_Part_Number__c, false);
            
        // Handle Purchase Upgrades for LMS ...
        performPurchaseUpgrades(endUserAccountId);
        //addFreeParts(endUserAccountId);
        Database.upsert(lsseRecords, Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c, false);
    }
    
    public static void refreshSnapshot(String endUserAccountId, String[] soldToAccountIds){
        
        // Regenerate Snapshot ...
        List<License_Snapshot_Sold_To_End_User__c> lsseRecords = [SELECT Id, Sold_To__c, End_User__c, Sold_To_End_User__c, Last_Processed_Date__c, Snapshot_Generated__c, Regenerate_Snapshot__c, Snapshot_Reason__c 
                                                                  FROM License_Snapshot_Sold_To_End_User__c 
                                                                  WHERE End_User__c = :endUserAccountId AND Sold_To__c IN :soldToAccountIds AND (Snapshot_Generated__c = false OR Regenerate_Snapshot__c = true)];
        
        List<License_Snapshot__c> snapshotRecordsNEW = new List<License_Snapshot__c>();
        for(License_Snapshot_Sold_To_End_User__c lsseRecord : lsseRecords){
            String soldToAccountId = lsseRecord.Sold_To__c;
            snapshotRecordsNEW.addAll(generateSnapshotRecords(soldToAccountId, endUserAccountId));
            
            lsseRecord.Last_Processed_Date__c = Date.today();
            lsseRecord.Snapshot_Generated__c = true;
            lsseRecord.Regenerate_Snapshot__c = false;
            lsseRecord.Snapshot_Reason__c = '';
        }
        // InActive all existing records first
        List<License_Snapshot__c> existingSnapShotData = [SELECT id, IsActive__c FROM License_Snapshot__c WHERE Sold_To__c IN :soldToAccountIds AND End_User__c = :endUserAccountId];
        for(License_Snapshot__c lp : existingSnapShotData){
            lp.IsActive__c = false;
        }
        Database.update(existingSnapShotData);
        
        // Insert new Snapshot data
        Database.upsert(snapshotRecordsNEW, Schema.License_Snapshot__c.Sold_To_End_User_Part_Number__c, false);
        
        // Handle Purchase Upgrades for LMS ...
        performPurchaseUpgrades(endUserAccountId);
        //addFreeParts(endUserAccountId);
        Database.upsert(lsseRecords, Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c, false);
    }
    
    public static List<License_Snapshot__c> generateSnapshotRecords(String soldToAccountId, String endUserAccountId){
        Map<String, License_Snapshot__c> licenseSnapshotRecordsMap = new Map<String, License_Snapshot__c>();
        List<CustomerProduct> customerProducts = getContractLineItemsByEU(soldToAccountId, endUserAccountId);
        for(CustomerProduct customerProduct: customerProducts){
            System.debug('@@ Part Number'+customerProduct.partNumber);
            // Sold_To_End_User_Part_Number__c
            String uniqueKey = soldToAccountId + endUserAccountId + (String)customerProduct.partNumber;
            License_Snapshot__c snapshotRecord;
            if(licenseSnapshotRecordsMap.containsKey(uniqueKey)){
                snapshotRecord = licenseSnapshotRecordsMap.get(uniqueKey);
                if(customerProduct.scType == 'Perpetual')
                    snapshotRecord.Perpetual__c += customerProduct.quantity;
                else 
                    snapshotRecord.Non_Perpetual__c += customerProduct.quantity;
            } else {
                snapshotRecord = new License_Snapshot__c();
                snapshotRecord.Sold_To__c = soldToAccountId;
                snapshotRecord.End_User__c = endUserAccountId;
                snapshotRecord.Sold_To_End_User_Part_Number__c = uniqueKey;
                snapshotRecord.Change_Date__c = Date.today();
                snapshotRecord.Product__c = customerProduct.productId;
                snapshotRecord.Part_Number__c = customerProduct.partNumber;
                snapshotRecord.Description__c = customerProduct.partDescription;
                snapshotRecord.ProductCategory__c = customerProduct.productCategory;
                snapshotRecord.ProductVersion__c = customerProduct.productVersion;
                snapshotRecord.Perpetual__c = 0;
                snapshotRecord.Non_Perpetual__c = 0;
                if(customerProduct.scType == 'Perpetual')
                    snapshotRecord.Perpetual__c = customerProduct.quantity;
                else 
                    snapshotRecord.Non_Perpetual__c = customerProduct.quantity;
                if(customerProduct.scType == 'Mirror')
                    snapshotRecord.isMirrored__c = true;
                else 
                    snapshotRecord.isMirrored__c = false;
            }
            snapshotRecord.IsActive__c = true;
            licenseSnapshotRecordsMap.put(uniqueKey, snapshotRecord);
        }
        return licenseSnapshotRecordsMap.values();  
    }
    
    public static void performPurchaseUpgrades(String endUser){
        Map<String, UL_Upsize_Parts__c> ULUpsizeParts = UL_Upsize_Parts__c.getAll();
        // Snapshot rows with UL Parts
        List<License_Snapshot__c> snapshotRecordsULParts = [SELECT Id, Name, 
                                                                Part_Number__c, Description__c, Product__c, Product__r.APN_Number__c, ProductCategory__c, Product_Category_Version__c, ProductVersion__c, 
                                                                Sold_To__c, End_User__c, Sold_To_End_User_Part_Number__c,
                                                                Perpetual__c, Non_Perpetual__c, Change_Date__c, IsActive__c, isMirrored__c 
                                                            FROM License_Snapshot__c 
                                                            WHERE End_User__c = :endUser AND IsActive__c = true AND Part_Number__c IN :ULUpsizeParts.KeySet()];
        
        if(!snapshotRecordsULParts.isEmpty()){
            Map<String, String> itemCategories = new Map<String, String>();
            for(LMS_ItemCategory__c lic : [SELECT id, Category_Id__c, Short_Name__c FROM LMS_ItemCategory__c]){
                itemCategories.put(lic.Category_Id__c, lic.Short_Name__c);  
            }
            
            Set<String> ULUpsizePartsNamesUpgradeFrom = new Set<String>();
            Set<String> ULUpsizePartsNamesUpgradeTo = new Set<String>();
            Map<String, String> ULPartFromToMapping = new Map<String, String>();
            
            for(License_Snapshot__c lsRecord : snapshotRecordsULParts){
                UL_Upsize_Parts__c ulPart = ULUpsizeParts.get(lsRecord.Part_Number__c);
                if(ulPart != NULL){
                    ULUpsizePartsNamesUpgradeFrom.add(ulPart.Part_To_Be_Decremented__c);
                    ULUpsizePartsNamesUpgradeTo.add(ulPart.Part_To_Be_Incremented__c);
                }
            }                                           
            System.debug(ULUpsizePartsNamesUpgradeFrom);
            System.debug(ULUpsizePartsNamesUpgradeTo);
    
            Map<String, Product2> productsMap = new Map<String, Product2>();
            for(Product2 p: [SELECT Id, APN_Number__c, Description FROM Product2 WHERE APN_Number__c IN :ULUpsizePartsNamesUpgradeTo]){
                productsMap.put(p.APN_Number__c, p);
            }           
            
            // Snapshot rows with for Parts to Decrement 
            List<License_Snapshot__c> snapshotRecordsDecrementParts = [SELECT Id, Name, 
                                                                            Part_Number__c, Description__c, Product__c, ProductCategory__c, Product_Category_Version__c, ProductVersion__c, 
                                                                            Sold_To__c, End_User__c, Sold_To_End_User_Part_Number__c,
                                                                            Perpetual__c, Non_Perpetual__c, Change_Date__c, IsActive__c, isMirrored__c 
                                                                        FROM License_Snapshot__c WHERE End_User__c = :endUser AND IsActive__c = true AND Part_Number__c IN :ULUpsizePartsNamesUpgradeFrom 
                                                                        ORDER BY Perpetual__c, Non_Perpetual__c];
            // Snapshot rows with for Parts to Increment 
            List<License_Snapshot__c> snapshotRecordsIncrementParts = [SELECT Id, Name, 
                                                                            Part_Number__c, Description__c, Product__c, ProductCategory__c, Product_Category_Version__c, ProductVersion__c, 
                                                                            Sold_To__c, End_User__c, Sold_To_End_User_Part_Number__c,
                                                                            Perpetual__c, Non_Perpetual__c, Change_Date__c, IsActive__c, isMirrored__c 
                                                                        FROM License_Snapshot__c WHERE End_User__c = :endUser AND IsActive__c = true AND Part_Number__c IN :ULUpsizePartsNamesUpgradeTo
                                                                        ORDER BY Perpetual__c, Non_Perpetual__c];   
            // New Records to insert for Purchase Upgades
            List<License_Snapshot__c> snapshotNewRecords = new List<License_Snapshot__c>();
            
            // Loop through each UL Part which is Purchase upgrade part ...
            for(License_Snapshot__c ulLSRecord : snapshotRecordsULParts){
                UL_Upsize_Parts__c ulPart = ULUpsizeParts.get(ulLSRecord.Part_Number__c);
                Integer ulLSRecordPerpetualQuantity = ulLSRecord.Perpetual__c != NULL ? ulLSRecord.Perpetual__c.intValue() : 0;
                Integer ulLSRecordNonPerpetualQuantity = ulLSRecord.Non_Perpetual__c != NULL ? ulLSRecord.Non_Perpetual__c.intValue() : 0;
                String IncrementPartNumber='';
                // Loop through each Snapshot Records that needs to be decremented ...
                for(License_Snapshot__c decrementLSRecord : snapshotRecordsDecrementParts){
                    if(decrementLSRecord.Part_Number__c == ulPart.Part_To_Be_Decremented__c){
                        if(ulLSRecordPerpetualQuantity > 0 ){
                            if(decrementLSRecord.Perpetual__c >= ulLSRecordPerpetualQuantity){
                                decrementLSRecord.Perpetual__c = decrementLSRecord.Perpetual__c - ulLSRecordPerpetualQuantity;
                                ulLSRecordPerpetualQuantity = 0;        
                            } else {
                                ulLSRecordPerpetualQuantity = ulLSRecordPerpetualQuantity - decrementLSRecord.Perpetual__c.intValue();
                                decrementLSRecord.Perpetual__c = 0;
                            }
                        }
                        if(ulLSRecordNonPerpetualQuantity > 0){
                            if(decrementLSRecord.Non_Perpetual__c >= ulLSRecordNonPerpetualQuantity){
                                decrementLSRecord.Non_Perpetual__c = decrementLSRecord.Non_Perpetual__c - ulLSRecordNonPerpetualQuantity;
                                ulLSRecordNonPerpetualQuantity = 0;     
                            } else {
                                ulLSRecordNonPerpetualQuantity = ulLSRecordNonPerpetualQuantity - decrementLSRecord.Non_Perpetual__c.intValue();
                                decrementLSRecord.Non_Perpetual__c = 0;
                            }
                        }
                        // Check if the same part exists in snapshotRecordsIncrementParts as well so you need to pass updated quanties
                        // The following for loop helps to handle situations where you have UPLIFT PARTS like A-->B, B-->C
                        for(Integer i=0; i < snapshotRecordsIncrementParts.size(); i++){
                            if(snapshotRecordsIncrementParts[i].Part_Number__c == decrementLSRecord.Part_Number__c){
                                snapshotRecordsIncrementParts[i] = decrementLSRecord;   
                                IncrementPartNumber=decrementLSRecord.Part_Number__c;
                            }   
                        }
                    }
                }
                
                // Loop through each Snapshot Records that needs to be incremented...
                Boolean incrementPartAlreadyExists = false;
                for(License_Snapshot__c incrementLSRecord : snapshotRecordsIncrementParts){
                    if(incrementLSRecord.Part_Number__c == ulPart.Part_To_Be_Incremented__c){
                        incrementLSRecord.Perpetual__c = incrementLSRecord.Perpetual__c + ulLSRecord.Perpetual__c;
                        incrementLSRecord.Non_Perpetual__c = incrementLSRecord.Non_Perpetual__c + ulLSRecord.Non_Perpetual__c;
                        incrementPartAlreadyExists = true;
                    }
                }

                // Create new snapshot record if the record does not exist
                if(incrementPartAlreadyExists == false){
                    Product2 product = productsMap.get(ulPart.Part_To_Be_Incremented__c);
                    String[] splitCodes = ulPart.Part_To_Be_Incremented__c.split('-');
                    String productCategory = '';
                    String productVersion = '';
                    if(splitCodes.size() > 2){
                        productCategory = itemCategories.get(splitCodes[1]);
                        productVersion = splitCodes[2];     
                    }
                    snapshotNewRecords.add(new License_Snapshot__c(
                            Part_Number__c = product.APN_Number__c, 
                            Description__c = product.Description, 
                            Product__c = product.Id, 
                            ProductCategory__c = productCategory, 
                            ProductVersion__c = productVersion, 
                            Sold_To__c = ulLSRecord.Sold_To__c, 
                            End_User__c = ulLSRecord.End_User__c, 
                            Sold_To_End_User_Part_Number__c = ulLSRecord.Sold_To__c + '' + ulLSRecord.End_User__c + '' + product.APN_Number__c,
                            Perpetual__c = ulLSRecord.Perpetual__c, 
                            Non_Perpetual__c = ulLSRecord.Non_Perpetual__c, 
                            Change_Date__c = Date.Today(), 
                            IsActive__c = true, 
                            isMirrored__c =  ulLSRecord.isMirrored__c
                    )); 
                }
                
                // Inactive any old snapshot rows with zero quantities 
                for(License_Snapshot__c decrementLSRecord : snapshotRecordsDecrementParts){
                    if(decrementLSRecord.Perpetual__c <= 0 && decrementLSRecord.Non_Perpetual__c <= 0  && decrementLSRecord.part_Number__c!=IncrementPartNumber){
                        decrementLSRecord.IsActive__c = false;   
                    }   
                }
                
                // Inactivate snapshot record with UL Part 
                ulLSRecord.IsActive__c = false;
            }
            
            if(snapshotRecordsULParts.size() > 0)
                Database.update(snapshotRecordsULParts);
            if(snapshotRecordsDecrementParts.size() > 0)
                Database.update(snapshotRecordsDecrementParts);
            if(snapshotRecordsIncrementParts.size() > 0)
                Database.update(snapshotRecordsIncrementParts);
            if(snapshotNewRecords.size() > 0)
                Database.insert(snapshotNewRecords);
        }
    }
    
    /*
    public static void addFreeParts(String endUser){
        List<Pure_Connect_Free_Part__c> freePartsConfig = [SELECT Id, Name, Purchased_Product__c, Purchased_Product_APN_Number__c, Free_Product__c, Free_Part_APN_Number__c, Free_Product__r.Description FROM Pure_Connect_Free_Part__c ];
        
        Set<String> freePartAPNNumbers = new Set<String>(); 
        for(Pure_Connect_Free_Part__c freePart : freePartsConfig){
            freePartAPNNumbers.add(freePart.Purchased_Product_APN_Number__c);   
        }
        
        // Snapshot rows with for Parts to Decrement 
        List<License_Snapshot__c> snapshotRecords = [SELECT Id, Part_Number__c, Product__c, ProductCategory__c, ProductVersion__c, 
                                                        Perpetual__c, Non_Perpetual__c, Total__c, isMirrored__c, IsActive__c, End_User__c, Sold_To__c
                                                        FROM License_Snapshot__c WHERE End_User__c = :endUser AND IsActive__c = true AND Part_Number__c IN :freePartAPNNumbers];
        
        List<License_Snapshot__c> snapshotRecordsToAdd = new List<License_Snapshot__c>();
        for(License_Snapshot__c lsRecord : snapshotRecords){
            for(Pure_Connect_Free_Part__c freePart : freePartsConfig){
                if(lsRecord.Part_Number__c == freePart.Purchased_Product_APN_Number__c){
                    License_Snapshot__c snapshotRecord = new License_Snapshot__c();
                    snapshotRecord.Sold_To__c = lsRecord.Sold_To__c;
                    snapshotRecord.End_User__c = lsRecord.End_User__c;
                    snapshotRecord.Sold_To_End_User_Part_Number__c = lsRecord.Sold_To__c + '' + lsRecord.End_User__c + freePart.Free_Part_APN_Number__c;
                    snapshotRecord.Change_Date__c = Date.today();
                    snapshotRecord.Product__c = freePart.Free_Product__c;
                    snapshotRecord.Part_Number__c = freePart.Free_Part_APN_Number__c;
                    snapshotRecord.Description__c = freePart.Free_Product__r.Description;
                    snapshotRecord.ProductCategory__c = lsRecord.ProductCategory__c;
                    snapshotRecord.ProductVersion__c = lsRecord.ProductVersion__c;
                    snapshotRecord.Perpetual__c = lsRecord.Perpetual__c;
                    snapshotRecord.Non_Perpetual__c = lsRecord.Non_Perpetual__c;
                    snapshotRecord.isMirrored__c = lsRecord.isMirrored__c;
                    snapshotRecord.IsActive__c = true;
                    snapshotRecordsToAdd.add(snapshotRecord);
                }
            }
        }
        if(snapshotRecordsToAdd.size() > 0){
            Database.insert(snapshotRecordsToAdd);  
        }                                       
    }
    */
    
    public static void trackServiceContractForSnapshot(List<ServiceContract> newList){
        Map<String, License_Snapshot_Sold_To_End_User__c> lsseRecordsMap = new Map<String, License_Snapshot_Sold_To_End_User__c>(); 
        for(ServiceContract newSC: newList) {
            String reason = '';
            if(newSC.Agreement_Status__c == 'Drop' || newSC.Agreement_Status__c == 'Shelved' || newSC.Agreement_Status__c == 'Downsize' || newSC.Agreement_Status__c == 'Legacy Drop'){
                reason = 'Downsize'; 
            } else if(newSC.Agreement_Status__c == 'Closed' || newSC.Agreement_Status__c == 'Terminated'){
                reason = 'Closed/ Terminated';     
            } else if(newSC.Agreement_Status__c == 'Split' || newSC.Agreement_Status__c == 'Transferred'){
                reason = 'Split/ Transferred';     
            } else if(newSC.Agreement_Status__c == 'In Negotiation'){
                reason = 'In Negotiation';      
            } else if(newSC.Agreement_Status__c == 'Active' || newSC.Agreement_Status__c == 'Credit'){
                reason = 'New Service Contract';      
            } 
            if(reason != ''){
                String key = newSC.Sold_To_Name__c + '' + newSC.End_User_Name__c;
                License_Snapshot_Sold_To_End_User__c lsseRecord = new License_Snapshot_Sold_To_End_User__c(Sold_To__c = newSC.Sold_To_Name__c, End_User__c = newSC.End_User_Name__c,
                                                                             Sold_To_End_User__c = key, Regenerate_Snapshot__c = true, Snapshot_Reason__c = reason);
                lsseRecordsMap.put(key, lsseRecord);
                reason = '';
            }
        } 
        if(lsseRecordsMap.size() > 0){
             Database.upsert(lsseRecordsMap.values(), Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c, false);
             if(!(System.isBatch() || System.isFuture()))
                Database.executeBatch(new LMSCaptureSnapshotBatch(), 1);
        }
    }
    
    public static void trackServiceContractForSnapshot(List<ServiceContract> newList, List<ServiceContract> oldList){
        Map<String, License_Snapshot_Sold_To_End_User__c> lsseRecordsMap = new Map<String, License_Snapshot_Sold_To_End_User__c>(); 
        for(Integer i = 0; i < newList.size(); i++){
            String reason = '';
            
            // Agreement Status Changed
            if(newList[i].Agreement_Status__c != oldList[i].Agreement_Status__c){
                reason = 'Service Contract Change'; 
                if(newList[i].Agreement_Status__c == 'Drop' || newList[i].Agreement_Status__c == 'Shelved' || newList[i].Agreement_Status__c == 'Downsize' || newList[i].Agreement_Status__c == 'Legacy Drop'){
                    reason = 'Downsize';    
                } else if(newList[i].Agreement_Status__c == 'Closed' || newList[i].Agreement_Status__c == 'Terminated'){
                    reason = 'Closed/ Terminated';    
                } else if(newList[i].Agreement_Status__c == 'Split' || newList[i].Agreement_Status__c == 'Transferred'){
                    reason = 'Split/ Transferred';   
                } else if(newList[i].Agreement_Status__c == 'In Negotiation'){
                    reason = 'In Negotiation';   
                } else if(newList[i].Agreement_Status__c == 'Active' || newList[i].Agreement_Status__c == 'Credit'){
                    reason = 'Service Contract Update';     
                }
            }
            
            // Sold To is Changed
            if(newList[i].Sold_To_Name__c != oldList[i].Sold_To_Name__c){
                reason = 'Sold To Account Changed';     
            }
            
            // Sold To is Changed
            if(newList[i].End_User_Name__c != oldList[i].End_User_Name__c){
                reason = 'End User Account Changed';    
            }
            
            // Maintenance Start Date Changed
            if(newList[i].startDate != oldList[i].startDate){
                reason = 'Maintenance Start Date Changed';  
            }

            // Maintenance End Date Changed
            if(newList[i].endDate != oldList[i].endDate){
                reason = 'Maintenance End Date Changed';    
            }

            if(reason != ''){
                if(newList[i].Sold_To_Name__c != oldList[i].Sold_To_Name__c){
                    String key1 = newList[i].Sold_To_Name__c + '' + newList[i].End_User_Name__c;
                    lsseRecordsMap.put(key1, new License_Snapshot_Sold_To_End_User__c(Sold_To__c = newList[i].Sold_To_Name__c, End_User__c = newList[i].End_User_Name__c,
                                                                                 Sold_To_End_User__c = key1, Regenerate_Snapshot__c = true, Snapshot_Reason__c = reason));
                                                                                 
                    String key2 = oldList[i].Sold_To_Name__c + '' + newList[i].End_User_Name__c;
                    lsseRecordsMap.put(key2, new License_Snapshot_Sold_To_End_User__c(Sold_To__c = oldList[i].Sold_To_Name__c, End_User__c = newList[i].End_User_Name__c,
                                                                                 Sold_To_End_User__c = key2, Regenerate_Snapshot__c = true, Snapshot_Reason__c = reason));
                    
                
                } else if(newList[i].End_User_Name__c != oldList[i].End_User_Name__c){
                    String key1 = newList[i].Sold_To_Name__c + '' + newList[i].End_User_Name__c;
                    lsseRecordsMap.put(key1, new License_Snapshot_Sold_To_End_User__c(Sold_To__c = newList[i].Sold_To_Name__c, End_User__c = newList[i].End_User_Name__c,
                                                                                 Sold_To_End_User__c = key1, Regenerate_Snapshot__c = true, Snapshot_Reason__c = reason));
                                                                                 
                    String key2 = newList[i].Sold_To_Name__c + '' + oldList[i].End_User_Name__c;
                    lsseRecordsMap.put(key2, new License_Snapshot_Sold_To_End_User__c(Sold_To__c = newList[i].Sold_To_Name__c, End_User__c = oldList[i].End_User_Name__c,
                                                                                 Sold_To_End_User__c = key2, Regenerate_Snapshot__c = true, Snapshot_Reason__c = reason));
                } else {
                    String key = newList[i].Sold_To_Name__c + '' + newList[i].End_User_Name__c;
                    lsseRecordsMap.put(key, new License_Snapshot_Sold_To_End_User__c(Sold_To__c = newList[i].Sold_To_Name__c, End_User__c = newList[i].End_User_Name__c,
                                                                                 Sold_To_End_User__c = key, Regenerate_Snapshot__c = true, Snapshot_Reason__c = reason));
                }
                reason = '';
            }
            
        }
        if(lsseRecordsMap.size() > 0){
             Database.upsert(lsseRecordsMap.values(), Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c, false);
             if(!(System.isBatch() || System.isFuture()))
                Database.executeBatch(new LMSCaptureSnapshotBatch(), 1);
        }
    }
    
    public static void trackServiceContractLineItemForSnapshot(List<ContractLineItem> newList, List<ContractLineItem> oldList){
        Boolean snapshotRegeneate = false;
        Set<Id> serviceContractIds = new Set<Id>();
        for(Integer i = 0; i < newList.size(); i++){
            if(newList[i].Current_Quantity__c != oldList[i].Current_Quantity__c){
                serviceContractIds.add(newList[i].ServiceContractId);
            }
            // && newList[i].Product2Id != oldList[i].Product2Id
            if(newList[i].PricebookEntryId != oldList[i].PricebookEntryId ){
                serviceContractIds.add(newList[i].ServiceContractId);
            }
            if(newList[i].Maintenance_Start_Date__c != oldList[i].Maintenance_Start_Date__c){
                serviceContractIds.add(newList[i].ServiceContractId);
            }
            if(newList[i].Maintenance_End_Date__c != oldList[i].Maintenance_End_Date__c){
                serviceContractIds.add(newList[i].ServiceContractId);
            }
            if(newList[i].Upgraded_Product__c != oldList[i].Upgraded_Product__c){
                serviceContractIds.add(newList[i].ServiceContractId);
            }
        }
        List<ServiceContract> serviceContracts = [SELECT Id, Sold_To_Name__c, End_User_Name__c FROM ServiceContract WHERE id IN :serviceContractIds];
        //Naresh Kumar  06/26/2018  Returning if map is empty.
        if(serviceContractIds.isEmpty())
            return;
        Map<String, License_Snapshot_Sold_To_End_User__c> lsseRecordsMap = new Map<String, License_Snapshot_Sold_To_End_User__c>();
        for(ServiceContract sc : serviceContracts){
            String key = sc.Sold_To_Name__c + '' + sc.End_User_Name__c;
            License_Snapshot_Sold_To_End_User__c lsseRecord = new License_Snapshot_Sold_To_End_User__c(Sold_To__c = sc.Sold_To_Name__c, End_User__c = sc.End_User_Name__c,
                                                                                                       Sold_To_End_User__c = key, Regenerate_Snapshot__c = true, Snapshot_Reason__c = 'Line Item Adjustment');
            lsseRecordsMap.put(key, lsseRecord);
        }
        if(lsseRecordsMap.size() > 0){
             Database.upsert(lsseRecordsMap.values(), Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c, false);
             if(!(System.isBatch() || System.isFuture()))
                Database.executeBatch(new LMSCaptureSnapshotBatch(), 1);
        }
    }
    
    public static void trackServiceContractLineItemForSnapshot(List<ContractLineItem> oldList){
        Boolean snapshotRegeneate = false;
        Set<Id> serviceContractIds = new Set<Id>();
        for(Integer i = 0; i < oldList.size(); i++){
            serviceContractIds.add(oldList[i].ServiceContractId);
        }
        List<ServiceContract> serviceContracts = [SELECT Id, Sold_To_Name__c, End_User_Name__c FROM ServiceContract WHERE id IN :serviceContractIds];
       
        Map<String, License_Snapshot_Sold_To_End_User__c> lsseRecordsMap = new Map<String, License_Snapshot_Sold_To_End_User__c>();
        for(ServiceContract sc : serviceContracts){
            String key = sc.Sold_To_Name__c + '' + sc.End_User_Name__c;
            License_Snapshot_Sold_To_End_User__c lsseRecord = new License_Snapshot_Sold_To_End_User__c(Sold_To__c = sc.Sold_To_Name__c, End_User__c = sc.End_User_Name__c,
                                                                                                       Sold_To_End_User__c = key, Regenerate_Snapshot__c = true, Snapshot_Reason__c = 'Line Item Deleted');
            lsseRecordsMap.put(key, lsseRecord);
        }
        if(lsseRecordsMap.size() > 0){
             Database.upsert(lsseRecordsMap.values(), Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c, false);
             if(!(System.isBatch() || System.isFuture()))
                Database.executeBatch(new LMSCaptureSnapshotBatch(), 1);
        }
    }
}