public class SubscriptionBurstTerm {
    public SubscriptionBurstTerm() {

    }

    public Subscription_Burst_Term__c addTermToQuote(String quoteId) { 
        if ( String.isEmpty(quoteId) )
           return null;
        
        Subscription_Burst_Term__c term;
        List<BigMachines__Quote_Product__c> prods = getBurstableQuoteProducts(quoteId);

        if ( prods != null && !prods.isEmpty() ) {
            term = new Subscription_Burst_Term__c(Quote__c = quoteId);
            insert term;
            
            Map<Id, BigMachines__Quote_Product__c> brsrprods = new Map<Id, BigMachines__Quote_Product__c>();         
            for (BigMachines__Quote_Product__c qtprd : prods) {               
               brsrprods.put(qtprd.Id, createBurstQuoteProdFromCommitedProd(qtprd, term.Id, quoteId));
            }

            if (brsrprods.size() == 0 || !addBurstProducts(brsrprods) )
                 delete term;
        }       
        return term;
    }

    public static Map<Id, Id> addTermToAmend (String subscrId, String quoteId) { 
        Map<Id, Id> termOldToNewId = new Map<Id, Id>();

        if (!String.isEmpty(quoteId) && !String.isEmpty(subscrId))  {
            List<Subscription_Burst_Term__c> subtrms = [SELECT Id, Term_Length_Months__c FROM Subscription_Burst_Term__c WHERE CCDB_Subscription__c = :subscrId];

            for (Subscription_Burst_Term__c trm : subtrms) {
                Subscription_Burst_Term__c amendTrm = new Subscription_Burst_Term__c(Quote__c = quoteId, Term_Length_Months__c = trm.Term_Length_Months__c,
                                                                                     CCDB_Subscription_Burst_Term__c = trm.Id);
                insert amendTrm;
                termOldToNewId.put(trm.Id, amendTrm.Id);
            } 
        }       
        return termOldToNewId;
    }

    public static List<BigMachines__Quote_Product__c> getBurstableQuoteProducts(String quoteId) {
       if ( String.isEmpty(quoteId) )
           return null;

        List<BigMachines__Quote_Product__c> prods = [SELECT id, Name, Bundle__c, BigMachines__Product__c, Bundle_Line__c,Weightage__c,Unit_of_Measure__c
                                                    FROM BigMachines__Quote_Product__c 
                                                    WHERE BigMachines__Quote__c = :quoteId
                                                    AND Subscription_Burst_Term__c = null
                                                    AND (BigMachines__Product__r.Seasonal_Licensing_Eligible__c = true OR
                                                         Bundle_Line__r.BigMachines__Product__r.Seasonal_Licensing_Eligible__c = true)];

       return prods;
    }

    public BigMachines__Quote_Product__c createBurstQuoteProdFromCommitedProd(BigMachines__Quote_Product__c qtprd, String termId, String quoteId) {
         BigMachines__Quote_Product__c bprd = qtprd.clone(false,true,false,false);
         bprd.Name = qtprd.Name.endsWith('BURST') || qtprd.Name.length()>83 ? qtprd.Name : qtprd.Name + '-BURST';
         bprd.Bundle__c = qtprd.Bundle__c;
         bprd.Bundle_Line__c = qtprd.Bundle_Line__c; //ORIGINAL ID, WILL REPLACE WITH NEW BUNDLE LINE ON INSERT
         bprd.Weightage__c = qtprd.Weightage__c;
         bprd.BigMachines__Quote__c = quoteId;
         bprd.Parent_Quote_Product__c = qtprd.id;
         bprd.Subscription_Burst_Term__c = termid;
         bprd.Quantity__c = bprd.BigMachines__Quantity__c = 0;
         bprd.Net_Unit_Price__c = bprd.Ext_Net_Price__c = bprd.Ext_List__c = 0;
         bprd.BigMachines__Sales_Price__c = 0;
         bprd.Weightage__c = qtprd.Weightage__c;
         bprd.Unit_of_Measure__c = qtprd.Unit_of_Measure__c;
         bprd.Is_Overage__c = true; 
         bprd.Total_Discount__c = bprd.Disc__c = null;

         ///TODO - List_Price if amendment??
         return bprd;
    }

    public static Boolean isQuoteBurstable(String quoteId) {
        List<BigMachines__Quote_Product__c> prds = getBurstableQuoteProducts(quoteId);
        //individual bundled products not counted
        Boolean isburstable = false;
        for (BigMachines__Quote_Product__c pr : prds) {
            if ( pr.Bundle_Line__c == null) {
                isburstable = true;
                break;
            }
        }
        return isburstable;       
    }

