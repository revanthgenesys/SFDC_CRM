public class MyCustomVFPage_CTR {
    public String Id {get;set;}
    public String ResponseCode {get;set;}
    public MyCustomVFPage_CTR () {
        Id = ApexPages.currentPage().getParameters().get('id');     
        ResponseCode = ApexPages.currentPage().getParameters().get('ResponseCode');
  
    }
    public PageReference InitPage() {
        List<Deal_Qualification__c> stat = [SELECT Order_Mgmt_Billing_approval__c
, Req_Order_Mgmt_Billing_approval__c,Status__c FROM Deal_Qualification__c WHERE Id=:Id LIMIT 1];
        if(!stat.IsEmpty()){
        if((stat[0].Req_Order_Mgmt_Billing_approval__c==true )&&(stat[0].Status__c=='Approval Pending'))
        {
            stat[0].Order_Mgmt_Billing_approval__c= ResponseCode;
            update stat;
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.info,'Thanks for the response' );
            ApexPages.addmessage(msg); 
            }    
                else{
         ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'Authorization Required' );
         ApexPages.addmessage(msg);
        
        }}
        return null;
    }
}