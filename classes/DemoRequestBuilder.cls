public class DemoRequestBuilder {
    
    public Demo_Request__c demo;
    
    public final List<String> demoLocations { get; private set; } 
    { demoLocations = new List<String>{'Web Based','On-site (Requires Approval)'}; } //'HQ Simulation Room','ININ HQ Campus'
    public final Map<String, List<String>> requestTypes { get; private set; } 
    { requestTypes = new Map<String, List<String>>{'Prospect' => new List<String>{'New Revenue', 'Other'},
        'Customer'=> new List<String>{'Additional Revenue', 'Training', 'Other'},
        'Partner' => new List<String>{'Training', 'Other'},
        'Analyst' => new List<String>{'Other'},
        'Consultant' => new List<String>{'Other'},
        'Internal' => new List<String>{'Internal', 'Training'}}; }
    public final List<String> verticals { get; private set; } 
    { verticals = new List<String>{'Not Applicable','ARM (Collections)','Education','Financial','Government',
        'Health Care','Insurance','Manufacturing',
        'Outsourcer','Retail','Technology','Telecom/Cable','Transportation','Travel & Hospitality','Utilities'}; 
    }
    public final List<String> queues { get; private set; }
   // { queues = new List<String>{'Technical Sales', 'Velocity Sales'}; }
    { queues = new List<String>{'Technical Sales'}; }
    public Set<String> timezones { get { return DemoRequestUtility.timezones; } }

    private String defaultInternalAccountName { get; set; } { defaultInternalAccountName='Genesys';}
    public Id acct { get; set; }
    private Id opp { get; set; }
    private string oppStage { get; private set; }
    private Id lead { get; set; }
    
    //Requester Info
    public String RequesterCompanyName { get; set; }
    public String RequesterEmail { get; set; }
    public String RequesterName { get; set; }
    public String RequesterPhone { get; set; }
    public String requestType { get; set; }
    public String audienceType { get; set; }
    public String queue { get; set; }
    
    //Demo Info
    public DateTime demoDateTime { get; set; }
    public String demoTimezone { get; set; }
    public Decimal demoDuration { get; set; }
    public String demoLocation { get; set; }
    
    //OnSite Info
    public String onsiteDemoLocation { get; set; }
    public String onsiteJustify { get; set; }
    public String onsiteMeetingRoom { get; set; }
    
    //Business Info
    public String companyName { get; set; }
    public String BusinessNeeds { get; set; }
    public String HotButtons { get; set; }
    public String Attendees { get; set; }
    public String Business { get; set; }
    public String Website { get; set; }
    public String Vertical { get; set; }
    public String submittedTimezone { get; set; } { submittedTimezone = 'GMT'; }
    
    public String otherProducts { get; set; }
    public Boolean suppressNotifications { get; set; } { suppressNotifications = false; }
    public Set<Id> selectedCompetitors { get; set; }
    public Boolean allTscDeclined { get; set; } {allTscDeclined = false;}
    public Boolean allTsDeclined { get; set; } {allTsDeclined = false;}
    
    //Multi-day Event Fields
    public Integer maxAttendees { get; set; }
    
    public DemoRequestBuilder() {
        demo = new Demo_Request__c();
        constructSets();
    }
    
    public DemoRequestBuilder(Demo_Request__c req) {
        demo = req;
        otherProducts = req.Other_Applications__c;
        constructSets();
    }
    
    private void constructSets() {
        selectedCompetitors = new Set<Id>();
    }
    
    public DemoRequestBuilder withOpportunity(Id i) {
        opp = i;
        Opportunity o = [Select Name, AccountId, StageName from Opportunity where Id = :i];
        oppStage = o.StageName;
        acct = o.AccountId;
        if(acct != null){
            Account a = [Select Name, Id from Account where Id =:o.AccountId];
            companyName = a.Name;
        }
        List<Opportunity_Competitor__c> comps = [Select Id, Competitor__c from Opportunity_Competitor__c where Opportunity__c = :i];
        if(comps.size() > 0) {
            for(Opportunity_Competitor__c c : comps){ 
                selectedCompetitors.add(c.Competitor__c);
            }
        }
        return this;
    }
    
    public DemoRequestBuilder withAccount(Id i) {
        acct = i;
        Account a = [Select Name, Website from Account where Id = :i];
        Website = a.Website;
        companyName = a.Name;
        return this;
    }
    
    public DemoRequestBuilder withInternalAccount() {
        Account a = [Select Name, Website, Id from Account where Name = :defaultInternalAccountName limit 1];
        acct = a.Id;
        Website = a.Website;
        companyName = a.Name;
        return this;
    }
    
    public DemoRequestBuilder withLead(Id i) {
        lead = i;
        Lead l = [Select Name, Company from Lead where Id = :i];
        companyName = l.Company;
        return this;
    }
    
    public DemoRequestBuilder withRequester(Id i) {
        User u = [Select Name, Phone, Email, CompanyName, TimeZoneSidKey from User where Id = :i];
        RequesterCompanyName = u.CompanyName;
        RequesterEmail = u.Email;
        RequesterName = u.Name;
        RequesterPhone = u.Phone;
        submittedTimezone = u.TimeZoneSidKey;
        return this;
    }

    public Demo_Request__c build() {
        demo = new Demo_Request__c();
        
        if(opp != null) {
            demo.Opportunity__c = opp;
            demo.OpportunityStageAtCreation__c = oppStage;
        }
        if(acct != null) demo.Account__c = acct;
        if(lead != null) demo.Lead__c = lead;
        if(opp == null && acct == null && lead == null) demo.CompanyName__c = companyName;
        
        demo.Requester_Email_Addr__c = RequesterEmail;
        demo.Requester_Company__c = RequesterCompanyName;
        demo.Requester_Name__c = RequesterName;
        demo.Requester_Phone__c = RequesterPhone;
        
        demo.AudienceType__c = audienceType;
        demo.Request_Type__c = requestType;
        
        demo.Demo_Date_Time__c = demoDateTime;
        demo.Demo_Time_Length__c = demoDuration;
        demo.Demo_Location__c = demoLocation;
        demo.Requested_Timezone__c = demoTimezone;
        demo.SubmittedUsersTimezone__c = submittedTimezone;
        if(otherProducts != null)
        {
            demo.Other_Applications__c = (otherProducts.length() > 255 ? otherProducts.left(255) : otherProducts);
        }

        if(demoLocation == 'On-site (Requires Approval)') {
            demo.OnSite_Justification__c = onsiteJustify;
            demo.On_site_Location__c = onsiteDemoLocation;
        } else if(demoLocation == 'ININ HQ Campus') {
            demo.HQ_Meeting_Room__c = onsiteMeetingRoom;
        }
    
        demo.Prospect_Business__c = Business;
        demo.Prospect_Needs__c = BusinessNeeds;
        demo.Hot_Buttons_Pain_Points__c = HotButtons;
        demo.Prospects_Website__c = Website;
        demo.Name_Title_Attendees__c = Attendees;
        demo.Vertical__c = Vertical;
        demo.Org_URL__c = DemoRequestUtility.orgUrl;
        demo.SuppressNotification__c = suppressNotifications;
        demo.MaxAttendees__c = maxAttendees;
        demo.QueueName__c = queue;
        Boolean needsApproval = DemoRequestClass.checkIfShouldRunApproval(demo);
        if(needsApproval) {
            demo.State__c = 'Pending Approval';
        } else if(DemoRequestUtility.EscalateForRequestedTime(demoDateTime)) {
            demo.State__c = 'Escalated';
            demo.Escalate_Request_Time__c = true;
            demo.Escalation_Reason__c = 'Submitted With Short Notice';
        } else if(allTscDeclined && !allTsDeclined){
            demo.State__c = 'Escalated';
            demo.Escalation_Reason__c = 'Submitted Despite Warning(s)';
        } else if(allTsDeclined){
            demo.State__c = 'Declined';
            demo.SuppressNotification__c = true;
        } else {
            demo.State__c = 'Submitted';
        }

        insert demo;
        system.debug('inserted demo: ' + demo.Id);
        buildCompetitors(demo.Id);
        DemoRequestClass.AutoDeclineRequest(demo);
        DemoRequestClass.CheckTestBeforePost(new List<Demo_Request__c>{demo}, DemoRequestUtility.chatterPostType.get(0));
        if(needsApproval) {
            DemoRequestClass.createApprovalProcess(demo);
        }
        if(allTscDeclined && !allTsDeclined) DemoRequestEmails.SendEscalationEmail(new List<Demo_Request__c>{demo});
        if(allTsDeclined) DemoRequestEmails.SendDeclineEmail(demo);
        if(DemoRequestUtility.isDuringMaintenance(demoDateTime, demoDuration)) DemoRequestEmails.SendMaintenanceEmail(new List<Demo_Request__c>{demo});
        
        return demo;
    }
    
    public void buildCompetitors(Id i) {
        if(selectedCompetitors.isEmpty()) return;
        List<Demo_Request_Competitor_Junction__c> junc = new List<Demo_Request_Competitor_Junction__c>();
        for(Id ic : selectedCompetitors) {
            Demo_Request_Competitor_Junction__c comp = new Demo_Request_Competitor_Junction__c();
            comp.Demo_Request__c = i;
            comp.Competition__c = ic;
            junc.add(comp);
        }
        insert junc;
    }
    
    public List<Competition__c> getCompetitors() {
        return [Select Name, Id from Competition__c where Id not in :selectedCompetitors order by Name];
    }
    
    public List<Competition__c> getSelectedCompetitors() {
        return [Select Name, Id from Competition__c where Id in :selectedCompetitors order by Name];
    }
    
}