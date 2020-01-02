//Naresh Kumar	11/22/2018	Helper class for order trigger. Contains DMLs in future methods
public class OrderTriggerHelperFuture {
    
    @future
    public static void updateOpportunityBookingStatus(Id oppId, String orderNumber){
        Opportunity objOpp = new Opportunity(id = oppId);
    	objOpp.ForecastStatus__c = '0.Booked';
        if(orderNumber != null)
        	objOpp.SAPRevenueOrderNo__c = orderNumber;
        update objOpp;                 
    }
    
    @future
    public static void updateAccountSupportOption(Id accountId, String supportOption){
        Account objAcc = new Account(id = accountId);
        objAcc.Support_Option__c = supportOption;
		update objAcc;        
    }

}