public without sharing class OrderLineItemController {
    
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
    //Added by navaneetha for PPU Product added.
    public String getproductAPNumber{get;set{orderLineItem.product__c = value;}}  
    public List<SelectOption> PPUNames { get; set; }
    PPUEnhancement__c ppuc = new PPUEnhancement__c();
    
    public OrderLineItemController(ApexPages.StandardController controller){   
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
        if(!currentOrder.isEmpty()){
            if(currentOrder[0].NRO_Type__c == 'Entitlement Adjustment')
                isEntitlementAdj = true; 
            isTechSprt = (currentOrder[0].NRO_Type__c == 'Customer Care') ? true : false;    
        }
        if(olId != null && pg=='view') {
            System.debug('>>> start ');    
            saveNewFlag = false;        
            orderLineItem = [select id,Memo__c, Name,list_price__c, APN_Number__c,Material_Number__c,Quantity__c,BigMachines_Quantity__c, Product__c ,Product__r.name,Product__r.Product_Manager_Approval_Group__c ,PM_Approval_Required_Product__c,Material_Description__c, Order__c, Sales_Price__c,Maintenance_Start_Date__c,Maintenance_End_Date__c, Sales_Order__c, Original_PO__c, Sold_To_Name__c, End_User_Name__c, Lic_Invoice__c, Original_License_Invoice_Date__c, Original_Qty__c, Current_Qty__c, Annualized_Maintenance_Due__c,
            Original_Net_License_Value__c, Revised_Net_License_Value__c, Comment__c, CD_Name__c, isVersionUntested__c, Support_Product__c, Order__r.NRO_Type__c, Description__c, Product_Version1__c, Operating_System__c, Language_lk__c,Maintenance_No_of_Months__c  from Order_Line_Item__c where id = :olId ];
        } else if(ordId !=null && pg=='new'){
            saveNewFlag = true;
            ord = [Select Maintenance_Start__c, Maintenance_End__c, RecordType.DeveloperName, Sold_To_Name__r.Name, End_User_Name__r.Name  From Order__c where id=:ordId ]; 
        if(ord.RecordType.DeveloperName == 'PPU_Order'){
                showFixedProduct = true;
              /* Commented by navaneetha
              List<Product2> product = [SELECT id FROM Product2 WHERE Name = '3GP08402ADAA'];
              if(!product.isEmpty())
              orderLineItem.Product__c = product[0].id;   
            */
            
            //Added by navaneetha for PPU Product added.                  
               //  ppuc  = [Select POB_Type__c from PPUEnhancement__c where ProductID__c =: orderLineItem.Product__c] ;
                // orderLineItem.POB_Type__c = ppuc.POB_Type__c;
                   // system.debug('TestNAvanee' +  orderLineItem.Product__c);
                //     system.debug('TestNAvanee2' +  orderLineItem.POB_Type__c);     
                 //    system.debug('TestNAvanee21' +  ppuc.POB_Type__c);       
            }
            else if ( isTechSprt ) {
            
                techSupNroType = 'IP';  
                
                /// product Customer Care NRO item  
                List<Product2> product = [SELECT id FROM Product2 WHERE APN_Number__c = '3GP21457TBAA'];
                if(!product.isEmpty())
                    orderLineItem.Product__c = product[0].id;  
                    
               ///preset language ENU
               List<Language__c> lng = [SELECT Id FROM Language__c WHERE Name = 'English (United States)'];
               if ( !lng.isEmpty() )
                   orderLineItem.Language_lk__c = lng[0].Id; 
            }
            orderLineItem.Order__c = ordId;
            orderLineItem.Name = determineOrderLineItemNameValue();
            orderLineItem.Maintenance_Start_Date__c = ord.Maintenance_Start__c;
            orderLineItem.Maintenance_End_Date__c = ord.Maintenance_End__c;
            orderLineItem.Sales_Price__c = 0;
            orderLineItem.Sold_To_Name__c = ord.Sold_To_Name__r.Name;
            orderLineItem.End_User_Name__c= ord.End_User_Name__r.Name;
            orderLineItem.Lic_Invoice__c = 'INV-NRO-E-' + String.valueOf(System.Date.today()).replace('-','');
            
        }
        else if(ordId !=null && pg=='edit'){
            saveNewFlag = false;
            orderLineItem = [select id,Memo__c, Name,list_price__c,APN_Number__c,Material_Number__c, Quantity__c,BigMachines_Quantity__c,Maintenance_Start_Date__c,Maintenance_End_Date__c, Product__c ,Product__r.Product_Manager_Approval_Group__c,Product__r.name, PM_Approval_Required_Product__c,Material_Description__c, Order__c, Sales_Price__c, Sales_Order__c, Original_PO__c, Sold_To_Name__c, End_User_Name__c, Lic_Invoice__c, Original_License_Invoice_Date__c, Original_Qty__c, Current_Qty__c, Annualized_Maintenance_Due__c,
            Original_Net_License_Value__c, Revised_Net_License_Value__c, Comment__c, CD_Name__c, isVersionUntested__c, Support_Product__c, Order__r.NRO_Type__c, Description__c, Product_Version1__c, Operating_System__c, Language_lk__c,Maintenance_No_of_Months__c   
                            from Order_Line_Item__c where id = :olId ];
            if ( isTechSprt ) {            
                  if ( orderLineItem.CD_Name__c != null )
                      techSupNroType = 'CD';
                  else
                      techSupNroType = 'IP';
                         
                  getVersions();
            }
        }
        getPPUNames();
    }
    
    public void getVersions() {       
       Id spId;
       if ( techSupNroType != null && techSupNroType == 'IP' )
           spId = orderLineItem.Support_Product__c;
       else
           spId = orderLineItem.CD_Name__c;

       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('', ''));
           
       if ( spId != null ) {
           List<Product_Version__c> vers = [SELECT  Version__c 
                                            FROM Product_Version__c 
                                            WHERE Parent_Product__c = :spId 
                                            AND Version__c != 'Unspecified' AND Customer_Available__c = true 
                                            ORDER BY Version__c DESC LIMIT 999];

           for ( Product_Version__c ver : vers ) {
                options.add(new SelectOption(ver.Version__c, ver.Version__c));
           }
           
       }
       versions = options;
    }
    
    public String determineOrderLineItemNameValue() {
        String returnValue = '';
        Integer counter  = [select count() from Order_Line_Item__c where Order__c = :ordId ] ;
        List<Order_Line_Item__c> nameList = [select Name from Order_Line_Item__c where Order__c = :ordId order by Name asc];
        String maxNameVal = '';
        /*for (Order_Line_Item__c oli: nameList) {
            maxNameVal = oli.Name;
            break;
        }*/
       
     /* MS - commented out, when more than 10 lines this code doesn't work
        Integer nameIntValue = 0;
        if(nameList.size()>0){
            maxNameVal = nameList.get(nameList.size()-1).Name;  
            nameIntValue = Integer.valueOf(maxNameVal);
            if (counter == nameIntValue) {
                returnValue = String.valueof(counter+1);
            } else {
                returnValue = String.valueof(nameIntValue+1);
            }
        }else{
            returnValue = String.valueof(counter+1);
        }
      */  
        returnValue = String.valueof(counter+1);
        
        return returnValue;
    }
    
    public PageReference editFn(){
        PageReference pg = new PageReference('/apex/OrderLineItemEdit?retURL='+ordId +'&pg=edit'+'&Olid='+olId+'&Oid='+ordId);
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference saveFn(){
        system.debug('orderLineItem.product__c' + orderLineItem.product__c);
        
        Product2 prod = [select APN_Number__c, Product_Manager_Approval_Group__c,Approval_Required__c, Shipment_Approval__c,
          Notification_Message__c, Description, Name, EOL_Announced_Date__c  from product2 where id=: orderLineItem.product__c];
        if(!showConfirmPanel && showConfirmBox(prod)){
          return null;
        }
        if(prod!=null)
        orderLineItem.APN_Number__c = prod.APN_Number__c;
        List<pricebookentry> pbe = new List<pricebookentry>();
        Order__c ord1  = new Order__c();
        String priceBookId = Global_Setting__c.getInstance('NRO_PriceBookId').Id__c;
        orderLineItem.Ext_List__c = orderLineItem.List_Price__c;
        orderLineItem.Net_Unit_Price__c = orderLineItem.List_Price__c;
        orderLineItem.Ext_Net_Price__c = orderLineItem.List_Price__c;
        orderLineItem.Sales_Price__c = orderLineItem.List_Price__c;
        
        if ( (isTechSprt != null && isTechSprt == true) ) {
               setCustomerCareDescription();                    
        }
        //Added by navaneetha
         ord1 = [Select  RecordType.DeveloperName From Order__c where id=:ordId ];
         if(ord1.RecordType.DeveloperName == 'PPU_Order'){
             ppuc  = [Select POB_Type__c from PPUEnhancement__c where ProductID__c =: orderLineItem.product__c] ;
             orderLineItem.POB_Type__c = ppuc.POB_Type__c;
             system.debug('TestNAvanee21' +  ppuc.POB_Type__c); 
             orderLineItem.POB_Type__c = ppuc.POB_Type__c;
         }
        //Ends
        pbe = [select unitprice from pricebookentry where pricebook2id = :priceBookId  and product2id=: orderLineItem.product__c and currencyisocode='USD'];
        if(pbe.size()>0 && pbe !=null)
          orderLineItem.list_price__c = pbe[0].unitprice ;
        if(confirmSelected){
          orderLineItem.PM_Confirmation__c = true;
          orderLineItem.Acknowledge_Text__c = prod.Notification_Message__c;
          if(prod.EOL_Announced_Date__c != NULL && prod.EOL_Announced_Date__c < System.today()){
            orderLineItem.Acknowledge_Text__c = Label.Product_EOL_Msg;
          }
        }
        
        upsert orderLineItem;
        if(prod.Product_Manager_Approval_Group__c != null){
          OrderUtil.updateOrderStatus(ordId,orderLineItem.id);
        }
        PageReference pg = new PageReference('/'+ordId);
        return pg;
    }
    
     public void setCustomerCareDescription() {   
         ID spId;
         if ( techSupNroType == 'IP' && orderLineItem.Support_Product__c != null )  { 
                spId = orderLineItem.Support_Product__c;
                 orderLineItem.CD_Name__c = null; 
          }
          else if ( techSupNroType == 'CD' && orderLineItem.CD_Name__c != null )  { 
                spId = orderLineItem.CD_Name__c;
                orderLineItem.Support_Product__c = null;
          }  
          
          if ( spId != null )  {  
              List<Support_Product__c> prodName = [SELECT Name FROM Support_Product__c WHERE Id = :spId];  
                   
              if ( !prodName.isEmpty() )
                   orderLineItem.Description__c = '[' + techSupNroType + ']  ' + prodName[0].Name;  
          }               
    }
    
    public PageReference saveNewFn(){
      isSaveAndNew = true;
      system.debug('orderLineItem.product__c' + orderLineItem.product__c);
        Product2 prod = [select APN_Number__c, Product_Manager_Approval_Group__c,Approval_Required__c, Shipment_Approval__c,
          Notification_Message__c, Description, Name, EOL_Announced_Date__c  from product2 where id=: orderLineItem.product__c];
        List<pricebookentry> pbe = new List<pricebookentry>();
        if(!showConfirmPanel && showConfirmBox(prod)){
          return null;
        } 
        if(prod!=null)
        orderLineItem.APN_Number__c = prod.APN_Number__c;
        String priceBookId = Global_Setting__c.getInstance('NRO_PriceBookId').Id__c;

        pbe = [ select unitprice from pricebookentry where pricebook2id =:priceBookId and product2id =: orderLineItem.product__c and currencyisocode='USD'];
        
        if(pbe.size()>0 && pbe !=null)
        orderLineItem.list_price__c = pbe[0].unitprice ;
        if(confirmSelected){
          orderLineItem.PM_Confirmation__c = true;
          orderLineItem.Acknowledge_Text__c = prod.Notification_Message__c;
          if(prod.EOL_Announced_Date__c != NULL && prod.EOL_Announced_Date__c < System.today()){
            orderLineItem.Acknowledge_Text__c = Label.Product_EOL_Msg;
          }
        }
        upsert orderLineItem;
        if(prod.Product_Manager_Approval_Group__c != null){
          OrderUtil.updateOrderStatus(ordId,orderLineItem.id);
        }
        
        PageReference pg = new PageReference('/apex/orderlineitemEdit?retUrl='+ordId+'&Oid='+ordId+'&pg=new');
        pg.setRedirect(true);
        return pg;
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
    //Added by navaneetha for PPU Product picklist getting values from custom settings.
    public void confBoxCancel(){
      showConfirmPanel = false;
    }
    
     public void getPPUNames() {
        PPUNames = new List<SelectOption>();
        
        List<PPUEnhancement__c> allPPU = new List<PPUEnhancement__c>();
        
        allPPU = [SELECT  Name,APNNumber__c,ProductID__c,ProductName__c,POB_Type__c  FROM    PPUEnhancement__c ];
        
        for( PPUEnhancement__c PPUvalues : allPPU ) {
            PPUNames.add( new SelectOption( PPUvalues.ProductID__c, PPUvalues.ProductName__c ) );
           // System.debug('navaneevalues:'+ PPUNames);
        }
    } 

}