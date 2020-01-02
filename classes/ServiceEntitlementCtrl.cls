/***************************************************************************************************
* 
*  Class Name      :   ServiceEntitlementCtrlTC
*  Description     :   This class is used to control the Service Entitlement_TC Page
*  Author          :   R Systems
* 
****************************************************************************************************/
global without sharing class ServiceEntitlementCtrl {
    
    
    global String accntId{get;set;}
    global Decimal currencyRate{get;set;} 
    global Decimal availableToken{get;set;}
    global Decimal availableTokenGU{get;set;}
    global Boolean isBuy{get;set;}
    global String accountName{get;set;}
    global string serviceValue{get;set;}
    global string showAllServiceElement {get;set;}
    global string showSelfServiceElement {get;set;}
    global string contactName {get; set;}
    public String currencyType {get;set;} //added by priyank
    public String sOfferingType{get;set;} //added by priyank on 14 dec 2018, on request by vinay.
    public String offeringTypeName{get;set;}
    public List<String> offeringTypeList;
    
    global ServiceEntitlementCtrl (){
        
        accntId =  apexpages.currentpage().getparameters().get('accId');
        availableToken = 0;
        availableTokenGU = 0; 
        isBuy = false;
        // If Opening from the Portal then get the contact Id 
        id id1 = Userinfo.getUserId();
        System.debug('Which User====='+id1);
        List<User>  lstUser = [Select Id, ContactId  from User where Id =: Id1];
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        System.debug('Display te contact Id==='+lstUser);
        // Get from User Contact Id
        if(lstUser.size() > 0 && lstUser[0].ContactId != null && accntId == null){
            
            List<Contact> lstCon = [Select Id, AccountId, Account.Total_Token_Available__c,All_Service_Elements_Access__c, Self_Service_Elements_Access__c from Contact where Id=:lstUser[0].ContactId];
              
            if(lstCon.size()  > 0)
            {
                accntId = lstCon[0].AccountId;
                showAllServiceElement = String.valueOf(lstCon[0].All_Service_Elements_Access__c);
                showSelfServiceElement = String.valueOf(lstCon[0].Self_Service_Elements_Access__c);
             }
             System.debug('All Service ====='+showAllServiceElement +'====ShowService Element:::::'+showSelfServiceElement);
         }
         List<Contact> cont = new List<Contact>([Select Name from Contact Where AccountId =:accntId AND PureSuccess_Main_Contact__c = True]);
           if(cont != null && cont.size()>0)
               contactName = cont[0].Name;
         List<Account> lstAcc = [Select Id, Total_Token_Available__c,Name,Advisor__c,Total_GU_Training_Units__c from Account where Id=:accntId];       
         if(lstAcc.size()>0)
             accountName = lstAcc[0].Name;
                System.debug('Account'+ accntId);
                List<Product_Group__c> lst = [Select Id from Product_Group__c where Type__c =: 'A la Carte'];
                
                if(lstAcc[0].Total_Token_Available__c != null)
                {
                    availableToken = lstAcc[0].Total_Token_Available__c;
                    availableTokenGU = lstAcc[0].Total_GU_Training_Units__c;
                 }
                    //if(lst.size() > 0 && availableToken < lst[0].Token_Value__c)
                      if(availableToken<0 || availableToken == 0)
                        isBuy = true;
         CurrencyType = '';           
         List<Token_Allocations__c> tka = new List<Token_Allocations__c>([Select ID, Currency__c from Token_Allocations__c where Account__c =: accntid AND Currency__c != NULL Limit 1]);                          
          System.debug('PP Currency Type===='+tka);
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
              currencyRate =  currencyValue[0].ConversionRate;    
          }  
          //Priyank added below code
          offeringTypeList = new List<String>();
          offeringTypeName ='';
          for(Pure_Success_Package__c p: [Select Order__r.Order_Category__c FROM Pure_Success_Package__c 
                                    Where Token_Status__c =: 'Allocated' 
                                    AND Account__r.Id =: accntId
                                    AND Package_Type__c =: 'Pure Success' and Order__c!=null ORDER BY Product__r.Description__c ASC]){
          if(!offeringTypeName.contains(p.Order__r.Order_Category__c) ){
              if(p.Order__r.Order_Category__c == 'PureCloud-Cloud Order' && !offeringTypeName.contains('PureCloud')){
                  offeringTypeName = offeringTypeName+ '{ itemLabel:"' + 'PureCloud' +'"' +','+
                                                  'itemValue:"' + 'PureCloud' +'"'+'}'+',';
                  offeringTypeList.add('PureCloud');
              }else if(p.Order__r.Order_Category__c == 'PureConnect-Cloud Order' && !offeringTypeName.contains('PureConnect Cloud')){
                  offeringTypeName = offeringTypeName+ '{ itemLabel:"' + 'PureConnect Cloud' +'"' +','+
                                                  'itemValue:"' + 'PureConnect Cloud' +'"'+'}'+',';
                  offeringTypeList.add('PureConnect Cloud');
              }else if((p.Order__r.Order_Category__c == 'PureEngage-Cloud Order' || p.Order__r.Order_Category__c == 'Business Edition') && !offeringTypeName.contains('PureEngage Cloud')){
                  offeringTypeName = offeringTypeName+ '{ itemLabel:"' + 'PureEngage Cloud' +'"' +','+
                                                  'itemValue:"' + 'PureEngage Cloud' +'"'+'}'+',';
                  system.debug('>>>>######  '+offeringTypeName);
                  offeringTypeList.add('PureEngage Cloud');
              }else if(p.Order__r.Order_Category__c != 'PureConnect-Cloud Order' && p.Order__r.Order_Category__c != 'PureCloud-Cloud Order' && p.Order__r.Order_Category__c != 'Business Edition' && p.Order__r.Order_Category__c != 'PureEngage-Cloud Order'){
                  offeringTypeName = offeringTypeName+ '{ itemLabel:"' + p.Order__r.Order_Category__c +'"' +','+
                                                  'itemValue:"' + p.Order__r.Order_Category__c +'"'+'}'+',';
                  
                  offeringTypeList.add(p.Order__r.Order_Category__c);
              }
           }
        }
        system.debug('>>>>######  '+offeringTypeList);
        if(!String.isBlank(offeringTypeName)){
            offeringTypeName = offeringTypeName.substring(0, offeringTypeName.length() - 1);
        }
        if(offeringTypeList.size()>0){
            sOfferingType = offeringTypeList[0] ;// added by priyank on 14 dec 2018, on request by vinay.
            system.debug('>>>>######  '+sOfferingType);
        }
        //Priyank code end.
    }
    
    
    @RemoteAction
    global static Decimal fetchCounter(String acntId) {
            
            Decimal availableToken = 0.0;
            List<Account> lstAcc = [Select Id, Total_Token_Available__c from Account where Id=:acntId]; 
            
            if(lstAcc.size() > 0)
                    availableToken = lstAcc[0].Total_Token_Available__c;
            
            System.debug('@Inside fetchCounter ' + availableToken);
            return availableToken;
    }
    
   
    // Get Pure Success Package
    @RemoteAction
    global static List<Pure_Success_Package__c> pureSuccessPacklist(String accId , string allService, string selfService){
                
        List<Pure_Success_Package__c> pureSuccessPacklist;
       /* if(allService == 'true' || allService == '' || selfService == '')
        {*/                  
            pureSuccessPacklist = [Select Account__r.Name,Account__r.Total_Token_Available__c,
                                        Contract_End_Date__c,Contract_Start_Date__c,
                                        CreatedDate,Id,Name,Order__c,Product_Group__c,Product__r.Description__c,
                                        Tokens__c,Token_Status_Expired__c,Token_Status__c,
                                        DaysToexpiration__c,Product_Group__r.Name,Service_Contract_No__c, Order__r.Name,
                                        Product_Group__r.Id,Order__r.PO_Number__c,Available_Service_element__c,Account__r.Advisor_Name__c
                                        ,Order__r.End_User_Name__r.Name,
                                        Order__r.Order_Category__c,Order__r.Contract_Lookup__c
                                        FROM Pure_Success_Package__c 
                                        Where Token_Status__c =: 'Allocated' 
                                        AND Account__r.Id =: accId
                                        AND Package_Type__c =: 'Pure Success' AND Product_Group__r.Name != NULL AND order__c!=null ORDER BY Product__r.Description__c ASC];
        //Added Order attribute null check by Kartik for Fixing Loading of Dashboard                                
        /*} 
        else if ((allService == 'false' || allService == '') && (selfService == 'true' || selfService == ''))
        {
             pureSuccessPacklist = [Select Account__r.Name,Account__r.Total_Token_Available__c,
                                        Contract_End_Date__c,Contract_Start_Date__c,
                                        CreatedDate,Id,Name,Order__c,Product_Group__c,Product__r.Description__c,
                                        Tokens__c,Token_Status_Expired__c,Token_Status__c,
                                        DaysToexpiration__c,Product_Group__r.Name,Service_Contract_No__c, Order__r.Name,
                                        Product_Group__r.Id,Order__r.PO_Number__c,Available_Service_element__c,Account__r.Advisor_Name__c
                                        ,Order__r.End_User_Name__r.Name,Product__c,Product__r.Consumption_Model__c
                                        FROM Pure_Success_Package__c 
                                        Where Token_Status__c =: 'Allocated' 
                                        AND Account__r.Id =: accId
                                        AND Package_Type__c =: 'Pure Success'
                                        AND Product__r.Consumption_Model__c =: 'Continuous - Not Tracked'];            
        }*/
        return pureSuccessPacklist;

    }
    
    // get token allocation history
    @RemoteAction
    global static List<Token_Allocations__c> getTokenAllocation(String accId, string allService, string selfService){
        List<Token_Allocations__c> tokenAllocationlist = [SELECT Account__c,CaseAccount__c,Contract_End_Date__c,
                                                            Contract_Start_Date__c,Id,Name,Order__c,CreatedDate,
                                                            Product_Group__c,Product__c,Product__r.Name,Product__r.APN_Number__c,
                                                            Tokens__c,Token_Status__c,
                                                            Order__r.Id,Tokens_Available__c,
                                                            Order__r.Name,
                                                            Order__r.End_User_Name__r.Name,
                                                            Account__r.Name,
                                                            Product_Group__r.Name,Product_Group__r.Id,
                                                            Tokens_Used__c,Is_Consumed__c,ContractStart_Date__C,ContractEnd_Date__C
                                                            FROM Token_Allocations__c 
                                                            Where
                                                            Account__c =: accId
                                                            AND Token_status__c = 'Allocated'
                                                            AND Allocation_Type__c = 'Subscription Token'
                                                            Order by Contract_End_Date__c ]; 
                                                            //AND Tokens__c >=0];
            return tokenAllocationlist;
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
                                                            Tokens_Used__c,Is_Consumed__c, ContractStart_Date__C,ContractEnd_Date__c
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
    
    // Get Package Services Consumed for Related PureSuccess Package
    @RemoteAction
    global static List<Package_Services__c> getPackageServicesConsumed(String packId , string allService, string selfService){
       List<Package_Services__c>  pkgSrvlist;
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
    }
    
    // Get Package Services availbale to Allocated or In Progress
    @RemoteAction
    global static List<Package_Services__c> getPackageServicesAvailable(String packId, string allService, string selfService){
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
    }
    
    // Get Package Service Data A la Carte consumed
    @RemoteAction
    global static List<Package_Services__c> getConsumedAlaCarte(String accId, string allService, string selfService,string offeringType){
        List<Package_Services__c> pureSuccessPacklist = new List<Package_Services__c>();
        Map<Id, Pure_Success_Package__c> mapPackage = new Map<Id, Pure_Success_Package__c>([Select Id from Pure_Success_Package__c where Account__c =:accId and Package_Type__c =: 'A la Carte']);
       /* if(allService == 'true' || allService == '')
        {*/
            pureSuccessPacklist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                                    Id,Name,Product_Group__c,Product__c,
                                    PureSuccess_Package__c,Status__c,Case__c,
                                    Product__r.Description,Product__r.Name,Case__r.CaseNumber
                                    ,PureSuccess_Package__r.Package_type__c,
                                    Product_Group__r.Name
                                    ,Product__r.APN_Number__c,
                                    Product__r.Consumption_Model__c,
                                    Product__r.Description__c,
                                    Order_Name__c,
                                    Order__c,
                                    OrderId__c,Consume_service__c,Consume_service__r.Id, Consume_Service_Name__c,Consume_Service_Id__c
                                    
                                    FROM Package_Services__c
                                    Where Status__c IN  ('Consumed')
                                    AND PureSuccess_Package__r.Package_Type__c =: 'A la Carte'
                                    and PureSuccess_Package__c In: mapPackage.keyset() and Product_Group__r.Offering_Type__c =:offeringType ORDER BY Product__r.Description__c ASC];
        /*}
        else if ((allService == 'false' || allService == '') && (selfService == 'true' || selfService == ''))
        {
            pureSuccessPacklist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                                    Id,Name,Product_Group__c,Product__c,
                                    PureSuccess_Package__c,Status__c,Case__c,
                                    Product__r.Description,Product__r.Name,Case__r.CaseNumber
                                    ,PureSuccess_Package__r.Package_type__c,
                                    Product_Group__r.Name
                                    ,Product__r.APN_Number__c,
                                    Product__r.Description__c,
                                    Order_Name__c,
                                    Order__c,
                                    OrderId__c,Product__r.Consumption_Model__c
                                    FROM Package_Services__c
                                    Where Status__c IN  ('Consumed')
                                    AND PureSuccess_Package__r.Package_Type__c =: 'A la Carte'
                                    and PureSuccess_Package__c In: mapPackage.keyset()
                                    AND Product__r.Consumption_Model__c =: 'Continuous - Not Tracked'];
        }*/
        return pureSuccessPacklist;

    }
    
    // Get Package Service Data A la Carte expired -Below method added by Priyank
    @RemoteAction
    global static List<Package_Services__c> getExpiredAlaCarte(String accId, string allService, string selfService,string offeringType){
        List<Package_Services__c> pureSuccessPacklist = new List<Package_Services__c>();
        Map<Id, Pure_Success_Package__c> mapPackage = new Map<Id, Pure_Success_Package__c>([Select Id from Pure_Success_Package__c where Account__c =:accId and Package_Type__c =: 'A la Carte']);
       /* if(allService == 'true' || allService == '')
        {*/
            pureSuccessPacklist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                                    Id,Name,Product_Group__c,Product__c,
                                    PureSuccess_Package__c,Status__c,Case__c,
                                    Product__r.Description,Product__r.Name,Case__r.CaseNumber
                                    ,PureSuccess_Package__r.Package_type__c,Product_Group__r.Offering_Type__c,
                                    Product_Group__r.Name,End_Date__c
                                    ,Product__r.APN_Number__c,
                                    Product__r.Consumption_Model__c,
                                    Product__r.Description__c,
                                    Order_Name__c,
                                    Order__c,
                                    OrderId__c,Consume_service__c,Consume_service__r.Id, Consume_Service_Name__c,Consume_Service_Id__c
                                    
                                    FROM Package_Services__c
                                    Where Status__c IN  ('Expired')
                                    AND PureSuccess_Package__r.Package_Type__c =: 'A la Carte'
                                    and PureSuccess_Package__c In: mapPackage.keyset() and Product_Group__r.Offering_Type__c =:offeringType ORDER BY Product__r.Description__c ASC];
        
        return pureSuccessPacklist;

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
        
        }*/
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
    
    // Get Package Service Data A la Carte In Progress and Allocated
    @RemoteAction
    global static List<Package_Services__c> getAlocatedAlaCarte(String accId , string allService , string selfService, string offeringType){
        Map<Id, Pure_Success_Package__c> mapPackage = new Map<Id, Pure_Success_Package__c>([Select Id from Pure_Success_Package__c where Account__c =:accId and Package_Type__c =: 'A la Carte']);
        List<Package_Services__c> pureSuccessPacklist;
        /*if(allService == 'true' || allService == '')
        { */
            pureSuccessPacklist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                                Id,Name,Product_Group__c,Product__c,
                                PureSuccess_Package__c,Status__c,Case__c,Case__r.Id,
                                Product__r.Description,Product__r.Name, Product__r.Description__c
                                ,PureSuccess_Package__r.Package_type__c ,Order__r.Original_Parent_Order1__c,
                                Product_Group__r.Name
                                ,Product__r.APN_Number__c,
                                Order_Name__c,Start_Date__c,End_Date__c,Product_Group__r.Offering_Type__c,
                                Order__r.Id,Order__r.Order_Category__c,PureSuccess_Package__r.Order__r.Original_Parent_Order1__c,
                                PureSuccess_Package__r.Order__r.Order_Category__c,PureSuccess_Package__r.Order__r.Date_Accepted__c,
                                OrderID__c,Case_Name__c,Consume_service__c,Consume_service__r.Id, Consume_Service_Name__c,Consume_Service_Id__c
                                FROM Package_Services__c
                                Where Status__c IN   ('In Progress','Allocated', 'Available','Order Submitted')
                                AND PureSuccess_Package__r.Package_Type__c =: 'A la Carte'
                                and PureSuccess_Package__c In: mapPackage.keyset() and Product_Group__r.Offering_Type__c =:offeringType ORDER BY Product__r.Description__c ASC];
        /*}
        else if ((allService == 'false' || allService == '') && (selfService == 'true' || selfService == ''))
        {
            pureSuccessPacklist = [SELECT ConnectionReceivedId,CurrencyIsoCode,
                                Id,Name,Product_Group__c,Product__c,
                                PureSuccess_Package__c,Status__c,Case__c,Case__r.Id,
                                Product__r.Description,Product__r.Name, Product__r.Description__c
                                ,PureSuccess_Package__r.Package_type__c ,
                                Product_Group__r.Name
                                ,Product__r.APN_Number__c,
                                Order_Name__c,
                                Order__r.Id,
                                OrderID__c,Case_Name__c,Product__r.Consumption_Model__c
                                FROM Package_Services__c
                                Where Status__c IN   ('In Progress','Allocated', 'Available','Order Submitted')
                                AND PureSuccess_Package__r.Package_Type__c =: 'A la Carte'
                                and PureSuccess_Package__c In: mapPackage.keyset()
                                AND Product__r.Consumption_Model__c =: 'Continuous - Not Tracked'];
        }*/
        
        system.debug('>>>>### after use    '+pureSuccessPacklist);
        return pureSuccessPacklist;

    }
    
    // Get Product Group Items where Product Group is A la Carte
    @RemoteAction
    global static List<Product_Group_Item__c> getProductGroupItems(String accId,string allService, string selfService, string currencyType,string offeringType){
        string soldToCountry;
        List<Product_Group_Item__c> pureSuccessPacklist = new List<Product_Group_Item__c>();
    //More filters as per discussion with Vinay 5/21
    //Include License_FYM_detail__c = 'Subscription Order'
        //Get Order Category of this account from Order
        system.debug('++++>>>> '+offeringType);
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
        string strProductGroupName = 'PureSuccess A la Carte';
        
        //Get first orders
        String sOrderCategory = offeringType; //=' PureEngage Subscription';
        
        if(lstOrder.size() == 1){
        
            if(lstOrder[0].End_User_Name__r.Recordtype.name == 'Enterprise - Business Partner')
                strProductGroupName = 'Partner PureSuccess A la Carte';
            
    //Tranform Business Edition for Pure Engage Cloud as per discussion with Vinay 5/21
    
            if(lstOrder[0].Order_category__c == 'Business Edition')    
                sOrderCategory = 'PureEngage Cloud';
            /*else
                sOrderCategory = lstOrder[0].Order_category__c;*/
        }
        
        
        
        
        //Map<Id, Product_Group__c> mapPackage = new Map<Id, Product_Group__c>([Select Id from Product_Group__c where Offering_Type__c =: sOrderCategory and Name =: strProductGroupName limit 1]);
        
        List<Product_Group__c> lstProdGroup = [Select Id from Product_Group__c where Offering_Type__c =: sOrderCategory and Name =: strProductGroupName limit 1];
        
        if(lstProdGroup.size() > 0){
            string ProdGroup = lstProdGroup[0].id;
            
            /*if(allService == 'true' || allService == '')
            {*/
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
                                    Product__c
                                    FROM Product_Group_Item__c
                                    Where Product_Group__c =: ProdGroup and Product_Group__r.Offering_Type__c =: offeringType and Remove_From_Service_Catalog__c = false ORDER BY Product__r.Description__c ASC];
              /*}
              else if ((allService == 'false' || allService == '') && (selfService == 'true' || selfService == ''))
              {
                  pureSuccessPacklist = [SELECT   APN_Number__c,
                                        Name,
                                        Product_Group__c,
                                        Product__r.Description__c,
                                        Product_Group__r.Name,
                                        Product__r.Description,
                                        Product__r.Name,
                                        Product__r.NG5_NA_USD_Price__c,
                                        Product__c,Product__r.Consumption_Model__c
                                        FROM Product_Group_Item__c
                                        Where Product_Group__c In: mapPackage.keyset()
                                        AND Product__r.Consumption_Model__c =: 'Continuous - Not Tracked'];
              }*/
            
            //Added by Priyank as request by Vinay. Date-12/Dec/2018
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
        return pureSuccessPacklist;
        //priyank code end.
    }

    //Get the token allocation record for the A la carte purchase
    @RemoteAction
    global static List<Token_allocations__c> getTokenAllocationForBuy(String accId, string allService, string selfService){
        List<Token_allocations__c> tknAl;
        Date todayDate = date.today();
        /*if(allService == 'true' || allService == '')
        {*/
            tknAl = [Select Account__c,Contract_End_Date__c,Contract_Start_Date__c,Currency__c,Id,Is_Consumed__c,
                        Name,Product_Group__c,Tokens_Available__c,Tokens_Used__c,Tokens__c,Token_Status__c,
                        Service_Contract_No__c, Product__c,Product__r.Consumption_Model__c,Contract_No__c, Order__r.Name
                        FROM Token_Allocations__c 
                        WHERE 
                        Account__c =: accId 
                        AND Token_Status__c =: 'Allocated' 
                        AND Tokens_Available__c >=: 1 
                        AND Contract_End_date__c >=: todayDate
                        AND Allocation_Type__c != : 'GU Training Units'
                        ORDER BY Contract_End_Date__c ASC ];
        /*}
        else if ((allService == 'false' || allService == '') && (selfService == 'true' || selfService == ''))
        {
            tknAl = [Select Account__c,Contract_End_Date__c,Contract_Start_Date__c,Currency__c,Id,Is_Consumed__c,
                        Name,Product_Group__c,Tokens_Available__c,Tokens_Used__c,Tokens__c,Token_Status__c,
                        Service_Contract_No__c, Product__c,Product__r.Consumption_Model__c
                        FROM Token_Allocations__c 
                        WHERE 
                        Account__c =: accId 
                        AND Token_Status__c =: 'Allocated' 
                        AND Tokens_Available__c >=: 1 
                        AND Product__r.Consumption_Model__c =: 'Continuous - Not Tracked'
                        ORDER BY Contract_End_Date__c ASC ];
        }*/
        return tknAl;
    
    }
    
    //Get the Token Consumption record for the particular Token 
    @RemoteAction
    global static List<Token_Consumption__c> getTokenConsumptionFortknAllc(String tknAllcId){
        System.debug('::::: Token ');
        List<Token_Consumption__c> tknConsume = [Select Name,Id,Status__c,Token_Allocation__c,Token_Allocation__r.Name,Tokens__c
                                                ,Product__c,Product__r.Name,
                                                Product__r.Description__c,CreatedDate,gu_entitlement__r.Entitlement_Name__c                                                
                                                FROM Token_Consumption__c 
                                                WHERE 
                                                Token_Allocation__c =: tknAllcId
                                                ORDER BY Name ASC ];
        return tknConsume;
    
    }
    // Get Product Group Items where Product Group is A la Carte
    @RemoteAction
    global static String createNRO(String prodId, String name, String acntId, String ProductID, String prdGroup, Decimal tokenValue){
        // Get Record Type ID 
        Decimal availableToken;
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
            ord.Order_Fulfillment_Email_Receipt__c = 'testxyz@test.com';
            ord.Sold_To_Name__c = acntId;
            //ord.RecordTypeId = '012U0000000M2Tw';
            ord.RecordTypeId = SoureAccountRecordTypeId ; //'012U0000000M2Tw';
            ord.Name = str;
            ord.Ship_To_Name__c = acntId;
            ord.End_User_Name__c = acntId;
            ord.Bill_To_Name__c = acntId;
            ord.Sold_To_Name__c = acntId;
            
            insert ord;
            
            System.debug('PP -- Order Creation Done'+ord);
            
            Order_Line_Item__c objOLItem = new Order_Line_Item__c();
            objOLItem.Name = str;
            objOLItem.Product__c = ProductID;
            objOLItem.Order__c = ord.id;
            objOLItem.BigMachines_Quantity__c = 1;
            insert objOLItem; 
            System.debug('PP -- Order Creation Done'+ord);
          
            List<Account> lstCon = [Select Id, Total_Token_Available__c from Account where Id=:acntId];
            if(lstCon[0].Total_Token_Available__c != null)
                    availableToken = lstCon[0].Total_Token_Available__c;
            System.debug('PP token availableToken++'+availableToken);
        }catch(Exception ex){
            System.debug('PP Inside CReate NRO Catch===='+ex.getMessage());
            string   err = ex.getMessage();
            return err;
        }
        
        return 'Success:'+availableToken;
    }
    
    // Create the Token consumption record for the specific record
    // PackageService ID
    // Token Allocation
    // Token - Service element
    // Status - In Progress
    // Order - 
    //String prodId, String name, String acntId, String ProductID, String prdGroup, Decimal tokenValue
    public class test{
        Integer id;
        String tokenValue;
    }
    

    @RemoteAction
    global static String CreateTokenConsumption(String prodId, String name, String acntId, String ProductID, String prdGroup, String tokencollection,String Servicetoken,string offeringType, string tokenId)
    {
        System.debug('==Pankaj Pandey - CreateTokenConsumption===' +tokencollection);
        Decimal availableToken = 0;        
        system.debug('prodId---> '+prodId+'ProductId----> '+ProductID+'tokenId----> '+tokenId);
        
        try{
            string serviceValue = Servicetoken;
            String [] tokencoll;
            Decimal tokenvalue=0.0;
            System.debug('Inside Order Creation');            
            Token_Allocations__c tknAll = new Token_Allocations__c();
            Pure_Success_Package__c purSuccPak = new Pure_Success_Package__c();
            Package_Services__c pkgsrv = new Package_Services__c();
            Token_Consumption__c tknconsume = new Token_Consumption__c();
            System.debug('Inside Order Creation = 2');
            List<Token_Consumption__c> tknCon = new List<Token_Consumption__c>();
            List<Token_Allocations__c> tknAllo = new List<Token_Allocations__c> ();
            Decimal currencyRate;
            if(tokencollection != null)
                tokencoll = tokencollection.split(';');
            system.debug(':::::=== token Collection::::::'+tokencoll);
            
           
             System.debug('Inside Order Creation = 5');
            
            
            for(Integer a = 0; a< tokencoll.size();a++)
            {
                System.debug(tokencoll[a].substringBefore('-'));
                System.debug(tokencoll[a].substringAfter('-'));
                tknconsume = new Token_Consumption__c();
                tknconsume.Tokens__c = decimal.valueOf(tokencoll[a].substringAfter('-')); //tknAl.Tokens_Available__c;
                tknconsume.Token_Allocation__c = tokencoll[a].substringBefore('-');
                tknconsume.Product__c = ProductID;
                tknconsume.Status__c = 'In Progress';
                tknCon.add(tknconsume);
                System.debug('==PP Token left Over== '+tokenValue);
                //tknAllo.add(tknAl);
                //insert tknconsume;
            }
            
            if(tknCon.size()>0){
                insert tknCon;
            }
           
            List<Product_Group__c>  prdGrp = new List<Product_Group__c>([Select ID,Token_Value__c from Product_Group__c Where Id =: prdGroup]);
            for(Product_Group__c pg : prdGrp){
                if(pg != null){
                    tokenValue = tokenValue;//pg.Token_Value__c;
                    }
            }
            
            Boolean IsAllConsume = false;            
            System.debug('PP Token cons===='+tknCon.size());
            
            List<Account> lstCon = [Select Id, Total_Token_Available__c from Account where Id=:acntId];
            if(lstCon[0].Total_Token_Available__c != null)
                    availableToken = lstCon[0].Total_Token_Available__c;
            
             String str = '';
                    if(name != null){
                        str = name.replace('amp;' , '');}
                        
            List<Product2> objProduct = [select ID,description__C from Product2 where id =: ProductId];
                    
            /*List<Pure_Success_Package__c> pspkg = new List<Pure_Success_Package__c>([Select Id from Pure_Success_Package__c Where Account__c =:acntId  and Package_type__c =: 'A la Carte'] );
            if(pspkg.size()>0 && pspkg != null){commented by Priyank as requested by vinay*/
            /*}
            else
            {*/
                    purSuccPak.Account__c = acntId;
                    purSuccPak.Product_group__c = prdGroup;
                    PurSuccPak.Token_status__c = 'Allocated';
                    PurSuccPak.Package_type__c = 'A la Carte';
                    purSuccPak.Product__c = ProductId;
                    insert purSuccPak;
                    
                    pkgsrv.Status__c = 'Order Submitted';
                    pkgsrv.Product__c = ProductId;
                    pkgsrv.PureSuccess_Package__c = purSuccPak.id;
                    pkgsrv.Product_Group__c = prdGroup;
                    pkgsrv.Buy_Date__c = date.today();
                    pkgsrv.Name = objProduct[0].description__c;
                    pkgsrv.Product_Group_Item__c = prodId;
    
                    insert pkgsrv;
           // }
            System.debug('PP Inside Order CreationPP +++');
            if(offeringType=='PureEngage Cloud'){
                offeringType = 'PureEngage';
            }
            if(offeringType=='PureConnect Cloud'){
                offeringType = 'PureConnect';
            }
            system.debug('acntId-->'+acntId+'offeringType-->'+offeringType);
           // List<Order__c> lstOrder = new List<Order__c>([Select Id from order__c Where End_User_Name__c =:acntId and offering_type__c =:offeringType and Original_Parent_Order1__c = Null]);              
            List<Token_Allocations__c> lstTokenAlloc = new List<Token_Allocations__c>([Select Id,Order__r.Name,Order__r.End_User_Name__c,Order__c FROM Token_Allocations__c WHERE id =:tokenId]);
            Id SoureAccountRecordTypeId = Schema.getGlobalDescribe().get('Order__c').getDescribe().getRecordTypeInfosByName().get('Non-Revenue Orders').getRecordTypeId();
            System.debug('This is called inside CreateNRO');
        
            Order__C ord = new Order__C();
            ord.status__c = 'Order Submitted';
            ord.NRO_Type__c = 'Service Element Use';
            ord.Ship_software_via__c = 'No Shipment Required';
            ord.Order_Fulfillment_Email_Receipt__c = 'testABC@test.com';
            ord.Sold_To_Name__c = acntId;
            ord.RecordTypeId = SoureAccountRecordTypeId ; 
            ord.Maintenance_Start__c = System.today();
            ord.Maintenance_End__c = System.today().addYears(1);//Changed from 2yrs to 1yr - 01/02/2019 - Vinay
            ord.Name = str;
            ord.Ship_To_Name__c = acntId;
            ord.End_User_Name__c = acntId;
            ord.Bill_To_Name__c = acntId;
            ord.Sold_To_Name__c = acntId; 
            ord.Date_Accepted__c = System.Now();
            ord.Original_Parent_Order1__c = lstTokenAlloc[0].order__c;               
            insert ord;           
            Order_Line_Item__c objOLItem = new Order_Line_Item__c();
            objOLItem.Name = str;
            objOLItem.Product__c = ProductID;
            objOLItem.Order__c = ord.id;
            objOLItem.BigMachines_Quantity__c = 1;
            insert objOLItem; 
                        
            pkgsrv.Order__C = ord.Id;
            update pkgsrv;
            purSuccPak.Order__C = ord.Id;
            update purSuccPak;
            
            //Below code added by priyank as discussed with vinay we need the staus of order to be completed.
            List<Order__c> ord1 = new List<Order__c>([Select id,status__c from Order__c where Id =: ord.id LIMIT 1]); 
            ord1[0].status__c = 'Approved';
            update ord1;
            List<Order__c> ord2 = new List<Order__c>([Select id,status__c from Order__c where Id =: ord1[0].id LIMIT 1]);
            ord2[0].status__c = 'Completed';
            update ord2;
            system.debug('Order:-->'+ord+' Order 2:--->'+ord1+' Order 3--->'+ord2);
            //Priyank code end.
            List<Token_Consumption__c> lsttknc = new List<Token_Consumption__c>();
            for(Token_Consumption__c tkc : tknCon)
            {
                tkc.Order__c = ord.Id;
                tkc.Package_Services__c = pkgsrv.Id;
                lsttknc.add(tkc);
            }
            
            if(lsttknc.size()>0)
            {
                update lsttknc;
            }
            System.debug('PP === Size of Token Allocation '+tknAllo);
            if(tknAllo.size()>0)
            {    
                List<Token_allocations__c> lsttk = new List<Token_allocations__c>();
                for(Token_allocations__c tk : tknAllo)
                {
                    tk.Token_Status__c = 'In Progress';
                    lsttk.add(tk);
                }
                
                if(lsttk.size()>0)
                    update tknAllo;            
            }
            List<Account> lstAcc = [Select Id, Total_Token_Available__c from Account where Id=:acntId]; 
            
            if(lstAcc.size() > 0)
                    availableToken = lstAcc[0].Total_Token_Available__c;
                
            system.debug('>>>>>>>>>>>>################pkgsrv'+pkgsrv);
        }catch(Exception ex){
            System.debug('PP Inside Catch ++++'+ex.getMessage());
            string   err = ex.getMessage();
            return err;
        }
        
        return 'Success:';
    }
    
    //In Case of Al Carte Package User Click on Buy Insert Record in 
    // Token Allocation with below value :-
    // Account ID, ProductID, ProductDescription. Package Type = "Al Carte", Token Value, Status = Allocated
    // Once token Allocation is insert is comlpeted We need to insert record in PureSuccess Package
    // Value AccountId, Product Group = 'A la Carte', Token Status = Allocated,
    // finally insert the record in Package Service
    // Value Status='Allocated', Product = Product Id, Product Group= Product Group Id, 
    
   
    
    
    @RemoteAction
    global static String createCase(String prodId, String name, String acntId, String ProductID){
        Decimal availableToken = 0;
        
            List<Package_Services__c> pkgsrv = new List<Package_Services__c>();
            List<SelectOption> prioropts = new List<SelectOption>();
            Consume_Service__c cs = new Consume_Service__c();
            
            string contId;
            List<Contact> objContact = [select id from contact where accountid =: acntId and PureSuccess_Main_Contact__c = true limit 1];
            if(objContact != null && objContact.size()>0)
             contId = objContact[0].Id;
             
            //String contId = '003U0000010wMcXIAU'; // This need to be portal Contact ID
            //String recordTypeId = '0121D0000000OYEQA2';
            //Id CaseRecordTypeId = Schema.getGlobalDescribe().get('case').getDescribe().getRecordTypeInfosByName().get('PureSuccess Services').getRecordTypeId();
            //String caseType;
           //if ( String.isNotBlank(recordTypeId) )
           //   caseType = CaseUtil.getAllTScaseTypesMap().get(CaseRecordTypeId).DeveloperName;
            String euId = acntId;
            try{
                    List<Package_Services__c >list_PkgSer = [Select ID,Case__c,Order__r.Opportunity__r.Lines_of_Businesses__c,Order__r.Opportunity__r.Primary_Line_of_Business__c,PureSuccess_Package__r.OPP_Offering_Platform__c from Package_Services__c Where Id =: prodId];
                    
                    //CaseService.caseInstance caseinst = new CaseService.caseInstance(CaseRecordTypeId);
                    //cs.RecordTypeID = CaseRecordTypeId;
                    //cs = caseinst.cs;
                    cs.Status__c = 'Open';                
                    
                    if(contId != null)
                        cs.Contact__c = contId;         
                    
                    cs.Account__C = euId;
                    //cs.AccountId = euId;
                    cs.Service_Element__c= prodId;
                    
                    //cs.Platform_Type__c = 
                    //string sType = list_PkgSer[0].Order__r.Opportunity__r.Lines_of_Businesses__c + '' + list_PkgSer[0].Order__r.Opportunity__r.Primary_Line_of_Business__c ;
                    string sType = list_PkgSer[0].PureSuccess_Package__r.OPP_Offering_Platform__c ;
                    
                    cs.Platform_Type__C = sType;
                    
                    if(sType == 'PureEngage Cloud' || sType == 'Legacy Enterprise Edition' )
                      cs.Gainsight_Relationship_Type__c = 'PureEngage Cloud';
                    if(sType == 'Outbound Engagement')
                      cs.Gainsight_Relationship_Type__c = 'PureEngage Cloud Outbound'; 
                    if(sType == 'Premier Edition')
                      cs.Gainsight_Relationship_Type__c = 'Premier Edition'; 
                    if(sType == 'PureCloud')
                      cs.Gainsight_Relationship_Type__c = 'PureCloud'; 
                    if(sType == 'PureConnect Cloud')
                      cs.Gainsight_Relationship_Type__c = 'PureConnect Cloud'; 
                    if(sType == 'PureEngage On Premise')
                      cs.Gainsight_Relationship_Type__c = 'PureEngage Premise';
                    if(sType == 'PureConnect On Premise')
                      cs.Gainsight_Relationship_Type__c = 'PureConnect Premise';          
                    
                    cs.Notes__c = 'This Service Record is created to Consume PureSuccess Subscription elements';
                    insert cs; 

                    for(Package_Services__c pkg : list_PkgSer)
                    {
                        if(pkg != null)
                        {
                            pkg.Consume_service__c = cs.Id;
                            pkg.Status__c = 'In Progress';
                            pkgsrv.add(pkg);
                        }
                    }
                    if(pkgsrv.size()>0)
                    {
                        update pkgsrv;
                    }
                    System.debug('PP Case created===='+cs + 'Product Service Id ==='+prodId);
            }
            catch (Exception ex) {
                System.debug('This is case error'+ex.getMessage());
                //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to create the Case. Additional details: ' + ex.getMessage() );
                //ApexPages.addMessage(msg);  
            }
            
        return 'Success';
    }
        @RemoteAction
    global static String createPackageALaCarte(String prodId, String name, String acntId, String ProductID, String prdGroup, Decimal tokenValue){
        Decimal availableToken = 0;
        
        try{
            
            System.debug('Inside Order Creation');            
            Token_Allocations__c tknAll = new Token_Allocations__c();
            Pure_Success_Package__c purSuccPak = new Pure_Success_Package__c();
            Package_Services__c pkgsrv = new Package_Services__c();
            Decimal currencyRate;
            
            //System.debug('PP at Inside Currency Rate for cal'+currencyRate);
            List<Product_Group__c>  prdGrp = new List<Product_Group__c>([Select ID from Product_Group__c Where Id =: prdGroup]);
            for(Product_Group__c pg : prdGrp){
                if(pg != null)
                    tokenValue = tokenValue;//pg.Token_Value__c;
            }
            system.debug('Token Allocation ' + acntId + ' Product ' + ProductID + 'prdGroup  ' + '  prdGrp '+ prdGrp.size());
            tknAll.Account__c = acntId;
            tknAll.Product__c = ProductID;
            tknAll.Product_Group__c = prdGroup;
            tknAll.Tokens__c    = -tokenValue;
            tknAll.Token_Status__c = 'In Progress';
            insert tknAll;
            
            /*
            List<Account> lstCon = [Select Id, Total_Token_Available__c from Account where Id=:acntId];
            if(lstCon[0].Total_Token_Available__c != null)
                    availableToken = lstCon[0].Total_Token_Available__c;
            */
            
             List<Product2> objProduct = [select ID,description__C from Product2 where id =: ProductId];
                    
            List<Pure_Success_Package__c> pspkg = new List<Pure_Success_Package__c>([Select Id from Pure_Success_Package__c Where Account__c =:acntId  and Package_type__c =: 'A la Carte'] );
            if(pspkg.size()>0 && pspkg != null){
                 pkgsrv.Status__c = 'Order Submitted';
                 pkgsrv.Product__c = ProductId;
                 pkgsrv.PureSuccess_Package__c = pspkg[0].id;
                 pkgsrv.Product_Group__c = prdGroup;
                 pkgsrv.Buy_Date__c = date.today();
                 insert pkgsrv;   
            }
            else
            {
                    purSuccPak.Account__c = acntId;
                    purSuccPak.Product_group__c = prdGroup;
                    PurSuccPak.Token_status__c = 'Allocated';
                    PurSuccPak.Package_type__c = 'A la Carte';
                    
                    insert purSuccPak;
                    
                    pkgsrv.Status__c = 'Order Submitted';
                    pkgsrv.Product__c = ProductId;
                    pkgsrv.PureSuccess_Package__c = purSuccPak.id;
                    pkgsrv.Product_Group__c = prdGroup;
                    pkgsrv.Buy_Date__c = date.today();
    
                    insert pkgsrv;
            }
            
            System.debug('PP Inside Order CreationPP +++');
                    String str = '';
                    if(name != null){
                        str = name.replace('amp;' , '');}
            Id SoureAccountRecordTypeId = Schema.getGlobalDescribe().get('Order__c').getDescribe().getRecordTypeInfosByName().get('Non-Revenue Orders').getRecordTypeId();
                System.debug('This is called inside CreateNRO');
             
                List<Pure_Success_Package__c> objPSP = [select id,Contract_End_Date__c from Pure_Success_Package__c where Account__c =: acntId order by Contract_End_Date__c desc limit 1 ]; 
                 
                Order__C ord = new Order__C();
                ord.status__c = 'Order Submitted';
                ord.NRO_Type__c = 'Service Element Use';
                ord.Ship_software_via__c = 'No Shipment Required';
                ord.Order_Fulfillment_Email_Receipt__c = 'testOBC@test.com';
                ord.Sold_To_Name__c = acntId;
                ord.RecordTypeId = SoureAccountRecordTypeId ; 
                ord.Maintenance_Start__c = System.today();
                
                if(objPSP != null && objPSP.size()>0)
                 ord.Maintenance_End__c = objPSP[0].Contract_End_Date__c;
                else
                 ord.Maintenance_End__c = System.today().addYears(2);
                
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
                tknAll.Order__c = ord.id;
                pkgsrv.Order__C = ord.Id;
                
                update tknAll;
                update pkgsrv;
            List<Account> lstAcc = [Select Id, Total_Token_Available__c from Account where Id=:acntId]; 
            
            if(lstAcc.size() > 0)
                    availableToken = lstAcc[0].Total_Token_Available__c;
        }catch(Exception ex){
            System.debug('PP Inside Catch ++++'+ex.getMessage());
            string   err = ex.getMessage();
            return err;
        }
        
        
        return 'Success:'+availableToken;
    }
    
}