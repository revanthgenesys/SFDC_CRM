//history PEC Changes added

public without sharing class ProposalOptionsExt1 
{
    public BigMachines__Quote__c objQuote {get;set;}
    public List<SelectOption> languages {get;set;}
    public Boolean blnIsPartner {get; private set;}
    public BigMachines__Quote__c quote {get; private set;}
    public String strAttachmentParentIds {get; private set;}
    public List<Account_Order_Address__c> list_QuoteAddresses {get; private set;}
    
    
    public ProposalOptionsExt1(ApexPages.StandardController controller) 
    {
        blnIsPartner = UserInfo.getUserType() == 'PowerPartner';
        objQuote = (BigMachines__Quote__c)controller.getRecord();
        objQuote.Show_Cover_Page__c = true;
        objQuote.Show_Cover_Letter__c = true;
        strAttachmentParentIds = '';
        list_QuoteAddresses = new List<Account_Order_Address__c>();
        quote = [SELECT Proposal_Language__c,End_User_ID__r.Name,Sold_To_Name__r.Name,Offering_Type__c, 
                 BigMachines__Opportunity__c, Opportunity_Offering_Type__c, Quote_Business_Type__c,
                 BigMachines__Opportunity__r.Sold_To_Country__r.PureConnect_Cloud_Delivery_Option__c,
                 BigMachines__Opportunity__r.Sold_To_Country__r.PureConnect_Premise_Delivery_Option__c,
                 BigMachines__Opportunity__r.Sold_To_Country__r.PureCloud_Delivery_Option__c,
                 BigMachines__Opportunity__r.Sold_To_Country__r.PureEngage_Cloud_Delivery_Option__c,
                 BigMachines__Opportunity__r.Sold_To_Country__r.PureEngage_Cloud_Selling_Entity__c,
                 BigMachines__Opportunity__r.Offering_Detail__c, MSA_Link__c ,BigMachines__Opportunity__r.Direct_Indirect_Sale__c,BigMachines__Opportunity__r.BusinessPartner__c,Purchase_Order_is_Required__c,Tax_Exemption_Applicable__c 
                 FROM BigMachines__Quote__c 
                 WHERE Id =: objQuote.id];
        String End_User = '[Company Name]';
        //Added by navaneetha for partner opportunity
        if(quote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect' && quote.BigMachines__Opportunity__r.BusinessPartner__c != null ){
            system.debug('testnavaneetha' + quote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c);
            system.debug('testnavaneetha' + quote.BigMachines__Opportunity__r.BusinessPartner__c);
            objQuote.Hide_Adjustments__c = true;            
            objQuote.Hide_Quote_Version__c = true;
        } 
        
        //Added By Ranjith on Jun 01, 2017 -- Starts
        //Logic to check if Bill to address is already assigned for this quote
        if(quote.Offering_Type__c == 'PureConnect Cloud' || quote.Offering_Type__c == 'PureCloud' || quote.Offering_Type__c == 'PureEngage Cloud')
        {
            list_QuoteAddresses = [SELECT Id, Address__c, City__c, Country__c, State__c, Zip_Code__c FROM Account_Order_Address__c 
                                   WHERE Quote__c = :quote.Id AND Address_Type__c = 'Bill To'];
            if(list_QuoteAddresses.size() == 0) 
            {                                                 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please select a Bill To address from Order Submission form before generating quote output.'));
                return;
            }
            /*
//Logic to display Solution Design attachments in Drawloop page.
for(Solution_Design__c objSolDes : [SELECT Id 
FROM Solution_Design__c 
WHERE Opportunity__c =: quote.BigMachines__Opportunity__c]) {
strAttachmentParentIds += objSolDes.Id + ',';
}
*/
        }
        else if(quote.Offering_Type__c == 'PureConnect On Premise' && quote.MSA_Link__c == null){
            quote.MSA_Link__c = Label.MSA_Link_PCP;
            objQuote.MSA_Link__c = Label.MSA_Link_PCP;
        }
        
        //Added By Ranjith on Jun 01, 2017 -- Ends
        if(End_User!= null)
            End_User = quote.End_User_ID__r.Name;
        
        //Added By Ranjith on Jun 20, 2017 -- Starts
        //if(quote.Offering_Type__c != 'CaaS')
        if(quote.Offering_Type__c != 'PureConnect Cloud' && quote.Offering_Type__c != 'PureCloud' && quote.Offering_Type__c != 'PureEngage Cloud')
            //Added By Ranjith on Jun 20, 2017 -- Ends
            
        {
            if(String.isBlank(objQuote.Cover_Letter_Text__c))
            {
                String strText = '<p>We are pleased to present the attached authorized quote obtained from Genesys on your behalf.<br/>';
                strText += 'This proposal pertains to the acquisition of commercial licenses and services for ' + quote.Sold_To_Name__r.Name + '.<br/>';
                strText += 'Thank you for the opportunity to share this information. We remain at your disposal to provide any further information.</p>';
                objQuote.Cover_Letter_Text__c = strText;
            }
            
            if(String.isBlank(objQuote.Executive_Summary__c)){
                String strText = 'The Grab is here you want to catch the reader attention by zeroing in on the problem at hand.<br/><br/>';
                strText += End_User+ ' is experiencing [insert problem and the need it has created. Grab the reader\'s attention by zeroing in on the problem at hand. Offer a bold statement that provides relevant insight specific to the RFP, the company, or an industry trend to add context and demonstrate your understanding of the situation].<br/><br/>';   
                strText += End_User+ ' requires a Premise-based solution that will [insert system requirements, business objectives, or other important solution details. Be brief here but show that you understand what the expectations are].<br/><br/>';
                strText += 'The ideal solution will not only meet these requirements, it will [insert an macro or an implied requirement\'s  go beyond the list supplied in the RFP and address a bigger picture need that Genesys can uniquely meet, e.g., Cross channel journeys, future proofed platform, reliable scale, visibility into workforce across all channels and work types].<br/><br/>'; 
                strText += 'Without implementing the proposed solution [briefly lay out the downside risk of doing nothing and staying with the status quo].<br/>';
                objQuote.Executive_Summary__c = strText;
                
            }
            
            if(String.isBlank(objQuote.What_you_want_to_Achieve__c)){
                String strText = End_User+'\'s objective is to find and engage a Partner who can [insert main objective of the RFP] and deliver the following:<br/><br/>';
                strText += 'Requirement A: explanation<br/><br/>';
                strText += 'Requirement B: explanation<br/><br/>';
                strText += 'Requirement C: explanation<br/><br/>';
                strText += 'The solution, when implemented will [insert big picture benefit or problem solved focus on the outcome].<br/><br/>';
                objQuote.What_you_want_to_Achieve__c= strText;
            }
            
            
            if(String.isBlank(objQuote.Genesys_Solution__c)){
                String strText = 'Genesys proposes its Enterprise Premise Solution, which is designed for large organizations that require highly scalable and customized contact center solutions. It delivers the contact center '+End_User+ ' needs integrated with your processes and back-end information systems.  The key features of this solution are:<br/><br/>';
                strText += '    Provides the necessary requirements for '+End_User+ ', now and in the future, within a single platform.<br/><br/>';
                strText += '    Full breadth and depth of capabilities for sophisticated, cross-channel contact centers, supporting unlimited agent deployments <br/><br/>';
                strText += '    Integrated self-service, analytics, workforce and back-office optimization for peak performance <br/><br/>';
                strText += '    Built-in support for remote and branch workers to span locations and geographies<br/><br/>';
                strText += '    Advanced customization to meet your unique requirements<br/><br/>';
                strText += '    Advanced third-party system integration to leverage legacy investments n<br/><br/>';
                strText += '    Unlimited scalability across geographies to meet the needs of large and dispersed contact centers<br/><br/><br/>';
                strText += 'In implementing our solution for '+End_User+ ' Genesys will: <br/><br/>';
                strText += '    Integrate with your existing systems and technology infrastructure<br/><br/>';
                strText += 'Requirement C: explanation<br/><br/>';
                strText += '    Deliver advanced reporting with deep insight into every aspect of your customer interactions<br/><br/>';
                strText += '    Provide 24x7 monitoring and support of the application infrastructure<br/><br/>';
                strText += 'The solution, when implemented will [insert big picture benefit or problem solved focus on the outcome].<br/><br/>';
                
                objQuote.Genesys_Solution__c= strText;
            }
            
            
            if(String.isBlank(objQuote.Why_Genesys__c)){
                String strText = 'Genesys is the most advanced software and service provider in the customer experience market today. For over 20 years, Genesys has brought innovation to the customer experience market from software based CTI through cross-channel routing and continuing with advanced analytics, modern desktops, and the ever growing integrations that allow companies to define their branded experience, always with an eye towards standards and open platforms.<br/><br/>';
                strText += 'Gartner has rated Genesys a magic quadrant leader 5 years running for Customer Experience, and Gartner Visionary Leader 3 years running. Frost & Sullivan recognized Genesys with the 2014 North American Company of the Year Award for Cloud Customer Contact Solutions. Over 40% of the Fortune 500 and 50% of global 200 companies use Genesys to improve their CX processes.  <br/><br/>';
                strText += 'Our spirit of innovation makes Genesys a future-proof platform and our SLAs demonstrate our promise to you and our financial ties to this commitments and to maintaining our leadership in the customer experience market.<br/><br/>';
                objQuote.Why_Genesys__c= strText;
            }
            
            if(String.isBlank(objQuote.Genesys_Unique_Benefits__c)){
                String strText = '  All-in-one platform consolidates the entire multi-vendor contact center stack <br/><br/>';
                strText += '    Operating seamlessly within your enterprise, our solution is designed to fully engage with your telephony, data and applications structure  <br/><br/>';
                strText += '    Solution offers a single point of configuration, management, routing and reporting<br/><br/>';
                strText += '    Outbound contact offers a single software dialing engine with virtually an unlimited scalability in both TDM and IP environments<br/><br/>';
                strText += '    World-class analytics embedded in the platform<br/><br/>';
                
                objQuote.Genesys_Unique_Benefits__c= strText;
            }
            
            if(String.isBlank(objQuote.Impacting_the_lives_of_everyday_people__c)){
                String strText = End_User+ ' is experiencing growth with a brand that promises a great customer experience. You are now at a crossroads having outgrown your existing technologies and we want to work with you to meet this challenge successfully. <br/><br/>';
                strText += 'Genesys technology helps businesses like '+End_User+ ' make a positive impact on the lives of everyday people, every day.  The Genesys Enterprise Premise Solution meets your combined need for growth and great customer experience with a solution that: <br/><br/>';
                strText += '    Integrates with '+End_User+ '\'s current systems <br/><br/>';
                strText += '    Supports branded customer experience delivery <br/><br/>';
                strText += '    Deploys as an all-in-one platform<br/><br/>';
                strText += '    Provides scalability & flexibility<br/><br/>';
                strText += '    Ensures high availability<br/><br/>';
                strText += 'The Genesys consolidated solution simplifies the business of being in business. The remainder of this document outlines the details of that solution. <br/><br/>';
                strText += 'We look forward to advancing to the next stage of your procurement process, and welcome the opportunity to present our solution and the value it can bring to your business.<br/><br/>';
                
                objQuote.Impacting_the_lives_of_everyday_people__c= strText;
            }
            
            languages = new List<SelectOption>();
            SelectOption newOption = new SelectOption('en_US', 'English');
            languages.add(newOption);            
            newOption = new SelectOption('fr', 'French');
            languages.add(newOption);
            if(objQuote.Quote_Business_Type__c != 'On Premise'){            
                newOption = new SelectOption('de', 'German');
                languages.add(newOption);
                newOption = new SelectOption('et', 'Italian');
                languages.add(newOption);
                newOption = new SelectOption('pt_BR', 'Portuguese');
                languages.add(newOption);
                newOption = new SelectOption('ko', 'Korean');
                languages.add(newOption);
                newOption = new SelectOption('zh_CN', 'Chinese');
                languages.add(newOption);
                newOption = new SelectOption('ja', 'Japanese');
                languages.add(newOption);
            }
        }
        
        if(blnIsPartner){
            objQuote.Hide_Decimal_In_Total__c = false;
            objQuote.Hide_Volume_Discount__c = false;
            objQuote.Hide_Discount__c = false;
            objQuote.Hide_Adjustments__c = true;
            objQuote.Hide_Maintenance_Months__c = false;
            objQuote.Hide_Maintenance_Due__c = false;
            objQuote.Hide_Table_of_Contents__c = true;
            objQuote.Hide_Quote_Version__c = true;
            objQuote.Hide_Product_Description__c = true;
            objQuote.Hide_List_Price__c = false;
            objQuote.Hide_Ext_List_Price__c = false;
            objQuote.Hide_Partner_Price__c = false;
            objQuote.Hide_Partner_Margin__c = false;
            objQuote.Hide_Extended_Net_Price__c = false;
            objQuote.Hide_Line_Item_Pricing__c = false;
            objQuote.Show_MSA_in_Output__c = false;
        }
    }
    
    // Handler for View Proposal button
    public PageReference viewContract()
    {   
        PageReference returnPage = null;    
        //try
        //{
        update objQuote;
        system.debug('!!!!objQuote'+objQuote.Contact__c);
        String id = objQuote.Contact__c;
        if(id != null && !(id.length() == 15 || id.length() == 18)){
            system.debug('!!!!Ins'+objQuote.Contact__c);
            //objQuote.Contact__c.addError('Please select a contact');
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a contact to proceed.'));
            //return null;
        }
        else { system.debug('!!!!Out'+objQuote.Contact__c);
              if(quote.Offering_Type__c == 'PureEngage Subscription' || quote.Offering_Type__c == 'PureConnect Subscription'){
                  returnPage = new PageReference('/apex/loop__looplus?Filter=Subscription');
              }
              else if(objQuote.Quote_Business_Type__c == 'On Premise') {                     
                  if(quote.Offering_Type__c == 'PureConnect On Premise') {
                      returnPage = new PageReference('/apex/loop__looplus?Filter=PureConnectOnPremiseQuote');
                      returnPage.getParameters().put('deploy', quote.BigMachines__Opportunity__r.Sold_To_Country__r.PureConnect_Premise_Delivery_Option__c); 
                  }
                  else {
                      returnPage = new PageReference('/apex/loop__looplus?Filter=QuoteOutput');
                  }
              }     
              else if(objQuote.Quote_Business_Type__c == 'Cloud' && quote.Offering_Type__c == 'Cloud Partner (PPU)'){
                  returnPage = new PageReference('/apex/loop__looplus?Filter=QuoteOutput');     
              }
              else {
                  if(quote.Offering_Type__c == 'PureCloud') {
                      returnPage = new PageReference('/apex/loop__looplus?Filter=PureCloudServiceOrderNew'); 
                      returnPage.getParameters().put('deploy', quote.BigMachines__Opportunity__r.Sold_To_Country__r.PureCloud_Delivery_Option__c);
                      if(quote.BigMachines__Opportunity__r.Offering_Detail__c == 'Free Trial') {
                          returnPage = new PageReference('/apex/loop__looplus?Filter=PureCloudServiceOrderNew1'); 
                      }                                                                    
                  }
                  else IF(quote.Offering_Type__c == 'PureEngage Cloud'){
                      returnPage = new PageReference('/apex/loop__looplus?Filter=PureEngageCloudServiceOrder'); 
                      returnPage.getParameters().put('deploy', quote.BigMachines__Opportunity__r.Sold_To_Country__r.PureEngage_Cloud_Delivery_Option__c);
                  }
                  else {
                      returnPage = new PageReference('/apex/loop__looplus?Filter=PureConnectCloudServiceOrder'); 
                      returnPage.getParameters().put('deploy', quote.BigMachines__Opportunity__r.Sold_To_Country__r.PureConnect_Cloud_Delivery_Option__c);
                  }
              }
              
              returnPage.getParameters().put('id', objQuote.Id);
              returnPage.getParameters().put('opportunityId', quote.BigMachines__Opportunity__c);
              returnPage.getParameters().put('contactId', objQuote.Contact__c);
              returnPage.getParameters().put('parentIds', strAttachmentParentIds);
              returnPage.getParameters().put('retURL', '/'+objQuote.Id);
              return returnPage;  
             }
        /*
}
catch(Exception e){            
} */    
        return returnPage;   
    }
    
    public void updateQuote(){
        update objQuote;        
    }
}