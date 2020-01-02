public with sharing class ServiceContracts360Controller {
	List<BigMachines__Quote__c> quoteCont = new List<BigMachines__Quote__c>();
 	String id ;
  	
  	public ServiceContracts360Controller (ApexPages.StandardController stdController) {
    	Id =stdController.getId();
    }
  	
  	public ServiceContracts360Controller () { 
  	}
  
  	public String getId() {
  		return Id;
  	}
  	
  	public List<BigMachines__Quote__c> getSc() {
  		String id=System.currentPageReference().getParameters().get('id');
    	System.debug('vvv'+id);
    	List<Quote_Service_Contracts__c> quoteSc = [Select id,Quote__c from Quote_Service_Contracts__c where Service_Contract__c=:id and Quote__c != null];
    	System.debug('vvv'+quoteSc);
    	if(!quoteSc.isempty()) {
        	for(Quote_Service_Contracts__c temp:quoteSc ){
        		BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where id=:temp.Quote__c];
        		quoteCont.add(quote);
	        }
	    }
	  	List<ContractLineItem> contLine = [Select id from ContractLineItem where ServiceContractId=:id];
	  	List<String> lines =new List<String>();
	  	if(!contLine.isempty()){
	   		for(ContractLineItem temp2:contLine)
	    		lines.add(temp2.id);
	  	}
	     
	  	List<BigMachines__Quote__c> quotes = [select id,Name,CreatedDate,BigMachines__Status__c, (select APN_Number__c,Contract_Line_Update_Status__c,BigMachines__Product__r.Name,BigMachines__Product__r.description,BigMachines__Quantity__c,Maintenance_Start_Date__c,Maintenance_End_Date__c,Revised_Net_License_Value__c,Status__c from BigMachines__BigMachines_Quote_Products__r where Service_Contract_Line_ID__c IN :lines) from BigMachines__Quote__c where id In :quoteCont];
	  	return quotes;  
  	}
}