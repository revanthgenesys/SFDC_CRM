public with sharing class CustomProduct2LookupController {
        
      
      public List<Product2> results{get;set;} // search results
      public string searchString{get;set;} // search keyword
      public string searchType{get;set;} // type
      public string searchCondition{get;set;} // condition
      public string searchInputString{get;set;} // search input
      
      public CustomProduct2LookupController() {
              searchString = System.currentPageReference().getParameters().get('lksrch');
              runSearch();  
      }
       
      // performs the keyword search
      public PageReference search() {
        runSearch();
        return null;
      }
      
      // prepare the query and issue the search command
      private void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        results = performSearch();               
      } 
      
      // run the search and return the records found. 
      private List<Product2> performSearch() {
        
        Set<id> inEligibleProdIds = new Set<id>();
        PricebookEntry [] pbResultSet = [Select id, Product2Id  From PricebookEntry  where Pricebook2.Name = 'Sales PriceBook'];
        
        for(PricebookEntry pbrs : pbResultSet){
            inEligibleProdIds.add(pbrs.Product2Id);
        }
        
        String soql = 'select id, ProductCode, APN_Number__c, Description,Family,Base_Item__c,SI_Version_Number__c, name,Type__c from Product2';
        
        soql = soql +  ' where Type__c <> \'Bundle\' AND IsActive = true AND Dont_Publish_In_Quote__c= false AND Availability_Status__c in (\'Active\',\'BOM Update\') AND id Not IN :inEligibleProdIds  AND OfferingType__c includes (\'PureEngage On Premise\',\'PureConnect On Premise\') '  ;
        
        if(searchType != '0' && searchCondition != '0' && (searchInputString != '' && searchInputString != null)) {
            if (searchType == '1') {
                soql = soql +  ' and ' + getWhereClauseByCondition('name', searchCondition, searchInputString);
            } else if (searchType == '2') {
                soql = soql +  ' and ' + getWhereClauseByCondition('Description', searchCondition, searchInputString);
            } else if (searchType == '3') {
                soql = soql +  ' and ' + getWhereClauseByCondition('Type__c', searchCondition, searchInputString);
            }else if (searchType == '4') {
                soql = soql +  ' and ' + getWhereClauseByCondition('APN_Number__c', searchCondition, searchInputString);
            }
            
        } else if(searchString != '' && searchString != null) {
            soql = soql +  ' and (Name LIKE \'%' + searchString +'%\'' + ' or Description LIKE \'%' + searchString +'%\''  + ' or APN_Number__c LIKE \'%' + searchString +'%\')';
        }
        
        soql = soql + 'and recordtypeid != \'012U0000000MTaf\'';
        soql = soql + ' limit 200';
        System.debug(soql);
        
        return database.query(soql); 
    
      }
      
      public string getWhereClauseByCondition(string searchBy, string searchCondition, string searchInputString) {
        string returnString='';
        if (searchCondition == '1') {
            returnString = searchBy +' = \'' + searchInputString +'\'';
        } else if (searchCondition == '2') {
            returnString = searchBy +' != \'' +  searchInputString +'\'';
        } else if (searchCondition == '3') {
            returnString = searchBy +' LIKE \'' +  searchInputString +'%\'';
        } else if (searchCondition == '4') {
            returnString = searchBy +' LIKE \'%' + searchInputString +'%\'';
        } else if (searchCondition == '5') {
            returnString = '( NOT '+ searchBy +' LIKE \'%' + searchInputString +'%\')';
        }
        
        return returnString;
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