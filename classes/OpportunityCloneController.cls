public with sharing class OpportunityCloneController {
    Opportunity tempId = null;  
    
    public OpportunityCloneController(ApexPages.StandardController stdController) {
        tempId = (Opportunity)stdController.getRecord();
    }
     
    public PageReference submit() {
        String query = CloneUtil.getCreatableFieldsSOQL('Opportunity','id=\''+tempId.id +'\'');
        Opportunity parentOpp = (Opportunity)Database.query(query);
        Opportunity  childOpp = parentOpp.clone(false, true);
        populateDefaultValues(childOpp);                
        insert childOpp;
        return new PageReference('/'+childOpp.Id + '/e?retURL=/' + childOpp.Id );
    }
    
    private void populateDefaultValues(Opportunity childOpp){
        childOpp.Name = 'Clone - ' + childOpp.Name; 
        childOpp.Service_Contract_Siebel_ID__c = childOpp.id;
        childOpp.Opportunity_Status__c = 'Hypothetical';
        childOpp.Forecast_Status__c= 'Hypothetical';
        childOpp.Quote_Quote_Status__c = null;
        childOpp.Send_To_Customer__c = false;
        childOpp.Sent_To_Customer__c = false;
        childOpp.Quote_Genesys_Care__c = null;
        childOpp.Decline_Maintenance__c = false;
        childOpp.Number_of_associated_Quotes__c = 0;
        childOpp.Primary_Quote__c = null;
        //childOpp.CloseDate = null;
        childOpp.Quote_USD_Equivalent__c = null;
        childOpp.Upgrade_to_Premium_Care__c = false;
        childOpp.Invoice__c = null;
        childOpp.Forecast_Status__c = null;
        childOpp.ForecastStatus__c = null;
        childOpp.Probability = null;
        childOpp.ALUProbability__c = null;
        childOpp.PO_Date__c = null;
        childOpp.PO_Number__c = null;
        childOpp.Payment_Amount__c = null;
        childOpp.Land__c = false;
        childOpp.Bill_To_Name__c = null;
        //Naresh Kumar 03/06/2017   iTrack-37519, StageName should reset to '1.Understand Needs' when cloning an opportunity.
        childOpp.StageName = '1.Understand Needs';
        childOpp.Win_Loss_Status__c ='';
        childOpp.Type = null;
        if(childOpp.Lines_of_Businesses__c == 'Premise;Cloud' ||   childOpp.Lines_of_Businesses__c == 'Cloud;Premise')
           childOpp.Lines_of_Businesses__c ='Premise';
           
        childOpp.Quote_Category__c = '';
        childOpp.ForecastStatus__c ='5.Pipeline';
        childOpp.ForecastCategoryName = '';
        childOpp.Stage_before_Closed__c= '';
        childOpp.License_Amount__c = 0;
        childOpp.Hardware_Total__c = 0;
        //childOpp.Professional_Service_Amount_RDP__c= 0;
        //childOpp.Genesys_Care_Amount__c= 0;
        childOpp.Annual_Contract_Value_new__c= 0;
        childOpp.ACV_Subscription_Only__c= 0;
        childOpp.Total_Annual_Contract_Value__c= 0;
        childOpp.Total_PS_Support__c= 0;
        childOpp.Monthly_Commitment__c= 0;
        childOpp.Estimated_Usage_Agreements_EUA__c = 0;
        childOpp.Amount=0;
        childOpp.WonLostCancelledReason__c ='';
        childOpp.Competitor__c='';
        childOpp.Who_did_Genesys_Replace__c='';
        childOpp.WonLostCancelledComments__c='';
        childOpp.Factors_Influencing_Price__c='';
        childOpp.SE_and_Other_Contributors__c='';
        childOpp.Was_SIP_Server_part_of_the_Solution__c   ='';
        childOpp.Did_it_replace_a_PBX__c='';
        childOpp.what_PBX_did_it_replace__c='';
        childOpp.Who_won_this_Opportunity__c='';
        childOpp.RFP_Proposal__c='';
        childOpp.What_is_the_missing_Product_Feature__c    ='';
        childOpp.Frequency_Term__c ='';
        childOpp.Term_Commitment__c ='';
        childOpp.SOW_Url__c ='';
        childOpp.MSA_Url__c ='';
        childOpp.Win_Email_Sent__c = false;
        //Added by Matt Dunham 3/7/2017
        childOpp.LeadDevelopmentRep__c = null;
        childOpp.Campaign_Source__c = null;
        childOpp.BudgetComments__c = '';
        childOpp.AuthorityComments__c = '';
        childOpp.Need_Comments__c = '';
        childOpp.TimeframeComments__c = '';
        
        //Oct 2 - Anju Starts -- clear win notification check
        childOpp.Cloud_Win_Email__c = false;
        //Oct 2 - Anju ends -- clear win notification check

		//Rony Joseph-July 29 2019 - Clear PureBridge Detials - Start
        childOpp.Lever__c = '';
        childOpp.Avaya_Contract_Expiration__c = null;
        //Rony Joseph-July 29 2019 - Clear PureBridge Detials - End															 
    }
}