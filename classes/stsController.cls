public with sharing class stsController {
    
    public opportunity opp {get; set;}
    public Boolean showPss { get; set;}
    public Boolean showLoadOption {get;set;}
    public Boolean showSurvey {get;set;}
    public Boolean showEstimate {get;set;}
    public String selectedPss {get; set;}
    public List<PSS_Opportunity__c> pssList {get; set;} 
    public List<SelectOption> options {get ; set;}
    //List of rows for the Q&A table
    public List<aTableRow> tableRows {get;set;}
    
    public List<categoryTable> categoryTables {get;set;}
    //List of selected quote items
    public List<PSS_Catalog__c> summaryList {get;set;}
    //List of selected quote items
    public List<PSS_Quote_Item__c> itemList {get;set;}
    //PSS Opportunity Record
    public PSS_Opportunity__c pssOpp {get;set;}
    
    public List<PSS_Opportunity__c> oppList {get;set;}
    //Recommended Package
    public PSS_Package__c recPackage{get;set;}
    
    public Integer selectedIndex{get;set;}
    
    public decimal tokenCount {get;set;}
    
    
    public class categoryTable
    {
        public string name {get;set;}
        public List<aTableRow> tableRows {get;set;}
        
        public categoryTable(string n)
        {
            name = n;
            tableRows = new List<aTableRow>();
        }
    }
    
    public class aTableRow
    {
        public PSS_Quote_Item__c quote {get;set;}
        public PSS_Catalog_Question__c question {get;set;}
        
        public aTableRow(PSS_Catalog_Question__c q, decimal i)
        {
            quote = new PSS_Quote_Item__c();
            question = q;
            quote.quantity__c = i;
        }
    }
    
    public stsController()
    {
       showPss=false;
       showLoadOption=false;
       pssList = new List<PSS_Opportunity__c>();
       pssOpp =  new PSS_Opportunity__c(); 
       options = new List<SelectOption>();
       tableRows = new List<aTableRow>();
       tokenCount = 0;
    }
    
    public void renderBlankPage()
    {
        renderBlankPage(false);
    }
    
    public void renderBlankPage(boolean test){
        selectedIndex = 0;
        recPackage = new PSS_Package__c();
        pssOpp = new PSS_Opportunity__c();
        categoryTables = new List<categoryTable>();
        summaryList = new List<PSS_Catalog__c>();
        itemList = new List<PSS_Quote_Item__c>();
        oppList = new List<PSS_Opportunity__c>();
        tokenCount = 0;
        
        List<PSS_Catalog_Question__c> questions = [select Name, formula__c, answerType__c, order__c, category__c, PSS_catalog__c, question__c, tip__c, isRecommended__c from PSS_Catalog_Question__c ORDER BY category__c, Order__c];
        for(PSS_Catalog_Question__c q:questions)
        {
            if(test){
                addTableRow(q, 1);
            }
            else{
            	addTableRow(q, 0);
            }
        }
        showSurvey = true;
    }
    
    public void getPss(){
      pssList = [select name, NumUsers__c, Opportunity__c, Summary__c from PSS_Opportunity__c where Opportunity__c = :pssOpp.Opportunity__c];
      showPss=true;
      if(pssList.size() > 0)
      {
          showLoadOption = true;
      }
      else
      {
          showLoadOption = false;
      }
      
     }
    
    public void getTokenCount(){
		List<PSS_Catalog__c> catalogList = [select name, summary__c, scope__c from PSS_Catalog__c];
        setItemList(catalogList);
        setTokenCount();
    }
    
    public List<SelectOption> getItems(){
        options = new List<SelectOption>();
        for(PSS_Opportunity__c ps: pssList){
            options.add(new SelectOption(ps.Name,ps.Name)); 
        }
        return options;
    }

    public PageReference loadOpp() {
        for (PSS_Opportunity__c o: pssList)
        {
            if(o.name == selectedPss)
            {
                pssOpp = o;
                showSurvey = true;
                break;
            }
        }
        if(showSurvey)
        {
            loadQuote();
        }
        return null;
    }
    
    public void addTableRow(PSS_Catalog_Question__c q, Decimal count) {
        Boolean newCat = true;
        for(categoryTable c:categoryTables)
        {    
            if(c.name == q.category__c)
            {
                c.tableRows.add(new aTableRow(q, count));
                newCat = false;
                break;
            }
        }
        if(newCat)
        {
            categoryTables.add(new categoryTable(q.category__c)); 
            categoryTables.get(categoryTables.size()-1).tableRows.add(new aTableRow(q, count));
        }
    }
    
    public void updatePage() {
        pssOpp.summary__c = '';
        List<PSS_Catalog__c> catalogList = [select name, summary__c, scope__c from PSS_Catalog__c];
        //PSS_Catalog__c bundle;
        //for (PSS_Catalog__c c:catalogList){if(c.PSS_ID__c=='tok001'){bundle=c;break;}}
		setItemList(catalogList);
        setTokenCount();
        buildOpportunityScope(catalogList);
        
        //get a list of all the packages
        List <PSS_Package__c> packages = [select name, description__c, eps__c, MinTokens__c, MaxTokens__c, tokens__c, monthly__c, prepay__c, scope__c from PSS_Package__c ORDER BY tokens__c ASC];
        integer count = 0;
        boolean selected = false;
		integer diff = 0;
		integer bundleCount = 1; 
        for(PSS_Package__c p:packages)
        {            
            if (tokenCount*1.2 >= p.MinTokens__c && tokenCount*1.2 <= p.MaxTokens__c)
            {
                selected = true;
                recPackage = p;
                pssOpp.PSS_Package__c = p.id;
                System.debug('Recommended Package' + pssOpp.summary__c);
                // Add Token Bundles
                if(tokenCount*1.2 > p.tokens__c)
                {
                    diff = math.round(tokenCount*1.2 - p.tokens__c);
                    while(diff > 9){
                        diff = math.mod(diff,10);
                        bundleCount++;
                    }
                }
                pssOpp.summary__c = '<span style="font-size:16px;font-weight:bold;color:blue"><big>Recommended Package:   '
                    + recPackage.Name + '</big></span><br><br>'
                    + '<span style="font-weight:bold;color:red"><big>Additional Token Bundles Recommended(10 per bundle): '
                    + 'Estimated Tokens: ' + tokenCount + '<br><br>'
                    + bundleCount + '</big></span><br><br>'
                    + p.scope__c + pssOpp.Summary__c;
                break;
            }
            count++;
        }
        pSSOpp.Summary__c = pSSOpp.Summary__c.replace('&lt;', '<').replace('&gt;', '>');
        System.debug(pssOpp.summary__c);
        showEstimate = true;
    }
    
    public void AddTokenBundles(integer i, PSS_Catalog__c bundle){
        PSS_Quote_Item__c item = new PSS_Quote_Item__c(quantity__c = i);
        item.PSS_Catalog__c = bundle.Id;
        item.PSS_Opportunity__c = pssOpp.Id;
        //item.PSS_Question__c = r.question.id;
        //item.formula__c = r.question.formula__c;
        itemList.add(item);
    }
    
    public void setItemList(List<PSS_Catalog__c> catalogList){
        itemList = new List<PSS_Quote_Item__c>();
        //Opportunity name and parent opportuntiy are bound to the input fields so nothing to do there
        //Insert new quote object
        for(categoryTable c:categoryTables)
        {
            for(aTableRow r:c.tableRows)
            {
                if(r.quote.Quantity__c > 0){
                    //Create a new quote item
                    PSS_Quote_Item__c item = new PSS_Quote_Item__c(quantity__c = r.quote.Quantity__c);
                    // Recommended Questions have a pre-calcuated value so set the flag
                    if (r.question.isRecommended__c){
                        //item.quantity__c = 0;
                        item.isRecommended__c = true;
                    }
                    item.PSS_Catalog__c = r.question.PSS_Catalog__c;
                    item.PSS_Opportunity__c = pssOpp.Id;
                    item.PSS_Question__c = r.question.id;
                    item.formula__c = r.question.formula__c;
                    itemList.add(item);
                }
            }
        }
    }
    
    public void setTokenCount(){
        //Determine the best PSS Package
        tokenCount = 0;
        for(PSS_Quote_Item__c i:itemList)
        {
            //get the catalog item's cost
            PSS_Catalog__c catalog = [select tokenCount__c from PSS_Catalog__c where id= :i.PSS_Catalog__c];
            i.unitCost__c = catalog.tokenCount__c;
            
            // There is only 1 formula right now
            if(i.formula__c != null && i.formula__c.length() > 0){
                tokenCount += catalog.tokenCount__c*i.Quantity__c*decimal.valueOf(i.formula__c);
            }
            // only update the token count for items not flagged as "recommended cost"
            if(!i.isRecommended__c){
                tokenCount += catalog.tokenCount__c*i.Quantity__c;
            }
        }
        // Now that the total token count is determined, go back and update the "estimate"
        decimal tempCount = (tokenCount*.06).setScale(0);
        for(PSS_Quote_Item__c i:itemList)
        {
            if (i.isRecommended__c){
                i.quantity__c = tempCount;
                tokenCount += tempCount*i.unitCost__c;
            }
        }
    }
    
    public void buildOpportunityScope(List<PSS_Catalog__c> catalogList){
        List<string> catList = new List<string>();
        List<string> scopeList = new List<string>();
        // Build Scope List
        for(PSS_Quote_Item__c i:itemList)
        {
            //Build scope
            boolean found = false;
            integer index = 0;
			PSS_Catalog__c catalog = getCatalogByQuoteItem(catalogList, i);
            for(string s:catList){
                if (s==catalog.name){
                    found = true;
                    //find total number of these catalog items and update the scope count accordingly
                    decimal count = i.Quantity__c;
                    for(PSS_Quote_Item__c i2:itemList){
                        if(i2.PSS_Catalog__c==i.PSS_Catalog__c){
                            count+=i2.Quantity__c;
                        }
                    }
                    scopeList[index] = buildScope(catalog, count);
                    break;
                }
                index++;
            }
            if(!found){                 
                catList.add(catalog.Name);
                scopeList.add(buildScope(catalog, i.Quantity__c));
            }
        }
        //Build scope
        for (string s:scopeList){
            pssOpp.summary__c += s;
        }
    }
    
    public PSS_Catalog__c getCatalogByQuoteItem(List<PSS_Catalog__c> catalogList, PSS_Quote_Item__c i)
    {
        for(PSS_Catalog__c c:catalogList)
        {
            if (c.Id == i.PSS_Catalog__c){return c;}
        }
        return null;
    }
    
    public string buildScope(PSS_Catalog__c catalog, decimal count){
        string scope =  '<br>--------------------------------------------------<br>';
        scope += '<span style="text-decoration:underline;font-weight:bold;">'+catalog.name+'</span><br>';
        scope += catalog.scope__c+'<br>';
        scope += '<span style="font-style:italic;font-weight:bold;">This estimate include (' + count + ') of these service offerings</span>';
        return scope;
    }
    
    public void save() {
        if (pssOpp.Id != null)
        {
            update pssOpp;
			List<PSS_Quote_Item__c> quoteItems = [select Quantity__c, PSS_Catalog__c, PSS_Question__c, isRecommended__c from PSS_Quote_Item__c where PSS_Opportunity__c = :pssOpp.id];
            delete quoteItems;
            insert itemList;
        }
        else
        {
            insert pssOpp; 
            updatePage(); 
            insert itemList;       
        }
    }
    
    public void deleteOpp() {
        if (pssOpp.Id != null)
        {
            delete pssOpp;
            getPss();
            showSurvey = false;
            showEstimate = false; 
        }
    }
    
    public void loadQuote() 
    {
        categoryTables = new List<categoryTable>();
        summaryList = new List<PSS_Catalog__c>();
        itemList = new List<PSS_Quote_Item__c>();
        
        List<PSS_Catalog_Question__c> questions = [select Name, formula__c, answerType__c, category__c, PSS_catalog__c, question__c, tip__c, order__c, isRecommended__c from PSS_Catalog_Question__c ORDER BY category__c, order__c];
        List<PSS_Quote_Item__c> quoteItems = [select Quantity__c, PSS_Catalog__c, PSS_Question__c, isRecommended__c from PSS_Quote_Item__c where PSS_Opportunity__c = :pssOpp.id];
        for(PSS_Catalog_Question__c q:questions)
        {
            boolean added = false;
            for(PSS_Quote_Item__c i:quoteItems)
            {
                if(i.PSS_Question__c == q.id)
                {
                    addTableRow(q, i.Quantity__c);
                    //tableRows.add(new aTableRow(q, i.Quantity__c));
                    added = true;
                    break;
                }
            }
            if(!added)
            {
                addTableRow(q, 0);
                //tableRows.add(new aTableRow(q, 0));
            }
        }
        showEstimate = true;        
    }
}