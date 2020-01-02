public class SMARTServicesContentController {
    public String partnerType='';
    public String partnerRegion='';
    public Id accId;
    public Boolean designatedPartner=false;
    public Boolean isBusinessApproved = false;
    public Boolean isSEOBetaProgram = false;
    public Boolean isGPSApproved = false;
    public List<ContentDocWrapper> pricingGuideList = new List<ContentDocWrapper>();
    public List<ContentDocWrapper> businessApprovedList = new List<ContentDocWrapper>();
    public List<ContentDocWrapper> seoBetaProgramList = new List<ContentDocWrapper>();
    public List<ContentDocWrapper> GenPSList = new List<ContentDocWrapper>();
    public Map<String,List<ContentDocWrapper>> contentResults;
    //Variables for sorting the columns of the table        
    public static String sortExpression {get; set;}
    public static String sortDirection {get; set;}
    public static String sortExp {get; set;}
    public static String sortDir {get; set;}
    public Boolean hasContent {get; set;}
    
    
    public SMARTServicesContentController() {
        hasContent = false;
        contentResults = new Map<String,List<ContentDocWrapper>>();
        performInitialSearch();    
    }
    
    //First method called on click of command link
    public void sortByField(){
        String tmpCol = ApexPages.currentPage().getParameters().get('srtColumn');
        String tmpDir = ApexPages.currentPage().getParameters().get('srtDir');
        sortExpression = (tmpCol != NULL)? tmpCol:'Title';
        sortDirection = (tmpDir != NULL)? tmpDir:'ASC';
        sortExp = sortExpression;
        sortDir = sortDirection;   
        for(String key : contentResults.keySet()){ 
            contentResults.get(key).sort(); //This will call the compareTo method in the wrapper class for comparison
        }
        System.debug('hasContent--->'+hasContent);
    }
    
    
    //Wrapper class uses the comparable interface for sorting
    public class ContentDocWrapper implements comparable{
        public String versionId { get; set; }
        public String title { get; set; }
        public String description { get; set; } 
        public String size { get; set; }
        public String author { get; set; }
        public String lastmodified { get; set; }
        public String docid { get; set; }
        public String url { get; set; }
        
        
        public ContentDocWrapper(ContentVersion cv) {
            versionId = cv.Id;
            title = cv.Title;
            description = cv.Description;
            docid = cv.ContentDocumentId; 
            size = cv.ContentSize == 0 ? '' : 
            cv.ContentSize>1073741824 ? Decimal.valueOf(''+cv.ContentSize).divide(1073741824.0,2).toPlainString()+'GB' :
            cv.ContentSize>1048576 ? Decimal.valueOf(''+cv.ContentSize).divide(1048576.0,2).toPlainString()+'MB' :
            cv.ContentSize>1024 ? Decimal.valueOf(''+cv.ContentSize).divide(1024.0,2).toPlainString()+'KB' :
            cv.ContentSize + ' bytes';
            author = cv.Legacy_Author__c==null || cv.Legacy_Author__c=='' ? cv.CreatedBy.Name : cv.Legacy_Author__c;
            lastmodified = cv.LastModifiedDate.format();
            url = Site.getBaseUrl() + docid;
        }
        
        //Actual sorting method that sorts by different columns
        public Integer compareTo(Object phw){    
            ContentDocWrapper ph = (ContentDocWrapper)phw;            
            try{
                if(sortExpression == 'Title'){                
                    String oldVal = (ph.Title== NULL)? null:ph.Title;                    
                    String newVal = (title == NULL)? title:title;
                    return (oldVal < newVal && sortDirection.toLowerCase().equals('desc')) ? 1:((oldVal > newVal && sortDirection.toLowerCase().equals('asc'))? 1:-1);
                        }
                
                else if(sortExpression == 'Author'){                
                    String oldVal = (ph.Author== NULL)? null:ph.Author;
                    String newVal = (Author == NULL)? Author:Author;
                    return (oldVal < newVal && sortDirection.toLowerCase().equals('desc')) ? 1:((oldVal > newVal && sortDirection.toLowerCase().equals('asc'))? 1:-1);
                        }
                else if(sortExpression == 'Last Modified'){                
                    String oldVal = (ph.lastmodified == NULL)? null:ph.lastmodified;
                    String newVal = (lastmodified == NULL)? lastmodified:lastmodified;
                    return (oldVal < newVal && sortDirection.toLowerCase().equals('desc')) ? 1:((oldVal > newVal && sortDirection.toLowerCase().equals('asc'))? 1:-1);
                        }
                
            }
            catch(Exception e){
            }                          
            return 1;
        }      
    }
    
    public Map<String,List<ContentDocWrapper>> getContentResults() {
        return contentResults;
    }
    
    public void performInitialSearch() {
        System.debug('performInitialSearch--->');
        List<String> contentTypes = new List<String>();
        String contentfields = 'Id,ContentDocumentId,Description,Title,ContentSize,'
            +'Legacy_Author__c,CreatedBy.Name,LastModifiedDate,Content_Type__c,Services_Programs__c,Region__c, Solution__c';
        
        String runAs = ApexPages.currentPage().getParameters().get('runAs');
        if(runAs == null)
            runAs = Userinfo.getUserId();
        User currentUser = [SELECT AccountId,Contact.Account.TM_Acc_Country_Region__c,Contact.Account.Partner_Tier__c,ContactId,
                            Contact.Designated_Partner_Contact__c, Contact.Account.PartnerType__c,Contact.Account.Country__r.Region__c,
                            Contact.Business_Consulting_Approved__c,Contact.SEO_Beta_Program__c,Contact.G_PS_Approved__c  
                            FROM User WHERE Id =: runAs];
        accId = currentUser.AccountId;
        partnerType = currentUser.Contact.Account.PartnerType__c!=null?currentUser.Contact.Account.PartnerType__c:'';
        partnerRegion = currentUser.Contact.Account.Country__r.Region__c !=null?currentUser.Contact.Account.Country__r.Region__c :'';
        
        //if(partnerRegion !='') {
        designatedPartner = currentUser.Contact.Designated_Partner_Contact__c;
        String internalUsage = 'Partners';
        isBusinessApproved = currentUser.Contact.Business_Consulting_Approved__c;
        isSEOBetaProgram = currentUser.Contact.SEO_Beta_Program__c;
        isGPSApproved = currentUser.Contact.G_PS_Approved__c; 
        contentTypes.add('SMART Services Content');
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        contentVersionList = Database.query('SELECT ' + contentfields 
                                            + ' FROM ContentVersion where '
                                            +' ( (Account__c = null AND Region__c includes (\'Global\')) OR ' 
                                            + ' (Account__c =: accId AND Region__c includes (\'' + partnerRegion +'\')) OR ' 
                                            + ' (Account__c = null AND Region__c includes (\'' + partnerRegion + '\'))) AND ' 
                                            + ' Content_Type__c in: contentTypes AND Internal_and_Partner_Usage__c includes (\'' +internalUsage +'\')' 
                                            + ' and IsLatest=true order by lastmodifieddate desc');
        
        setupData(contentVersionList);
        if(contentResults.size() > 0) {
            hasContent = true; 
        }
        // }
    }
    
    public void setupData(List<ContentVersion> docs) {
        Set<String> cvContentTypes = new Set<String>();
        for (ContentVersion cv : docs) { 
            if (contentResults.containsKey(cv.Solution__c)) {
                contentResults.get(cv.Solution__c).add(new ContentDocWrapper(cv));
            } else {
                contentResults.put(cv.Solution__c, new List<ContentDocWrapper>{new ContentDocWrapper(cv)});
            }    
        }
        return;
    }
}