public class CaseViewSelector {

    public static List<SelectOption> statusOptsByCaseType (String recType) {
        List<SelectOption> options = new  List<SelectOption>();       
    	if ( recType == 'adm' ) 
   	    	options =  adminOpts(); 	    	
   	    else if ( recType == 'cld' || recType == 'pcld' )
   	        options = cloudSupportOpts();   	        
   	    else if ( recType == 'sprt' )
   	       	 options = premSupportOpts();   	       	 
   	    else if ( recType == 'frprm' || recType == 'frcld' )   	 
   	       	 options = FROpts();
   	  
   	    return options;   	
    }
    
	public static List<SelectOption>  premSupportOpts() {	
		List<SelectOption> options = new List<SelectOption>();
                
        options.add(new SelectOption('MyNonClosed','My Non-Closed Cases')); 
        options.add(new SelectOption('MyOpen','My Open Cases'));       
        options.add(new SelectOption('MyAwaiting Info','My Awaiting Info Cases'));
        options.add(new SelectOption('MySolution Proposed','My Solution Proposed Cases'));
        options.add(new SelectOption('MyClosed','My Closed Cases'));
        
        options.add(new SelectOption('AllNonClosed','All Non-Closed Cases'));
        options.add(new SelectOption('Open','All Open Cases'));
        options.add(new SelectOption('Awaiting Info','All Awaiting Info Cases'));
        options.add(new SelectOption('Solution Proposed','All Solution Proposed Cases'));
        options.add(new SelectOption('AllClosed','All Closed Cases'));
        return options;        
	}
	
	public static List<SelectOption>  adminOpts() {	
		List<SelectOption> options = new List<SelectOption>();
                
        options.add(new SelectOption('MyNonClosed','My Non-Closed Admin Cases')); 
        options.add(new SelectOption('MyClosed','My Closed Admin Cases'));        
        return options;        
	}
	
	public static List<SelectOption>  cloudSupportOpts() {	
		List<SelectOption> options = new List<SelectOption>();
                
        options.add(new SelectOption('MyNonClosed','My Cases - All Non-Closed')); 
        options.add(new SelectOption('MySupGenAct','My Cases - Genesys Action'));       
        options.add(new SelectOption('MySupCustAct','My Cases - Customer Action'));
        options.add(new SelectOption('MyClosed','My Cases - Closed'));
        
        options.add(new SelectOption('AllNonClosed','All Cases - All Non-Closed'));
        options.add(new SelectOption('AllSupGenAct','All Cases - Genesys Action'));
        options.add(new SelectOption('AllSupCustAct','All Cases - Customer Action'));
        options.add(new SelectOption('AllClosed','All Cases - Closed'));
        return options;        
	}
	
	public static List<SelectOption>  FROpts() {	
		List<SelectOption> options = new List<SelectOption>();
                
        options.add(new SelectOption('MyNonClosed','My Cases - All Non-Closed'));
        options.add(new SelectOption('MyFRGenAct','My Cases - Genesys Action'));
        options.add(new SelectOption('MyFRCustAct','My Cases - Customer Action'));
        options.add(new SelectOption('MyClosed','My Cases - Closed'));
        
        options.add(new SelectOption('AllNonClosed','All Cases - All Non-Closed'));
        options.add(new SelectOption('AllFRGenAct','All Cases - Genesys Action'));
        options.add(new SelectOption('AllFRCustAct','All Cases - Customer Action'));
        options.add(new SelectOption('AllClosed','All Cases - Closed'));
        return options;       
	}
	
   public static String baseWhere(String recType) {
        String returnNone = 'WHERE id = null ';
        String wherecls;  
        String base;
        
   	    if ( recType == 'adm' )  {
   	    	base = adminWhere();
   	    	wherecls = base == '' ? returnNone : 'WHERE RecordType.DeveloperName = \'Genesys_Admin_Case\' AND ' + base;
   	    }	
   	    else if ( recType == 'cld' )  {   	    	
   	        base = cldSuppstWhere();
   	        wherecls = base == '' ? returnNone : 'WHERE RecordType.DeveloperName IN (\'Genesys_Cloud_Support_Request\', \'Genesys_Cloud_Service_Request\', \'Genesys_Cloud_Incident\') AND ' + base;
   	    }    
   	    else if ( recType == 'sprt' )  {
   	    	 base =  premSupprtWhere(); 
   	    	 wherecls = base == '' ? returnNone : 'WHERE RecordType.DeveloperName IN (\'Genesys_Product_Case\', \'Premises_Service_Request\') AND ' + base;  	    	
   	       //	 wherecls = base == '' ? returnNone : 'WHERE RecordType.DeveloperName = \'Genesys_Product_Case\' AND ' + base;
   	    }   	 
   	    else if ( recType == 'frprm' )  {   	 
   	       	 base = premSupprtWhere(); 
   	       	 wherecls = base == '' ? returnNone : 'WHERE RecordType.DeveloperName = \'Genesys_Feature_Request_Case\' AND ' + base;   	       	 
   	    }   
   	    else if ( recType == 'frcld' )  {   	 
   	       	 base = cldSuppstWhere(); 
   	       	 wherecls = base == '' ? returnNone : 'WHERE RecordType.DeveloperName = \'Genesys_Cloud_Feature_Request\' AND ' + base;   	       	 
   	    }   	 	 
   	    else
   	        wherecls = returnNone;   
   	       	     	     	    
   	    return wherecls;  	
   }
   
