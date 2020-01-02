public with sharing class SWDLPortalCustomerHistoryController {
        
        private String orderBy;
        private String whereClause;
        private String q;
               	        
        public ApexPages.StandardSetController setCon {
        get {                       
            if(setCon == null) {
                whereClause ='';
                q = '';
    
                List<User> lstUser = [SELECT Id,ContactId 
                                      FROM   User  
                                      WHERE  Id = :UserInfo.getUserId()];
                for(Support_Access__c sa : [SELECT End_User_Account__c,Sold_To_Account__c
                                            FROM   Support_Access__c 
                                            WHERE Contact__c = :lstUser[0].ContactId                                                                                       
                                               and SR_Access_Level__c = 'Read/Write'
                                               and Service_Contract_Status__c ='Active'
                                               and Status__c ='Active']) {
                
                
                       if(sa.End_User_Account__c!=null && sa.Sold_To_Account__c!=null){
                             if ( whereClause != '' )
                                   whereClause += ' OR ';
                                           
                            whereClause += '(End_User_Account__c= \'' + sa.End_User_Account__c + '\'' +
                                           ' and Sold_To_Account__c= \''+ sa.Sold_To_Account__c + '\')';
                     }
                }
                
                if ( whereClause == '' )
                    whereClause = 'ID = null'; //return nothing
                
                setQ();              

                 System.debug('<<<<['+ q + ']>>>>');                
                 setCon = new ApexPages.StandardSetController(Database.getQueryLocator(q));
            }
            return setCon;
        }
        set;
    }

    public void first()                             {   setCon.first();                     }
    public void previous()                          {   setCon.previous();                  }
    public void next()                              {   setCon.next();                      }
    public void last()                              {   setCon.last();                      }
    public Boolean getHasPrevious()                 {   return setCon.getHasPrevious();     }
    public Boolean getHasNext()                     {   return setCon.getHasNext();         }
    public Integer getResultSize()                  {   return setCon.getResultSize();      }
    public Integer getPageNumber()                  {   return setCon.getPageNumber();      }
    public void setPageNumber(Integer pageNumber)   {   setCon.setPageNumber(pageNumber);   } 
    
    public List<Customer_SW_Download_History__c> getHistory() {   
        return (List<Customer_SW_Download_History__c>) setCon.getRecords();
    }
    
    public void toggleSort() {
          sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
          
          setQ();
          setCon = new ApexPages.StandardSetController(Database.getQueryLocator(q));
    } 
    
    public String sortDir {
        get  { 
                if (sortDir == null) {  
                        sortDir = 'desc'; 
                } return sortDir;
        }
        set;
    }
    
    public String sortField {
        get  { 
                if (sortField == null) {
                        sortField = 'CreatedDate'; 
                } 
                return sortField;  
        }
        set;
    } 
    
    private void setQ () {
        
        q = 'SELECT c.Version__c, c.Sold_To_Account__c, c.Release_Date__c, c.Product__c,' + 
                           ' c.OS__c,c.Major_Release__c, c.Language__c, c.File_Size__c, '         +
                           ' c.File_Name__c, c.End_User_Account__c, STEU__c,'                             +
                           ' c.Date_of_Download__c,c.CreatedDate, c.Contact__c, c.Contact_Name__c,' +
                           ' c.Contact_Country__c, c.Component__c, c.Component__r.Name ' +
                     'FROM Customer_SW_Download_History__c c Where ' + 
                      whereClause +
                     ' ORDER BY ' + sortField + ' ' + sortDir + ' nulls last';
    }
}