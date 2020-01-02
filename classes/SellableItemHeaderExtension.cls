//Naresh Kumar  07/14/2015
public without sharing class SellableItemHeaderExtension {
    private Sellable_Item_Product__c sellableItem;
    public String sellableItemId {get;set;}
    public String clonedSellableItemId {get;set;}
    public Boolean showDraftComplete {get;set;}
    public Boolean showValidateAndFreeze {get;set;}
    public Boolean showPricingComplete {get;set;}
    public Boolean showValidateAndApprove {get;set;}
    public Boolean showSubmitToSAP {get;set;}
    public Boolean showSAPProfileComplete {get;set;}
    public Boolean showActivateAndRelease {get;set;}
    public Boolean showUpdateSellableItem {get;set;}
    public Boolean showFinanceReview {get;set;}//New flow
    public Boolean showTax{get;set;} //New flow
    public Boolean showEOL {get;set;}
    public Boolean showERPHold {get;set;}
    public Boolean showDecline {get;set;}
    public Boolean isPricingManagement {get;set;}
    public Boolean isProductManagement {get;set;}
    public Boolean isProjectManagement {get;set;}
    public Boolean isSoftwareDelivery {get;set;}    
    public Boolean isFinance {get;set;} //New Flow
    public Boolean isTax{get;set;}
    public String errorStatus {get;set;}
    public Boolean showDeleteButton {get;set;}
    
    public SellableItemHeaderExtension(ApexPages.StandardController stdController) {
        sellableItem = MDMUtil.getSellableItem(stdController.getRecord().id);
        sellableItemId = sellableItem.id;
        populateCurrentUserGroupInfo();
        showHideButtons();      
        showDeleteButton = SellableItemBeforeInsertUpdateHandler.isRecordDeletable(sellableItem);
        
        
    }
    
    @Testvisible private void showHideButtons(){
        if(sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_TO_BE_UPDATED 
            && (sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS 
                || sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE)){
            showDraftComplete = true;   
        }
        else if(sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_DRAFT 
            && (sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS 
                || sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE)){
            showValidateAndFreeze = true;   
        }
        else if(sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_SI_ATTRIBUTES_FROZEN 
            && (sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS 
                || sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE)){
            showPricingComplete = true; 
        }
        
        /*else if(sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_PRICING_FROZEN
            && (sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS 
                || sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE)){
            showValidateAndApprove = true; 
            showSubmitToSAP = true; 
        }*/
        
        //Commented by JJ as condition already in above scenario

        else if(sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_SELLABLE_ITEM_READY 
            && (sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS 
                || sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE)){
            showSubmitToSAP = true; 
            //showValidateAndApprove = true;
        }
        
        else if(sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_Submitted_to_Finance && isFinance){
                     showFinanceReview = true;
                 }
        else if(sellableItem.status__c == MDMUtil.SELLABLE_STATUS_Submitted_to_Tax && isTax){
              showTax = true;
        }
        else if((sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_SAP_PROFILE_COMPLETE)
            && (sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS 
                || sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE
            || sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_ERP_HOLD || 
                 sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_EOL) && isSoftwareDelivery){
            //showSAPProfileComplete = true;
            showActivateAndRelease = true;  
            showUpdateSellableItem = true;  
            showEOL = true;
            showERPHold = true;
                 } 
                     
    //  }
        /*
        else if(sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_SAP_PROFILE_COMPLETE
            && (sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS 
                || sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE)){
            showActivateAndRelease = true;  
        }
        */
        else if(
            (sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_SAP_PROFILE_COMPLETE
            && sellableItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_ACTIVE) && isSoftwareDelivery){
            showUpdateSellableItem = true;  
            showEOL = true;
            showERPHold = true;
        }
        //Decline button visibility
        showDecline = false;
        if(isPricingManagement && sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_SI_ATTRIBUTES_FROZEN){
            showDecline = true;
        }
        else if(isProjectManagement && sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_PRICING_FROZEN){
            showDecline = true;
        }
        else if(!isProductManagement && !isPricingManagement && !isProjectManagement){
            showDecline = true;
        }
    }

    public void draftComplete(){
        sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_DRAFT;
        update sellableItem;
    }
    
    public void validateAndFreeze(){
        errorStatus='';
        boolean error = false;
        if(sellableItem.Number_of_BOM_Updates__c == 0 && !sellableItem.Nothing_shipped_license_only__c){
            errorStatus = 'Please enter at least 1 Bill of Material.';
            error=true;
        }
        
       
     /*   if(sellableItem.Shippable_Item_Pre_requisites__c && sellableItem.Number_of_Prerequisites__c == 0){
            if(errorStatus!=null)
             errorStatus += 'Please enter at least 1 Prerequisites';
            else
              errorStatus = 'Please enter at least 1 Prerequisites';  
            error=true;
        }*/
        List<Product_Relationship__c> productRelationShips = [SELECT id FROM Product_Relationship__c WHERE Successors__c =: sellableItem.id LIMIT 1];
        if(sellableItem.Entitlement__c  <> 'New Sellable Item' && productRelationShips.isEmpty()){
            if(errorStatus!=null)
                errorStatus += 'Please enter at least 1 Predecessors.';
            else
               errorStatus = 'Please enter at least 1 Predecessors.';
            error=true;
        }
        if(error)
            return;        
        
        if(sellableItem.Type__c == MDMUtil.SELLABLE_TYPE_CLOUD  || sellableItem.Type__c == MDMUtil.SELLABLE_TYPE_PS){
            sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SELLABLE_ITEM_READY;       
        }
        else{
            sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SI_ATTRIBUTES_FROZEN;
        }
        update sellableItem;     
        errorStatus = 'OK';   
    }
    
    public void pricingComplete(){
        System.debug('NKC debug sellableItem.Status__c ['+sellableItem.Status__c+']');
        if(sellableItem.Type__c == MDMUtil.SELLABLE_TYPE_GU || sellableItem.Type__c == MDMUtil.SELLABLE_TYPE_CARE || sellableItem.Type__c == MDMUtil.SELLABLE_TYPE_Product ){
            sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SELLABLE_ITEM_READY;       
        }
        else{       
            sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_PRICING_FROZEN;
        }
        System.debug('NKC debug sellableItem.Status__c ['+sellableItem.Status__c+']');
        update sellableItem;
    }
    
    public void validateAndApprove(){
        sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SELLABLE_ITEM_READY;
        update sellableItem;
    }
    
    public void submitToSAP(){
        sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SUBMITTED_TO_SAP;
        update sellableItem;
    }
    
    public void FinanceReview(){
        sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_Submitted_to_Finance;
        update sellableItem;
    }

    public void decline(){
        sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_TO_BE_UPDATED;
        sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS;
        update sellableItem;
    }
    
    public void Tax()
    {
        sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_Submitted_to_Tax;
        //sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS;
        update sellableItem;
    }
    /* 
    public void SAPProfileComplete(){
        sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SAP_PROFILE_COMPLETE;
        update sellableItem;
    }
    */
    public void activateAndRelease(){
        sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SAP_PROFILE_COMPLETE; //flow change //commented on 28th Feb 2018
        
        //sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_SUBMITTED_TO_SAP ;
        sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_ACTIVE;
        update sellableItem;
    }   
    
    public void updateSellableItem(){
        sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_TO_BE_UPDATED;
        sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_BOM_UPDATE;
        update sellableItem;
    }
    
    public void EOL(){
        sellableItem.Status__c = MDMUtil.SELLABLE_STATUS_RETIRED;
        sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_EOL;
        update sellableItem;
    }
    
    public void ERPHold(){
        sellableItem.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_ERP_HOLD;
        update sellableItem;
    }
    
    public void deleteRecord(){
        delete sellableItem;        
    }
    
    public void cloneRecord(){
        clonedSellableItemId = MDMUtil.cloneSellableItem(sellableItemId);       
    }
    
    private void populateCurrentUserGroupInfo(){
        isPricingManagement = false;
        isProductManagement = false;
        isProjectManagement = false;
        isSoftwareDelivery = false;
        isFinance = false;
        Set<String> currentUserGroup = MDMUtil.getCurrentUserGroup();
        if(currentUserGroup.contains(MDMUtil.GROUP_MML_PRICING_MANAGEMENT))
            isPricingManagement = true;
        if(currentUserGroup.contains(MDMUtil.GROUP_MML_PRODUCT_MANAGEMENT))
            isProductManagement = true;
        if(currentUserGroup.contains(MDMUtil.GROUP_MML_PROJECT_MANAGEMENT))
            isProjectManagement = true;
        if(currentUserGroup.contains(MDMUtil.GROUP_MML_SOFTWARE_DELIVERY))
            isSoftwareDelivery = true;
        if(currentUserGroup.contains(MDMUtil.GROUP_MML_Finance_Management))
            isFinance = true;   
        if(currentUserGroup.contains(MDMUtil.GROUP_MML_Tax_Management))
            isTax = true;   
    }
}