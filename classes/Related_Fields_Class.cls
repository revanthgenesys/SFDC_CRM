public without sharing class  Related_Fields_Class {

public BigMachines__Quote__c quot{get;set;}
public ServiceContract SC{get;set;}
public order__c ord{get;set;}
public opportunity opp{get;set;}
public opportunity oppid{get;set;}
public string str_fieldset;
public boolean show_newquote{get;set;}
public boolean  show_oldquote{get;set;}
public string show_query{get;set;}

    public Related_Fields_Class(ApexPages.StandardController controller) {
        
        SC = (ServiceContract)controller.getRecord();
        SC = [select id,Renewal_Opportunity__c,Renewal_Opportunity__r.name,Quote_Name__c,Order__c from ServiceContract where id=: SC.id];
        oppid = new opportunity(id=SC.Renewal_Opportunity__c,name=SC.Renewal_Opportunity__r.name);
        
        opp = Query_Opp_Info_Fieldset();
       
        if(SC.Quote_Name__c != null){
            str_fieldset = 'QuoteInfo';
            show_newquote = true;
            quot = Query_QuoteInfo_Fieldset();
            } else {
            str_fieldset = 'SCQuoteInfo';
            show_oldquote = true;
            SC = Query_SCQuoteInfo_Fieldset();
            }
          if(SC.Order__c!=null)
            ord = Query_Order_Info_Fieldset();
        
    }
    
    public List<Schema.FieldSetMember> getFields() {
    if(str_fieldset == 'QuoteInfo')
        return SObjectType.BigMachines__Quote__c.FieldSets.Quote_Info_Fields.getFields();
    if(str_fieldset == 'SCQuoteInfo')
        return SObjectType.ServiceContract.FieldSets.ServiceContract_Quote_Fields.getFields();
        
    else
    return null;    
    }
    
    public List<Schema.FieldSetMember> getFields_Fees() {
    if(str_fieldset == 'QuoteInfo')
        return SObjectType.BigMachines__Quote__c.FieldSets.Quote_Fees_Uplift_Value_Add.getFields();
    if(str_fieldset == 'SCQuoteInfo')
        return SObjectType.ServiceContract.FieldSets.ServiceContract_Quote_Fees_Uplift.getFields();
        
    else
    return null;    
    }
    
     public List<Schema.FieldSetMember> getFields_Quote_SalesInfo() {
          if(str_fieldset == 'QuoteInfo')
          return SObjectType.BigMachines__Quote__c.FieldSets.Quote_Sales_Info.getFields();
          if(str_fieldset == 'SCQuoteInfo')
            return SObjectType.ServiceContract.FieldSets.SC_Sales_Info.getFields();
        
          else 
          return null;
      }
    
     public List<Schema.FieldSetMember> getFields_Orders() {
          return SObjectType.Order__c.FieldSets.Basic_Order_Fields.getFields();
      }
    
       public List<Schema.FieldSetMember> getFields_Opp() {
          return SObjectType.Opportunity.FieldSets.Service_Contract_Fields.getFields();
      }  
       
      private Opportunity Query_Opp_Info_Fieldset() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields_Opp()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM Opportunity where id=\'' + SC.Renewal_Opportunity__c + '\' LIMIT 1';
        return Database.query(query);
    } 
   
      private Order__c Query_Order_Info_Fieldset() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields_Orders()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM Order__c where id=\'' + SC.Order__c + '\' LIMIT 1';
        return Database.query(query);
    }
    
    private BigMachines__Quote__c Query_QuoteInfo_Fieldset() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        for(Schema.FieldSetMember f : this.getFields_Fees()) {
            query += f.getFieldPath() + ', ';
        }
        for(Schema.FieldSetMember f : this.getFields_Quote_SalesInfo()) {
            query += f.getFieldPath() + ', ';
        }        
        query += 'Id FROM BigMachines__Quote__c where id=\'' + SC.Quote_Name__c + '\' LIMIT 1';
        return Database.query(query);
    }
    
    private ServiceContract Query_SCQuoteInfo_Fieldset() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
         for(Schema.FieldSetMember f : this.getFields_Fees()) {
            query += f.getFieldPath() + ', ';
        }
          for(Schema.FieldSetMember f : this.getFields_Quote_SalesInfo()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id,order__c FROM ServiceContract where id=\'' + SC.id + '\' LIMIT 1';
        show_query = query;
        return Database.query(query);
    }

}