//Naresh Kumar      07/08/2015
public without sharing class SellableItemPricingController {

    public SellableItemPricingController(ApexPages.StandardController controller) {
     Isoffernull = false;
    }
  public String offerstype{get;set;}
    String offertype;
    public boolean Isoffernull{get; set;}
  public Sellable_Item_Product__c sellableItem {get;set;}
    //public List<SellableItemPricingControllerHelper.wrapperPricing> retpricingList {get;set;}
    private List<SellableItemPricingControllerHelper.wrapperPricing> pricingList ;//= new List<SellableItemPricingControllerHelper.wrapperPricing>();
    public Boolean isPricingManagement {get;set;}
    private String sellableItemId;
    public SellableItemPricingController(){
      sellableItemId = ApexPages.currentPage().getParameters().get('id');
      sellableItem = SellableItemPricingControllerHelper.getSelllableItem(sellableItemId);
        //pricingList = SellableItemPricingControllerHelper.getPricingRecords(sellableItemId);
        //05-Nov-19 Muthu Added the below code
        offerstype = sellableItem.Offer_Type__c;
        if(offerstype!=null) Isoffernull = true;
        //05-Nov-19 Muthu Code Ends here
        pricingList = new List<SellableItemPricingControllerHelper.wrapperPricing>();
        Set<String> currentUserGroup = MDMUtil.getCurrentUserGroup();
        if(currentUserGroup.contains(MDMUtil.GROUP_MML_PRICING_MANAGEMENT))
          isPricingManagement = true;
        else
          isPricingManagement = false;
        if(sellableItem.Price_Book_Type__c == null)
          sellableItem.Price_Book_Type__c = MDMUtil.BOTH_PRICING;
  }

    public PageReference save(){
        Savepoint sp = Database.setSavepoint();
        try{
            update sellableItem;
            SellableItemPricingControllerHelper.save(sellableItem.id, pricingList);
            pricingList = SellableItemPricingControllerHelper.getPricingRecords(sellableItem.id, offerstype);
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Pricing saved Successfully.'));
        }catch(DmlException ex) {
            Database.rollback(sp);
            //Lokesh : Visualforce behaving absurdly - page messages getting auto displayed with additional "String" added at the start
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Hi Error: ' +e.getDMLMessage(0)));
        }
        return null;
    }

    public List<SellableItemPricingControllerHelper.wrapperPricing> getpricingList(){
    system.debug('offerstype'+sellableItem.Offer_Type__c);
    offerstype = sellableItem.Offer_Type__c;
    if(offerstype !=null)
    {
    Isoffernull =true;
    }
    system.debug('offerstype1111'+ offerstype);
            List<SellableItemPricingControllerHelper.wrapperPricing> retpricingList = SellableItemPricingControllerHelper.getPricingRecords(sellableItemId, offerstype);

        PricingList = new List<SellableItemPricingControllerHelper.wrapperPricing>();
        System.debug('getpricelist' + retpricingList);
        for(SellableItemPricingControllerHelper.wrapperPricing wrppr:retpricingList){
            if(sellableItem.Offer_Type__c != null && wrppr.newPricing !=null){

                if(sellableItem.Offer_Type__c=='PureConnect'){
                    offertype = 'PureConnect';
               System.debug('wrppr.newPricing.Price_Book__c'+ wrppr.newPricing.Price_Book__c + wrppr.newPricing.Name + wrppr.newPricing.offering_type__c);
                system.debug('wrppr'+ wrppr);
               if(wrppr.newPricing.offering_type__c.containsIgnoreCase(offertype)){
               System.debug('123if condition');
               PricingList.add(wrppr);
               }
                }
                else if(sellableItem.Offer_Type__c=='PPU'){
                    if(wrppr.newPricing.Name.containsIgnoreCase('PPU')){
                        PricingList.add(wrppr);
                    }
                }
                else if(sellableItem.Offer_Type__c=='PureEngage'){
                     offertype = 'PureEngage';
                    System.debug('wrppr.newPricing.offering_type__c --->'+wrppr.newPricing.Price_Book__c +wrppr.newPricing.Name+ wrppr.newPricing.offering_type__c);
                    //if(wrppr.newPricing!=null)
                    //{
                    if(wrppr.newPricing.offering_type__c.containsIgnoreCase(offertype)){
                        PricingList.add(wrppr);
                    //}
                }
                }
            }
            else{
                PricingList.add(wrppr);
            }
        }
        System.Debug('PricingList--->'+PricingList);
        return PricingList;
    }


    public void refresh0(){
      system.debug('offerstype'+sellableItem.Offer_Type__c);
      if(sellableItem.Offer_Type__c !=null)
      Isoffernull = true;
    }

    public void refresh(){

    }

    public void Flip_flag1(){
      if(sellableItem.Pricing_Approval_Required__c)
          sellableItem.Pricing_Approved__c=false;
    }

    public void Flip_flag2(){
      if(sellableItem.Pricing_Approved__c)
            sellableItem.Pricing_Approval_Required__c=false;
    }



}