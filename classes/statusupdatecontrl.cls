public class statusupdatecontrl {
   public Deal_Qualification__c getid() {
        return [SELECT Status__c,Order_Mgmt_Billing_approval__c ,Req_Order_Mgmt_Billing_approval__c FROM Deal_Qualification__c
                WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
    }

}