public without sharing class ListOfServiceContractLineItems {
    public List<resultWrapper> resultItems {get;set;}
    public List<orderWrapper> resultOrders {get;set;}
    public Boolean noResult {get;set;}
    private String accId;
    private String contactId;
    public String recordId {get;set;}
    public String recordIdName {get;set;}
    public Boolean isPortal {get;set;}
    public List<SelectOption> endUserList {get;set;}
    public String selectedEndUser {get;set;}
    public Boolean showOrders {get;set;}
    public String title {get;set;}
    public Boolean showLimitMsg {get;set;}
    public ListOfServiceContractLineItems(){
        isPortal = false;
        showOrders = false;
        showLimitMsg = false;
        title = 'Entitlement Products';
        accId = ApexPages.currentPage().getParameters().get('accId');
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        if(ApexPages.currentPage().getParameters().get('showOrders') != null && ApexPages.currentPage().getParameters().get('showOrders') == 'true'){
            showOrders = true;
        }
        if(ApexPages.currentPage().getParameters().get('selectedFilter') != null && ApexPages.currentPage().getParameters().get('selectedFilter') != '')
            selectedEndUser = ApexPages.currentPage().getParameters().get('selectedFilter');
        User portalUser = [SELECT id, contactId FROM User WHERE id =: Userinfo.getUserId() LIMIT 1];
        if(portalUser.ContactId != null){
            contactId = portalUser.ContactId;
            isPortal = true;
        }       
        populateRecords();
    }
    
    public void populateRecords(){
        List<ContractLineItem> contLineItems;
        List<Order__c> orders;
        if(accId != null){
            contLineItems = [SELECT ServiceContractId, ServiceContract.Name, Product_Description__c, Current_Quantity__c, 
                Maintenance_Start_Date__c, Maintenance_End_Date__c, ServiceContract.End_User_Name__r.Name, ServiceContract.Sold_To_Name__r.Name,
                Original_Quantity__c, Actual_Original_Quantity__c FROM ContractLineItem WHERE (ServiceContract.End_User_Name__c =: accId OR
                ServiceContract.Sold_To_Name__c =: accId) AND ServiceContract.Agreement_Status__c IN ('Active', 'Pending', 'In Negotiation') LIMIT 1000];
            recordId = accId;
            recordIdName = 'accId';
        }
        else if(contactId != null && showOrders){
            Contact cont = [SELECT accountId FROM Contact WHERE id =: contactId LIMIT 1];
            orders = [SELECT Name, Date_Submitted__c, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name 
                FROM Order__c WHERE End_User_Name__c =: cont.accountId LIMIT 1000];
            title = 'Purchase History';
        }
        else if(contactId != null){
         /* MS 3/5/2015
            List<Support_Access__c> supportAccess = [SELECT Service_Contract__c FROM Support_Access__c WHERE Contact__c =: contactId AND Service_Contract__c != null];
            Set<Id> scIds = new Set<Id>();
            for(Support_Access__c eachSA : supportAccess)
                scIds.add(eachSA.Service_Contract__c);
         */        
            List<ServiceContract> servConracts = [SELECT Id FROM ServiceContract 
                                                  WHERE End_User_Name__c IN 
                                                             (SELECT End_User_Account__c FROM Support_Access__c WHERE Contact__c = :contactId) 
                                                  AND Sold_To_Name__c IN 
                                                             (SELECT Sold_To_Account__c FROM Support_Access__c WHERE Contact__c = :contactId) 
                                                  AND Agreement_Status__c IN ('Active', 'Pending', 'In Negotiation')];
            Set<Id> scIds = new Set<Id>();
            for(ServiceContract eachSC : servConracts)
                  scIds.add(eachSC.Id);    
                
            if(selectedEndUser == null){
                contLineItems = [SELECT ServiceContractId, ServiceContract.Name, Product_Description__c, Current_Quantity__c, 
                    Maintenance_Start_Date__c, Maintenance_End_Date__c, ServiceContract.End_User_Name__r.Name, ServiceContract.Sold_To_Name__r.Name,
                    Original_Quantity__c, Actual_Original_Quantity__c FROM ContractLineItem WHERE ServiceContractId IN : scIds AND 
                    ServiceContract.Agreement_Status__c IN ('Active', 'Pending', 'In Negotiation') LIMIT 1000];
            }
            else{
                contLineItems = [SELECT ServiceContractId, ServiceContract.Name, Product_Description__c, Current_Quantity__c, 
                    Maintenance_Start_Date__c, Maintenance_End_Date__c, ServiceContract.End_User_Name__r.Name, ServiceContract.Sold_To_Name__r.Name,
                    Original_Quantity__c, Actual_Original_Quantity__c FROM ContractLineItem WHERE ServiceContractId IN : scIds 
                    AND ServiceContract.Agreement_Status__c IN ('Active', 'Pending', 'In Negotiation')                  
                    AND ServiceContract.End_User_Name__c =: selectedEndUser LIMIT 1000];   
            }
            recordId = contactId;
            recordIdName = 'contactId';
        }
        
        showLimitMsg = (contLineItems.size() == 1000);
        resultItems = new List<resultWrapper>();
        endUserList = new List<SelectOption>();
        Set<Id> endUserIds = new Set<Id>();
        endUserList.add(new SelectOption('', '--Select--'));
        if(showOrders){
            if(orders.size() == 0)
                noResult = true;
            else
                noResult = false;   
            resultOrders = new List<orderWrapper>();
            for(Order__c eachOrder : orders){
                if(!endUserIds.contains(eachOrder.End_User_Name__c) && selectedEndUser == null){
                    endUserIds.add(eachOrder.End_User_Name__c);
                    SelectOption item = new SelectOption(eachOrder.End_User_Name__c, eachOrder.End_User_Name__r.Name);
                    endUserList.add(item);
                }
                orderWrapper newRecord = new orderWrapper();
                newRecord.orderNumber = eachOrder.Name;
                newRecord.submitDate = eachOrder.Date_Submitted__c;
                newRecord.endUserName = eachOrder.End_User_Name__r.Name;
                newRecord.endUserId = eachOrder.End_User_Name__c;
                newRecord.soldToName = eachOrder.Sold_To_Name__r.Name;
                newRecord.soldToId = eachOrder.Sold_To_Name__c;
                resultOrders.add(newRecord);
            }   
        }
        else{
            if(contLineItems.size() == 0)
                noResult = true;
            else
                noResult = false;   
            for(ContractLineItem eachCLI : contLineItems){          
                if(!endUserIds.contains(eachCLI.ServiceContract.End_User_Name__c) && selectedEndUser == null){
                    endUserIds.add(eachCLI.ServiceContract.End_User_Name__c);
                    SelectOption item = new SelectOption(eachCLI.ServiceContract.End_User_Name__c, eachCLI.ServiceContract.End_User_Name__r.Name);
                    endUserList.add(item);
                }
                resultWrapper newRecord = new resultWrapper();
                newRecord.ServiceContractId = eachCLI.ServiceContractId;
                newRecord.Name = eachCLI.ServiceContract.Name;
                newRecord.Descripiton = eachCLI.Product_Description__c;
                newRecord.Quantity = eachCLI.Current_Quantity__c;
                newRecord.startDate = eachCLI.Maintenance_Start_Date__c;
                newRecord.endDate = eachCLI.Maintenance_End_Date__c;
                newRecord.endUserName = eachCLI.ServiceContract.End_User_Name__r.Name;
                newRecord.endUserId = eachCLI.ServiceContract.End_User_Name__c;
                newRecord.soldToName = eachCLI.ServiceContract.Sold_To_Name__r.Name;
                newRecord.soldToId = eachCLI.ServiceContract.Sold_To_Name__c;
                newRecord.actualQuantity = (eachCLI.Actual_Original_Quantity__c == null ? eachCLI.Original_Quantity__c : eachCLI.Actual_Original_Quantity__c);
                resultItems.add(newRecord);     
            }   
        }
    }
    
    public pageReference back(){
        return new pageReference('/' + recordId);
    }
    
    public class orderWrapper{
        public String orderNumber {get;set;}
        public String endUserId {get;set;}
        public String endUserName {get;set;}
        public String soldToId {get;set;}
        public String soldToName {get;set;}
        public DateTime submitDate {get;set;}
    }
    
    public class resultWrapper{
        public String ServiceContractId {get;set;}
        public String Name {get;set;}
        public String Descripiton {get;set;}
        public Decimal Quantity {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public String endUserId {get;set;}
        public String endUserName {get;set;}
        public String soldToId {get;set;}
        public String soldToName {get;set;}
        public Decimal actualQuantity {get;set;}
        
        
    }
}