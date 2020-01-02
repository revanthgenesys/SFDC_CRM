@isTest(SeeAllData = true)
private class DealSupport_Test
{
    
    static testmethod void TestDealsupportyes(){
      
            //Test.startTest();
            
            // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
     
              Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            insert runAsUser;
           // runAsUser.Bypass_Triggers__c = true;
           // update runAsUser;
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account12345678', Status__c = 'Active',Street1__c = 'test',City__c = 'test',Industry__c='test',Phone='1234456788',Type_of_Commerce__c= 'test',ZipCode__c = '123345');
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                insert objTestAccount;
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                
                insert objTestOppty;
            
            Id idDSR;
            Deal_Support__c objTestDS = new Deal_Support__c();
            objTestDS.Opportunity__c = objTestOppty.Id;
            objTestDS.Support_Area__c = 'Business Consulting';
            objTestDS.Request_Type__c = 'Business Consulting Inquiry';
            objTestDS.Subject__c = 'test';
            objTestDS.Description__c = 'test';
            objTestDS.Org_ID__c = 'test';
            objTestDS.Primary_Churn_Reason__c = 'Platform';
            objTestDS.Notification_Date__c = system.today();
            objTestDS.Official_Cancelation_Date__c = system.today();    
            insert objTestDS;
            
            PageReference pageRef1 = Page.DealSupportQuery;
            Test.setCurrentPage(pageRef1);
            ApexPages.currentPage().getParameters().put('id', objTestDS.Id);
            ApexPages.currentPage().getParameters().put('supportarea', 'POR Review');  
            ApexPages.currentPage().getParameters().put('type', 'test');
            ApexPages.currentPage().getParameters().put('oppId', objTestOppty.Id);
                  ApexPages.currentPage().getParameters().put('isFromPSAttachments', 'test');
            ApexPages.currentPage().getParameters().put('psDSRId', objTestDS.Id);
            
                 DealSupportQueryController objDSQCtrl1 = new DealSupportQueryController(); 
           
          
                
            }
        
    }
    static testmethod void testDealSupport()
    {
        try
        {
            //Test.startTest();
            
            // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            insert runAsUser;
           // runAsUser.Bypass_Triggers__c = true;
           // update runAsUser;
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account12345678', Status__c = 'Active',Street1__c = 'test',City__c = 'test',Industry__c='test',Phone='1234456788',Type_of_Commerce__c= 'test',ZipCode__c = '123345');
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                insert objTestAccount;
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                
                insert objTestOppty;
            
            Id idDSR;
            Deal_Support__c objTestDS = new Deal_Support__c();
            objTestDS.Opportunity__c = objTestOppty.Id;
            objTestDS.Support_Area__c = 'Business Consulting';
            objTestDS.Request_Type__c = 'Business Consulting Inquiry';
            objTestDS.Subject__c = 'test';
            objTestDS.Description__c = 'test';
            objTestDS.Org_ID__c = 'test';
            objTestDS.Primary_Churn_Reason__c = 'Platform';
            objTestDS.Notification_Date__c = system.today();
            objTestDS.Official_Cancelation_Date__c = system.today();    
            insert objTestDS;
            
            PageReference pageRef1 = Page.DealSupportQuery;
            Test.setCurrentPage(pageRef1);
            ApexPages.currentPage().getParameters().put('id', objTestDS.Id);
            ApexPages.currentPage().getParameters().put('supportarea', 'POR Review');  
            ApexPages.currentPage().getParameters().put('type', 'test');
            ApexPages.currentPage().getParameters().put('oppId', objTestOppty.Id);
            
                 DealSupportQueryController objDSQCtrl1 = new DealSupportQueryController(); 
            //Test.setCurrentPage(new PageReference('/apex/DealSupportQuery?id=objTestDS.Id&supportarea=Product Management&type=test&oppId=' + objTestOppty.Id));
            
            PageReference pageRef = Page.DealSupportQuery;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', objTestDS.Id);
            ApexPages.currentPage().getParameters().put('supportarea', 'Product Management');  
            ApexPages.currentPage().getParameters().put('type', 'test');
            ApexPages.currentPage().getParameters().put('oppId', objTestOppty.Id);
            //ApexPages.currentPage().getParameters().put('strSupportArea', 'POR Review');
                 
         /*   ApexPages.currentPage().getParameters().put('isFromPSAttachments', 'test');
            ApexPages.currentPage().getParameters().put('psDSRId', objTestDS.Id);*/
            
            system.debug('++++objTestDS.Id++++'+objTestDS.Id);
            
             Attachment objAtt=new Attachment();
            objAtt.Description='Discovery Plan';
            objAtt.Name='Test';
            objAtt.ParentId=objTestDS.Id;
            objAtt.Body=Blob.valueOf('Test');
            insert objAtt; 
            
            DealSupportQueryController objDSQCtrl = new DealSupportQueryController();             
            objDSQCtrl.strpsDSRId = objTestDS.Id;  
            objDSQCtrl.objDS.Id = objTestDS.Id;  
            objDSQCtrl.sAttachmentId = objAtt.id;       
            objDSQCtrl.objDS.Subject__c = 'test';
            objDSQCtrl.objDS.Request_Type__c = 'test';
            objDSQCtrl.save();
            objDSQCtrl.submit();            
            objDSQCtrl.UploadFile();
               
            objDSQCtrl.objDS.Request_Type__c = 'test';           
            objDSQCtrl.save();
            objDSQCtrl.submit();
            objDSQCtrl.objDS.Description__c = 'test';
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;
            objDSQCtrl.save();
            objDSQCtrl.submit();
                
            objDSQCtrl.UploadFile();
            objDSQCtrl.objDS.Solution_Category__c = 'Inbound';
            objDSQCtrl.objDS.Product__c = 'Inbound Voice';
            objDSQCtrl.objDS.Request_Type__c = 'End of Life information';
            objDSQCtrl.save();
            objDSQCtrl.submit();
                
                
            objDSQCtrl.fileName ='test';
            objDSQCtrl.fileBody =Blob.valueof('test');
            objDSQCtrl.UploadFile();
            idDSR = objTestDS.Id;
            System.debug('??? ' + idDSR);
            objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Request_Type__c = 'Product feature/functionality enquiry';
            objDSQCtrl.save();
            objDSQCtrl.submit();
            objDSQCtrl.UploadFile();
            objDSQCtrl.objDS.Product__c = 'SBC';
            objDSQCtrl.save();
            objDSQCtrl.submit();
            
            objDSQCtrl.objDS.PS_SMART_DSR__c = true;
            objDSQCtrl.UploadFile();
            //objDSQCtrl.DeleteAttachment();
            objDSQCtrl.GetAttachments();
            objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Country_Name__c = 'Brazil';
            objDSQCtrl.objDS.Support_Area__c = 'Finance';
            objDSQCtrl.objDS.Request_Type__c = 'Order Management Cloud';
            objDSQCtrl.save();
            objDSQCtrl.submit();
                
            objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Country_Name__c = 'Brazil';
            objDSQCtrl.objDS.Support_Area__c = 'Product Management';
            objDSQCtrl.objDS.Request_Type__c = 'Data Protection';
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;
            objDSQCtrl.save();
            objDSQCtrl.submit();
                
            objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Country_Name__c = 'Brazil';
            objDSQCtrl.objDS.Support_Area__c = 'Tools/Systems Support';
            objDSQCtrl.objDS.Request_Type__c = 'Data Management';
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;
            objDSQCtrl.save();
            objDSQCtrl.submit();
                
         
                objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Country_Name__c = 'Brazil';
            objDSQCtrl.objDS.Support_Area__c = 'Sales Ops';
            objDSQCtrl.objDS.Request_Type__c = 'Data Management';
            objDSQCtrl.objDS.Focus_Area__c = 'Contact';
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;
            objDSQCtrl.save();
            objDSQCtrl.submit();
                
                
            objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Country_Name__c = 'Brazil';
            objDSQCtrl.objDS.Support_Area__c = 'Product Management';
            objDSQCtrl.objDS.Request_Type__c = 'Product Idea Lab';
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;
            objDSQCtrl.save();
            objDSQCtrl.submit();
                
                
            objDSQCtrl.objDS.Id = null;   
            objDSQCtrl.objDS.Support_Area__c = 'Subscription PureSuccess';
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;
             objDSQCtrl.save();
            objDSQCtrl.submit();
                
                        
            
                
            objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Support_Area__c = 'Pricing';
            objDSQCtrl.objDS.Request_Type__c = 'On Premise Pricing';
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;
            objDSQCtrl.save();
            objDSQCtrl.submit();
                
            objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Support_Area__c = 'Business Consulting';
            objDSQCtrl.objDS.Request_Type__c = 'Business Consulting Inquiry';
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;
            objDSQCtrl.save();
            objDSQCtrl.submit();
            
            objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Support_Area__c = 'Play Support';
            objDSQCtrl.objDS.Request_Type__c = 'Play Assistance';
            objDSQCtrl.objDS.Primary_Play__c = '2019 Play 3 Digital Service';
            objDSQCtrl.objDS.P2P_Region__c = 'EMEA';
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;
            objDSQCtrl.save();
            objDSQCtrl.submit();
           
                
                
            objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;
            objDSQCtrl.objDS.Support_Area__c = 'Customer Care';
            objDSQCtrl.objDS.Request_Type__c = 'Compliance';
          //  objDSQCtrl.save();
           // objDSQCtrl.submit();
            objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Country_Name__c = 'United States';
            objDSQCtrl.objDS.Support_Area__c = 'Deal Factory';
            objDSQCtrl.objDS.Request_Type__c = 'Net Pricing';
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;          
            objDSQCtrl.save();
           // objDSQCtrl.submit();
           // objDSQCtrl.objDS.Region__c = 'xyz';
           // objDSQCtrl.save();
          //  objDSQCtrl.submit();
           // objDSQCtrl.objDS.Region__c = 'NA';
           // objDSQCtrl.objDS.Support_Area__c = 'Product Management';
           // objDSQCtrl.objDS.Request_Type__c = 'EOL Information';
          //  objDSQCtrl.save();
          //  objDSQCtrl.submit();
           // objDSQCtrl.saveBtnHandler();
             Test.startTest();  
           /* objDSQCtrl.objDS.Region__c = 'NA';
            objDSQCtrl.objDS.Support_Area__c = 'Transactional Help';
            objDSQCtrl.strIsTransDSR = 'yes';
            objDSQCtrl.save();
            objDSQCtrl.submit();
            objDSQCtrl.saveBtnHandler();*/
                
            objDSQCtrl.objDS.Requested_Action__c = 'Inactivate Line of Business';
            objDSQCtrl.objDS.Org_ID__c = 'test';
            objDSQCtrl.objDS.Primary_Churn_Reason__c = 'test';
            objDSQCtrl.objDS.Notification_Date__c = System.today();
            objDSQCtrl.objDS.Official_Cancelation_Date__c = System.today();
            objDSQCtrl.save();
            objDSQCtrl.submit();
                
            DealSupportQueryController.GetPSDSREmailTarget('EMEA','Premise');
            objDSQCtrl.GetPSDSR_Documents();
            objDSQCtrl.SetPSDSRReturnParams();
            objDSQCtrl.AddPSRDocuments();
          
            
            string[]semai = new string[1];
            semai[0]='aa@aa.com';
            DealSupportQueryController.SendEmailByTemplate(UserInfo.GetUserId(),'Deal Support Request for Support User- VF', objDSQCtrl.objDS.Id,semai);
              objDSQCtrl.CancelPSDSR();
            
            objDSQCtrl.DeleteAttachment();
            
            Test.setCurrentPageReference(new PageReference('/apex/DealSupportQuery?supportarea=Deal Factory&type=test&accId=' + objTestAccount.Id));
            ApexPages.currentPage().getParameters().put('oppId','');
            objDSQCtrl = new DealSupportQueryController();           
            objDSQCtrl.save();
            objDSQCtrl.submit();
            objDSQCtrl.cancel();
            
            //Deal_Support__c objTestDS = new Deal_Support__c(Id = idDSR,Support_Email__c = 'someaddress@email.com',Support_Email2__c = 'anotheraddress@email.com');
           
            
               objTestDS.Support_Email__c = 'someaddress@email.com';
               objTestDS.Support_Email2__c = 'anotheraddress@email.com';  
               update objTestDS;
           
           
                
            Test.setCurrentPageReference(new PageReference('/apex/DealSupport?id=' + objTestOppty.Id));
            ApexPages.currentPage().getParameters().put('objid', objTestOppty.Id);
            apexPages.StandardController sc = new ApexPages.StandardController(objTestDS);
            DealSupportExt objDSE = new DealSupportExt();
            DealSupportExt objDeal = new DealSupportExt(sc);
            
            Test.setCurrentPageReference(new PageReference('/apex/DealSupport?id=' + objTestAccount.Id));
            objDSE = new DealSupportExt();
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

            email.subject = 'DSR Test';
            email.fromAddress = 'someaddress@email.com';
            email.htmlBody = 'awesome<br/>ref:' + objTestDS.Id + ':ref';

            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] { attachment };

            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body = 'my attachment text';
            attachmenttext.fileName = 'textfiletwo3.txt';
            attachmenttext.mimeTypeSubType = 'texttwo/plain';
            email.textAttachments =   new Messaging.InboundEmail.TextAttachment[] { attachmenttext };

            DealSupportEmailCapturer  objDSEC = new DealSupportEmailCapturer();
            objDSEC.handleInboundEmail(email,env);
            email.toAddresses = new List<String>{'test@email.com'};
            objDSEC.handleInboundEmail(email,env);
            
            Note objNote = new Note();
            objNote.ParentId = idDSR;
            objNote.Title = 'title';
            objNote.Body = 'body';
            insert objNote;
                
            /*Deal_Support__c testDS = new Deal_Support__c();
            testDS.Opportunity__c = objTestOppty.Id;
            insert testDS;*/
            
            LatestNoteOnDSRController objLNODSRC = new LatestNoteOnDSRController();
            objLNODSRC.DealSupportId = idDSR;
            objLNODSRC.DealSupportId = null;
            objLNODSRC = new LatestNoteOnDSRController();
            //objLNODSRC.DealSupportId = [SELECT Id FROM Deal_Support__c WHERE Id != :idDSR AND Opportunity__c = :objTestOppty.Id LIMIT 1].Id;
			List<Deal_Support__c> DS = [SELECT Id FROM Deal_Support__c WHERE Id != :idDSR AND Opportunity__c = :objTestOppty.Id LIMIT 1];
			 if(DS.size()>0)
			 objLNODSRC.DealSupportId = DS[0].id;
	            //End chages done by aparna
            objTestDS.Country_Name__c = 'Brazil';
            objTestDS.Support_Area__c = 'Finance';
            objTestDS.Request_Type__c = 'Order Management Cloud';
            update objTestDS;
         /*   try
            {
                objTestDS.Support_Area__c = 'Product Management';
                objTestDS.Request_Type__c = 'test';
                objTestDS.Solution_Category__c = 'Inbound';
                objTestDS.Product__c = 'xyz';
                update objTestDS;
            }
            catch(Exception ex)
            {
                System.assert(ex.getMessage().containsIgnoreCase('Please select Solution category and product'));
            } */
           /* objTestDS.Solution_Category__c = 'Inbound';
            objTestDS.Product__c = 'Inbound Voice';
            objTestDS.Request_Type__c = 'End of Life information';
            update objTestDS;
            objTestDS.Support_Area__c = 'Pricing';
            objTestDS.Request_Type__c = 'On Premise Pricing';
            update objTestDS;
            objTestDS.Support_Area__c = 'Product Management';
            objTestDS.Product__c = 'Inbound Voice';
            objTestDS.Request_Type__c = 'Product feature/functionality enquiry';
            update objTestDS;
            objTestDS.Support_Area__c = 'Business Consulting';
            objTestDS.Request_Type__c = 'Business Consulting Inquiry';
            update objTestDS;*/
            try
            {
                objTestDS.Support_Area__c = 'Product Management';
                objTestDS.Solution_Category__c = 'Inbound';
                objTestDS.Product__c = 'SBC';
                objTestDS.Request_Type__c = 'Product feature/functionality enquiry';
                update objTestDS;
            }
            catch(Exception ex)
            {
                System.assert(ex.getMessage().containsIgnoreCase('Product not supported'));
            }
            try
            {
                /*objTestDS.Support_Area__c = 'Customer Care';
                objTestDS.Request_Type__c = 'Compliance';
                update objTestDS;*/
                objTestDS.Country_Name__c = 'United States';
                objTestDS.Support_Area__c = 'Deal Desk';
                objTestDS.Request_Type__c = 'Net Pricing';
                update objTestDS;
            
                objTestDS.Region__c = 'NA';
                objTestDS.Support_Area__c = 'xyz';
                update objTestDS;
            }
            catch(Exception ex)
            {
                //System.assert(ex.getMessage().containsIgnoreCase('Support Area not supported'));
            }
            
            Test.setCurrentPageReference(new PageReference('/apex/DealSupport?oppId=' + objTestOppty.Id));
            DealSupportRequestController objDSRC = new DealSupportRequestController();
            
            Test.setCurrentPageReference(new PageReference('/apex/DealSupport?accId=' + objTestAccount.Id));
            ApexPages.currentPage().getParameters().put('oppId',null);
            objDSRC = new DealSupportRequestController();
            ApexPages.currentPage().getParameters().put('accId',null);
            objDSRC = new DealSupportRequestController();
            }
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
    
    static testmethod void testDealSupport2()
    {
        try
        {
            Test.startTest();
            
            // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            insert runAsUser;
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account12345678', Status__c = 'Active', Street1__c = 'test',City__c = 'test',Industry__c='test',Phone='1234456788',Type_of_Commerce__c= 'test',ZipCode__c = '123345' );
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                insert objTestAccount;
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                insert objTestOppty;
            }
            Id idDSR;
            
            Test.setCurrentPagereference(new PageReference('/apex/DealSupportQuery?supportarea=ININ Sales Support&type=Business Consultant Support&oppId=' + objTestOppty.Id));
            DealSupportQueryController objDSQCtrl = new DealSupportQueryController();            
            
            objDSQCtrl.strSupportArea = 'ININ Sales Support';
            objDSQCtrl.strRequestType  ='Business Consultant Support';
            objDSQCtrl.objDS.Support_Area__c = 'ININ Sales Support';
            objDSQCtrl.objDS.Subject__c = 'test';
            objDSQCtrl.objDS.Request_Type__c = 'Business Consultant Support';
            objDSQCtrl.objDS.Offering_Type__c = 'Pure Engage';
            objDSQCtrl.objDS.Region__c = 'NA';
          
            objDSQCtrl.submit();   
            
            
            objDSQCtrl.objDS.Support_Area__c = 'Value Consulting';
            objDSQCtrl.objDS.Subject__c = 'test';
            objDSQCtrl.objDS.Request_Type__c = 'Value Consulting Inquiry';
            objDSQCtrl.objDS.Offering_Type__c = 'Pure Engage';
            objDSQCtrl.objDS.Region__c = 'NA';
            objDSQCtrl.submit(); 
            objDSQCtrl.objDS.Support_Area__c = 'Finance – Field Finance';
            objDSQCtrl.objDS.Subject__c = 'test';
            objDSQCtrl.objDS.Request_Type__c = 'Field Finance';
            objDSQCtrl.objDS.Offering_Type__c = 'Pure Engage';
            objDSQCtrl.objDS.Region__c = 'NA';
            objDSQCtrl.submit(); 
             
           objDSQCtrl.FetchSWATTeam('Business Consultant Support' ,'NA','Pure Engage');
             objDSQCtrl.objDS.Support_Area__c = 'Transaction Help';
            objDSQCtrl.objDS.Subject__c = 'test';
            objDSQCtrl.objDS.Request_Type__c = 'Create a Quote';
            objDSQCtrl.objDS.Offering_Type__c = 'Pure Engage';
            objDSQCtrl.objDS.Region__c = 'NA';
            objDSQCtrl.submit(); 
             objDSQCtrl.FetchSWATTeam('Transaction Help' ,'NA','Pure Engage');
             
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
    //Added by navaneetha
    static testmethod void testdeactiveemail()
    {
        try
        {
            Test.startTest();
            
            // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            insert runAsUser;
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account12345678', Status__c = 'Active' , Street1__c = 'test',City__c = 'test' ,Industry__c='test',Phone='1234456788',Type_of_Commerce__c= 'test',ZipCode__c = '123345');
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                objTestAccount.Ownerid = userinfo.getuserid();
                objTestAccount.CSM_Account_Owner__c = userinfo.getuserid();                     
                insert objTestAccount;
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                objTestOppty.AE_Name__c = '005U0000001uZZA'; // CRM Sales Ops Sales user
                
                insert objTestOppty;
            }
            Id idDSR;           
            Test.setCurrentPagereference(new PageReference('/apex/DealSupportQuery?supportarea=Sales Ops&type=Data Management&accId=' + objTestAccount.Id));
            DealSupportQueryController objDSQCtrl = new DealSupportQueryController();    
            objDSQCtrl.objDS.Requested_Action__c  = 'Inactivate Line of Business';
            objDSQCtrl.objDS.Support_Area__c = 'Sales Ops';
            objDSQCtrl.objDS.Request_Type__c = 'Data Management';           
            objDSQCtrl.objDS.Subject__c = 'test';
            objDSQCtrl.objDS.Description__c = 'test';           
            objDSQCtrl.objDS.Offering_Type__c = 'Pure Engage';
            objDSQCtrl.objDS.Region__c = 'NA';
            objDSQCtrl.objDS.Primary_Churn_Reason__c = 'Implementation';
            objDSQCtrl.objDS.Secondary_Churn_Reason__c = 'Platform';
            objDSQCtrl.objDS.Line_of_Business__c = 'PureConnect Cloud';
            objDSQCtrl.objDS.Competitor_Replacing_Genesys__c = 'Unknown';
            objDSQCtrl.objDS.Owner_Approval__c = 'Channel Manager';
            objDSQCtrl.objDS.Completion_Status__c = 'Completed';
            objDSQCtrl.objDS.Requester__c = objTestAccount.Ownerid;
            objDSQCtrl.objDS.Focus_Area__c = 'Account';  
            objDSQCtrl.objDS.Description__c = 'test';
            objDSQCtrl.objDS.Notification_Date__c = System.now().date();
            objDSQCtrl.objDS.Official_Cancelation_Date__c = System.now().date();
            objDSQCtrl.objDS.Trial_Evaluation__c  = 'yes';
            objDSQCtrl.objDS.Org_ID__c = '123';
            objDSQCtrl.inactivationemailmetod(); 
            
            objDSQCtrl.objDS.Requester__c = userinfo.getuserid();
            objDSQCtrl.objDS.Trial_Evaluation__c  = 'No';
            objDSQCtrl.inactivationemailmetod();  
            
              
            
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
 // Ends
    /* static testmethod void cancelmail(){
          Test.startTest();
           Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            insert runAsUser;
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account12345678', Status__c = 'Active' , Street1__c = 'test',City__c = 'test',Industry__c='test',Phone='1234456788',Type_of_Commerce__c= 'test',ZipCode__c = '123345');
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                insert objTestAccount;
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                objTestOppty.AE_Name__c = '005U0000001uZZA'; // CRM Sales Ops Sales user
                
                insert objTestOppty;
            
            Id idDSR;
            Deal_Support__c objTestDS = new Deal_Support__c();
            objTestDS.Opportunity__c = objTestOppty.Id;
            objTestDS.Support_Area__c = 'Sales Ops';
            objTestDS.Request_Type__c = 'Data Management';
            objTestDS.Subject__c = 'test';
            objTestDS.Description__c = 'test';
            objTestDS.Requested_Action__c  = 'Inactivate Line of Business';
            objTestDS.Offering_Type__c = 'Pure Engage';
            objTestDS.Region__c = 'NA';
            objTestDS.Focus_Area__c = 'Account'; 
            
            
            insert objTestDS;
            
            
            PageReference pageRef = Page.dealsupportAccinactive;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('DSId', objTestDS.Id);  
            ApexPages.currentPage().getParameters().put('ResponseCode', 'Approved');  
            dealsupportAccinactivecont dsracc = new dealsupportAccinactivecont();
            dsracc.InitPage();
            dsracc.testre();
             
            }
          Test.stoptest();
         
     }  */
    static testmethod void testPSDSRs()
    {
        try
        {
            Test.startTest();
            
            // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            insert runAsUser;
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account12345678', Status__c = 'Active' , Street1__c = 'test',City__c = 'test',Industry__c='test',Phone='1234456788',Type_of_Commerce__c= 'test',ZipCode__c = '123345');
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                insert objTestAccount;
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                objTestOppty.AE_Name__c = '005U0000001uZZA'; // CRM Sales Ops Sales user
                
                insert objTestOppty;
            
            Id idDSR;
            Deal_Support__c objTestDS = new Deal_Support__c();
            objTestDS.Opportunity__c = objTestOppty.Id;
            objTestDS.Support_Area__c = 'Professional Services';
            objTestDS.Request_Type__c = 'Budgetary Estimate (BE)';
            objTestDS.Subject__c = 'test';
            objTestDS.Description__c = 'test';
            insert objTestDS;
            
            
            PageReference pageRef = Page.DealSupportQuery;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', objTestDS.Id);
            ApexPages.currentPage().getParameters().put('supportarea', 'Professional Services');  
            ApexPages.currentPage().getParameters().put('type', 'Budgetary Estimate (BE)');
            ApexPages.currentPage().getParameters().put('oppId', objTestOppty.Id);
            //ApexPages.currentPage().getParameters().put('isFromPSAttachments', 'test');
            //ApexPages.currentPage().getParameters().put('psDSRId', objTestDS.Id);
            
            system.debug('++++objTestDS.Id++++'+objTestDS.Id);
            
             Attachment objAtt=new Attachment();
            objAtt.Description='Discovery Plan';
            objAtt.Name='Test';
            objAtt.ParentId=objTestDS.Id;
            objAtt.Body=Blob.valueOf('Test');
            insert objAtt; 
            
            DealSupportQueryController objDSQCtrl = new DealSupportQueryController();             
            objDSQCtrl.strpsDSRId = objTestDS.Id;  
            objDSQCtrl.objDS.Id = objTestDS.Id;  
            objDSQCtrl.sAttachmentId = objAtt.id;       
            objDSQCtrl.objDS.Subject__c = 'test';
            objDSQCtrl.objDS.Request_Type__c = null;
            objDSQCtrl.save();
            objDSQCtrl.submit();            
            objDSQCtrl.UploadFile();
            objDSQCtrl.objDS.Request_Type__c = 'test';           
            objDSQCtrl.save();
            objDSQCtrl.submit();
            objDSQCtrl.objDS.Description__c = 'test';
            objDSQCtrl.objDS.Opportunity__c = objTestOppty.Id;
            objDSQCtrl.save();
            objDSQCtrl.submit();
            objDSQCtrl.UploadFile();
            objDSQCtrl.objDS.Solution_Category__c = 'Inbound';
            objDSQCtrl.objDS.Product__c = 'Inbound Voice';
            objDSQCtrl.objDS.Request_Type__c = 'End of Life information';
            objDSQCtrl.save();
            objDSQCtrl.submit();
            objDSQCtrl.fileName ='test';
            objDSQCtrl.fileBody =Blob.valueof('test');
            objDSQCtrl.UploadFile();
            idDSR = objDSQCtrl.objDS.Id;
            System.debug('??? ' + idDSR);
            objDSQCtrl.objDS.Id = null;
            objDSQCtrl.objDS.Request_Type__c = 'Product feature/functionality enquiry';
            objDSQCtrl.save();
            objDSQCtrl.submit();
            objDSQCtrl.UploadFile();
            objDSQCtrl.objDS.Product__c = 'SBC';
            objDSQCtrl.save();
            objDSQCtrl.submit();
            
            objDSQCtrl.objDS.PS_SMART_DSR__c = true;
            objDSQCtrl.UploadFile();
            //objDSQCtrl.DeleteAttachment();
            objDSQCtrl.GetAttachments();
            objDSQCtrl.objDS.Region__c = 'NA';
            objDSQCtrl.objDS.Support_Area__c = 'Professional Services';
            objDSQCtrl.objDS.Request_Type__c = 'Budgetary Estimate (BE)';
            objDSQCtrl.objDS.PS_SMART_DSR__c = true;
            objDSQCtrl.save();
            objDSQCtrl.submit();
            objDSQCtrl.saveBtnHandler();
            
            DealSupportQueryController.GetPSDSREmailTarget('EMEA','Premise');
            DealSupportQueryController.GetPSDSREmailTarget('NA','');
            DealSupportQueryController.GetPSDSRAutoAssignCSDUserID('EMEA', 'Premise', objDSQCtrl.strpsDSRId);
            DealSupportQueryController.GetPSDSRAutoAssignCSDUserID('NA', 'PureCloud', objDSQCtrl.strpsDSRId);
            objDSQCtrl.GetPSDSR_Documents();
            objDSQCtrl.SetPSDSRReturnParams();
            objDSQCtrl.AddPSRDocuments();
            objDSQCtrl.CancelPSDSR();
            objDSQCtrl.wer();
            objDSQCtrl.duedateupdate();
            objTestDS.Support_Email__c = 'someaddress@email.com';
            objTestDS.Support_Email2__c = 'anotheraddress@email.com';  
            update objTestDS;
                
            Test.setCurrentPageReference(new PageReference('/apex/DealSupport?id=' + objTestOppty.Id));
            ApexPages.currentPage().getParameters().put('objid', objTestOppty.Id);
            apexPages.StandardController sc = new ApexPages.StandardController(objTestDS);
            DealSupportExt objDSE = new DealSupportExt();
            DealSupportExt objDeal = new DealSupportExt(sc);
            
            Test.setCurrentPageReference(new PageReference('/apex/DealSupport?id=' + objTestAccount.Id));
            objDSE = new DealSupportExt();
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

            email.subject = 'DSR Test';
            email.fromAddress = 'someaddress@email.com';
            email.htmlBody = 'awesome<br/>ref:' + objTestDS.Id + ':ref';

            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body = 'my attachment text';
            attachmenttext.fileName = 'textfiletwo3.txt';
            attachmenttext.mimeTypeSubType = 'texttwo/plain';
            email.textAttachments =   new Messaging.InboundEmail.TextAttachment[] { attachmenttext };

            DealSupportEmailCapturer  objDSEC = new DealSupportEmailCapturer();
            objDSEC.handleInboundEmail(email,env);
            email.toAddresses = new List<String>{'test@email.com'};
            objDSEC.handleInboundEmail(email,env);
            
            Note objNote = new Note();
            objNote.ParentId = idDSR;
            objNote.Title = 'title';
            objNote.Body = 'body';
            insert objNote;
            
            Test.setCurrentPageReference(new PageReference('/apex/DealSupport?oppId=' + objTestOppty.Id));
            DealSupportRequestController objDSRC = new DealSupportRequestController();
            
            Test.setCurrentPageReference(new PageReference('/apex/DealSupport?accId=' + objTestAccount.Id));
            ApexPages.currentPage().getParameters().put('oppId',null);
            objDSRC = new DealSupportRequestController();
            ApexPages.currentPage().getParameters().put('accId',null);
            objDSRC = new DealSupportRequestController();
            }
            Test.stopTest();
        }
        catch(CalloutException e){}
    }

}