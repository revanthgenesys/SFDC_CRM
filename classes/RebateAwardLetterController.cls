/**
 * @Author      	: Narasimha Rao Tumma
 * @Created Date	: Dec 14, 2015
 * @Org. Release	: Dec 2015
 * @Description 	: Controller class for generating the Partner Earned Rebate Award Letter.
 * @Test Class  	: EarnedRebateClassesTest
 * @Modifications	: 
*/
public class RebateAwardLetterController {
    public Partner_Rebate__c rebate {get; set;}
	public Decimal careRevenue {get; set;}
	public Decimal licenseRevenue {get; set;}
	public Decimal saasRevenue {get; set;}
    public Decimal solutionMultiplier {get; set;}

    public User pUser {get; set;}
    public Integer rebateNextYear {get; set;}        
    public String rebateYear {get; set;}  

    private String userId;
    private String accountId; 
    public RebateAwardLetterController(){
        rebate = NULL;
        userId = UserInfo.getUserId();
        
		// Collect Parameters from Page URL
        rebateYear = ApexPages.currentPage().getParameters().get('ry');
        accountId = ApexPages.currentPage().getParameters().get('lua');
        
        rebateNextYear = Integer.valueOf(rebateYear) + 1;
        
        List<Partner_Rebate__c> rebateList = [SELECT Rebate_Name__c,Rebate_Year__c,Start_Date__c,End_Date__c,Earned_Genesys_Care_Amount__c,
                                                Earned_License_Amount__c,Earned_SaaS_Amount__c,Publish_Earned_Amounts_to_Partner_Portal__c,
                                                Amount__c,License_Amount__c,SaaS_Amount__c,Agree_Disagree_Flag__c,CurrencyIsoCode,
                                                Published_to_Partner_Portal__c, Partner_Name__r.Name, Total_Earned_Rebate__c
                                                FROM  Partner_Rebate__c 
                                                WHERE Partner_Name__c = :accountId AND Agree_Disagree_Flag__c = true
                  								AND Rebate_Year__c = :rebateYear AND Publish_Earned_Amounts_to_Partner_Portal__c = True];
        
        pUser = [select id, Name, ContactId, Contact.Name FROM User WHERE Id = :userId];
        
        If(rebateList != NULL && rebateList.size() > 0){
            rebate = rebateList[0];

			// Care Revenue             
            Set<String> gcaRevenueTypes 	= new Set<String>(Partner_Revenue_Mapping__c.getValues('Maintenance').Revenue_Type__c.split(','));
            AggregateResult[] careGroupedResults  = [SELECT SUM(Revenue_Amount__c) revenue FROM Partner_EndUser_Data__c 
                                                 WHERE Account__c  = :accountId AND Revenue_Year__c = :rebateYear 
                                                 AND Revenue_Type__c IN :gcaRevenueTypes];
			careRevenue = (Decimal)careGroupedResults[0].get('revenue');
			

			// License Revenue
			Set<String> licenseRevenueTypes = new Set<String>(Partner_Revenue_Mapping__c.getValues('License').Revenue_Type__c.split(','));
            AggregateResult[] licenseGroupedResults  = [SELECT SUM(Revenue_Amount__c) revenue FROM Partner_EndUser_Data__c 
                                                 WHERE Account__c  = :accountId AND Revenue_Year__c = :rebateYear 
                                                 AND Revenue_Type__c IN :licenseRevenueTypes];
			licenseRevenue = (Decimal)licenseGroupedResults[0].get('revenue');
            
			// SAAS Revenue
			Set<String> saasRevenueTypes 	= new Set<String>(Partner_Revenue_Mapping__c.getValues('SaaS').Revenue_Type__c.split(','));
            AggregateResult[] saasGroupedResults  = [SELECT SUM(Revenue_Amount__c) revenue FROM Partner_EndUser_Data__c 
                                                 WHERE Account__c  = :accountId AND Revenue_Year__c = :rebateYear 
                                                 AND Revenue_Type__c IN :saasRevenueTypes];
			saasRevenue = (Decimal)saasGroupedResults[0].get('revenue');

            // Solution Multiplier
            AggregateResult[] smGroupedResults  = [SELECT SUM(Solutions_Multiplier__c) revenue FROM Partner_EndUser_Data__c WHERE Account__c  = :accountId AND Revenue_Year__c = :rebateYear];
        	solutionMultiplier = (Decimal)smGroupedResults[0].get('revenue');
        }
        
            
    }
}