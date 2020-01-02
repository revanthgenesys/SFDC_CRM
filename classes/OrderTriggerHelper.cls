/***************************************************************************************************
* 
*  Class Name      :    OrderTriggerHelper
*  Description     :    This class is used to define the method for OrderTrigger.trigger.
:    This helper class is used to insert the Pure Success package , Package Group,
:    Token Allocation on the completation of Order.     
*  Author          :    Pankaj Pandey
* 
****************************************************************************************************/

public with sharing class OrderTriggerHelper {
    
    public static Boolean isStopOrderTriggerHelper = true;
    
    public static void InsertPureSuccessPackage(Map<Id, Order__c> newMapOrder, Map<Id, Order__c> oldMapOrder){
        
        
        Set<id> set_Quote = new Set<id>();
        string TokenAPN = Label.Token_APN_Number;
        Map<id,string>map_OrdStatus = new Map<id,string>();
        Map<id, Order__c> mapOrderValidProcess = new Map<id,Order__c>();
        Set<id> setProductID = new Set<id>();
        Set<id> setProductIDAl = new Set<id>();
        Map<id,string>map_SrcContractName = new Map<id,string>();
        Map<id,string>map_ServiceConNames = new Map<id,string>();
        Set<id> setOrderId = new Set<id>();
        Set<id> setAccountId = new Set<id>();
        
        System.debug('==PP -- Inside Insert Purse Success Package====');
        
        //If Order Status is changed to Completed
        for(Order__c objOrd : newMapOrder.values()){
            System.debug('### Enter Main Condition');        
            //Map for old status of OrderStatus
            //Extra Order filters are added by JJ on 11/5
            //Additional filters are added by JJ on 11/12 as requested by Vinay
            if(oldMapOrder != null && (objOrd.License_FYM_detail__c == 'Subscription Order' || objOrd.License_FYM_detail__c == 'Cloud Order') && (objOrd.Order_Category__c == 'PureEngage Subscription' || objOrd.Order_Category__c == 'PureConnect Cloud' || objOrd.Order_Category__c == 'Business Edition' || objOrd.Order_Category__c == 'PureEngage-Cloud Order' || objOrd.Order_Category__c == 'PureConnect Subscription' || objOrd.Order_Category__c == 'PureConnect-Cloud Order' || objOrd.Order_Category__c == 'PureCloud-Cloud Order')){
                map_OrdStatus.put(objOrd.id,oldMapOrder.get(objOrd.Id).Status__c);
                if(objOrd.Status__c == 'Completed' && objOrd.NRO_Type__c != 'Service Element Use' 
                   && objOrd.Status__c != map_OrdStatus.get(objOrd.id) && objOrd.End_User_Name__c != null 
                   && objOrd.Sold_To_Name__c != null){
                       if(objOrd.Quote__c != null){
                           set_Quote.add(objOrd.Quote__c);
                           mapOrderValidProcess.put(objOrd.id,objOrd);
                           //Added by JJ on 6/4, anyway we just need SoldTo
                           setAccountId.add(objOrd.Sold_To_Name__c);
                           //Commented by JJ on 6/4/2018, anyway we just need SoldTo
                           if(objOrd.End_User_Name__c == objOrd.Sold_To_Name__c)
                               setAccountId.add(objOrd.Sold_To_Name__c);
                           else
                               setAccountId.add(objOrd.End_User_Name__c);
                       }
                   }
            }           
        }
        
        //Below code is only to Create the token allocation for GU units. Increment the Gu unit by token value of product group item for type training units. Added by Priyank as requested by Vinay.
        Set<string> orderIdNrOrder = new Set<string>(); //Contains order id for NR order.
        List<string> accIdNrOrder = new List<string>();
        List<Token_Allocations__c> lstTokenAllocationNrOrder = new List<Token_Allocations__c>();//new Token allocation for Nr Order.
        Map<string,string> mapProductIdNrOrder = new Map<string,string>();//Contains Product id and token allocation record .
        for(Order__c objOrd : newMapOrder.values()){
            if(objOrd.NRO_Type__c == 'Service Element Use' && objOrd.Status__c == 'Completed'){
            orderIdNrOrder.add(objOrd.id);
            accIdNrOrder.add(objOrd.End_User_Name__c);
            }
        }
        //Below query to fetch Productid through with we fetch product group later.
        if(orderIdNrOrder.size()>0){
            List<Order_Line_Item__c> oLINrOrder = new List<Order_Line_Item__c>([SELECT Id, Product__r.Type__c, Product__c , Order__c FROM Order_Line_Item__c WHERE Order__c IN :orderIdNrOrder ]);
            for(Order_Line_Item__c oli : oLINrOrder){
                mapProductIdNrOrder.put(oli.Product__c,oli.Order__c);
            }
        }
        //Below query to fetch the value from Product group based on product Id.
        if(mapProductIdNrOrder.size()>0){
            List<Product_Group_Item__c> lstProductGroupNrOrder = new List<Product_Group_Item__c>([ SELECT Id, Product__r.Type__c, Token_Value__c, Product__c, product__r.Name FROM Product_Group_Item__c Where Product__c IN : mapProductIdNrOrder.keySet()]);
            for(Product_Group_Item__c pgiNrOrder : lstProductGroupNrOrder){
                if(pgiNrOrder.Product__r.Type__c == 'Training Unit'){
                    if(pgiNrOrder.Token_Value__c != NULL ){
                        if(mapProductIdNrOrder.containsKey(pgiNrOrder.Product__c)){
                            Token_Allocations__c objInsertTokenAllocation = new Token_Allocations__c();
                            objInsertTokenAllocation.Allocation_Type__c = 'GU Training Units';
                            objInsertTokenAllocation.Order__c = mapProductIdNrOrder.get(pgiNrOrder.Product__c);
                            objInsertTokenAllocation.Token_Status__c = 'Allocated';
                            objInsertTokenAllocation.Tokens__c = pgiNrOrder.Token_Value__c;
                            objInsertTokenAllocation.Account__c = accIdNrOrder[0];
                            lstTokenAllocationNrOrder.add(objInsertTokenAllocation);
                        }
                    }
                }
            }
        }
        if(lstTokenAllocationNrOrder.size()>0){
            insert lstTokenAllocationNrOrder;
        }
        // Priyank Code end.
        
        //If Order is directly submitted with status Completed
        //It happenes in Cloud Orders
        for(Order__c objOrd : newMapOrder.values()){
            //Extra Order filters are added by JJ on 11/5
            //Additional filters are added by JJ on 11/12 as requested by Vinay
            //Added PureCloud order category value in below if condition - 01/02/19 by Vinay
            if(oldMapOrder == null && (objOrd.License_FYM_detail__c == 'Subscription Order' || objOrd.License_FYM_detail__c == 'Cloud Order') && (objOrd.Order_Category__c == 'PureEngage Subscription' || objOrd.Order_Category__c == 'PureConnect Cloud' || objOrd.Order_Category__c == 'Business Edition' || objOrd.Order_Category__c == 'PureEngage-Cloud Order' || objOrd.Order_Category__c == 'PureConnect Subscription' || objOrd.Order_Category__c == 'PureConnect-Cloud Order' || objOrd.Order_Category__c == 'PureCloud-Cloud Order')){
                System.debug('###Enter PureCloud');        
                if(objOrd.Status__c == 'Completed' && objOrd.NRO_Type__c != 'Service Element Use' 
                   && objOrd.End_User_Name__c != null && objOrd.Sold_To_Name__c != null){
                       if(objOrd.Quote__c != null){
                           System.debug('###Enter PureCloud1');
                           set_Quote.add(objOrd.Quote__c);
                           mapOrderValidProcess.put(objOrd.id,objOrd);
                           if(objOrd.End_User_Name__c == objOrd.Sold_To_Name__c)
                               setAccountId.add(objOrd.Sold_To_Name__c);
                           else
                               setAccountId.add(objOrd.End_User_Name__c);
                       }
                   }
            }
        }
        
        String Account = '';
        String SoldTo = '';
        String Product = '';
        String ProductGroup = '';
        string SrcContractName = '';
        string Order = '';
        
        System.debug('PP - size of new map is ===='+mapOrderValidProcess.keySet());
        Set<id> set_ProdGroup = new Set<id>();
        Set<id> set_ProductGroupID = new set<id>();
        Set<id> set_ProductGroupIDAl = new set<id>();
        if(!mapOrderValidProcess.isEmpty()){
            if(set_Quote.size()>0){
                System.debug('PP - Inside If condition of new map ===='+mapOrderValidProcess.values());
                //List<BigMachines__Quote_Product__c> quoteProductList;
                List<BigMachines__Quote_Product__c> quoteProductList =  new List<BigMachines__Quote_Product__c>([select id,BigMachines__Product__r.id,
                                                                                                                 BigMachines__Quote__c, 
                                                                                                                 BigMachines__Product__c, 
                                                                                                                 BigMachines__Product__r.Type__c, 
                                                                                                                 BigMachines__Product__r.OfferingType__c,
                                                                                                                 BigMachines__Quote__r.Order_Type__c,
                                                                                                                 BigMachines__Quantity__c FROM BigMachines__Quote_Product__c
                                                                                                                 WHERE (BigMachines__Product__r.Type__c =: 'Token' OR BigMachines__Product__r.Type__c =: 'Bundle')
                                                                                                                 AND BigMachines__Product__r.OfferingType__c Includes('PureSuccess')
                                                                                                                 AND BigMachines__Quote__c IN :set_Quote]);
                
                
                for(BigMachines__Quote_Product__c obj : quoteProductList){
                    set_ProdGroup.add(obj.BigMachines__Product__c);
                }                
                //System.debug('===PP Size of  Quote Product List '+quoteProductList.size() + '== Size of Quote ==='+set_Quote);
                //Get all the Quote Line Items which are part of A la Carte Package
                //As per discussion with Vinay on 01/10/2018
                List<BigMachines__Quote_Product__c> quoteProductAlaCarteList =  new List<BigMachines__Quote_Product__c>([select id,Bundle__c,BigMachines__Product__r.id,
                                                                                                                         BigMachines__Quote__c, BigMachines__Product__c, 
                                                                                                                         BigMachines__Product__r.Type__c,
                                                                                                                         BigMachines__Product__r.Description__c, 
                                                                                                                         BigMachines__Product__r.OfferingType__c,
                                                                                                                         BigMachines__Quote__r.Order_Type__c,
                                                                                                                         Bundle__r.Name,
                                                                                                                         Quantity_Change__c,
                                                                                                                         Quantity__c,
                                                                                                                         BigMachines__Quantity__c 
                                                                                                                         FROM BigMachines__Quote_Product__c 
                                                                                                                         WHERE BigMachines__Quote__c = :set_Quote
                                                                                                                         AND BigMachines__Product__r.Type__c != 'Token'
                                                                                                                         AND Bundle__r.name like '%A la Carte%']);
                
                
                //New feature data preparation to make AlaCarte Service Element Status as Consumed
                //Code Start
                Set<id> setProduct_GroupID_AlaCarte = new Set<id>();
                for(BigMachines__Quote_Product__c obj : quoteProductAlaCarteList)
                    setProduct_GroupID_AlaCarte.add(obj.Bundle__C);
                
                List<Product_Group_Item__c> lstProductGroupItemforAlaCarte = [select ID,Product__c from Product_Group_Item__c where Product_Group__c in : setProduct_GroupID_AlaCarte and Remove_from_Allocation__c = true];
                Set<id> setRemovefromPackageItemforAlaCarte = new Set<id>();
                for(Product_Group_Item__c obj : lstProductGroupItemforAlaCarte)
                    setRemovefromPackageItemforAlaCarte.add(obj.Product__c);
                //Code End
                
                Map<id, Product_Group__c> mapProductGroup = new Map<id,Product_Group__c>();
                Map<id, Product_Group__c> mapProductGroupAl = new Map<id,Product_Group__c>();
                
                for(BigMachines__Quote_Product__c obj: quoteProductList)
                    setProductID.add(obj.BigMachines__Product__c);
                
                for(BigMachines__Quote_Product__c obj: quoteProductAlaCarteList)
                    setProductIDAl.add(obj.BigMachines__Product__c);
                
                //Get Product Group to Create PureSuccess Package
                List<Product_Group__c> lstProductGroup = [select id,token_value__c,Product__c FROM Product_Group__c 
                                                          WHERE Product__c IN :setProductID AND Group_Type__c = 'PureSuccess'];
                
                //Get Product Group to create PureSuccess Package for A la Carte
                List<Product_Group__c> lstProductGroupAl = [select id,token_value__c,Product__c FROM Product_Group__c 
                                                            WHERE Product__c IN :setProductIDAl AND Group_Type__c = 'A la Carte'];
                
                for(Product_Group__c obj : lstProductGroup)
                {             
                    if(obj.id != null){
                        set_ProductGroupID.add(obj.id);
                        mapProductGroup.put(obj.Product__c,obj);
                    }
                }
                System.debug('PP === Product Mapping==='+mapProductGroup);
                Map<id, Product_Group_item__c> mapProductGroupItem = new Map<id,Product_Group_item__c>();
                //Get Product Group Items to Create PureSuccess Package Line Items
                List<Product_Group_item__c> lstProductGroupItems = [select id,Product__c,Product__r.description__c,Product_Group__c,Remove_from_Package__c 
                                                                    from Product_Group_item__c 
                                                                    WHERE Product_Group__c IN :set_ProductGroupID and Remove_from_Allocation__c = false];
                //System.debug(' Size of Product Group Item ==='+lstProductGroupItems.size());
                for(ServiceContract srvc : [Select ID, Name, Order__r.Id from ServiceContract Where Order__r.Id IN : trigger.newMap.keyset()])
                {
                    map_SrcContractName.put(srvc.id, srvc.Name);
                    if(!setOrderId.contains(srvc.Order__r.Id))
                        map_ServiceConNames.put(srvc.Order__r.Id,srvc.Name);
                }
                Map <ID, ID> mapAcctPS = new Map<ID, ID>();
                for (Pure_Success_Package__c objPS : [Select id, Account__c from Pure_Success_Package__c where Account__c = :setAccountId and Package_Type__c = 'A la Carte'])
                {
                    mapAcctPS.put(objPS.Account__c,objPS.Id);
                }
                //System.debug('PP ==== mapAcctPS '+mapAcctPS +'==== Size of mapAcctPS==='+mapAcctPS.size());
                List<Package_Services__c> lstInsertPackageServices; //= new List<Package_Services__c>();
                List<Package_Services__c> lstInsertPackageServicesAlaCarte = new List<Package_Services__c>();
                List<Pure_Success_Package__c> lstInsertPureSuccessPackage = new List<Pure_Success_Package__c>();
                List<Pure_Success_Package__c> lstInsertPureSuccessPackageAlacarte = new List<Pure_Success_Package__c>();
                Map<id, List<Package_Services__c>> mapPSP = new Map<id, List<Package_Services__c>>();
                Map<id, List<Package_Services__c>> mapPSAlaCarte = new Map<id, List<Package_Services__c>>();
                //Token Allocation
                List<Token_Allocations__c> lstInsertTokenAllocations = new List<Token_Allocations__c>();
                List<BigMachines__Quote__c> list_Token = [Select Id,Token_value__c, Total_GU_Training_Units_Change__c, Total_GU_Training_Units__c, Order_Type__c, Total_Tokens_Change__c from BigMachines__Quote__c Where Id IN : set_Quote AND (Token_Value__c !=0 OR Total_GU_Training_Units__c !=0)];
                system.debug('list_Token'+list_Token);
                Map<Id, String> map_AccountIdProcessString = new Map<Id, String>();
                Map<Id, String> map_AccountIdRegionString = new Map<Id, String>();
                
                //Order looping Start 
                for(Order__c objOrder : [SELECT Id, End_User_Name__c, Sold_To_Name__c, 
                                         Quote__c, Sold_To_Name__r.Region__c, 
                                         Offering_Type__c, Sold_To_Name__r.Advisor__c,Order_Category__c  
                                         FROM Order__c 
                                         WHERE Id IN : mapOrderValidProcess.keySet()])    //mapOrderValidProcess.values())
                {
                    SrcContractName = map_ServiceConNames.get(objOrder.id);
                    Account = objOrder.End_User_Name__c; 
                    SoldTo = objOrder.Sold_To_Name__c;
                    system.debug('##Account##'+Account);
                    system.debug('##SoldTo##'+SoldTo);
                    //Get all the quote products for this order based on Quote ID
                    for(BigMachines__Quote_Product__c obj : quoteProductList)
                    {
                        if(obj.BigMachines__Quote__c == objOrder.Quote__c)
                        {
                            //PureSuccess Package
                            Product_Group__c objPG = mapProductGroup.get(obj.BigMachines__Product__c);
                            Pure_Success_Package__c objInsertPureSuccessPackage = new Pure_Success_Package__c();
                            if(objPG != null)
                            {
                                if(Account == SoldTo)
                                    objInsertPureSuccessPackage.Account__c = Account;
                                else
                                    objInsertPureSuccessPackage.Account__c = SoldTo;
                                
                                System.debug('PP ==== Size of Product Group ===='+objPG);
                                Product = objPG.Product__c;
                                ProductGroup = objPG.id;
                                if(obj.BigMachines__Quote__r.Order_Type__c != 'Amend Subscription' && obj.BigMachines__Quote__r.Order_Type__c != 'Amend'){
                                    objInsertPureSuccessPackage.Package_Type__c = 'Pure Success';
                                    objInsertPureSuccessPackage.Order__c = objOrder.id;
                                    objInsertPureSuccessPackage.Product__c = objPG.Product__c;
                                    objInsertPureSuccessPackage.Product_Group__c = objPG.id;
                                    objInsertPureSuccessPackage.Service_Contract_No__c = SrcContractName; // Added by PP for the Service Contract Name to be associated with Equip package
                                    objInsertPureSuccessPackage.Token_Status__c = 'Allocated';
                                    lstInsertPureSuccessPackage.add(objInsertPureSuccessPackage);
                                    
                                    lstInsertPackageServices = new List<Package_Services__c>();
                                    for(Product_Group_item__c objPGI : lstProductGroupItems)
                                    {
                                        if(objPGI.Product_Group__c == objPG.ID) 
                                        {
                                            Package_Services__c objInsertPackageServices = new Package_Services__c();
                                            objInsertPackageServices.Name = objPGI.Product__r.description__c;
                                            objInsertPackageServices.Product__c = objPGI.Product__c; 
                                            objInsertPackageServices.Product_Group__c = objPGI.Product_Group__c;
                                            objInsertPackageServices.Product_Group_Item__c = objPGI.Id;
                                            system.debug('after objPGI.Remove_from_Package__c   '+objPGI.Remove_from_Package__c);
                                            if(objPGI.Remove_from_Package__c)
                                                objInsertPackageServices.Status__c = 'Consumed';
                                            else
                                                objInsertPackageServices.Status__c = 'Allocated';
                                            
                                            lstInsertPackageServices.add(objInsertPackageServices);
                                            mapPSP.put(objOrder.id,lstInsertPackageServices);
                                        }//If End
                                    }//Product Group Item End
                                }
                                lstInsertPackageServices = new List<Package_Services__c>();
                            }    
                        }//If End
                    }//BigMachine Quote End
                    
                    
                    //A la Carte Package
                    //System.debug('PP Map of Product Group Item '+mapPSP.size());
                    //System.debug('PP Size of lstInsertPureSuccessPackage (Product Group) '+lstInsertPureSuccessPackage.size());
                    //System.debug('PP Size of A la Carte Package'+quoteProductAlaCarteList.size());
                    if(quoteProductAlaCarteList.size()>0 && quoteProductAlaCarteList != null)
                    {
                        lstInsertPackageServicesAlaCarte = new List<Package_Services__c>();
                        string AcctID ='';
                        if(Account == SoldTo)
                            AcctID=Account;
                        else
                            AcctID=SoldTo;
                        
                        //List<Pure_Success_Package__c> objPS = new List<Pure_Success_Package__c>();
                        //objPS = [Select id from Pure_Success_Package__c where Account__c = :AcctID and Package_Type__c = 'A la Carte'];
                        //if(objPS.size()<=0 || objPS == null)
                        boolean blnInsert = false;  
                        for(BigMachines__Quote_Product__c obj : quoteProductAlaCarteList)
                        {
                            system.debug('>>>#### priyank obj   '+obj);
                            if(!setRemovefromPackageItemforAlaCarte.contains(obj.BigMachines__Product__c))
                            {
                                if(Product == null || Product == '')
                                    Product = obj.BigMachines__Product__c;
                                if(ProductGroup == null || ProductGroup == '')
                                    ProductGroup = obj.Bundle__c;
                                if(obj.BigMachines__Quote__c == objOrder.Quote__c)
                                {
                                    if(obj.BigMachines__Quote__r.Order_Type__c != 'Amend Subscription' && obj.BigMachines__Quote__r.Order_Type__c != 'Amend'){
                                        List<Package_Services__c> lstInsertPackageServicesAlaCarte1 = new List<Package_Services__c>();
                                        //if(!mapAcctPS.containsKey(AcctId)) Priyank Commented the blew if condition and else part.
                                        //{
                                        System.debug('Apple');
                                        if(!blnInsert)
                                        {
                                            System.debug('Apple');
                                            Pure_Success_Package__c objInsertPureSuccessPackage = new Pure_Success_Package__c();
                                            objInsertPureSuccessPackage.Account__c = AcctID;
                                            objInsertPureSuccessPackage.Package_Type__c = 'A la Carte';
                                            objInsertPureSuccessPackage.Order__c = objOrder.Id;
                                            objInsertPureSuccessPackage.Product__c = obj.BigMachines__Product__c;
                                            objInsertPureSuccessPackage.Product_Group__c = obj.Bundle__c;
                                            objInsertPureSuccessPackage.Service_Contract_No__c = SrcContractName; // Added by PP for the Service Contract Name to be associated with Equip package
                                            objInsertPureSuccessPackage.Token_Status__c = 'Allocated';
                                            
                                            lstInsertPureSuccessPackageAlacarte.add(objInsertPureSuccessPackage);
                                            
                                            blnInsert = true;
                                        }
                                        //forloop added below by priyank,on request of vinay to show the package service multiple time if quantity is more that 1.
                                        system.debug('>>>>>>#######  '+ obj.quantity__c);
                                        integer quantityNumber;
                                        if(obj.Quantity__c != NULL){
                                            quantityNumber = Integer.valueOf(obj.Quantity__c);
                                        }else if(obj.BigMachines__Quantity__c != NULL){
                                            quantityNumber = Integer.valueOf(obj.BigMachines__Quantity__c);
                                        }
                                        for(integer i=0;i<quantityNumber;i++){
                                            Package_Services__c objInsertPackageServices = new Package_Services__c();
                                            objInsertPackageServices.Product__c = obj.BigMachines__Product__c;
                                            objInsertPackageServices.Name = obj.BigMachines__Product__r.Description__c; 
                                            objInsertPackageServices.Product_Group__c = obj.Bundle__c;
                                            objInsertPackageServices.Status__c = 'Allocated'; 
                                            
                                            //If Product Group Item's Remove from Allocation is True then make the Service Element Status = Consumed otherwise Allocated
                                            /*
if(setRemovefromPackageItemforAlaCarte.contains(obj.BigMachines__Product__c))
objInsertPackageServices.Status__c = 'Consumed';
else
objInsertPackageServices.Status__c = 'Allocated';    
*/
                                            
                                            lstInsertPackageServicesAlaCarte.add(objInsertPackageServices);
                                            system.debug('>>>>>>####### lstInsertPackageServicesAlaCarte   '+ lstInsertPackageServicesAlaCarte);
                                        }
                                        system.debug('>>>>>>####### lstInsertPackageServicesAlaCarte   '+ lstInsertPackageServicesAlaCarte);
                                        if(!mapPSAlaCarte.containsKey(objOrder.id))
                                        {
                                            mapPSAlaCarte.put(objOrder.id,new List<Package_Services__c>());
                                        }
                                        mapPSAlaCarte.get(objOrder.id).addAll(lstInsertPackageServicesAlaCarte);       
                                        system.debug('>>>>>>####### lstInsertPackageServicesAlaCarte   '+ mapPSAlaCarte);                         
                                        //}
                                        /*else
{
Package_Services__c objInsertPackageServices = new Package_Services__c();
objInsertPackageServices.Product__c = obj.BigMachines__Product__c; 
objInsertPackageServices.Name = obj.BigMachines__Product__r.Description__c; 
objInsertPackageServices.Product_Group__c = obj.Bundle__c;
objInsertPackageServices.Status__c = 'Allocated';

//If Product Group Item's Remove from Package is True then make the Service Element Status = Consumed otherwise Allocated
/*
if(setRemovefromPackageItemforAlaCarte.contains(obj.BigMachines__Product__c))
objInsertPackageServices.Status__c = 'Consumed';
else
objInsertPackageServices.Status__c = 'Allocated';


objInsertPackageServices.PureSuccess_Package__c = mapAcctPS.get(AcctId);
lstInsertPackageServicesAlaCarte1.add(objInsertPackageServices);                             
}
if(lstInsertPackageServicesAlaCarte1 != null && lstInsertPackageServicesAlaCarte1.size()>0)
insert lstInsertPackageServicesAlaCarte1;*/
                                    }else if(obj.BigMachines__Quote__r.Order_Type__c == 'Amend Subscription' || obj.BigMachines__Quote__r.Order_Type__c == 'Amend'){
                                        if(obj.Bundle__r.Name == 'PureSuccess A la Carte'){
                                            if(obj.Quantity_Change__c>0){
                                                List<Package_Services__c> lstInsertPackageServicesAlaCarte1 = new List<Package_Services__c>();
                                                if(!blnInsert)
                                                {
                                                    Pure_Success_Package__c objInsertPureSuccessPackage = new Pure_Success_Package__c();
                                                    objInsertPureSuccessPackage.Account__c = AcctID;
                                                    objInsertPureSuccessPackage.Package_Type__c = 'A la Carte';
                                                    objInsertPureSuccessPackage.Order__c = objOrder.Id;
                                                    objInsertPureSuccessPackage.Product__c = obj.BigMachines__Product__c;
                                                    objInsertPureSuccessPackage.Product_Group__c = obj.Bundle__c;
                                                    objInsertPureSuccessPackage.Service_Contract_No__c = SrcContractName; // Added by PP for the Service Contract Name to be associated with Equip package
                                                    objInsertPureSuccessPackage.Token_Status__c = 'Allocated';
                                                    
                                                    lstInsertPureSuccessPackageAlacarte.add(objInsertPureSuccessPackage);
                                                    
                                                    blnInsert = true;
                                                }
                                                //forloop added below by priyank,on request of vinay  to show the package service multiple time if quantity is more that 1.
                                                for(integer i=0;i<obj.Quantity_Change__c;i++){
                                                    Package_Services__c objInsertPackageServices = new Package_Services__c();
                                                    objInsertPackageServices.Product__c = obj.BigMachines__Product__c;
                                                    objInsertPackageServices.Name = obj.BigMachines__Product__r.Description__c; 
                                                    objInsertPackageServices.Product_Group__c = obj.Bundle__c;
                                                    objInsertPackageServices.Status__c = 'Allocated'; 
                                                    
                                                    lstInsertPackageServicesAlaCarte.add(objInsertPackageServices);
                                                }
                                                if(!mapPSAlaCarte.containsKey(objOrder.id))
                                                {
                                                    mapPSAlaCarte.put(objOrder.id,new List<Package_Services__c>());
                                                }
                                                mapPSAlaCarte.get(objOrder.id).addAll(lstInsertPackageServicesAlaCarte);
                                            }
                                        }
                                    }
                                }
                                lstInsertPackageServicesAlaCarte = new List<Package_Services__c>(); 
                            }
                        }  
                    }
                    //Allocate value of Token_Value__c in Token Allocation
                    //Changes done by JJ on 12/18/2017 as per discussion with Ankit
                    //Now tokens will set from quote line item quantity where product APN Number = Tokens (may be changed this later)
                    for(BigMachines__Quote__c objToken : list_Token)
                    {
                        system.debug('objToken.Token_Value__c'+objToken.Token_Value__c);
                        if(objToken.Id == objOrder.Quote__c && objToken.Token_Value__c > 0 )
                        {
                            system.debug('objToken.Token_Value__c'+objToken.Order_Type__c);
                            if(objToken.Order_Type__c == 'Amend Subscription' || objToken.Order_Type__c == 'Amend'){
                                if(objToken.Total_Tokens_Change__c>0){
                                    System.debug('PP ==== Product Id = '+Product + '==== Product Group ID ==='+ProductGroup);
                                    Token_Allocations__c objInsertTokenAllocation = new Token_Allocations__c();
                                    if(Account == SoldTo)
                                        objInsertTokenAllocation.Account__c = Account;
                                    else
                                        objInsertTokenAllocation.Account__c = SoldTo;
                                    
                                    objInsertTokenAllocation.Allocation_Type__c = 'Subscription Token';
                                    objInsertTokenAllocation.Contract_No__c = SrcContractName;
                                    objInsertTokenAllocation.Order__c = objOrder.id;
                                    objInsertTokenAllocation.Tokens__c = objToken.Total_Tokens_Change__c;
                                    objInsertTokenAllocation.Token_Status__c = 'Allocated';
                                    lstInsertTokenAllocations.add(objInsertTokenAllocation);
                                }
                            }else if(objToken.Order_Type__c != 'Amend Subscription' || objToken.Order_Type__c != 'Amend'){
                                System.debug('PP ==== Product Id = '+Product + '==== Product Group ID ==='+ProductGroup);
                                Token_Allocations__c objInsertTokenAllocation = new Token_Allocations__c();
                                if(Account == SoldTo)
                                    objInsertTokenAllocation.Account__c = Account;
                                else
                                    objInsertTokenAllocation.Account__c = SoldTo;
                                
                                objInsertTokenAllocation.Allocation_Type__c = 'Subscription Token';
                                objInsertTokenAllocation.Contract_No__c = SrcContractName;
                                objInsertTokenAllocation.Order__c = objOrder.id;
                                objInsertTokenAllocation.Tokens__c = objToken.Token_Value__c;
                                objInsertTokenAllocation.Token_Status__c = 'Allocated';
                                lstInsertTokenAllocations.add(objInsertTokenAllocation);
                            }
                        }
                        if(objToken.Id == objOrder.Quote__c && objToken.Total_GU_Training_Units__c > 0 )
                        {
                            if(objToken.Order_Type__c == 'Amend Subscription' || objToken.Order_Type__c == 'Amend'){
                                if(objToken.Total_GU_Training_Units_Change__c>0){
                                    System.debug('PP ==== Product Id = '+Product + '==== Product Group ID ==='+ProductGroup);
                                    Token_Allocations__c objInsertTokenAllocation = new Token_Allocations__c();
                                    if(Account == SoldTo)
                                        objInsertTokenAllocation.Account__c = Account;
                                    else
                                        objInsertTokenAllocation.Account__c = SoldTo;
                                    
                                    objInsertTokenAllocation.Allocation_Type__c = 'GU Training Units';
                                    objInsertTokenAllocation.Contract_No__c = SrcContractName;
                                    objInsertTokenAllocation.Order__c = objOrder.id;
                                    objInsertTokenAllocation.Tokens__c = objToken.Total_GU_Training_Units_Change__c;
                                    objInsertTokenAllocation.Token_Status__c = 'Allocated';
                                    lstInsertTokenAllocations.add(objInsertTokenAllocation);
                                }
                            }else if(objToken.Order_Type__c != 'Amend Subscription' || objToken.Order_Type__c != 'Amend'){
                                System.debug('PP ==== Product Id = '+Product + '==== Product Group ID ==='+ProductGroup);
                                Token_Allocations__c objInsertTokenAllocation = new Token_Allocations__c();
                                if(Account == SoldTo)
                                    objInsertTokenAllocation.Account__c = Account;
                                else
                                    objInsertTokenAllocation.Account__c = SoldTo;
                                
                                objInsertTokenAllocation.Allocation_Type__c = 'GU Training Units';
                                objInsertTokenAllocation.Contract_No__c = SrcContractName;
                                objInsertTokenAllocation.Order__c = objOrder.id;
                                objInsertTokenAllocation.Tokens__c = objToken.Total_GU_Training_Units__c;
                                objInsertTokenAllocation.Token_Status__c = 'Allocated';
                                lstInsertTokenAllocations.add(objInsertTokenAllocation);
                            }
                        }
                    }
                    
                    //Change added on 6/4 to set the Advisor Name if it is blank
                    //Get the Advisor Name for SoldTo Account
                    System.debug('objOrder.Sold_To_Name__r.Advisor__C----'+objOrder.Sold_To_Name__r.Advisor__C);
                    if(objOrder.Sold_To_Name__r.Advisor__C == null)
                    {
                        if(objOrder.Order_Category__c!= null){
                            map_AccountIdProcessString.put(objOrder.Sold_To_Name__c, objOrder.Order_Category__c);
                        }
                        map_AccountIdRegionString.put(objOrder.Sold_To_Name__c, objOrder.Sold_To_Name__r.Region__c);
                        System.debug('objOrder.Sold_To_Name__r.Region__c----'+objOrder.Sold_To_Name__r.Region__c);
                    }
                    
                }//Order looping End    
                
                if(map_AccountIdProcessString.size() > 0){
                    getAdvisorName(map_AccountIdProcessString, map_AccountIdRegionString);
                }
                
                if(lstInsertPureSuccessPackage != null && lstInsertPureSuccessPackage.size()>0)
                {
                    insert lstInsertPureSuccessPackage;
                    System.debug('Pure Success Package Inserted');
                }
                //Insert Pure Success Package For A La Carte.
                if(lstInsertPureSuccessPackageAlacarte != null && lstInsertPureSuccessPackageAlacarte.size()>0)
                {
                    insert lstInsertPureSuccessPackageAlacarte;
                }
                //System.debug('PP ==== Package Service Map Ala =='+mapPSAlaCarte.size());
                //System.debug('PP ==== Package Service Map Ala =='+mapPSAlaCarte);
                for(Pure_Success_Package__c obj : lstInsertPureSuccessPackage)
                {                
                    //objPSPS.add(mapPSP.get(obj.Order__c));
                    //System.debug('PP==== AtLine 261==='+objPSPS.size());
                    if(mapPSP.containskey(obj.Order__c) == true)
                    {
                        List<Package_Services__c> objPSPS1 = new List<Package_Services__c>();
                        for(Package_Services__c objPSPS : mapPSP.get(obj.Order__c))
                        {
                            objPSPS1.add(objPSPS);
                        }
                        for(Package_Services__c obj1 : objPSPS1)
                        {
                            if(obj1 != null)
                            {
                                obj1.PureSuccess_Package__c = obj.id;
                                lstInsertPackageServices.add(obj1);
                            }
                        }
                        //System.debug('PP Size of Package Service to Insert'+objPSPS1.size());
                        
                    }
                }
                // AlaCarte Package Service Insert
                for(Pure_Success_Package__c obj : lstInsertPureSuccessPackageAlacarte)
                {                
                    if(mapPSAlaCarte.containskey(obj.Order__c) == true)
                    {
                        List<Package_Services__c> objPSPS1 = new List<Package_Services__c>();
                        for(Package_Services__c objPSPS : mapPSAlaCarte.get(obj.Order__c))
                        {
                            objPSPS1.add(objPSPS);
                            //objPSPS1.PureSuccess_Package__c = obj.id;
                            //InsertPackageServicesAlaCarte.add(objPSPS1);                                                              
                        }
                        for(Package_Services__c obj1 : objPSPS1)
                        {
                            if(obj1 != null)
                            {
                                obj1.PureSuccess_Package__c = obj.id;
                                lstInsertPackageServicesAlaCarte.add(obj1);
                            }
                        }
                        //System.debug('PP Size of Package Service Ala carte to Insert'+objPSPS1.size());
                    }
                }
                
                //A la carte Insert
                //PureSuccess Package and Package Services
                //System.debug('===Size of lstInsertPureSuccessPackageAlacarte ==='+lstInsertPureSuccessPackageAlacarte.size());
                //System.debug('===Size of lstInsertPackageServicesAlaCarte ==='+lstInsertPackageServicesAlaCarte.size());
                
                if(lstInsertPackageServicesAlaCarte != null && lstInsertPackageServicesAlaCarte.size()>0 )
                {
                    insert lstInsertPackageServicesAlaCarte;
                    System.debug('Package Service A la Carte Inserted');                
                }
                
                // Non A la carte Service Insert
                if(lstInsertPackageServices != null && lstInsertPackageServices.size()>0)
                {
                    system.debug('lstInsertPackageServices'+lstInsertPackageServices.size());
                    for(Package_Services__c ps:lstInsertPackageServices)
                    {
                        system.debug('psobj'+ps);
                    }
                    insert lstInsertPackageServices;
                    System.debug('Package Service Inserted');
                }
                if(lstInsertTokenAllocations != null && lstInsertTokenAllocations.size()>0)
                {
                    insert lstInsertTokenAllocations;
                    System.debug('Token Allocation Inserted');                
                }
            }
        }
        isStopOrderTriggerHelper = false;
    }
    
    
    public static void getAdvisorName(Map<Id, String> map_AccountIdProcessStr, Map<Id, String> map_AccountIdRegionStr)
    {
        List<Account> list_AccountToUpdate = new List<Account>();
        Map<String, Set<Id>> map_UserNameAccountList = new map<String, Set<Id>>();
        
        List<RegionBasedUsers__c> list_RegionBasedUser = new List<RegionBasedUsers__c>([SELECT Region__c, User_Name__c, Process__c FROM RegionBasedUsers__c 
                                                                                        WHERE Process__c IN :map_AccountIdProcessStr.values() 
                                                                                        AND (Region__c IN :map_AccountIdRegionStr.values() OR Region__c = 'Default')]);
        
        for(Id accId : map_AccountIdProcessStr.keySet()){
            boolean isMatch = false;
            string defaultUserName;
            string userName;
            for(RegionBasedUsers__c regBasUsr : list_RegionBasedUser){
                if(regBasUsr.Region__c == 'Default'){
                    defaultUserName = regBasUsr.User_Name__c;
                }               
                if(map_AccountIdProcessStr.get(accId) == regBasUsr.Process__c && map_AccountIdRegionStr.get(accId) == regBasUsr.Region__c){
                    userName = regBasUsr.User_Name__c;                  
                    isMatch = true;
                }
            }
            if(!isMatch){
                userName = defaultUserName;
            }
            if(userName != null){
                if(!map_UserNameAccountList.containsKey(userName)){
                    map_UserNameAccountList.put(userName, new Set<Id>());
                }
                map_UserNameAccountList.get(userName).add(accId);
            }
        } 
        
        if(map_UserNameAccountList.size() > 0){
            for(User usr : [SELECT UserName, Id FROM User WHERE UserName IN :map_UserNameAccountList.keySet()]){
                for(Id accObjId : map_UserNameAccountList.get(usr.UserName)){
                    Account acc = new Account(Id = accObjId, Advisor__C = usr.Id);
                    list_AccountToUpdate.add(acc);
                }
            }
            
            update list_AccountToUpdate;
        }
    }
}