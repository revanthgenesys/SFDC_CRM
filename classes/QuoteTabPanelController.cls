//Naresh Kumar	03/21/2017 Quote tab panel controller
public class QuoteTabPanelController {
    //quote object
    public BigMachines__Quote__c objQuote;
    //whether the portal user is logged in or not
    public Boolean blnIsPartner {get; private set;}
    
	public BigMachines__Quote__c getObjQuote() {
        String strQuoteId = ApexPages.currentPage().getParameters().get('id');
        if(strQuoteId != null){
            //querying the quote object
            return [SELECT Show_Genesys_Care_Tab__c, Offering_Type__c FROM BigMachines__Quote__c 
                   WHERE id =:strQuoteId LIMIT 1];
        }
        else{
            return null;
        }
  	}
	
    
    public QuoteTabPanelController(){
        blnIsPartner = UserInfo.getUserType() == 'PowerPartner';        
    }
}