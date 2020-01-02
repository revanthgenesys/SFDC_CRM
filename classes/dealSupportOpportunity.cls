global class dealSupportOpportunity {
    
    webservice static String createopty(ID tid){        
       list<opportunity> opporty = new list<opportunity>();
      // list<deal_support__c> dslobj = new list<deal_support__C>();
       
      // list<deal_support__c> dslobj = [select id,name,Opportunity__c from deal_support__c where id=:dsrid ];
       list<DSR_Opportunity_Detail__c> optylist = [select id, Name,Stage__c, Account__c,Close_Date__c,Deal_Support__c,Direct_Indirect_Sale__c,Lead_Offer__c,Opportunity_Currency__c,Opportunity_Source__c,recordtype__c,BusinessPartner__c,Sold_To_Country__c,Primary_Contact__c from DSR_Opportunity_Detail__c where id=:tid ];  
      
        for(DSR_Opportunity_Detail__c pro:optylist){            
            opportunity oppty = new opportunity();
            oppty.CloseDate= pro.Close_Date__c;
            oppty.StageName =  pro.Stage__c;
            oppty.Accountid = pro.Account__c;
            oppty.Name = pro.Name ; 
            oppty.Direct_Indirect_Sale__c = pro.Direct_Indirect_Sale__c ; 
            oppty.Lead_Offer__c = pro.Lead_Offer__c ; 
            oppty.CurrencyIsoCode = pro.Opportunity_Currency__c ; 
            oppty.Partner_Opportunity_Source__c = pro.Opportunity_Source__c ; 
            oppty.RecordTypeid = [Select id,name from RecordType where name = 'GEN - Opportunity Record Type' AND SObjectType = 'opportunity' ].id ; 
            oppty.BusinessPartner__c = pro.BusinessPartner__c ; 
            oppty.Sold_To_Country__c = pro.Sold_To_Country__c ; 
            oppty.Contact__c = pro.Primary_Contact__c ;   
            oppty.Transactional_Help__c = true;
            opporty.add(oppty); 
        }
        Database.SaveResult[] lsr = Database.insert(opporty);
        
       /*for(deal_support__c dsropp : dslobj){
            dsropp.Opportunity__c = lsr[0].getId();
            dslobj.add(dsropp);
            }
            update dslobj; */

       //insert opporty; 
        if (lsr[0].isSuccess()) {
            Deal_Support__c dsobj = [select id,Opportunity__c from Deal_Support__c where id =: optylist[0].Deal_Support__c];
            dsobj.Opportunity__c = lsr[0].getId();
            update dsobj;
            return lsr[0].getId();
           
            
        }
        else{return 'failed';}
        
         
       
    }
}