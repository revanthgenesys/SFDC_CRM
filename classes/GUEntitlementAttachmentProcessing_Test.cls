//Test class of class GUEntitlementAttachmentProcessing
//It is used in GU Entitlement Email Service


@isTest(SeeAllData = true)
private class GUEntitlementAttachmentProcessing_Test
{

              static Contact testContact;
    static testmethod void testOnServiceEntitlementCtrlNew()
    {
        try
        {
            Test.startTest();
            
            
            //Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            List<Account>list_Acc = new List<Account>();
            List<Address__c>list_Address = new List<Address__c>();
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            Map<ID, Opportunity> opplst;
            //List<Address__c>list_Address = new List<Address__c>();
            RecordType objRecType = [select id,name from RecordType where name =: 'EMG - Customer Record Type'];
            RecordType objRecType_Opp = [select id,name from RecordType where name =: 'GEN - Opportunity Record Type'];
            
            

           // System.runAs(runAsUser[0]) 
            //{
                
                List<Account> list_Accounts = TestUtil.createAccounts(1,false);
                list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
                insert list_Accounts;
                
                Contact testContact = new Contact();
                testContact.AccountId = list_Accounts[0].Id;
                testContact.All_Service_Elements_Access__c = true;
                testContact.Self_Service_Elements_Access__c = true;
                testContact.LastName = 'Pankaj001';
                testContact.PureSuccess_Main_Contact__c = true;
                insert testContact;
                
                Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
                objOpportunity.Lines_of_Businesses__c = 'PureCloud';
                insert objOpportunity;
                
                
                
                List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'PureSuccess_Services'];
                Case cs = new Case(status='Open',subject='test', ContactId = testContact.Id,                      
                               recordtypeid = rectp[0].id);                        
                insert cs;
              
                List<Product2> list_Products = TestUtil.createProducts(5, false);
                System.assert(list_Products.size() == 5);
                for(Product2 objProduct :  list_Products){
                    objProduct.APN_Number__c = 'APNABC'+objProduct.Name;
                }
                insert list_Products;
                System.assert(list_Products[0].Id != NULL);
              
                Product_Group__c prdgrp = new Product_group__c();
              
              prdgrp.Name = 'Test';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              Order__c ord_1 = new Order__c();
              ord_1.Name = 'Test Order';
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = objOpportunity.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'USD';
              insert ord_1;
              
              List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, ord_1.Id, true);
              List<ServiceContract> list_SC = TestUtil.createServiceContracts2(1, false,list_Accounts[0]);
              list_SC[0].End_User_Name__c = list_Accounts[0].id;
              insert list_SC;
              
              Token_Allocations__c tkAll = new Token_Allocations__c();
              tkAll.Account__c = list_Accounts[0].id;
              tkAll.Order__c = ord_1.Id;
              tkAll.Product__c = list_Products[0].id;
              tkAll.Product_Group__c = prdgrp.id;
              tkAll.Tokens__c = 500;
              //tkAll.Currency__c = 'USD';
              tkAll.Token_status__c = 'Allocated';
              tkAll.Contract_No__c = list_SC[0].Name;
              tkAll.allocation_type__c = 'GU Training Units';
              insert tkAll;
              
              Token_Consumption__c tknc = new Token_Consumption__c();
              tknc.Product__c = list_Products[0].Id;
              tknc.Status__c = 'In Progress';
              tknc.Tokens__c = 10;
              tknc.Token_Allocation__c = tkAll.Id;
              insert tknc;
               List<Pure_Success_Package__c> pSuccessPkg = new List<Pure_Success_Package__c>();
               List<Token_Allocations__c> tknlst = new List<Token_Allocations__c>();
               List<Package_Services__c> pkgSrv = new List<Package_Services__c>();
               List<Product_Group_Item__c> pdgrpItm = new List<Product_Group_Item__c>();
               List<Token_Consumption__c> tknc1 = new List<Token_Consumption__c>();
               List<Contact> lstcont = new List<Contact>();
               
               Pure_Success_Package__c ppkg = new Pure_Success_Package__c();
               ppkg.Account__c = list_Accounts[0].id;
               ppkg.Product__c = list_Products[0].id;  
               insert ppkg;
               
