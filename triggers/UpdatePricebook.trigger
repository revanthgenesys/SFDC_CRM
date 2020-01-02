trigger UpdatePricebook on Opportunity (before update, before insert) {
    if(Util.Bypass_Trigger_Chk)return;
    Set<String> accIds = new Set<String>();
    Map<String, Account> mapAccIdVsAccount = new Map<String, Account>();
    Set<String> countryIds = new Set<String>();
    Set<String> ecCountryIds = new Set<String>();
    Map<String, Country__c> mapCountryIdVsCountry = new Map<String, Country__c>();
    Map<String, Country__c> mapECCountryIdVsCountry = new Map<String, Country__c>();    
    Map<String, List<Order__c>> mapOppIdVsOrder = new Map<String, List<Order__c>>();
    Set<String> oppOwnerIds = new Set<String>();
    Map<String, User> mapUserIdVsUser = new Map<String, User>();
    Map<String, String> mapOppIdVsOppOwnerId = new Map<String, String>();
    List<Order__c> orderListToBeUpdated = new List<Order__c>();
    Set<String> oppIds = new Set<String>();

    //Populating opp ids
    for(Opportunity eachOpp : Trigger.new){
        if(Trigger.oldMap == null || (eachOpp.BusinessPartner__c != null && eachOpp.BusinessPartner__c != Trigger.oldMap.get(eachOpp.id).BusinessPartner__c)
        	|| (eachOpp.Gene_Care_Specialist__c != Trigger.oldMap.get(eachOpp.id).Gene_Care_Specialist__c) 
        	|| (eachOpp.Quote_Mtce_Ops__c != Trigger.oldMap.get(eachOpp.id).Quote_Mtce_Ops__c)
        ){
            accIds.add(eachOpp.BusinessPartner__c);
            ecCountryIds.add(eachOpp.Country__c);
            oppOwnerIds.add(eachOpp.OwnerId);
            oppOwnerIds.add(eachOpp.Gene_Care_Specialist__c);
            oppOwnerIds.add(eachOpp.Quote_Mtce_Ops__c);
            if(Trigger.isUpdate){
                oppIds.add(eachOpp.id);
            }
        }
    }
    if(accIds.size() == 0)
        return;
    //Populating map mapAccIdVsAccount & country ids
    for(Account eachAcc : [SELECT id, Country__c, Country__r.Region__c FROM Account WHERE id in : accIds]){
        mapAccIdVsAccount.put(eachAcc.id, eachAcc); 
        if(eachAcc.Country__c != null) 
            countryIds.add(eachAcc.Country__c);      
    }
    //Populating mapCountryIdVsCountry map.
    for(Country__c eachCountry : [SELECT Region__c FROM Country__c WHERE id in : countryIds]){
        mapCountryIdVsCountry.put(eachCountry.id, eachCountry);    
    }
    //Populating mapECCountryIdVsCountry map.
    for(Country__c eachCountry : [SELECT Region__c FROM Country__c WHERE id in : ecCountryIds]){
        mapECCountryIdVsCountry.put(eachCountry.id, eachCountry);    
    }
    //Populating mapUserIdVsUser map.
    for(User eachUser : [SELECT Email FROM User WHERE id in : oppOwnerIds] ){
        mapUserIdVsUser.put(eachUser.id, eachUser);    
    }
    //Now looping over each opp and updating values
    for(Opportunity eachOpp : Trigger.new){
        if(eachOpp.Direct_Sales__c == true && eachOpp.Country__c != null){
            eachOpp.sold_to_country__c = eachOpp.Country__c;            
        }
        else if(eachOpp.Direct_Sales__c == false && eachOpp.Country__c != null && eachOpp.BusinessPartner__c != null){
            if(mapCountryIdVsCountry.get(eachOpp.Country__c) != null && mapECCountryIdVsCountry.get(eachOpp.Country__c) != null && 
                mapECCountryIdVsCountry.get(eachOpp.Country__c).Region__c != mapCountryIdVsCountry.get(eachOpp.Country__c).Region__c
                && eachOpp.RecordTypeId == '012U0000000LrBP'){
                eachOpp.BusinessPartner__c.addError('Please Enter Business Partner with in End User Country\'s region');
                return;       
            }
            if(mapAccIdVsAccount.get(eachOpp.id) != null && mapAccIdVsAccount.get(eachOpp.id).Country__c != null)
                    eachOpp.Sold_To_Country__c = mapAccIdVsAccount.get(eachOpp.BusinessPartner__c).Country__c;                
        }
        if(Trigger.isInsert)
            eachOpp.Opportunity_Owner__c = eachOpp.OwnerId;
   }
        
   if(Trigger.isUpdate){       
       //Populating mapOppIdVsOrder map.
       for(Order__c eachOrder : [SELECT id, Opportunity__c FROM Order__c WHERE Opportunity__c in : oppIds]){
           if(mapOppIdVsOrder.get(eachOrder.Opportunity__c) == null){
               List<Order__c> orderList = new List<Order__c>();
               orderList.add(eachOrder);
               mapOppIdVsOrder.put(eachOrder.Opportunity__c, orderList);
           }
           else{
               mapOppIdVsOrder.get(eachOrder.Opportunity__c).add(eachOrder);    
           }
       }
       //Now looping over each opp and updating values
       for(Opportunity eachOpp : Trigger.new){
            if(eachOpp.OwnerId != trigger.oldMap.get(eachOpp.id).OwnerId
            	|| (eachOpp.Gene_Care_Specialist__c != Trigger.oldMap.get(eachOpp.id).Gene_Care_Specialist__c) 
        	    || (eachOpp.Quote_Mtce_Ops__c != Trigger.oldMap.get(eachOpp.id).Quote_Mtce_Ops__c)){
                eachOpp.Opportunity_Owner__c = eachOpp.OwnerId;
                if(mapOppIdVsOrder.get(eachOpp.id) != null)                
                    for(Integer count = 0; count < mapOppIdVsOrder.get(eachOpp.id).size(); count++){
                        Order__c orderToBeUpdated = mapOppIdVsOrder.get(eachOpp.id)[count];
                        orderToBeUpdated.Rep_Email__c = mapUserIdVsUser.get(eachOpp.OwnerId).Email;
                        orderToBeUpdated.Genesys_Care_Specialist_Email__c = mapUserIdVsUser.get(eachOpp.Gene_Care_Specialist__c).Email;
                        orderToBeUpdated.Genesys_Care_Ops_Email__c = mapUserIdVsUser.get(eachOpp.Quote_Mtce_Ops__c).Email;
                        orderListToBeUpdated.add(orderToBeUpdated);
                    }
            }
        }
    }     
    if(!orderListToBeUpdated.isEmpty()){
        Database.SaveResult[] result = Database.update(orderListToBeUpdated, false);
        Integer counter = 0;
        // Iterate through the Save Results
        for(Database.SaveResult sr:result){
            if(!sr.isSuccess()){
                Database.Error err = sr.getErrors()[0];        
                orderListToBeUpdated[counter].addError(err.getMessage());
            }
            counter ++;
        }
    }
}