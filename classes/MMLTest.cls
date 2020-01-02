@isTest (seeAllData=true)
private class MMLTest {
    static Base_Item_Product__c testBaseItem;
    static Sellable_Item_Product__c testSellableItem;  
    static Shippable_Item__c testShippableItem;
    static Sellable_Shippable_Items__c testSellableShippableItem;
    static Sellable_Item_Family__c testFamily;
    static Sellable_Item_SI_Version_Number__c testSIVersion;
    static testMethod void APN_ECCN_GenerationHelper() {
        //Creats test data
        createTestData();
        testSellableItem.Status__c = MDMUtil.SELLABLE_STATUS_DRAFT;
        testSellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS;
        update testSellableItem;
        //Updating ECCN
        testShippableItem.ECCN_GB_Numbers__c = '5D002 c.1.';
        update testShippableItem;
        //Deleting bill of material
        delete testSellableShippableItem;
    }
    
    static testMethod void SellableItemBeforeInsertUpdateHandler(){
        //Creats test data
        createTestData();
        testSellableItem.Locked__c = true;
        testSellableItem.Stage__c = true;
        testSellableItem.New_Family__c = testFamily.id; 
        testSellableItem.SI_Version_Number__c = testSIVersion.id;
        testSellableItem.Action__c = MDMUTIL.ACTION_UP_REV;
        try{
            //Try to uprev when locked is true        
            update testSellableItem;
        }
        catch(Exception ex){}
        //Try to uprev when locked is false
        testSellableItem.Locked__c = false;
        update testSellableItem;
        //Undo uprev
        testSellableItem.Action__c = MDMUTIL.ACTION_NO_CHANGE;        
        update testSellableItem;
        try{
            //Delete sellable item          
            delete testSellableItem;
        }
        catch(Exception ex){}
    }
    
    static testMethod void SellableItemHeaderExtension(){
        //Creats test data
        createTestData();
        testSellableItem.Status__c = MDMUtil.SELLABLE_STATUS_TO_BE_UPDATED;
        testSellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE;
        SellableItemHeaderExtension extension = new SellableItemHeaderExtension(new ApexPages.StandardController(testSellableItem));
        
        extension.sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_DRAFT;
        extension.sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE;
        extension.showHideButtons();
        
        extension.sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SI_ATTRIBUTES_FROZEN;
        extension.sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE;
        extension.showHideButtons();
        
        extension.sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_PRICING_FROZEN;
        extension.sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE;
        extension.showHideButtons();
        
        extension.sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SELLABLE_ITEM_READY;
        extension.sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE;
        extension.showHideButtons();
        
        extension.sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SELLABLE_ITEM_READY;
        extension.sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE;
        extension.showHideButtons();
        
        extension.isSoftwareDelivery = true;
        extension.sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SAP_PROFILE_COMPLETE;
        extension.sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE;
        extension.showHideButtons();
        
        extension.draftComplete();
        extension.validateAndFreeze();
        extension.pricingComplete();
        extension.validateAndApprove();
        extension.draftComplete();
        extension.decline();
        extension.activateAndRelease();
        extension.updateSellableItem();
        extension.EOL();
        extension.ERPHold();
        extension.cloneRecord();     
        extension.showValidateAndApprove= false;
        extension.showSAPProfileComplete = false;
        extension.showFinanceReview = false;
        extension.showTax = false;
        extension.isTax = false;
        extension.submitToSAP();
        extension.FinanceReview();
        extension.Tax();
        //extension.deleteRecord();
    }
    
    static testMethod void SellableItemHistoryExtension(){
        //Creats test data
        createTestData();        
        testSellableItem.Status__c = 'Test 1';
        update testSellableItem;
        testSellableItem.Status__c = 'Test 2';
        update testSellableItem;
        testSellableItem.Status__c = null;
        update testSellableItem;
        //SI Version Number
        Sellable_Item_SI_Version_Number__c testSIVersion1 = new Sellable_Item_SI_Version_Number__c();
        testSIVersion1.Name = '10.0';
        insert testSIVersion1;      
        testSellableItem.SI_Version_Number__c = testSIVersion1.id;      
        update testSellableItem;
        
        ApexPages.currentPage().getParameters().put('seperateTab', 'true');
        SellableItemHistoryExtension extension = new SellableItemHistoryExtension(new ApexPages.StandardController(testSellableItem));
    }
    
