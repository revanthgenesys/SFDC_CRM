@isTest 
public class CaseReassignMultipleEmailTasks_Test {
	
	static testMethod void reassignTest() {
		
	        Util.Bypass_Trigger_Chk = true;
	        
	        List<RecordType> recType = [SELECT ID FROM RecordType WHERE Name = 'Email To Case'];
	              
	        List<Case> cases = TestUtil.createCases(3, true);  
	        if ( !recType.isEmpty() )   {
	        	cases[0].RecordTypeId = recType[0].Id;
	        	update cases[0];
	        }  
	                  
	        Case targetCase = [Select CaseNumber from case where id = :cases[2].Id][0];        
	        
	        List<Task> srcTasks = TestUtil.createTasks(1, true, cases[0]);
	        List<EmailMessage> emMsgs = TestUtil.createEmailMessage(1, true, srcTasks[0]);
	        
	        String bdStr = 'body';
		    Blob bd = Blob.valueof(bdStr);
	        Attachment attch = new Attachment(Description = 'descr', Name = 'name', Body = bd, ParentId = emMsgs[0].Id);
	        insert attch;
	        
	        Test.startTest();
	        CaseReassignMultipleEmailTasks.reassignEmailTasks(cases, targetCase.CaseNumber);
	        Test.stopTest();
	        
	        List<Task> tasks = [SELECT Id, whatId FROM task WHERE whatId = :targetCase.Id];
	        
	    //    System.assertEquals(false, tasks.isEmpty());

	}

}