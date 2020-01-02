public with sharing class Bidding_Cost_Controller {

public Bidding_Cost__c bc {get;set;}
public string retURL {get;set;}
public String oqmId {get;set;}
public String oqmName {get;set;}
public List<SelectOption> getCurrencyIsoCode(){return getPickListValue('Bidding_Cost__c','CurrencyIsoCode',false);}
public List<SelectOption> getCostItem(){return getPickListValue('Bidding_Cost__c','COST_OF_BIDDING_ITEMS__c',false);}

    public Bidding_Cost_Controller(ApexPages.StandardController controller){
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        bc = (Bidding_Cost__c) controller.getRecord();
        Unit_Cost__c uc = Unit_Cost__c.getInstance(UserInfo.getProfileId());
        bc.unit_cost__c = Decimal.valueOf(uc .Value_Unit_Cost__c);
        oqmId = bc.OQM_NAME__c;
        oqmName = [select name from OQM_Form__c where id =: oqmId][0].name;
        bc.currencyIsoCode = [select currencyIsoCode from OQM_Form__c where id =: oqmId][0].currencyIsoCode;
        
    }
    
    public static List<SelectOption> getPickListValue(string objectType,string picklistName,boolean hasNoneValue) {       
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;           
        List<SelectOption> op = new List<SelectOption>();       
        Schema.SObjectType s = m.get(objectType) ;       
        Schema.DescribeSObjectResult r = s.getDescribe() ;       
        if(r == null)
        {           
            return op;       
        }        
        Map<String, Schema.SObjectField> fields = r.fields.getMap();        
        Schema.SObjectField f = fields.get(picklistName);          
        if(f == null)
        {           
            return op;     
        }       
        Schema.DescribeFieldResult r2 = f.getDescribe() ;         
        if(r2 == null)           
            return op;       
        Schema.PicklistEntry [] Commpref = r2.getPickListValues();       
        if(hasNoneValue)           
            op.add(new selectOption('','--None--'));       
        for(Schema.PicklistEntry val : Commpref){         
            op.add(new selectOption(val.getValue(),val.getLabel()));       
        }       
        return op;   
    }
    
    public PageReference save(){
        
        insert bc;
        return new PageReference('/' + oqmId);
    }
    
    public PageReference saveNew(){
        insert bc;
        PageReference pr = new PageReference(ApexPages.currentPage().getURL());
        pr.setRedirect(true);
        return pr;
    }
}