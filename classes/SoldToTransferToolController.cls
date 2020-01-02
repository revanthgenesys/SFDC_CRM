public class SoldToTransferToolController {
    public Contact accountSelection {get; set;}
    public Contact targetSoldTo {get; set;}
    public Boolean authorizedUser {get; set;}
    public Boolean selectAll {get; set;}
    
    public List<Sold_To_Transfer_Request_Header__c> pendingRequests {get; set;}
    public List<Order__c> pendingOrders {get; set;}
    public List<BigMachines__Quote__c> pendingQuotes {get; set;}
    public List<ServiceContractWrapper> serviceContracts {get; set;} 
    
    public Boolean atleastOneServiceSelected {get; set;}
    public Boolean validationCompleted {get; set;}
    public Boolean soldToSelectionError {get; set;}
    
    public SoldToTransferToolController(){
        accountSelection = new Contact();
        targetSoldTo = new Contact();
    	authorizedUser = false;    
    	selectAll = false;
    	atleastOneServiceSelected = false;
    	validationCompleted = false;
    	soldToSelectionError = false;
    	for(GroupMember m : [Select Id, UserOrGroupId, GroupId, Group.type From GroupMember Where Group.Name = 'Sold To Transfer Tool Access']) {
    		if(UserInfo.getUserId() == m.UserOrGroupId){
    			authorizedUser = true;
    			break;	
    		}
    	}
    }
    
     public void goClicked(){
     	targetSoldTo = new Contact();
     	atleastOneServiceSelected = false;
     	validationCompleted = false;
     	soldToSelectionError = false;
     	selectAll = false;
     	pendingRequests = new List<Sold_To_Transfer_Request_Header__c>();
     	pendingOrders = new List<Order__c>();
     	pendingQuotes = new List<BigMachines__Quote__c>();
     	if(accountSelection.AccountId != null){
     		pendingRequests = [SELECT id, Name, Target_Sold_To__c, Target_Sold_To__r.Name, Status__c, CreatedDate, CreatedById, CreatedBy.Name 
     							FROM Sold_To_Transfer_Request_Header__c 
     							WHERE Account__c = :accountSelection.AccountId AND Status__c != 'Approved' AND Status__c != 'Rejected'];
     							
     		serviceContracts = new List<ServiceContractWrapper>();
           	for(ServiceContract sc :  [SELECT Id, Name, ContractNumber, Sold_To_Name__c, Sold_To_Name__r.Name, StartDate,  EndDate, Agreement_Status__c, Maintenance_Amount__c, Opp_Status__c, Service_Contract_Type__c, Offering_Type__c
                					FROM ServiceContract where AccountId = :accountSelection.AccountId 
                					AND Agreement_Status__c IN ('Active', 'In Negotiation') 
                					AND Service_Contract_Type__c IN ('Perpetual', 'Evaluation', 'Upgrade', 'Rental', 'Mirror')
                					ORDER BY Name])
			{
            	serviceContracts.add(new ServiceContractWrapper(sc));	    						
			}
     	}
     }
     
     public void selectAllServiceContracts(){
     	atleastOneServiceSelected = false;
     	for(ServiceContractWrapper scw : serviceContracts){
			scw.selected = selectAll;
			if(scw.selected)
				atleastOneServiceSelected = true;
     	}
     	validationCompleted = false;
     	soldToSelectionError = false;
     }
     
     public void serviceContractSelectionChanged(){
     	atleastOneServiceSelected = false;
     	for(ServiceContractWrapper scw : serviceContracts){
			if(scw.selected)
				atleastOneServiceSelected = true;
     	}
     	validationCompleted = false;
     	soldToSelectionError = false;
     }
     
     public void proceed(){
     	targetSoldTo = new Contact();
     	Set<String> selectedSCSoldTos = new Set<String>();
     	for(ServiceContractWrapper scw : serviceContracts){
     		if(scw.selected){
				selectedSCSoldTos.add(scw.sc.Sold_To_Name__c);
     		}
     	}
     	
     	if(selectedSCSoldTos.size() > 0){
	     	// Check if any pending orders exists 
	     	pendingOrders = [SELECT id, Name, Status__c, End_User_Name__c, End_User_Name__r.Name, Sold_To_Name__c, Sold_To_Name__r.Name 
	     							FROM Order__c WHERE End_User_Name__c = :accountSelection.AccountId AND Sold_To_Name__c IN :selectedSCSoldTos
	     							AND Status__c IN ('Order Submitted', 'Approved', 'Send to ERP', 'Processed In ERP')];	
	     	pendingQuotes = [SELECT id, Name, BigMachines__Status__c, End_User_ID__c, End_User_ID__r.Name, Sold_To_Name__c, Sold_To_Name__r.Name 
	     							FROM BigMachines__Quote__c WHERE End_User_ID__c = :accountSelection.AccountId AND Sold_To_Name__c IN :selectedSCSoldTos 
	     							AND BigMachines__Is_Primary__c = true AND BigMachines__Status__c IN ('Quote In Progress', 'Quote Approved')];							
	     	validationCompleted = true;												
     	}
     }
     
     public void cancel(){
     	accountSelection = new Contact();
        targetSoldTo = new Contact();
    	authorizedUser = true;    
    	selectAll = false;
    	validationCompleted = false;	
    	soldToSelectionError = false;
    	pendingRequests = new List<Sold_To_Transfer_Request_Header__c>();
     	pendingOrders = new List<Order__c>();
     	pendingQuotes = new List<BigMachines__Quote__c>();
     }
     
     public PageReference doTransfer(){
     	String regionalController = NULL;
     	soldToSelectionError = false;
     	for(ServiceContractWrapper scw : serviceContracts){
     		if(scw.selected && scw.sc.Sold_To_Name__c == targetSoldTo.AccountId){
				soldToSelectionError = true;	
     		}
     	}
     	if(soldToSelectionError == false){
	    	Account endUserAccount = [SELECT id, Name, Region__c, Genesys_Care_specialist__c, Genesys_Care_specialist__r.Email, Genesys_Care_Ops__c, Genesys_Care_Ops__r.Email FROM Account WHERE Id = :accountSelection.AccountId];
	    	Account soldToAccount = [SELECT id, Name, Region__c FROM Account WHERE Id = :targetSoldTo.AccountId];
	     	if(Regional_Controller_List__c.getInstance(endUserAccount.Region__c) != NULL){
	     		User userObj = [Select id from User where username = :Regional_Controller_List__c.getInstance(endUserAccount.Region__c).Regional_Controller_User__c];
	     		if(userObj != NULL)
	     			regionalController = userObj.id;	
	     	}
	     	// Temporarily set for testing
	     	// regionalController = UserInfo.getUserId();
	     	Sold_To_Transfer_Request_Header__c soldToTransferHeader = new Sold_To_Transfer_Request_Header__c();
	     	soldToTransferHeader.Account__c = accountSelection.AccountId;
	     	soldToTransferHeader.Target_Sold_To__c = targetSoldTo.AccountId;
	     	soldToTransferHeader.Regional_Controller__c = regionalController;
	     	soldToTransferHeader.Status__c = 'New'; 
	     	insert soldToTransferHeader;
	     	
	     	List<Sold_To_Transfer_Request_Detail__c> soldToTransferDetails = new List<Sold_To_Transfer_Request_Detail__c>();
	     	for(ServiceContractWrapper scw : serviceContracts){
	     		if(scw.selected)
					soldToTransferDetails.add(new Sold_To_Transfer_Request_Detail__c(Sold_To_Transfer_Request_Header__c = soldToTransferHeader.id, Original_Service_Contract__c = scw.sc.Id));
	     	}
	     	insert soldToTransferDetails;
	     	
	     	return new PageReference('/'+ soldToTransferHeader.Id);     		
     	} else {
     		return null;
     	}
     }
     
     public class ServiceContractWrapper {
     	public ServiceContract sc {get; set;}
     	public Boolean selected {get; set;}
     	
     	public ServiceContractWrapper(ServiceContract scInput){
     		this.sc = scInput;
     		selected = false;
     	}
     }
}