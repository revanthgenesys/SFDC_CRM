//Naresh Kumar  08/07/2015
public without sharing class CloudCommitmentController {

    public List<wrapperAccountSummary> accountSummary {get;set;}
    public List<wrapperCommitmentDetails> accountCommitmentData {get;set;}
    public Boolean showPopup {get;set;}
    public String selectedAccountName {get;set;}
    public String selectedAccountId {get;set;}
    public String recordIdToBeDeleted {get;set;}
    public String selectedDepartment {get;set;}
    public static final String NA = 'NA';
    public static final String RED = 'RED';
    public static final String ACTIVE = 'ACTIVE';
    public static final String YELLOW = 'YELLOW';
    public static final String GREEN = 'GREEN';
    public static final String GRAY = 'GRAY';
    public static final String STATUS_IN_PROGRESS = 'In Progress';
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String DEPARTMENT_SALES = '1.Sales';
    public static final String DEPARTMENT_OFFER_MGMT = '2.Offer Management';
    public static final String DEPARTMENT_PS = '3.PS';
    public static final String DEPARTMENT_PROVISIONING = '4.Provisioning';
    public static final String DEPARTMENT_SDQA = '5.SDQA';
    public static final String DEPARTMENT_OPERATIONS = '6.Operations';
    public static final String DEPARTMENT_CUSTOMER_CARE = '8.Customer Care';
    public static final String DEPARTMENT_CXM = 'CXM';
    
    
    public CloudCommitmentController(){
        populateRecords();
        showPopup = false;
    }
    
    private void populateRecords(){
        List<Account> accounts = [SELECT id, Name FROM Account WHERE Cloud_Flag__c =: true ORDER BY Name];
        List<Cloud_Commitment__c> cloudCommitments = [SELECT Account__c, Customer_Project__c, Comments__c, Health__c, 
        	JIRA_Id__c, JIRA_PCD_Id__c, Status_Description__c, Date__c, Department__c, Revised_Date__c, 
            Status__c, Commitment_Type__c, Probability__c, Dependent_On__c, Commitment_Assigned_To__c, LastModifiedBy.Name,
            OwnerId FROM Cloud_Commitment__c ORDER BY Department__c ASC];          
        Map<Id, List<Cloud_Commitment__c>> mapAccountIdVsCloudCommitment = new Map<Id, List<Cloud_Commitment__c>>();
        for(Cloud_Commitment__c eachCommitment : cloudCommitments){
            if(mapAccountIdVsCloudCommitment.get(eachCommitment.Account__c) == null){
                List<Cloud_Commitment__c> newList = new List<Cloud_Commitment__c>();
                newList.add(eachCommitment);
                mapAccountIdVsCloudCommitment.put(eachCommitment.Account__c, newList);
            }
            else
                mapAccountIdVsCloudCommitment.get(eachCommitment.Account__c).add(eachCommitment);
        }
        accountSummary = new List<wrapperAccountSummary>();
        //Looping over each Account
        for(Account eachAccount : accounts){            
            wrapperAccountSummary newRecord = new wrapperAccountSummary();
            newRecord.account = eachAccount;            
            newRecord.criticalDatesClass = NA;                       
            newRecord.salesClass = NA;
            newRecord.offerMgmtClass = NA;
            newRecord.PSClass = NA;
            newRecord.provisioningClass = NA;       
            newRecord.SDQAClass = NA;
            newRecord.operationsClass = NA; 
            newRecord.customerCareClass = NA;
            newRecord.CXMClass = NA;
            List<Cloud_Commitment__c> commitments = mapAccountIdVsCloudCommitment.get(eachAccount.id);            
            if(commitments != null && !commitments.isEmpty())
            	newRecord.noOfCommitments = commitments.size();
            System.debug('NKC debug commitments ['+commitments+']');
            if(commitments != null){
                Map<String,String> mapDepartmentVsClass = new Map<String, String>();
                Set<String> setOfColors = new Set<String>();
                for(Cloud_Commitment__c eachCommitment : commitments){
                	                   
                    String cl =  (eachCommitment.Health__c == null ? '' : eachCommitment.Health__c.toUpperCase());//getCommitmentStatus(eachCommitment);                    
                    setOfColors.add(cl);                        
                    /*                
                    if(eachCommitment.Department__c == DEPARTMENT_SALES){
                        newRecord.salesClass = cl;     
                        newRecord.sales = (cl == 'NA' ? '' : cl);
                        mapDepartmentVsClass.put(DEPARTMENT_SALES, cl);                
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_OFFER_MGMT){
                        newRecord.offerMgmtClass = cl;
                        newRecord.offerMgmt = (cl == 'NA' ? '' : cl);
                        mapDepartmentVsClass.put(DEPARTMENT_SALES, cl);                      
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_PS){
                        newRecord.PSClass = cl;                     
                        newRecord.PS = (cl == 'NA' ? '' : cl);
                        mapDepartmentVsClass.put(DEPARTMENT_SALES, cl);
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_PROVISIONING){
                        newRecord.provisioningClass = cl;            
                        newRecord.provisioning = (cl == 'NA' ? '' : cl);   
                        mapDepartmentVsClass.put(DEPARTMENT_SALES, cl);        
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_SDQA){
                        newRecord.SDQAClass = cl;                    
                        newRecord.SDQA = (cl == 'NA' ? '' : cl);   
                        mapDepartmentVsClass.put(DEPARTMENT_SALES, cl);
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_OPERATIONS){
                        newRecord.operationsClass = cl;    
                        newRecord.operations = (cl == 'NA' ? '' : cl);
                        mapDepartmentVsClass.put(DEPARTMENT_SALES, cl);                 
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_CUSTOMER_CARE){
                        newRecord.customerCareClass = cl; 
                        newRecord.customerCare = (cl == 'NA' ? '' : cl);
                        mapDepartmentVsClass.put(DEPARTMENT_SALES, cl);                      
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_CXM){
                        newRecord.CXMClass = cl;   
                        newRecord.CXM = (cl == 'NA' ? '' : cl);
                        mapDepartmentVsClass.put(DEPARTMENT_SALES, cl);                     
                    } 
                    */ 
                }   
                if(setOfColors.contains(RED)){
	                newRecord.status = RED;
	                newRecord.statusClass = RED;
                }
	            else if(setOfColors.contains(YELLOW)){
	                newRecord.status = YELLOW;
	                newRecord.statusClass = YELLOW;
	            }
	            else if(setOfColors.contains(GREEN)){
	                newRecord.status = GREEN;
	                newRecord.statusClass = GREEN;
	            }
	            else if (setOfColors.contains(GRAY)){
	                newRecord.status = GRAY;	
	                newRecord.statusClass = GRAY; 
	            }
	            /*       
                //Checking if 'YELLOW'
                for(Cloud_Commitment__c eachCommitment : commitments){
                    String cl =  eachCommitment.Status__c;//getCommitmentStatus(eachCommitment);
                    
                    if(eachCommitment.Department__c == DEPARTMENT_SALES){
                        if(eachCommitment.Dependent_On__c != null && 
                            mapDepartmentVsClass.get(eachCommitment.Dependent_On__c) == RED)
                        newRecord.salesClass = YELLOW;                
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_OFFER_MGMT){
                        if(eachCommitment.Dependent_On__c != null && 
                            mapDepartmentVsClass.get(eachCommitment.Dependent_On__c) == RED)
                        newRecord.offerMgmtClass = YELLOW;                      
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_PS){
                        if(eachCommitment.Dependent_On__c != null && 
                            mapDepartmentVsClass.get(eachCommitment.Dependent_On__c) == RED)
                        newRecord.PSClass = YELLOW;
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_PROVISIONING){
                        if(eachCommitment.Dependent_On__c != null && 
                            mapDepartmentVsClass.get(eachCommitment.Dependent_On__c) == RED)
                        newRecord.provisioningClass = YELLOW;        
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_SDQA){
                        if(eachCommitment.Dependent_On__c != null && 
                            mapDepartmentVsClass.get(eachCommitment.Dependent_On__c) == RED)
                        newRecord.SDQAClass = YELLOW;
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_OPERATIONS){
                        if(eachCommitment.Dependent_On__c != null && 
                            mapDepartmentVsClass.get(eachCommitment.Dependent_On__c) == RED)
                        newRecord.operationsClass = YELLOW;                 
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_CUSTOMER_CARE){
                        if(eachCommitment.Dependent_On__c != null && 
                            mapDepartmentVsClass.get(eachCommitment.Dependent_On__c) == RED)
                        newRecord.customerCareClass = YELLOW;                                              
                    }
                    else if(eachCommitment.Department__c == DEPARTMENT_CXM){
                        if(eachCommitment.Dependent_On__c != null && 
                            mapDepartmentVsClass.get(eachCommitment.Dependent_On__c) == RED)
                        newRecord.CXMClass = YELLOW;                     
                    }                                      
                    if(cl == RED){                      
                        continue;
                    }
                }        
                */          
            }            
            accountSummary.add(newRecord);
        }       
    }
    
    private String getCommitmentStatus(Cloud_Commitment__c eachCommitment){
        String cl = NA;
        if(eachCommitment.Date__c == null)
            return cl;
        System.debug('NKC debug eachCommitment.Date__c ['+eachCommitment.Date__c+']');
        if(eachCommitment.Date__c < System.today() && eachCommitment.Status__c == STATUS_IN_PROGRESS){
            cl = RED;
        }
        else if(eachCommitment.Date__c >= System.today() && eachCommitment.Status__c == STATUS_IN_PROGRESS){
            cl = ACTIVE;
        }
        else if(eachCommitment.Status__c == STATUS_COMPLETED){
            cl = GREEN;
        }
        return cl;
    }
    
    private Integer randomNumber(Integer lower, Integer upper){
        return Math.round((Math.random() * (upper - lower)) + lower);
    }
    
    public void showPopup(){
        showPopup = true;
        List<Cloud_Commitment__c> cloudCommitments;
        if(selectedDepartment == null || selectedDepartment == '')
            cloudCommitments = [SELECT Account__c, Customer_Project__c, Comments__c, Health__c, 
        	JIRA_Id__c, JIRA_PCD_Id__c, Status_Description__c, Date__c, Department__c, Revised_Date__c, 
                Status__c, Commitment_Type__c, Probability__c, Dependent_On__c, Commitment_Assigned_To__c, LastModifiedBy.Name,
                OwnerId FROM Cloud_Commitment__c WHERE Account__c =: selectedAccountId ORDER BY Department__c ASC];
        else
            cloudCommitments = [SELECT Account__c, Customer_Project__c, Comments__c, Health__c, 
        	JIRA_Id__c, JIRA_PCD_Id__c, Status_Description__c, Date__c, Department__c, Revised_Date__c, 
                Status__c, Commitment_Type__c, Probability__c, Dependent_On__c, Commitment_Assigned_To__c, LastModifiedBy.Name,
                OwnerId FROM Cloud_Commitment__c WHERE Account__c =: selectedAccountId AND Department__c =: selectedDepartment ORDER BY Department__c ASC];
        accountCommitmentData = new List<wrapperCommitmentDetails>();
        //Looping over each cloud commitment
        for(Cloud_Commitment__c eachCommit : cloudCommitments){
            wrapperCommitmentDetails newRecord = new wrapperCommitmentDetails();
            newRecord.record = eachCommit;
            accountCommitmentData.add(newRecord);   
        }
        if(accountCommitmentData.isEmpty())
            addRow();
    }
    
    public void save(){
        List<Cloud_Commitment__c> cloudCommitmentsToUpsert = new List<Cloud_Commitment__c>();
        for(wrapperCommitmentDetails eachRecord : accountCommitmentData){
            cloudCommitmentsToUpsert.add(eachRecord.record);
        }
        if(!cloudCommitmentsToUpsert.isEmpty())
            upsert cloudCommitmentsToUpsert;
        closePopup();
    }
    
    public void closePopup(){
        showPopup = false;
        populateRecords();
    }
    
    public void addRow(){
        wrapperCommitmentDetails newRecord = new wrapperCommitmentDetails();
        Cloud_Commitment__c newCommitment = new Cloud_Commitment__c(Account__c = selectedAccountId);        
        newRecord.record = newCommitment;
        if(selectedDepartment != null && selectedDepartment != '')
            newRecord.record.Department__c = selectedDepartment;
        accountCommitmentData.add(newRecord);   
    }
    
    public void deleteCommitment(){
        Cloud_Commitment__c cloudCommitmentToBeDeleted = new Cloud_Commitment__c(id = recordIdToBeDeleted);
        delete cloudCommitmentToBeDeleted;  
        showPopup();
    } 
    
    public class wrapperAccountSummary{
        public transient Account account {get;set;}
        public transient Integer noOfCommitments {get;set;}
        public transient Integer timeToRevenue {get;set;}
        public transient String timeToRevenueClass {get;set;}   
        public transient String status {get;set;}
        public transient String statusClass {get;set;}
        public transient String criticalDatesClass {get;set;}
        public transient String criticalDatesToolTip {get;set;}
        public transient String criticalDatesText {get;set;}
        public transient String sales {get;set;}
        public transient String salesToolTip {get;set;}
        public transient String salesClass {get;set;}
        public transient String offerMgmt {get;set;}
        public transient String offerMgmtClass {get;set;}
        public transient String offerMgmtToolTip {get;set;}
        public transient String PS {get;set;}
        public transient String PSClass {get;set;}
        public transient String PSToolTip {get;set;}
        public transient String provisioning {get;set;}
        public transient String provisioningClass {get;set;}
        public transient String provisioningToolTip {get;set;}
        public transient String SDQA {get;set;}
        public transient String SDQAClass {get;set;}
        public transient String operations {get;set;}
        public transient String operationsClass {get;set;}
        public transient String customerCare {get;set;}
        public transient String customerCareClass {get;set;}
        public transient String CXM {get;set;}
        public transient String CXMClass {get;set;} 
        public transient String overAllStatus {get;set;}
        public transient Boolean randomFlag {get;set;}
    }
    
    
    public class wrapperCommitmentDetails{
        public Cloud_Commitment__c record {get;set;}        
        public String slippage {get;set;}
        public String colorStatus {get;set;}         
    }
}