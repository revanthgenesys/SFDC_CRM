public class clsSCEngagementReport
{
   public List<wow_request_form__c>list_wow{get;set;}
   public Integer pageSize {get; set;}
   Public Integer noOfRecords{get; set;}
   
   public clsSCEngagementReport(ApexPages.StandardController ctrl)
   {
     list_wow = new List<wow_request_form__c>();
     noOfRecords = list_wow.size();
     inIt();
   }
   
   private void inIt()
   {
     
     
     list_wow = [Select id,name,Opportunity_Id__r.owner.name,Account_Id__c,
                    AE__c,
                    AE_Name__c,
                    Opp_Annual_Contract_Value__c,
                    ArchitectureBlueprints__c,
                    Assign_Queue__c,
                    AssignTo__c,
                    Opp_Annual_Contract_Value_new__c,
                    BC__c,
                    Business_Partner__c,
                    Opp_Monthly_Commitment__c,
                    Custom_Architecture__c,
                    Customer_Name__c,
                    Custom_Use_Case__c,
                    Deployment_Topology__c,
                    Design_Activities__c,
                    Design_End_Date__c,
                    Design_Start_Date__c,
                    Discovery_Activities__c,
                    Type_of_Discovery__c,
                    Discovery_End_Date__c,
                    Discovery_Start_Date__c,
                    DSR_Open_Days__c,
                    Opp_Estimated_Usage_Agreements_EUA__c,
                    Expected_Closed_Date__c,
                    Expected_Discovery_Start__c,
                    FunctionalUseCase__c,
                    Opp_Genesys_Care_Amount__c,
                    Opp_Hardware_Total__c,
                    High_Level_Request_details__c,
                    Impact_SC_Engagement__c,
                    Industry__c,
                    Internal_Kick_Off_Date__c,
                    IsBCOwner__c,
                    IsSEOwner__c,
                    Primary_Business_Objectives__c,
                    Lead__c,
                    Lessons_Learned_Feedback__c,
                    Opp_License_Amount__c,
                    Opp_License_Equivalency__c,
                    Opportunity_Id__c,
                    Opportunity_Name__c,
                    Partner_Customer_Aware_Design__c,
                    Platform_Type__c,
                    Opp_Potential_Pipeline__c,
                    Primary_Solution__c,
                    Opp_Professional_Service_Amount_RDP__c,
                    Opp_Total_PS_Support__c,
                    SEM__c,
                    Rejected_Status__c,
                    WoW_Status__c,
                    Wow_URL__c,
                    Score__c,
                    SE__c,
                    Stage__c,
                    Technical_Profile__c,
                    Technical_Profile_Acknowledgement_Date__c,
                    Temp_Lead__c,
                    Temp_Lead_SLA__c,
                    Opp_Term_License__c,
                    Opp_Term_License_Amount_TCV__c,
                    Total_Amount__c,
                    Opp_Total_Annual_Contract_Value__c,
                    Type_of_Design__c,
                    VirtualTeamMembers__c,
                    Vision_Activity__c,
                    Vision_Start_Date__c,
                    Vision_Stage_Activities__c,
                    Who_Provides_Design__c,LastModifiedById,(Select id,name from Attachments) from wow_request_form__c];
   }
   
   public List<Wow_Request_Form__c> getUserRecords() {
    return (List<Wow_Request_Form__c>) con.getRecords();
  }
  public ApexPages.StandardSetController con {
    get {
        if(con == null) {
            pageSize = 25;
           
            con = new ApexPages.StandardSetController(list_wow);
            
            //Sets the number of records in each page set
            con.setPageSize(pageSize);
        }
        return con;
    }
    set;
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
    
    // returns totall number of records
    public Integer resultSize {
        get {
            return con.getresultSize();
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
    /**
    * Method to calculate total number of pages 
    * @return number of page set    
    */
    public Integer getTotalPages() {
        System.debug('resultSize-->'+resultSize);
        System.debug('pageSize-->'+pageSize);
        
        if(math.mod(resultSize, pageSize) > 0) {
            return resultSize/pageSize + 1;
        }
        else {
            return (resultSize/pageSize);
        }
    }
}