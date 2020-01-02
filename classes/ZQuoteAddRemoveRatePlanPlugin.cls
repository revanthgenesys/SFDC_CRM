global class ZQuoteAddRemoveRatePlanPlugin implements zqu.SelectProductComponentOptions.IAddRemoveRatePlanPlugin {
    
    public void onAdd(String quoteId, List<String> addedRatePlans) {

        ZQuotePromotionManagement promotionManager = new ZQuotePromotionManagement();
        if (promotionManager.HasPromotions())
        {           
            promotionManager.AddPromotions(quoteId, addedRatePlans);
        }
        
    }
    
    public void onRemove(String quoteId, List<String> removedRatePlans) {

        ZQuotePromotionManagement promotionManager = new ZQuotePromotionManagement();
        if (promotionManager.HasPromotions())
        {
            promotionManager.DeletePromotions(quoteId, removedRatePlans);
        }

    }
        
}