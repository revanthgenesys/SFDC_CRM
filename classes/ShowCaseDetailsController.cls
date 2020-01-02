public class ShowCaseDetailsController
{
    public List<KPI1_Case_Details__c> list_KPIDetls {get;set;}
    public Partner_Quarterly_KPI__c objPartnerKPI {get;set;}
    public string quarterStr {get;set;}
    
    public ShowCaseDetailsController()
    {
        String strKPIId = ApexPages.currentPage().getParameters().get('kpiid');
        String quarterStr = ApexPages.currentPage().getParameters().get('quarter');
        string psrc = 'notkpidash';
        psrc = ApexPages.currentPage().getParameters().get('psrc');
        objPartnerKPI = new Partner_Quarterly_KPI__c();
        list_KPIDetls = new List<KPI1_Case_Details__c>();
        
        if(strKPIId != NULL){
             objPartnerKPI = [SELECT Year__c,Account__c,Account_Name__c, Period__c, 
                                                               Quality_Assessment__c,Closure_Assessment__c,
                                                               Cases_Closed_by_Default__c,
                                                               Training_Assessment__c,Total_KPI_Score__c,
                                                               Period_From__c,Period_To__c, Platform__c
                                      FROM Partner_Quarterly_KPI__c WHERE Id = :strKPIId];
           
            if(psrc=='kpidash'){
                list_KPIDetls = [SELECT id,Case_Number__c,Contact_Name__c,Product__c,
                                Problem_Description_Clear_and_Detailed__c,
                                Supporting_Info_Provided__c,Should_Have_Been_Solved_Using_Docs_KB__c,
                                Case_Logged_by_GU_Certified_Contact__c, Sub_Status_Group__c, Platform__c
                                FROM KPI1_Case_Details__c
                                WHERE 
                                Period__c = :objPartnerKPI.Period__c AND
                                Account__c = :objPartnerKPI.Account__c
                                //AND Platform__c = :objPartnerKPI.Platform__c
                                ORDER BY Case_Number__c];
            }
            else{
                list_KPIDetls = [SELECT id,Case_Number__c,Contact_Name__c,Product__c,
                                Problem_Description_Clear_and_Detailed__c,
                                Supporting_Info_Provided__c,Should_Have_Been_Solved_Using_Docs_KB__c,
                                Case_Logged_by_GU_Certified_Contact__c, Sub_Status_Group__c, Platform__c
                                FROM KPI1_Case_Details__c
                                WHERE 
                                Period__c = :objPartnerKPI.Period__c AND
                                Account__c = :objPartnerKPI.Account__c AND 
                                Platform__c = :objPartnerKPI.Platform__c
                                ORDER BY Case_Number__c];
            }
        }
    }
}