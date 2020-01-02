public class Order_Trigger_Class {

    Public Static void onAfterUpdate(Map<Id,Order__c> triggerOld, Map<Id,Order__c> triggerNew) {      
    // Inserting Account Address records when order status changed to Approved
    // Update Order Address records Sold To and End User field records when these field values are changed
    insertAcntAddressRecords(triggerOld,triggerNew);
    }    
   
   private static void insertAcntAddressRecords( Map<Id,Order__c> triggerOld , Map<Id,Order__c> triggerNew)
   {
    Set<Id> orderIds = new Set<id>();
    Set<Id> acntIds = new Set<id>();
    
    Set<String> acntAddrCompStrns = new Set<String>();
    List<Account_Order_Address__c> ordAdrList = new List<Account_Order_Address__c>();
    
    Map<Id,Boolean> orderAcntsFlagMap = new Map<Id,Boolean>();
    
    Set<Id> orderIds_soldto = new Set<Id>();
    Set<Id> orderIds_enduser = new Set<Id>();
    Set<String> ordAddressStrings = new Set<String>();
 
    Set<String> acntAddrCompStrns_diff = new Set<String>();
    
    Map<String,String> orderAddreCompStrnsMap = new Map<String,String>();
    
    List<Address__c> newacntAddrList = new List<Address__c>();
    List<Account_Order_Address__c> orderAdrUpdateSoldto_List = new  List<Account_Order_Address__c>();
    List<Account_Order_Address__c> orderAdrUpdateEndUser_List = new   List<Account_Order_Address__c>();
    
      for (Order__c eachorder : triggerNew.values()) 
      {
        if(eachorder.status__c == 'Approved' && eachorder.status__c != triggerOld.get(eachorder.id).Status__c)
        {    
            orderIds.add(eachorder.id);
            if(eachorder.End_User_Name__c == eachorder.Sold_To_Name__c)
            {
             orderAcntsFlagMap.put(eachorder.id,true);
             acntIds.add(eachorder.End_User_Name__c);
            }else if(eachorder.End_User_Name__c != eachorder.Sold_To_Name__c)
            {
             orderAcntsFlagMap.put(eachorder.id,false);
             acntIds.add(eachorder.End_User_Name__c);
             acntIds.add(eachorder.Sold_To_Name__c);    
            }
        }
            //Collect order id values when sold to and End user values are changed
            if(eachorder.Sold_To_Name__c != triggerOld.get(eachorder.id).Sold_To_Name__c )
            {   
                orderIds_soldto.add(eachorder.id);   
            }
            
            if(eachorder.End_User_Name__c != triggerOld.get(eachorder.id).End_User_Name__c)
            {
                orderIds_enduser.add(eachorder.id);                 
            } 
       }  
       

     // Add Strings of addresses if th e   
     if(acntIds.size() > 0)
     {
        for(Address__c eachAcntAddr : [Select Id,Type__c,Address_Line_1__c,Address_Line_2__c,City__c,State__c,Country__c FROM Address__c WHERE Account__c in :acntIds])
        {
            String eachSameStr = eachAcntAddr.Type__c+':'+eachAcntAddr.Address_Line_1__c+':'+eachAcntAddr.Address_Line_2__c+':'+eachAcntAddr.City__c+':'+eachAcntAddr.State__c+':'+eachAcntAddr.Country__c;
            acntAddrCompStrns.add(eachSameStr.toLowerCase());
         }
      }
     
     if(orderIds.size() > 0)
     { 
      ordAdrList = [Select Id,Company__c,Name,Address_Type__c,Order__r.End_User_Name__c,Order__r.End_User_Name__r.Name,Order__r.Sold_To_Name__c,Order__r.Sold_To_Name__r.Name,Order__r.Ship_To_Name__c,Order__r.Ship_To_Name__r.Name,Order__r.Bill_To_Name__c,Order__r.Bill_To_Name__r.Name,Address__c,Address2__c,City__c,State__c,Country__c,Zip_Code__c FROM Account_Order_Address__c WHERE Order__c in :orderIds];
     }

     for(Account_Order_Address__c eachOrdAddressStr : ordAdrList)
     {
        String ordAdrString_new = eachOrdAddressStr.Address__c+':'+eachOrdAddressStr.Address2__c+':'+eachOrdAddressStr.City__c+':'+eachOrdAddressStr.State__c+':'+eachOrdAddressStr.Country__c;        
        orderAddreCompStrnsMap.put(eachOrdAddressStr.Address_Type__c,ordAdrString_new.toLowerCase());
        ordAddressStrings.add(ordAdrString_new);  
     }  
     
     
     for (Order__c eachorder : triggerNew.values()) 
     {     
          if(orderAcntsFlagMap != null && orderAcntsFlagMap.size() > 0)
          {
          if(orderAcntsFlagMap.get(eachorder.id))
          {
             system.debug('----------------inside-----directorder----------------'+orderAcntsFlagMap.get(eachorder.id));
             // Direct Order 
             if(orderAddreCompStrnsMap.get('Sold To') == orderAddreCompStrnsMap.get('End User') && orderAddreCompStrnsMap.get('Sold To') == orderAddreCompStrnsMap.get('Bill To') && orderAddreCompStrnsMap.get('Sold To') == orderAddreCompStrnsMap.get('Ship To'))
             {
               orderAddreCompStrnsMap.remove('Bill To'); orderAddreCompStrnsMap.remove('Ship To'); orderAddreCompStrnsMap.remove('End User');
                
             } else if(orderAddreCompStrnsMap.get('Sold To') == orderAddreCompStrnsMap.get('Bill To') && orderAddreCompStrnsMap.get('Sold To') == orderAddreCompStrnsMap.get('Ship To'))
             {
               orderAddreCompStrnsMap.remove('Bill To'); orderAddreCompStrnsMap.remove('Ship To'); orderAddreCompStrnsMap.remove('End User');
             } else if (orderAddreCompStrnsMap.get('Bill To') == orderAddreCompStrnsMap.get('Ship To'))
             {
               orderAddreCompStrnsMap.remove('Ship To'); orderAddreCompStrnsMap.remove('End User');
             }else if(orderAddreCompStrnsMap.get('Bill To') != orderAddreCompStrnsMap.get('Ship To'))
             {
               orderAddreCompStrnsMap.remove('End User');
             }
         }else {
             system.debug('----------------inside---indirect--directorder----------------'+orderAcntsFlagMap.get(eachorder.id));
             // Indirect Order
             if(orderAddreCompStrnsMap.get('Sold To') == orderAddreCompStrnsMap.get('Bill To') && orderAddreCompStrnsMap.get('Sold To') == orderAddreCompStrnsMap.get('Ship To'))
             {
              orderAddreCompStrnsMap.remove('Bill To'); orderAddreCompStrnsMap.remove('Ship To');
             }else if(orderAddreCompStrnsMap.get('Bill To') == orderAddreCompStrnsMap.get('Ship To'))
             {
               orderAddreCompStrnsMap.remove('Ship To');
             }
           }
          }
     }
      
     Boolean addresSameflag_SoldTo = false;
     Boolean addresSameflag_EndUser = false;
     Boolean allAddressSameflag = false;
          
     for(Account_Order_Address__c eachOrdAddress : ordAdrList)
     {
       if(orderAddreCompStrnsMap.keySet().contains(eachOrdAddress.Address_Type__c))
       {
       String ordAdrString = eachOrdAddress.Address_Type__c+':'+eachOrdAddress.Address__c+':'+eachOrdAddress.Address2__c+':'+eachOrdAddress.City__c+':'+eachOrdAddress.State__c+':'+eachOrdAddress.Country__c;
       
       Address__c adrss =  new Address__c(Address_Line_1__c = eachOrdAddress.Address__c,Address_Line_2__c = eachOrdAddress.Address2__c,City__c =  eachOrdAddress.City__c,State__c = eachOrdAddress.State__c,Country__c = eachOrdAddress.Country__c,Zipcode__c = eachOrdAddress.Zip_Code__c);
       
       // Checks in the Account Address if this Adddress already crated.
       if(!acntAddrCompStrns.contains(ordAdrString.toLowerCase()))
       {
            if(orderAddreCompStrnsMap.keySet().contains('Bill To') && eachOrdAddress.Address_Type__c == 'Bill To' )
            {
            String adrName = eachOrdAddress.Order__r.Sold_To_Name__r.Name;
            adrss.Account__c = eachOrdAddress.Order__r.Sold_To_Name__c; 
            adrss.Type__c = eachOrdAddress.Address_Type__c;
            adrss.Address_Type__c = eachOrdAddress.Address_Type__c;
        
            if(eachOrdAddress.Address__c != null)
            {
            if(eachOrdAddress.Address__c.length() > 80 )
            {
             String addrssName = eachOrdAddress.Address__c.SubString(0,80); 
              adrss.Name = addrssName;
             } else{
               adrss.Name = eachOrdAddress.Address__c;
            }   
            }
           
            adrss.Addressee__c = adrName;
            adrss.Address_Name__c = adrName;
            if(eachOrdAddress.Address__c != null ) { newacntAddrList.add(adrss); }        
           }  
          
         if(orderAddreCompStrnsMap.keySet().contains('Sold To') && eachOrdAddress.Address_Type__c == 'Sold To')
         {
            String adrName = eachOrdAddress.Order__r.Sold_To_Name__r.Name;
            adrss.Account__c = eachOrdAddress.Order__r.Sold_To_Name__c; 
            adrss.Type__c = eachOrdAddress.Address_Type__c;
            adrss.Address_Type__c = eachOrdAddress.Address_Type__c;
         
            if(eachOrdAddress.Address__c != null)
            {
            if(eachOrdAddress.Address__c.length() > 80 )
            {
             String addrssName = eachOrdAddress.Address__c.SubString(0,80); 
              adrss.Name = addrssName;
             } else{
               adrss.Name = eachOrdAddress.Address__c;
            }   
            }
            
            adrss.Addressee__c = adrName;
            adrss.Address_Name__c = adrName;
            if(eachOrdAddress.Address__c != null) { newacntAddrList.add(adrss); }        
         }
         
         if(orderAddreCompStrnsMap.keySet().contains('Ship To') && eachOrdAddress.Address_Type__c == 'Ship To')
         {
            String adrName = eachOrdAddress.Order__r.Sold_To_Name__r.Name;      
            adrss.Account__c = eachOrdAddress.Order__r.Sold_To_Name__c;  
            adrss.Type__c = eachOrdAddress.Address_Type__c;
            adrss.Address_Type__c = eachOrdAddress.Address_Type__c;
          
            if(eachOrdAddress.Address__c != null)
            {
            if(eachOrdAddress.Address__c.length() > 80 )
            {
             String addrssName = eachOrdAddress.Address__c.SubString(0,80); 
              adrss.Name = addrssName;
             } else{
               adrss.Name = eachOrdAddress.Address__c;
            }   
            }       
          
            adrss.Addressee__c = adrName;
            adrss.Address_Name__c = adrName;
            if(eachOrdAddress.Address__c != null) { newacntAddrList.add(adrss); }        
         }
         
         if(orderAddreCompStrnsMap.keySet().contains('End User') && eachOrdAddress.Address_Type__c == 'End User')
         {
            String adrName = eachOrdAddress.Order__r.End_User_Name__r.Name; 
            adrss.Account__c = eachOrdAddress.Order__r.End_User_Name__c; 
            adrss.Type__c = eachOrdAddress.Address_Type__c;
            adrss.Address_Type__c = eachOrdAddress.Address_Type__c;
            
            if(eachOrdAddress.Address__c != null)
            {
            if(eachOrdAddress.Address__c.length() > 80 )
            {
             String addrssName = eachOrdAddress.Address__c.SubString(0,80); 
              adrss.Name = addrssName;
             } else{
               adrss.Name = eachOrdAddress.Address__c;
            }   
            }
            
            adrss.Addressee__c = adrName;
            adrss.Address_Name__c = adrName;
            if(eachOrdAddress.Address__c != null) { newacntAddrList.add(adrss); }        
         }
       }  
      }   
     }
         
     // Collection of order object records to update End User and Sold to Value of Order Object
     if(orderIds_soldto.size() > 0)
     {
     orderAdrUpdateSoldto_List = [Select Id,Order__r.End_User_Name__c,Order__r.Sold_To_Name__c FROM Account_Order_Address__c WHERE Order__c in :orderIds_soldto];    
     for(Account_Order_Address__c eachAddresOrderUpdate_soldTo: orderAdrUpdateSoldto_List)
     {
     eachAddresOrderUpdate_soldTo.Sold_To_Business_Partner__c = eachAddresOrderUpdate_soldTo.Order__r.Sold_To_Name__c; 
     }
     }
     
     if(orderIds_enduser.size() > 0)
     {
     orderAdrUpdateEndUser_List = [Select Id,Order__r.End_User_Name__c,Order__r.Sold_To_Name__c FROM Account_Order_Address__c WHERE Order__c in :orderIds_enduser];    
     for(Account_Order_Address__c eachAddresOrderUpdate_endUSer: orderAdrUpdateEndUser_List)
     {
     eachAddresOrderUpdate_endUSer.Account__c = eachAddresOrderUpdate_endUSer.Order__r.End_User_Name__c; 
     }
     }

     //DMl Statement to update order Addresses if sold to value is changed   
     if(orderAdrUpdateSoldto_List.size() > 0)
     {
       update orderAdrUpdateSoldto_List;
     }
     
     //DMl Statement to update order Addresses if end user value is changed
     if(orderAdrUpdateEndUser_List.size() > 0)  
     {
       update orderAdrUpdateEndUser_List;
     } 


     //DMl Statement to create Account Addresses
     if(newacntAddrList.size() > 0)     
     {
     insert newacntAddrList;
     }
     orderAdrUpdateSoldto_List.clear();
     orderAdrUpdateEndUser_List.clear();
     newacntAddrList.clear();
    }
}