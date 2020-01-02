public class Order_checklist
 {
  
    
    public ID orderId { get; set; }
    
    public boolean flag { get; set; }
    
    public string scurl{get;set;}
    
    public Export_Screening_Checklist__c esc{get;set;}

    public Order_checklist(ApexPages.StandardController c) 
   {
     orderId = c.getRecord().id;
     
     List<order__c> records = [SELECT Id,End_User_Name__c FROM Order__c WHERE End_User_Name__r.screening_checklist_completed__c = true and id=:orderId limit 1];
     
     If( records.size()!=0)
        {
           list<Export_Screening_Checklist__c> lst = [select id,name,Completiondate__c,screening_checklist_completed__c,Checklist_expiration_date__c,Status__c,CreatedDate,ownerid  from Export_Screening_Checklist__c where account__c=:records[0].End_User_Name__c and screening_checklist_completed__c = true  limit 1];
           if(lst.size()>0)
           esc = lst[0];
           flag=true;
           scurl= '/apex/compliance_edit?retURL=/'+records[0].End_User_Name__c+'&sfdc.override=1&mode=edit';
        }
        else 
        {
            flag=false;
            scurl= null;
        }
   }
   
 
 
        
       
        
       
    

}