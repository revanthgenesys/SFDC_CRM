@isTest
public class ServiceTokenDomainTest {

    static zqu__Quote__c zQuote;
    static TestZQuoteContext context;
    static Account acc;
    
    public static TestMethod void GetAvailableTokens()
    {
        SetupData();        
        Test.startTest();
        ServiceTokenDomain std = new ServiceTokenDomain(acc);
		system.debug('==> Available Tokens : ' + std.AvailableServiceTokens);
        system.debug('===> tokens: ' + std.ServiceTokens);

        std.CreateServiceTokens('PS-170-PURE-SVBRONZE', 1, Date.Today());

        integer i = std.AvailableServiceTokens;
		system.debug('==> Available Tokens : ' + std.AvailableServiceTokens);
        system.debug('===> tokens: ' + std.ServiceTokens);

        System.AssertEquals(40,i,'Should be 40 tokens.');
        
        Test.stopTest();
                
    }

    public static TestMethod void GetAvailableTokensStatic()
    {        
        SetupData();        

        ServiceTokenDomain std = new ServiceTokenDomain(acc);
		system.debug('==> Available Tokens : ' + std.AvailableServiceTokens);
        system.debug('===> tokens: ' + std.ServiceTokens);
        std.CreateServiceTokens('PS-170-PURE-SVBRONZE', 1, Date.Today());
        Test.startTest();

        integer i = ServiceTokenDomain.AvailableServiceTokens(acc);
		System.AssertEquals(40,i,'Should be 40 tokens.');

        Test.stopTest();
    }

    public static TestMethod void UseTokensMoreThenOneBatch()
    {
        SetupData();        
        ServiceTokenDomain std = new ServiceTokenDomain(acc);
		system.debug('==> Available Tokens 1 : ' + std.AvailableServiceTokens);
        std.CreateServiceTokens('PS-170-PURE-SVBRONZE', 1, Date.Today());
        std.CreateServiceTokens('PS-170-PURE-SVSILVER', 1, Date.Today());

        Test.startTest();
		system.debug('==> Available Tokens 2 : ' + std.AvailableServiceTokens);
        system.debug('===> tokens: ' + std.ServiceTokens);
        std.UseTokens(80,'Ref1');
		system.debug('==> Available Tokens 3 : ' + std.AvailableServiceTokens);
        system.debug('===> tokens: ' + std.ServiceTokens);
        
        integer i = std.AvailableServiceTokens;
		System.AssertEquals(40,i,'Should be 40 tokens.');

        Test.stopTest();
        
    }
    public static TestMethod void UseTokens()
    {        
        SetupData(); 
        
        Test.startTest();
        
        ServiceTokenDomain std = new ServiceTokenDomain(acc);
		
        std.CreateServiceTokens('PS-170-PURE-SVBRONZE', 1, Date.Today());
        std.UseTokens(15,'Ref1');	
        
        integer i = std.AvailableServiceTokens;
		System.AssertEquals(65,i,'Should be 65 tokens.');

        Test.stopTest();
    }
    
    
    static void SetupData()
    {                
        context = new TestZQuoteContext();
        //5 charges for ZQuote added
        context.SetupZQuote();
        zQuote = context.ZQuote;    
 		acc = [SELECT Id, Name, PureCloud_Products__c FROM Account WHERE Id = :zQuote.zqu__Account__c LIMIT 1];               
    }
}