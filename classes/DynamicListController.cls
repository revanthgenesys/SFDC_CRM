/*
Class	: DynamicListController
Author –  Vinay Lakshmeesh
Date –    3/15/2013
Usage   : This Controller used by to implement pagination
Revision History
*/
public virtual class DynamicListController {
  
//  To pass controller to component        
//  -------------------------------------------------------------------------------------------
    private ApexPages.StandardSetController controller;
           
//  Const     
//  -------------------------------------------------------------------------------------------
    private String baseQuery;
    public DynamicListController(String baseQuery) {
        this.baseQuery = baseQuery;
        query();
    }

//  Query methods
//  -------------------------------------------------------------------------------------------
    protected void query() {
    
    //  construct the query string
        String queryString = baseQuery + ' ' + getWhereClause() + ' ' + getSortClause() + ' limit 10000';        

    //  Save pageSize
        Integer pageSize = this.pageSize;
		System.debug('NKC debug queryString ['+queryString+']');
    //  Reboot standard set controller
        controller = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));

    //  Reset pageSize
        this.pageSize = pageSize; 
    
    } 

//  Search methods
//  -------------------------------------------------------------------------------------------
    public PageReference search() {
        query();
        return null;
    }

//  Override to construct dynamic SOQL where clause 
//  -------------------------------------------------------------------------------------------
    public String nameSearchFld {get; set;}    
    public virtual String getWhereClause() {
        if (nameSearchFld != null && nameSearchFld.trim() != '')
            return 'where Name like :nameSearchFld ';
        else return '';
    }

//  Sort methods
//  -------------------------------------------------------------------------------------------
    public String sortColumn {
        get {
            if (sortColumn == null) sortColumn = '';
            return sortColumn;
        }
        set {
            if (sortColumn != value) sortAsc = false;
            sortColumn = value;
        }
    }

    public Boolean sortAsc {
        get {
            if (sortAsc == null) sortAsc = false;
            return sortAsc;
        } 
        set;
    }

    public PageReference sort() {
        sortAsc = !sortAsc;
        query();    
        return null;
    }

    protected virtual String getSortClause() {
        if (sortColumn == '') return ' order by ' + 'Date_Modifiedx__c' + (sortAsc ? ' asc ' : ' desc ') + ' nulls last';
        else return ' order by ' + sortColumn + (sortAsc ? ' asc ' : ' desc ') + ' nulls last';
    }

//  Get records
//  ------------------------------------------------------------------------------------------- 
    protected List<SObject> getRecords() {
        return controller.getRecords();
    }

//  Pagination
//  -------------------------------------------------------------------------------------------
    public void first()                             {   controller.first();                     }
    public void previous()                          {   controller.previous();                  }
    public void next()                              {   controller.next();                      }
    public void last()                              {   controller.last();                      }
    public Boolean getHasPrevious()                 {   return controller.getHasPrevious();     }
    public Boolean getHasNext()                     {   return controller.getHasNext();         }
    public Integer getResultSize()                  {   return controller.getResultSize();      }
    public Integer getPageNumber()                  {   return controller.getPageNumber();      }
    public void setPageNumber(Integer pageNumber)   {   controller.setPageNumber(pageNumber);   }   
    
    public Integer getPageCount(){
        Integer resultSize = getResultSize();
        Integer oddRecordCount = Math.mod(resultSize, pageSize);
        return ((resultSize - oddRecordCount) / pageSize) + (oddRecordCount > 0 ? 1 : 0);
    } 
 
    public Integer pageSize {
        get {
            if (controller != null) 
                pageSize = controller.getPageSize();
            else
                // default pagesize
                pageSize = 20; 

            return pageSize;
        }

        set {
            pageSize = value;
            controller.setPageSize(pageSize);
        }
    }

    public Boolean getRenderResults() {
        return (getResultSize() > 0);
    }

    //** update methods
    public virtual PageReference save() {
        return controller.save();
    }

    public virtual PageReference cancel() {
        return controller.cancel();
    }

    //** pass reference to dynamic paginator component 
    public DynamicListController getController () {
        return this;
    }
}