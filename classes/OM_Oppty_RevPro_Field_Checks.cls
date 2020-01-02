Public class OM_Oppty_RevPro_Field_Checks
{
    public boolean areOpptyRevProFieldsMissing {get; set;}
    public String opptyRevProMissingDataDetails {get; set;}
    public String renderColour {get; set;}

    public OM_Oppty_RevPro_Field_Checks()
    {
    }
    
    public OM_Oppty_RevPro_Field_Checks(ApexPages.StandardController cont)
    {
        renderColour = 'green';
        Id OMApprovalID = (Id) cont.getRecord().get('id');
        list <Opportunity_Approval__c> oppApprs = [SELECT Id, Opportunity__c FROM Opportunity_Approval__c WHERE Id = :OMApprovalID];
        Id linkedOpptyID = oppApprs[0].Opportunity__c;
        System.Debug('NikM Debug:: Getting associated opportunity RevPro field check details for Oppty : ' + linkedOpptyID);

        list<Opportunity> opps = [SELECT Id, Name, RevPro_Missing_Data_Details__c, RevPro_Required_Data_Missing__c FROM Opportunity WHERE Id = :linkedOpptyID];
  
        for (Opportunity Opp : opps)
        {     
            System.Debug('NikM Debug:: Opportunity ' + Opp.Name + ' with ID ' + Opp.Id + ' being processed');
            areOpptyRevProFieldsMissing = Opp.RevPro_Required_Data_Missing__c;
            
            if (areOpptyRevProFieldsMissing)
            {
                renderColour = 'red';
                opptyRevProMissingDataDetails = Opp.RevPro_Missing_Data_Details__c;
            }
            else
            {
                renderColour = 'green';
                opptyRevProMissingDataDetails = 'All expected RevPro data is present on the PS Opportunity';                    
            }
        }
    }

}