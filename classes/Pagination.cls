public with sharing class Pagination {
	public Apexpages.Standardsetcontroller setCon;
	public  List<Util.Wrappers> wrappers {get; set;} 
	public Pagination( String query, Integer size){
		setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
		setCon.setPageSize(size);
		
	}
	
	public List<Util.Wrappers> getWrappers() {
		
   		 wrappers = new List<Util.Wrappers>();
   		 for(Sobject o : (List<Sobject>) setCon.getRecords()){
   		 	Util.Wrappers w = new Util.Wrappers( o );
   		 	wrappers.add(w);
   		 } 
   		 return wrappers;
   	}
   	
	// indicates whether there are more records after the current page set.
	public Boolean hasNext {
		get {
			return setCon.getHasNext();
		}
		set;
	}
 
 
    public Boolean hasPrevious {
		get {
			return setCon.getHasPrevious();
		}
		set;
	}
 
	// returns the page number of the current page set
	public Integer pageNumber {
		get {
			return setCon.getPageNumber();
		}
		set;
	}
 
	// returns the first page of records
 	public void first() {
 		setCon.first();
 		getWrappers();
 	}
 
 	// returns the last page of records
 	public void last() {
 		setCon.last();
 		getWrappers();
 	}
 
 	// returns the previous page of records
 	public void previous() {
 		setCon.previous();
 		getWrappers();
 	}
 
 	// returns the next page of records
 	public void next() {
 		setCon.next();
 		getWrappers();
 	}
}