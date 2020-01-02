/*****************************************************
Class: SearchPortalCaseResultsController
Author : Vinay Lakshmeesh   3/19/2013 
This class adds search case functionality on cusotmer portal
Revision History

******************************************************/
public without sharing class SearchPortalCaseResultsController extends DynamicListOffsetController{
    public List<Id> soldToAccntList = new List<Id>();
    public List<Id> endUsrAccntList = new List<Id>();
    public static boolean isEndUsrNull = false;
    public static boolean isSolToNull = false;
     public static List<Cloud_Deployment__c> custdepls;
         
    public SearchPortalCaseResultsController() {
 
        super('select '+ListFields()+' from Case', 'Case', 'where RecordType.DeveloperName IN (\'Genesys_Admin_Case\',\'Genesys_Feature_Request_Case\',\'Genesys_Product_Case\') ' +
              ' AND ( (End_User_Account__c in '+ gtEnDUsr() +'and Sold_To_Account__c in ' + gtSoldTo() + 
            ' AND Deployment_Type__c != \'Cloud\' AND Cloud_Deployment__c=null)' + getCloudDeplClause() + ')  and ( '+buildSearch()+' )', false);
        pageSize = 20; 
    }

/*    
    public Pagereference fetchSearchResults(){
        this.activated = true;
        this.ChangeQuery('select '+ListFields()+' from Case', 'Case', 'where End_User_Account__c in '+ gtEnDUsr() +'and Sold_To_Account__c in '+gtSoldTo());
        return null;
    }
*/    
    public static String gtEnDUsr(){
        String endUsrAccntList;
        isEndUsrNull = false;
        endUsrAccntList = '(';
        List<User> lstUser = [Select Id,ContactId from User  where Id = :UserInfo.getUserId()];
        Id conId = lstUser[0].ContactId;
        
        for(Support_Access__c sa : [SELECT Id, Name,End_User_Account__c, Sold_To_Account__c 
                                    FROM   Support_Access__c 
                                    WHERE Contact__c =:conId
                                    AND Status__c = 'Active' 
                                    AND (SR_Access_Level__c = 'Read/Write' OR SR_Access_Level__c = 'Read Only')                       
                                    AND Service_Contract_Status__c = 'Active']) {
            
            if(sa.End_User_Account__c!=null){
                endUsrAccntList = endUsrAccntList +'\''+ sa.End_User_Account__c +'\',';
            }
        }
        
        if(endUsrAccntList!= '('){
            endUsrAccntList = endUsrAccntList.removeEnd(',') + ')';
        }else{
            isEndUsrNull = true;
            //endUsrAccntList = '(\'No End User\')';
            //to make sure query returns no data
            endUsrAccntList = '(null) AND End_User_Account__c != null ';
        }
        
        return endUsrAccntList;     
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
    
    public static String gtSoldTo(){
        String soldToAccntList;
        isSolToNull = false;
        soldToAccntList = '(';
        //List<Id> soldToAccntList = new List<Id>();
        List<User> lstUser = [Select Id,ContactId from User  where Id = :UserInfo.getUserId()];
        Id conId = lstUser[0].ContactId;
        
        for(Support_Access__c sa : [SELECT Id,Name,End_User_Account__c, Sold_To_Account__c                                            
                                    FROM   Support_Access__c 
                                    WHERE  Contact__c =:conId]) {
                                        
            if(sa.End_User_Account__c!=null){
                //endUsrAccntList.add(sa.End_User_Account__c);
            }
            
            if(sa.Sold_To_Account__c!=null){
                soldToAccntList = soldToAccntList +'\''+ sa.Sold_To_Account__c +'\',';
            }
        }
        
        if(soldToAccntList!= '('){
            soldToAccntList = soldToAccntList.removeEnd(',') + ')';
        }else{
            isSolToNull = true;
            //soldToAccntList = '(\'No Sold To\')';
            //to make sure query returns no data
            soldToAccntList = '(null) AND Sold_To_Account__c != null ';
        }
        
        return soldToAccntList;
    }

/*
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Open','All Open Cases'));
        options.add(new SelectOption('Awaiting Info','All Cases Awaiting My Input'));
        options.add(new SelectOption('Solution Proposed','All Solutions Suggested'));
        options.add(new SelectOption('Closed','All Closed Cases'));
        return options;
    }
*/
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
        
        for(Schema.FieldSetMember f : SObjectType.Case.FieldSets.Portal_Case_Search_Fields.getFields()) {
            
            if(fields == null)fields = f.getFieldPath();
            else fields += ','+f.getFieldPath();
        }
        
        return fields;
   }
   
   private static String buildSearch(){
       String searchClause = '';
       String searchInp = ApexPages.CurrentPage().getParameters().get('inp');
       
       for(Schema.FieldSetMember f : SObjectType.Case.FieldSets.Portal_Case_Search_Fields.getFields()) {
           
           if(searchClause == null) searchClause  = f.getFieldPath() +' LIKE \'%'+searchInp+'%\' or ';
               searchClause  = searchClause + f.getFieldPath() +' LIKE \'%'+searchInp+'%\' or ';
       }
       
       if(searchClause!=null){
           searchClause = searchClause.removeEnd('or ');
       }
       
       return searchClause; 
   }
}