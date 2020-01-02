/*
*/

public without sharing class PortalViewFRViewController extends DynamicListOffsetController {
    public List<Id> soldToAccntList = new List<Id>();
    public List<Id> endUsrAccntList = new List<Id>();
    public static boolean isEndUsrNull = false;
    public static boolean isSolToNull = false;
    public String myCases {get;set;}
    public static Id conId;
    public String endUsrId {get;set;}
    public boolean fr;
    public String frCaseRecordTypeId {get;set;}
    public Boolean isReadOnlyProfile {get;set;} 
     public static List<Cloud_Deployment__c> custdepls;
    
    //  Override Const
//  ---------------------------------------------------------------------------------------------    
    public PortalViewFRViewController() {               
                   
        super('select '+ListFields()+',Support_Product__r.Name from Case', 'Case', 'where (RecordType.DeveloperName = \'Genesys_Feature_Request_Case\') ' +
			    ' AND ( (End_User_Account__c in '+ gtEnDUsr() +'and Sold_To_Account__c in ' + gtSoldTo() + 
			    ' AND Deployment_Type__c != \'Cloud\' AND Cloud_Deployment__c=null)' +  getCloudDeplClause() + ') ' +  
			    ' AND contactId= \'' + gtConId() +'\' and status !=\'Closed\'', false);
                           
        String pgSize = Apexpages.currentPage().getParameters().get('pgsize');
        String feature = Apexpages.currentPage().getParameters().get('fr');
        
        if(pgsize!=null){
            pageSize = Integer.valueOf(pgSize);
        }else{
            pageSize = 5;
        }   
     
      if(feature!= null && feature =='true')
       fr = true;
        
        if ( CaseUtil.isCurrentUserProfileReadOnly() || ContactUtil.isCloudUser() )
            isReadOnlyProfile = true;
        else
            isReadOnlyProfile = false;
        
        RecordType rType = [SELECT id FROM RecordType WHERE DeveloperName = 'Genesys_Feature_Request_Case' LIMIT 1];
        frCaseRecordTypeId = rType.id;
        
    }
    
    public Pagereference gtMyCases(){
        this.activated = true;
        String status ='';
        String addContactClause = '';
        String endUserClause = '';
        if(endUsrId!=null){
            endUserClause =' and End_User_Account__c= \''+endUsrId+'\'';
        }
        
        if(myCases.startsWith('My')){
            addContactClause = ' and contactId= \''+gtConId()+'\'';
            myCases = myCases.removeStart('My');
          
        }
        
        if(myCases == 'All') {
            status = '';
        }
        else if((myCases != 'NonClosed') && (myCases == 'Awaiting Info' || myCases == 'Solution Proposed' || myCases == 'Solution Proposed' || myCases == 'Closed')){
            status = 'and status=\''+myCases+'\'';         
        }
       
       if((myCases == 'NonClosed'))
        status = 'and status !=\''+'Closed'+'\'';
    
       if(myCases == 'Open'){ 
        status = ' and (status= \'Open - Customer Care\' or status = \'Open - Product Management\')';
       }    
    
       if((myCases == 'AllNonClosed'))
        status = ' and status !=\''+'Closed'+'\''; 
        
       if((myCases == 'Awaiting Info'))
        status = ' and sub_status__c =\''+'Info Required From Customer'+'\''; 
 
    this.ChangeQuery('select '+ListFields()+',Support_Product__r.Name from Case', 'Case', 'where (RecordType.DeveloperName = \'Genesys_Feature_Request_Case\') ' +
      ' AND((End_User_Account__c in ' + gtEnDUsr() +'and Sold_To_Account__c in '+ gtSoldTo() + 
      ' AND Deployment_Type__c != \'Cloud\' AND Cloud_Deployment__c=null) ' +  getCloudDeplClause() + ')' + 
	    status + addContactClause +endUserClause);
      
    this.resetResultSize('select count() from Case', 'Case', 'where (RecordType.DeveloperName = \'Genesys_Feature_Request_Case\') ' +
      ' AND((End_User_Account__c in ' + gtEnDUsr() +'and Sold_To_Account__c in '+ gtSoldTo() + 
      ' AND Deployment_Type__c != \'Cloud\' AND Cloud_Deployment__c=null) ' +  getCloudDeplClause() + ')' + 
	    status + addContactClause +endUserClause);
        return null;
    }
 
    public static List<Support_Access__c> getSAList() {
   
         List<Support_Access__c> sa =  [SELECT Id, Name, End_User_Account__c, Sold_To_Account__c, End_User_Account__r.Name 
                                                 FROM Support_Access__c 
                                                 WHERE Contact__c =:gtConId() 
                                                 AND (SR_Access_Level__c ='Read/Write' or SR_Access_Level__c = 'Read Only') 
                                                 AND Status__c = 'Active'] ;
        return sa;
    }
 
    public static String gtEnDUsr(){
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
    
    public List<SelectOption> getEUsrList() {
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
    
    public static Id gtConId(){
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
        if ( custdepls == null )
              custdepls = ContactUtil.getUserCloudDepl();
              
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
        
      
        options.add(new SelectOption('MyOpen','My Open Feature Requests'));
        options.add(new SelectOption('MyAwaiting Info','My Awaiting Info Feature Requests'));
        options.add(new SelectOption('MyClosed','My Closed Feature Requests'));
        options.add(new SelectOption('Open','All Open Feature Requests'));
        options.add(new SelectOption('Awaiting Info','All Awaiting Info Feature Requests'));
        options.add(new SelectOption('Closed','All Closed Feature Requests'));
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
        

//  Get the fields from a field set 
//  ---------------------------------------------------------------------------------------------
    private static String ListFields(){  
        String fields;             
        for(Schema.FieldSetMember f : SObjectType.Case.FieldSets.Portal_FR_Fields_View.getFields()) {
            if(fields == null)fields = f.getFieldPath();
            else fields += ','+f.getFieldPath();
        }
        return fields;
   }
}