   public static String premSupprtWhere()  {
   	  String fullCls = '';
   	  String idComboLst;
   	  String euLst; //need this for performance
   	  
   	  List<Support_Access__c> supacs = ContactUtil.getAllActiveSupprtAccLstByContact(ContactUtil.getUserContactId());
   	  Integer len = supacs.size();
   	  
   	  if ( len > 0 )  {
   	  	  idComboLst = 'StEuIdCombo__c IN (';
   	  	  euLst = ' AND End_User_Account__c IN (';
   	  	  Boolean addcomma = false;
   	  	  
	   	  for (Integer n=0; n<len; n++ )  {
	   	  	if ( supacs[n].Sold_To_Account__c == null || supacs[n].End_User_Account__c == null )
	   	  	   continue;
	   	  	   
              if ( addcomma ) {
		   	       idComboLst += ', ' ;
		   	       euLst += ', ';
              }
                  
	   	      idComboLst += '\'' + Id.ValueOf(supacs[n].Sold_To_Account__c) + '_' + Id.ValueOf(supacs[n].End_User_Account__c) + '\'';
	   	      euLst += '\'' + Id.ValueOf(supacs[n].End_User_Account__c) + '\'';
	   	      addcomma = true;
	   	  }
	   	  idComboLst += ') ';
	   	  euLst += ') ';
	   	  
	   	  fullCls = idComboLst + euLst + 'AND ContactId != null';
   	  }   	  
   	  return fullCls;
   }
   
   public static String cldSuppstWhere() {
   	   String dplIdLst = '';
   	   
   	   List<Cloud_Deployment__c> depls = ContactUtil.getAllActiveCloudDeplByContId(ContactUtil.getUserContactId());
   	   Integer len = depls.size();
   	   
   	   if ( len > 0 )  {
   	  	   dplIdLst = 'Cloud_Deployment__c IN (';
   	  	  
	   	  for (Integer n=0; n<len; n++ )  {
              if ( n > 0 )
		   	       dplIdLst += ', ' ;
		   	       
	   	      dplIdLst += '\'' + depls[n].Id + '\'';
	   	  }
	   	  dplIdLst += ') ';
   	  }
   	   return dplIdLst;
   }
   
   public static String adminWhere() {
   	   return 'ContactId = \'' +  ContactUtil.getUserContactId() + '\' ';
   }
   
   public static String statusClause(String selectedStatus) {
        String expr = '';
        selectedStatus = String.isBlank(selectedStatus) ? 'MyNonClosed' : selectedStatus; 
        
        if ( selectedStatus.contains('NonClosed') )  {
           expr = ' AND Status !=\'Closed\'';
        }
        else {
           if ( selectedStatus.endsWith('Open') )
              expr = ' AND Status=\'Open\'';    
              
          else if ( selectedStatus.endsWith('Awaiting Info') )
              expr = ' AND Status=\'Awaiting Info\'';   

          else if (selectedStatus.endsWith('Solution Proposed') )
               expr = ' AND Status=\'Solution Proposed\''; 
               
          else if (selectedStatus.endsWith('SupGenAct') )
               expr = ' AND Status IN (\'Open\', \'Service Restored\')'; 
               
          else if (selectedStatus.endsWith('SupCustAct') )
               expr = ' AND Status IN (\'Awaiting Info\', \'Replied\')'; 
               
          else if (selectedStatus.endsWith('FRGenAct') )
               expr = ' AND Sub_Status__c NOT IN (\'Info Required From Customer\',\'Solution Proposed\') AND Status !=\'Closed\'';
               
          else if (selectedStatus.endsWith('FRCustAct') )
               expr = ' AND Sub_Status__c IN (\'Info Required From Customer\',\'Solution Proposed\') AND Status !=\'Closed\'';
               
          else if ( selectedStatus == 'MyClosed' || selectedStatus == 'AllClosed' ) 
               expr = ' AND Status=\'Closed\' AND ClosedDate >= LAST_N_MONTHS:35'; 
        }            
       return expr;                  
    }
 
}