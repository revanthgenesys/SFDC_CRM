//Created by: swastika Rajkhowa
Global Class OrderClone{
    Webservice Static string OrderCloneClass(Id OrderId){
            Try{            
            //Find old order 
            Order__c oldOrder=new Order__c();           
            String soql = getCreatableFieldsSOQL('Order__c','Id=\''+OrderId+'\'');
            oldOrder= (Order__c)Database.query(soql);
            
            
            
            /* check all cloned order of Original Parent Order*/
            List<Order__c>list_ChildOrder = new List<Order__c>();
            
            //if(oldOrder.Original_Parent_Order1__c != null)
              list_ChildOrder = [Select id,Original_Parent_Order1__c,Original_Parent_Order1__r.name from Order__c where Original_Parent_Order1__c =: oldOrder.id];
            
            /*Cloning of old Order*/
            Order__c newOrder  = oldOrder.clone(false, true);
            newOrder.Status__c ='Order Submitted';
            if(oldOrder.Original_Parent_Order1__c == null)
            {  
               system.debug('+++oldOrder.Original_Parent_Order1__c+++'+oldOrder.Original_Parent_Order1__c);  
               newOrder.Original_Parent_Order1__c = oldOrder.id;
               newOrder.name = oldOrder.name + '-CO-' + (list_ChildOrder.size()+1) ;
            }
            else
            {
              system.debug('+++oldOrder.Original_Parent_Order1__c else+++'+oldOrder.Original_Parent_Order1__c); 
              newOrder.Original_Parent_Order1__c = oldOrder.Original_Parent_Order1__c;
              newOrder.name = oldOrder.name + '-CO-' + (list_ChildOrder.size()+1);
            }                 
            newOrder.Date_Submitted__c = system.today();
            newOrder.Date_Re_Submitted__c = null;
            newOrder.Date_Rejected__c = null;
            newOrder.Date_Accepted__c = null;
            newOrder.Invoice_Number__c = null;
            newOrder.Order_Number__c = null;
            newOrder.Invoiced__c = false;
            newOrder.Net_Suite_Order__c = null;
            newOrder.Invoice_Date__c = null;
            newOrder.Order_Date__c = null;
            newOrder.Siebel_ID__c = null;
            insert newOrder;
            
            system.debug('+++1+++');
            
            //Update the old Order by status=Cancelled
            //If(oldOrder.Status__c!='Cancelled'){
            //oldOrder.Status__c='Cancelled';
            //Update oldOrder;
            //}      
            system.debug('+++2+++'+oldOrder);      
            //Find All Line items, create line items and map with the new order   
            String soqlLineItem = getCreatableFieldsSOQL('Order_Line_Item__c','Order__c=\''+OrderId+'\'');  
             List<Order_Line_Item__c> LineItems= (List<Order_Line_Item__c>)Database.query(soqlLineItem );  
           
            
            
            List<Order_Line_Item__c>list_OrderLinItm = new List<Order_Line_Item__c>();
            if(LineItems!=null && !LineItems.isEmpty()) {
            for(Order_Line_Item__c record: LineItems) {
                Order_Line_Item__c objLineItem = new Order_Line_Item__c();
                objLineItem= record.clone(false,true,false,true); 
                objLineItem.Order__c=newOrder.Id;  
                list_OrderLinItm.add(objLineItem);             
                                         
             }
             insert list_OrderLinItm;
         }       
         
         system.debug('+++3+++');        
         //Find all service contract and mark them as Declined and create new service contract for new order          
           String soqlService = getCreatableFieldsSOQL('ServiceContract','Order__c=\''+OrderId+'\'');  
             List<ServiceContract> SerConts= (List<ServiceContract>)Database.query(soqlService ); 
          
           system.debug('+++4+++'); 
          List<ServiceContract>list_NewSC = new List<ServiceContract>();
          if(SerConts!=null && !SerConts.isEmpty()) 
          {
              for(ServiceContract record: SerConts) 
              {
               //record.Agreement_Status__c ='Declined';
               ServiceContract objServiceCont = new ServiceContract(); 
               objServiceCont= record.clone(false,true,false,true);
               objServiceCont.Order__c=newOrder.Id;
               objServiceCont.Agreement_Status__c='Active';
               
               //Add in List
               //list_NewSC.add(objServiceCont);               
               //insert objServiceCont;
              }
              
              //Insert SC List
              //insert list_NewSC;
              //update  SerConts;             
          } 
           system.debug('+++5+++'); 
          
           String soqlOrd_Addr = getCreatableFieldsSOQL('Account_Order_Address__c','Order__c=\''+OrderId+'\'');     
           List<Account_Order_Address__c> ord_addr = (List<Account_Order_Address__c>)Database.query(soqlOrd_Addr );  
                       
            
            List<Account_Order_Address__c>list_ord_addr = new List<Account_Order_Address__c>();
            if(ord_addr!=null && !ord_addr.isEmpty()) {
            for(Account_Order_Address__c record: ord_addr) {
                Account_Order_Address__c objordaddr = new Account_Order_Address__c();
                objordaddr= record.clone(false,true,false,true); 
                objordaddr.Order__c=newOrder.Id;  
                list_ord_addr.add(objordaddr);             
                                         
             }
             insert list_ord_addr;
                
            String soqlOrd_Att = getCreatableFieldsSOQL('Attachment','Parentid=\''+OrderId+'\'');     
            List<Attachment> ord_Att = (List<Attachment>)Database.query(soqlOrd_Att);  
                       
            
            List<Attachment>list_ord_Att = new List<Attachment>();
            if(ord_Att!=null && !ord_Att.isEmpty()) {
            for(Attachment record: ord_Att) {
                Attachment objordAtt = new Attachment();
                objordAtt= record.clone(false,true,false,true); 
                objordAtt.Parentid=newOrder.Id;  
                list_ord_Att.add(objordAtt);             
                                         
             }
             insert list_ord_Att;   
         }            
            
                
             String soqlOrd_Note = getCreatableFieldsSOQL('Note','Parentid=\''+OrderId+'\'');     
            List<Note> ord_Note = (List<Note>)Database.query(soqlOrd_Note);  
                       
            
            List<Note>list_ord_Note = new List<Note>();
            if(ord_Note!=null && !ord_Note.isEmpty()) {
            for(Note record: ord_Note) {
                Note objordNote = new Note();
                objordNote= record.clone(false,true,false,true); 
                objordNote.Parentid=newOrder.Id;  
                list_ord_Note.add(objordNote);             
                                         
             }
             insert list_ord_Note;   
         }            
            
            }    
                
          return newOrder.Id;          
        
            }       
    catch(DmlException e) { 
        System.debug('The following exception has occurred: ' + e.getMessage());   
        return null;     
        }    
    catch (Exception e) {
        System.debug('The following exception has occurred: ' + e.getMessage()); 
        return null;          
        }      
            }
    //Added by Swastika on 26-oct-2015
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){         
        String selects = '';         
        if (whereClause == null || whereClause == ''){ return null; }         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}             
        }         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;         
    } 
    
}