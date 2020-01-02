public with sharing class QuoteRedirectController {

    public Id quoteId;
    public BigMachines__Quote__c quoteObj {get; set;}
    
    public QuoteRedirectController(ApexPages.StandardController controller) 
    {
        quoteId = ApexPages.currentPage().getParameters().get('id');
        quoteObj =  new BigMachines__Quote__c();
    }

    public PageReference goToPage(){   
        System.debug('In QuoteRedirectController.goToPage() - Start');
        quoteObj  = [select Offering_Type__c,id, Quote_Business_Type__c, BigMachines__Account__c, BigMachines__Opportunity__r.id,Pricing_Model__c, 
            BigMachines__Opportunity__r.Quote_Category__c, Quote_Opportunity_Type__c,CreatedDate, Primary_Solution__c 
            FROM BigMachines__Quote__c where id = :quoteId ] ;
        System.debug('quoteObj : '+quoteObj);
        PageReference pg = null;
        System.debug('quoteObj.BigMachines__Opportunity__r.Quote_Category__c != quoteObj.Quote_Business_Type__c : '
                     +quoteObj.BigMachines__Opportunity__r.Quote_Category__c != quoteObj.Quote_Business_Type__c);
        if(quoteObj.BigMachines__Opportunity__r.Quote_Category__c != quoteObj.Quote_Business_Type__c){  
            opportunity opp = new opportunity(id=quoteObj.BigMachines__Opportunity__r.id);
            opp.Quote_Category__c = quoteObj.Quote_Business_Type__c;
            try{
                update opp;
            }
            catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                System.debug('Message :'+ApexPages.getMessages());
                return null;
            }
        }
        System.debug('quoteObj.Quote_Business_Type__c == Cloud : '+ quoteObj.Quote_Business_Type__c == 'Cloud');
        System.debug('quoteObj.Offering_Type__c : '+quoteObj.Offering_Type__c);
        System.debug('quoteObj.Quote_Business_Type__c : '+quoteObj.Quote_Business_Type__c);
        if(quoteObj.Quote_Business_Type__c == 'Cloud') 
        {
            if(quoteObj.Offering_Type__c == 'Business Edition') 
                pg = new PageReference('/apex/ServiceOrderQuoteToolBE?id='+quoteId);            
            else if(quoteObj.Offering_Type__c == 'Premier Edition' && quoteObj.CreatedDate >= Date.newInstance(2016,10,13)) 
                pg = new PageReference('/apex/ServiceOrderQuoteToolPE?id='+quoteId);            
            else if(quoteObj.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CAAS)
                pg = new PageReference('/apex/CreateQuoteCloud?id='+quoteId);
            else if(quoteObj.Offering_Type__c == 'Cloud Partner (PPU)')
                pg = new PageReference('/apex/CreateQuotePPU?id='+quoteId);
            else
                pg = new PageReference('/apex/ServiceOrderQuoteTool?id='+quoteId);
        }
        //Naresh Kumar	03/21 Updating the redirection according to the new quoting tool changes
        //Quote_Business_Type__c = Platform Type
        //Offering_Type__c = Offering Type
        else if (quoteObj.Quote_Business_Type__c == 'On Premise' && quoteObj.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC) {
            pg = new PageReference('/apex/CreateQuoteCIC?id='+quoteId);
        }
        else if (quoteObj.Quote_Business_Type__c == 'Cloud' 
                 && (quoteObj.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CAAS || quoteObj.Offering_Type__c == 'PureCloud')) {
            pg = new PageReference('/apex/CreateQuoteCloud?id='+quoteId);
        }        
        else if(quoteObj.Quote_Business_Type__c == 'On Premise') {
            pg = new PageReference('/apex/CreateQuoteOnPremise1?id='+quoteId);
        }
        System.debug('-------pg'+pg);
        pg.setRedirect(true);
        return pg;
    }

}