/*
- Author : Michael Le Grand (Kerensen Consulting)
- Description : 
	Component : Trigger AP01 "Products To Assets" (Opportunity After Update)
	Object (s):  Opportunity / OpportunityLineItem / Asset / Account
	What : Products on Opportunity become Assets when Opportunity is saved with the stage "Closed Won“
- Delivery Date : 07/11/2008
- Governor informations :
	Single : 				SOQL queries : 2 / 20 (1 Top and 1 parent-child relationship sub-query)
							Query rows : fn(nb OpportunityLineItems) / 1000
							DML Statments : 1 / 20
							DML rows : 	fn(nb OpportunityLineItems) / 100
	With others triggers :
							SOQL queries : / 20
							Query rows : fn(nb OpportunityLineItems) / 1000
							DML Statments : 1 / 20
							DML rows : 	fn(nb OpportunityLineItems) / 100
*/

public class AP01Opportunity {

public static void ConvertToAssets(Map<Id,Opportunity> oppMap)
    { 
		List<Asset> lstAssets = new List<Asset>(); 
		Map<Id,Account> lstAcc = new Map<Id,Account>(); //account to update : Prospect -> Client
		
		Map<Id,Opportunity> CloneOppMap = oppMap.deepClone();
		
    	System.debug('## Nb Opportunities  concerned:'+CloneOppMap.size());
		Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
		[select Id/*,Competitor__c*/,ShippingDate__c, CloseDate, AccountId,IsConverted__c,BusinessPartner__c,
			//sub-query OpportunityLineItems
			(select Id,TotalPrice, Quantity__c, PricebookEntry.Product2Id, PricebookEntry.Name, PricebookEntryId, OpportunityId, Description,LinesSeatsPortsUsers__c from opportunitylineitems) 
		from Opportunity
		where Id in : getHasParentAccountOpportunitiesId(CloneOppMap.Values())]);
		
		System.debug('## Nb Opportunities to treat after filtration concerned:'+opportunityMap.size());

		 for (Opportunity opp:opportunityMap.Values()) 
		 { 
		 	 System.debug('## Opp treated:'+opp.Id);
			for(OpportunityLineItem oli: opp.OpportunityLineItems)
			{
				lstAssets.add(new Asset( AccountId = opp.AccountId,
          								 Product2Id = oli.PricebookEntry.Product2Id,
          								 Name = oli.PricebookEntry.Name,
							             Quantity = oli.Quantity__c,
							             PurchaseDate = opp.CloseDate,
							             InstallDate = opp.ShippingDate__c,
							             //MLG 07/09/2010
							             //Manufacturer__c = opp.Competitor__c,
							             Manufacturer__c = Config.ASSET_DEFAULT_MANUFACTURER,
							             Description = oli.Description,
							             //ALU_Partner__c = opp.BusinessPartner__c,
							             LinesSeatsPortsUsers__c = oli.LinesSeatsPortsUsers__c));
			}
		 	
		 	//opp does not refer directly to Trigger.New that is why we need to refer to original Map
		 	// to update the opp triggered
		     CloneOppMap.get(opp.Id).IsConverted__c = true;
		     
		    //add Accounts to update as Client
		    lstAcc.put(opp.AccountId, new Account(Id=opp.AccountId,Type='Customer', IsUpdatedByApexTrigger__c = true));
		    
		 }
		 
		 insert lstAssets;
		 update CloneOppMap.values(); //set opp to IsConverted =true
		 //Update Account list  : Account.Type = Client
		 update lstAcc.values(); 	
		 
		
		  System.debug('####################');
		  System.debug('## Governor Limit:');
		  System.debug('## Limits.getLimitDMLRows():'+Limits.getLimitDMLRows());
		  System.debug('## Limits.getDMLRows():'+Limits.getDMLRows());		

    }
	
		/* Get OpportunityId if Opportunity is linked to an Account 
		Note that Asset need to be linked to an Account when it is created */
		private static Set<Id> getHasParentAccountOpportunitiesId(List<Opportunity> lstOpp) { 
			Set<Id> idSet = new Set<Id>(); 
			for(Opportunity opp:lstOpp) { 
				if(opp.AccountId != null) idSet.add(opp.Id); 
			} 
			return idSet; 
		} 
		
		
/*****************************************************************	
/**************** TEST METHODS ***********************************
/*****************************************************************/	

	private static integer MAX_OPPLINITEM_PER_OPP = 100;
	//private static integer MAX_OPPLINITEM_PER_OPP = 100;
	
//1. Test sur un nombre restreint d'enregistrement : OK
//2. Test sur un nombre important d'Opportunuit� (Max : context trigger = 100
//3. Test sur un nombre important d'OLI (max 200 to insert Assets)
	
	private static PricebookEntry pbe = null;
	private static Account myAccount = null;
	//private static BusinessPartner__c myPartner = null;

