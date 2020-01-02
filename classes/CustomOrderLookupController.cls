public class CustomOrderLookupController {
  
  public Order__c order{get;set;} // new account to create
  public List<Order__c> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  public String endUserId;
  public CustomOrderLookupController() {
    order = new Order__c();
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    endUserId = System.currentPageReference().getParameters().get('acc');
    runSearch();  
  }
   
  // performs the keyword search
  public PageReference search() {
    results = performSearch(searchString);               
    return null;
  }
  
  // prepare the query and issue the search command
  private void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results = performSearch(searchString);               
  } 
  
  // run the search and return the records found. 
  private List<Order__c> performSearch(string searchString) {
    String soql = 'select id, name from Order__c Where End_User_Name__c=\''+endUserId+'\' AND status__c = \'Completed\'';
    if(searchString != '' && searchString != null)
      soql = soql +  ' AND name LIKE \'%' + searchString +'%\'';
    soql = soql + ' limit 25';
    
    return database.query(soql); 

  }
  
  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }
    
  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }
 
}