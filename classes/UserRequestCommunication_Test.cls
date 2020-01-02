/*
Created By: Swastika Rajkhowa
Created Date: 10-Mar-2017
Function: Test Classes for Controller class Communication
*/
@isTest(SeeAllData = true)
private class UserRequestCommunication_Test
{
 static testmethod void testmethod1()
    {
        try
        {
            Test.startTest();
            List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Account' and DeveloperName= 'EMGCustomerRecordType'];
            account objAcc = testutil.createAccounts(1,true)[0];
            objAcc.recordTypeId =rtypes[0].Id;
            update objAcc;
            
            List<User> UserTo = TestUtil.createUsers(2, true); 
            UserTo[0].Email ='test@test.com';
            UserTo[1].Email ='test1@test.com';
            update UserTo;   
            
            Partner_User_Request__c objPartner = new Partner_User_Request__c();
            objPartner.Account_Name__c = objAcc.Id;
            objPartner.Requester__c = UserTo[0].Id;
            insert objPartner;
            list<Attachment> listAttachment= testUtil.createAttachment(1,false, objPartner.Id);
            listAttachment[0].Body =  Blob.valueOf('test');
            insert listAttachment;
            PageReference pageRef = Page.Communication; 
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', objPartner.Id);                       
            UserRequestCommunication objUserRequestCommunication = new UserRequestCommunication();
            objUserRequestCommunication.sUsersIds = UserTo[0].Id+','+UserTo[1].Id;
            objUserRequestCommunication.sSubject ='testing';
            objUserRequestCommunication.sOrgWideId = 'test@test.com';
            objUserRequestCommunication.list_AttachIds.add(listAttachment[0].Id);
            objUserRequestCommunication.sEmailAdd = 'test1@test.com'; 
            objUserRequestCommunication.sTo = 'test@test.com';
            objUserRequestCommunication.sFrom = 'test2@test.com';
            objUserRequestCommunication.fileName = 'test';                      
            objUserRequestCommunication.SendEmail();
            objUserRequestCommunication.UploadFile();
            objUserRequestCommunication.GetAttachments();
            Test.stopTest();
         }
         catch(CalloutException e){}
    }     
}