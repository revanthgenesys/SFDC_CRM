public class TM01Opportunity {
/*
- Author : Michael Le Grand (Kerensen Consulting)
- Description : 
	Component : Trigger TM01 "Update Opportunity Territory when Owner is changed" 
				(Opportunity After Update / Opportunity Before Insert)
	Object (s):  Opportunity / UserTerritory / Territory
	What : When Opportunity's ownership is changed then Territory is changed on Opportunity 
		   selecting TerritoryId whose Territory.TRM__c = true And Territory related to this new user (see UserTerritory junction table)
- Delivery Date : 02/06/2009
- Governor informations :
	Single : 				SOQL queries : 2 / 20
							Query rows : 0 / 1000
							DML Statments : 1 / 20
							DML rows : 	 / 100
	With others triggers  :
							SOQL queries :  / 20
							Query rows :   / 1000
							DML Statments :  / 20
							DML rows : 	 / 100
*/
private static boolean alreadyUpdatedOpp = false;
public static boolean hasAlreadyUpdatedOpp() {
return alreadyUpdatedOpp;
}
// By setting the variable to true, it maintains this
// new value throughout the duration of the request
// (or testMethod)
public static void setAlreadyAlreadyUpdatedOpp() {
alreadyUpdatedOpp = true;
}

public static void assignNewTerritory(Opportunity[] Opportunities)
{
	System.Debug('## >>> Starting TM01Opportunity.assignNewTerritory <<<');
	//Important Note : it is impossible to use child relationship with SOQL for UserTerritory Table ex : UserTerritory.Territory.TRM__c
	List<Opportunity> lstOppClone = Opportunities.deepClone(); //clone as we are in after insert context
	
	Map<Id,UserTerritory> mapUserTerritory = new Map<Id,UserTerritory> (
	[Select UserId, TerritoryId from UserTerritory where  IsActive=:true and UserId IN: Util.getSetFromFieldName(Opportunities,'OwnerId') ]);
	
	Map<String,String> mapIdTerritoryUserId = Util.mapBuildFromList(mapUserTerritory.Values(),'TerritoryId', 'UserId');
	
	//get All territory which TRM__c = true
	Map<Id,Territory> mapTerritory = new Map<Id,Territory>(
	[Select Id, TMR__c from Territory Where TMR__c=:true  and Id IN:mapIdTerritoryUserId.keySet()]);
	
	//build Map<userId,TerritoryId whose TRM__c = true>
	Map<String,String> mapUserIdTerritoryIdOK = new Map<String,String>();
	for (Territory t : mapTerritory.Values())
	{
		mapUserIdTerritoryIdOK.put(mapIdTerritoryUserId.get(t.Id),t.Id);
	}
	for(Opportunity opp:lstOppClone)
	{
			System.debug('## Opportunity.Id:'+opp.Id);
			System.debug('## Opportunity New OwnerId:'+opp.OwnerId);
			System.debug('## New Owner TerritoryId:'+mapUserIdTerritoryIdOK.get(opp.OwnerId));
			opp.TerritoryId = mapUserIdTerritoryIdOK.get(opp.OwnerId);
			//opp.TerritoryId = 'ESD Overviews';
	}
	update lstOppClone; 
	System.Debug('## >>> Ending TM01Opportunity.assignNewTerritory <<<');
}

/*****************************************************************/
/**************** TEST METHODS ***********************************/
/*****************************************************************/	
static testmethod void testassignNewTerritory()
{
	
	String strOptyTerritoryIdUser1 = '';
	String strOptyTerritoryIdUser2 = '';
	User user_1 = TestCommon.createUser('testmlg', 'MyTestUserName@test.test', 'MyTestLastName','MyTestFirstName',null); 
	User user_2 = TestCommon.createUser('testmlg2', 'MyTestUserName2@test.test', 'MyTestLastName2','MyTestFirstName2',null);
		

	/*Account myAccount = new Account(name='Acc_AlcatelTriggerTest '+datetime.newInstance(2008, 12, 1, 12, 30, 2));
	insert myAccount;
	Opportunity opp1 = new Opportunity(AccountId = myAccount.Id, //mapped with Asset
								  name='Opp_AlcatelTriggerTest 1  XYZ', //mandatory
								  stageName='Open', //mandatory
								  CloseDate=Date.newInstance(2006,10,10),//mandatory
								  OwnerId = user_1.Id
								  );
	System.debug('## Insert oppt1');
	insert opp1;
	System.debug('## Id Opty inserted:'+opp1);*/
	Account myaccount = TestCommon.createAccount(true);
	
	Opportunity opp1 = TestCommon.createOpportunity(Myaccount.Id);
	
	strOptyTerritoryIdUser1 = [Select Id, TerritoryId from Opportunity Where Name=:opp1.Name].TerritoryId;
	System.debug('### strOptyTerritoryIdUser1:'+strOptyTerritoryIdUser1);
	//verify that a TerritoryId related to User1 exists(see Table UserTerritory) 
	System.assertNotEquals(null, [Select UserId, TerritoryId from UserTerritory where UserId=:user_1.Id and TerritoryId=:strOptyTerritoryIdUser1]);
	//Verify that territory selected from UserTerritory table is the one with TRM__c =  true
	//System.assertEquals(true,[Select Id,TMR__c from Territory where Id=:strOptyTerritoryIdUser1].TMR__c);
	
	//Check After Update when Opportunity ownership change
	alreadyUpdatedOpp = false;
	opp1.OwnerId = user_2.Id;
	update opp1;
	strOptyTerritoryIdUser2 = [Select Id, TerritoryId from Opportunity Where Id=:opp1.Id].TerritoryId;
	System.debug('### strOptyTerritoryIdUser2:'+strOptyTerritoryIdUser2);
	//System.assertNotEquals(strOptyTerritoryIdUser1,strOptyTerritoryIdUser2);
	//verify that new TerritoryId is related  to new user (see Table UserTerritory) 
	//System.assertNotEquals(null, [Select UserId, TerritoryId from UserTerritory where UserId=:user_2.Id and TerritoryId=:strOptyTerritoryIdUser2]);
	//Verify that territory selected from UserTerritory table is the one with TRM__c =  true
	//System.assertEquals(true,[Select Id,TMR__c from Territory where Id=:strOptyTerritoryIdUser2].TMR__c);

}

}