public class CasePortalSearchResultsController {
		
	public List<wrapCase> cases {get; set;}	
	public String infoTxt {get; set;}
	public Boolean premUser {get; set;}
	public Boolean cldUser {get; set;}
	public String sortDir {get; set;}
	public String sortField {get; set;}
	public List<Case> unsortedcases;
	
	public CasePortalSearchResultsController() {
	    unsortedcases = new List<Case>();
	    cases = new List<wrapCase>();
	
	    premUser = ContactUtil.isPremiseUser() ? true : ContactUtil.isPremiseReadOnlyUser();
	    cldUser =  ContactUtil.isCloudUser() ? true : ContactUtil.isCloudReadOnlyUser();
	      
	    if ( premUser )  {
	   		unsortedcases.addAll( searchPremCases() );
	    }
	    
	    if (cldUser && unsortedcases.size() < 100 )  {
	    	unsortedcases.addAll( searchCloudCases() );
	    }
	    
	    if ( unsortedcases.size() < 100 )  {
	    	unsortedcases.addAll( searchAdminCases() );
	    }
	   
	    sortCases();
	    
	    if ( cases.size() < 100 )
	       infoTxt = 'Total records found: ' + cases.size();
	     else
	       infoTxt = 'Your search returned more than 100 results. First 100 has been displayed.';	       
	}
	
	public List<Case> searchPremCases() {
		String wherecls = CaseViewSelector.premSupprtWhere();
		if ( String.isBlank(wherecls) )
		      wherecls = 'Id = null';
				
		String queryStr = 'SELECT '+ selectListFields() +' FROM Case ' + 
		   'WHERE RecordType.DeveloperName IN (\'Genesys_Product_Case\', \'Genesys_Feature_Request_Case\', \'Premises_Service_Request\') AND ' + 
		         wherecls + ' AND (' + searchClause('prem') + ') ORDER BY CreatedDate DESC LIMIT 100';

		return Database.query(queryStr);
	}
	
	public List<Case> searchCloudCases() {
		String wherecls = CaseViewSelector.cldSuppstWhere();
		if ( String.isBlank(wherecls) )
		      wherecls = 'Id = null';
						
		String queryStr = 'SELECT '+ selectListFields() +' FROM Case ' + 
		   'WHERE RecordType.DeveloperName LIKE \'Genesys_Cloud_%\' AND ' + 
		         wherecls + ' AND (' + searchClause('cld') + ') ORDER BY CreatedDate DESC LIMIT 100';
		
		return Database.query(queryStr);
	}
	
	public List<Case> searchAdminCases() {
		String wherecls = CaseViewSelector.adminWhere();
		if ( String.isBlank(wherecls) )
		      wherecls = 'Id = null';
						
		String queryStr = 'SELECT '+ selectListFields() +' FROM Case ' + 
		   'WHERE RecordType.DeveloperName = \'Genesys_Admin_Case\' AND ' + 
		        wherecls + ' AND (' + searchClause('adm') + ') ORDER BY CreatedDate DESC LIMIT 100';
		
		return Database.query(queryStr);
	}
	
	private static String searchClause(String listType) {
       String searchClause = '';
       String searchInp = ApexPages.CurrentPage().getParameters().get('inp');
       
       searchInp = searchInp != null ? searchInp.trim() : '';
       
       if ( String.isBlank(searchInp) ) {
       	   return 'Id = null ';
       }
       
       ///search only fields relevant to the case type
       List<Schema.FieldSetMember> fldSet = new List<Schema.FieldSetMember>();
       if ( listType == 'prem' )
           fldSet = SObjectType.Case.FieldSets.Portal_Case_Search_Prem_Fields.getFields();
       else if ( listType == 'cld' )
             fldSet = SObjectType.Case.FieldSets.Portal_Case_Search_Cloud_Fields.getFields();
       else if ( listType == 'adm' )
             fldSet = SObjectType.Case.FieldSets.Portal_Case_Search_Admin_Fields.getFields();
             
       for( Schema.FieldSetMember f : fldSet ) {           
           searchClause  += f.getFieldPath() +' LIKE \'%' + searchInp + '%\' OR ';     
       }
       
       searchClause = searchClause.removeEnd('OR ');
       return searchClause; 
   }
   
