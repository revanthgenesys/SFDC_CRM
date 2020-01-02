public class LookupAccountsController{
    public String query {get; set;}
    public List<Contact> contacts {get; set;}
    public String[] fieldsToQuery {get; set;}
    
    public LookupAccountsController(){
        fieldsToQuery = new String[] {'id', 'name', 'SAP_Account_Code__c' };
        query = ApexPages.CurrentPage().getParameters().get('searchText');
    }

}