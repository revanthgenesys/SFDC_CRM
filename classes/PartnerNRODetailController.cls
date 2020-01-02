public class PartnerNRODetailController {
        
        public List<Order_Line_Item__c> lineItems {get; set;}
        public String orderId {get; set;}
        public String orderName {get;set;}
        
        public PartnerNRODetailController()  {
                
                orderId = ApexPages.currentPage().getParameters().get('Id');  
        
            if ( orderId != null ) {
                
                try {
                    lineItems = [SELECT Name, Material_Description__c, BigMachines_Quantity__c
                                                          FROM Order_Line_Item__c
                                                          WHERE Order__c = :orderId];                                                                                       
                     
                     
                         List<Order__c> orderLst = [SELECT Name FROM Order__c WHERE Id = :orderId]; 
                         orderName = orderLst[0].Name; 
                }
                catch (Exception ex) {
                        return;
                }
           }
        }
        
        public PageReference goBack() {
                 return new PageReference('/partner/apex/PartnerNROrder');              
        }
}