/*
Class   : PortalViewCaseController
Author –  Vinay Lakshmeesh
Date –    4/1/2013
Usage   : This Controller gets Cases based on Cases status
          Dispalys the case on a paginated table with page size of 7
Revision History
*/

public without sharing class PortalViewCaseController extends DynamicListOffsetController {
    public List<Id> soldToAccntList = new List<Id>();
    public List<Id> endUsrAccntList = new List<Id>();
    public static boolean isEndUsrNull = false;
    public static boolean isSolToNull = false;
    public String myCases {get;set;}
    public String endUsrId {get;set;}
    public boolean fr;
    public Boolean isReadOnlyProfile {get;set;} 
    public Boolean isClosed {get; set;}
    public String exportTitle {get; set;}
   // public Boolean isGCAPuser {get; set;} //not used??
    public static List<Cloud_Deployment__c> custdepls;

  public PortalViewCaseController() {                 
        
       super('select '+ListFields()+',Support_Product__r.Name from Case', 'Case', 'where RecordType.DeveloperName IN (' + getCaseType() + ')' + 
            ' AND ( (End_User_Account__c in '+ gtEnDUsr() +'and Sold_To_Account__c in ' + gtSoldTo() + 
            ' AND Deployment_Type__c != \'Cloud\' AND Cloud_Deployment__c=null)' + 
             getCloudDeplClause() + ') AND contactId= \'' + gtConId() + '\' and status !=\'Closed\'', false);
 
        String pgSize = Apexpages.currentPage().getParameters().get('pgsize');
        String feature = Apexpages.currentPage().getParameters().get('fr');
        
        //// export cases
        endUsrId = Apexpages.currentPage().getParameters().get('euid');
        String cstp = Apexpages.currentPage().getParameters().get('cstp');
        myCases = cstp != null ? cstp : '';
        
        if (pgsize!=null)  {
            pageSize = Integer.valueOf(pgSize);
        }
        else {
            pageSize = 5;
        }   
     
      if(feature!= null && feature =='true')
        fr = true;
    
    ///NOT USED???  need to remove  
      isReadOnlyProfile = CaseUtil.isCurrentUserProfileReadOnly();
      
      // MS-02/2016 isGCAPuser = ContactUtil.isGCAPuser();
    }
    
    public Pagereference gtMyCases() {
        this.activated = true;
        isClosed = false;
        String status ='';
        String addContactClause = '';
        String endUserClause = '';
       
        if( endUsrId != null && endUsrId != '') {
            endUserClause =' and End_User_Account__c= \'' + endUsrId + '\'';
        }
        
        if( myCases.startsWith('My') )  {
            addContactClause = ' and contactId= \'' + gtConId() +'\'';
        }
        
        /// all non-closed
        if ( myCases.contains('NonClosed') )  {
           status = 'and status !=\''+'Closed'+'\'';
        }
        else {
                /// specific status
              String cstat = '';
              if (myCases.endsWith('Open') )
                  cstat = 'Open';
              else if ( myCases.endsWith('Awaiting Info') )
                  cstat = 'Awaiting Info';
               else if (myCases.endsWith('Solution Proposed') )
                  cstat = 'Solution Proposed';
               else if ( myCases.endsWith('Closed') ) 
                  cstat = 'Closed';
                  
            status = 'and status=\'' + cstat +'\'';
            
            if (cstat == 'Closed')  {
                 this.isClosed = true;
                 status += ' AND ClosedDate >= LAST_N_MONTHS:35 ';
            }              
       }      
        
     this.ChangeQuery('select '+ListFields()+',Support_Product__r.Name from Case', 'Case', 'where RecordType.DeveloperName IN (' + 
             getCaseType() + ') And ((End_User_Account__c in '+ gtEnDUsr() +'and Sold_To_Account__c in '+gtSoldTo() + 
             ' AND Deployment_Type__c != \'Cloud\' AND Cloud_Deployment__c=null) ' + 
             getCloudDeplClause() + ')' + status + addContactClause + endUserClause);
      
     this.resetResultSize('select count() from Case', 'Case', 'where RecordType.DeveloperName IN (' + 
             getCaseType() + ') And ((End_User_Account__c in '+ gtEnDUsr() +'and Sold_To_Account__c in '+gtSoldTo() + 
             ' AND Deployment_Type__c != \'Cloud\' AND Cloud_Deployment__c=null) ' + 
             getCloudDeplClause() + ')' + status + addContactClause + endUserClause);
            
        return null;
    }
    
    //Get Support Access of the Contact
    //Get End User from Support Access
    public static String gtEnDUsr()  {
        String endUsrAccntList;
        isEndUsrNull = false;
        endUsrAccntList = '(';
  
        for( Support_Access__c sa : getSAList() )   {                                                
            if(sa.End_User_Account__c != null) {
                endUsrAccntList = endUsrAccntList +'\''+ sa.End_User_Account__c +'\',';
            }
         }
         
        if(endUsrAccntList!= '('){
            endUsrAccntList = endUsrAccntList.removeEnd(',') + ')';
        }else{
            isEndUsrNull = true;
            endUsrAccntList = '(\'123456789012345678\')';
        }
        
        return endUsrAccntList;        
    }
    
    public static List<Support_Access__c> getSAList() {
   
         List<Support_Access__c> sa =  [SELECT Id, Name, End_User_Account__c, Sold_To_Account__c, End_User_Account__r.Name 
                                                 FROM Support_Access__c 
                                                 WHERE Contact__c =:gtConId() 
                                                 AND (SR_Access_Level__c ='Read/Write' or SR_Access_Level__c = 'Read Only') 
                                                 AND Status__c = 'Active'] ;
        return sa;
    }
    
    public List<SelectOption> getEUsrList(){
        List<SelectOption> options = new List<SelectOption>();
        Map<String, String> euMap = new Map<String, String>(); 
        Set<String> endUserNames = new Set<String>();

        for( Support_Access__c sa : getSAList() )  {                           
                                                                    
            if(sa.End_User_Account__r.Name != null &&  !endUserNames.contains( sa.End_User_Account__r.Name ) ){
                euMap.put(sa.End_User_Account__r.Name, sa.End_User_Account__c);
                endUserNames.add( sa.End_User_Account__r.Name );
            }
        }
        
        ///cloud cases
        if ( custdepls == null )
              custdepls = ContactUtil.getUserCloudDepl();
        for( Cloud_Deployment__c cld : custdepls )  {                           
                                                                    
            if(cld.Account__c != null &&  !endUserNames.contains( cld.Account__r.Name ) ){
                euMap.put(cld.Account__r.Name, cld.Account__c);
                endUserNames.add( cld.Account__r.Name );
            }
        }
        
        List<String> euList = new List<String>(endUserNames);
        euList.sort();
        options.add(new SelectOption('','All'));
        for (String eu : euList)
           options.add(new SelectOption( euMap.get(eu), eu ) );
        
        return options;
    }
    
    public static Id gtConId() {
        return ContactUtil.getUserContactId();
    }
    
    //Get Sold To from Support Access
    public static String gtSoldTo(){
        String soldToAccntList;
        isSolToNull = false;
        soldToAccntList = '(';

         //added by Ankit on 8/26/2013
        for( Support_Access__c sa : getSAList() )  {            
            if( sa.Sold_To_Account__c != null ) {
                soldToAccntList = soldToAccntList +'\''+ sa.Sold_To_Account__c +'\',';
            }           
        }
                       
        if(soldToAccntList!= '(') {
            soldToAccntList = soldToAccntList.removeEnd(',') + ')';
        } else {
            isSolToNull = true;
            soldToAccntList = '(\'123456789012345678\')';
        }
        
        return soldToAccntList;
    }
    
    public static String getCloudDeplClause()  {
        if ( custdepls == null )  {
             // custdepls = ContactUtil.getUserCloudDepl();
              custdepls = [SELECT Id, Name, Account__r.Name, Account__c, Cloud_Offering__c FROM Cloud_Deployment__c WHERE Id IN
                          (SELECT Cloud_Deployment__c FROM Support_Access_Cloud__c 
                           WHERE Contact__c = :gtConId() 
                            AND Access_Status__c = 'Active' AND Access_Level__c IN ('Read/Write','Read Only') )
                           ORDER BY Name];  	  	
        }     
         String deplIds = '';
         
         Integer len = custdepls.size(); 
         for ( Integer n=0; n<len; n++ ) {
             if (n>0) 
                deplIds += ', ';
                 deplIds += '\'' + custdepls[n].Id + '\'';
         }
         
         if (deplIds != '')
            return ' OR Cloud_Deployment__c IN (' + deplIds + ') ';
         else
            return '';
    }
 
    public List<SelectOption> getItems() {
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
        options.add(new SelectOption('Closed','All Closed Cases'));
        return options;
    }
    
//  Cast the resultset
//  ---------------------------------------------------------------------------------------------
    public List<Case> getCases() {
       return (List<Case>) getRecords();
    }

    public pageReference lazyLoad(){
        activated = true;
        getCases();
        return null;
    } 
    
   public PageReference exportCases() {
        pagesize = 1000;
        gtMyCases();
        
        for ( SelectOption so : getItems() )  {
            if (so.getValue() == myCases)  {
                   exportTitle = so.getLabel();
                   break;
            }
        }

        return null;
    }
      
    public List<Case> getHomePageCases() {
    	String hpquery = 'SELECT Id, CaseNumber, Subject, Date_Modified_Closed__c FROM Case ' +
    	          ' WHERE RecordType.DeveloperName IN (\'Genesys_Admin_Case\', \'Genesys_Product_Case\', \'Genesys_Feature_Request_Case\')' +
    	          ' AND Status !=\'Closed\' ' +
    	          ' AND ( (End_User_Account__c in '+ gtEnDUsr() +'and Sold_To_Account__c in ' + gtSoldTo() + 
            	  ' AND Deployment_Type__c != \'Cloud\' AND Cloud_Deployment__c=null)' + getCloudDeplClause() + ') ' +
            	  ' AND contactId= \'' + gtConId() + '\'' +
    	          ' AND Date_Modified_Closed__c >= LAST_MONTH ORDER BY Date_Modified_Closed__c DESC LIMIT 5';
    	                  
        return Database.query(hpquery);
    }   

//  Get the fields from a field set 
//  ---------------------------------------------------------------------------------------------
    private static String ListFields(){  
        String fields;             
        for(Schema.FieldSetMember f : SObjectType.Case.FieldSets.Portal_Fields_All.getFields()) {
            if(fields == null)fields = f.getFieldPath();
            else fields += ','+f.getFieldPath();
        }
        return fields;
   }
   
   private static String getCaseType() {
          String casetype = Apexpages.currentPage().getParameters().get('ctp');
           
          if ( casetype == 'Admin' )             
             return '\'Genesys_Admin_Case\'';
          else
             return '\'Genesys_Product_Case\'';
   }
}