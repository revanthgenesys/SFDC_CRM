public with sharing class ServiceContractsCoTermController {

    public Sobject quote {get;set;}
    public  List<ServiceContract> sclines{ get; set; }
    public Opportunity opp{get;set;}
        
    public ServiceContractsCoTermController (ApexPages.StandardController stdController) {
        Quote_Service_Contracts__c [] quotesc;
        BigMachines__Quote__c[] quo;
        sclines = new List<ServiceContract>();
        this.quote= stdController.getRecord();
        if(quote.getsObjectType() == Opportunity.sObjectType) {
         quo = [select id from BigMachines__Quote__c where BigMachines__Opportunity__c=:quote.id and BigMachines__Is_Primary__c =true];
         if(!quo.isEmpty()) {
          quote = quo[0];   
         }
        }
                
        if(quote.getsObjectType() == BigMachines__Quote__c.sObjectType) {
          quotesc = [Select Service_Contract__c from Quote_Service_Contracts__c where Quote__c =:quote.id];
           ServiceContract sc = null;
           //Added next line by ankit on 4/28/2013
           List<ServiceContract> sc_lst;
           for( Quote_Service_Contracts__c scId:quotesc){
              //updated next line by ankit on 4/28/2013
             /*
             sc_lst= [select id,Agreement_Number__c,Name,Sold_To_Name__r.Name,Sold_To_Name__r.id, 
                    End_User_Name__r.Name,End_User_Name__r.id,Maintenance_Amount__c,PO_Number__c,
                    StartDate,EndDate, Renewal_Opportunity__r.Name, Renewal_Opportunity__r.id,
                    Renewal_Opportunity__r.Opportunity_Status__c
                     from ServiceContract where id =:scId.Service_Contract__c];        
             //added 2 lines by ankit on 4/28/2013
             */
             

             sc_lst= [select id, Name, Agreement_Number__c,
                    Sold_To_Name__r.Name,Sold_To_Name__r.id, 
                    End_User_Name__r.Name,End_User_Name__r.id,Maintenance_Amount__c,PO_Number__c,
                    StartDate,EndDate, Renewal_Opportunity__r.Name, Renewal_Opportunity__r.id,
                    Renewal_Opportunity__r.Opportunity_Status__c
                     from ServiceContract where id =:scId.Service_Contract__c];        
             
             
             if(sc_lst.size()>0)
             sc = sc_lst[0];
             
             if(sc!=null)
              sclines.add(sc);
            
            }
         }
    } 

    
    public List<ServiceContract> getSclines() {
        return sclines; 
        
    }
}