    public static List<Subscription_Burst_Term__c> getQuoteBurstTerms(String quoteId) {
        List<Subscription_Burst_Term__c> terms = new List<Subscription_Burst_Term__c> ();

        if ( !String.isEmpty(quoteId) )   
           terms = [SELECT Id, Name, Term_Length_Months__c, Quote__c, Comment__c, CCDB_Subscription__c, CCDB_Subscription_Burst_Term__c
                    FROM Subscription_Burst_Term__c WHERE Quote__c = :quoteId]; 
        
        return terms;
    }

    public void deleteBlankQuoteTerm(String termId) {
        if ( String.isEmpty(termId) )
           return;

        List<BigMachines__Quote_Product__c> qtprods = [SELECT Id FROM BigMachines__Quote_Product__c 
                                                      WHERE Subscription_Burst_Term__c = :termId 
                                                      AND Subscription_Burst_Term__r.CCDB_Subscription__c = null];
        if ( qtprods.isEmpty() ) {
            Subscription_Burst_Term__c term = new Subscription_Burst_Term__c(id=termId);
            delete term;
        }        
    }

    public void deleteQuoteBurstTerm(String termId) {
        if ( String.isEmpty(termId) )
           return;

        List<BigMachines__Quote_Product__c> qtprods = [SELECT Id FROM BigMachines__Quote_Product__c WHERE Subscription_Burst_Term__c = :termId];
        if ( qtprods.size() > 0 )
           delete qtprods;

        ///don't delete if term is linked to a CCDB 
        List<Subscription_Burst_Term__c> term = [SELECT CCDB_Subscription__c, Quote__c FROM Subscription_Burst_Term__c WHERE Id = :termId];
        if ( !term.isEmpty() ) {
            if ( term[0].CCDB_Subscription__c != null ) {
                term[0].Quote__c = null;
                update term[0];
            }
            else 
                 delete term[0];
        }
    }

    public void addMissingBurstProdsToQuote(String quoteId) {
         if ( String.isEmpty(quoteId) )
           return;
         
         List<Subscription_Burst_Term__c> terms = [SELECT Id, (SELECT BigMachines__Product__c FROM BigMachines_Quote_Products__r) 
                                                   FROM Subscription_Burst_Term__c WHERE Quote__c = :quoteId];
         if ( !terms.isEmpty() ) {
               List<BigMachines__Quote_Product__c> qtprds = getBurstableQuoteProducts(quoteId);

               if ( !qtprds.isEmpty() ) {   
                    Map<Id,BigMachines__Quote_Product__c> brsrprods = new Map<Id,BigMachines__Quote_Product__c>();
                    for ( BigMachines__Quote_Product__c pr : qtprds) {

                        for (Subscription_Burst_Term__c trm : terms) {
                           Boolean found = false;
                           for (BigMachines__Quote_Product__c trmprd : trm.BigMachines_Quote_Products__r) {
                                if ( trmprd.BigMachines__Product__c == pr.BigMachines__Product__c) {
                                    found = true;
                                    break;
                                }
                           }                                                       
                            if (!found)
                                brsrprods.put(pr.Id, createBurstQuoteProdFromCommitedProd(pr, trm.Id, quoteId));
                        }
                    }
                    if (brsrprods.size() > 0)
                      Boolean added = addBurstProducts(brsrprods);
               }
         }       
    }

    public Boolean addBurstProducts(Map<Id,BigMachines__Quote_Product__c> clonedLines) {
        Boolean added = false;
        Map<Id, Id> bundleLineIdMapping = new Map<Id, Id>();
        List<BigMachines__Quote_Product__c> unbundled = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> bundleItems = new List<BigMachines__Quote_Product__c>();

        //1. Insert unbundled line items
        for (Id oldId : clonedLines.keySet()) {
           if (clonedLines.get(oldId).Bundle__c == null)
              unbundled.add(clonedLines.get(oldId));
        }
        if ( unbundled.size() > 0 ) {
           insert unbundled; 
           added = true;
        }
        //2. Insert bundle headers
        for (Id oldId : clonedLines.keySet()) {
           if (clonedLines.get(oldId).Bundle__c != null && clonedLines.get(oldId).Bundle_Line__c == null) {
               BigMachines__Quote_Product__c bndl = clonedLines.get(oldId);           
               insert bndl;
               added = true;
               ///map bundle old id to bundle new id
               bundleLineIdMapping.put(oldId, bndl.Id );          
           }             
        }
        //3. Insert bundle line items
        for (Id oldId : clonedLines.keySet()) {
           if (clonedLines.get(oldId).Bundle__c != null && clonedLines.get(oldId).Bundle_Line__c != null) {               
              //map and reassign Bundle_Line__c Id 
              if ( bundleLineIdMapping.containsKey(clonedLines.get(oldId).Bundle_Line__c) ) {                  
                   clonedLines.get(oldId).Bundle_Line__c = bundleLineIdMapping.get(clonedLines.get(oldId).Bundle_Line__c);
                   bundleItems.add(clonedLines.get(oldId));
              }
          }
        }
        if ( bundleItems.size() > 0 )
           insert bundleItems; 

        return added;
    }