    static testMethod void SellableItemPricingController(){
        //Creats test data
        createTestData();
        ApexPages.currentPage().getParameters().put('id', testSellableItem.id);
        SellableItemPricingController newSellableItem = new SellableItemPricingController();
        newSellableItem.getpricingList();
        newSellableItem.save();
        newSellableItem.refresh();
        newSellableItem.Flip_flag1();
        newSellableItem.Flip_flag2();   
        newSellableItem.refresh0();
        //newSellableItem.selectedOffer = 'Pureengage' ;
        newSellableItem.isPricingManagement =true;
        testSellableItem.Offer_Type__c='Pureengage';
        update testSellableItem;
        try{
        newSellableItem.getpricingList();
        }
        catch (Exception ex){          
        }
       // testSellableItem.Offer_Type__c='PPU';
       // update testSellableItem;
       // newSellableItem.getpricingList();
       // testSellableItem.Offer_Type__c='PPU';
      //  update testSellableItem;
      //  newSellableItem.getpricingList();
    }
    
    static testMethod void SellableItemPricingController_readonly(){
        //Creats test data
        createTestData();
        ApexPages.currentPage().getParameters().put('id', testSellableItem.id);
        SellableItemPricingController_readonly newSellableItem = new SellableItemPricingController_readonly(new ApexPages.StandardController(testSellableItem));
    	Sellable_Item_Product__c newSellableItemProduct = SellableItemPricingControllerROHelper.getSelllableItem(testSellableItem.id);
//      SellableItemPricingControllerROHelper.save();
    }
    
    static void createTestData(){
        //Creating test base item
        testBaseItem = new Base_Item_Product__c();
        testBaseItem.Name = 'Test Base Item 1';
        testBaseItem.New_Category__c = 'Routing';
    //    testBaseItem.Taxonomy_Solution_Category__c = 'Customer Engagement';
    //    testBaseItem.Taxonomy_Solution__c = 'Digital';
    //    insert testBaseItem;
        
        //Creating test sellable item
        testSellableItem = new Sellable_Item_Product__c();
        testSellableItem.Name = 'Test Sellable Item 1';
        testSellableItem.Status__c = MDMUtil.SELLABLE_STATUS_TO_BE_UPDATED;
        testSellableItem.Availability__c = mdmutil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS;
        testSellableItem.Offer_Type__c ='PureEngage';
        insert testSellableItem;
        
        //Creating test shippable item
        testShippableItem = new Shippable_Item__c();
        testShippableItem.Name = 'Test Shippable Item 1';
        testShippableItem.ECCN_GB_Numbers__c = '5D002';
        testShippableItem.ECCN_NL_Number__c = '5D002 Restricted';
        testShippableItem.ECCN_US_Number__c = '5D002 c.1.';
        insert testShippableItem;
        
        //Bill To Material
        testSellableShippableItem = new Sellable_Shippable_Items__c();
        testSellableShippableItem.Sellable_Item_Product__c = testSellableItem.id;
        testSellableShippableItem.Shippable_Item_Product__c = testShippableItem.id;
        insert testSellableShippableItem;
        
        //Family
        testFamily = new Sellable_Item_Family__c();
        testFamily.Name = '9.0.9';
        insert testFamily;
        
        //SI Version Number
        testSIVersion = new Sellable_Item_SI_Version_Number__c();
        testSIVersion.Name = '9.0';
        insert testSIVersion;
        
        List<Currency_Configuration__c> currConfigs = [SELECT id FROM Currency_Configuration__c];
                
        //Sellable Item Pricing
        List<Sellable_Item_Pricing__c> itemPricingToBeInserted = new List<Sellable_Item_Pricing__c>();
        if(currConfigs.size() > 0){
            Sellable_Item_Pricing__c testPricing1 = new Sellable_Item_Pricing__c();
            testPricing1.Sellable_Item_Product__c = testSellableItem.id;
            testPricing1.Name = 'North America';
            testPricing1.Currency_Configuration__c = currConfigs[0].id;
            testPricing1.Updated_Price__c = 100;
            testPricing1.Pricing_Type__c = 'New Pricing';
            testPricing1.Price_Book__c = 'NG5_NA_USD';
            itemPricingToBeInserted.add(testPricing1);
        }
        if(currConfigs.size() > 1){
            Sellable_Item_Pricing__c testPricing2 = new Sellable_Item_Pricing__c();
            testPricing2.Sellable_Item_Product__c = testSellableItem.id;
            testPricing2.Name = 'North America';
            testPricing2.Currency_Configuration__c = currConfigs[0].id;
            testPricing2.Updated_Price__c = 100;
            testPricing2.Pricing_Type__c = 'Old Pricing';
            testPricing2.Price_Book__c = 'NG1_APAC_USD';
            itemPricingToBeInserted.add(testPricing2);
        }       
        insert itemPricingToBeInserted;
        
    }
}