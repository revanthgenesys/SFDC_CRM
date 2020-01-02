public without sharing class IntegrationSolutionDetailCtrlrExtension {
   
    private Integration_Solution__c m_solution;
    
    public List<Integration_Solution_Resource__c> demoVideos { get; set; }
    public List<Integration_Solution_Resource__c> whitePapers{ get; set; }
    public List<Integration_Solution_Resource__c> caseStudies{ get; set; }
    public List<Integration_Solution_Resource__c> productBrochures{ get; set; }
    public List<Integration_Solution_Resource__c> allianceFactSheets{ get; set; }
    public List<Integration_Solution_Resource__c> presentations{ get; set; }
    
    public List<ReferenceCustomer> currentReferenceCustomers { get; set; }
    
    public List<SkilledContact> skilledContacts { get; set; }
            
    public Boolean hasDemoVideos {get;set;}
    public Boolean hasWhitePapers{get;set;}
    public Boolean hasCaseStudies{get;set;}
    public Boolean hasProductBrochures {get;set;}
    public Boolean hasAllianceFactSheets {get;set;}
    public Boolean hasPresentations {get;set;}
     
    public String errorMessage {get;set;}
            
    public String objectToRedirectTo {get;set;}
    
    //chatter question
    public String question{get;set;}
    public String questionType{get;set;}
    public String questionResult{get;set;}
    
    public String allianceBusinessChatterGroupId{get;private set;}
    public String allianceTechnicalChatterGroupId{get;private set;}
    
    public IntegrationSolutionDetailCtrlrExtension(){
        
    }
        
    public IntegrationSolutionDetailCtrlrExtension(ApexPages.StandardController stdController) {
        SetSolution((Integration_Solution__c)stdController.getRecord());
    }
    
    public void SetSolution(Integration_Solution__c solution) {
        allianceBusinessChatterGroupId ='';
        allianceTechnicalChatterGroupId='';
        
        this.m_solution = solution;
        Initialize();
    }
   
    private void Initialize(){
    
        for(Integration_Solution_Chatter_Groups__c chatterGroup : [Select Chatter_Group__c, Name FROM Integration_Solution_Chatter_Groups__c]){
            if(chatterGroup.Name == 'Business'){
                allianceBusinessChatterGroupId = chatterGroup.Chatter_Group__c;
            }else if (chatterGroup.Name == this.m_solution.Integration_Type__c){
                allianceTechnicalChatterGroupId = chatterGroup.Chatter_Group__c;
            }
        }
        
        demoVideos = new List<Integration_Solution_Resource__c>();
        whitePapers = new List<Integration_Solution_Resource__c>();
        caseStudies = new List<Integration_Solution_Resource__c>();
        productBrochures = new List<Integration_Solution_Resource__c>();
        allianceFactSheets = new List<Integration_Solution_Resource__c>();
        presentations = new List<Integration_Solution_Resource__c>();
        
        List<Integration_Solution_Resource__c> allResources  = [SELECT Name__c, Url__c, Link_Type__c
                                                                FROM Integration_Solution_Resource__c           
                                                                WHERE Integration_Solution__c = :m_solution.Id
                                                                ORDER BY Name__c];
        
        for (Integration_Solution_Resource__c resource : allResources) { 
            if(resource.Link_Type__c == 'White Paper'){
                whitePapers.add(resource);
            }
            else if(resource.Link_Type__c == 'Case Study'){
                caseStudies.add(resource);
            }
            else if(resource.Link_Type__c == 'Video'){
                demoVideos.add(resource);
            }
            else if(resource.Link_Type__c == 'Product Brochure'){
                productBrochures.add(resource);
            }
            else if(resource.Link_Type__c == 'Alliance Fact Sheet'){
                allianceFactSheets.add(resource);
            }
            else if(resource.Link_Type__c == 'Presentation'){
                presentations.add(resource);
            }
                
        }
               
        List<Integration_Solution_Ref_Cust_Junction__c> referenceCustomers = [SELECT account__r.Name, Is_In_Production__c, Is_Referenceable__c, Reference_Details__c, Last_Contacted_Regarding_Solution__c 
                                                                                FROM Integration_Solution_Ref_Cust_Junction__c 
                                                                                WHERE Integration_Solution__c = :m_solution.Id  ORDER By account__r.Name];
      
        currentReferenceCustomers = new List<ReferenceCustomer>();
        for(Integration_Solution_Ref_Cust_Junction__c customer: referenceCustomers){
            ReferenceCustomer referenceCustomer = new ReferenceCustomer(customer);
            currentReferenceCustomers.add(referenceCustomer);
        }
               
        List<Integration_Solution_Contact_Junction__c> contactJunctions = [SELECT User__c, contact_type__c, user__r.name, user__r.department__c, user__r.email, user__r.Phone 
                                                                            FROM Integration_Solution_Contact_Junction__c
                                                                            WHERE Integration_Solution__c = :m_solution.Id ORDER BY user__r.name];
        
        skilledContacts = new List<SkilledContact>();
        
        for(Integration_Solution_Contact_Junction__c contact: contactJunctions){
            SkilledContact skilledContact = new SkilledContact(contact);
            skilledContacts.add(skilledContact);
        }
        
        hasDemoVideos = demoVideos.size() > 0;
        hasWhitePapers = whitePapers.size() > 0;
        hasCaseStudies = caseStudies.size() > 0;
        hasProductBrochures = productBrochures.size() > 0;
        hasAllianceFactSheets = allianceFactSheets.size() > 0;
        hasPresentations = presentations.size() > 0;
      
    }
        
    public PageReference redirectToObject(){
        PageReference newPage = new PageReference('/' + objectToRedirectTo);
        return newPage;
    }
    
    public class SkilledContact {
        public String Name { get; set; }
        public String Id { get; set; }
        public String Phone { get; set; }
        public String Department { get; set; }
        public String Email { get; set; }
         public String Skills { get; set; }

        public SkilledContact(Integration_Solution_Contact_Junction__c skilledContact) {
            Id = skilledContact.user__c;
            Name = skilledContact.user__r.Name;
            Phone = skilledContact.user__r.Phone;
            Department = skilledContact.user__r.Department__c;
            Email = skilledContact.user__r.Email;
            Skills = skilledContact.contact_type__c;
        }
    }
    
    public class ReferenceCustomer {
        public String Name { get; set; }
        public String Id { get; set; }
        public Boolean IsInProduction { get; set; }
        public Boolean IsReferencable { get; set; }
        public Date LastContactedRegardingSolution { get; set; }
        public String ReferenceDetails { get; set; }
        
        public ReferenceCustomer(Integration_Solution_Ref_Cust_Junction__c customer) {
            Name = customer.Account__r.Name;
            Id = customer.Account__c;
            IsInProduction = customer.Is_In_Production__c;
            IsReferencable = customer.Is_Referenceable__c;
            LastContactedRegardingSolution = customer.Last_Contacted_Regarding_Solution__c;
            ReferenceDetails = customer.Reference_Details__c;
        }
    }
   
    public ConnectApi.FeedItemInput GetFeedInput(){
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        ConnectApi.HashtagSegmentInput hashtagSegment = new ConnectApi.HashtagSegmentInput();
        hashtagSegment.tag = m_solution.Name.replaceAll(' ', '');
        messageInput.messageSegments.add(hashtagSegment);
        
        ConnectApi.TextSegmentInput questionSegment = new ConnectApi.TextSegmentInput();
        questionSegment.text = ' question: ' + question + ' ';
        messageInput.messageSegments.add(questionSegment);

        List<User> contacts = [SELECT Id, Department__c
                               FROM User             
                               WHERE (Id IN (SELECT User__c 
                                               FROM Integration_Solution_Contact_Junction__c 
                                               WHERE Integration_Solution__c = :m_solution.Id AND Contact_type__c includes (:questionType)))];
    
        for(User contact : contacts){
            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            mentionSegment.id = contact.Id;
            messageInput.messageSegments.add(mentionSegment);               
                               
            ConnectApi.TextSegmentInput separator = new ConnectApi.TextSegmentInput();
            separator.text = ' ';
            messageInput.messageSegments.add(separator);
                                        
        }
        
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = messageInput;
        
        return input;
    }
        
    public PageReference postQuestion (){
       
        String chatterGroup = '';
        
        if(questionType == 'Business'){
            chatterGroup = allianceBusinessChatterGroupId;
        }else{
            chatterGroup = allianceTechnicalChatterGroupId;
        }
        
        
        if(question.length() > 0 && chatterGroup!= '')
        {
            ConnectApi.FeedItemInput messageInput = GetFeedInput();  
                       
            ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, chatterGroup, messageInput, null);
            questionResult = 'Question Posted';            
        }else if (question.length() > 0 && chatterGroup== ''){
            questionResult = 'Chatter group not defined for this integration type.  Please contact the integration owner';
            return NULL;
        }
        else{
            questionResult = '';
        }
                
        question = '';
       
        return NULL;
    }
}