    ///method to synch bundle line items with the header amounts
    public static List<BigMachines__Quote_Product__c> updateBurstBasePackageItems(List<BigMachines__Quote_Product__c> list_QuoteProductRecords,
                                                                                  List<BigMachines__Quote_Product__c> basePackLineItems) {
      
       List<BigMachines__Quote_Product__c> updatedPkLines = new List<BigMachines__Quote_Product__c>();

        //for each Base Package header find and update line items
        for ( BigMachines__Quote_Product__c qtline : list_QuoteProductRecords ) {
            if ( qtline.Subscription_Burst_Term__c != null && qtline.Bundle__c != null && qtline.Bundle_Line__c == null ) {

               //find and update line items
               for (BigMachines__Quote_Product__c packline : basePackLineItems) {

                    if (packline.Bundle_Line__c != null && packline.Bundle_Line__c == qtline.Id) {                     
                        Decimal weight = packline.Weightage__c == null ? 0 : packline.Weightage__c / 100;  

                        if (packline.Weightage__c == null ) {
                            packline.Quantity__c = packline.BigMachines__Quantity__c = 0;
                            continue;
                        }
                        else if (packline.Weightage__c == 0 && qtline.Quantity__c != null && qtline.Quantity__c != 0) {
                            packline.Quantity__c = packline.BigMachines__Quantity__c = 1; 
                        }
                        else                          
                        packline.Quantity__c = packline.BigMachines__Quantity__c = qtline.Quantity__c;
                        
                        packline.List_Price__c = qtline.List_Price__c * weight;  
                        packline.List_Price_1__c = qtline.List_Price_1__c * weight;  
                        packline.List_Price_2__c = qtline.List_Price_2__c * weight;

                        packline.Partner_Price__c = qtline.Partner_Price__c * weight; 
                        packline.Partner_Price_1__c = qtline.Partner_Price_1__c * weight;   
                        packline.Partner_Price_2__c = qtline.Partner_Price_2__c * weight;   
                                    
                        packline.Ext_List__c =   qtline.Ext_List__c * weight;
                        packline.Ext_List_Price_1__c = qtline.Ext_List_Price_1__c * weight; 
                        packline.Ext_List_Price_2__c = qtline.Ext_List_Price_2__c * weight; 

                        packline.Net_Unit_Price__c  = qtline.Net_Unit_Price__c * weight; 
                        packline.Net_Unit_Price_1__c = qtline.Net_Unit_Price_1__c * weight; 
                        packline.Net_Unit_Price_2__c = qtline.Net_Unit_Price_2__c * weight; 

                        packline.Ext_Net_Price__c = qtline.Net_Unit_Price__c * weight;
                        packline.Ext_Net_Price_1__c = qtline.Net_Unit_Price_1__c * weight ;
                        packline.Ext_Net_Price_2__c = qtline.Net_Unit_Price_2__c * weight ;

                        packline.BigMachines__Sales_Price__c = packline.Net_Unit_Price__c; 
                        updatedPkLines.add(packline); 
                    }
               }
            }
        } 
        return updatedPkLines;
    }

    public static void setCommitQtyOnBurstSubscrProd(List<Subscription_Product__c> subscrProds) { 
        if (subscrProds == null || subscrProds.isEmpty())
           return;

        //get committed products with quant.
        Map<Id, Decimal> committedProds = new Map<Id, Decimal>();
        for (Subscription_Product__c cpd : subscrProds) {
            if ( cpd.Subscription_Burst_Term__c == null && cpd.Bundle__c == null )
               committedProds.put( cpd.Product__c, cpd.Quantity__c);
        }

        //set committed quantity on Bursted products
        if ( !committedProds.isEmpty() )  {
            for (Subscription_Product__c bpd : subscrProds) {
                if ( bpd.Subscription_Burst_Term__c != null && bpd.Bundle__c == null ) {
                    if ( committedProds.containsKey(bpd.Product__c))
                       bpd.Committed_Quantity__c = committedProds.get(bpd.Product__c);
                }
            }
         }
         return;
    }
}