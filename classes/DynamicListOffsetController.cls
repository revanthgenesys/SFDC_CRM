/*
Class	: DynamicListOffsetController
Author –  Vinay Lakshmeesh
Date –    3/15/2013
Usage   : This Controller used by to implement pagination
Revision History
*/
public virtual class DynamicListOffsetController {

//  Const     
//  -------------------------------------------------------------------------------------------
    private String baseQuery;
    private String sObjectType;
    private String whereClause;
    public Boolean activated {get; set;}
    
	public DynamicListOffsetController(){
	 	//isDloadsPg = true;
	}
    public DynamicListOffsetController(String baseQuery, String sObjectType, String whereClause, Boolean activated) {
        this.baseQuery = baseQuery;
        this.sObjectType = sObjectType; 
        this.whereClause = whereClause;
        this.activated = activated;
    }
    
    public void ChangeQuery(String baseQuery, String sObjectType, String whereClause){
        records = null;
        this.baseQuery = baseQuery;
        this.sObjectType = sObjectType; 
        this.whereClause = whereClause;
      //  first();
    }
    
    public void resetResultSize(Integer rSize){
        this.resultSize = rSize;
    }
    
    public void resetResultSize(String baseQuery, String sObjectType, String whereClause){
		String queryString = baseQuery + ' '+ whereClause;  
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> QUERYSTR: '+queryString);
        
    //  Reboot the query
        this.resultSize = Database.countQuery(queryString);

    }
    
    //Change where clause without initial sorting - assignment manager
    public void changeWhereClause(String whrClause){
    	this.whereClause = whrClause;
    }
    
    public void resetwithPageSize(){
    	String queryString = this.baseQuery  + ' '+ this.whereClause;  
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> QUERYSTR: '+queryString);
        
    //  Reboot the query
        this.resultSize = Database.countQuery(queryString);
    	
    }
//  Get records
//  ------------------------------------------------------------------------------------------- 
    List<Sobject> records;
    protected List<SObject> getRecords() {
        if(records == null && activated)query();    
        return records;
    }
        
//  Query methods
//  -------------------------------------------------------------------------------------------
    
    protected void query() {
          
    //  Save pageSize
        Integer pageSize = this.pageSize;
        Integer offs;

        if ( math.abs(counter) > 2000 )
             offs = 2000;
        else
             offs = math.abs(counter);
             
    //  construct the query string
        String queryString = baseQuery + ' '+ whereClause+' '+ getSortClause()+' limit '+pageSize+' offset '+ offs;  
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> QUERYSTR: '+queryString);
        
    //  Reboot the query
	    if(baseQuery!=null){
	        records = Database.query(queryString);
	    }
    
    } 


//  Sort methods
//  -------------------------------------------------------------------------------------------
    public String sortColumn {
        get {
            if (sortColumn == null) sortColumn = 'date_modifiedx__c';
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
        records = null; 
        sortAsc = !sortAsc;
        return null;
    }

    protected virtual String getSortClause() {
        if (sortColumn == '') return '';
        else return ' order by ' + sortColumn + (sortAsc ? ' asc ' : ' desc ') + ' nulls last';
    }
    
//  Pagination
//  -------------------------------------------------------------------------------------------
    private     integer counter     =0;     //keeps track of the offset

    public void first()                             {   records = null; counter = 0;                                                        }
    public void previous()                          {   records = null; counter -= pageSize;                                                }
    public void next()                              {   records = null; counter += pageSize;                                                }
    public void last()                              {   records = null; counter = getResultSize() - math.mod(getResultSize(), pageSize);    }
    public Boolean getHasPrevious()                 {   if (counter>0) return true; else return false;                                      }
    public Boolean getHasNext()                     {   if (counter + pageSize < getResultSize()) return true; else return false;           }
    public Integer getPageNumber()                  {   return counter/pageSize + 1;                                                        }
    public void setPageNumber(Integer pageNumber)   {   counter += pageSize*pageNumber;                                                     }
    
//  Result Size (Count Query)
//  -------------------------------------------------------------------------------------------    
    private Integer resultSize;
    public Integer getResultSize(){
        if(ResultSize == null && activated && sObjectType != null && whereClause != null ){
            resultSize = Database.CountQuery('select count() from '+sObjectType+' '+whereClause);
        }
        return ResultSize == null ? 0 : ResultSize;
    }
    
    public Integer getPageCount(){  
        if(activated){  
            Integer oddRecordCount = Math.mod(getResultSize(), pageSize);
            return ((getResultSize() - oddRecordCount) / pageSize) + (oddRecordCount > 0 ? 1 : 0);
        } else return 0;
    } 

    public Integer pageSize {
        get {
            if (pageSize == null)pageSize = 5; 
            return pageSize;
        }
        set {
            records = null;
            pageSize = value;
        }
    }
    
    public Boolean getRenderResults() {
        return (getResultSize() > 0);
    }

    //** pass reference to dynamic paginator component 
    public DynamicListOffsetController getController () {
        return this;
    }


}