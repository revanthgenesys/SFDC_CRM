public without sharing class PartnerPortalSearchController {    
    
    public static String PRODUCT_SOLUTION_PAGE {get { return 'Products & Solutions'; } }
    public static String SERVICES_PAGE {get { return 'Services'; } }
    public static String TRAINING_PAGE {get { return 'Training'; } }     
    
    String workspaceName = 'Sales Contributed Content';
    Id workspaceId = null;
    
    //Variables for sorting the columns of the table        
    public static String sortExpression {get; set;}
    public static String sortDirection {get; set;}
    public static String sortExp {get; set;}
    public static String sortDir {get; set;}   
        
    //First method called on click of command link
    public void sortByField(){
     String tmpCol = ApexPages.currentPage().getParameters().get('srtColumn');
     String tmpDir = ApexPages.currentPage().getParameters().get('srtDir');
     sortExpression = (tmpCol != NULL)? tmpCol:'Title';
     sortDirection = (tmpDir != NULL)? tmpDir:'ASC';
     sortExp = sortExpression;
     sortDir = sortDirection;     
      for(Map<String,List<PartnerPortalSearchController.ContentDocWrapper>> mapTmp : contentResults.values()){
        for(String key : mapTmp.keyset()){ 
           mapTmp.get(key).sort(); //This will call the compareTo method in the wrapper class for comparison
        }  
      }
     } 
   
    //Wrapper class uses the comparable interface for sorting
    public class ContentDocWrapper implements comparable{
        public String title { get; set; }
        public String description { get; set; } 
        public String size { get; set; }
        public String author { get; set; }
        public String lastmodified { get; set; }
        public String docid { get; set; }
        public String url { get; set; }
                
        public ContentDocWrapper(ContentVersion cv) {            
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

    
    public Map<String,Map<String,List<ContentDocWrapper>>> contentResults;
    public List<String> topLevelResult { get; set; }
    
    public String contentTypeFilter { get; set; }
    public String serviceFilter { get; set; }
    public String searchFilter { get; set; }
    public String productFilter { get; set; }
    public String solutionFilter { get; set; }
    public String pageId { get; set; }
    public String partnerType='';
    public String partnerRegion='';
    public Boolean designatedPartner=false;
    
    public PartnerPortalSearchController searchController { get; set; }
    
    public PartnerPortalSearchController() {
        if (workspaceId==null) {
            List<ContentWorkspace> workspaces = [SELECT Id FROM ContentWorkspace WHERE Name=:workspaceName];
            if (workspaces.size()>0) workspaceId = workspaces[0].Id;
        }
        contentTypeFilter='';
        serviceFilter='';
        searchFilter='';
        productFilter='- Not Specific -';
        solutionFilter='- Not Specific -';
        pageId='';  
        searchController = this;
        
        performInitialSearch();
        
    }
    
    public Map<String,Map<String,List<ContentDocWrapper>>> getContentResults() {
        return contentResults;
    }
    
    private string getConditionStment(){
        String condition = getInitialSearchCondition() ;
        System.debug('******getPageName()'+getPageName());
        if(getPageName().contains('Partner_Portal_Products_Solutions')){
            condition += ' AND  Primary_Product__c != null and Solution__c != null';
        }else if(getPageName().contains('Partner_Portal_Services')){
            condition += ' AND (Services_Programs__c=\'Business Consulting\' OR Services_Programs__c=\'Professional Services\' OR Services_Programs__c=\'Genesys Care\' OR Services_Programs__c=\'Managed Services\' OR Services_Programs__c=\'Customer Care\')';
        }else if(getPageName().contains('Partner_Portal_Training')){
            //condition += ' AND (Content_Type__c = \'Training\' or Content_Type__c = \'Webinar: External\' or Content_Type__c = \'Webinar: Internal\' or Content_Type__c = \'Genesys University\')';
            condition += ' AND (Content_Type__c = \'Training\' or Services_Programs__c = \'Genesys University\')';
        }else if(getPageName().contains('Partner_Portal_Sales_Marketing')){
            condition += ' AND ' + multiCondition('Content_Type__c', 'Advertisement;Analyst report;Article - Published;Branding;Collateral: Brochure;Collateral: Datasheet;Collateral: Infographic;Collateral: White paper;Competitive Information;Customer Story: External;Demo - Flash;eBook;Email Template;Event: G-Force;Event: Other;Event: Partner;FAQ;Features and Benefits Document;GAME Sales Aid;Guide - Sales/Program/Product/Marketing;Newsletter: Customer;Newsletter: Partner;Other;Presentation;Press Release;Sales Process;Sales Tools;Use Case;Video;Webinar: External;Webinar: Internal;');
        }else if(getPageName().contains('Partner_Portal_Partner_Program')){
            condition += ' AND  Services_Programs__c = \'Partner Program\'';
        }
      System.debug('*****condition'+condition);  
      return condition;
    }
    public void performInitialSearch(){
        
        // 2. execute the search
        String contentfields = 'Id,ContentDocumentId,Description,Title,ContentSize,'
                              +'Legacy_Author__c,CreatedBy.Name,LastModifiedDate,Content_Type__c,Services_Programs__c,Region__c';

        
        String condition=getConditionStment();
        
        List<String> contentTypes = new List<String> ();
        Schema.DescribeFieldResult contentTypeField = ContentVersion.Content_Type__c.getDescribe();
        List<Schema.PicklistEntry> values = contentTypeField.getPickListValues();
        for (Schema.PicklistEntry v : values) { 
            contentTypes.add(v.getValue());
        }
        String runAs = ApexPages.currentPage().getParameters().get('runAs');
        if(runAs == null)
            runAs = Userinfo.getUserId();           
        User currentUser = [SELECT ContactId,email FROM User where id =: runAs];
        Contact userContact = [Select AccountId,Designated_Partner_Contact__c from Contact where id =:currentUser.ContactId ];
        Account userAcnt = [Select Name,SAP_Code__c,Country__r.Name, PartnerType__c,
        Country__r.Region__c,Tier__c from Account where id=:userContact.AccountId]; 
        partnerType = userAcnt.PartnerType__c!=null?userAcnt.PartnerType__c:'';
        partnerRegion = userAcnt.Country__r.Region__c!=null?userAcnt.Country__r.Region__c:'';
        designatedPartner = userContact.Designated_Partner_Contact__c;
        String usage;
        String internalUsage = 'Partners';

        List<ContentVersion> docs = new List<ContentVersion>();
        for (String theContentType:contentTypes){
        String sql=        'SELECT ' + contentfields + ' FROM ContentVersion ' + condition + ' and Content_Type__c = \''+theContentType+'\' and Internal_and_Partner_Usage__c includes (\''+internalUsage+'\')' + ' order by lastmodifieddate desc';
        system.debug('@@@@@@@####'+sql);
            for (ContentVersion tmp : Database.query('SELECT ' + contentfields + ' FROM ContentVersion ' + condition + ' and Content_Type__c = \''+theContentType+'\' and Internal_and_Partner_Usage__c includes (\''+internalUsage+'\')'+ ' order by lastmodifieddate desc')) {
                docs.add(tmp);
            }
        }
        
        setUpData(docs);
        return;
    }
    
    
    private void setUpData(List<ContentVersion> docs){
                
        contentResults = new Map<String,Map<String,List<ContentDocWrapper>>>();
        //if (serviceFilter=='') {
        //  contentResults.put('DEFAULT', new Map<String,List<ContentVersion>>());
        //};
        //t == > Partner Program
        //k == > Content Type
        String t,k;
        //check Partner Type
        Boolean allowPartnerType = checkPartnerType(partnerType);
        for (ContentVersion cv : docs) {        
            t = (serviceFilter=='' ? 'DEFAULT' : cv.Services_Programs__c);

            Map<String,List<ContentDocWrapper>> m;
            if (contentResults.containsKey(t)) {
                m = contentResults.get(t);
            } else {
                m = new Map<String,List<ContentDocWrapper>>();
                contentResults.put(t, m);
            }
            
            k = cv.Content_Type__c;
            List<ContentDocWrapper> cvlist;
            if (m.containsKey(k)) {
                cvlist = m.get(k);
            } else {
                cvlist = new List<ContentDocWrapper>();
                //Logic added to show only Pricing Guides for specific regions and avoid invalid Partners
                if((k!='Pricing Guides' && k!= 'Program Guide') || (allowPartnerType && (k=='Pricing Guides' || k=='Program Guide') && designatedPartner && (cv.Region__c.containsIgnoreCase(partnerRegion) || cv.Region__c.containsIgnoreCase('Global') ))){
                    m.put(k,cvlist);
                }
            }
            if(k!='Pricing Guides' || (allowPartnerType && k=='Pricing Guides' && designatedPartner && (cv.Region__c.containsIgnoreCase(partnerRegion) || cv.Region__c.containsIgnoreCase('Global')))){
                cvlist.add(new ContentDocWrapper(cv));
            }
        }
        return;
    }
    
    /* Method is used to validate if Account Partner Type is part of allowed Partner Types for which Pricing Guides will be visible.
    */
    public boolean checkPartnerType(String partnerType){
        
        //Set<String> validPartnerTypes = new Set<String>{'VAR','Specialized Reseller','Cloud Partner','Managed Services Provider','Contract Reseller'};
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
    
    public void performSearch() {
        System.debug('NKC debug pageId ['+pageId+']');
        System.debug('NKC debug searchFilter ['+searchFilter+']');
        // 1. validate we should perform a search or set default filter values
        if (pageId=='Products & Solutions' && serviceFilter=='') 
           contentResults = null;        
        // 2. execute the search
        String contentfields = 'Id,ContentDocumentId,Description,Title,ContentSize,'
                              +'Legacy_Author__c,CreatedBy.Name,LastModifiedDate,Content_Type__c,Services_Programs__c,Region__c';
        String condition = getSearchCondition();
        if( ( pageId== 'Products & Solutions')// && ( productCondition()!= '' || solutionCondition() != ''))
            || (pageId== 'Services'  && serviceCondition()!= '')
            || (pageId== 'Training'  /*&& contentTypeCondition()!= ''*/)
            || (pageId== 'Sales & Marketing Tools' /* && contentTypeCondition()!= ''*/)
            || (pageId== 'Home Page'))
        {  
        String runAs = ApexPages.currentPage().getParameters().get('runAs');
        if(runAs == null)
            runAs = Userinfo.getUserId();           
        User currentUser = [SELECT ContactId,email FROM User where id =: runAs];
        Contact userContact = [Select AccountId from Contact where id =:currentUser.ContactId ];
        Account userAcnt = [Select Name,SAP_Code__c,Country__r.Name, PartnerType__c,
        Country__r.Region__c,Tier__c from Account where id=:userContact.AccountId]; 
        String usage;
        String internalUsage = 'Partners'; 
         system.debug('@@@@@@@####--notspecicfic'+contentTypeCondition());
        System.debug('NKC debug searchFilter ['+searchFilter+']');
        System.debug('******getConditionStment()'+getConditionStment());
        System.debug('******pageId'+pageId);
        if((pageId== 'Training' ||pageId== 'Sales & Marketing Tools') && (contentTypeCondition()== ''|| contentTypeCondition().contains('- Not Specific -'))){
            System.debug('******pageId'+pageId);
            String strLike = String.escapeSingleQuotes(likeString(searchFilter));
            System.debug('******strLike'+strLike);
            if(strLike != ''){
                condition = getConditionStment() +' AND '+searchFilterCondition();
                System.debug('******condition'+condition);              
            }
            else{
                condition = getConditionStment(); 
                System.debug('******condition'+condition);
            }
        }
        System.debug('NKC debug condition ['+condition+']');
        String query = 'SELECT ' + contentfields + ' FROM ContentVersion ' + condition + ' and Internal_and_Partner_Usage__c includes (\''+internalUsage+'\')';
        System.debug('NKC debug query ['+query+']');
        system.debug('@@@@@@@####'+query);
        query += ' order by lastmodifieddate desc';
        system.debug('@@@@@@@####'+query);
        List<ContentVersion> docs = Database.query(query);   
   
        setUpData(docs);
        
        system.debug('----------------------docs---------------------------'+docs);    
        return;
        }        
    }
        
    public String getWorkspaceInfo() {
        return workspaceName + '(' + workspaceId + ')';
    }
    
    public List<SelectOption> getProductOptions(){
        Schema.DescribeFieldResult prodfield = ContentVersion.Primary_Product__c.getDescribe();
        List<Schema.PicklistEntry> values = prodfield.getPickListValues();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','- Not Specific -'));
        for (Schema.PicklistEntry v : values) { 
            if(v.getValue() != '- Not Specific -'){         
                options.add(new SelectOption(v.getValue(), v.getLabel()));
            }  
        }
        return options;
    }
    
    public List<SelectOption> getSolutionOptions(){
        Schema.DescribeFieldResult solfield = ContentVersion.Solution__c.getDescribe();
        List<Schema.PicklistEntry> values = solfield.getPickListValues();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','- Not Specific -'));
        for (Schema.PicklistEntry v : values) {    
            if(v.getValue() != '- Not Specific -'){     
                options.add(new SelectOption(v.getValue(), v.getLabel()));
            } 
        }
        return options;
    }
    
    
    public String getInitialSearchCondition() {
        List<String> preconditions = new List<String>();
        preconditions.add(workspaceCondition());
        String condition='WHERE IsLatest=TRUE AND PublishStatus=\'P\'';
        for (Integer i=0; i<preconditions.size(); i++) {
            String pc = preconditions.get(i);
            if (pc!=null && pc!='') {
                condition += ' AND ' + pc;
            }
        }
        return condition;
    }
    
    
    public String getSearchCondition() {
        List<String> preconditions = new List<String>();
        
        system.debug('----------------searchFilterCondition()-----------------'+searchFilterCondition());

        system.debug('----------------contentTypeCondition()-----------------'+contentTypeCondition());

        system.debug('----------------serviceCondition()-----------------'+serviceCondition());

        system.debug('----------------productCondition()-----------------'+productCondition());
        
        system.debug('----------------solutionCondition()-----------------'+solutionCondition());
                
        system.debug('----------------workspaceCondition()-----------------'+workspaceCondition());

        preconditions.add(searchFilterCondition());
        preconditions.add(contentTypeCondition());
  
        if(pageId== 'Services')preconditions.add(serviceCondition());
        
        if( pageId== 'Products & Solutions'){
            preconditions.add(productCondition());
            preconditions.add(solutionCondition());
        }
        preconditions.add(workspaceCondition());
        String condition='WHERE IsLatest=TRUE AND PublishStatus=\'P\'';
        for (Integer i=0; i<preconditions.size(); i++) {
            String pc = preconditions.get(i);
            if (pc!=null && pc!='') {
                condition += ' AND ' + pc;
            }
        }
        
        system.debug('----------------condition -----------------'+condition);
        return condition;
    }
    
    private String likeString(String s) {
        String replU = '\\_';
        String replP = '\\%';
        return s.replace('\\', '\\').replace('_',replU).replace('%',replP);
    }
    
    private String searchFilterCondition() {
        if (searchFilter==null || searchFilter=='') return '';
        String strLike = String.escapeSingleQuotes(likeString(searchFilter));
        return '(Description LIKE \'%'+strLike+'%\' OR Title LIKE \'%' + strLike + '%\')';
    } 
    
    private String multiCondition(String field, String values) {
        if (values==null || values=='') return '';
        List<String>vals = values.split(';');
        String cond = '';
        Integer ct=0;
        for (Integer i=0; i<vals.size(); i++) {
            String c = vals.get(i);
            if (c!=null && c!='') {
                cond += (i>0 ? ' OR ' : '') + field + '=\'' + String.escapeSingleQuotes(c) + '\'';
                ct++;
            }
        }
        if (ct>1) return '(' + cond + ')';
        return cond;
    }
    private String contentTypeCondition() {
        System.debug('*****contentTypeFilter'+contentTypeFilter);
        //return multiCondition('Content_Type__c', contentTypeFilter);
        //String testCondition = multiCondition('Content_Type__c', contentTypeFilter);
        //System.debug('*****testCondition'+testCondition);
        if(pageId == 'Training'){
            String contentTypeConditionString = '(Content_Type__c = \'Training\' or Services_Programs__c = \'Genesys University\')';
            System.debug('*****contentTypeConditionString'+contentTypeConditionString);
            return contentTypeConditionString;
        }
        return multiCondition('Content_Type__c', contentTypeFilter);
    }
    private String serviceCondition() {
        //return multiCondition('Services_Programs__c', serviceFilter);
        System.debug('****serviceFilter'+serviceFilter);
        if(serviceFilter!=null && serviceFilter!='' && serviceFilter=='Genesys Care'){
            serviceFilter = 'Genesys Care;Managed Services;Customer Care';
        }
        System.debug('****serviceFilter'+serviceFilter);
        String strFilterval=multiCondition('Services_Programs__c', serviceFilter);
        if(strFilterval=='')
        strFilterval= ' (Services_Programs__c=\'Business Consulting\' OR Services_Programs__c=\'Professional Services\' OR Services_Programs__c=\'Genesys Care\')';
      
        return strFilterval;
    }
    
    private String productCondition() {
        if (productFilter==null || productFilter=='') return '';
        return 'Primary_Product__c=\'' + String.escapeSingleQuotes(productFilter) + '\'';
    }
    
    private String solutionCondition() {
        if (solutionFilter==null || solutionFilter=='') return '';
        return 'Solution__c=\'' + String.escapeSingleQuotes(solutionFilter) + '\'';
    }
    
    private String workspaceCondition() {
        if (workspaceId==null) return '';
        return ''; // TODO: REMOVE THIS LINE TO TURN ON THE WORKSPACE FILTERING!!!!!
        return 'ContentDocument.ParentId = \'' + String.escapeSingleQuotes(workspaceId) + '\'';
    }
    
    public string getPageName(){
          String pageName = ApexPages.CurrentPage().getUrl();     
          pageName = pageName.replaceFirst('/apex/','');          
          pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');   
                                                                  
          string[] pageNameExtra = pageName.split('%3F',0);   
                                                                  
          pageName = pageNameExtra[0];                           
                                                                  
          return pageName;                                        
      }
    
    
}