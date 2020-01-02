public class cloud_upfront_class {

     public class ApprovalStepsList{
        public Integer Step {get;set;}
        public String Type  {get;set;}
        public String Total_Discount {get;set;}
        public String Approver {get;set;}
        public String ApproverName {get;set;}
     }
     
     public List<ApprovalStepsList> values {get; set;}
     
     public cloud_upfront_class()
     {
        values = new List<ApprovalStepsList>();
        ApprovalStepsList asList;
        String quoteId;
        
        system.debug('-----------------quoteId -----------------'+ApexPages.currentPage().getParameters().get('id'));

        
        if(ApexPages.currentPage().getParameters().get('id') != null)
        {
         quoteId = ApexPages.currentPage().getParameters().get('id');
        }
        
        List<BigMachines__Quote__c> QuoteObj = [Select id,Sub_Region__c,BigMachines__Opportunity__r.Lines_of_Businesses__c,Discount__c,Additional_Legal_Terms__c,include_Special_Offer_in_Output__c from BigMachines__Quote__c where id=:quoteId limit 1];
        if(QuoteObj.isEmpty())
        	return;
        Map<String,PE_Cloud_Approval_Steps__c> allValues = PE_Cloud_Approval_Steps__c.getall();        
        List<String> settingNames = new List<String>();
        List<Integer> intList = new List<Integer>();
        settingNames.addAll(PE_Cloud_Approval_Steps__c.getall().keySet());
        for(String s : settingNames) intList.add(Integer.valueOf(s));
        intList.sort();        
        List<PE_Cloud_Approval_Steps__c> newValues =  new List<PE_Cloud_Approval_Steps__c>();
        for(Integer eacint: intList){ newValues.add(allValues.get(String.Valueof(eacint)));}
        
        Decimal OppDiscount =  QuoteObj[0].Discount__c;
        Boolean legalTerms =  QuoteObj[0].Additional_Legal_Terms__c;
        Boolean  speacialOffers = QuoteObj[0].include_Special_Offer_in_Output__c ;
        
        for(PE_Cloud_Approval_Steps__c eachVal : newValues )
        {
        asList = new ApprovalStepsList();
        asList.Type = eachVal.Type__c;
        asList.Total_Discount  = eachVal.Total_Discount__c;
        asList.Approver = eachVal.Approver__c;
        
        system.debug('-------------------------Lines_of_Businesses__c-----------------------------------'+QuoteObj[0].BigMachines__Opportunity__r.Lines_of_Businesses__c);
        
                system.debug('-------------------------Sub_Region__c-----------------------------------'+QuoteObj[0].Sub_Region__c);


        system.debug('-------------------------Approver__c-----------------------------------'+eachVal.Approver__c);


        
        List<Cloud_Approve_Table__c> caTableList = [Select id,Approver_Name__c from Cloud_Approve_Table__c where (Sub_Region__c =:QuoteObj[0].Sub_Region__c) and (Queue_Name__c =:eachVal.Approver__c) and (Type__c = 'Regular') limit 1];
        
        system.debug('-------------------------caTableList -----------------------------------'+caTableList);
       
        if(caTableList.size() > 0) { asList.ApproverName = caTableList[0].Approver_Name__c;}
        if(legalTerms && eachVal.Type__c == 'Any “Additional Legal Terms” (regardless of discount)')
        { 
        values.add(asList); 
        asList.Step = 1;
        }
        
        if(speacialOffers && eachVal.Type__c == 'Any “Business Exceptions” (regardless of discount)')
        { 
        values.add(asList); 
        asList.Step = 1;
        }
        
        if(eachVal.Type__c != 'Any “Additional Legal Terms” (regardless of discount)' && eachVal.Type__c != 'Any “Business Exceptions” (regardless of discount)' )
        {
        if(OppDiscount > 20 && eachVal.Total_Discount__c!= '>30%' && eachVal.Total_Discount__c!= '>40%' && eachVal.Total_Discount__c!= '>50%') 
        { 
        values.add(asList);
        asList.Step = 1;
        }
        else if(OppDiscount > 30 && eachVal.Total_Discount__c!= '>40%' && eachVal.Total_Discount__c != '>50%') 
        { 
        values.add(asList); 
        asList.Step = 1;
        }
        else if(OppDiscount > 40 && eachVal.Total_Discount__c!= '>50%')
        { 
        values.add(asList); 
        asList.Step = 2;
        }else if(OppDiscount > 50)
        {
        values.add(asList);
        asList.Step = 3;
        }
        }
      }  
    }
}