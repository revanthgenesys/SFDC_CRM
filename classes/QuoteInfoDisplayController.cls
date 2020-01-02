public with sharing class QuoteInfoDisplayController {
   // public BigMachines__Quote__c quoteOpp { get{ return getQuoteOppFields();} set; }
    public Order__c ord {get;set;}
    public  BigMachines__Quote__c quote{get;set;}
    public boolean show_newquote{get;set;}
    public boolean  show_oldquote{get;set;}
    
   /* public List<Schema.FieldSetMember> fieldSetMembers {get{
                                                            //if(fieldSetMembers == null){
                                                                Map<String, Schema.FieldSet> fieldsets = getFields();
                                                                if(Apexpages.currentPage().getUrl().contains( 'QuoteInfoDisplay' )){
                                                                        this.fieldSetMembers =fieldsets.get('Order_Quote_Fields').getFields();
                                                                    }
                                                                if(Apexpages.currentPage().getUrl().contains( 'QuoteSalesInfoDisplay' )) {
                                                                        this.fieldSetMembers =fieldsets.get('Quote_Sales_Info').getFields();
                                                                }
                                                            //}
                                                            system.debug(fieldSetMembers);
                                                            return fieldSetMembers;
                                                        } set;}*/
    
    
    public QuoteInfoDisplayController( ApexPages.Standardcontroller controller ) {
        ord = (Order__c)controller.getRecord();
        ord = [Select id,opportunity__c,quote__c from order__c where id=: ord.id];
        if(ord.quote__c != null){   
         show_newquote = true;

          quote = Query_QuoteInfo_Fieldset();
          
          }else{    
             show_oldquote = true;

          ord = Query_OrderInfo_Fieldset();            
          }    
  //this.quoteOpp = getQuoteOppFields();
        //system.debug(quoteOpp);
    }

/*   public Map<String, Schema.FieldSet> getFields() {
              
           if(ord.quote__c!=null)
            return BigMachines__Quote__c.SObjectType.getDescribe().FieldSets.getMap();
          
           //SObjectType.Order__c.FieldSets.Basic_Order_Fields.getFields();
    }*/
    
     public List<Schema.FieldSetMember> getFields_Orders() {
          return SObjectType.Order__c.FieldSets.Migrated_Order_Fields.getFields();
     }
             
     public List<Schema.FieldSetMember> getFields_Orders_SalesInfo() {
          return SObjectType.Order__c.FieldSets.Order_Sales_Info.getFields();
      }
             
     public List<Schema.FieldSetMember> getFields_Quote() {
          return SObjectType.BigMachines__Quote__c.FieldSets.Order_Quote_Fields.getFields();
      }
      public List<Schema.FieldSetMember> getFields_Quote_SalesInfo() {
          return SObjectType.BigMachines__Quote__c.FieldSets.Quote_Sales_Info.getFields();
      }
        
     private BigMachines__Quote__c Query_QuoteInfo_Fieldset() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields_Quote()) {
            query += f.getFieldPath() + ', ';
        }
        
        for(Schema.FieldSetMember f : this.getFields_Quote_SalesInfo()) {
            query += f.getFieldPath() + ', ';
        }
       
         query += 'Id FROM BigMachines__Quote__c where id=\'' + ord.quote__c + '\' LIMIT 1';
         
        return Database.query(query);
      }
    
      private Order__c Query_OrderInfo_Fieldset() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields_Orders()) {
            query += f.getFieldPath() + ', ';
        }
         for(Schema.FieldSetMember f : this.getFields_Orders_SalesInfo()) {
            query += f.getFieldPath() + ', ';
        }
         query += 'Id FROM Order__c where id=\'' + ord.id + '\' LIMIT 1';
        return Database.query(query);
      }
    


   /* private BigMachines__Quote__c getQuoteOppFields() {
    
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : fieldSetMembers) {
            query += f.getFieldPath() + ', ';
        }
        //System.debug(opp.Id);
               
        if(ord.quote__c != null){
        query += 'Id FROM BigMachines__Quote__c where id =  \'' + ord.quote__c + '\'  limit 1';
        system.debug(query);
        //return null;
        return Database.query(query);
    }*/
    
}