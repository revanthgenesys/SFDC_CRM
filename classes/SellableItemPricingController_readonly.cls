public class SellableItemPricingController_readonly {

    public Sellable_Item_Product__c sellableItem {get;set;}
    public List<SellableItemPricingControllerROHelper.wrapperPricing> pricingList {get;set;}
    public Boolean isPricingManagement {get;set;}

    public SellableItemPricingController_readonly(ApexPages.StandardController controller) {
    string offerstype;
        String sellableItemId = ApexPages.currentPage().getParameters().get('id');       
        sellableItem = SellableItemPricingControllerROHelper.getSelllableItem(sellableItemId);
        // 09-Oct-19:Muthu added the below line for PM10 requirement 
        offerstype = sellableItem.Offer_Type__c;
        pricingList = SellableItemPricingControllerROHelper.getPricingRecords(sellableItemId, offerstype);
        Set<String> currentUserGroup = MDMUtil.getCurrentUserGroup();
        if(currentUserGroup.contains(MDMUtil.GROUP_MML_PRICING_MANAGEMENT))
            isPricingManagement = true;
        else
            isPricingManagement = false;
        if(sellableItem.Price_Book_Type__c == null)
            sellableItem.Price_Book_Type__c = MDMUtil.BOTH_PRICING;

    }

}