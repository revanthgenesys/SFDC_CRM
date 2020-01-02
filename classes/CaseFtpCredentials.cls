@isTest(seeAllData = true)
public without sharing class CaseFtpCredentials {	
	private final Case cs;
    public String user {get; set;}
    public String pswd {get; set;}
    
    public CaseFtpCredentials(ApexPages.StandardController stdController) {            
       this.cs = (Case)stdController.getRecord();
                        
       try {
                Case csquery = [SELECT CaseNumber, Case_Number__c, End_User_Account__c, Status,
                                       Sold_To_Account__c, End_User_Account__r.Support_Group__c  
                                FROM Case WHERE ID= :cs.ID];
       
            	FTP_Access__c fa =      [SELECT f.SAP_Code_Sold_To__c, f.SAP_Code_End_User__c,
                                             f.FTP_User_Name__c, f.FTP_Password__c 
                                      FROM FTP_Access__c f
                                      WHERE f.End_User_Account__c= :csquery.End_User_Account__c
                                        AND f.Sold_To_Account__c= :csquery.Sold_To_Account__c
                                     ];
 
                user = fa.FTP_User_Name__c;
                pswd = fa.FTP_Password__c;                                                                                                
       }
       catch (Exception e) {
              
       }
    }
    public CaseFtpCredentials() {            
       this.cs = [SELECT id FROM Case WHERE id =: ApexPages.currentPage().getParameters().get('id')];
                        
       try {
                Case csquery = [SELECT CaseNumber, Case_Number__c, End_User_Account__c, Status,
                                       Sold_To_Account__c, End_User_Account__r.Support_Group__c  
                                FROM Case WHERE ID= :cs.ID];
       
            	FTP_Access__c fa =      [SELECT f.SAP_Code_Sold_To__c, f.SAP_Code_End_User__c,
                                             f.FTP_User_Name__c, f.FTP_Password__c 
                                      FROM FTP_Access__c f
                                      WHERE f.End_User_Account__c= :csquery.End_User_Account__c
                                        AND f.Sold_To_Account__c= :csquery.Sold_To_Account__c
                                     ];
 
                user = fa.FTP_User_Name__c;
                pswd = fa.FTP_Password__c;                                                                                                
       }
       catch (Exception e) {
              
       }
    } 
    
    static testMethod void CaseFtpCredentials()  {
    	
		Case testCase = TestUtil.createCases(1, true)[0];       
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        CaseFtpCredentials crd = new CaseFtpCredentials(stdController);
        String pswd = crd.pswd;
        String user = crd.user;
	}
}