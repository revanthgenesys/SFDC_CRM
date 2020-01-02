public with sharing class AppFoundryOLIController {
	public Order_Line_Item__c orderLineItem {get; set;}
    public Id ordId;
    public Id olId;
    public Boolean saveNewFlag {get; set;}
    public Boolean showFixedProduct {get;set;}
    public String pg {get;set;}
    public Boolean isEntitlementAdj {get;set;} 
    public Boolean isTechSprt{get;set;} 
    public String techSupNroType{get;set;}
    public List<SelectOption> versions{get; set;}
    public Boolean showConfirmPanel {get;set;}
    public Boolean confirmSelected {get;set;}
    public Product2 productToConfirm {get;set;}
    public Boolean isSaveAndNew {get;set;}
    
    public List<SelectOption> apProductNames {get;set;}
    public String prdName {get;set;}
    
    public AppFoundryOLIController(ApexPages.StandardController controller){ 
    	apProductNames = new List<SelectOption>();  
    	ordId = ApexPages.currentPage().getParameters().get('Oid');
        olId = ApexPages.currentPage().getParameters().get('Olid');
        String pg = ApexPages.currentPage().getParameters().get('pg');
        orderLineItem =  new Order_Line_Item__c();
        orderLineItem.BigMachines_Quantity__c = 1;
        Order__c ord = new Order__c();
        showFixedProduct = false;
        isEntitlementAdj = false;
        isSaveAndNew = false;
        showConfirmPanel = false;
        confirmSelected = false;
        List<Order__c> currentOrder = [SELECT NRO_Type__c FROM Order__c WHERE id =: ordId];
        if(olId != null && pg=='view') {
            System.debug('>>> start ');    
            saveNewFlag = false;        
            orderLineItem = [select id,Memo__c, Name,list_price__c, APN_Number__c,Material_Number__c,Quantity__c,BigMachines_Quantity__c, Product__c ,Product__r.name,Product__r.Product_Manager_Approval_Group__c ,PM_Approval_Required_Product__c,Material_Description__c, Order__c, Sales_Price__c,Maintenance_Start_Date__c,Maintenance_End_Date__c, Sales_Order__c, Original_PO__c, Sold_To_Name__c, End_User_Name__c, Lic_Invoice__c, Original_License_Invoice_Date__c, Original_Qty__c, Current_Qty__c, Annualized_Maintenance_Due__c,
            Original_Net_License_Value__c, Revised_Net_License_Value__c, Comment__c, CD_Name__c, isVersionUntested__c, Support_Product__c, Order__r.NRO_Type__c, Description__c, Product_Version1__c, Operating_System__c, Language_lk__c from Order_Line_Item__c where id = :olId ];
        } else if(ordId !=null && pg=='new'){
            saveNewFlag = true;
			List<AppFoundryProductDetails__c> afPrdNameList  = AppFoundryProductDetails__c.getall().values();
			for(AppFoundryProductDetails__c prdName : afPrdNameList) {
					
				apProductNames.add(new SelectOption(prdName.Product_Id__c,prdName.Name)); 
			}           
            orderLineItem.Order__c = ordId;
            orderLineItem.Name = determineOrderLineItemNameValue();
            orderLineItem.Maintenance_Start_Date__c = ord.Maintenance_Start__c;
            orderLineItem.Maintenance_End_Date__c = ord.Maintenance_End__c;
            orderLineItem.Sales_Price__c = 0;
            orderLineItem.Sold_To_Name__c = ord.Sold_To_Name__r.Name;
            orderLineItem.End_User_Name__c= ord.End_User_Name__r.Name;
            orderLineItem.Lic_Invoice__c = 'INV-NRO-E-' + String.valueOf(System.Date.today()).replace('-','');
        } else if(ordId !=null && pg=='edit'){
            saveNewFlag = false;
            orderLineItem = [select id,Memo__c, Name,list_price__c,APN_Number__c,Material_Number__c, Quantity__c,BigMachines_Quantity__c,Maintenance_Start_Date__c,Maintenance_End_Date__c, Product__c ,Product__r.Product_Manager_Approval_Group__c,Product__r.name, PM_Approval_Required_Product__c,Material_Description__c, Order__c, Sales_Price__c, Sales_Order__c, Original_PO__c, Sold_To_Name__c, End_User_Name__c, Lic_Invoice__c, Original_License_Invoice_Date__c, Original_Qty__c, Current_Qty__c, Annualized_Maintenance_Due__c,
            Original_Net_License_Value__c, Revised_Net_License_Value__c, Comment__c, CD_Name__c, isVersionUntested__c, Support_Product__c, Order__r.NRO_Type__c, Description__c, Product_Version1__c, Operating_System__c, Language_lk__c  
                            from Order_Line_Item__c where id = :olId ];
        	List<AppFoundryProductDetails__c> afPrdNameList  = AppFoundryProductDetails__c.getall().values();
			for(AppFoundryProductDetails__c prdInfo : afPrdNameList) {
					
				apProductNames.add(new SelectOption(prdInfo.Product_Id__c,prdInfo.Name)); 
				if(prdInfo.Product_Id__c == orderLineItem.Product__c) {
					System.debug('prdInfo.Name--->'+prdInfo.Name);
					prdName = prdInfo.Product_Id__c;
				}
			} 
        }
    }
    
    
    
    public String determineOrderLineItemNameValue() {
        String returnValue = '';
        Integer counter  = [select count() from Order_Line_Item__c where Order__c = :ordId ] ;
        List<Order_Line_Item__c> nameList = [select Name from Order_Line_Item__c where Order__c = :ordId order by Name asc];
        String maxNameVal = '';
        returnValue = String.valueof(counter+1);
        return returnValue;
    }
    
    public PageReference editFn(){
        PageReference pg = new PageReference('/apex/AppFoundryOrderLineItem?retURL='+ordId +'&pg=edit'+'&Olid='+olId+'&Oid='+ordId);
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference saveFn(){
    	List<Product2> prdList = [select Id,APN_Number__c from Product2 where Id =: prdName];
    	List<PricebookEntry> pbeList = [SELECT CurrencyIsoCode,Id,Pricebook2Id,UnitPrice FROM PricebookEntry WHERE Product2Id =: prdName AND Pricebook2.Name = 'Standard Price Book' AND CurrencyIsoCode = 'USD'];
    	
    	orderLineItem.Product__c = prdName;
    	orderLineItem.Pricebook_Entry_ID__c = pbeList[0].Id;
    	orderLineItem.APN_Number__c = prdList[0].APN_Number__c;
    	orderLineItem.Ext_List__c = orderLineItem.List_Price__c;
        orderLineItem.Net_Unit_Price__c = orderLineItem.List_Price__c;
        orderLineItem.Ext_Net_Price__c = orderLineItem.List_Price__c;
        orderLineItem.Sales_Price__c = orderLineItem.List_Price__c;
        upsert orderLineItem;
        PageReference pg = new PageReference('/'+ordId);
        return pg;
    }
    
     
    
    public PageReference saveNewFn(){
      isSaveAndNew = true;
        List<Product2> prdList = [select Id,APN_Number__c from Product2 where Id =: prdName];
    	List<PricebookEntry> pbeList = [SELECT CurrencyIsoCode,Id,Pricebook2Id,UnitPrice FROM PricebookEntry WHERE Product2Id =: prdName AND Pricebook2.Name = 'Standard Price Book' AND CurrencyIsoCode = 'USD'];
    	
    	orderLineItem.Product__c = prdName;
    	orderLineItem.Pricebook_Entry_ID__c = pbeList[0].Id;
    	orderLineItem.APN_Number__c = prdList[0].APN_Number__c;
    	orderLineItem.Ext_List__c = orderLineItem.List_Price__c;
        orderLineItem.Net_Unit_Price__c = orderLineItem.List_Price__c;
        orderLineItem.Ext_Net_Price__c = orderLineItem.List_Price__c;
        orderLineItem.Sales_Price__c = orderLineItem.List_Price__c;
        upsert orderLineItem;
       
        PageReference pgNew = new PageReference('/apex/AppFoundryOrderLineItem?retUrl='+ordId+'&Oid='+ordId+'&pg=new');
        pgNew.setRedirect(true);
        return pgNew;
    }
    
    public Boolean showConfirmBox(Product2 currentProduct){
      if(currentProduct.Shipment_Approval__c == Label.EOL_Value || currentProduct.Shipment_Approval__c == Label.Restrictions_Value ||
          currentProduct.Shipment_Approval__c == Label.Expansion_Only_Value  
            || (currentProduct.EOL_Announced_Date__c != NULL && currentProduct.EOL_Announced_Date__c < System.today())){
            System.debug('IN ');
          showConfirmPanel = true;           
          productToConfirm = currentProduct; 
          if((currentProduct.EOL_Announced_Date__c != NULL && currentProduct.EOL_Announced_Date__c < System.today())){
            productToConfirm.Notification_Message__c = Label.Product_EOL_Msg;
          }
          return true;  
        }      
        return false;
    }

    public PageReference backFn(){
        PageReference pg = new PageReference('/'+ordId);
        return pg;
    }
    
    public PageReference deleteFn(){
        delete orderLineItem;
        PageReference pg = new PageReference('/'+ordId);
        return pg;
    }
    
    public PageReference confBoxProceed(){
      if(!confirmSelected){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please acknowledge this message before you continue or you can click Cancel.'));
            return null;
        }
      if(isSaveAndNew)
        return saveNewFn();
      else
        return saveFn();
    }
    
    public void confBoxCancel(){
      showConfirmPanel = false;
    }
    

}