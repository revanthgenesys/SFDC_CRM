//Naresh Kumar	08/30/2017
public class ServiceContractCloneController {
    
    public string serviceContractId {get; private set;}
    public ServiceContract objSC {get; set;}
    
    public ServiceContractCloneController(){
        serviceContractId = ApexPages.currentPage().getParameters().get('id');
		objSC = [SELECT Name, StartDate, EndDate FROM ServiceContract WHERE id =: serviceContractId];
    }
    
    public pageReference cloneSC(){
        String serviceContractSOQL = CloneUtility.getCreatableFieldsSOQL('ServiceContract','id  =\'' + objSC.id + '\'');  
        ServiceContract clonedSC = (ServiceContract)Database.query(serviceContractSOQL);
        clonedSC.id = null;
        clonedSC.StartDate = objSC.StartDate;
        clonedSC.EndDate = objSC.EndDate;
        insert clonedSC;
        clonedSC.Name += ' -1';
        update clonedSC;
        
        String oldServiceContractLineItemsSOQL = CloneUtility.getCreatableFieldsSOQL('ContractLineItem','ServiceContractId  =\'' + objSC.id + '\'');  
		List<ContractLineItem> lineItemsFromOldServiceContract = (List<ContractLineItem>)Database.query(oldServiceContractLineItemsSOQL);
        
        for(ContractLineItem eachCLI : lineItemsFromOldServiceContract){
            eachCLI.id = null;
        	eachCLI.ServiceContractId = clonedSC.id;
            eachCLI.Maintenance_Start_Date__c = clonedSC.StartDate;
            eachCLI.Maintenance_End_Date__c = clonedSC.EndDate;
        }
		insert lineItemsFromOldServiceContract;
        return new PageReference('/' + clonedSC.id);
    }

}