    private static String selectListFields() {  
        /// always select fields for all case types because if user has access to Cloud and Prem we need to combine results in the one list,
        ///  plus Admin cases              
        return 'Id, CaseNumber, Support_product__r.Name, Cloud_Service__r.Name, Status, Priority, Subject, ' +
               'Contact_Name__c, Cloud_Deployment__r.Name, RecordType.DeveloperName, End_User_Account__r.Name, Sold_To_Account__r.Name ';
  
   }
 
  public class wrapCase implements Comparable {
  	 public Case cs {get; set;}
  	 private CasePortalSearchResultsController outerCl;
  	   	 
  	 public wrapCase(CasePortalSearchResultsController outerCl, Case caseInp) {
  	 	 this.cs = caseInp;
  	 	 this.outerCl = outerCl;
  	 }
  	
     public Integer compareTo(Object compareTo)  {
         wrapCase wrCs = (wrapCase)compareTo;
      
         String compStr1, compStr2;        
         if (outerCl.sortField == 'casenum') {
	        compStr1 = wrCs.cs.CaseNumber;
	        compStr2 = cs.CaseNumber;
                               
         }           
         else if (outerCl.sortField=='eu')  {
         	 compStr1 = wrCs.cs.End_User_Account__r.Name == null ? '' : wrCs.cs.End_User_Account__r.Name;
         	 compStr2 = cs.End_User_Account__r.Name == null ? '' : cs.End_User_Account__r.Name;
         	                                  
         }
         else if (outerCl.sortField=='stat')  {
         	 compStr1 = wrCs.cs.Status == null ? '' : wrCs.cs.Status;
         	 compStr2 = cs.Status == null ? '' : cs.Status;
         	                                  
         }
         else if (outerCl.sortField=='prior')  {
         	 compStr1 = wrCs.cs.Priority == null ? '' : wrCs.cs.Priority;
         	 compStr2 = cs.Priority == null ? '' : cs.Priority;
         	                                  
         }
         else if (outerCl.sortField=='st')  {
         	 compStr1 = wrCs.cs.Sold_To_Account__r.Name == null ? '' : wrCs.cs.Sold_To_Account__r.Name;
         	 compStr2 = cs.Sold_To_Account__r.Name == null ? '' : cs.Sold_To_Account__r.Name;
                               
         }
         else if (outerCl.sortField=='prod')  {
         	 compStr1 = wrCs.cs.Support_product__r.Name == null ? '' : wrCs.cs.Support_product__r.Name;
         	 compStr2 = cs.Support_product__r.Name == null ? '' : cs.Support_product__r.Name;
                                 
         }
         else if (outerCl.sortField=='cldsrv')  {
         	 compStr1 = wrCs.cs.Cloud_Service__r.Name == null ? '' : wrCs.cs.Cloud_Service__r.Name;
         	 compStr2 = cs.Cloud_Service__r.Name == null ? '' : cs.Cloud_Service__r.Name;         	                       
         }
         else if (outerCl.sortField=='dpl')  {
         	 compStr1 = wrCs.cs.Cloud_Deployment__r.Name == null ? '' : wrCs.cs.Cloud_Deployment__r.Name;
         	 compStr2 = cs.Cloud_Deployment__r.Name == null ? '' : cs.Cloud_Deployment__r.Name;
         	                          
         }
         else if (outerCl.sortField=='cont')  {
         	 compStr1 = wrCs.cs.Contact_Name__c == null ? '' : wrCs.cs.Contact_Name__c; 
         	 compStr2 = cs.Contact_Name__c == null ? '' : cs.Contact_Name__c;        	                                                         
         }
         else
         	return -1;  
         	
        if (outerCl.sortDir == 'desc') 
              return compStr1.compareTo(compStr2);
         else
              return compStr2.compareTo(compStr1);            
     }
  }
  
  public void sortCases() { 
  	cases.clear();
  	
  	if ( sortField == null )
  	    sortField = 'CaseNumber'; 
  	
  	if ( sortDir == null )
        sortDir ='asc';
    else if (sortDir == 'asc')
        sortDir = 'desc';
    else if (sortDir == 'desc')
        sortDir='asc';
  	
  	 for ( Case cs :  unsortedcases ) 
          cases.add( new wrapCase (this, cs) ); 
                  	 
  	  cases.sort();
  }
}