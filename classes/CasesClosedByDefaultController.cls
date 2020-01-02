public class CasesClosedByDefaultController {
	
    public List<CCBDDetail> CCBDDetails {get; set;}
    public String period {get; set;}
    public String accountId {get; set;}
    public CasesClosedByDefaultController(){
        period = ApexPages.currentPage().getParameters().get('period');
        accountId = ApexPages.currentPage().getParameters().get('aId');

        CCBDDetails = new List<CCBDDetail>();
        for(Cases_Closed_By_Default_Detail__c cdetails : [SELECT id, Name, Case_Number__c, Contact_Name__c, Case_Owner__c FROM Cases_Closed_By_Default_Detail__c WHERE Partner_Account__c = :accountId AND Period__c = :period Order By Contact_Name__c,Case_Number__c]){
            CCBDDetails.add(new CCBDDetail(cdetails.Case_Number__c, cdetails.Contact_Name__c, cdetails.Case_Owner__c));
        }    
    }
    
    public class CCBDDetail{
        public String caseNumber { get; set; }
        public String contactName { get; set; }
        public String ownerName { get; set; }
        public CCBDDetail(String caseNumber, String contactName, String ownerName) {
            this.caseNumber = caseNumber;
            this.contactName = contactName;
            this.ownerName = ownerName;
        }
    }
}