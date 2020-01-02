public class QuoteProductsEmailClass {
    private final List<BigMachines__Quote_Product__c> cProduct;
    public Id quoteId {get; set;}

    

    public List<BigMachines__Quote_Product__c> getProduct() {
       System.debug('Vikram' + quoteId);
        /*Add a NULL check here*/
        if(quoteId != NULL){
            List<BigMachines__Quote_Product__c> cProduct=
                [
                    SELECT
                        Product_Description__c,Discount__c,Total_Discount__c
                    FROM
                        BigMachines__Quote_Product__c
                    WHERE
                        BigMachines__Quote__c = :quoteId
                      and Total_Discount__c <> null
                   
                    LIMIT 20
                ];
                   
            /*Add a NULL check here too*/
            if(cProduct!=NULL && cProduct.size()>0)
                return cProduct;
        }
       
        return NULL;
    }
}