public without sharing class PartnerPortalGSelectController {
    public String partnerType='';
    public String partnerRegion='';
    public Id accId;
    public Boolean designatedPartner=false;
    public Boolean isBusinessApproved = false;
    public Boolean isSEOBetaProgram = false;
    public Boolean isGPSApproved = false;
    
    public Boolean isSubscriptionQualified = false;
    
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
    
    
    public PartnerPortalGSelectController() {
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
                              +'Legacy_Author__c,CreatedBy.Name,LastModifiedDate,Content_Type__c,Services_Programs__c,Region__c';
        
        String runAs = ApexPages.currentPage().getParameters().get('runAs');
        if(runAs == null)
            runAs = Userinfo.getUserId();
        //User currentUser = [SELECT ContactId,email FROM User where id =: runAs];
        User currentUser = [SELECT AccountId,Contact.Account.TM_Acc_Country_Region__c,Contact.Account.Partner_Tier__c,ContactId,
                        Contact.Designated_Partner_Contact__c, Contact.Account.PartnerType__c,Contact.Account.Country__r.Region__c,
                        Contact.Business_Consulting_Approved__c,Contact.SEO_Beta_Program__c,Contact.G_PS_Approved__c,Contact.Account.Subscription_Qualified__c  
                        FROM User WHERE Id =: runAs];
        //Contact userContact = [Select AccountId,Designated_Partner_Contact__c,Business_Consulting_Approved__c, SEO_Beta_Program__c, G_PS_Approved__c from Contact where id =:currentUser.ContactId ];
        //Account userAcnt = [Select Name,SAP_Code__c,Country__r.Name, PartnerType__c,
        //Country__r.Region__c,Tier__c from Account where id=:userContact.AccountId];
        
        accId = currentUser.AccountId;
        partnerType = currentUser.Contact.Account.PartnerType__c!=null?currentUser.Contact.Account.PartnerType__c:'';
        partnerRegion = currentUser.Contact.Account.Country__r.Region__c !=null?currentUser.Contact.Account.Country__r.Region__c :'';
        
        System.debug('accId-->'+accId);
        System.debug('partnerType-->'+partnerType);
        System.debug('partnerRegion-->'+partnerRegion);
        
        if(partnerRegion !='') {
            designatedPartner = currentUser.Contact.Designated_Partner_Contact__c;
            String internalUsage = 'Partners';
            isBusinessApproved = currentUser.Contact.Business_Consulting_Approved__c;
            isSEOBetaProgram = currentUser.Contact.SEO_Beta_Program__c;
            isGPSApproved = currentUser.Contact.G_PS_Approved__c; 
            isSubscriptionQualified = currentUser.Contact.Account.Subscription_Qualified__c;
            
            /*for (ContentTypes__c cntType : ContentTypes__c.getAll().values()) {
                contentTypes.add(cntType.Name);    
            } */
            
            //To Check condition for Pricing guide
            if(designatedPartner && checkPartnerType(partnerType)) {
                contentTypes.add('Pricing Guides'); 
                System.debug('designatedPartner---');
            }
            
            if(isBusinessApproved) {
                contentTypes.add('Business Consulting Approved');
            }
            if(isSEOBetaProgram) {
                contentTypes.add('SEO Beta Program');
            }
            if(isGPSApproved) {
                contentTypes.add('G-PS Approved');
            }
            if(isSubscriptionQualified && designatedPartner){
                contentTypes.add('Subscription Pricing Guides');
            }
            
            if(partnerType != NULL && partnerType.contains('Technology Partner'))
                contentTypes.add('Technology Partner');
            if(partnerType != NULL && (partnerType.contains('Cloud Partner') || partnerType.contains('Cloud Reseller') || partnerType.contains('Cloud Solution Provider')))
                contentTypes.add('Cloud Partner');
            if(partnerType != NULL && partnerType.contains('Cloud Reseller'))
                contentTypes.add('Cloud Reseller');
            if(partnerType != NULL && partnerType.contains('Cloud Solution Provider'))
                contentTypes.add('Cloud Solution Provider');
            /*
            if(checkTechnologyPartnerType(partnerType)) {
                contentTypes.add('Technology Partner');
            }
            if(checkCloudPartnerType(partnerType)) {
                contentTypes.add('Cloud Partner');
            }
            if(checkCloudResellerPartnerType(partnerType)) {
                contentTypes.add('Cloud Reseller');
            }
            if(checkCloudSolutionProviderType(partnerType)) {
                contentTypes.add('Cloud Solution Provider');
            }
            */
            System.debug('contentTypes-->'+contentTypes);
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            contentVersionList = Database.query('SELECT ' + contentfields + ' FROM ContentVersion where ((Account__c = null and Region__c includes (\'Global\'))' + ' or (Account__c =: accId and Region__c includes (\'' + partnerRegion +'\'))' + ' or (Account__c = null and Region__c includes (\'' + partnerRegion + '\')))' + ' and Content_Type__c in: contentTypes and Internal_and_Partner_Usage__c includes (\'' +internalUsage +'\')' +  ' and IsLatest=true and refedge__Content_Status__c = \'Active\' order by lastmodifieddate desc');
            
            System.debug('contentVersionList-->'+contentVersionList.size());
            //System.debug('contentVersionList-->'+contentVersionList);
            setupData(contentVersionList);
            if(contentResults.size() > 0) {
                hasContent = true; 
            }
        }
    }
    
    
    /* Method is used to validate if Account Partner Type is part of allowed Partner Types for which Pricing Guides will be visible.
    */
    public boolean checkPartnerType(String partnerType){
        
        //Set<String> validPartnerTypes = new Set<String>{'VAR','Specialized Reseller','Cloud Reseller','Managed Services Provider','Contract Reseller','Cloud Solution Provider'};
        Set<String> validPartnerTypes = new Set<String>();
        List<Partner_Portal_Deal_Registration_Config__c> partnerConfig = Partner_Portal_Deal_Registration_Config__c.getall().values();
        for(Partner_Portal_Deal_Registration_Config__c ppdr: partnerConfig){
            if(ppdr.Pricing_Guides__c == true){
                validPartnerTypes.add(ppdr.Name);
            }
        }
        if(partnerType!=null && partnerType!=''){
            for(String indv : partnerType.split(';')){
                if(validPartnerTypes.contains(indv)){
                    return true;
                }
            }
        }
        return false;
    }
    
   
    /*
    // Method is used to validate if Account Partner Type is "Technology partner".
    public boolean checkTechnologyPartnerType(String partnerType){
        String techPartnerType = 'Technology Partner';
        if(partnerType!=null && partnerType!=''){
            for(String indv : partnerType.split(';')){
                if(techPartnerType.equalsIgnoreCase(indv)) {
                    return true;
                }
            }
        }
        return false;
    }
    
    // Method is used to validate if Account Partner Type is “Cloud Partner”.
    public boolean checkCloudPartnerType(String partnerType){
        Set<String> validPartnerTypes = new Set<String>{'Cloud Partner','Cloud Referral Partner', 'Cloud Reseller'};
        
        if(partnerType!=null && partnerType!=''){
            for(String indv : partnerType.split(';')){
                 if(validPartnerTypes.contains(indv)){
                    return true;
                }
            }
        }
        return false;
    }
    
    // Method is used to validate if Account Partner Type is “'Cloud Solution Provider”.
    public boolean checkCloudSolutionProviderType(String partnerType){
        Set<String> validPartnerTypes = new Set<String>{'Cloud Solution Provider'};
        
        if(partnerType!=null && partnerType!=''){
            for(String indv : partnerType.split(';')){
                 if(validPartnerTypes.contains(indv)){
                    return true;
                }
            }
        }
        return false;
    }
    
    public boolean checkCloudResellerPartnerType(String partnerType){
        Set<String> validPartnerTypes = new Set<String>{'Cloud Reseller'};
        
        if(partnerType!=null && partnerType!=''){
            for(String indv : partnerType.split(';')){
                 if(validPartnerTypes.contains(indv)){
                    return true;
                }
            }
        }
        return false;
    }
    */
    public void setupData(List<ContentVersion> docs) {
        Set<String> cvContentTypes = new Set<String>();
        for (ContentVersion cv : docs) { 
            // different content type
            if(((cv.Content_Type__c == 'Pricing Guides' || cv.Content_Type__c == 'Subscription Pricing Guides' || cv.Content_Type__c == 'Technology Partner' || cv.Content_Type__c == 'Cloud Partner' || cv.Content_Type__c == 'Cloud Solution Provider' || cv.Content_Type__c == 'Cloud Reseller') && cv.Region__c.Contains(partnerRegion)) 
                || cv.Content_Type__c == 'Business Consulting Approved' || cv.Content_Type__c == 'SEO Beta Program' || cv.Content_Type__c == 'G-PS Approved' ) {
                if (contentResults.containsKey(cv.Content_Type__c)) {
                    contentResults.get(cv.Content_Type__c).add(new ContentDocWrapper(cv));
                } else {
                    contentResults.put(cv.Content_Type__c, new List<ContentDocWrapper>{new ContentDocWrapper(cv)});
                }    
            }
        }
        if(contentResults.size()>0){
            if(contentResults.containsKey('Subscription Pricing Guides') && contentResults.containsKey('Pricing Guides')){
                contentResults.get('Pricing Guides').addAll(contentResults.get('Subscription Pricing Guides'));
                contentResults.remove('Subscription Pricing Guides');
            }
            else if(contentResults.containsKey('Subscription Pricing Guides')){
                contentResults.put('Pricing Guides',contentResults.get('Subscription Pricing Guides'));
                contentResults.remove('Subscription Pricing Guides');               
            }
        }
        
        for(String str:contentResults.keySet()) {
            List<ContentDocWrapper> tempList = contentResults.get(str);
            if(str == 'Business Consulting Approved') {
                contentResults.remove(str);
                str = 'Genesys Business Consulting';  
                contentResults.put(str,tempList);
            }
            if(str == 'SEO Beta Program') {
                contentResults.remove(str);
                str = 'Genesys SEO Content';  
                contentResults.put(str,tempList);
            }
            if(str == 'G-PS Approved') {
                contentResults.remove(str);
                str = 'Genesys Professional Services';  
                contentResults.put(str,tempList);
            }
            if(str == 'Technology Partner') {
                contentResults.remove(str);
                str = 'Technology Partner Content';  
                contentResults.put(str,tempList);
            }
            if(str == 'Cloud Partner') {
                contentResults.remove(str);
                str = 'Cloud Partner Content';  
                contentResults.put(str,tempList);
            }
            if(str == 'Cloud Solution Provider') {
                contentResults.remove(str);
                str = 'Cloud Solution Provider Partner Content';  
                contentResults.put(str,tempList);
            }
            if(str == 'Cloud Reseller') {
                contentResults.remove(str);
                str = 'Cloud Reseller Partner Content';  
                contentResults.put(str,tempList);
            }
        }
        System.debug('contentResults-->'+contentResults);
        return;
    }
    
}