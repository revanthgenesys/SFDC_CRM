/***************************************************************************************************
* 
*  Class Name      :   PartnerServiceEntitlementCtrl
*  Description     :   This class is used to control the Service Entitlement Page
*  Auther          :   R Systems
* 
****************************************************************************************************/
global without sharing class PartnerServiceEntitlementCtrl {
    
    
    global String accntId{get;set;}
    global Decimal currencyRate{get;set;}    
    global Decimal availableToken{get;set;}
    global Decimal availableTokenAlaCarte{get;set;}
    global String accountName{get;set;}
    global Boolean isBuy{get;set;}
    global string serviceValue{get;set;}
    global string showAllServiceElement {get;set;}
    global string showSelfServiceElement {get;set;}
    global string contactName {get; set;}
    global Decimal availableTokenGU{get;set;}
    public String currencyType {get;set;} //added by priyank
    public String sOfferingType{get;set;} //added by priyank on 14 dec 2018, on request by vinay.
    public String offeringTypeName{get;set;}//added by priyank
    public List<String> offeringTypeList; //added by priyank
    
    global Boolean gotoButtonFlag{get;set;}
    
    global PartnerServiceEntitlementCtrl(){
    // Field For the Price of Produt on A la Carte product       NG5_NA_USD_Price__c
        accntId =  apexpages.currentpage().getparameters().get('accId');
        availableToken = 0;
        availableTokenGU = 0;
        gotoButtonFlag = false;
        isBuy = false;
        // If Opening from the Portal then get the contact Id        
        id id1 = Userinfo.getUserId();
        System.debug('Which User====='+id1);
        List<User>  lstUser = [Select Id, ContactId  from User where Id =: Id1];
        //lstUser[0].ContactID = '0031D00000FhCGm'; 
        
        System.debug('@lstUser '+lstUser + gotoButtonFlag);
        
        
        // Get from User Contact Id
        if(lstUser.size() > 0 && lstUser[0].ContactId != null && accntId == null){            
             List<Contact> lstCon = [Select Id, AccountId, PureSuccess_Main_Contact__c,
                                    Account.Total_Token_Available__c,All_Service_Elements_Access__c, Self_Service_Elements_Access__c
                                    from Contact where Id=:lstUser[0].ContactId];
              
            if(lstCon.size()  > 0)
            {
                accntId = lstCon[0].AccountId;
                
               if(lstCon[0].All_Service_Elements_Access__c){
                    
                    showAllServiceElement = 'true';
                }else{
                    
                    showAllServiceElement = 'false';
                }
                
                if(lstCon[0].Self_Service_Elements_Access__c){
                    
                    showSelfServiceElement = 'true';
                }else{
                    
                    showSelfServiceElement = 'false';
                }
                //showAllServiceElement = String.valueOf(lstCon[0].All_Service_Elements_Access__c);
                //showSelfServiceElement = String.valueOf(lstCon[0].Self_Service_Elements_Access__c);
                
                //System.debug(' @lstCon[0].PureSuccess_Main_Contact__c ' + lstCon[0].PureSuccess_Main_Contact__c);
                
                System.debug('@gotoButtonFlag - inside' + gotoButtonFlag);
                
                if(lstCon[0].PureSuccess_Main_Contact__c || lstCon[0].Self_Service_Elements_Access__c || lstCon[0].All_Service_Elements_Access__c){
                    gotoButtonFlag = true;
                }
             }
             
             System.debug('@gotoButtonFlag ' + gotoButtonFlag);
             
             System.debug('All Service ====='+showAllServiceElement +'====ShowService Element:::::'+showSelfServiceElement);             
         }         
         List<Account> lstAcc = [Select Id, Name,Total_Token_Available__c,Total_GU_Training_Units__c,Advisor__c  from Account where Id=:accntId];
         accountName = lstAcc[0].Name;      
                System.debug('Account'+ accntId);
                List<Product_Group__c> lst = [Select Id from Product_Group__c where Type__c =: 'A la Carte Partner'];
                if(lstAcc[0].Total_Token_Available__c != null)
                {
                    availableToken = lstAcc[0].Total_Token_Available__c;
                    availableTokenGU = lstAcc[0].Total_GU_Training_Units__c;
                }    //if(lst.size() > 0 && availableToken < lst[0].Token_Value__c)
                    if(availableToken<0 || availableToken == 0)
                        isBuy = true;
          System.debug('PP Value of IsBuy'+isBuy);
          CurrencyType = '';
          List<Token_Allocations__c> tka = new List<Token_Allocations__c>([Select ID, Currency__c from Token_Allocations__c where Account__c =: accntid AND Currency__c != NULL Limit 1]);                          
          if(tka.size()>0)
          {
              CurrencyType = tka[0].Currency__c;
          }
          else
          {
          
              CurrencyType = 'USD';
          }
          List<CurrencyType> currencyValue = new List<CurrencyType>([SELECT ConversionRate,Id,IsActive,IsCorporate,IsoCode FROM CurrencyType  Where IsoCode =: CurrencyType Limit 1]);
          if(currencyValue.size()>0)
          {
              currencyRate =  Math.round(currencyValue[0].ConversionRate);    
          }
          System.debug('PP at Page load Currency Rate for cal'+currencyRate);
          List<Contact> cont = new List<Contact>([Select Name from Contact Where AccountId =:accntId AND PureSuccess_Main_Contact__c = True]);
          if(cont != null && cont.size()>0)
              contactName = cont[0].Name;
              
          //Priyank added below code
        offeringTypeList = new List<String>();
        offeringTypeName ='';
        for(Pure_Success_Package__c p: [Select Order__r.Order_Category__c FROM Pure_Success_Package__c 
                                    Where Token_Status__c =: 'Allocated' 
                                    AND Account__r.Id =: accntId
                                    AND Package_Type__c =: 'Pure Success' and Order__c!=null ORDER BY Product__r.Description__c ASC]){
          if(!offeringTypeName.contains(p.Order__r.Order_Category__c)){
              if(p.Order__r.Order_Category__c == 'PureCloud-Cloud Order' && !offeringTypeName.contains('PureCloud')){
                  offeringTypeName = offeringTypeName+ '{ itemLabel:"' + 'PureCloud' +'"' +','+
                                                  'itemValue:"' + 'PureCloud' +'"'+'}'+',';
                  offeringTypeList.add('PureCloud');
              }else if(p.Order__r.Order_Category__c == 'PureConnect-Cloud Order' && !offeringTypeName.contains('PureConnect Cloud')){
                  offeringTypeName = offeringTypeName+ '{ itemLabel:"' + 'PureConnect Cloud' +'"' +','+
                                                  'itemValue:"' + 'PureConnect Cloud' +'"'+'}'+',';
                  offeringTypeList.add('PureConnect Cloud');
                  system.debug('>>>>######  '+offeringTypeName);
              }else if(p.Order__r.Order_Category__c != 'PureConnect-Cloud Order' && p.Order__r.Order_Category__c != 'PureCloud-Cloud Order' && p.Order__r.Order_Category__c != 'Business Edition' && p.Order__r.Order_Category__c != 'PureEngage-Cloud Order'){
                  offeringTypeName = offeringTypeName+ '{ itemLabel:"' + p.Order__r.Order_Category__c +'"' +','+
                                                  'itemValue:"' + p.Order__r.Order_Category__c +'"'+'}'+',';
                  
                  offeringTypeList.add(p.Order__r.Order_Category__c);
              }else if((p.Order__r.Order_Category__c == 'PureEngage-Cloud Order' || p.Order__r.Order_Category__c == 'Business Edition') && !offeringTypeName.contains('PureEngage Cloud') ){
                  offeringTypeName = offeringTypeName+ '{ itemLabel:"' + 'PureEngage Cloud' +'"' +','+
                                                  'itemValue:"' + 'PureEngage Cloud' +'"'+'}'+',';
                  
                  offeringTypeList.add('PureEngage Cloud');
              }
              
          }
        }
        system.debug('>>>>######  '+offeringTypeName);
        if(!String.isBlank(offeringTypeName)){
            offeringTypeName = offeringTypeName.substring(0, offeringTypeName.length() - 1);
        }
        if(offeringTypeList.size()>0){
          sOfferingType = offeringTypeList[0] ;// added by priyank on 14 dec 2018, on request by vinay.
        }
        //Priyank code end.
    }
    
   
    // Get Pure Success Package
    @RemoteAction
    global static List<Pure_Success_Package__c> pureSuccessPacklist(String accId, string allService, string selfService){
        List<Pure_Success_Package__c> pureSuccessPacklist;
        if(allService == 'true' || allService == '')
        {
            pureSuccessPacklist = [Select Account__r.Name,Account__r.Total_Token_Available__c,
                                    Contract_End_Date__c,Contract_Start_Date__c,
                                    CreatedDate,Id,Name,Order__c,Product_Group__c,
                                    Tokens__c,Token_Status_Expired__c,Token_Status__c,Order__r.Order_Category__c,
                                    DaysToexpiration__c,Product_Group__r.Name,Service_Contract_No__c, Order__r.Name,
                                    Product_Group__r.Id,Order__r.PO_Number__c,Available_Service_element__c,Account__r.Advisor_Name__c
                                    ,Order__r.End_User_Name__r.Name, Product__C, Product__r.Consumption_Model__c
                                    FROM Pure_Success_Package__c 
                                    Where Token_Status__c =: 'Allocated' 
                                    AND Account__r.Id =: accId
                                    AND Package_Type__c =: 'Pure Success' AND Product_Group__r.Name != NULL and order__c!=null];
         }
         else if ((allService == 'false' && selfService == 'true') || (selfService == '')  )
         {
             pureSuccessPacklist = [Select Account__r.Name,Account__r.Total_Token_Available__c,
                                    Contract_End_Date__c,Contract_Start_Date__c,
                                    CreatedDate,Id,Name,Order__c,Product_Group__c,
                                    Tokens__c,Token_Status_Expired__c,Token_Status__c,Order__r.Order_Category__c,
                                    DaysToexpiration__c,Product_Group__r.Name,Service_Contract_No__c, Order__r.Name,
                                    Product_Group__r.Id,Order__r.PO_Number__c,Available_Service_element__c,Account__r.Advisor_Name__c
                                    ,Order__r.End_User_Name__r.Name, Product__C, Product__r.Consumption_Model__c
                                    FROM Pure_Success_Package__c 
                                    Where Token_Status__c =: 'Allocated' 
                                    AND Account__r.Id =: accId
                                    AND Package_Type__c =: 'Pure Success'
                                    AND Product__r.Consumption_Model__c =: 'Continuous - Not Tracked' AND Product_Group__r.Name != NULL and order__c!=null];
         }    
            
        return pureSuccessPacklist;

    }
    
     /*// get token allocation history for GU Training Units
    @RemoteAction
    global static List<Token_Allocations__c> getTokenAllocationGU(String accId, string allService, string selfService){
        List<Token_Allocations__c> tokenAllocationlist = [SELECT Account__c,CaseAccount__c,Contract_End_Date__c,
                                                            Contract_Start_Date__c,Id,Name,Order__c,CreatedDate,
                                                            Product_Group__c,Product__c,Product__r.Name,Product__r.APN_Number__c,
                                                            Tokens__c,Token_Status__c,
                                                            Order__r.Id,Tokens_Available__c,
                                                            Order__r.Name,
                                                            Order__r.End_User_Name__r.Name,
                                                            Account__r.Name,
                                                            Product_Group__r.Name,Product_Group__r.Id,
                                                            Tokens_Used__c,Is_Consumed__c
                                                            FROM Token_Allocations__c 
                                                            Where
                                                            Account__c =: accId
                                                            AND Token_status__c =: 'Allocated'
                                                            AND Allocation_Type__c =: 'GU Training Units'
                                                            Order by Contract_End_Date__c]; 
                                                            //AND Tokens__c >=0];
            return tokenAllocationlist;
    }*/
    
    // Get Package Services Consumed for Related PureSuccess Package
    @RemoteAction
    global static List<Package_Services__c> getPackageServicesConsumed(String packId,string allService, string selfService){
        
        /*List<Package_Services__c>  pkgSrvlist;
           pkgSrvlist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                            Id,Name,Product_Group__c,Product__c,
                            PureSuccess_Package__c,Status__c,
                            Product__r.Description, Product__r.Description__c,
                            Product__r.Name, 
                            Product__r.APN_Number__c,
                            Order_Name__c,
                            Order__c,
                            Case__r.casenumber,
                            Case_name__c,
                            Consume_service__c,
                            Consume_service__r.Id, 
                            Consume_Service_Name__c,
                            Consume_Service_Id__c,
                            Product_Group_Item__c,
                            Product_Group_Item__r.Product_to_Hide__c,
                            Product_Group_Item__r.Product_to_Hide__r.Product__r.Consumption_Model__c
                            
                            FROM  Package_Services__c
                            Where Status__c IN  ('Consumed')
                            AND PureSuccess_Package__c =: packId ORDER BY Product__r.Description__c ASC];

        return pkgSrvlist;
        */
        List<Package_Services__c>  pkgSrvlist;
        if(allService == 'true' || allService == '')
        {
            pkgSrvlist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                            Id,Name,Product_Group__c,Product__c,
                            PureSuccess_Package__c,Status__c,
                            Product__r.Description,
                            Product__r.Description__c, 
                            Product__r.Name, 
                            Product__r.APN_Number__c,
                            Order_Name__c,
                            Order__c,case_Name__c,Case__r.CaseNumber,Case__c
                            FROM  Package_Services__c
                            Where Status__c IN  ('Consumed')
                            AND PureSuccess_Package__c =: packId];
        }
        else if ((allService == 'false' && selfService == 'true') || (selfService == ''))
        {
            pkgSrvlist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                            Id,Name,Product_Group__c,Product__c,
                            PureSuccess_Package__c,Status__c,
                            Product__r.Description,
                            Product__r.Description__c, 
                            Product__r.Name, 
                            Product__r.APN_Number__c,
                            Order_Name__c,Product__r.Consumption_Model__c,
                            Order__c,case_Name__c,Case__r.CaseNumber,Case__c
                            FROM  Package_Services__c
                            Where Status__c IN  ('Consumed')
                            AND PureSuccess_Package__c =: packId
                            AND Product__r.Consumption_Model__c =: 'Continuous - Not Tracked'];
        }
        
        return pkgSrvlist;
    }
    
    //Get list of all Contact for the account
    @RemoteAction
    global static List<Contact> getEndContactList(String packId){
        /*String AccountId;
        List<Package_Services__c> pkg = [SELECT  PureSuccess_Package__c FROM  Package_Services__c WHERE PureSuccess_Package__c =: packId];
        if(pkg != null)
        {
            List<Pure_Success_Package__c>  pupkg = [Select Order__c, Order__r.End_User_Name__c from Pure_Success_Package__c Where Id =: pkg[0].PureSuccess_Package__c ] ; 
            if(pupkg != null)
                AccountId = pupkg[0].Order__r.End_User_Name__c;
        
        }
        
        List<Contact> endContactList = [Select ID, Name, Email, AccountId From Contact Where AccountId =: AccountId ];
        
        return endContactList;*/
        
        System.debug('PP=======Account Id ====='+packId);
        List<Contact> endContactList = [Select ID, Name, Email, AccountId,
                                        All_Service_Elements_Access__c,PureSuccess_Main_Contact__c,Self_Service_Elements_Access__c  
                                        From Contact 
                                        Where AccountId =: packId
                                        AND (PureSuccess_Main_Contact__c =: True
                                        OR All_Service_Elements_Access__c =: True
                                        OR Self_Service_Elements_Access__c =: True ) ];
        
        return endContactList;
        
        
    }
    
    // Get Package Services availbale to Allocated or In Progress
    @RemoteAction
    global static List<Package_Services__c> getPackageServicesAvailable(String packId,string allService, string selfService){
        
        List<Package_Services__c>  pkgSrvlist;
       
            pkgSrvlist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                            Id,Name,Product_Group__c,Product__c,
                            PureSuccess_Package__c,Status__c,
                            Product__r.Description, Product__r.Description__c,
                            Product__r.Name, 
                            Product__r.Consumption_Model__c,
                            Product__r.APN_Number__c,
                            Order_Name__c,
                            Order__c,case__r.casenumber,
                            Order__r.Name, 
                            Case_Name__c, 
                            Consume_service__c,
                            Consume_service__r.Id, 
                            Consume_Service_Name__c,
                            Consume_Service_Id__c,
                            Product_Group_Item__c,
                            Product_Group_Item__r.Product_To_Hide__c,
                            PureSuccess_Package__r.Order__r.Order_Category__c
                            FROM  Package_Services__c
                            Where Status__c IN  ('Available','Allocated', 'In Progress')
                            AND PureSuccess_Package__c =: packId ORDER BY Product__r.Description__c ASC];
                                                       
        return pkgSrvlist;
        
        /*List<Package_Services__c>  pkgSrvlist;
        if(allService == 'true' || allService == '')
        {
            pkgSrvlist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                            Id,Name,Product_Group__c,Product__c,
                            PureSuccess_Package__c,Status__c,
                            Product__r.Description,
                            Product__r.Description__c, 
                            Product__r.Name, 
                            Product__r.APN_Number__c,
                            Order_Name__c,
                            Order__c,Case__r.CaseNumber,Case__c,
                            Order__r.Name,Case_Name__c
                            FROM  Package_Services__c
                            Where Status__c IN  ('Available','Allocated', 'In Progress')
                            AND PureSuccess_Package__c =: packId
                            order by Name];
        }
        else if ((allService == 'false' && selfService == 'true') || (selfService == ''))
        {
            pkgSrvlist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                            Id,Name,Product_Group__c,Product__c,
                            PureSuccess_Package__c,Status__c,
                            Product__r.Description,
                            Product__r.Description__c, 
                            Product__r.Name, 
                            Product__r.APN_Number__c,
                            Order_Name__c,
                            Order__c,Case__r.CaseNumber,Case__c,
                            Order__r.Name,Case_Name__c,Product__r.Consumption_Model__c
                            FROM  Package_Services__c
                            Where Status__c IN  ('Available','Allocated', 'In Progress')
                            AND PureSuccess_Package__c =: packId
                            AND Product__r.Consumption_Model__c =: 'Continuous - Not Tracked'];
        }
        
        return pkgSrvlist;*/
    }
    
    // Get Package Service Data A la Carte consumed
    @RemoteAction
    global static List<Package_Services__c> getConsumedAlaCarte(String accId,string offeringType){
        
        Map<Id, Pure_Success_Package__c> mapPackage = new Map<Id, Pure_Success_Package__c>([Select Id from Pure_Success_Package__c where Account__c =:accId and Package_Type__c =: 'A la Carte']);
        List<Package_Services__c> pureSuccessPacklist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                                                                    Id,Name,Product_Group__c,Product__c,
                                                                    PureSuccess_Package__c,Status__c,Case__c,
                                                                    Product__r.Description,Product__r.Name,Case__r.CaseNumber
                                                                    ,PureSuccess_Package__r.Package_type__c,
                                                                    Product_Group__r.Name
                                                                    ,Product__r.APN_Number__c,Product__r.Description__c,
                                                                    Order_Name__c,
                                                                    Order__c,
                                                                    OrderId__c
                                                                    FROM Package_Services__c
                                                                    Where Status__c IN  ('Consumed')
                                                                    AND PureSuccess_Package__r.Package_Type__c =: 'A la Carte'
                                                                    and PureSuccess_Package__c In: mapPackage.keyset()and Product_Group__r.Offering_Type__c =:offeringType ];
        
        return pureSuccessPacklist;

    }
    
    // Get Package Service Data A la Carte Expired
    @RemoteAction
    global static List<Package_Services__c> getExpiredAlaCarte(String accId,string offeringType){
        
        Map<Id, Pure_Success_Package__c> mapPackage = new Map<Id, Pure_Success_Package__c>([Select Id from Pure_Success_Package__c where Account__c =:accId and Package_Type__c =: 'A la Carte']);
        List<Package_Services__c> pureSuccessPacklist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                                                                    Id,Name,Product_Group__c,Product__c,
                                                                    PureSuccess_Package__c,Status__c,Case__c,
                                                                    Product__r.Description,Product__r.Name,Case__r.CaseNumber
                                                                    ,PureSuccess_Package__r.Package_type__c,
                                                                    Product_Group__r.Name,Offering_Type__c,End_Date__c
                                                                    ,Product__r.APN_Number__c,Product__r.Description__c,
                                                                    Order_Name__c,
                                                                    Order__c,
                                                                    OrderId__c
                                                                    FROM Package_Services__c
                                                                    Where Status__c IN  ('Expired')
                                                                    AND PureSuccess_Package__r.Package_Type__c =: 'A la Carte'
                                                                    and PureSuccess_Package__c In: mapPackage.keyset()and Product_Group__r.Offering_Type__c =:offeringType ];
        
        return pureSuccessPacklist;

    }
    
    
    // Get Package Service Data A la Carte In Progress and Allocated
    @RemoteAction
    global static List<Package_Services__c> getAlocatedAlaCarte(String accId, string allService, string selfService, string offeringType){
        Map<Id, Pure_Success_Package__c> mapPackage = new Map<Id, Pure_Success_Package__c>([Select Id from Pure_Success_Package__c where Account__c =:accId and Package_Type__c =: 'A la Carte']);
        List<Package_Services__c> pureSuccessPacklist;
        if(allService == 'true' || allService == '')
        {
            pureSuccessPacklist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                                    Id,Name,Product_Group__c,Product__c,
                                    PureSuccess_Package__c,Status__c,Case__c,
                                    Product__r.Description,Product__r.Name,Case__r.CaseNumber
                                    ,PureSuccess_Package__r.Package_type__c ,
                                    Product_Group__r.Name,Product__r.Description__c
                                    ,Product__r.APN_Number__c,
                                    Order_Name__c,
                                    Order__r.Id,case_name__c,Start_Date__c,End_Date__c,Offering_Type__c,
                                    OrderID__c
                                    FROM Package_Services__c
                                    Where Status__c IN   ('In Progress','Allocated', 'Available','Order Submitted')
                                    AND PureSuccess_Package__r.Package_Type__c =: 'A la Carte' AND Product_Group__r.Offering_Type__c =:offeringType
                                    and PureSuccess_Package__c In: mapPackage.keyset()];        
        }
        else if ((allService == 'false' && selfService == 'true') || (selfService == ''))
        {
            pureSuccessPacklist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                                    Id,Name,Product_Group__c,Product__c,
                                    PureSuccess_Package__c,Status__c,Case__c,
                                    Product__r.Description,Product__r.Name,Case__r.CaseNumber
                                    ,PureSuccess_Package__r.Package_type__c ,
                                    Product_Group__r.Name,Product__r.Description__c
                                    ,Product__r.APN_Number__c,Start_Date__c,End_Date__c,Offering_Type__c,
                                    Order_Name__c,
                                    Order__r.Id,case_name__c,Product__r.Consumption_Model__c,
                                    OrderID__c
                                    FROM Package_Services__c
                                    Where Status__c IN   ('In Progress','Allocated', 'Available','Order Submitted')
                                    AND PureSuccess_Package__r.Package_Type__c =: 'A la Carte'
                                    and PureSuccess_Package__c In: mapPackage.keyset()
                                    AND Product__r.Consumption_Model__c =: 'Continuous - Not Tracked' AND Product_Group__r.Offering_Type__c =:offeringType];
        }
        return pureSuccessPacklist;

    }
    
    // Get Product Group Items where Product Group is A la Carte
    @RemoteAction
    global static List<Product_Group_Item__c> getProductGroupItems(String accId , string allService, string selfService, String CurrencyType,string offeringType){
        string soldToCountry;
        System.debug('PP - Account Id Product Item'+accId);
        
        system.debug('++++>>>> '+offeringType);
        
        
        Map<Id, Product_Group__c> mapPackage = new Map<Id, Product_Group__c>([Select Id from Product_Group__c where Type__c =: 'A la Carte Partner']);
        List<Product_Group_Item__c> pureSuccessPacklist;
        
        //More filters as per discussion with Vinay 5/21
        //Include License_FYM_detail__c = 'Subscription Order'
    
        //Get Order Category of this account from Order
        List<Order__c> lstOrder = new List<Order__c>([Select Id, Opportunity__r.Sold_To_Country__r.Name, Order_category__c,End_User_Name__r.Recordtype.name from Order__c where End_User_Name__c =: accId and  Offering_Type__c != null and recordtype.name = 'General Orders'  and (License_FYM_detail__c = 'Subscription Order' OR License_FYM_detail__c = 'Cloud Order') and Offering_Type__c =: offeringType limit 1]);
        if(offeringType == 'PureCloud'){
            if(lstOrder.size()>0){
                soldToCountry = lstOrder[0].Opportunity__r.Sold_To_Country__r.Name;
            }else{
                List<Order__c> lstOrder1 = new List<Order__c>([Select Id, Order_category__c, Opportunity__r.Sold_To_Country__r.Name, Sold_To_Name__c, End_User_Name__c, End_User_Name__r.Recordtype.name from Order__c where Sold_To_Name__c =: accId and  Offering_Type__c != null and recordtype.name = 'General Orders'  and (License_FYM_detail__c = 'Subscription Order' OR License_FYM_detail__c = 'Cloud Order') and Offering_Type__c =: offeringType limit 1]);
                if(lstOrder1.size()>0){
                    soldToCountry = lstOrder1[0].Opportunity__r.Sold_To_Country__r.Name;
                }
            }
        }
        string strProductGroupName ='PureSuccess A la Carte';
        
        //Get first orders
        String sOrderCategory =offeringType; // PureEngage Subscription';
        
        if(lstOrder.size() == 1){
        
            if(lstOrder[0].End_User_Name__r.Recordtype.name == 'Enterprise - Business Partner')
                strProductGroupName = 'Partner PureSuccess A la Carte';
            
        //Tranform Business Edition for Pure Engage Cloud as per discussion with Vinay 5/21
    
            if(lstOrder[0].Order_category__c == 'Business Edition')    
                sOrderCategory = 'PureEngage Cloud';
           /* else
                sOrderCategory = lstOrder[0].Order_category__c; */
        }
        List<Product_Group__c> lstProdGroup = new List<Product_Group__c>([Select Id from Product_Group__c where Offering_Type__c =: sOrderCategory and Name =: strProductGroupName limit 1]);
        if(lstProdGroup.size()>0){
            string ProdGroup = lstProdGroup[0].id;
            system.debug('>>>### '+lstProdGroup[0].id);
            if(allService == 'true' || allService == '')
            {
                pureSuccessPacklist = [SELECT   APN_Number__c,
                                    Name,
                                    Product_Group__c,
                                    Product__r.Description__c,
                                    Product_Group__r.Name,
                                    Product__r.Description,
                                    Product__r.Name,
                                    Product__r.NG5_NA_USD_Price__c,
                                    Product__r.NG5_NA_CAD_Price__c,
                                    Product__r.NG1_APAC_ANZ_AUD_Price__c,
                                    Product__r.NG5_NZD_Price__c,
                                    Product__r.NG3_EMEA_GBP_Price__c,
                                    Product__r.NG3_EMEA_EUR_Price__c,
                                    Product__r.NG2_BRAZIL_BRL_Price__c,
                                    Product__r.NG4_APAC_JAPAN_YEN_Price__c,
                                    Product__r.NG5_ZAR_Price__c,
                                    Product__r.Currency_Conversion__c,
                                    Product__r.PureSuccess_Type__c,
                                    Product__c, Product__r.Consumption_Model__c
                                    FROM Product_Group_Item__c
                                    Where Product_Group__c =: ProdGroup and Remove_From_Service_Catalog__c = false and Product_Group__r.Offering_Type__c =:offeringType ORDER BY Product__r.Description__c ASC];
            
            }
            else if((allService == 'false' && selfService == 'true') || (selfService == ''))
            {
                system.debug('-- else if--');
                pureSuccessPacklist = [SELECT   APN_Number__c,
                                    Name,
                                    Product_Group__c,
                                    Product__r.Description__c,
                                    Product_Group__r.Name,
                                    Product__r.Description,
                                    Product__r.Name,
                                    Product__r.NG5_NA_USD_Price__c,
                                    Product__r.NG5_NA_CAD_Price__c,
                                    Product__r.NG1_APAC_ANZ_AUD_Price__c,
                                    Product__r.NG5_NZD_Price__c,
                                    Product__r.NG3_EMEA_GBP_Price__c,
                                    Product__r.NG3_EMEA_EUR_Price__c,
                                    Product__r.NG2_BRAZIL_BRL_Price__c,
                                    Product__r.NG4_APAC_JAPAN_YEN_Price__c,
                                    Product__r.NG5_ZAR_Price__c,
                                    Product__r.Currency_Conversion__c,
                                    Product__r.PureSuccess_Type__c,
                                    Product__c, Product__r.Consumption_Model__c
                                    FROM Product_Group_Item__c
                                    Where Product_Group__c =: ProdGroup and Remove_From_Service_Catalog__c = false 
                                    AND Product__r.Consumption_Model__c =: 'Continuous - Not Tracked' AND Product_Group__r.Offering_Type__c =:offeringType ORDER BY Product__r.Description__c ASC
                                    ];
            }
            if(pureSuccessPacklist.size()>0){
                if(offeringType != 'PureCloud'){
                    List<CurrencyType> currencyValue = new List<CurrencyType>([SELECT ConversionRate,Id,IsActive,IsCorporate,IsoCode FROM CurrencyType  Where IsoCode =: CurrencyType Limit 1]);
                    decimal currencyRate;
                    if(currencyValue.size()>0){
                        currencyRate =  currencyValue[0].ConversionRate;    
                    } 
                    for(Product_Group_Item__c pgiObj : pureSuccessPacklist){
                        if(currencyType == 'AUD'){
                            pgiObj.Product__r.Currency_Conversion__c = pgiObj.Product__r.NG1_APAC_ANZ_AUD_Price__c / currencyRate;
                        }else if(currencyType == 'BRL'){
                            pgiObj.Product__r.Currency_Conversion__c = pgiObj.Product__r.NG2_BRAZIL_BRL_Price__c / currencyRate;
                        }else if(currencyType == 'CAD'){
                            pgiObj.Product__r.Currency_Conversion__c = pgiObj.Product__r.NG5_NA_CAD_Price__c/ currencyRate;
                        }else if(currencyType == 'EUR'){
                            pgiObj.Product__r.Currency_Conversion__c = pgiObj.Product__r.NG3_EMEA_EUR_Price__c/ currencyRate;
                        }else if(currencyType == 'GBP'){
                            pgiObj.Product__r.Currency_Conversion__c = pgiObj.Product__r.NG3_EMEA_GBP_Price__c/ currencyRate;
                        }else if(currencyType == 'JPY'){
                            pgiObj.Product__r.Currency_Conversion__c = pgiObj.Product__r.NG4_APAC_JAPAN_YEN_Price__c/ currencyRate;
                        }else if(currencyType == 'NZD'){
                            pgiObj.Product__r.Currency_Conversion__c = pgiObj.Product__r.NG5_NZD_Price__c/ currencyRate;
                        }else if(currencyType == 'USD'){
                            pgiObj.Product__r.Currency_Conversion__c = pgiObj.Product__r.NG5_NA_USD_Price__c/ currencyRate;
                        }else if(currencyType == 'ZAR'){
                            pgiObj.Product__r.Currency_Conversion__c = pgiObj.Product__r.NG5_ZAR_Price__c/ currencyRate;
                        }                
                    }
                }else{
                    Map<String,Decimal> mapTypeMultiplier = new Map<String,Decimal>(); 
                    if(String.isNotBlank(soldToCountry)){
                        Country__c conObj = [SELECT name, New_DAP_Region__c FROM Country__c WHERE Name =: soldToCountry LIMIT 1];
                        system.debug('>>>>>>####### New_DAP_Region__c'+conObj.New_DAP_Region__c);
                        if(conObj.name == 'Brazil'){
                        for(PureSuccess_Region_Multiplier__mdt metaDataTypeMultiplier : [SELECT Type__c, Multiplier__c, Region__c FROM PureSuccess_Region_Multiplier__mdt WHERE Region__c =: conObj.Name]){
                            mapTypeMultiplier.put(metaDataTypeMultiplier.Type__c, metaDataTypeMultiplier.Multiplier__c);
                            system.debug('>>>>#>#### metaDataTypeMultiplier' + metaDataTypeMultiplier);
                        }
                        }else if(conObj.New_DAP_Region__c == 'Developing MEA'){
                            for(PureSuccess_Region_Multiplier__mdt metaDataTypeMultiplier : [SELECT Type__c, Multiplier__c, Region__c FROM PureSuccess_Region_Multiplier__mdt WHERE Region__c = 'MEA']){
                                mapTypeMultiplier.put(metaDataTypeMultiplier.Type__c, metaDataTypeMultiplier.Multiplier__c);
                                system.debug('>>>>#>#### metaDataTypeMultiplier' + metaDataTypeMultiplier);
                            }
                        }else if(conObj.New_DAP_Region__c == 'EMEA' || conObj.New_DAP_Region__c == 'Central & Eastern Europe'){
                            for(PureSuccess_Region_Multiplier__mdt metaDataTypeMultiplier : [SELECT Type__c, Multiplier__c, Region__c FROM PureSuccess_Region_Multiplier__mdt WHERE Region__c = 'Europe']){
                                mapTypeMultiplier.put(metaDataTypeMultiplier.Type__c, metaDataTypeMultiplier.Multiplier__c);
                                system.debug('>>>>#>#### metaDataTypeMultiplier' + metaDataTypeMultiplier);
                            }
                        }else if(conObj.New_DAP_Region__c == 'Greater China'){
                            for(PureSuccess_Region_Multiplier__mdt metaDataTypeMultiplier : [SELECT Type__c, Multiplier__c, Region__c FROM PureSuccess_Region_Multiplier__mdt WHERE Region__c = 'China']){
                                mapTypeMultiplier.put(metaDataTypeMultiplier.Type__c, metaDataTypeMultiplier.Multiplier__c);
                                system.debug('>>>>#>#### metaDataTypeMultiplier' + metaDataTypeMultiplier);
                            }
                        }else if(conObj.New_DAP_Region__c == 'NA'){
                            for(PureSuccess_Region_Multiplier__mdt metaDataTypeMultiplier : [SELECT Type__c, Multiplier__c, Region__c FROM PureSuccess_Region_Multiplier__mdt WHERE Region__c = 'North America']){
                                mapTypeMultiplier.put(metaDataTypeMultiplier.Type__c, metaDataTypeMultiplier.Multiplier__c);
                                system.debug('>>>>#>#### metaDataTypeMultiplier' + metaDataTypeMultiplier);
                            }
                        }else{
                            for(PureSuccess_Region_Multiplier__mdt metaDataTypeMultiplier : [SELECT Type__c, Multiplier__c, Region__c FROM PureSuccess_Region_Multiplier__mdt WHERE Region__c =: conObj.New_DAP_Region__c]){
                                mapTypeMultiplier.put(metaDataTypeMultiplier.Type__c, metaDataTypeMultiplier.Multiplier__c);
                                system.debug('>>>>#>#### metaDataTypeMultiplier' + metaDataTypeMultiplier);
                            }
                        }
                    }
                    for(Product_Group_Item__c pgiObj : pureSuccessPacklist){
                        if(mapTypeMultiplier.containskey(pgiObj.Product__r.PureSuccess_Type__c)){
                            system.debug('>>>>#>#### pgiObj.Product__r.NG5_NA_USD_Price__c' + pgiObj.Product__r.NG5_NA_USD_Price__c);
                            system.debug('>>>>#>#### mapTypeMultiplier.get(pgiObj.Product__r.PureSuccess_Type__c)    ' + mapTypeMultiplier.get(pgiObj.Product__r.PureSuccess_Type__c));
                            pgiObj.Product__r.Currency_Conversion__c = pgiObj.Product__r.NG5_NA_USD_Price__c * mapTypeMultiplier.get(pgiObj.Product__r.PureSuccess_Type__c);
                            system.debug('pgiObj.Product__r.Currency_Conversion__c'+pgiObj.Product__r.Currency_Conversion__c);
                            integer currencyValue = math.mod(integer.valueOf(pgiObj.Product__r.Currency_Conversion__c),100);
                            system.debug('currencyValue '+currencyValue );
                            if(currencyValue!=0){
                                pgiObj.Product__r.Currency_Conversion__c = pgiObj.Product__r.Currency_Conversion__c + 100 - currencyValue;
                                system.debug('pgiObj.Product__r.Currency_Conversion__c'+pgiObj.Product__r.Currency_Conversion__c);
                            }
                        }
                    }
                }
            }
        }
        //system.debug('>>>####### pureSuccessPacklist '+pureSuccessPacklist);
        return pureSuccessPacklist;
    }
    
    
     // get token allocation history for GU Training Units
    @RemoteAction
    global static List<Token_Allocations__c> getTokenAllocationGU(String accId, string allService, string selfService){
        List<Token_Allocations__c> tokenAllocationlist = [SELECT Account__c,CaseAccount__c,Contract_End_Date__c,
                                                            Contract_Start_Date__c,Id,Name,Order__c,CreatedDate,
                                                            Product_Group__c,Product__c,Product__r.Name,Product__r.APN_Number__c,
                                                            Tokens__c,Token_Status__c,
                                                            Order__r.Id,Tokens_Available__c,
                                                            Order__r.Name,
                                                            Order__r.End_User_Name__r.Name,
                                                            Account__r.Name,
                                                            Product_Group__r.Name,Product_Group__r.Id,
                                                            Tokens_Used__c,Is_Consumed__c
                                                            FROM Token_Allocations__c 
                                                            Where
                                                            Account__c =: accId
                                                            AND Token_status__c =: 'Allocated'
                                                            AND Allocation_Type__c =: 'GU Training Units'
                                                            Order by Contract_End_Date__c ]; 
                                                            //AND Tokens__c >=0];
            return tokenAllocationlist;
    }
    
    // get token allocation history for GU Training Units In Progress
    @RemoteAction
    global static List<GU_Entitlement__c> getTokenAllocationGUcancelled(String accId, string allService, string selfService){
        List<GU_Entitlement__c> tokenAllocationlist = [SELECT Certification_Expiration__c,
                                                                 Name,
                                                                 Certified__c,
                                                                 Course_End_Date__c,
                                                                 Course_Location__c,
                                                                 Course_Start_Date__c,
                                                                 End_Customer_Name__c,
                                                                 Cancellation_Date__c,
                                                                 Entitlement_Name__c,
                                                                 Entitlement_Number__c,
                                                                 Entitlement_Type__c,
                                                                 GU_Voucher_Used__c,
                                                                 Partner_Name__c,
                                                                 Service_Contract__c,
                                                                 Service_Contract_Number__c,
                                                                 Status__c,
                                                                 Student_Email__c,
                                                                 Student_Name__c
                                                            from GU_Entitlement__c
                                                            where End_Customer_Name__c=:accId and Status__c =: 'Cancelled'];
            return tokenAllocationlist;
    }
    
    
     // get token allocation history for GU Training Units In Progress
    @RemoteAction
    global static List<GU_Entitlement__c> getTokenAllocationGUInProgress(String accId, string allService, string selfService){
        List<GU_Entitlement__c> tokenAllocationlist = [SELECT Certification_Expiration__c,
                                                                 Name,
                                                                 Certified__c,
                                                                 Course_End_Date__c,
                                                                 Course_Location__c,
                                                                 Course_Start_Date__c,
                                                                 End_Customer_Name__c,
                                                                 Entitlement_Name__c,
                                                                 Entitlement_Number__c,
                                                                 Entitlement_Type__c,
                                                                 GU_Voucher_Used__c,
                                                                 Partner_Name__c,
                                                                 Service_Contract__c,
                                                                 Service_Contract_Number__c,
                                                                 Status__c,
                                                                 Student_Email__c,
                                                                 Student_Name__c
                                                            from GU_Entitlement__c
                                                            where End_Customer_Name__c=:accId and Status__c =: 'In Progress'];
            return tokenAllocationlist;
    }
    
    // get token allocation history for GU Training Units Completed
     @RemoteAction
    global static List<GU_Entitlement__c> getTokenAllocationGUCompleted(String accId, string allService, string selfService){
        List<GU_Entitlement__c> tokenAllocationlist = [SELECT Certification_Expiration__c,
                                                                 Name,
                                                                 Certified__c,
                                                                 Course_End_Date__c,
                                                                 Course_Location__c,
                                                                 Course_Start_Date__c,
                                                                 End_Customer_Name__c,
                                                                 Entitlement_Name__c,
                                                                 Entitlement_Number__c,
                                                                 Entitlement_Type__c,
                                                                 GU_Voucher_Used__c,
                                                                 Partner_Name__c,
                                                                 Service_Contract__c,
                                                                 Service_Contract_Number__c,
                                                                 Status__c,
                                                                 Student_Email__c,
                                                                 Student_Name__c
                                                            from GU_Entitlement__c
                                                            where End_Customer_Name__c=:accId and Status__c =: 'Completed'];
            return tokenAllocationlist;
    }
    
    
    // Get Product Group Items where Product Group is A la Carte
    @RemoteAction
    global static String createNRO(String prodId, String name, String acntId, String ProductID){
        // Get Record Type ID 
        
        try{
            String str = '';
            if(name != null){
                str = name.replace('amp;' , '');
            }
            Id SoureAccountRecordTypeId = Schema.getGlobalDescribe().get('Order__c').getDescribe().getRecordTypeInfosByName().get('Non-Revenue Orders').getRecordTypeId();
            System.debug('This is called inside CreateNRO');
            
            Order__C ord = new Order__C();
            ord.status__c = 'Order Submitted';
            ord.NRO_Type__c = 'Service Element Use';
            ord.Ship_software_via__c = 'No Shipment Required';
            ord.Order_Fulfillment_Email_Receipt__c = 'test@test.com';
            ord.Sold_To_Name__c = acntId;
            //ord.RecordTypeId = '012U0000000M2Tw';
            ord.RecordTypeId = SoureAccountRecordTypeId ; //'012U0000000M2Tw';
            ord.Name = str;
            ord.Ship_To_Name__c = acntId;
            ord.End_User_Name__c = acntId;
            ord.Bill_To_Name__c = acntId;
            ord.Sold_To_Name__c = acntId;
            
            insert ord;
            
            Order_Line_Item__c objOLItem = new Order_Line_Item__c();
            objOLItem.Name = str;
            objOLItem.Product__c = ProductID;
            objOLItem.Order__c = ord.id;
            objOLItem.BigMachines_Quantity__c = 1;
            insert objOLItem; 
            
            Package_Services__c packS = new Package_Services__c();
            packS.Id = prodId;
            packS.Status__c = 'In Progress';
            packS.Order__C = ord.Id;
            packs.Use_Date__c = date.today();
            update packS;
            
            
            
        }catch(Exception ex){
            string   err = ex.getMessage();
            return err;
        }
        
        return 'Success';
    }
    
    //In Case of Al Carte Package User Click on Buy Insert Record in 
    // Token Allocation with below value :-
    // Account ID, ProductID, ProductDescription. Package Type = "Al Carte", Token Value, Status = Allocated
    // Once token Allocation is insert is comlpeted We need to insert record in PureSuccess Package
    // Value AccountId, Product Group = 'A la Carte', Token Status = Allocated,
    // finally insert the record in Package Service
    // Value Status='Allocated', Product = Product Id, Product Group= Product Group Id, 
    
    @RemoteAction
    global static String createPackageALaCarte(String prodId, String name, String acntId, String ProductID, String prdGroup, Decimal tokenValue, String CurrencyType){
        Decimal availableTokenBuy = 0;
        
        try{
            Token_Allocations__c tknAll = new Token_Allocations__c();
            Pure_Success_Package__c purSuccPak = new Pure_Success_Package__c();
            Package_Services__c pkgsrv = new Package_Services__c();
            Decimal currencyRate;
            
            //List<Cloud_Currency_Conversion__c> currencyValue = new List<Cloud_Currency_Conversion__c>([SELECT ConversionRate__c,CurrencyIsoCode,Id,IsoCode__c,LastModifiedDate,Name,NextStartDate__c,StartDate__c FROM Cloud_Currency_Conversion__c where Name =: CurrencyType ORDER BY LastModifiedDate Limit 1]);
            List<CurrencyType> currencyValue = new List<CurrencyType>([SELECT ConversionRate,Id,IsActive,IsCorporate,IsoCode FROM CurrencyType  Where IsoCode =: CurrencyType Limit 1]);
            if(currencyValue.size()>0)
            {
                 currencyRate =  currencyValue[0].ConversionRate;    
            }
            System.debug('PP at Inside Currency Rate for cal'+currencyRate);
            List<Product_Group__c>  prdGrp = new List<Product_Group__c>([Select ID from Product_Group__c Where Id =: prdGroup]);
            for(Product_Group__c pg : prdGrp){
                if(pg != null)
                    tokenValue = tokenValue;//pg.Product__r.NG5_NA_USD_Price__c; //pg.Token_Value__c;
            }
            system.debug('Token Allocation ' + acntId + ' Product ' + ProductID + 'prdGroup  ' + '  prdGrp '+ prdGrp.size());
            tknAll.Account__c = acntId;
            tknAll.Product__c = ProductID;
            tknAll.Product_Group__c = prdGroup;
            tknAll.Tokens__c    = -tokenValue;
            tknAll.Token_Status__c = 'Consumed';
            insert tknAll;
            
            /*
            List<Account> lstCon = [Select Id, Total_Token_Available__c from Account where Id=:acntId];
            if(lstCon[0].Total_Token_Available__c != null)
                    availableToken = lstCon[0].Total_Token_Available__c;
            */
                    
            List<Pure_Success_Package__c> pspkg = new List<Pure_Success_Package__c>([Select Id from Pure_Success_Package__c Where Account__c =:acntId  and Package_type__c =: 'A la Carte Partner'] );
            if(pspkg.size()>0 && pspkg != null){
                 pkgsrv.Status__c = 'Allocated';
                 pkgsrv.Product__c = ProductId;
                 pkgsrv.PureSuccess_Package__c = pspkg[0].id;
                 pkgsrv.Product_Group__c = prdGroup;
                 pkgsrv.Buy_Date__c = date.today();
                 insert pkgsrv;   
            }
            else{
                purSuccPak.Account__c = acntId;
                purSuccPak.Product_group__c = prdGroup;
                PurSuccPak.Token_status__c = 'Allocated';
                PurSuccPak.Package_type__c = 'A la Carte Partner';
                
                insert purSuccPak;
                
                pkgsrv.Status__c = 'Allocated';
                pkgsrv.Product__c = ProductId;
                pkgsrv.PureSuccess_Package__c = purSuccPak.id;
                pkgsrv.Product_Group__c = prdGroup;
                pkgsrv.Buy_Date__c = date.today();
    
                insert pkgsrv;
            
            }
            
            List<Account> lstAcc = [Select Id, Total_Token_Available__c from Account where Id=:acntId]; 
            
            if(lstAcc.size() > 0)
                    availableTokenBuy = lstAcc[0].Total_Token_Available__c;
        }catch(Exception ex){
            string   err = ex.getMessage();
            return err;
        }
        return 'Success:'+availableTokenBuy;
    }
    //Get the Token Consumption record for the particular Token 
    @RemoteAction
    global static List<Token_Consumption__c> getTokenConsumptionFortknAllc(String tknAllcId){
        System.debug('::::: Token ');
        List<Token_Consumption__c> tknConsume = [Select Name,Id,Status__c,Token_Allocation__c,
                                                Token_Allocation__r.Name,Tokens__c, Product__c,
                                                Product__r.Description__c,CreatedDate
                                                FROM Token_Consumption__c 
                                                WHERE 
                                                Token_Allocation__c =: tknAllcId
                                                ORDER BY Name ASC ];
        return tknConsume;
    
    }
    // Get Token Allocation Detail For Partner
    @RemoteAction
    global static List<Token_Allocations__c> getTokenAllocation(String accId){
       // Map<Id, Pure_Success_Package__c> mapPackage = new Map<Id, Pure_Success_Package__c>([Select Id from Pure_Success_Package__c where Account__c =:accId and Package_Type__c =: 'A la Carte']);
        List<Token_Allocations__c> tokenAllocationlist = [SELECT Account__c,CaseAccount__c,Contract_End_Date__c,
                                                            Contract_Start_Date__c,Id,Name,Order__c,CreatedDate,
                                                            Product_Group__c,Product__c,Product__r.Name,Product__r.APN_Number__c,
                                                            Tokens__c,Token_Status__c,Tokens_Used__c,Tokens_Available__c,
                                                            Order__r.Id,Product__r.Description__c,Is_Consumed__c,
                                                            Order__r.Name,
                                                            Order__r.End_User_Name__r.Name,
                                                            Account__r.Name,
                                                            Product_Group__r.Name
                                                            FROM Token_Allocations__c 
                                                            Where
                                                            Account__c =: accId
                                                            AND Token_status__c =: 'Allocated'
                                                            AND Allocation_Type__c = 'Subscription Token'
                                                            Order by Contract_End_Date__c]; 
                                                            //AND Tokens__c >=0];
            return tokenAllocationlist;
    }
}