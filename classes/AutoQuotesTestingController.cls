/*
 * Class            : AutoQuotesTestingController
 * Description      : Controller Class for Auto Quoting VF Page.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Jul 03, 2017
 * Test Class       : AutoQuotesTestingControllerTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Modified BY      Modified Date       Changes/ Notes
 * ----------------------------------------------------------------------------------------------
 *
 */ 
 public class AutoQuotesTestingController {
    public Contact contactObj {get; set;}
    public Account accountObj {get; set;}
    public Boolean disableGenerateButton {get;set;}
    public List<BigMachines__Quote__c> quotes {get; set;}
    public List<ServiceContract> regularServiceContracts {get; set;}
    public List<ServiceContract> gapServiceContracts {get; set;}
    
    public Date regularQuoteStartDate {get; set;}  
    public Date regularQuoteEndDate {get; set;} 
    public String mode {get; set;}
                     
    public AutoQuotesTestingController(){
        mode = 'view';
        disableGenerateButton = true;
        contactObj = new Contact(); 
        accountObj = new Account();
        quotes = new List<BigMachines__Quote__c>();
        regularServiceContracts = new List<ServiceContract>(); 
        gapServiceContracts = new List<ServiceContract>();
    }

    public void refresh(){
        quotes = new List<BigMachines__Quote__c>();
        regularServiceContracts = new List<ServiceContract>(); 
        gapServiceContracts = new List<ServiceContract>();
        
        Boolean errors = false;
        if(contactObj.AccountId != NULL){
            accountObj = [SELECT Id, Name, Genesys_Care_Offering__c,
                             Support_Option__c, Partner_Product_Margin__c, Partner_GU_Margin__c,  
                             Auto_Renew_Eligible__c, Auto_Renew_Anniversary__c, Auto_Renew_Contract_Term__c, Auto_Renew_Rate__c,
                             Increased_Percentage__c, Auto_Renew_Contractual_Increase__c,
                             Genesys_Care_specialist__c, Genesys_Care_specialist__r.Email, 
                             Genesys_Care_Ops__c, Genesys_Care_Ops__r.Email
                          FROM Account WHERE id = :contactObj.AccountId];
            
            Integer contractTerm = 0;
            Map<String, List<String>> soldTo_PureEngage_Opportunities;
            Map<String, List<String>> soldTo_PureConnect_Opportunities; 
            
            if(accountObj.Auto_Renew_Eligible__c == true && accountObj.Auto_Renew_Anniversary__c != NULL){
                contractTerm = accountObj.Auto_Renew_Anniversary__c != NULL ? accountObj.Auto_Renew_Contract_Term__c.intValue() : 12;
                regularQuoteStartDate = accountObj.Auto_Renew_Anniversary__c.addDays(-2);
                regularQuoteEndDate = regularQuoteStartDate.addMonths(contractTerm).addDays(-1);
                
                soldTo_PureEngage_Opportunities = new  Map<String, List<String>>();
                soldTo_PureConnect_Opportunities = new  Map<String, List<String>>();
            }
                        
            if( (accountObj.Auto_Renew_Eligible__c == false) || (accountObj.Auto_Renew_Anniversary__c == NULL && accountObj.Auto_Renew_Contract_Term__c == NULL )){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Account is not eligible for Auto Renewal, Please review and update Account Auto Renewal Settings.'));
                disableGenerateButton = true;
            } else if (accountObj.Auto_Renew_Anniversary__c != NULL && (accountObj.Auto_Renew_Anniversary__c < Date.Today() || accountObj.Auto_Renew_Anniversary__c > Date.Today().addDays(120))) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Auto Renewal Anniversary is not in next 120 Days. Please review.'));
                disableGenerateButton = true;
            } else {
                disableGenerateButton = false;
            }
            
            regularServiceContracts = [SELECT id, Name, Renewal_Opportunity__c, Renewal_Opportunity__r.Name, Renewal_Opportunity__r.CloseDate,
                                            Sold_To_Name__c, Sold_To_Name__r.Name, AccountId, Account.Name, Offering_Type__c, Renewal_Opportunity__r.Lines_of_Businesses__c 
                                          FROM ServiceContract 
                                          WHERE Renewal_Opportunity__r.AccountId = :contactObj.AccountId 
                                            AND Renewal_Opportunity__r.RecordType.Name = 'Genesys Renewal' 
                                            AND Renewal_Opportunity__r.Opportunity_Status__c = 'In Progress'
                                            AND Renewal_Opportunity__r.CloseDate >= :regularQuoteStartDate
                                            AND Renewal_Opportunity__r.CloseDate <= :regularQuoteEndDate
                                            AND Renewal_Opportunity__r.Already_Auto_Renew__c = false
                                            ORDER BY Sold_To_Name__c ASC, Renewal_Opportunity__r.CloseDate ASC];
                
            gapServiceContracts = [SELECT id, Name, Renewal_Opportunity__c, Renewal_Opportunity__r.Name, Renewal_Opportunity__r.CloseDate,
                                        Sold_To_Name__c, Sold_To_Name__r.Name, AccountId, Account.Name, Offering_Type__c, Renewal_Opportunity__r.Lines_of_Businesses__c 
                                      FROM ServiceContract 
                                      WHERE Renewal_Opportunity__r.AccountId = :contactObj.AccountId AND Renewal_Opportunity__r.Eligible_for_Gap_Quote__c = true 
                                        ORDER BY Sold_To_Name__c ASC, Renewal_Opportunity__r.CloseDate ASC];
            
            quotes = [SELECT id, Name, End_User_ID__c, End_User_ID__r.Name, Sold_To_Name__c, Sold_To_Name__r.Name, 
                        BigMachines__Opportunity__c, BigMachines__Opportunity__r.Name, Sold_To_Region__c, 
                        Increase_type__c,  Maintenance_Start_Date__c, Maintenance_End_Date__c
                        FROM BigMachines__Quote__c WHERE End_User_ID__c = :contactObj.AccountId AND (Name LIKE '%-AUTO' OR Name LIKE '%-A')];
            
        }       
    }   

    public void editMode(){
        mode = 'edit';
    }    
    
    public void cancelEdit(){
        mode = 'view';
    }    
    public void saveAccount(){
        mode = 'view';
        Database.update(accountObj);
        refresh();
    }    
    
    // New Methods
    public PageReference generateAutoQuotesRegular(){
        if(contactObj.AccountId != NULL){
            String query = 'SELECT Id, Name, Genesys_Care_Offering__c,'
                         + 'Support_Option__c, Partner_Product_Margin__c, Partner_GU_Margin__c, '   
                         + 'Auto_Renew_Eligible__c, Auto_Renew_Anniversary__c, Auto_Renew_Contract_Term__c, Auto_Renew_Rate__c,' 
                         + 'Increased_Percentage__c, Auto_Renew_Contractual_Increase__c,'
                         + 'Genesys_Care_specialist__c, Genesys_Care_specialist__r.Email, Genesys_Care_Ops__c, Genesys_Care_Ops__r.Email '
                         + 'FROM Account WHERE Id = \''+ contactObj.AccountId +'\' AND Auto_Renew_Eligible__c = true';
            Database.executeBatch(new AutoRenewalBatch(query), 1);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You need to select an Account in order to proceed.'));
        }
        refresh();
        return null;
    }
    
    // New Methods
    public PageReference generateAutoQuotesGap(){
        if(contactObj.AccountId != NULL){
            String query = 'SELECT AccountId, Id FROM Opportunity WHERE AccountId = \''+ contactObj.AccountId +'\' AND Eligible_for_Gap_Quote__c = true';
            Database.executeBatch(new AutoRenewalGapQuotesBatch(query), 1);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You need to select an Account in order to proceed.'));
        }
        
        refresh();
        return null;
    }
    
    //
    public void deleteQuotes(){
        List<BigMachines__Quote__c> quotes = [SELECT id FROM BigMachines__Quote__c WHERE End_User_ID__c = :contactObj.AccountId AND (Name LIKE '%-AUTO' OR Name LIKE '%-A')];

        List<Opportunity> opportunities = new List<Opportunity>();
        for(Quote_Service_Contracts__c qsc : [SELECT Service_Contract__c, Service_Contract__r.Renewal_Opportunity__c FROM Quote_Service_Contracts__c WHERE Quote__c IN :quotes]){
            opportunities.add(new Opportunity(id=qsc.Service_Contract__r.Renewal_Opportunity__c, Already_Auto_Renew__c = false));
        }
        update opportunities;

        Database.delete(quotes);
        refresh();
    }

    public void lmsSync(){
        
        if(contactObj.AccountId != NULL) {
            List<Id> acclst = new List<Id>();
            acclst.add(contactObj.AccountId);
            LMSIintegrationService.putAccountsInLMSQueueById(acclst );
        }
        
        Database.executeBatch(new BatchLMSIntegrationProcessQueue(),5); 
           
    }
}