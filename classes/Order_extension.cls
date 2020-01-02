public class Order_extension 
{
   public string recid;
   public order__c OrderAcct{set;get;}
   public List<wAddress> bill_to_waddress{get;set;}
   public List<wAddress> Ship_to_waddress{get;set;}
   public List<wAddress> Sold_to_waddress{get;set;}
   public List<wAddress> end_user_waddress{get;set;}
   public Integer billcounter=0;
   public Integer Shipcounter=0;
   public Integer Soldcounter=0;
   public Integer endcounter=0;
   public Address__c billto_Name {get;set;}
   public Address__c soldto_Name{get;set;}
   public Address__c shipto_Name{get;set;}
   public Address__c enduser_Name{get;set;}
   List<Account_Order_Address__c> Accorders = new List<Account_Order_Address__c> ();
   List<Account_Order_Address__c> UpdateAccorders = new List<Account_Order_Address__c> ();
   List<Account_Order_Address__c> InsertAccorders = new List<Account_Order_Address__c> ();

    public Order_extension(ApexPages.StandardController controller)
     {
         recid = ApexPages.currentPage().getParameters().get('id');
         Set<String> billTo_Adrr_StrList = new Set<String>();
         Set<String> endUser_Adrr_StrList = new Set<String>();
         Set<String> shipTo_Adrr_StrList = new Set<String>();
         Set<String> soldTo_Adrr_StrList = new Set<String>();
         
         OrderAcct=[select id,Bill_To_Name__c,End_User_Name__c,Ship_To_Name__c,Sold_To_Name__c,owner.name,recordtype.name,status__c,name from order__c where id=:recid limit 1];
         if(OrderAcct.Bill_To_Name__c!=null){
             bill_to_waddress = new List<wAddress>();
             for(Address__c temp :[SELECT id,Account__c,Address_Line_1__c,Address_Line_2__c,Address_Name__c,Address_Type__c,City__c,Country__c,State__c,Account__r.name,
                                 Zipcode__c FROM Address__c where Account__c=:OrderAcct.Bill_To_Name__c]){
                 wAddress obj = new wAddress(temp);
                 
                 String eachAddrString = temp.Address_Line_1__c+':'+temp.Address_Line_2__c+':'+temp.City__c+':'+temp.State__c+':'+temp.Country__c;                      
                 if(billTo_Adrr_StrList.add(eachAddrString) == true)  
                 {                  
                  bill_to_waddress.add(obj);
                 }  
             }
         }
                    
         if(OrderAcct.End_User_Name__c!=null){
            end_user_waddress = new List<wAddress>();
             for(Address__c temp :[SELECT id,Account__c,Address_Line_1__c,Address_Line_2__c,Address_Name__c,Address_Type__c,City__c,Country__c,State__c,Account__r.name,
                                 Zipcode__c FROM Address__c where Account__c=:OrderAcct.End_User_Name__c]){
                 wAddress obj = new wAddress(temp);
                 String eachAddrString = temp.Address_Line_1__c+':'+temp.Address_Line_2__c+':'+temp.City__c+':'+temp.State__c+':'+temp.Country__c;        
                 if(endUser_Adrr_StrList.add(eachAddrString) == true)
                 {
                  end_user_waddress.add(obj);
                 }
             }
         }
         
          if(OrderAcct.Ship_To_Name__c!=null){
            Ship_to_waddress = new List<wAddress>();
             for(Address__c temp :[SELECT id,Account__c,Address_Line_1__c,Address_Line_2__c,Address_Name__c,Address_Type__c,City__c,Country__c,State__c,Account__r.name,
                                 Zipcode__c FROM Address__c where Account__c=:OrderAcct.Ship_To_Name__c]){
                 wAddress obj = new wAddress(temp);
                 String eachAddrString = temp.Address_Line_1__c+':'+temp.Address_Line_2__c+':'+temp.City__c+':'+temp.State__c+':'+temp.Country__c;        
                 if(shipTo_Adrr_StrList.add(eachAddrString) == true)
                 {
                 Ship_to_waddress.add(obj);
                 }
             }
         }
         
          if(OrderAcct.Sold_To_Name__c!=null){
            Sold_to_waddress = new List<wAddress>();
             for(Address__c temp :[SELECT id,Account__c,Address_Line_1__c,Address_Line_2__c,Address_Name__c,Address_Type__c,City__c,Country__c,State__c,Account__r.name,
                                Zipcode__c FROM Address__c where Account__c=:OrderAcct.Sold_To_Name__c]){
                 wAddress obj = new wAddress(temp);
                 String eachAddrString = temp.Address_Line_1__c+':'+temp.Address_Line_2__c+':'+temp.City__c+':'+temp.State__c+':'+temp.Country__c;        
                 if(soldTo_Adrr_StrList.add(eachAddrString) == true)
                 {
                 Sold_to_waddress.add(obj);
                 }
             }
         }     
         if(!bill_to_waddress.isEmpty()) { billto_Name = bill_to_waddress[0].addr; }
         if(!end_user_waddress.isEmpty()) { enduser_Name = end_user_waddress[0].addr; }
         if(!Ship_to_waddress.isEmpty()) { shipto_Name = Ship_to_waddress[0].addr; }         
         if(!Sold_to_waddress.isEmpty()) { soldto_Name = Sold_to_waddress[0].addr; }   
      }
    
    public class wAddress{
          public Address__c addr{get; set;}
          public Boolean selected {get; set;}
          
          public wAddress(Address__c obj) {
              addr= obj;
              selected = false;
          }
    }
    
    public pagereference submit()
    {
    //system.debug('***size'+bill_to_waddress.size());
     
    if(bill_to_waddress!=null)
   {
    for(wAddress obj: bill_to_waddress)
       {      
         if(obj.selected == true)
         billcounter++;
       }
    }
    if(Ship_to_waddress!=null)
   {
     for(wAddress obj: Ship_to_waddress)
       { if(obj.selected == true)
         Shipcounter++;
       }
     }
     
     if(Sold_to_waddress!=null)
   {
        for(wAddress obj: Sold_to_waddress)
       { if(obj.selected == true)
         Soldcounter++;
       }
    }
    if(end_user_waddress!=null)
   {
        for(wAddress obj: end_user_waddress)
       { if(obj.selected == true)
         endcounter++;
       }
     }
       
      if(billcounter==1)
      {
        for(wAddress obj: bill_to_waddress)
       { 
        if(obj.selected == true)
          {
               Accorders=[SELECT Id,Name,Address__c,Address2__c,Address_Type__c,Country__c,State__c,City__c,Zip_Code__c,Account__c,Order__c FROM Account_Order_Address__c where Address_Type__c='Bill To' and Order__c=:recid order by lastmodifieddate desc ];
               if(Accorders.size()!=0)
               {
                Accorders.get(0).Address__c=obj.addr.Address_Line_1__c;
                Accorders.get(0).Address2__c=obj.addr.Address_Line_2__c;
                Accorders.get(0).Country__c=obj.addr.Country__c;
                Accorders.get(0).State__c=obj.addr.State__c;
                Accorders.get(0).City__c=obj.addr.City__c;
                Accorders.get(0).Zip_Code__c=obj.addr.Zipcode__c;
                Accorders.get(0).Company__c = obj.addr.Account__r.name;
                //   Accorders.get(0).Sold_To_Business_Partner__c = OrderAcct.Sold_To_Name__c;
                UpdateAccorders.add(Accorders.get(0));
               }
               else
               {
                Account_Order_Address__c temp = new Account_Order_Address__c();
               
               temp.Address__c=obj.addr.Address_Line_1__c;
                temp.Address2__c=obj.addr.Address_Line_2__c;
                temp.Country__c=obj.addr.Country__c;
               temp.State__c=obj.addr.State__c;
                temp.City__c=obj.addr.City__c;
               temp.Zip_Code__c=obj.addr.Zipcode__c;
               temp.Address_Type__c='Bill To';
               temp.Order__c=recid;
               // temp.Account__c=obj.addr.Account__c;
                
                temp.Company__c = obj.addr.Account__r.name;
                temp.Account__c=OrderAcct.End_User_Name__c;
                temp.Sold_To_Business_Partner__c = OrderAcct.Sold_To_Name__c;
                InsertAccorders.add(temp);
               
               }
           } 
         }
         
      }
      else  if(billcounter>1)
       { 
       System.debug('*** inside error ');
       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select one Bill To Address');
       ApexPages.addmessage(myMsg);
        billcounter=0;
       return null;
       }
       if(Shipcounter==1)
      {
        Accorders.clear();
        for(wAddress obj: Ship_to_waddress)
       { 
        if(obj.selected == true)
          {
               Accorders=[SELECT Id,Name,Address__c,Address2__c,Address_Type__c,Country__c,State__c,City__c,Zip_Code__c,Account__c,Order__c FROM Account_Order_Address__c where Address_Type__c='Ship To' and Order__c=:recid order by lastmodifieddate desc ];
               
              
               if(Accorders.size()!=0)
               {
                Accorders.get(0).Address__c=obj.addr.Address_Line_1__c;
                Accorders.get(0).Address2__c=obj.addr.Address_Line_2__c;
                Accorders.get(0).Country__c=obj.addr.Country__c;
                Accorders.get(0).State__c=obj.addr.State__c;
                Accorders.get(0).City__c=obj.addr.City__c;
                Accorders.get(0).Zip_Code__c=obj.addr.Zipcode__c;
                Accorders.get(0).Company__c = obj.addr.Account__r.name;
                 //  Accorders.get(0).Sold_To_Business_Partner__c = OrderAcct.Sold_To_Name__c;
                UpdateAccorders.add(Accorders.get(0));
               }
               else
               {
                Account_Order_Address__c temp = new Account_Order_Address__c();
               
                temp.Address__c=obj.addr.Address_Line_1__c;
                temp.Address2__c=obj.addr.Address_Line_2__c;
                temp.Country__c=obj.addr.Country__c;
                temp.State__c=obj.addr.State__c;
                temp.City__c=obj.addr.City__c;
                temp.Zip_Code__c=obj.addr.Zipcode__c;
                temp.Address_Type__c='Ship To';
                temp.Order__c=recid;
                //temp.Account__c=obj.addr.Account__c;
                 temp.Account__c=OrderAcct.End_User_Name__c;
                temp.Sold_To_Business_Partner__c = OrderAcct.Sold_To_Name__c;
                temp.Company__c = obj.addr.Account__r.name;

                InsertAccorders.add(temp);
               
               }
           } 
         }
         
      }
      else if(Shipcounter>1)
       { 
       System.debug('*** inside error ');
       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select one Ship To Address');
       ApexPages.addmessage(myMsg);
        Shipcounter=0;
       return null;
       }
       if(Soldcounter==1)
      {
        Accorders.clear();
        for(wAddress obj: Sold_to_waddress)
       { 
        if(obj.selected == true)
          {
               Accorders=[SELECT Id,Name,Address__c,Address2__c,Address_Type__c,Country__c,State__c,City__c,Zip_Code__c,Account__c,Order__c FROM Account_Order_Address__c where Address_Type__c='Sold To' and Order__c=:recid order by lastmodifieddate desc ];
               if(Accorders.size()!=0)
               {
                Accorders.get(0).Address__c=obj.addr.Address_Line_1__c;
                Accorders.get(0).Address2__c=obj.addr.Address_Line_2__c;
                Accorders.get(0).Country__c=obj.addr.Country__c;
                Accorders.get(0).State__c=obj.addr.State__c;
                Accorders.get(0).City__c=obj.addr.City__c;
                Accorders.get(0).Zip_Code__c=obj.addr.Zipcode__c;
                Accorders.get(0).Company__c = obj.addr.Account__r.name;
                //Accorders.get(0).Sold_To_Business_Partner__c = OrderAcct.Sold_To_Name__c;
                UpdateAccorders.add(Accorders.get(0));
               }
               else
               {
                Account_Order_Address__c temp = new Account_Order_Address__c();
               
               temp.Address__c=obj.addr.Address_Line_1__c;
                temp.Address2__c=obj.addr.Address_Line_2__c;
                temp.Country__c=obj.addr.Country__c;
               temp.State__c=obj.addr.State__c;
                temp.City__c=obj.addr.City__c;
               temp.Zip_Code__c=obj.addr.Zipcode__c;
               temp.Address_Type__c='Sold To';
               temp.Order__c=recid;
                 temp.Account__c=OrderAcct.End_User_Name__c;
                temp.Company__c = obj.addr.Account__r.name;
                temp.Sold_To_Business_Partner__c = OrderAcct.Sold_To_Name__c;
                InsertAccorders.add(temp);
               
               }
           } 
         }
         
      }
      else if(Soldcounter>1)
       { 
       System.debug('*** inside error ');
       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select one Sold To Address');
       ApexPages.addmessage(myMsg);
        Soldcounter=0;
       return null;
       }
      if(endcounter==1)
      {
        Accorders.clear();
        for(wAddress obj: end_user_waddress)
       { 
        if(obj.selected == true)
          {
               Accorders=[SELECT Id,Name,Address__c,Address2__c,Address_Type__c,Country__c,State__c,City__c,Zip_Code__c,Account__c,Order__c FROM Account_Order_Address__c where Address_Type__c='End User' and Order__c=:recid order by lastmodifieddate desc ];
               if(Accorders.size()!=0)
               {
                Accorders.get(0).Address__c=obj.addr.Address_Line_1__c;
                Accorders.get(0).Address2__c=obj.addr.Address_Line_2__c;
                Accorders.get(0).Country__c=obj.addr.Country__c;
                Accorders.get(0).State__c=obj.addr.State__c;
                Accorders.get(0).City__c=obj.addr.City__c;
                Accorders.get(0).Zip_Code__c=obj.addr.Zipcode__c;
                Accorders.get(0).Company__c = obj.addr.Account__r.name;
                //Accorders.get(0).Sold_To_Business_Partner__c = OrderAcct.Sold_To_Name__c;
                UpdateAccorders.add(Accorders.get(0));
               }
               else
               {
                Account_Order_Address__c temp = new Account_Order_Address__c();
               
               temp.Address__c=obj.addr.Address_Line_1__c;
               temp.Address2__c=obj.addr.Address_Line_2__c;
               temp.Country__c=obj.addr.Country__c;
               temp.State__c=obj.addr.State__c;
               temp.City__c=obj.addr.City__c;
               temp.Zip_Code__c=obj.addr.Zipcode__c;
               temp.Address_Type__c='End User';
               temp.Order__c=recid;
                temp.Account__c=OrderAcct.End_User_Name__c;
               temp.Company__c = obj.addr.Account__r.name;
               temp.Sold_To_Business_Partner__c = OrderAcct.Sold_To_Name__c;
               InsertAccorders.add(temp);
               
               }
           } 
         }
         
      }
       else if(endcounter>1)
       { 
       System.debug('*** inside error ');
       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select one End User Address');
       ApexPages.addmessage(myMsg);
        endcounter=0;
       return null;
       }
     update UpdateAccorders;
     Insert InsertAccorders;  
      
      PageReference pf = new  PageReference('/'+recid);
      pf.setRedirect(true);
      return pf;
    }
   

}