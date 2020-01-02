/*
    Naresh Kumar    07/15/2012
*/
global class Update_Order_WS {
    webservice static String updateOrderStatus(String orderId, String status,string accId, integer lnCnt,string Ship_software, string profile){
        string region='';
                
        List<Product2> prodsWithAppRequired = [SELECT id,name,Product_Manager_Approval_Group__r.Id FROM Product2 
        	WHERE Shipment_Approval__c =: DealQualificationApprovalUtil.HIGHLY_TECHNICAL_SALE AND
            id IN (SELECT Product__c FROM Order_Line_Item__c WHERE Order__c =: orderId AND Order__r.Approved_By_Manager__c = false)];
        
        if(lnCnt==0){
            return 'Order cannot be submitted without a line item' ; 
        }
        
        List<Order__c> ppuOrder = [SELECT id FROM Order__c WHERE id =: orderId AND RecordType.DeveloperName =: OrderUtil.PPU_ORDER];
        if(!ppuOrder.isEmpty()){
	        List<Attachment> orderAtts = [SELECT id FROM Attachment WHERE parentId =: orderId];
	        if(orderAtts.isEmpty())
	        	return 'Please attach PO and/or usage report to the order.';
        }
       
        if(prodsWithAppRequired.isEmpty() 
        //|| ( !prodsWithAppRequired.isEmpty() && (profile =='System Administrator' || profile =='GEN - Finance'))
         ){
                    
            List<Account> acnt = [ select id, TM_Acc_Country_Region__c from Account where id=:accId] ;
             if(acnt.size()>0){          
                 if(acnt[0].TM_Acc_Country_Region__c != null) {       
                     region =    acnt[0].TM_Acc_Country_Region__c;                
                 }   
              }
              
             Order__c currentOrder = new Order__c(id = orderId, Status__c = status);
             Global_Setting__c obj;
             
             if(Ship_software != null && !Ship_software.contains('No Shipment Required')){
                 if(region == 'North America')  obj = Global_Setting__c.getInstance('NA Order Queue');
                 if(region=='EMEA' )            obj = Global_Setting__c.getInstance('EMEA Order Queue');
                 if(region=='LATAM')            obj = Global_Setting__c.getInstance('LATAM Order Queue');
                 if(region=='APAC')             obj = Global_Setting__c.getInstance('APAC Order Queue');
                 if(region=='Japan' || region=='JAPAN') obj = Global_Setting__c.getInstance('Japan Order Queue');
             }
             else if(Ship_software != null && Ship_software.contains('No Shipment Required')){
                // if(region == 'North America')
                   obj = Global_Setting__c.getInstance('Maintenance Management Group');
             /*    if(region=='EMEA' )            obj = Global_Setting__c.getInstance('EMEA Maintenance Management Group');
                 if(region=='LATAM')            obj = Global_Setting__c.getInstance('LATAM Maintenance Management Group');
                 if(region=='APAC')             obj = Global_Setting__c.getInstance('APAC Maintenance Management Group');
                 if(region=='Japan' || region=='JAPAN') obj = Global_Setting__c.getInstance('Japan Maintenance Management Group'); */
             }
                         
             if(obj == null){
                 obj = Global_Setting__c.getInstance('Order Queue');
             }
             if(obj != null){
                User currUser = new User();
                Order__c currOrder = [Select Id,Name,CreatedByID from Order__c where Id=:currentOrder.id];
                currUser = [Select id,Email from User where id=:currOrder.createdById];
                currentOrder.OwnerId = obj.ID__c;
                currentOrder.Date_Submitted__c = System.now();
                currentOrder.Rep_Email__c = currUser.Email;
             }           
            try{
             update currentOrder;
             
            }catch (Exception e){
                return 'Cannot Edit/Submit an Order That is already Submitted' ;
            }
            DealQualificationAndQuoteApprovalHelper.sendNROPMApprovalNotifications(orderId);
            return 'OK'; 
       /*     if(!prodsWithAppRequired.isEmpty()){   //email being sent as OrderLineItem is Created.
                buildAndSendApprovalRequiredEmail(prodsWithAppRequired, currentOrder.Id);
                return 'OK';
            } */
                 
        }
        else{
            return 'Please Attach your approvals and check the box before you submit the order';
        }
    }
    
    public static void buildAndSendApprovalRequiredEmail(List<Product2> prodsWithAppRequired, Id orderId){
        String addresses='';
        String ccAddresses = '';
        String products='<br><br><b><u>Parts Information:</b></u>';
        Map <id, Order_Line_Item__c> orderLnItemMap ;
        Map <id, Product2> productMap = new Map <id, Product2>();
        
        for(Product2 prod: prodsWithAppRequired){
            if(!productMap.containsKey(prod.id)){
                productMap.put(prod.id, prod);
            }           
        }
        String orgURL = URL.getSalesforceBaseUrl().toExternalForm();
        Order__c currentOrder = [Select Name, Sold_To_Name__r.Name, Region__c, End_User_Name__r.Name, CreatedBy.Email, CreatedBy.Name, CreatedById From Order__c where id = :orderId];
        orderLnItemMap = new Map<id, Order_Line_Item__c> ([select id, Product__c,Product__r.Description,APN_Number__c, Name, BigMachines_Quantity__c from Order_Line_Item__c where order__c =: currentOrder.Id ]);
         ccAddresses = currentOrder.CreatedBy.Email;
         System.debug('CC ADDRESSES>>>>>>>>>' +  ccAddresses + '>>>>>>>>>>' + currentOrder.CreatedBy.Email);
         String orderInfo = '<br><br><b><u>Order Information:</b></u><br>';
         orderInfo += '<br>Order Name: <a href="' + orgURL + '/' + currentOrder.id + '">' +  currentOrder.Name + '<a/>';
         orderInfo += '<br>Order Requestor: ' +  currentOrder.CreatedBy.Name ;
         orderInfo += '<br>Order Requestor’s Email: <a href="mailto:' +  currentOrder.CreatedBy.Email + '">' + currentOrder.CreatedBy.Email + '</a>';
         orderInfo += '<br>Sold To Customer  : ' +  currentOrder.Sold_To_Name__r.Name; 
         orderInfo += '<br>End User Customer  : ' +  currentOrder.End_User_Name__r.Name;
         orderInfo += '<br>Region: ' +  currentOrder.Region__c;
         
         for(Order_Line_Item__c orderLnItem : orderLnItemMap.values()){
            if(productMap.containsKey(orderLnItem.Product__c)){
                products += '<br><br>Line Item: '+ orderLnItem.Name;
                products += '<br>Part Number: '+ orderLnItem.APN_Number__c ;
                products += '<br>Part Description: '+ orderLnItem.Product__r.Description;
                products += '<br>Line Item Quantity: '+ orderLnItem.BigMachines_Quantity__c;                
            }
         }
         
        List<Id> productManagerApprovalGroupIdList = new List<Id>();        
        for(Product2 product: prodsWithAppRequired ){
            productManagerApprovalGroupIdList.add(product.Product_Manager_Approval_Group__r.Id);
        }
    
        List<Product_Manager_Approval_Group__c> productManagerEmailAddressesList = [select Product_Manager_Email_Addresses__c from Product_Manager_Approval_Group__c where id IN : productManagerApprovalGroupIdList];
        if(productManagerEmailAddressesList.size()>0){
            for(Product_Manager_Approval_Group__c productManagerEmailAddress: productManagerEmailAddressesList ) {
                if(addresses !='') {
                    addresses = addresses + ';' + productManagerEmailAddress.Product_Manager_Email_Addresses__c;
                } else {
                    addresses = productManagerEmailAddress.Product_Manager_Email_Addresses__c ;
                }
           }
            String subject = 'Approval Required For Products';
            String body = 'Dear User, <br><br>This Non Revenue Order requires your approval since it includes a product/s indicated for PM approval' + orderInfo + products;
            body += '<br><br>Please reply on this email to the Account Executive with your approval.';
            body += '<br><br><font color="red">Note to Account Executive: Attach the approval email to your Order and check the PM approval checkbox on the header.</font>';
            body += '<br><br> Thank You.';
            NotifyApprovalRequiredViaEmail(addresses, ccAddresses, subject, body);
        }
    }
    
    public static void NotifyApprovalRequiredViaEmail(String addresses, String ccAddresses, String subject, String body) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setSubject( subject );
        email.setToAddresses( addresses.split(';',0) );
        email.setCcAddresses(ccAddresses.split(';', 0));
        email.setHtmlBody( body );
        Messaging.SendEmailResult [] r = 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
    }    
    
}