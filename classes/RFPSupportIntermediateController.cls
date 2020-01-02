public with sharing class RFPSupportIntermediateController {

    public RFPSupportIntermediateController(ApexPages.StandardController controller) {

    }

    public Pagereference redirectSupportRequest()
    {
        If(ApexPages.currentPage().getParameters().containsKey('oppId') && (ApexPages.currentPage().getParameters().get('oppId')!=null || ApexPages.currentPage().getParameters().get('oppId')!=''))
        {
             List<RFP_Support_Request__c> rpfRequest = [SELECT id FROM RFP_Support_Request__c WHERE Opportunity__c =: ApexPages.currentPage().getParameters().get('oppId')];
             if(rpfRequest.size()>0)
              {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'This opportunity already have a RFP Support Request. You can\'t have more than one request on an Opportunity'));    
                 return null;
              }
              else
              {
                  Pagereference pg = new Pagereference('/apex/RFPSupportRequestEdit?oppId='+ApexPages.currentPage().getParameters().get('oppId'));
                  pg.setRedirect(true);
                  return pg;
              }
        
        }
         return null;
    }

}