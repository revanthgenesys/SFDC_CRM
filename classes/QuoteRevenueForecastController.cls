public with sharing class QuoteRevenueForecastController {
    
    public String selectedPhase {get;set;}
    public List<lineItemsWrapper> lineItems {get;set;}
    public Boolean showPopup {get;set;}
    public Opportunity opp {get;set;}
    public String quoteNumber {get;set;}
    public String cloudBillingId {get;set;}    
    public String oppId {get;set;}
    public Cloud_Billing_Phase__c newPhase {get;set;}
    public String selectedPhaseName {get;set;}
    public List<phaseWrapper> phases {get;set;}
    public List<revenueDetailWrapper> revenueDetails {get;set;}    
    public String pageBlockTitle {get;set;}
    public Boolean isEditPhase {get;set;}
    public Boolean showGrid {get;set;}
    public String accountId {get;set;}
    public Boolean showRevenueDetails {get;set;}
    public Boolean showRevenueDetailsGrid {get;set;}
    public List<String> monthNames {get;set;}
    public Cloud_Billing_Information__c cloudBillingForecast {get;set;}
    public List<wrapperStatusMatrix>  statusMatrix {get;set;}
    public Boolean showStatusMatrix {get;set;}
    public List<Cloud_Billing_Phase_History__c> phaseHistory{get;set;}
    public List<Cloud_Forecast_Information_History__c>informationHistory{get;set;}
    public List <Cloud_Forecast_Month__c> cloudMonthForecast {get;set;} 
    public List<SelectOption> phasesOptions {get;set;}
    public String productLineId {get;set;}
    
    //public Opportunity objGoLiveOpp{get;set;}
    public Cloud_Billing_Information__c objCBI{get;set;}
    
    public boolean isDisableGoLive{get;set;}
    public string sCurrentURL;
    public boolean IsErr{get;set;}
    //public string sEventType{get;set;}
    
    public QuoteRevenueForecastController(){
        
    } 
    
    public String modeCheck{get;set;}
    public boolean edit{get;set;}
    
    public void init(){ 
        sCurrentURL = Apexpages.currentPage().getUrl();  
        oppId = ApexPages.currentPage().getParameters().get('oppId');
        modeCheck = ApexPages.currentPage().getParameters().get('mode');
        List <Cloud_Billing_Information__c > tempOpp = new List<Cloud_Billing_Information__c >();
                
        if(modeCheck!= null && modeCheck.equals('edit'))
          edit =true;
        else 
         edit = false;  
         
        if(oppId == null)
            return;
            
       if(oppId !=null)
         oppId = Id.valueOf(oppId);
        
        opp= [SELECT id, Account.Name,Annual_Contract_Value__c,Total_Annual_Contract_Value__c, Name, CloseDate, Override_Annual_Contract_Value__c,Subscription_Term__c,PS_Amount_On_Premise__c,Lines_of_Businesses__c,Country_Region__c,Country_Sub_Region__c FROM Opportunity WHERE id =: oppId];
        
        
        lineItems = QuoteRevenueForecastControllerHelper.populateLines(oppId, quoteNumber, selectedPhase);        
        showPopup = false;
        isEditPhase = false;
        pageBlockTitle = 'Primary Quote Lines';
        monthNames =  QuoteRevenueForecastControllerHelper.getMonthList(opp.CloseDate);
        populateCloudBillingRecord();        
        setGridVisibility(lineItems);
        populateStatusMatrix();
        getInformationHistory();
        
        LiveTextData();
    }
    
    public void LiveTextData()
    {
      try{
        system.debug('+++LiveTextData+++');
        List<Cloud_Billing_Information__c> lstCBI = [SELECT id, Account__c,Go_Live_Email_Sent_By__c,Go_Live_Email_Sent_Date__c,Go_Live_Text__c,Go_Live_Mail_Sent__c  FROM Cloud_Billing_Information__c WHERE Opportunity__c =: oppId];
        if(lstCBI != null && lstCBI.size()>0){
            objCBI= lstCBI[0] ; 
            system.debug('++++objCBI+++'+objCBI.Go_Live_Mail_Sent__c  );  
        }
       
       
        /* Get Opportunity data*/ 
      //objGoLiveOpp= [Select Go_Live_Text__c,Go_Live_Email_Sent_Date__c,id,CloseDate,Lines_of_Businesses__c,Country_Region__c,Country_Sub_Region__c,Account.Name,Subscription_Term__c,Annual_Contract_Value__c,Total_Annual_Contract_Value__c,PS_Amount_On_Premise__c from Opportunity where id =: oppId ];
      
      if(lstCBI[0].Go_Live_Email_Sent_Date__c != null)
       isDisableGoLive = true;
      else
       isDisableGoLive = false; 
      }
      catch(Exception ex)
      {}
    }
    /*public void EventType()
    {
      system.debug('++++sEventType +++ '+ sEventType );
      SendEmail();
      
    }*/
    /*public PageReference RedirectOnly()
    {
      PageReference pageRef;
      pageRef =  new PageReference(sCurrentURL);
      pageRef.setRedirect(true);
      return pageRef;
    }*/
    public PageReference SendEmail()
    {
      PageReference pageRef;
      try{
       system.debug('++++SendEmail+++');
       string sTmpName = 'Live Announce';
       string sEmailBody;
       string subject;
      IsErr = false;
      //Get Go Live distribution email list from custom settings
      List<GoLiveDistributionList__c> lstCstSetting = GoLiveDistributionList__c.getall().values();
      String[] toAddresses = new String[lstCstSetting.size()];
      for(integer i=0;i<lstCstSetting.size();i++)
      {
        toAddresses[i] =  lstCstSetting[i].Email__c;
      }
       
      /* Get Opportunity data*/ 
      Opportunity objGoLiveOpp= [Select id,CloseDate,Lines_of_Businesses__c,Country_Region__c,Country_Sub_Region__c,Account.Name,Subscription_Term__c,Annual_Contract_Value__c,Total_Annual_Contract_Value__c,PS_Amount_On_Premise__c from Opportunity where id =: oppId ];
       
      /* Get Email Template  */
      //EmailTemplate objEmTmp =  [SELECT Body,name,subject,HtmlValue FROM EmailTemplate where name =:sTmpName ];
      //emailBody = objEmTmp.HtmlValue;
      
      /* Merging values*/
      //emailBody = emailBody.replace('{!Opportunity.Account}',opp.Account.Name);
      //system.debug('++++emailBody +++ '+ emailBody );
      
      //Get Email body
      //system.debug('++++objCBI.Go_Live_Text__c+++ '+ objCBI.Go_Live_Text__c);
      //sEmailBody = EmailBody(objCBI.Go_Live_Text__c);
      //system.debug('++++sEmailBody +++ '+ sEmailBody );
      
      string sLinesBusiness='';
      if(objGoLiveOpp.Lines_of_Businesses__c != null)
       sLinesBusiness = objGoLiveOpp.Lines_of_Businesses__c;
      subject = 'Successful ' + sLinesBusiness  + ' Cloud Implementation at ' + opp.account.name;
      
      //if(objCBI.Go_Live_Text__c != '')
      //{
                  ///string sGoLiveText= string.valueof(objCBI.Go_Live_Text__c);
                 // sGoLiveText = sGoLiveText.replace('<br>','<br></br>');
                  //sGoLiveText = sGoLiveText.replace('<br>', '<br></br>');
                 // objCBI.Go_Live_Text__c=sGoLiveText;         
      //}
      
      if(objCBI.Go_Live_Text__c.length() < 140)
        IsErr = true;
      
       //system.debug('++++sEventType +++ '+ sEventType );
      /*Check if event is save with then call followin section*/  
       //if(sEventType == 'SaveWithEmail')
       //{
          /* Sending Email*/
          //if(!IsErr)
          //  EmailNotification(sEmailBody,subject,toAddresses);  
               
          /*Update Go Live Text Data in Cloud Forecast Information object*/
          //objCBI.Go_Live_Email_Sent_By__c = UserInfo.getUserEmail();
          //objCBI.Go_Live_Email_Sent_Date__c = Date.today();
          //objCBI.Go_Live_Mail_Sent__c = true;
          //objCBI.Go_Live_Text__c = sEmailBody;
          update objCBI;
          
          //update objGoLiveOpp;
       //}
       //else
       //  update objCBI;

      pageRef =  new PageReference(sCurrentURL);
      pageRef.setRedirect(true);

      }
      catch(Exception ex)
      {
        pageRef =  new PageReference(sCurrentURL);
        pageRef.setRedirect(false);
        ApexPages.addMessages(ex);
      }
      return pageRef ;
    }
    
    /*private string EmailBody(string sLiveText)
    {
      string sEmailBody; 
       Datetime dt = opp.CloseDate;
       string closedate = dt.format('MMMM d,  yyyy');
       string sCountryRegion = '';
       string sCountrySubRegion = '';
       string sSubscriptionTerm = '';
       double dAnnualContractValue = 0.00;
       double dTotalAnnualContractValue = 0.00;
       double dPSAmountOnPremise = 0.00;
       string sBusinessLine='';
       if(opp.Country_Region__c != null)
         sCountryRegion = opp.Country_Region__c;
       if(opp.Country_Sub_Region__c != null) 
         sCountrySubRegion = opp.Country_Sub_Region__c;
       if(opp.Subscription_Term__c!= null)
         sSubscriptionTerm = opp.Subscription_Term__c;
       
       if(opp.Annual_Contract_Value__c!= null)
         dAnnualContractValue = opp.Annual_Contract_Value__c;
       if(opp.Total_Annual_Contract_Value__c!= null)
         dTotalAnnualContractValue = opp.Total_Annual_Contract_Value__c;
       if(opp.PS_Amount_On_Premise__c != null)
         dPSAmountOnPremise = opp.PS_Amount_On_Premise__c;
       if(opp.Lines_of_Businesses__c != null)
         sBusinessLine = opp.Lines_of_Businesses__c;        
         
        try{
        sEmailBody = '<html><body><span style=\'font-size:9.0pt;font-family:"Arial","sans-serif"\'><table border="0" cellspacing="0" cellpadding="3">';
        sEmailBody= sEmailBody + '<tr><td style="font-size:20;color:#ff6666"><b>Confidential! FOR INTERNAL USE ONLY!</b></td></tr>';
        //sEmailBody= sEmailBody + '<tr><td></td></tr>';        
        
        //sEmailBody= sEmailBody + '<tr><td>I know that you are all very familiar with the Great Win Announcements that are generated from salesforce.';  
        //sEmailBody= sEmailBody + 'In early November, you will begin to see salesforce announcements when we complete projects and “Go Live”. '; 
        //sEmailBody= sEmailBody + 'In the meantime, Slava Zhakov and I wanted to get the great news about ' + opp.Account.name+ ' to you!  Successful Cloud projects are truly a team effort and span Professional Services, the CTO organization, Customer Care, Sales — and other parts of the business.  We are very excited to announce the successful go-live of ';
        //sEmailBody= sEmailBody + opp.Account.name+ ' IQR.<td></tr>';    
        //sEmailBody= sEmailBody + '<tr><td><br></br></td></tr>'; 
        // sEmailBody= sEmailBody + '<tr><td><br></br></td></tr>';    
        sEmailBody= sEmailBody + '<tr style="margin-top:10px;"><td>Congratulations on the successful implementation of ' + opp.Account.name+ ', a '+ sBusinessLine +' customer, on ' + closedate +'.</td></tr>';
        sEmailBody= sEmailBody + '<tr style="height:10px"><td></td></tr>'; 
        sEmailBody= sEmailBody + '<tr><td><u>Deployment details: </u></td></tr>';
        sEmailBody= sEmailBody + '<tr><td><b>Region:</b> '+ sCountryRegion +'</td></tr>';
        sEmailBody= sEmailBody + '<tr><td><b>Sub Region:</b>'+sCountrySubRegion +'</td></tr>';
        sEmailBody= sEmailBody + '<tr style="height:10px"><td></td></tr>'; 
               
        
        sEmailBody= sEmailBody + '<tr><td><b>Opportunity Name:</b> '+opp.name+'</td></tr>';
        sEmailBody= sEmailBody + '<tr><td><b>End Customer:</b> '+opp.Account.name+'</td></tr>';
        sEmailBody= sEmailBody + '<tr><td><b>Subscription Term: </b>'+ sSubscriptionTerm  +'</td></tr>';
        sEmailBody= sEmailBody + '<tr><td><b>Annual Contract Value:</b> '+ dAnnualContractValue  +'</td></tr>';
        sEmailBody= sEmailBody + '<tr><td><b>Total Contract Value:</b> '+ dTotalAnnualContractValue  +'</td></tr>';
        sEmailBody= sEmailBody + '<tr><td><b>Professional services: </b>'+dPSAmountOnPremise +'</td></tr>';
        
        sEmailBody= sEmailBody + '<tr style="height:10px"><td></td></tr>'; 
          
        sEmailBody= sEmailBody + '<tr><td><b>Talk about Go Live: </b>'+sLiveText+'</td></tr>'; 
          
        sEmailBody= sEmailBody + '<tr style="height:10px"><td></td></tr>';   
          
        //sEmailBody= sEmailBody + '<tr><td>By keeping this customer green and hitting our deliverable dates, we are well on our way to having a happy, referenceable customer in the cloud who will continue to roll out additional Genesys products into their deployment.<tr><td>';
        //sEmailBody= sEmailBody + '<tr><td>Keep up the good work!</td></tr>';
        
        //sEmailBody= sEmailBody + 'By satisfying this key customer objective and delivering on this key milestone, we are well on our way to having a happy, referenceable customers in the Cloud.';
        
        //sEmailBody= sEmailBody + '<tr style="height:10px"><td></td></tr>';    
        
        sEmailBody= sEmailBody + '<tr><td>By satisfying this key customer objective and delivering on this key milestone, we are well on our way to having a happy, referenceable customers in the Cloud.</td></tr>';
        sEmailBody= sEmailBody + '<tr><td></td></tr>'; 
        sEmailBody= sEmailBody + '<tr><td><b>Lucy Norris and Slava Zhakov</b></td></tr>';
        sEmailBody= sEmailBody + '</table></span></body></html>';
      }
      catch(Exception ex)
      {
      }
      return sEmailBody;
    }
    
    private void EmailNotification(string mailBody,string mailSubject,String[] toAddresses){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[]{MgrEmail};
        mail.setToAddresses(toAddresses);
        mail.setPlainTextBody(mailBody);
        mail.setHtmlBody(mailBody);
        mail.setSubject(mailSubject);
        if(!Test.isRunningTest())
          Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
   }*/
    
    private void populateStatusMatrix(){
        statusMatrix = QuoteRevenueForecastControllerHelper.populateStatusMatrix(cloudBillingForecast);
        if(statusMatrix.isEmpty())
            showStatusMatrix = false;
        else
            showStatusMatrix = true;
    }
    private void setGridVisibility(List<lineItemsWrapper> lineItems){
        if(lineItems.size() == 2)
            showGrid = false;
        else
            showGrid = true;
    }
    
    public void populateCloudBillingRecord(){
        List<Cloud_Billing_Information__c> cloudBillingRecord = [SELECT id, Account__c FROM Cloud_Billing_Information__c WHERE Opportunity__c =: oppId];
        if(cloudBillingRecord.isEmpty()){
            Cloud_Billing_Information__c newCloudBilling = QuoteRevenueForecastControllerHelper.createCloudBillingRecord(oppId);
            cloudBillingRecord.add(newCloudBilling);
        }
        cloudBillingId = cloudBillingRecord[0].id;
        accountId = cloudBillingRecord[0].Account__c;
        phases = QuoteRevenueForecastControllerHelper.populatePhases(cloudBillingId, null);
        populatePhaseOptions(phases);
        cloudBillingForecast = [SELECT id, Project_Health__c, Actual_Go_Live_Date__c, SOW_Execution_Date__c, Forecasted_Go_Live_Date_At_SOW_Signatu__c, 
            Forecasted_Go_Live_Date_Projected__c,  Professional_Services_PM__c, Discovery_Phase_Complete__c, Technical_Requirements_Completion_Date__c, 
            SOW_Fully_Delivered_Date_Actual__c, SOW_Fully_Delivered_Date_Forecasted__c, Design_Phase_Completed__c, Close_Date__c, PM_Assigned__c,
            Opportunity_Close_Date__c,Opportunity__r.Name,Time_to_Revenue__c,Original__c ,Forecasted_Time_to_Revenue__c,Go_Live_Planned_Date__c,
            Opportunity__c FROM Cloud_Billing_Information__c WHERE Opportunity__c =:oppId];     
    }
     
    private void populatePhaseOptions(List<QuoteRevenueForecastController.phaseWrapper> phases){
        phasesOptions = new List<SelectOption>();            
        for(phaseWrapper eachPhase : phases){
            System.debug('NKC debug eachPhase ['+eachPhase+']');
            if(eachPhase.phase != null){
                String label = eachPhase.phase.Phase_Classification__c + ' - (' + String.valueOf(eachPhase.phase.End_Date__c) + ')';                                                                
                SelectOption newOption = new SelectOption(eachPhase.phase.id, label);
                phasesOptions.add(newOption);
            }
        }
    }
    private void populateAccountId(){
        List<Cloud_Billing_Information__c> cloudBillingRecord = [SELECT id, Account__c FROM Cloud_Billing_Information__c WHERE Opportunity__c =: oppId];
        if(cloudBillingRecord.isEmpty()){
            accountId = cloudBillingRecord[0].Account__c;   
        }
    }
    
   
    public void loadRevenueDetails(){
        showRevenueDetails = true;      
        revenueDetails = QuoteRevenueForecastControllerHelper.populateRevenueDetails(cloudBillingId, null, null);   
        if(revenueDetails.isEmpty())
            showRevenueDetailsGrid = false;
        else
            showRevenueDetailsGrid = true;  
    }
    public class revenueDetailWrapper{
        public Cloud_Billing_Phase__c phase {get;set;}
        public String rowStyle {get;set;}  
        public Boolean isTotalRow {get;set;}  
        public Boolean isCMRRRow {get;set;}  
        
        public Decimal Total_Month_1{get;set;}
        public Decimal Total_Month_2{get;set;}  
        public Decimal Total_Month_3{get;set;} 
        public Decimal Total_Month_4{get;set;} 
        public Decimal Total_Month_5{get;set;} 
        public Decimal Total_Month_6{get;set;}
        public Decimal Total_Month_7{get;set;}
        public Decimal Total_Month_8{get;set;} 
        public Decimal Total_Month_9{get;set;}
        public Decimal Total_Month_10{get;set;}
        public Decimal Total_Month_11{get;set;}
        public Decimal Total_Month_12{get;set;}
        public Decimal Total_Month_13{get;set;}             
        public Decimal Total_Month_14{get;set;}
        public Decimal Total_Month_15{get;set;}  
        public Decimal Total_Month_16{get;set;} 
        public Decimal Total_Month_17{get;set;} 
        public Decimal Total_Month_18{get;set;} 
        public Decimal Total_Month_19{get;set;}
        public Decimal Total_Month_20{get;set;}
        public Decimal Total_Month_21{get;set;} 
        public Decimal Total_Month_22{get;set;}
        public Decimal Total_Month_23{get;set;}
        public Decimal Total_Month_24{get;set;}
        public Decimal Total_Month_25{get;set;}
        public Decimal Total_Month_26{get;set;}
        public Decimal Total_Month_27{get;set;}
        public Decimal Total_Month_28{get;set;}
        public Decimal Total_Month_29{get;set;}
        public Decimal Total_Month_30{get;set;}
        public Decimal Total_Month_31{get;set;}
        public Decimal Total_Month_32{get;set;}
        public Decimal Total_Month_33{get;set;}
        public Decimal Total_Month_34{get;set;}
        public Decimal Total_Month_35{get;set;}
        public Decimal Total_Month_36{get;set;}        
        public Decimal total1To24 {get;set;}
        public Decimal totalPhaseRevenueOneTime {get;set;}
    
    
    }
    
    public void deletePhase(){
        Cloud_Billing_Phase__c cloudBillingPhase = new Cloud_Billing_Phase__c( id = selectedPhase);
        delete cloudBillingPhase;
        phases = QuoteRevenueForecastControllerHelper.populatePhases(cloudBillingId, selectedPhase);
        selectedPhase = null;
    }
    
    public void showPopup(){
        newPhase = new Cloud_Billing_Phase__c();
        newPhase.Cloud_Billing_Information__c = cloudBillingId;
        showPopup = true;
    }
    public void createPhase(){
        cloudMonthForecast = new List <Cloud_Forecast_Month__c>();      
        insert newPhase;        
        newPhase = QuoteRevenueForecastControllerHelper.populatePhaseDates(newPhase, opp.CloseDate);
        update newPhase;
        showPopup = false;
        phases = QuoteRevenueForecastControllerHelper.populatePhases(cloudBillingId, null);
        populatePhaseOptions(phases);
        insert cloudMonthForecast;
    }
    public void hidePopup(){        
        showPopup = false;        
    }    
    
    public void editPhase(){        
        isEditPhase = true;
        newPhase = [SELECT id, Phase_Number__c, End_Date__c, Phase_Classification__c, Phase_Revenue__c, Phase_Name__c, Comments__c,
            Phase_Revenue_One_Time__c FROM Cloud_Billing_Phase__c WHERE id =: selectedPhase];      
        showPopup = true;
    }
    
    public void updatePhase(){
        cloudMonthForecast = new List <Cloud_Forecast_Month__c>();      
        
        newPhase = QuoteRevenueForecastControllerHelper.populatePhaseDates(newPhase, opp.CloseDate );
        update newPhase;
        showPopup = false;
        phases = QuoteRevenueForecastControllerHelper.populatePhases(cloudBillingId, null);
        populatePhaseOptions(phases);
        insert cloudMonthForecast;
    }
    
    public void loadPhaseLines(){
        System.debug('NKC debug selectedPhase ['+selectedPhase+']');
        System.debug('NKC debug selectedPhaseName ['+selectedPhaseName+']');        
        showPopup = false;
        showRevenueDetails = false;        
        //phases = QuoteRevenueForecastControllerHelper.populatePhases(cloudBillingId, selectedPhase);
        pageBlockTitle = selectedPhaseName;        
        lineItems = QuoteRevenueForecastControllerHelper.loadPhaseLineItems(selectedPhase, lineItems, oppId);
        setGridVisibility(lineItems);
        getPhaseHistory();
    }
   
    public void getPhaseHistory(){    
        phaseHistory = [Select id,Cloud_Billing_Phase__c,Phase_Classification__c,Old_End_Date__c,New_End_Date__c,
                        Old_Phase_Revenue__c,New_Phase_Revenue__c,Revenue_Change__c,Phase_Date_Change__c,Phase_Date_Change_Status__c,
                        Revenue_Change_Status__c,LastModifiedBy.name,LastModifiedDate from Cloud_Billing_Phase_History__c where Cloud_Billing_Phase__c =: selectedPhase  order by LastModifieddate desc];
     }
  
    public void getInformationHistory(){    
        informationHistory = [Select id,Field__c,Old_Date__c,New_Date__c,
                        Old_Value__c,New_Value__c,
                        LastModifiedBy.name,LastModifiedDate from Cloud_Forecast_Information_History__c where Cloud_Forecast_Information__c =: cloudBillingId order by LastModifieddate desc];
     }
  
    
    
    public void saveUpdate(){
        if(accountId == null)
            populateAccountId();
        
        QuoteRevenueForecastControllerHelper.savePhaseLines(lineItems, oppId, selectedPhase, accountId);
        lineItems = QuoteRevenueForecastControllerHelper.populateLines(oppId, quoteNumber, selectedPhase);
        if(selectedPhase != null && selectedPhase != '') {
         newPhase = QuoteRevenueForecastControllerHelper.getPhase(selectedPhase);
         newPhase = QuoteRevenueForecastControllerHelper.populatePhaseDates(newPhase, opp.CloseDate);
         update newPhase;
        }
        
        else { 
         List<Cloud_Billing_Phase__c> lstUpdatePhase = new List<Cloud_Billing_Phase__c>();
         List<Cloud_Billing_Phase__c> lstPhase  = [SELECT End_Date__c, Phase_Revenue_One_Time__c FROM Cloud_Billing_Phase__c where Cloud_Billing_Information__c =: cloudBillingId];
         for (Cloud_Billing_Phase__c  eachInfo : lstPhase) {
           
           eachInfo = QuoteRevenueForecastControllerHelper.populatePhaseDates(eachInfo, opp.CloseDate);
           lstUpdatePhase.add(eachInfo);
           
          }
         update lstUpdatePhase;
        }
        
        setGridVisibility(lineItems);
        
        //phases = QuoteRevenueForecastControllerHelper.populatePhases(cloudBillingId, selectedPhase);
        //newPhase = QuoteRevenueForecastControllerHelper.populatePhaseDates(newPhase, opp.CloseDate );
        //update newPhase;
    
    }
    
    public void cloneProductLine(){     
        QuoteRevenueForecastControllerHelper.cloneProductLine(lineItems, productLineId); 
    }
    
    public void addProductLine(){       
        QuoteRevenueForecastController.lineItemsWrapper newItem = new QuoteRevenueForecastController.lineItemsWrapper();
        newItem.isAddLine = true;
        newItem.isHeaderLine = false;
        newItem.isFromQuote = false;
        newItem.isTotalLine = false;
        Cloud_Phase_Line_Items__c newPhaseLineItem = new Cloud_Phase_Line_Items__c();
        newItem.phaseLineItem = newPhaseLineItem;
        lineItems.add(newItem);
        setGridVisibility(lineItems);
        return;        
    }
    public void deleteProductLine(){
        Cloud_Phase_Line_Items__c newLineItem = new Cloud_Phase_Line_Items__c(id = productLineId);
        delete newLineItem; 
        lineItems = QuoteRevenueForecastControllerHelper.populateLines(oppId, quoteNumber, selectedPhase);
        setGridVisibility(lineItems);
    }
    
    public void editCheck() {
        modeCheck = ApexPages.currentPage().getParameters().get('edit');    
    }
    
    public void saveHeader(){
        update cloudBillingForecast;
        edit=false;
        populateStatusMatrix();
    }
     public void editHeader(){
        edit = true;
        update cloudBillingForecast;
        populateStatusMatrix();
    }
    
    public void refresh(){      
    }
 
    public class lineItemsWrapper{
        public Integer index {get;set;}
        public Boolean selected {get;set;}
        public String lineName {get;set;}
        public String status {get;set;}
        public Double quantity {get;set;}
        public Double revenue {get;set;}
        public Double price {get;set;}
        public BigMachines__Quote_Product__c quoteProduct {get;set;} 
        public String oppProductId {get;set;}  
        public Double phaseQuantity {get;set;}   
        public String rowStyle {get;set;}   
        public String linePhases {get;set;} 
        public Boolean isHeaderLine {get;set;}
        public Boolean isOppLine {get;set;}
        public Integer phaseTotal {get;set;}
        public Decimal netUnitPrice{get;set;}
        public String phaseId {get;set;}
        public Cloud_Phase_Line_Items__c phaseLineItem {get;set;}
        public Boolean isAddLine {get;set;}
        public Boolean isFromQuote {get;set;}
        public Boolean isTotalLine {get;set;}
    }
    
    public class wrapperStatusMatrix{
        public String statusType {get;set;}
        public String status {get;set;}
        public String color {get;set;}
        public String statusText {get;set;}    
        public String previousStatus{get;set;}
        public String previousColor{get;set;}   
        
        
        public wrapperStatusMatrix(){
            status = '';
        }
    }    
    
    public class phaseWrapper{
        public Cloud_Billing_Phase__c phase {get;set;}
        public Boolean isAddPhase {get;set;}  
        public String style {get;set;}  
    }
   
  
    
    
}