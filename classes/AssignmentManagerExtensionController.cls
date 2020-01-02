/*
Class	: AssignmentManagerExtensionController
Author –  Vinay Lakshmeesh
Date –    4/01/2013
Usage   : AssignmentManagerExtensionController is a extension controller to 
		  1) display analyst score has been calculated based on the agent’s fit to meet the requirements. 
		  This calculation will be performed at a case level, when the Assignment Manager button is 
		  clicked on a case record
		  2) assign the agent to the Case (owner) from the list of avaliable records on the
		  paginated table.
		   
		  DynamicListOffsetController - Pagination and sorting of agents table
Revision History
*/
global with sharing class AssignmentManagerExtensionController{
	
	public Case ca {get;set;}
	public Id newOwnerId {get;set;}
	public boolean hasErrors {get;set;}
	List<userWrapper> users {get;set;}
	public static Map<Id,Integer> usrWrkLdScore = new Map<Id,Integer>();
	List<User> querryUsrList = new List<User>();
	List<Case> caList = new List<Case>();
	List<Id> userIdList = new List<id>();
	List<User> listOfAgents = new List<User>();
	
	public AssignmentManagerExtensionController(){
		Id caId = Apexpages.currentPage().getParameters().get('Id');
		this.ca = [Select Id,CaseNumber,Support_Product__c, End_User_Support_Group__c, End_User_Account__r.Support_Group__c, OwnerId FROM Case WHERE id= :caId][0];
		if( this.ca.Support_Product__c == null || string.valueof( this.ca.Support_Product__c ) == ''){
            Apexpages.addMessage( new Apexpages.Message( Apexpages.Severity.ERROR, 'Please ensure there is Product attached to the case.') );
            //this.activated = true;
            this.hasErrors = true;
           // return null;
        }
        else{
		  calculateScore();
        }
	}

    
    // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController con {
    	
        get {
            if(con == null) {
                
                con = new ApexPages.StandardSetController(querryUsrList);
                // sets the number of records in each page set
                con.setPageSize(99999);
            }
            return con;
        }
        set;
    }
    
	// returns a list of wrapper objects for the sObjects in the current page set
    public List<userWrapper> getUsers() {
        users = new List<userWrapper>();
        
        List<User> newList = con.getRecords();
        calcScoreForUsers();
        //calculateScore();
        for (User u : newList)
            users.add(new UserWrapper(u,usrWrkLdScore.get(u.Id)));
        users.sort();
        return users;
    }
     
   //  Get the fields from a field set 
   //  ---------------------------------------------------------------------------------------------
   private static String ListFields(){  
        String fields;             
        
        for(Schema.FieldSetMember f : SObjectType.User.FieldSets.Assignment_Manager_Fields.getFields()) {
            
            if(fields == null)fields = f.getFieldPath();
            else fields += ','+f.getFieldPath();
        }
        
        return fields;
   }
   

    public pageReference lazyLoad(){
    	/*if( this.ca.Support_Product__c == null || string.valueof( this.ca.Support_Product__c ) == '')
		{
			Apexpages.addMessage( new Apexpages.Message( Apexpages.Severity.ERROR, 'Please ensure there is Product attached to the case.') );
			//this.activated = true;
			this.hasErrors = true;
			return null;
		}else{
			// Calculate the score of each available agent 
			calculateScore();
			
			//this.activated = true;
			//this.pageSize = 10;
			String whereClause = ' Profile.Name like \'Tech Support%\' and Current_Status__c = \'Available\'';
			//Change Query to get the agents 
			this.ChangeQuery('SELECT  '+ListFields()+' from User where','User', whereClause);
			//Get size of the table - to support pagination
			this.resetResultSize('SELECT  count() FROM User where ','User', whereClause);
		    //activated = true;
		    getUsers();
		    this.changeWhereClause(whereClause);// Change where clause without sorting
		    this.sortColumn = 'Total_Score__c';
		    sort();// Sort Asc
		    sort();// Sort Desc
		}*/
        return null;
    }
    
    /*
    	Method : calculateScore
    	Usage  : Calculate and update the score of each avaliable.
    
    */
    public void calculateScore(){
    	
    	String whereClause = ' Profile.Name like \'Tech Support%\' and Current_Status__c = \'Available\'';
    	
    	listOfAgents = Database.query('SELECT  Id, '+ListFields()+' from User where' +whereClause);
   		userIdList = new List<id>();
   		system.debug('--listOfAgents'+listOfAgents);
   		
   		for(User u:listOfAgents){
   			userIdList.add(u.Id);
   		}
   		
   		
   		/*caList = [Select OwnerId,Sub_Status__c
                     From   Case
                     Where OwnerId in:userIdList];*/
                     
   		calcScoreForUsers();
    }
    
    public void calcScoreForUsers(){
    	Map<Id,boolean> hasOpenTier2Cases = new Map<Id,boolean>();
        Map<Id,boolean> hasOpenTier3Cases = new Map<Id,boolean>();
        List<User> updateUsrList = new List<User>();
        
        /*
        for(Case c: [Select OwnerId,Sub_Status__c
                     From   Case
                     Where  status != 'Closed' and OwnerId in:userIdList ]) {
            
            if(c.Sub_Status__c == 'Tier 2'){
                hasOpenTier2Cases.put(c.OwnerId, true);
            }
            
            if(c.Sub_Status__c == 'Tier 3'){
                hasOpenTier3Cases.put(c.OwnerId, true);
            }           
        } */
        
        Map<Id,List<Id>> mapOfSkills = new Map<id,List<Id>>();
        
        for(Customer_Care_Analyst_Skill__c ccSkill :[Select Support_Product__c, User__c 
                                                     from   Customer_Care_Analyst_Skill__c
                                                     where  User__c in: userIdList]){
                                                        
            List<Id> skillList = new List<Id>();
            
            if(mapOfSkills!=null && mapOfSkills.get(ccSkill.User__c)!=null){
                skillList = mapOfSkills.get(ccSkill.User__c);
            }
            
            skillList.add(ccSkill.Support_Product__c);
            mapOfSkills.put(ccSkill.User__c,skillList);
        }
        
        for(User u:listOfAgents){
            Integer regionScore = 0;
            Integer totalScore = 0;
            Set<Id> uniqueSkillSet = new Set<Id>();
            
            if(mapOfSkills!=null && mapOfSkills.get(u.Id)!=null){
                uniqueSkillSet.addAll(mapOfSkills.get(u.Id)); 
            }
            
            system.debug('--this.ca.End_User_Account__r.Support_Group__c '+this.ca.End_User_Account__r.Support_Group__c );
            regionScore += 1200 //base score
                            +(this.ca.End_User_Account__r.Support_Group__c == u.Support_Group__c ? 100000 : 0)
                           // +  (hasOpenTier2Cases.get(u.Id) != null ? 1000 : 0)
                           // +  (hasOpenTier3Cases.get(u.Id) != null ? 200 : 0)
                            + (uniqueSkillSet.contains(this.ca.Support_Product__c) ? 1500 : 0);
            system.debug('--regionScore'+regionScore);
            system.debug('--u'+u);
            totalScore =  (Integer) (regionScore - (u.Care_Analyst_Workload_Score__c !=null ? u.Care_Analyst_Workload_Score__c :0));
            
            usrWrkLdScore.put(u.Id,totalScore);        
            
            updateUsrList.add(u);
        }
        
        querryUsrList = updateUsrList;
    }
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
 
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
 
    // returns the first page of records
    public void first() {
        con.first();
    }
 
    // returns the last page of records
    public void last() {
        con.last();
    }
 
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
 
    // returns the next page of records
    public void next() {
        con.next();
    }
 
    // returns the PageReference of the original page, if known, or the home page.
    public void cancel() {
        con.cancel();
    }
 
    /*
    	Method : assignCaseOwner
    	Usage  : Assign case to the selected agent
    */
    public Pagereference assignCaseOwner(){
    	//String oldOwnerId = ca.OwnerId;
    	ca.OwnerId = newOwnerId;
    	update ca;
    	/*Set<Id> userIds = new Set<Id>();
    	
    	if(oldOwnerId.substring(0,3) != '00G')userIDs.add(oldOwnerId);   
    	
    	if(userIDs != null && userIDs.size()>0) UserWorkload.calculateWorkload(userIds);// Recalculate the workload score of the old owner.*/
    	
    	return null;
    	
    }
    
    public Pagereference closePage(){
    	return null;
    }
    
    global class UserWrapper implements comparable{
 
	    //public Boolean checked{ get; set; }
	    public User usr { get; set;}
	    public Decimal totalScore {get;set;}     
	    public UserWrapper(){
	        usr = new User();
	        //checked = false;
	    }
	 
	    public UserWrapper(User u,Integer score){
	        usr = u;
	        //checked = false;
	        totalScore =(Decimal) score;
	    }
	    global Integer compareTo(Object compareToObj) {
	    	//UserWrapper compareToUsr = (UserWrapper)compareTo;
	       /* if (regionScore == compareToUsr.regionScore) return 0;
	        if (regionScore > compareToUsr.regionScore) return 1;
	        return -1;   */
	        // Cast argument to OpportunityWrapper
            UserWrapper compareToUsr = (UserWrapper)compareToObj;
        
        // The return value of 0 indicates that both elements are equal.
	        Integer returnValue = 0;
	        if (totalScore > (Integer) compareToUsr.totalScore) {
	            // Set return value to a positive value.
	            returnValue = -1;
	        } else if (totalScore < (Integer) compareToUsr.totalScore) {
	            // Set return value to a negative value.
	            returnValue = 1;
	        }
            return returnValue;  
	        // return Integer.valueOf(regionScore - ((UserWrapper)objToCompare).regionScore);
	             
        }
	    
 
    }
    
}