static testMethod Opportunity insertRequiredBasicObjects()
{
	//methode de test sur un nombre restreint d'enregistrements
	//create un compte
	 myAccount = new Account(name='Acc_AlcatelTriggerTest '+datetime.newInstance(2008, 12, 1, 12, 30, 2));
	insert myAccount;
	Account myPartner = TestCommon.createAccountBP(true);
	//remarque : lors de la cr�ation d'une Opportunit�, on doit d�finir le PriceBook par d�faut
	//par cons�quent il est necessaire de faire les traitements qui suivent avant de cr�er
	//l'opportunite
	
	//create sur cette opportunite 2 OpportunityLineItems 
		//mais avant on cr�er Produit/priceBookEntry dans le PriceBook Standard
		//remarque : un produit ne peut �tre dans un catalogue uniquement si il est dans le catalogue standard
		Product2 p = new product2(name='product_Alcatel'); 
		insert p; 
		Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1]; 
		insert new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id, unitprice=1.0, isActive=true); 
		
		// Next, we create a new pricebook with an entry for this product 
		Pricebook2 pb = new pricebook2(name='test_Alcatel'); 
		insert pb; 
		pbe = new PricebookEntry(pricebook2id=pb.id, product2id=p.id, unitprice=1.0, isActive=true); 
		insert pbe; 
		//create Business Partner
		//myPartner = new BusinessPartner__c(Street1__c='Street BP test', name='MyBP MLG');
		//insert myPartner;
		//we create the Opportunity affected to the test pricebook
		Opportunity opp = new Opportunity(AccountId = myAccount.Id, //mapped with Asset
										name='Opp_AlcatelTriggerTest', //mandatory
										pricebook2id=pb.id, //mapped with Asset
										stageName='Open', //mandatory
										CloseDate=Date.newInstance(2008,10,10),//mandatory, label : Booking Date
										BusinessPartner__c=myPartner.Id,
										WonLostCancelledReason__c = 'Best Practice' //, 
										//Competitor__c = '3COM'//,
										//ShippingDate__c = Date.newInstance(2008,10,15)
										);
		insert opp; 
		
		return opp;
		
}
static testMethod void testConvertToAsset()
{
		Opportunity o = insertRequiredBasicObjects();
		Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
		oppMap.put(o.id,o);
		//OpportunityAlcatel.ConvertToAssets(oppMap);
		OpportunityLineItem oli = new OpportunityLineItem(opportunityid=o.id, pricebookentryid=pbe.id, unitprice=1.5, Quantity__c=2,Quantity = 3, Description='oli description',LinesSeatsPortsUsers__c=14 ); 
		insert oli; 
		//o.IsWon = true;
		o.stageName=CONFIG.OPP_STAGE82;
		o.Competitor__c = 'ALCATEL LUCENT';
		o.WonLostCancelledComments__c='test';
		o.Factors_Influencing_Price__c='test';
		o.WonLostCancelledComments__c ='testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test';
		o.WonLostCancelledComments__c += ' test testing  test testing  test testing  test testing  test testing  test testing  test testing  test testing ';
		update o;
		
		
		
		//verify that Opportunity has IsConverted__c = true as trigger performed via previous update
		//System.assertEquals(true, [select IsConverted__c from Opportunity where id = :o.id].IsConverted__c); 
		
		//verify mapping of Assets with fields of Objects associated
		for(Asset ast: [select 
								 AccountId,
  								 Product2Id, 
  								 Name,
  								 //Price,
					             Quantity, 
					             PurchaseDate,
					             //Status,
					             InstallDate,
					             Manufacturer__c,
					             Description,
					             LinesSeatsPortsUsers__c
					             from Asset
					            where AccountId =: myAccount.Id])
		{
			System.assertEquals(ast.AccountId, myAccount.Id);
			System.assertEquals(ast.Product2Id, pbe.Product2Id);
			System.assertEquals(ast.Name, [select Name from PricebookEntry where id = :pbe.id].Name);
			//System.assertEquals(ast.Price, oli.Quantity * oli.unitprice);
			System.assertEquals(ast.Quantity, oli.Quantity__c);
			System.assertEquals(ast.PurchaseDate, o.CloseDate); // bookingDate
			//System.assertEquals(ast.Status,'Installed');
			//System.assertEquals(ast.InstallDate,o.ShippingDate__c);
			//MLG 07/09/2010
			//System.assertEquals(ast.Manufacturer__c,o.Competitor__c);
			System.assertEquals(ast.Manufacturer__c,Config.ASSET_DEFAULT_MANUFACTURER);
			System.assertEquals(ast.Description,oli.Description);
			System.assertEquals(ast.LinesSeatsPortsUsers__c,oli.LinesSeatsPortsUsers__c);
		}
		
		

		//verify that only one asset has been inserted
		//System.assertEquals(1, [select count() from Asset where AccountId = :myAccount.Id]); 
		//Verify that Account became Client Type
		//System.assertEquals('Customer', [select Type from Account where Id = :myAccount.Id].Type); 
}

static  testMethod void testConvertToAssetWithManyOli()
{
	Opportunity o = CreateOpportunityWithManyOli(MAX_OPPLINITEM_PER_OPP);
	o.stageName='8-Closed Won';
	o.WonLostCancelledComments__c='test';
	o.Factors_Influencing_Price__c='test';
	o.Competitor__c = 'ALCATEL LUCENT';
	o.WonLostCancelledComments__c ='testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test';
		o.WonLostCancelledComments__c += ' test testing  test testing  test testing  test testing  test testing  test testing  test testing  test testing ';
		
	update o;
}

	//A utility method used for bulk testing
static Opportunity CreateOpportunityWithManyOli(Integer n) 
{
		Opportunity o = insertRequiredBasicObjects();
		List<OpportunityLineItem> LstOli = new List<OpportunityLineItem>();
		for (Integer i = 0; i < n; i++) {
			LstOli.add(new OpportunityLineItem(opportunityid=o.id, pricebookentryid=pbe.id, unitprice=1.5, Quantity__c=2,Quantity = 3,  Description='oli description'));
		}	
		insert LstOli;
		return o;
}		
}