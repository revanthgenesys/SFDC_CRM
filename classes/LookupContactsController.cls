public class LookupContactsController{
    
    public String query {get; set;}
    public List<Contact> contacts {get; set;}
    public String[] fieldsToQuery {get; set;}
    public LookupContactsController(){
        fieldsToQuery = new String[] {'id', 'Name', 'MailingStreet', 'MailingCity', 'MailingPostalcode' };
        query = ApexPages.CurrentPage().getParameters().get('searchText');
    }
 
}