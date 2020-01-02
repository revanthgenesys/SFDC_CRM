public class ProposalOptionsExt{
    
    public BigMachines__Quote__c objQuote {get;set;}
    public List<SelectOption> languages {get;set;}
    public ProposalOptionsExt(ApexPages.StandardController controller){
        objQuote = (BigMachines__Quote__c)controller.getRecord();
        objQuote.Show_Cover_Page__c = true;
        objQuote.Show_Cover_Letter__c = true;
        objQuote.Hide_End_User__c = false;
        
        BigMachines__Quote__c quote = [SELECT Proposal_Language__c,End_User_ID__r.Name,Sold_To_Name__r.Name,Sold_To_Address__c,Sold_To_City__c,Sold_To_State__c,Sold_To_Country__c,Sold_To_Name__r.Street1__c,
                                       Sold_To_Name__r.City__c,Sold_To_Name__r.StateProvince__c,Sold_To_Name__r.ZipCode__c,Sold_To_Name__r.Country__r.name FROM BigMachines__Quote__c WHERE id =: objQuote.id];
        
        
        if( objQuote.Quote_Business_Type__c != null &&  objQuote.Quote_Business_Type__c == 'Renewal') {
            objQuote.Show_Cover_Page__c = false;
            objQuote.Show_Cover_Letter__c = false;
        }
        
        if(objQuote.Sold_To_Address__c == null){
            objQuote.Sold_To_Address__c = quote.Sold_To_Name__r.Street1__c;
            objQuote.Sold_To_City__c = quote.Sold_To_Name__r.City__c;
            objQuote.Sold_To_State__c = quote.Sold_To_Name__r.StateProvince__c;
            objQuote.Sold_To_Country__c   = quote.Sold_To_Name__r.Country__r.Name;
            objQuote.Sold_To_Zip_Code__c = quote.Sold_To_Name__r.ZipCode__c;
        }
        
        String End_User = '[Company Name]';
        
        if(End_User!= null)
            End_User = quote.End_User_ID__r.Name;
        
        //objQuote.Proposal_Language__c = quote.Proposal_Language__c;
        if(String.isBlank(objQuote.Cover_Letter_Text__c)){
            String strText = '<p>We are pleased to present the attached proposal obtained from Genesys on your behalf.<br/>';
            strText += 'This proposal pertains to the acquisition of commercial licenses and services for ' + quote.Sold_To_Name__r.Name + '.<br/>';
            strText += 'Thank you for the opportunity to share this information. We remain at your disposal to provide any further information.</p>';
            objQuote.Cover_Letter_Text__c = strText;
        }
        
        if(String.isBlank(objQuote.Executive_Summary__c)){
            String strText = End_User+ ' is experiencing rapid growth that has brought the company to a critical crossroad - the existing systems are no longer sufficient to support the company\'s expansion.'; 
            strText += End_User + ' needs to invest in a Customer Experience Platform to support the company\'s short and long term growth and deliver on the brand promise of delivering a great customer experience.<br/><br/>';
            strText += End_User + ' requires a scalable, Customer Experience Platform that will grow to meet future demands. The solution should therefore seamlessly integrate with existing systems to engage customers regardless of channel or touch point and create a true omnichannel experience. The ability to realize cost efficiencies by improving first contact resolution, automation of cross-channel workforce scheduling, and reduction of handle time will all play a role in delivering a truly transformative solution.<br/><br/>'; 
            strText += 'This proposal for a Customer Experience platform outlines how Genesys is uniquely qualified to meet these needs.';
            objQuote.Executive_Summary__c = strText;
        }
        
        if(String.isBlank(objQuote.What_you_want_to_Achieve__c)){
            String strText = End_User+'\'s objective is to find and engage a Partner who can implement a solution that is cost effective and includes the following:<br/>';
            strText += '<ul><li>Contact Center Communications Manager </li>';
            strText += '<li>Omnichannel Transformation</li>  ';
            strText += '<li>Workforce Management and Associated Toolsets</li>';
            strText += '<li>Knowledge Management Solution</li> ';
            strText += '<li>On-Premise Integration to scale to 5000+ seats</li></ul> ';
            strText += 'The solution, once implemented, will position '+ End_User + ' to set a new standard in customer care while leveraging your existing technology investments. <br/><br/>';
            objQuote.What_you_want_to_Achieve__c= strText;
        }
        
        if(String.isBlank(objQuote.Genesys_Solution__c)){
            String strText = 'The solution we propose for  '+ End_User + '  is built on a proven and scalable platform.  We understand your goal is not to simply install new technology but deliver world-class customer experience to your customers. Genesys proposes the CX Enterprise solution which is designed for large organizations that require highly scalable and customized contact center solutions. Key features of this solution are:<br/>';
            strText += '<ul><li>Provides the necessary requirements for  '+ End_User + ' , now and in the future, within a single platform</li>';
            strText += '<li>Full breadth and depth of capabilities for sophisticated, omnichannel contact centers, supporting unlimited agent deployments </li>';
            strText += '<li>Integrated self-service, analytics, workforce and back-office optimization for peak performance  </li>';
            strText += '<li>Built-in support for remote and branch workers to span locations and geographies</li>';
            strText += '<li>Advanced customization to meet your unique requirements</li>';
            strText += '<li>Advanced third-party system integration to leverage legacy investments </li>';
            strText += '<li>Unlimited scalability across geographies to meet the needs of large and dispersed contact centers</li></ul><br/>';
            strText += 'In implementing this solution, Genesys will: <br/>';
            strText += '<ul><li>Integrate with your existing systems and technology infrastructure</li>';
            strText += '<li>Deliver advanced reporting with deep insight into every aspect of your customer interactions</li>';
            strText += '<li>Provide 24x7 monitoring and support of the application infrastructure</li></ul>';
            
            objQuote.Genesys_Solution__c= strText;
        }
        
        if(String.isBlank(objQuote.Why_Genesys__c)){
            String strText = 'Genesys is the most advanced software and service provider in the customer experience market today. For over 20 years, Genesys has brought innovation to the customer experience market from software based CTI through cross-channel routing and continuing with advanced analytics, modern desktops, and the ever growing integrations that allow companies to define their branded experience, always with an eye towards standards and open platforms.<br/><br/>';
            strText += 'Genesys solutions are used around the world to deliver exceptional customer service. Gartner has rated Genesys a magic quadrant leader 5 years running for Customer Experience and Gartner Visionary Leader 3 years running. Over 40% of the Fortune 500 and 50% of global 200 companies use Genesys to improve their CX processes.  <br/> <br/>';
            strText += 'Genesys is the only solution that routes all customer interactions &#45;  voice, web, email, chat, social and IVR &#45; through a single routing engine.   Universal Routing can direct interactions from a wide variety of platforms, such as toll-free carrier switches, premise PBXs or ACDs, IVRs, IP PBXs, e-mail servers, web servers, and workflow servers. Genesys routing enables organizations to address performance metrics for its call answering service levels, abandon rates, and customer satisfaction measures.<br/><br/>';
            strText += 'Our spirit of innovation makes Genesys a future &#45; proof platform and our SLAs demonstrate our promise to you and our financial ties to this commitment - and to maintaining our leadership in the customer experience market.';
            objQuote.Why_Genesys__c= strText;
        }
        
        if(String.isBlank(objQuote.Genesys_Unique_Benefits__c)){
            String strText = '<ul><li>All-in-one platform consolidates the entire multi-vendor contact center stack </li>';
            strText += '<li>Operating seamlessly within your enterprise, our solution is designed to fully engage with your telephony, data and applications structure  </li>';
            strText += '<li>Solution offers a single point of configuration, management, routing and reporting</li>';
            strText += '<li>Outbound contact offers a single software dialing engine with virtually an unlimited scalability in both TDM and IP environments</li>';
            strText += '<li>World-class analytics embedded in the platform</li></ul>';
            objQuote.Genesys_Unique_Benefits__c= strText;
        }
        
        if(String.isBlank(objQuote.Impacting_the_lives_of_everyday_people__c)){
            String strText = 'Over 40% of the Fortune 500 and 50% of the Global 200 companies, use Genesys to improve their CX processes. <br/><br/>';
            strText += 'Innovative companies like Ticketmaster, BT and Emirates work with Genesys on a continuing bases to deliver solutions for their customer journeys. <br/><br/>';
            strText += 'We look forward to the opportunity to build a partnership with ' +  End_User + '<br/>';
            strText += 'You will gain the full advantage of our expertise and consulting guidance, grounded in more than two decades of experience in helping clients implement CX solutions.';
            objQuote.Impacting_the_lives_of_everyday_people__c= strText;
        }
        
        if(String.isBlank(objQuote.Proposal_Title__c)){
            objQuote.Proposal_Title__c='Genesys Enterprise Premise Solution';          
        }
        
        languages = new List<SelectOption>();
        SelectOption newOption = new SelectOption('en_US', 'English');
        languages.add(newOption);
        newOption = new SelectOption('fr', 'French');
        languages.add(newOption);
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
    
    // Handler for View Proposal button
    public void viewContract(){       
        try{
            update objQuote;
            if(objQuote.Contact__c==null){
                //objQuote.Contact__c.addError('Please select a contact');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select contact'));
                return;
            }
        }
        catch(Exception e){}
    }
}