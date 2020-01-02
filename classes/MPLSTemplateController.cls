public class MPLSTemplateController{
    Id m_mplsQuoteId;
    public string apiSessionId { get; set;} 
    public string apiSessionURL { get; set;} 
    public string redirectUrl {get;set;}
    
    public MPLSTemplateController()
    {
         if(ApexPages.currentPage().getParameters().get('MPLS_Quote_Id') != null)
        {
            m_mplsQuoteId = ApexPages.currentPage().getParameters().get('MPLS_Quote_Id');        
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Solution Design Id was supplied'));
        } 
        
        if(ApexPages.currentPage().getParameters().get('ServerURL') != null)
        {
            apiSessionURL = ApexPages.currentPage().getParameters().get('ServerURL');        
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not obtain the Server URL.  Cannot generate the document without it.'));
        }
        
        if(ApexPages.currentPage().getParameters().get('SessionId') != null)
        {
            apiSessionId = ApexPages.currentPage().getParameters().get('SessionId');        
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not obtain the Session Id.  Cannot generate the document without it.'));
        }
    }
    
    
    public string CreateMPLS() {
        MPLS_RVA_Quote_Request__c request = [SELECT Id,Name From MPLS_RVA_Quote_Request__c WHERE Id=: m_mplsQuoteId];               
        string baseurl = 'https://composer.congamerge.com?SessionId=' +apiSessionId +'&ServerUrl='+apiSessionURL+'&Id='+request.Id;              
        Profile p = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()];
        string queryString = '&DS7=' + (p.Name == 'System Administrator'?'0':'1');       

        /* Commented as Conga is not installed - Jitendra

        //It's always an MPLS template
        string recordType = 'MPLS/RVA/DC Quote';
        List<APXTConga4__Conga_Template__c> templates = new List<APXTConga4__Conga_Template__c>();
        templates = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE RecordType.Name =: recordType];
        if(templates.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'The MPLS Quote Type does not currently have a template associated with it'));
            return '';
        }
        queryString = queryString +'&TemplateID=' +templates.get(0).Id;

        List<string> reportIds = getReportIds(recordType);
        string recordId = request.Id;
        string finalId = recordId.substring(0,15);
       
        for(string reportId : reportIds)
        {            
           queryString = queryString + '&ReportID=' + reportId + finalId;
        }
        queryString = queryString + '&OFN=Quote+Request+-+'+EncodingUtil.urlEncode(request.Name, 'UTF-8')+'+-+'+System.Now().format('yyyy-MM-dd')+'';
        redirectUrl = baseurl + queryString;
        System.debug('RedirectUrl:' + redirectUrl);     
        return redirectUrl;
        */
        
        return 'temp';
    }
    
    /*Commented as Conga is not installed - Jitendra
    private List<string> getReportIds(string recordType)
    {
        //Temporary function until we decide how we want to manage report ids
        List<string> reportIds = new List<string>();
        for (Conga_Template_Reports__c customSetting : [SELECT Alias__c,Report_Id__c FROM Conga_Template_Reports__c WHERE Record_Type__c =:recordType ORDER BY Order__c])
        {
            reportIds.add('['+ customSetting.Alias__c +']'+customSetting.Report_Id__c + '?pv0=');            
        }
        
        return reportIds;
    }
    */
}