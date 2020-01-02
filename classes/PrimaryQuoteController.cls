public with sharing class PrimaryQuoteController {
        //public Opportunity quoteOpp { get{ return getPrimaryQuoteOppFields();} set; }
        public Opportunity opp;
        public boolean isOrder {get;set;}
        public boolean isRed {get;set;}
        public Order__c ord {get;set;}
    public  BigMachines__Quote__c quote{get;set;}
    public  BigMachines__Quote__c quote_BUsers{get;set;} //Ravi added for displaying primary quote data for new VF page
    public boolean show_newquote{get;set;}
    public boolean  show_oldquote{get;set;}
        
 /*     public List<Schema.FieldSetMember> fieldSetMembers {get{
                                                                                                                        //if(fieldSetMembers == null){
                                                                                                                                Map<String, Schema.FieldSet> fieldsets = getFields();
                                                                                                                                if(Apexpages.currentPage().getUrl().contains( 'PrimaryQuoteInfo' )){
                                                                                                                                        this.fieldSetMembers =fieldsets.get('Primary_Quote_Info').getFields();
                                                                                                                                }
                                                                                                                                else{
                                                                                                                                        this.fieldSetMembers =fieldsets.get('Fees_Uplifts_and_Value_Add').getFields();
                                                                                                                        }
                                                                                                                        //}
                                                                                                                        system.debug(fieldSetMembers);
                                                                                                                    return fieldSetMembers;
                                                                                                                } set;}*/
    
    public PrimaryQuoteController( ApexPages.Standardcontroller controller ) {
        opp  = (Opportunity)controller.getRecord();
        //Opportunity tempOpp = [Select Primary_quote__c from Opportunity where id=:opp.id];
        Opportunity tempOpp = [Select Primary_quote__c from Opportunity where id=:opp.id];
        list<BigMachines__Quote__c> quot_lst = [select id from BigMachines__Quote__c where BigMachines__Is_Primary__c=:true and BigMachines__Opportunity__c=:opp.id];
        
        //if(tempOpp.Primary_Quote__c == null){
        if(quot_lst.size()>0){
         //isDecline = false;
         isRed= true;
         quote = quot_lst[0];
         quote = Query_PrimayQuote_Fieldset();
         quote_BUsers=Query_PrimayQuote_Fieldset_BUsers(); //Ravi added for displaying primary quote data for new VF page
         List<order__c> ord_lst = [select id from order__c where quote__c =: quote.id and (License_FYM_detail__c=:'Maintenance Only Order' or License_FYM_detail__c= 'Both License & Maintenance Order')limit 1];
         if(ord_lst.size()>0){
         
isOrder =true;         ord= ord_lst[0];
         ord = Query_OrderInfo_Fieldset();
         }  
        }
        else {
         //isDecline = true;
         isRed = false;
        }        
        //this.quoteOpp = getPrimaryQuoteOppFields();
        //system.debug(quoteOpp);
    }
        
        public List<Schema.FieldSetMember> getFields_PrimaryQuote() {
          return SObjectType.BigMachines__Quote__c.FieldSets.Quote_Primary_Fields.getFields();
     }
        
        public List<Schema.FieldSetMember> getFields_PrimaryQuote_Fees() {
          return SObjectType.BigMachines__Quote__c.FieldSets.Quote_Fees_Uplift_Value_Add.getFields();
     }
     
     public List<Schema.FieldSetMember> getFields_Orders() {
          return SObjectType.Order__c.FieldSets.Opportunity_order_Fields.getFields();
     }

  
        private BigMachines__Quote__c Query_PrimayQuote_Fieldset() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields_PrimaryQuote()) {
            query += f.getFieldPath() + ', ';
        }
        
        for(Schema.FieldSetMember f : this.getFields_PrimaryQuote_Fees()) {
            query += f.getFieldPath() + ', ';
        }
       
         query += 'Id FROM BigMachines__Quote__c where id=\'' + quote.id + '\' LIMIT 1';
         
        return Database.query(query);
      }
    
      private Order__c Query_OrderInfo_Fieldset() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields_Orders()) {
            query += f.getFieldPath() + ', ';
        }
       
         query += 'Id FROM Order__c where id=\'' + ord.id + '\' LIMIT 1';
        return Database.query(query);
      }
    
    
    //Ravi added for displaying primary quote data for new VF page
    
    public List<Schema.FieldSetMember> getFields_PrimaryQuote_BUsers()
         {
          return SObjectType.BigMachines__Quote__c.FieldSets.Quote_Primary_Fields_BUsers.getFields();//Getting from Quote field set where we can add more fields
         }
    
    private BigMachines__Quote__c Query_PrimayQuote_Fieldset_BUsers()
      {
        String query = 'SELECT ';
        
         for(Schema.FieldSetMember f : this.getFields_PrimaryQuote_BUsers())
          {
            query += f.getFieldPath() + ', ';
           }
         
         query += 'Id FROM BigMachines__Quote__c where id=\'' + quote.id + '\' LIMIT 1';
        
          return Database.query(query);
       }
        
        
}