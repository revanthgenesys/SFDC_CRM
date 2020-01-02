//Naresh 07/08/2015
public without sharing class SellableItemPricingControllerROHelper {
    public static Sellable_Item_Product__c getSelllableItem(String sellableItemId){
        return [SELECT Name, Price_Book_Type__c, Pricing_Approval_Required__c, Pricing_Approved__c,Offer_Type__c   
        FROM Sellable_Item_Product__c WHERE id =: sellableItemId];
    }
  
    public static List<wrapperPricing> getPricingRecords(String sellableItemId, String Offerstype){    
    
        //Querying all pricing config records
         List<Currency_Configuration__c> configRecords = new List<Currency_Configuration__c>();
         system.debug('Offerstypehelper' +Offerstype);
        if(Offerstype == null){
        configRecords = [SELECT id, Name, Conversion_Rate__c, Multiplier__c,offering_type__c,            
            Price_Book__c, Pricing_Type__c,Display_Order__c FROM Currency_Configuration__c    ORDER BY Display_Order__c];
            }
         if(Offerstype != null){
        /* configRecords = [SELECT id, Name, Conversion_Rate__c, Multiplier__c,offering_type__c,            
            Price_Book__c, Pricing_Type__c FROM Currency_Configuration__c where offering_type__c INCLUDES (:Offerstype)   ORDER BY Display_Order__c]; */
            
            configRecords = [SELECT id, Name, Conversion_Rate__c, Multiplier__c,offering_type__c,            
            Price_Book__c, Pricing_Type__c,Display_Order__c FROM Currency_Configuration__c where offering_type__c INCLUDES (:Offerstype) and Start_Date__c <= TODAY AND End_Date__c >= TODAY   ORDER BY Display_Order__c];
            }
        //Will hold region name and it's old pricing details 
        Map<String, Currency_Configuration__c> mapRegionVsOldPricing = new Map<String, Currency_Configuration__c>();
        //Will hold region name and it's new pricing details 
        Map<String, Currency_Configuration__c> mapRegionVsNewPricing = new Map<String, Currency_Configuration__c>();
        //Will hold region names
        Set<String> setOfRegions = new Set<String>();
        Set<Decimal> setOfGroupId = new Set<Decimal>();
//        Set<String> setOfPriceBook = new Set<String>();
       Map<String, Currency_Configuration__c> mapofRegions = new Map<String,Currency_Configuration__c>();
       // List<String> setOfRegions = new List<String>();
        //Looping over each pricing record
        for(Currency_Configuration__c eachConfig : configRecords){
            //Adds region name to set
           setOfRegions.add(eachConfig.Name);

       //    mapofRegions.put(eachConfig.Name + '-'+ eachConfig.Pricing_Type__c + '-'+ eachConfig.Price_Book__c + '-' + eachConfig.Multiplier__c + '-' + eachConfig.Conversion_Rate__c, eachConfig);
            //Old Pricing
            if(eachConfig.Pricing_Type__c == MDMUtil.OLD_PRICING){
                //Populating old pricing details into map
               // mapRegionVsOldPricing.put(eachConfig.Name + '-'+ eachConfig.Pricing_Type__c + '-'+ eachConfig.Price_Book__c +'-' + eachConfig.Multiplier__c + '-' + eachConfig.Conversion_Rate__c, eachConfig);
                   mapRegionVsOldPricing.put(eachConfig.Name , eachConfig);
                
            }
            //New Pricing
            if(eachConfig.Pricing_Type__c == MDMUtil.NEW_PRICING){
                //Populating new pricing details into map
                //mapRegionVsNewPricing.put(eachConfig.Name + '-'+ eachConfig.Pricing_Type__c +'-'+ eachConfig.Price_Book__c + '-' + eachConfig.Multiplier__c + '-' + eachConfig.Conversion_Rate__c, eachConfig);
                mapRegionVsNewPricing.put(eachConfig.Name , eachConfig);
            }           
        }
        //Get GroupId for all regions and create a set of GroupIds for creating Array 
        Map<string,PricebookGroup__c> mapPBGroup = PricebookGroup__c.getAll();
        List<PricebookGroup__c> listPBGroup = mapPBGroup.values();
        for(PricebookGroup__c PBGroup :listPBGroup )
        {
            setOfGroupId.add(PBGroup.GroupId__c);
        }        

        //Will hold region name and it's old existing pricing details 
        Map<String, Sellable_Item_Pricing__c> mapRegionVsOldExistingPricing = new Map<String, Sellable_Item_Pricing__c>();
        //Will hold region name and it's new existing pricing details 
        Map<String, Sellable_Item_Pricing__c> mapRegionVsNewExistingPricing = new Map<String, Sellable_Item_Pricing__c>();
        getPricingForSellableItem(sellableItemId, mapRegionVsOldExistingPricing, mapRegionVsNewExistingPricing);
		List<List<wrapperPricing>>  pricingListArray = new List<List<wrapperPricing>>();
        for(Decimal dec:setOfGroupId)
        {
            pricingListArray.add(new List<wrapperPricing>());
                
        }
        pricingListArray.add(new List<wrapperPricing>());
        List<wrapperPricing> pricingList = new List<wrapperPricing>();       
        //Looping over each Region
        for(String region : setOfRegions){
      
       // for(String region : mapofRegions.keySet()){
             system.debug('mapofRegions.keySet()' + mapofRegions.keySet());
            //Old Pricing record for current region
            Currency_Configuration__c oldPrice = mapRegionVsOldPricing.get(region);            
            //New Pricing record for current region
            Currency_Configuration__c newPrice = mapRegionVsNewPricing.get(region);
            wrapperPricing newRecord = new wrapperPricing();
            newRecord.oldPricing = oldPrice;
            newRecord.newPricing = newPrice;
            PricebookGroup__c PBCategory = mapPBGroup.get(newPrice.Price_Book__c);
            if(PBCategory!=null)
            newRecord.regionCategory = PBCategory.GroupId__c;
            else
           	newRecord.regionCategory = setOfGroupId.size();
            //Old Pricing existing record for current region
            Sellable_Item_Pricing__c oldExistingPrice = mapRegionVsOldExistingPricing.get(region);
            //New Pricing existing record for current region
            Sellable_Item_Pricing__c newExistingPrice = mapRegionVsNewExistingPricing.get(region);
            //Populating all prices
            if(oldExistingPrice != null){           
                if(oldExistingPrice.Price__c >= 0)  
                    newRecord.oldPrice = String.valueOf(oldExistingPrice.Price__c);
                if(oldExistingPrice.Updated_Price__c >= 0)
                    newRecord.oldCurrentPrice = String.valueOf(oldExistingPrice.Updated_Price__c);              
                newRecord.oldUpdatedPrice = newRecord.oldCurrentPrice;
            }
            if(newExistingPrice != null){
                if(newExistingPrice.Price__c >= 0)
                    newRecord.newPrice = String.valueOf(newExistingPrice.Price__c);
                if(newExistingPrice.Updated_Price__c >= 0)
                    newRecord.newCurrentPrice = String.valueOf(newExistingPrice.Updated_Price__c);
                newRecord.newUpdatedPrice = newRecord.newCurrentPrice;              
            }

//            pricingList.add(newRecord);
				Decimal aryIndex = newRecord.regionCategory;
            	Integer j = aryIndex.intValue()-1;
            	if(!pricingListArray.isEmpty())
                pricingListArray[j].add(newRecord);

} 
		    
			for(List<wrapperPricing> wP:pricingListArray)
            {
              if(pricingList.size()>0 && wP.size()>0)
                	pricingList.add(new wrapperPricing());
                wP.sort();
                pricingList.addAll(wP);
            }    	
  
        	return pricingList;
       
    }
    
    private static void  getPricingForSellableItem(String sellableItemId, Map<String, Sellable_Item_Pricing__c> mapRegionVsOldExistingPricing,
        Map<String, Sellable_Item_Pricing__c> mapRegionVsNewExistingPricing){
            
        List<Sellable_Item_Pricing__c> pricingRecords = [SELECT Name, Pricing_Type__c, Price__c, Price_Book__c, Updated_Price__c 
            FROM Sellable_Item_Pricing__c WHERE Sellable_Item_Product__c =: sellableItemId];
            
        //Looping over each pricing record
        for(Sellable_Item_Pricing__c eachPricingRecord : pricingRecords){
            //Old Pricing
            if(eachPricingRecord.Pricing_Type__c == MDMUtil.OLD_PRICING){
                //Populating old pricing details into map
                mapRegionVsOldExistingPricing.put(eachPricingRecord.Name, eachPricingRecord);
                
            }
            //New Pricing
            if(eachPricingRecord.Pricing_Type__c == MDMUtil.NEW_PRICING){
                //Populating new pricing details into map
                mapRegionVsNewExistingPricing.put(eachPricingRecord.Name, eachPricingRecord);
            }           
        }       
    }
    
/*    public static void save(String sellableItemId, List<wrapperPricing> pricingList){
        //Delete existing records
        List<Sellable_Item_Pricing__c> pricingRecordsToBeDeleted = [SELECT id FROM Sellable_Item_Pricing__c WHERE Sellable_Item_Product__c =: sellableItemId];
        if(!pricingRecordsToBeDeleted.isEmpty()){
            delete pricingRecordsToBeDeleted;
        }
        List<Sellable_Item_Pricing__c> pricingRecordsToBeInserted = new List<Sellable_Item_Pricing__c>();
        //Looping over each wrapper record
        for(wrapperPricing eachRecord : pricingList){
            //Old Pricing
            if(eachRecord.oldPricing != null){
                Sellable_Item_Pricing__c newOldPricing = new Sellable_Item_Pricing__c(Sellable_Item_Product__c = sellableItemId);
                newOldPricing.Conversion_Rate_Used__c = eachRecord.oldPricing.Conversion_Rate__c;
                newOldPricing.Currency_Configuration__c = eachRecord.oldPricing.id;
                newOldPricing.Multiplier_Used__c = eachRecord.oldPricing.Multiplier__c;
                newOldPricing.Name = eachRecord.oldPricing.Name;
                newOldPricing.Pricing_Type__c = MDMUtil.OLD_PRICING;            
                newOldPricing.Price_Book__c = eachRecord.oldPricing.Price_Book__c;  
                //newOldPricing.offering_type__c = eachRecord.offering_type__c;
                newOldPricing.Price__c = Double.valueOf((eachRecord.oldPrice == null || eachRecord.oldPrice.replace(' ','') == '') ? '-1' : eachRecord.oldPrice);
                newOldPricing.Updated_Price__c = Double.valueOf((eachRecord.oldUpdatedPrice == null || eachRecord.oldUpdatedPrice.replace(' ','') == '') ? '-1' : eachRecord.oldUpdatedPrice);
                pricingRecordsToBeInserted.add(newOldPricing);
            }
            //New Pricing
            if(eachRecord.newPricing != null){
                Sellable_Item_Pricing__c newNewPricing = new Sellable_Item_Pricing__c(Sellable_Item_Product__c = sellableItemId);
                newNewPricing.Conversion_Rate_Used__c = eachRecord.newPricing.Conversion_Rate__c;
                newNewPricing.Currency_Configuration__c = eachRecord.newPricing.id;
                newNewPricing.Multiplier_Used__c = eachRecord.newPricing.Multiplier__c;
                newNewPricing.Name = eachRecord.newPricing.Name;
                newNewPricing.Pricing_Type__c = MDMUtil.NEW_PRICING;            
                newNewPricing.Price_Book__c = eachRecord.newPricing.Price_Book__c;    
                //newNewPricing.offering_type__c = eachRecord.offering_type__c;
                newNewPricing.Price__c = Double.valueOf((eachRecord.newPrice == null || eachRecord.newPrice.replace(' ','') == '')  ? '-1' : eachRecord.newPrice);
                newNewPricing.Updated_Price__c = Double.valueOf((eachRecord.newUpdatedPrice == null || eachRecord.newUpdatedPrice.replace(' ','') == '') ? '-1' : eachRecord.newUpdatedPrice);
                pricingRecordsToBeInserted.add(newNewPricing);
            }
        }
        if(!pricingRecordsToBeInserted.isEmpty()){
            insert pricingRecordsToBeInserted;
        }
    }*/
    
    
    public class wrapperPricing implements Comparable{
        public Currency_Configuration__c oldPricing {get;set;}
        public Currency_Configuration__c newPricing {get;set;}  
        public String oldPrice {get;set;}
        public String oldCurrentPrice {get;set;}
        public String oldUpdatedPrice {get;set;}        
        public String newPrice {get;set;}
        public String newCurrentPrice {get;set;}
        public String newUpdatedPrice {get;set;}
      	public Decimal regionCategory {get;set;}
		
        public Integer compareTo(Object compareTo) 
    {
        wrapperPricing wP = (wrapperPricing) compareTo;
        if (newPricing.Display_Order__c == wP.newPricing.Display_Order__c) return 0;
        if (newPricing.Display_Order__c > wP.newPricing.Display_Order__c) return 1;
        return -1;        
    }
        
    }
    

}