@isTest
private class DQSpecialApprovalCtrlTest
 {
 private static testMethod void unitTest(){
 Test.startTest();
 //test class for credit
  Deal_Qualification__c testRec = new Deal_Qualification__c();
            testRec.Order_Mgmt_Billing_approval__c='Approved';
            testRec.Req_Order_Mgmt_Billing_approval__c=true;
            testRec.Status__c = 'Approved';
            testRec.Req_Legal_approval__c = true;
            testRec.Legal_approval__c = 'Pending';
            testRec.Req_Credit_Collections_approval__c= true;
            testRec.Credit_and_Collections_approval__c='Pending';
            testRec.Req_Revenue_Approval__c=true;
            testRec.Revenue_approval__c = 'Approved';
            insert testRec;
          
            PageReference pageRef = Page.DQapprovalvfpage;
            pageRef.getParameters().put('id', String.valueOf(testRec.id));
            pageRef.getParameters().put('ResponseCode','Approved' );
            pageRef.getParameters().put('Field','Credit' );
            Test.setCurrentPage(pageRef);  
            DQSpecialApprovalCtrl ex = new DQSpecialApprovalCtrl();
            ex.InitPage();
            
            testRec.Status__c = 'Approval Pending';
            update testRec;
            Test.setCurrentPage(pageRef);  
            DQSpecialApprovalCtrl ex4 = new DQSpecialApprovalCtrl();
            ex4.InitPage();
            PageReference pageRef4 = Page.DQapprovalvfpage;
            pageRef4.getParameters().put('id', String.valueOf(testRec.id));
            pageRef4.getParameters().put('ResponseCode','Rejected' );
            pageRef4.getParameters().put('Field','Credit' );
            Test.setCurrentPage(pageRef4); 
             DQSpecialApprovalCtrl ex8 = new DQSpecialApprovalCtrl();
            ex8.InitPage(); 
            testRec.Status__c = 'Approved';
            update testRec;  
            Test.setCurrentPage(pageRef4); 
             DQSpecialApprovalCtrl e1 = new DQSpecialApprovalCtrl();
            e1.InitPage(); 
            testRec.Credit_and_Collections_approval__c='Rejected';
            update testRec;  
            Test.setCurrentPage(pageRef4); 
             DQSpecialApprovalCtrl v1 = new DQSpecialApprovalCtrl();
            v1.InitPage(); 
   ///////test classes for legal
             PageReference pageRef1 = Page.DQapprovalvfpage;
            pageRef1.getParameters().put('id', String.valueOf(testRec.id));
            pageRef1.getParameters().put('ResponseCode','Approved' );
            pageRef1.getParameters().put('Field','Legal' );
            Test.setCurrentPage(pageRef1); 
     DQSpecialApprovalCtrl s1 = new DQSpecialApprovalCtrl();
            s1.InitPage(); 
            testRec.Status__c = 'Approval Pending';
            update testRec;
            Test.setCurrentPage(pageRef1); 
            DQSpecialApprovalCtrl ex5 = new DQSpecialApprovalCtrl(); 
            ex5.InitPage();    
             PageReference pageRef5 = Page.DQapprovalvfpage;
            pageRef5.getParameters().put('id', String.valueOf(testRec.id));
            pageRef5.getParameters().put('ResponseCode','Rejected' );
            pageRef5.getParameters().put('Field','Legal' );
            Test.setCurrentPage(pageRef1); 
             DQSpecialApprovalCtrl ex9 = new DQSpecialApprovalCtrl();
            ex9.InitPage();
     testRec.Legal_approval__c='Rejected';
            update testRec;  
            Test.setCurrentPage(pageRef5); 
             DQSpecialApprovalCtrl v2 = new DQSpecialApprovalCtrl();
            v2.InitPage();
            testRec.Status__c = 'Approved';
            update testRec;  
            Test.setCurrentPage(pageRef5); 
             DQSpecialApprovalCtrl e2 = new DQSpecialApprovalCtrl();
            e2.InitPage();
     
            ///test classes for order
             PageReference pageRef2 = Page.DQapprovalvfpage;
            pageRef2.getParameters().put('id', String.valueOf(testRec.id));
            pageRef2.getParameters().put('ResponseCode','Approved' );
            pageRef2.getParameters().put('Field','Order' );
            Test.setCurrentPage(pageRef2);  
            DQSpecialApprovalCtrl ex2 = new DQSpecialApprovalCtrl();
            ex2.InitPage();               
            testRec.Status__c = 'Approval Pending';
            update testRec;
            Test.setCurrentPage(pageRef2);  
          DQSpecialApprovalCtrl ex6 = new DQSpecialApprovalCtrl();
            ex6.InitPage();
            PageReference pageRef6 = Page.DQapprovalvfpage;
            pageRef6.getParameters().put('id', String.valueOf(testRec.id));
            pageRef6.getParameters().put('ResponseCode','Rejected' );
            pageRef6.getParameters().put('Field','Order' );
            Test.setCurrentPage(pageRef6); 
             DQSpecialApprovalCtrl exl = new DQSpecialApprovalCtrl();
            exl.InitPage();
     testRec.Order_Mgmt_Billing_approval__c='Pending';
            update testRec;
            Test.setCurrentPage(pageRef6);  
            DQSpecialApprovalCtrl p1 = new DQSpecialApprovalCtrl();
            p1.InitPage();
     testRec.Order_Mgmt_Billing_approval__c='Rejected';
            update testRec;
            Test.setCurrentPage(pageRef2);  
            DQSpecialApprovalCtrl e5 = new DQSpecialApprovalCtrl();
            e5.InitPage();
            testRec.Status__c = 'Approved';
            update testRec;  
            Test.setCurrentPage(pageRef2); 
             DQSpecialApprovalCtrl e3 = new DQSpecialApprovalCtrl();
            e3.InitPage();
     
     
  ///    test classes for Revenue
            testRec.Status__c = 'Approval Pending';
            update testRec; 
             PageReference pageRef3 = Page.DQapprovalvfpage;
            pageRef3.getParameters().put('id', String.valueOf(testRec.id));
            pageRef3.getParameters().put('ResponseCode','Approved' );
            pageRef3.getParameters().put('Field','Revenue' );
            Test.setCurrentPage(pageRef3);  
    DQSpecialApprovalCtrl ex7 = new DQSpecialApprovalCtrl();
            ex7.InitPage();
     testRec.Revenue_approval__c='Pending';
            update testRec;
            Test.setCurrentPage(pageRef3);  
            DQSpecialApprovalCtrl e6 = new DQSpecialApprovalCtrl();
            e6.InitPage();
       testRec.Revenue_approval__c='Rejected';
            update testRec;
            Test.setCurrentPage(pageRef);  
            DQSpecialApprovalCtrl e9 = new DQSpecialApprovalCtrl();
            e9.InitPage();      
            
            Test.setCurrentPage(pageRef3); 
             DQSpecialApprovalCtrl exl1 = new DQSpecialApprovalCtrl();
            exl1.InitPage();
            testRec.Status__c = 'Approved';
            update testRec;  
            Test.setCurrentPage(pageRef3); 
             DQSpecialApprovalCtrl e4 = new DQSpecialApprovalCtrl();
            e4.InitPage();
     Test.stopTest();
           
    }
    }