                Package_services__c pkg = new Package_services__c ();
                pkg.Case__c = cs.id;
                pkg.Status__c = 'Consumed';        
                pkg.PureSuccess_Package__c = ppkg.id;
                insert pkg;
                
                Pure_Success_Package__c ppkg1 = new Pure_Success_Package__c();
               ppkg1.Account__c = list_Accounts[0].id;
               ppkg1.Product__c = list_Products[0].id;  
               insert ppkg1;
               
                Package_services__c pkg1 = new Package_services__c ();
                pkg1.Case__c = cs.id;
                pkg1.Status__c = 'Allocated';        
                pkg1.PureSuccess_Package__c = ppkg1.id;
                insert pkg1;
                
               Pure_Success_Package__c ppkg2 = new Pure_Success_Package__c();
               ppkg2.Account__c = list_Accounts[0].id;
               ppkg2.Product__c = list_Products[0].id;
               ppkg2.Package_Type__c = 'A la Carte';
               insert ppkg2;
               
                Package_services__c pkg2 = new Package_services__c ();
                pkg2.Case__c = cs.id;
                pkg2.Status__c = 'Consumed';        
                pkg2.PureSuccess_Package__c = ppkg2.id;
                insert pkg2;
                
                Pure_Success_Package__c ppkg3 = new Pure_Success_Package__c();
               ppkg3.Account__c = list_Accounts[0].id;
               ppkg3.Product__c = list_Products[0].id;
               ppkg3.Package_Type__c = 'A la Carte';
               insert ppkg3;
               
                Package_services__c pkg3 = new Package_services__c ();
                pkg3.Case__c = cs.id;
                pkg3.Status__c = 'Allocated';        
                pkg3.PureSuccess_Package__c = ppkg3.id;
                insert pkg3;
                
                pkg3.Status__c= 'In Progress';
                pkg3.Case__c = cs.id;
                
                update pkg3;
                
                
                
                GUEntitlementAttachmentProcessing objGU = new GUEntitlementAttachmentProcessing();
                
                // Create a new email, envelope object and Attachment
                   Messaging.InboundEmail email = new Messaging.InboundEmail();
                   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                   Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
                
                   email.subject = 'test';
                   env.fromAddress = 'user@acme.com';
                
                   // set the body of the attachment
                   string strData = 'EntitlementID,EndUser,PartnerName,EntitlementName,EntitlementNumber,EntitlementType,StudentName,StudentEmail,CourseStartDate,CourseEndDate,Certified,CertificationExpiration,GUVoucherUsed,OrderName,Order,Status,CancellationDate,CourseLocation,EndCustomerName\n';
                   strData += ',,,New Course1,10004,PISP,Vinay Ravula,vinay.ravula@genesys.com,1/1/2018,4/4/2018,false,,10,Test Order,,,,,Indianapolis';
                   
                   inAtt.body = blob.valueOf(strData);
                   inAtt.fileName = 'GUEntitlement_InProgress.csv';
                   inAtt.mimeTypeSubType = 'txt';
                
