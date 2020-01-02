public class CasesListViewPortal extends DynamicListOffsetController {
        
    public String selectedStatus {get; set;}
    public String selectedEuId {get;set;}
    public String selectedCldDeplId {get; set;}
        
    public String endUsrId {get;set;}
    public String recType {get; set;}
    public String platformFilter {get; set;}
    
    public List<Id> endUsrAccntList = new List<Id>();    
    public Boolean isClosed {get; set;}
    public String exportTitle {get; set;}
    public static List<Cloud_Deployment__c> custdepls;
    public Integer myCasesCount {get; set;}
    public Integer showMoreIncr {get; set;}
    public Map<Integer, Case> MyCases {get; set;}
    public String searchTxt {get; set;}

  public CasesListViewPortal() {                 
      /// List Views
      String pgSize = Apexpages.currentPage().getParameters().get('pgsize');
      
      /// expected types: sprt, cld, frprm, frcld, adm
      recType = Apexpages.currentPage().getParameters().get('rectp');
      
     //// export cases
      selectedEuId = Apexpages.currentPage().getParameters().get('euid');
      selectedCldDeplId = Apexpages.currentPage().getParameters().get('dpl');
      String exportStatus = Apexpages.currentPage().getParameters().get('st');
      platformFilter = Apexpages.currentPage().getParameters().get('fltr');
         
      platformFilter = platformFilter == null ? '' : platformFilter;
              
      if ( String.isNotBlank(pgSize) )  {
           pageSize = Integer.valueOf(pgSize);
       }
       else {
           pageSize = 5;
       } 
      
      ///My Cases page
      MyCases = new Map<Integer,Case>();
      showMoreIncr = 5;
      myCasesCount=0;
      searchTxt = '';
            
      selectedStatus = String.isNotBlank(exportStatus) ? exportStatus : 'MyNonClosed';
      isClosed = false;       
      buildQuery();
  }
         
  public List<SelectOption> EuSelectOpts {
         get {
                List<SelectOption> options = new List<SelectOption>();              
                List<Support_Access__c> supaccess = ContactUtil.getAllActiveSupprtAccLstByContact( ContactUtil.getUserContactId() );
                if ( supaccess.size() > 0 ) {
                        
                       if ( supaccess.size() > 1 )
                           options.add( new SelectOption('', 'All') );
                           
                        Map<String, String> euMap = new Map<String, String>();
                        Set<String> EuIDs = new Set<String>();
                        for (Support_Access__c sa : supaccess) {
    
                           if ( sa.BOA_Platform__c.startswith('PureConnect') && platformFilter == 'cnct' ) {
                               euMap.put( sa.End_User_Account__c, sa.End_User_Account__r.Name );
                                   EuIDs.add(sa.End_User_Account__c);
                                    }
                                    else if ( sa.BOA_Platform__c.startswith('PureEngage') && platformFilter == 'eng' ) {
                                           euMap.put( sa.End_User_Account__c, sa.End_User_Account__r.Name );
                                           EuIDs.add(sa.End_User_Account__c);
                                    }
                        }   

                        for (String euId : EuIDs ) {
                           if ( euId != null )
                               options.add( new SelectOption(euId, euMap.get(euId)) );
                        }
                }
                return options;         
         }
     set;
  }
  
  public List<SelectOption> cldDeplOpts {
         get {
                 List<SelectOption> options = new List<SelectOption>();                                        
                 List<Cloud_Deployment__c> depls = ContactUtil.getAllActiveCloudDeplByContId(ContactUtil.getUserContactId());
                 if ( depls.size() > 0 ) {
                                
                            if ( depls.size() > 1 )
                                    options.add( new SelectOption('', 'All') );
                                    
                                for (Cloud_Deployment__c dpl : depls) {
                                        
                                   if ( dpl.Cloud_Platform__c.startswith('PureCloud') && platformFilter == 'pcld' ) 
                                       options.add( new SelectOption(dpl.Id, dpl.Name) );
                                   else if ( dpl.Cloud_Platform__c.startswith('PureConnect') && platformFilter == 'cnct' ) 
                                       options.add( new SelectOption(dpl.Id, dpl.Name) );
                                   else if ( !dpl.Cloud_Platform__c.startswith('PureCloud') && !dpl.Cloud_Platform__c.startswith('PureConnect') &&
                                                           platformFilter == 'eng' )
                                       options.add( new SelectOption(dpl.Id, dpl.Name) );
                                }
                 }
                return options;         
         }
     set;
  }
  
  public List<SelectOption> statusOpts {
         get {
                  return CaseViewSelector.statusOptsByCaseType (recType); 
         }
         set;
  }
  
  public void buildQuery() {
       if ( selectedStatus == 'MyClosed' || selectedStatus == 'AllClosed' ) 
           isClosed = true;
       else
           isClosed = false;
                
       this.ChangeQuery('SELECT '+ ListFields() +' FROM Case', 'Case', 
         CaseViewSelector.baseWhere(recType) + CaseViewSelector.statusClause(selectedStatus) + myOwnClause() + accntClause() + pltfrmClause(recType));
                         
       this.resetResultSize('SELECT count() FROM Case', 'Case', 
         CaseViewSelector.baseWhere(recType) + CaseViewSelector.statusClause(selectedStatus) + myOwnClause() + accntClause() + pltfrmClause(recType));
            
  }
      
  public PageReference changeQuerySelections() {          
          buildQuery();
          lazyLoad();
          return null;
  }
   
  public List<Case> getCases() {
       return (List<Case>) getRecords();
  }
  
  public pageReference lazyLoad() {
        activated = true;
        getCases();
        return null;
  } 
     
  public PageReference exportCases() {
        pagesize = 1000;
        lazyLoad();
        
        for ( SelectOption so : CaseViewSelector.statusOptsByCaseType (recType) )  {
            if ( so.getValue() == selectedStatus )  {
                   exportTitle = so.getLabel();
                   break;
            }
        }
        return null;
    }

    private String myOwnClause() {
        String expr = '';       
        if( selectedStatus.startsWith('My') )  {
            expr = ' AND ContactId= \'' + ContactUtil.getUserContactId() +'\'';
        }
        return expr;
    }
    
    private String accntClause() {
        String expr = '';        
        if ( String.isNotBlank(selectedEuId) && recType != 'cld' && recType != 'frcld' ) {
            expr =' AND End_User_Account__c= \'' + selectedEuId + '\'';
        }
        else if (  String.isNotBlank(selectedCldDeplId) && (recType == 'cld' || recType == 'frcld') ) {
            expr =' AND Cloud_Deployment__c= \'' + selectedCldDeplId + '\'';
        }       
        return expr;
    }
    
    private String pltfrmClause(String recType) {
        String expr = '';

        if ( platformFilter == 'pcld' ) {
                 expr = ' AND Cloud_Platform__c = \'PureCloud\' ';
        }    
        else if ( recType == 'cld' || recType == 'frcld' ) {
            if ( platformFilter == 'cnct' ) 
               expr = ' AND Cloud_Platform__c LIKE \'PureConnect%\' ';
             else if ( platformFilter == 'eng' )
               expr = ' AND Cloud_Platform__c != \'PureConnect Cloud\' AND Cloud_Platform__c != \'PureCloud\' ';
        }       
        else {
             if ( platformFilter == 'cnct' ) 
               expr = ' AND BOA_Platform__c LIKE \'PureConnect%\' ';
             else if ( platformFilter == 'eng'  )
               expr = ' AND BOA_Platform__c LIKE \'PureEngage%\' ';
        }
        
        return expr;
    }
      
    private static String ListFields(){  
        String fields;             
        for(Schema.FieldSetMember f : SObjectType.Case.FieldSets.Portal_Fields_All.getFields()) {
            if(fields == null)fields = f.getFieldPath();
            else fields += ','+f.getFieldPath();
        }
        return fields;
   }

   public void showMore() {
          showMoreIncr += 5;
          return;
   }
   public void populateMyCases() {
           List<Case> mycs = getHomePageCases();
                  myCasesCount = mycs.size();
              for (Integer n=0; n < myCasesCount; n++)
                MyCases.put(n, mycs[n]);   
   }
   
   public List<Case> getHomePageCases() {
      List<Case> returnCases = new List<Case>();
  
      List<Case> allcases = [SELECT Id, CaseNumber, Subject, Date_Modified_Closed__c, LastModifiedDate, RecordType.DeveloperName,
                                    Cloud_Deployment__c, StEuIdCombo__c, Status, End_User_Account_For_Search__c, Case_Type_Portal__c 
                             FROM Case 
                             WHERE ContactId = :ContactUtil.getUserContactId()
                               AND Status != 'Closed' ORDER BY Date_Modified_Closed__c DESC];
      
      ///if user does not have support access, remove case from the list
      Map<Id, Cloud_Deployment__c> depls = new Map<Id, Cloud_Deployment__c>(ContactUtil.getAllActiveCloudDeplByContId(ContactUtil.getUserContactId()));
      
      List<Support_Access__c> supaccess = ContactUtil.getAllActiveSupprtAccLstByContact( ContactUtil.getUserContactId() );
      Set<String> validStEuCombos = new Set<String>();
      for ( Support_Access__c sa : supaccess )
          validStEuCombos.add( sa.Sold_To_Account__c + '_' + sa.End_User_Account__c);
            
      for ( Case cs : allcases )  {
          Boolean valid = false;          
          if ( cs.RecordType.DeveloperName.startswith('Genesys_Cloud_') && depls.containsKey(cs.Cloud_Deployment__c) ) 
                valid = true;
          else if ( cs.RecordType.DeveloperName == 'Genesys_Admin_Case' )
                valid = true;
          else if ( (cs.RecordType.DeveloperName == 'Genesys_Product_Case' || cs.RecordType.DeveloperName == 'Premises_Service_Request' ||
                     cs.RecordType.DeveloperName == 'Genesys_Feature_Request_Case') && validStEuCombos.contains(cs.StEuIdCombo__c) )
                valid = true;
  
          if ( valid ) 
              returnCases.add(cs);
       }
       
       myCasesCount = returnCases.size();               
       return returnCases;
    }   
    
}