public with sharing class Show_Quote_Order_Info {
public Order__c ord {get;set;}
public  BigMachines__Quote__c quote{get;set;}
 public boolean show_quote{get;set;}
    public boolean  show_order{get;set;}

    public Show_Quote_Order_Info(ApexPages.StandardController controller) {
    
    quote = (BigMachines__Quote__c )controller.getRecord();
    List<order__c> ord_lst = Query_OrderInfo_Fieldset(); 
    if(ord_lst.size()>0){
    ord = ord_lst[0];
    show_order = true;
    }else{
    show_quote = true;
    quote = Query_QuoteInfo_Fieldset(); 
    }
    }
 public List<Schema.FieldSetMember> getFields_Orders() {
          return SObjectType.Order__c.FieldSets.Quote_Orders_Fields.getFields();
             }
             
 public List<Schema.FieldSetMember> getFields_Quote() {
          return SObjectType.BigMachines__Quote__c.FieldSets.Quote_Order_Fields.getFields();
             }         

 private List<Order__c> Query_OrderInfo_Fieldset() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields_Orders()) {
            query += f.getFieldPath() + ', ';
        }
         query += 'Id FROM Order__c where Quote__c =\'' + quote.id + '\'  and (License_FYM_detail__c= \'Maintenance Only Order\' or License_FYM_detail__c= \'Both License & Maintenance Order\')  LIMIT 1';
        return Database.query(query);
      }
private BigMachines__Quote__c  Query_QuoteInfo_Fieldset() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields_Quote()) {
            query += f.getFieldPath() + ', ';
        }
         query += 'Id FROM BigMachines__Quote__c where id =\'' + quote.id + '\' LIMIT 1';
        return Database.query(query);
      }

}