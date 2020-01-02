trigger ProductUpgradeRequestNotification on Product_Upgrade_Request__c (After Insert) {
    
    Set<Id> AccId= new Set<Id>();
    set<Id> EmailtoSend = new set<Id>();
    
    for(Product_Upgrade_Request__c PUR:Trigger.new){
        AccId.add(PUR.Account__c);
    }
    
    /*LstAcc = [SELECT Id,Name,Genesys_Care_Ops__c,Genesys_Care_Ops__r.Email,Genesys_Care_specialist__c,Genesys_Care_specialist__r.Email 
              FROM Account WHERE Id IN:AccId AND Genesys_Care_Ops__c !='' AND Genesys_Care_specialist__c !=''];
    system.debug('LstAcc #####'+LstAcc);
    */
     List<BigMachines__Quote__c> ListQuote = new List<BigMachines__Quote__c>();
         ListQuote = [SELECT Id,Name,BigMachines__Opportunity__r.Name,BigMachines__Status__c,BigMachines__Opportunity__r.Opportunity_Status__c,BigMachines__Opportunity__r.Recordtype.Name,BigMachines__Account__c,End_User_ID__c
                      FROM BigMachines__Quote__c WHERE BigMachines__Is_Primary__c=true AND BigMachines__Opportunity__r.Recordtype.Name='Genesys Renewal' 
                      AND BigMachines__Status__c Not IN ('Order Accepted','Order Submitted') 
                      AND BigMachines__Opportunity__r.Opportunity_Status__c IN ('In Progress','Hypothetical','Quoted','With Customer','Sent to Customer','CoTerm Pending')
                      AND BigMachines__Account__c IN:AccId];
    
    if(!ListQuote.isempty()){
        for(BigMachines__Quote__c Q:ListQuote){
            EmailtoSend.add(Q.End_User_ID__c);
        }
    }
    //Send Email Method
    if(!EmailtoSend.isempty()){
        ProductUpgradeRequestNotificationHelper.sendEmail(EmailtoSend);
    }
}