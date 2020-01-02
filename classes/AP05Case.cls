/*
- Author : Mohammed BEZRHOUD (Kerensen Consulting)
- Description : 
	Component : Trigger CaseAfterInsert  "Add the requester to CaseTeam with Read Only Access" (AfterInsert Case)
	Object (s):  Case / CaseTeamMember /CaseTeamRole
	What : The requester is added to CaseTeam with Read Only Access  when Case is created
- Delivery Date : 10/02/2011
- Governor informations :
	Single : 				SOQL queries : 2 / 20
							Query rows : 2 / 1000
							DML Statments : 3 / 20
							DML rows : 	3 / 100
*/
@isTest(seeAllData = true)
public class AP05Case {

	//Add User  in CaseTeam with Read Access
	public static void AddRequesterToCaseTeamReadAccess(Case[] cases)
	{
		System.Debug('## >>> Starting AP05Case.AddRequesterToCaseTeamReadAccess <<<');
		CaseTeamMember[] newmembers = new CaseTeamMember[]{};
		CaseTeamRole[] ReadTeamRoleId = [Select  Id From CaseTeamRole Where AccessLevel = 'Read' Limit 1];
		if(ReadTeamRoleId.size()>0)
		{
			for(Case c : cases) 
			{
				System.debug('## RequesterId:'+c.CreatedById);
				System.debug('## CaseId:'+c.Id);
				CaseTeamMember Teammemberad=new CaseTeamMember();
		          Teammemberad.ParentId=c.id;
		          Teammemberad.MemberId=c.CreatedById;
		          Teammemberad.TeamRoleId= ReadTeamRoleId[0].Id;
		          newmembers.add(Teammemberad);
			} 
			//insert CaseTeamMember list
			     Database.SaveResult[] lsr = Database.insert(newmembers,false);
			     for(Database.SaveResult sr:lsr)
			     {
				    if(!sr.isSuccess())
				    {
				        Database.Error emsg =sr.getErrors()[0];
				        system.debug('## ERROR ADDING TEAM MEMBER:'+emsg);
				    }
				    else
				    {
				    	system.debug('## OK CREATOR ADDED AS REQUESTER WITH READ ONLY ACCESS :'+sr.getId());
				    }      
			     }
		}
		System.Debug('## >>> Ending AP05Case.AddRequesterToCaseTeamReadAccess <<<');
	}

/*****************************************************************/
/**************** TEST METHODS ***********************************/
/*****************************************************************/	

//Scenario
//1. Insert a Case
//2. Verify that User is in CaseTeam
	
static  testMethod void TestAddRequesterToCaseTeamWithReadAccess()
{
	Id profileId = [Select Id From Profile Limit 1].Id;
	User requester = new User(Alias = 'testmb', Username = 'TestUserName@test.test',LastName = 'TestLastName',FirstName = 'TestFirstName', Email = 'TestUserName@test.test', CommunityNickname= 'TestUserName',	TimeZoneSidKey='Europe/Paris',LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId= profileId,LanguageLocaleKey='fr',isActive=true,ByPassValidationRules__c = true);
	insert requester;
	Case Mycase = new Case(Status = 'New',Case_Type__c = 'Data Visibility', Subject = 'My Test Case' , Description = 'This is a case to test AddRequesterToCaseTeamWithReadAccess', OwnerId = requester.Id);
	insert Mycase;
		
		CaseTeamRole ReadTeamRoleId = [Select  Id From CaseTeamRole Where AccessLevel = 'Read' limit 1];
		CaseTeamMember Teammember=new CaseTeamMember();
		          Teammember.ParentId=Mycase.id;
		          Teammember.MemberId=requester.id;
		          Teammember.TeamRoleId= ReadTeamRoleId.Id;
		          insert Teammember;
	
	List<Case> lstCase = new List<Case>();
	lstCase.add(Mycase);
	AP05Case.AddRequesterToCaseTeamReadAccess(lstCase);
	CaseTeamMember MyCaseTeamMember = [select TeamRoleId from CaseTeamMember where ParentId =: Mycase.Id limit 1];
	System.assertNotEquals(null, MyCaseTeamMember);
	CaseTeamRole MyCaseTeamRole = [select AccessLevel from CaseTeamRole where Id =: MyCaseTeamMember.TeamRoleId limit 1];
	System.assertEquals('Read', MyCaseTeamRole.AccessLevel);
}
}