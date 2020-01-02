/**
 * @Author      	: Narasimha Rao Tumma
 * @Created Date	: Dec 14, 2015
 * @Org. Release	: Dec 2015
 * @Description 	: Controller class for generating Partner Rebate Requests Statement.
 * @Test Class  	: EarnedRebateClassesTest
 * @Modifications	: 
*/
public class RebateStatementController {
    public String rebateYear {get; set;}  
    public String accountId {get; set;} 
    private String userId;
    
    public Account pAccount {get; set;}
    public User pUser {get; set;}
    
    public Double totalRebateUsed {get; set;} 
    public Double totalRebateInProcess {get; set;} 
    
    public Partner_Rebate__c rebate {get; set;}
    public List<Partner_Rebate_Request__c> rebateRequests {get; set;} 
    
    public RebateStatementController(){
        userId = UserInfo.getUserId();
        rebateYear = ApexPages.currentPage().getParameters().get('ry');
        accountId = ApexPages.currentPage().getParameters().get('lua');

        pAccount = [Select id, Name, Owner.Name, Owner.Title, Owner.Email, Owner.Manager.Name, Owner.Manager.Title, Owner.Manager.Email  from Account WHERE Id = :accountId];
        pUser = [select id, Name, ContactId, Contact.Name FROM User WHERE Id = :userId];
        
        List<Partner_Rebate__c> rebateList = [SELECT Rebate_Name__c,Rebate_Year__c,Start_Date__c,End_Date__c,Earned_Genesys_Care_Amount__c,
                                                Earned_License_Amount__c,Earned_SaaS_Amount__c,Publish_Earned_Amounts_to_Partner_Portal__c,
                                                Amount__c,License_Amount__c,SaaS_Amount__c,Agree_Disagree_Flag__c,CurrencyIsoCode,
                                                Published_to_Partner_Portal__c, Partner_Name__r.Name, Total_Earned_Rebate__c
                                                FROM  Partner_Rebate__c 
                                                WHERE Partner_Name__c = :accountId AND Agree_Disagree_Flag__c = true
                  								AND Rebate_Year__c = :rebateYear AND Publish_Earned_Amounts_to_Partner_Portal__c = True];
        
        If(rebateList != NULL && rebateList.size() > 0)
            rebate = rebateList[0];
        

        rebateRequests = [SELECT Id, Name, Date__c, Expense_Type__c, Requested_Rebate_Amount__c, Status__c, Contact__r.Name 
                          FROM Partner_Rebate_Request__c 
                          WHERE Partner_Account__c = :accountId AND Rebate_Year__c = :rebateYear ORDER BY Date__c, Id];
        totalRebateUsed = 0.0;
        totalRebateInProcess = 0.0;
        for(Partner_Rebate_Request__c prr: rebateRequests){
            if(prr.Status__c == 'Processed')
            	totalRebateUsed +=  prr.Requested_Rebate_Amount__c;
            if(prr.Status__c == 'In-Process')
                totalRebateInProcess += prr.Requested_Rebate_Amount__c;
        }  		
        
        /*
        AggregateResult[] totalRebateUsedResults = [SELECT SUM(Requested_Rebate_Amount__c) total 
							FROM Partner_Rebate_Request__c WHERE Status__c = 'Processed' 
							AND  Partner_Account__c = :accountId AND Rebate_Year__c = :rebateYear];
        totalRebateUsed = (Double)totalRebateUsedResults[0].get('total');

		AggregateResult[] totalRebateInProcessResults = [SELECT SUM(Requested_Rebate_Amount__c) total 
				FROM Partner_Rebate_Request__c WHERE Status__c = 'In-Process' AND  Partner_Account__c = :accountId AND  Rebate_Year__c = :rebateYear];
        totalRebateInProcess = (Double)totalRebateInProcessResults[0].get('total');
		*/
    }
    
    public PageReference redirectToPerformance(){
        return new PageReference('/partner/apex/Performance');
    }
    public PageReference exportToExcel(){
        return new PageReference('/partner/apex/RebateStatementExport');
    }
}