                   email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt }; 
                
                   // call the class and test it with the data in the testMethod
                   GUEntitlementAttachmentProcessing emailServiceObj = new GUEntitlementAttachmentProcessing();
                   emailServiceObj.handleInboundEmail(email, env ); 
        // }
            
            
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
 
   static testmethod void testOnServiceEntitlementCtrl2()
    {
        try
        {
            Test.startTest();
            
            system.debug('&&&&&&&&&&list_SC_Temp ++++++++  ');
            //Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            List<Account>list_Acc = new List<Account>();
            List<Address__c>list_Address = new List<Address__c>();
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, true);
            Map<ID, Opportunity> opplst;
            //List<Address__c>list_Address = new List<Address__c>();
            RecordType objRecType = [select id,name from RecordType where name =: 'EMG - Customer Record Type'];
            RecordType objRecType_Opp = [select id,name from RecordType where name =: 'GEN - Opportunity Record Type'];
            
            

           // System.runAs(runAsUser[0]) 
           // {
                
                List<Account> list_Accounts = TestUtil.createAccounts(1,false);
                list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
                insert list_Accounts;
                
                system.debug('&&&&&&&&&&list_Accounts++++++++  '+list_Accounts);
                
                Contact testContact = new Contact();
                testContact.AccountId = list_Accounts[0].Id;
                testContact.All_Service_Elements_Access__c = true;
                testContact.Self_Service_Elements_Access__c = true;
                testContact.LastName = 'Pankaj001';
                testContact.PureSuccess_Main_Contact__c = true;
                insert testContact;
                
                Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
                objOpportunity.Lines_of_Businesses__c = 'PureCloud';
                insert objOpportunity;
                
                
                
                List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'PureSuccess_Services'];
                Case cs = new Case(status='Open',subject='test', ContactId = testContact.Id,                      
                               recordtypeid = rectp[0].id);                        
                insert cs;
                
                system.debug('&&&&&&&&&&cs++++++++  '+cs);
              
                List<Product2> list_Products = TestUtil.createProducts(5, false);
                System.assert(list_Products.size() == 5);
                for(Product2 objProduct :  list_Products){
                    objProduct.APN_Number__c = 'APNABC'+objProduct.Name;
                }
                
                insert list_Products;
                
                System.assert(list_Products[0].Id != NULL);
                
                system.debug('&&&&&&&&&&list_Products++++++++  '+list_Products);
              
                Product_Group__c prdgrp = new Product_group__c();
              
              prdgrp.Name = 'Test';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              Order__c ord_1 = new Order__c();
              ord_1.Name = 'Test Order';
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = objOpportunity.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'USD';
              insert ord_1;
              
              List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, ord_1.Id, true);
              List<ServiceContract> list_SC = TestUtil.createServiceContracts2(1, false,list_Accounts[0]);
              list_SC[0].End_User_Name__c = list_Accounts[0].id;
              insert list_SC;
              
              system.debug('&&&&&&&&&&list_OLIs ++++++++  '+list_OLIs);
              
              
              Token_Allocations__c tkAll = new Token_Allocations__c();
              tkAll.Account__c = list_Accounts[0].id;
              tkAll.Order__c = ord_1.Id;
              tkAll.Product__c = list_Products[0].id;
              tkAll.Product_Group__c = prdgrp.id;
              tkAll.Tokens__c = 500;
              //tkAll.Currency__c = 'USD';
              tkAll.Token_status__c = 'Allocated';
              tkAll.Contract_No__c = list_SC[0].Name;
              tkAll.allocation_type__c = 'GU Training Units';
              insert tkAll;
              
              Token_Consumption__c tknc = new Token_Consumption__c();
              tknc.Product__c = list_Products[0].Id;
              tknc.Status__c = 'In Progress';
              tknc.Tokens__c = 10;
              tknc.Token_Allocation__c = tkAll.Id;
              insert tknc;
               List<Pure_Success_Package__c> pSuccessPkg = new List<Pure_Success_Package__c>();
               List<Token_Allocations__c> tknlst = new List<Token_Allocations__c>();
               List<Package_Services__c> pkgSrv = new List<Package_Services__c>();
               List<Product_Group_Item__c> pdgrpItm = new List<Product_Group_Item__c>();
               List<Token_Consumption__c> tknc1 = new List<Token_Consumption__c>();
               List<Contact> lstcont = new List<Contact>();
               
               Pure_Success_Package__c ppkg = new Pure_Success_Package__c();
               ppkg.Account__c = list_Accounts[0].id;
               ppkg.Product__c = list_Products[0].id;  
               insert ppkg;
               
                Package_services__c pkg = new Package_services__c ();
                pkg.Case__c = cs.id;
                pkg.Status__c = 'Consumed';        
                pkg.PureSuccess_Package__c = ppkg.id;
                insert pkg;
                
                Pure_Success_Package__c ppkg1 = new Pure_Success_Package__c();
               ppkg1.Account__c = list_Accounts[0].id;
               ppkg1.Product__c = list_Products[0].id;  
               insert ppkg1;
               
                Package_services__c pkg1 = new Package_services__c ();
                pkg1.Case__c = cs.id;
                pkg1.Status__c = 'Allocated';        
                pkg1.PureSuccess_Package__c = ppkg1.id;
                insert pkg1;
                
               Pure_Success_Package__c ppkg2 = new Pure_Success_Package__c();
               ppkg2.Account__c = list_Accounts[0].id;
               ppkg2.Product__c = list_Products[0].id;
               ppkg2.Package_Type__c = 'A la Carte';
               insert ppkg2;
               
                Package_services__c pkg2 = new Package_services__c ();
                pkg2.Case__c = cs.id;
                pkg2.Status__c = 'Consumed';        
                pkg2.PureSuccess_Package__c = ppkg2.id;
                insert pkg2;
                
                Pure_Success_Package__c ppkg3 = new Pure_Success_Package__c();
               ppkg3.Account__c = list_Accounts[0].id;
               ppkg3.Product__c = list_Products[0].id;
               ppkg3.Package_Type__c = 'A la Carte';
               insert ppkg3;
               
                Package_services__c pkg3 = new Package_services__c ();
                pkg3.Case__c = cs.id;
                pkg3.Status__c = 'Allocated';        
                pkg3.PureSuccess_Package__c = ppkg3.id;
                insert pkg3;
                
                pkg3.Status__c= 'In Progress';
                pkg3.Case__c = cs.id;
                
                update pkg3;
                
                
                system.debug('&&&&&&&&&&list_SC[0].name ++++++++  '+list_SC[0].name);
                
                //system.debug('&&&&&&&&&&list_SC_Temp ++++++++  '+list_SC_Temp );
               //  List<ServiceContract> list_SC = new List<ServiceContract>([SELECT Name, Id FROM ServiceContract LIMIT 1]);
               //  system.debug('&&&&&&&&&&list_SC ++++++++  '+list_SC );
                 
                
                 GU_Entitlement__c objGU = new GU_Entitlement__c();
                 //objGU.Course_End_Date__c = objWrap.CourseEndDate ;
                 //objGU.Course_Location__c = objWrap.CourseLocation ;
                 //objGU.Course_Start_Date__c = objWrap.CourseStartDate ;
                 //objGU.End_Customer_Name__c = objWrap.EndUser; //objWrap.EndCustomerName.trim() ;
                 //objGU.Entitlement_Name__c = objWrap.EntitlementName ;
                 //objGU.Entitlement_Number__c = objWrap.EntitlementNumber ;
                 //objGU.Entitlement_Type__c = objWrap.EntitlementType ;
                 //objGU.GU_Voucher_Used__c = objWrap.GUVoucherUsed ;
                 //objGU.Partner_Name__c = objWrap.PartnerName ;
                 //objGU.Service_Contract__c = objWrap.ServiceContract;
                 //objGU.Service_Contract_Number__c = objWrap.ServiceContractNumber ;
                 objGU.Status__c = 'In Progress' ;
                 //objGU.Student_Email__c = objWrap.StudentEmail ;
                 //objGU.Student_Name__c = objWrap.StudentName ;
                 insert objGU;
                
                
                GUEntitlementAttachmentProcessing objGUE = new GUEntitlementAttachmentProcessing();
                
                // Create a new email, envelope object and Attachment
                   Messaging.InboundEmail email = new Messaging.InboundEmail();
                   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                   Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
                
                   email.subject = 'test';
                   env.fromAddress = 'user@acme.com';
                
                   // set the body of the attachment
                   string strData = 'EntitlementID,EndUser,PartnerName,EntitlementName,EntitlementNumber,EntitlementType,StudentName,StudentEmail,CourseStartDate,CourseEndDate,Certified,CertificationExpiration,GUVoucherUsed,OrderName,Order,Status,CancellationDate,CourseLocation,EndCustomerName\n';
                   strData += ''+objGU.id+',,,New Course1,10004,PISP,Vinay Ravula,vinay.ravula@genesys.com,1/1/2018,4/4/2018,false,,10,Test Order,,,,,Indianapolis';
                   
                   inAtt.body = blob.valueOf(strData);
                   inAtt.fileName = 'GUEntitlement_Completed.csv';
                   inAtt.mimeTypeSubType = 'txt';
                
                   email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt }; 
                
                   // call the class and test it with the data in the testMethod
                   GUEntitlementAttachmentProcessing emailServiceObj = new GUEntitlementAttachmentProcessing();
                   emailServiceObj.handleInboundEmail(email, env ); 
         //}
            
            
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
}