/************************************************************************************
Purpose : Data factory class for quoting related test classes
Written By : Ranjith Punneli
Test Classes : N/A
*************************************************************************************/

@isTest(seeAlldata = true)
public class TestDataFactoryForQuoteTool {
    //*** Method to create accounts //
    public static List<Account> createAccounts(Integer intNumOfAccts) {
        List<Account> list_NewAccts = new List<Account>();
        for(Integer i=0; i<intNumOfAccts; i++) {
            Account a = new Account(Name='TestAccount' + i,Screening_Checklist_Completed__c=true);
            list_NewAccts.add(a);
        }
        insert list_NewAccts;
        return list_NewAccts;
    } 
    //*** Method to create contacts //
    //*** Method to create accounts //
    public static List<Account> createAccountspartner(Integer intNumOfAccts) {
        List<Account> list_NewAccts = new List<Account>();
        for(Integer i=0; i<intNumOfAccts; i++) {
            Account a = new Account(Name='TestAccount' + i,Screening_Checklist_Completed__c=true,PartnerType__c = 'Cloud Reseller',Partner_Offering_Type__c = 'PureConnect Cloud Reseller');
            list_NewAccts.add(a);
        }
        insert list_NewAccts;
        return list_NewAccts;
    } 
    //*** Method to create contacts //
    public static List<Contact> createContacts(Id acctId, Integer intNumOfConts) {   
        List<Contact> list_NewConts = new List<Contact>();
        for(Integer i=0; i<intNumOfConts; i++) {
            list_NewConts.add(new Contact(LastName=' Contact ' + i,                                   
                                          AccountId=acctId));
        }
        // Insert all contacts for accounts.
        insert list_NewConts;         
        return list_NewConts;
    }
    //*** Method to create opportunities //
    public static List<Opportunity> createOpportunties(Id acctId, Integer intNumOfOpps) {   
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        for(Integer i=0; i<intNumOfOpps; i++) {
            list_NewOpps.add(new Opportunity(Name=' Opportunity ' + i,
                                             StageName='1.Recognize Needs',
                                             CurrencyIsoCode = 'USD',
                                             Sold_To_Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id,
                                             Direct_Sales__c = true,
                                             CloseDate=System.today().addMonths(1),
                                             AccountId=acctId));
        }
        // Insert all opportunities for all accounts.
        insert list_NewOpps;         
        return list_NewOpps;
    }
    
    
     
    
    //*** Method to create opportunities for PureEngage Subcription //
    public static List<Opportunity> createOpportunties2(Id acctId, Integer intNumOfOpps) {   
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        for(Integer i=0; i<intNumOfOpps; i++) {
            list_NewOpps.add(new Opportunity(Name=' Opportunity ' + i,
                                             StageName='1.Recognize Needs',
                                             CurrencyIsoCode = 'USD',
                                             Lines_of_Businesses__c = 'PureEngage Subscription',
                                             Sold_To_Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id,
                                             Direct_Sales__c = true,
                                             CloseDate=System.today().addMonths(1),
                                             AccountId=acctId));
        }
        // Insert all opportunities for all accounts.
        insert list_NewOpps;         
        return list_NewOpps;
    }
    
    public static List<Opportunity> createOpportunties(Id acctId, Integer intNumOfOpps, String strCountry) {   
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        for(Integer i=0; i<intNumOfOpps; i++) {
            list_NewOpps.add(new Opportunity(Name=' Opportunity ' + i,
                                   StageName='1.Recognize Needs',
                                   CurrencyIsoCode = 'USD',
                                   Sold_To_Country__c = [SELECT Id FROM Country__c WHERE Name = :strCountry LIMIT 1].Id,
                                   Direct_Sales__c = true,
                                   CloseDate=System.today().addMonths(1),
                                   AccountId=acctId));
        }
        // Insert all opportunities for all accounts.
        insert list_NewOpps;         
        return list_NewOpps;
    }
    
    public static List<BigMachines__Quote__c> createQuotes(Id oppId, Id acctId, Integer intNumOfQuotes, String strOfferingType) {
        //if (strOfferingType == 'PureCloud') return createPCQuotes(oppId, acctId, intNumOfQuotes);
        List<BigMachines__Quote__c> list_NewQuotes = new List<BigMachines__Quote__c>();
        Map<String, RecordType> map_BMQuoteRecTypes = getOrderRecordTypes('BigMachines__Quote__c');
        for (Integer i=0; i<intNumOfQuotes; i++) {
            BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c(
                                                  RecordTypeId = map_BMQuoteRecTypes.get('Cloud Quote').Id,
                                                  BigMachines__Opportunity__c = oppId, Quote_Created_Date__c = System.today(), 
                                                  BigMachines__Status__c = 'Quote In Progress', BigMachines__Is_Primary__c = true,
                                                  Offering_Type__c = strOfferingType, Service_Level__c = 'Business',  
                                                  Quote_Opportunity_Type__c = 'New Pricing', Duration_Unit__c = 'Months', 
                                                  End_User_ID__c = acctId, BigMachines__Account__c = acctId, No_Of_Months__c = 12, 
                                                  Sold_To_Name__c = acctId, New_Price_Book__c = 'NG5_NA_USD', Delivery_Method__c = 'Electronic', 
                                                  Support_Owner__c = acctId, System_Integrator__c = acctId, Payment_Method__c = 'ACH',
                                                  CurrencyISOCode = 'USD', Quote_Business_Type__c = 'Cloud', Grid_Group_By__c='Categories',
                                                  Expiration_Date__c = Date.today().addDays(90), Pricing_Model__c = 'Named', 
                                                  Group_Product_By__c = 'Standard View', Order_Payment_Terms__c = 'Net 30', 
                                                  Renewal_Subscription_Term__c = 'Automatic Monthly', Order_Type__c = Label.New_Subscription,                                                 
                                                  Initial_Subscription_Term__c = '1 Year', Billing_Category__c = 'Annual Pre-Pay',
                                                  Billing_Period__c = 'Annually', Ramp_Period__c = '90', Approval_Submission_Date__c = Date.today(),
                                                  Billing_Start_Date__c = Date.today(), Subscription_Start_Date__c = Date.today().addDays(90),
                                                  PureCloud_Monthly_Minimum__c = 2000, Subscription_End_Date__c = Date.today().addMonths(12),
                                                  Total_Services__c=0,Total_Contract_Value__c=0,Annual_Contract_Value__c = 100000,Total_Hardware__c = 1000,Total_Education__c = 1000,Setup_Provisioning_Charges__c = 1000);
            list_NewQuotes.add(objNewQuote);            
        }
        insert list_NewQuotes;
        return list_NewQuotes;
    }
    
    //*** Method to create opportunities for PureEngage Subcription //
    public static List<Opportunity> createOpportuntiesPartner(Id acctId, Integer intNumOfOpps) {   
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        for(Integer i=0; i<intNumOfOpps; i++) {
            list_NewOpps.add(new Opportunity(Name=' Opportunity ' + i,
                                             StageName='1.Recognize Needs',
                                             CurrencyIsoCode = 'USD',
                                             Lines_of_Businesses__c = 'PureEngage Subscription',
                                             Sold_To_Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id,
                                             Direct_Indirect_Sale__c = 'Indirect',
                                             BusinessPartner__c = acctId,
                                             Partner_Opportunity_Status__c = 'Approved',
                                             Partner_Opportunity_Source__c = 'Partner Registered Opportunity',
                                             CloseDate=System.today().addMonths(1),
                                             AccountId=acctId));
        }
        // Insert all opportunities for all accounts.
        insert list_NewOpps;         
        return list_NewOpps;
    }
    
    public static list<country__C> createcountry(integer intNumsofCounty){
        List<country__c> list_County = new List<country__C>();
        for(Integer i=0; i<intNumsofCounty; i++) {
            list_County.add(new country__c(Name = 'United States', Country__c='USA', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                           New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'));
        }
        insert list_County;         
        return list_County;
    } 
    
    public static List<Opportunity> createOpportunties1(Id acctId, Id County, Integer intNumOfOpps) {   
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        for(Integer i=0; i<intNumOfOpps; i++) {
            list_NewOpps.add(new Opportunity(Name=' Opportunity ' + i,
                                             StageName='1.Recognize Needs',
                                             CurrencyIsoCode = 'USD',
                                             Sold_To_Country__c = County,
                                             Direct_Sales__c = true,
                                             CloseDate=System.today().addMonths(1),
                                             AccountId=acctId));
        }
        // Insert all opportunities for all accounts.
        insert list_NewOpps;         
        return list_NewOpps;
    }
    //*** Method to create BM pureconnect cloud quotes //
    public static List<BigMachines__Quote__c> createQuotes(Id oppId, Id acctId, Integer intNumOfQuotes) {
        List<BigMachines__Quote__c> list_NewQuotes = new List<BigMachines__Quote__c>();
        Map<String, RecordType> map_BMQuoteRecTypes = getOrderRecordTypes('BigMachines__Quote__c');
        for (Integer i=0; i<intNumOfQuotes; i++) {
            BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c(
                RecordTypeId = map_BMQuoteRecTypes.get('Cloud Quote').Id,
                BigMachines__Opportunity__c = oppId, Quote_Created_Date__c = System.today(), 
                BigMachines__Status__c = 'Quote In Progress', BigMachines__Is_Primary__c = true,
                Product_Tier__c = 'Premium', Offering_Type__c = 'PureConnect Cloud',
                Service_Level__c = 'Business', Pricing_Model__c = 'Enabled', 
                Quote_Opportunity_Type__c = 'New Pricing', Duration_Unit__c = 'Months', 
                Order_Numb_of_Maint_Months__c = 12, Order_Type__c = 'Revenue', 
                End_User_ID__c = acctId, BigMachines__Account__c = acctId, 
                Sold_To_Name__c = acctId, New_Price_Book__c = 'NG5_NA_USD', 
                Support_Owner__c = acctId, System_Integrator__c = acctId, 
                CurrencyISOCode = 'USD', Quote_Business_Type__c = 'Cloud',Top_Play__c = 'Automation at Work',Offer__c = 'Automation at Work - Genesys Workforce Engagement', 
                Expiration_Date__c = Date.today().addDays(90), Deployment_Model__c = 'Local Control',
                Approval_Submission_Date__c = Date.today(),Annual_Contract_Value__c = 1000000,Total_Hardware__c = 1000,Total_Education__c = 1000,Setup_Provisioning_Charges__c = 1000);
            list_NewQuotes.add(objNewQuote);            
        }
        insert list_NewQuotes;
        return list_NewQuotes;
    }
    
    public static List<BigMachines__Quote__c> createQuotes2(Id oppId, Id acctId, Integer intNumOfQuotes) {
        List<BigMachines__Quote__c> list_NewQuotes = new List<BigMachines__Quote__c>();
        Map<String, RecordType> map_BMQuoteRecTypes = getOrderRecordTypes('BigMachines__Quote__c');
        for (Integer i=0; i<intNumOfQuotes; i++) {
            BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c(
                RecordTypeId = map_BMQuoteRecTypes.get('Cloud Quote').Id,
                BigMachines__Opportunity__c = oppId, Quote_Created_Date__c = System.today(), 
                BigMachines__Status__c = 'Quote In Progress', BigMachines__Is_Primary__c = true,
                Product_Tier__c = 'Premium', Offering_Type__c = 'PureConnect Cloud',
                Service_Level__c = 'Business', Pricing_Model__c = 'Enabled', 
                Quote_Opportunity_Type__c = 'New Pricing', Duration_Unit__c = 'Months', 
                Order_Numb_of_Maint_Months__c = 12, Order_Type__c = 'Revenue', 
                End_User_ID__c = acctId, BigMachines__Account__c = acctId, 
                Sold_To_Name__c = acctId, New_Price_Book__c = 'NG5_NA_USD', 
                Support_Owner__c = acctId, System_Integrator__c = acctId, 
                CurrencyISOCode = 'USD', Quote_Business_Type__c = 'Cloud', 
                Expiration_Date__c = Date.today().addDays(90), Deployment_Model__c = 'Local Control',
                Approval_Submission_Date__c = Date.today(),Annual_Contract_Value__c = 1000000,Total_Hardware__c = 1000,Total_Education__c = 1000,Setup_Provisioning_Charges__c = 1000,Ramp_Period__c = '180.8976');
            list_NewQuotes.add(objNewQuote);            
        }
        insert list_NewQuotes;
        return list_NewQuotes;
    }
    
    public static List<BigMachines__Quote__c> createQuotes_Custom(Id oppId, Id acctId, Integer intNumOfQuotes) {
        List<BigMachines__Quote__c> list_NewQuotes = new List<BigMachines__Quote__c>();
        Map<String, RecordType> map_BMQuoteRecTypes = getOrderRecordTypes('BigMachines__Quote__c');
        for (Integer i=0; i<intNumOfQuotes; i++) {
            
            //Removed Product_Tier__c = 'Premium' by Anshul Jain on 27/08/18 as Quote and Opportunity was breaking.
            BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c(
                RecordTypeId = map_BMQuoteRecTypes.get('Cloud Quote').Id,
                BigMachines__Opportunity__c = oppId, Quote_Created_Date__c = System.today(), 
                BigMachines__Status__c = 'Quote In Progress', BigMachines__Is_Primary__c = true,
                Offering_Type__c = 'PureConnect Cloud',
                Service_Level__c = 'Business', Pricing_Model__c = 'Enabled', 
                Quote_Opportunity_Type__c = 'New Pricing', Duration_Unit__c = 'Months', 
                Order_Numb_of_Maint_Months__c = 12, Order_Type__c = 'Revenue', 
                End_User_ID__c = acctId, BigMachines__Account__c = acctId, 
                Sold_To_Name__c = acctId, New_Price_Book__c = 'NG5_NA_USD', 
                Support_Owner__c = acctId, System_Integrator__c = acctId, 
                CurrencyISOCode = 'USD', Quote_Business_Type__c = 'Cloud', 
                Expiration_Date__c = Date.today().addDays(90), Deployment_Model__c = 'Local Control',
                Approval_Submission_Date__c = Date.today());
            
            
            /*BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c(
RecordTypeId = map_BMQuoteRecTypes.get('Cloud Quote').Id,
BigMachines__Opportunity__c = oppId, Quote_Created_Date__c = System.today(), 
BigMachines__Status__c = 'Quote In Progress', BigMachines__Is_Primary__c = true,
Product_Tier__c = 'Premium', Offering_Type__c = 'PureConnect Cloud',
Service_Level__c = 'Business', Pricing_Model__c = 'Enabled', 
Quote_Opportunity_Type__c = 'New Pricing', Duration_Unit__c = 'Months', 
Order_Numb_of_Maint_Months__c = 12, Order_Type__c = 'Revenue', 
End_User_ID__c = acctId, BigMachines__Account__c = acctId, 
Sold_To_Name__c = acctId, New_Price_Book__c = 'NG5_NA_USD', 
Support_Owner__c = acctId, System_Integrator__c = acctId, 
CurrencyISOCode = 'USD', Quote_Business_Type__c = 'Cloud', 
Expiration_Date__c = Date.today().addDays(90), Deployment_Model__c = 'Local Control',
Approval_Submission_Date__c = Date.today());*/
            
            list_NewQuotes.add(objNewQuote);            
        }
        insert list_NewQuotes;
        return list_NewQuotes;
    }
    
    public static List<Product2> createproducts(Integer intNumOfprods) {   
        List<Product2> list_NewProd = new List<Product2>();
        for(Integer i=0; i<intNumOfprods; i++) {
            list_NewProd.add(new Product2(Name='Testproduct' + i,Quantities_Available__c = '1',
                                          Unit_of_Measure__c = 'Seat',Quantity__c = 1 ,Product_Name__c='test',
                                          Taxonomy_Solution_Category__c='Business Optimization', Taxonomy_Solution__c='Integration',
                                          OfferingType__c ='PureEngage Subscription',Shipment_Approval__c='No Approval Required',
                                          Tier__c='Preferred', ProductSubFamily__c = 'Data Center Provisioning',zqu__SKU__c = '123'+ i));
        }
        // Insert all Products for prod.
        insert list_NewProd;         
        return list_NewProd;
    }
    
    //*** Method to create BM pureconnect cloud quote line items //
    public static List<BigMachines__Quote_Product__c> createQuoteProducts(Id quoteId) {
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 
                                        WHERE ProductSubFamily__c = 'Data Center Provisioning' LIMIT 2];
                                         
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            system.debug('product list1'+ list_Products[0]);
            system.debug('product list2'+ list_Products[1]);
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000,Quantity__c=100);
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('product listyyy'+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    public static List<BigMachines__Quote_Product__c> createQuoteProducts2(Id quoteId) {
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 
                                        WHERE ProductSubFamily__c = 'Data Center Provisioning' LIMIT 2];
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            system.debug('product list1'+ list_Products[0]);
            system.debug('product list2'+ list_Products[1]);
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000,List_Price__c=100,Extended_Price_Per_Month__c = 1100,Quantity__c=200);
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('product listyyy'+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    //*** Method to create BM pureconnect cloud quote line items //
    public static List<BigMachines__Quote_Product__c> createQuoteProducts1(Id quoteId) {
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 
                                        WHERE ProductSubFamily__c = 'Data Center Provisioning' LIMIT 2];
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            system.debug('product list1'+ list_Products[0]);
            system.debug('product list2'+ list_Products[1]);
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000, Quantity__c = 100
            );
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('product listyyy'+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    public static List<BigMachines__Quote_Product__c> createQuoteProducts4(Id quoteId) {
        Product_Group__c obj_ProductGroup = new Product_Group__c();
        obj_ProductGroup.Name = 'Equip,Guide,Drive,Partner';
        insert obj_ProductGroup;
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 
                                        WHERE ProductSubFamily__c = 'Data Center Provisioning' LIMIT 3];
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            system.debug('product list1'+ list_Products[0]);
            system.debug('product list2'+ list_Products[1]);
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000, Quantity__c = 100,
                Bundle__c = obj_ProductGroup.Id );
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('product listyyy'+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    public static List<BigMachines__Quote_Product__c> createQuoteProductsforDQ(Id quoteId) {
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = new List<Product2>();
        Product2 objProduct1 = [SELECT Id, Name, APN_Number__c
                                FROM Product2 
                                WHERE ProductSubFamily__c = 'Data Center Provisioning' LIMIT 1];
        list_Products.add(objProduct1);
        Product2 objProduct2 = [SELECT Id, Name, APN_Number__c
                                FROM Product2 
                                WHERE ProductSubFamily__c = 'Base Agent' LIMIT 1];
        list_Products.add(objProduct2);
        Product2 objProduct3 = [SELECT Id, Name, APN_Number__c
                                FROM Product2 
                                WHERE ProductSubFamily__c = 'Hardware' LIMIT 1];
        list_Products.add(objProduct3);
        Product2 objProduct4= [SELECT Id, Name, APN_Number__c
                               FROM Product2 
                               WHERE ProductSubFamily__c = 'Business Users & Add-On Functionality' LIMIT 1];
        list_Products.add(objProduct4);
        Product2 objProduct5= [SELECT Id, Name, APN_Number__c
                               FROM Product2 
                               WHERE Third_Party__c = 'TRUE' LIMIT 1];
        
        list_Products.add(objProduct5);
        
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            system.debug('product list1'+ list_Products[0]);
            system.debug('product list2'+ list_Products[1]);
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000, Quantity__c = 100,Total_Discount__c = 20);
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('product listyyy'+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    public static List<BigMachines__Quote_Product__c> createQuoteProductsforDQPC(Id quoteId) {
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = new List<Product2>();
        Product2 objProduct1 = [SELECT Id, Name, APN_Number__c
                                FROM Product2 
                                WHERE ProductSubFamily__c = 'PROFESSIONAL SERVICES' and Name != null and APN_Number__c != null LIMIT 1];
        list_Products.add(objProduct1);
        Product2 objProduct2 = [SELECT Id, Name, APN_Number__c
                                FROM Product2 
                                WHERE ProductSubFamily__c = 'Software' and Name != null and APN_Number__c != null LIMIT 1];
        list_Products.add(objProduct2);
        Product2 objProduct3 = [SELECT Id, Name, APN_Number__c
                                FROM Product2 
                                WHERE ProductSubFamily__c = 'Hardware' and Name != null and APN_Number__c != null LIMIT 1];
        list_Products.add(objProduct3);
        Product2 objProduct4= [SELECT Id, Name, APN_Number__c
                               FROM Product2 
                               WHERE ProductSubFamily__c = 'Business Users & Add-On Functionality' and Name != null and APN_Number__c != null LIMIT 1];
        list_Products.add(objProduct4);
        Product2 objProduct5= [SELECT Id, Name, APN_Number__c
                               FROM Product2 
                               WHERE Third_Party__c = 'TRUE' LIMIT 1];
        
        list_Products.add(objProduct5);
        
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            system.debug('product list1'+ list_Products[0]);
            system.debug('product list2'+ list_Products[1]);
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000, Quantity__c = 100,Total_Discount__c = 20);
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('product listyyy'+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    public static List<BigMachines__Quote_Product__c> createQuoteProducts5(Id quoteId) {
        Product_Group__c obj_ProductGroup = new Product_Group__c();
        obj_ProductGroup.Name = 'Equip,Guide,Drive,Partner';
        insert obj_ProductGroup;
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = new List<Product2>();
        
        for(Integer i=0;i<3;i++){
            Product2 objProd = new Product2();
            objProd.Name = 'test'+String.valueOf(i);
            objProd.APN_Number__c = '7882922929'+String.valueOf(i);
            objProd.New_Category__c = 'Passthrough';
            objProd.Partner_Margin_Category__c = 'Software';
            list_Products.add(objProd);
        }
        insert list_Products;
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            system.debug('product list1'+ list_Products[0]);
            system.debug('product list2'+ list_Products[1]);
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000, Quantity__c = 100,
                Bundle__c = obj_ProductGroup.Id,List_Price__c = 10 );
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('product listyyy'+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    public static List<BigMachines__Quote_Product__c> createQuoteProducts6(Id quoteId) {
        Product_Group__c obj_ProductGroup = new Product_Group__c();
        obj_ProductGroup.Name = 'Equip,Guide,Drive,Partner';
        insert obj_ProductGroup;
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = new List<Product2>();
        
        for(Integer i=0;i<3;i++){
            Product2 objProd = new Product2();
            objProd.Name = 'test'+String.valueOf(i);
            objProd.APN_Number__c = '7882922929'+String.valueOf(i);
            objProd.New_Category__c = 'Passthrough';
            objProd.Partner_Margin_Category__c = 'Software';
            list_Products.add(objProd);
        }
        insert list_Products;
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            system.debug('product list1'+ list_Products[0]);
            system.debug('product list2'+ list_Products[1]);
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000, Quantity__c = 100,
                Bundle__c = obj_ProductGroup.Id,List_Price__c = 10 );
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('product listyyy'+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    public static List<BigMachines__Quote_Product__c> createQuoteProducts7(Id quoteId) {
        Product_Group__c obj_ProductGroup = new Product_Group__c();
        obj_ProductGroup.Name = 'Equip,Guide,Drive,Partner';
        insert obj_ProductGroup;
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = new List<Product2>();
        List<Product_Tier_Pricing__c> list_ProductTierPricing = new List<Product_Tier_Pricing__c>();
        List<String> list_String= new List<String>();
        list_String.add('Range');
        list_String.add('Rate Plan');
        list_String.add('Editable');
        List<String> list_StringChargeType= new List<String>();
        list_StringChargeType.add('M2M');
        list_StringChargeType.add('Annual M2M');
        list_StringChargeType.add('One-Time');
        for(Integer i=0;i<3;i++){
            Product2 objProd = new Product2();
            objProd.Name = 'test'+String.valueOf(i);
            objProd.APN_Number__c = '7882922929'+String.valueOf(i);
            objProd.New_Category__c = 'Passthrough';
            objProd.Partner_Margin_Category__c = 'Software';
            objProd.Price_Type__c = list_String[i];
            objProd.NG5_NA_USD_Price__c = 100;
            list_Products.add(objProd);
        }
        insert list_Products;
        integer j = 0;
        for(Product2 objProd : list_Products){
            Product_Tier_Pricing__c objProdTierPricing = new Product_Tier_Pricing__c();
            objProdTierPricing.Product__c = objProd.Id;
            objProdTierPricing.Charge_Type__c = list_StringChargeType[j];
            objProdTierPricing.NG5_NA_USD_Price__c = 100;
            list_ProductTierPricing.add(objProdTierPricing);
            j++;
            
        }
        insert list_ProductTierPricing;
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            system.debug('product list1'+ list_Products[0]);
            system.debug('product list2'+ list_Products[1]);
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000, Quantity__c = 100,
                List_Price__c = 10, Is_Overage__c = false );
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('product listyyy'+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    //*** Method to create orders for BM quotes //
    public static List<Order__c> createOrders(Id quoteId, Id oppId, Integer intNumOfOrders){
        List<Order__c> list_NewOrders = new List<Order__c>();
        
        for(Integer i=0; i<intNumOfOrders; i++ ){
            Order__c objNewOrder = new Order__c();
            objNewOrder.Quote__c = quoteId;
            objNewOrder.Maintenance_Start__c = Date.today();
            objNewOrder.Maintenance_End__c = Date.today().addYears(1);
            objNewOrder.Opportunity__c = oppId;
            objNewOrder.Numb_of_Maint_Months__c = 12;
            list_NewOrders.add(objNewOrder);
        }
        
        insert list_NewOrders;
        return list_NewOrders;  
    }
    
    //*** Method to create account order address for Zuora quotes //
    public static List<Account_Order_Address__c> createAOAs(Id quoteId){
        List<Account_Order_Address__c> list_NewAOAs = new List<Account_Order_Address__c>();
        List<String> list_addrTypes = new List<String> {'Bill To', 'End User', 'Ship To', 'Sold To'};
            for(Integer i=0; i<list_addrTypes.size(); i++ ){
                Account_Order_Address__c objNewAOA = new Account_Order_Address__c();
                objNewAOA.Quote__c = quoteId;
                objNewAOA.Address_Type__c = list_addrTypes[i];
                objNewAOA.Address__c = 'Address 1 - '+i;
                objNewAOA.Address2__c = 'Address 2 - '+i;
                objNewAOA.City__c = 'City'+i;
                objNewAOA.State__c = 'State'+i;
                objNewAOA.Country__c = 'US';
                objNewAOA.Sort_Order__c = i+1;
                objNewAOA.Email__c = 'test@test.com';
                list_NewAOAs.add(objNewAOA);
            }
        
        insert list_NewAOAs;
        return list_NewAOAs;  
    }
    
    //*** Method to create account order address for Zuora quotes //
    public static List<Account_Order_Address__c> createAOAsForAccount(Id accountId){
        List<Account_Order_Address__c> list_NewAOAs = new List<Account_Order_Address__c>();
        List<String> list_addrTypes = new List<String> {'Bill To', 'End User', 'Ship To', 'Sold To'};
            for(Integer i=0; i<list_addrTypes.size(); i++ ){
                Account_Order_Address__c objNewAOA = new Account_Order_Address__c();
                objNewAOA.Account__c = accountId;
                objNewAOA.Address_Type__c = list_addrTypes[i];
                objNewAOA.Address__c = 'Address 1 - '+i;
                objNewAOA.Address2__c = 'Address 2 - '+i;
                objNewAOA.City__c = 'City'+i;
                objNewAOA.State__c = 'State'+i;
                objNewAOA.Country__c = 'US';
                objNewAOA.Sort_Order__c = i+1;
                objNewAOA.Email__c = 'test@test.com';
                list_NewAOAs.add(objNewAOA);
            }
        
        insert list_NewAOAs;
        return list_NewAOAs;  
    }
    
    //*** Method to create opportunities //
    public static List<Opportunity> 
    Opportunties(Id acctId, Integer intNumOfOpps) {   
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        for(Integer i=0; i<intNumOfOpps; i++) {
            list_NewOpps.add(new Opportunity(Name=' Opportunity ' + i,
                                             StageName='1.Recognize Needs', CloseDate=System.today().addMonths(1),
                                             CurrencyIsoCode = 'USD', Lines_of_Businesses__c = 'PureCloud',
                                             Sold_To_Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id,
                                             Direct_Sales__c = true, Pricebook2Id = Label.Standard_Pricebook_Id, AccountId=acctId));
        }
        // Insert all opportunities for all accounts.
        insert list_NewOpps;         
        return list_NewOpps;
    }
    
    //*** Method to create BM purecloud quotes //
    public static List<BigMachines__Quote__c> createPCQuotes(Id oppId, Id acctId, Integer intNumOfQuotes) {
        List<BigMachines__Quote__c> list_NewQuotes = new List<BigMachines__Quote__c>();
        Map<String, RecordType> map_BMQuoteRecTypes = getOrderRecordTypes('BigMachines__Quote__c');
        for (Integer i=0; i<intNumOfQuotes; i++) {
            BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c(
                RecordTypeId = map_BMQuoteRecTypes.get('Cloud Quote').Id,
                BigMachines__Opportunity__c = oppId, Quote_Created_Date__c = System.today(), 
                BigMachines__Status__c = 'Quote In Progress', BigMachines__Is_Primary__c = true,
                Offering_Type__c = 'PureCloud', Service_Level__c = 'Business',  
                Quote_Opportunity_Type__c = 'New Pricing', Duration_Unit__c = 'Months', 
                End_User_ID__c = acctId, BigMachines__Account__c = acctId, No_Of_Months__c = 12, 
                Sold_To_Name__c = acctId, New_Price_Book__c = 'NG5_NA_USD', Delivery_Method__c = 'Electronic', 
                Support_Owner__c = acctId, System_Integrator__c = acctId, Payment_Method__c = 'ACH',
                CurrencyISOCode = 'USD', Quote_Business_Type__c = 'Cloud', Grid_Group_By__c='Categories',
                Expiration_Date__c = Date.today().addDays(90), Pricing_Model__c = 'Named', 
                Group_Product_By__c = 'Standard View', Order_Payment_Terms__c = 'Net 30', 
                Renewal_Subscription_Term__c = 'Automatic Monthly', Order_Type__c = Label.New_Subscription,                                                 
                Initial_Subscription_Term__c = '1 Year', Billing_Category__c = 'Annual Pre-Pay',
                Billing_Period__c = 'Annually', Ramp_Period__c = '90', Approval_Submission_Date__c = Date.today(),
                Billing_Start_Date__c = Date.today(), Subscription_Start_Date__c = Date.today().addDays(90),
                PureCloud_Monthly_Minimum__c = 2000, Subscription_End_Date__c = Date.today().addMonths(12),
                Total_Services__c=0,Total_Contract_Value__c=0,Annual_Contract_Value__c = 100000,Total_Hardware__c = 1000,Total_Education__c = 1000,Setup_Provisioning_Charges__c = 1000);
            list_NewQuotes.add(objNewQuote);            
        }
        insert list_NewQuotes;
        return list_NewQuotes;
    }
    
    //*** Method to create BM purecloud quotes //
    public static List<BigMachines__Quote__c> createPCQuotes2(Id oppId, Id acctId, Id acctId2, Integer intNumOfQuotes) {
        List<BigMachines__Quote__c> list_NewQuotes = new List<BigMachines__Quote__c>();
        Map<String, RecordType> map_BMQuoteRecTypes = getOrderRecordTypes('BigMachines__Quote__c');
        for (Integer i=0; i<intNumOfQuotes; i++) {
            BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c(
                RecordTypeId = map_BMQuoteRecTypes.get('Cloud Quote').Id,
                BigMachines__Opportunity__c = oppId, Quote_Created_Date__c = System.today(), 
                BigMachines__Status__c = 'Quote In Progress', BigMachines__Is_Primary__c = true,
                Offering_Type__c = 'PureCloud', Service_Level__c = 'Business',  
                Quote_Opportunity_Type__c = 'New Pricing', Duration_Unit__c = 'Months', 
                End_User_ID__c = acctId, BigMachines__Account__c = acctId, No_Of_Months__c = 12, 
                Sold_To_Name__c = acctId2,New_Price_Book__c = 'NG5_NA_USD', Delivery_Method__c = 'Electronic', 
                Support_Owner__c = acctId, System_Integrator__c = acctId, Payment_Method__c = 'ACH',
                CurrencyISOCode = 'USD', Quote_Business_Type__c = 'Cloud', Grid_Group_By__c='Categories',
                Expiration_Date__c = Date.today().addDays(90), Pricing_Model__c = 'Named', 
                Group_Product_By__c = 'Standard View', Order_Payment_Terms__c = 'Net 30', 
                Renewal_Subscription_Term__c = 'Automatic Monthly', Order_Type__c = Label.New_Subscription,                                                 
                Initial_Subscription_Term__c = '1 Year', Billing_Category__c = 'Annual Pre-Pay',
                Billing_Period__c = 'Annually', Ramp_Period__c = '90', Approval_Submission_Date__c = Date.today(),
                Billing_Start_Date__c = Date.today(), Subscription_Start_Date__c = Date.today().addDays(90),
                PureCloud_Monthly_Minimum__c = 2000, Subscription_End_Date__c = Date.today().addMonths(12),
                Total_Services__c=0,Total_Contract_Value__c=0,Annual_Contract_Value__c = 100000,Total_Hardware__c = 1000,Total_Education__c = 1000,Setup_Provisioning_Charges__c = 1000);
            list_NewQuotes.add(objNewQuote);            
        }
        insert list_NewQuotes;
        Partner_Discount__c objPartnerDiscount = new Partner_Discount__c(Category__c='Base Line Discount', Discount__c =10, type__c = 'PureConnect Cloud',Account__c =acctId2 );
        insert objPartnerDiscount;
        return list_NewQuotes;
    }
    
    //*** Method to create BM purecloud quote line items //
    public static List<BigMachines__Quote_Product__c> createPCQuoteProducts(Id quoteId) {
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        Set<String> set_ProdAPNs = new Set<String>{'PC-170-NV-USR1', 'PS-170-PURE-SVTOKEN', 'PC-170-NV-PCPENTST', 
            'TH-900-PCEDGE-2120200', 'ED-012-NV-WEXV', 'PCSMS-170-NV-SMS', 
            'PC-170-NV-PCEDGE-VIR', 'PV-170-NV-PCVOICE','3GP00209AAAA'};
                List<Product2> list_Products = [SELECT Id, Name, APN_Number__c, NG5_NA_USD_Price__c,Sub_Type__c,Include_in_CMMR_Total__c
                                                FROM Product2 
                                                WHERE APN_Number__c IN :set_ProdAPNs];
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            prod.NG5_NA_USD_Price__c = prod.NG5_NA_USD_Price__c == null ? 1 : prod.NG5_NA_USD_Price__c;
            BigMachines__Quote_Product__c objNewOvgQuoteProduct = new BigMachines__Quote_Product__c();
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                Quantity__c=1, BigMachines__Quantity__c=1, BigMachines__Sales_Price__c=prod.NG5_NA_USD_Price__c,
                List_Price__c=prod.NG5_NA_USD_Price__c,Net_Unit_Price__c=prod.NG5_NA_USD_Price__c,
                Ext_List__c=1*prod.NG5_NA_USD_Price__c,Ext_Net_Price__c=1*prod.NG5_NA_USD_Price__c,
                Is_Overage__c=false);
            
            if(prod.APN_Number__c == 'PC-170-NV-PCEDGE-VIR') {
                objNewQuoteProduct.Is_Overage__c = true;
            }
            list_NewQuoteProducts.add(objNewQuoteProduct);                      
            
            if(prod.APN_Number__c == 'PC-170-NV-USR1') {
                objNewOvgQuoteProduct = objNewQuoteProduct.clone(false, true, false, false);
                objNewOvgQuoteProduct.Is_Overage__c = true;
                list_NewQuoteProducts.add(objNewOvgQuoteProduct);
            }      
        }
        system.debug('product list: '+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
      // ECD PEC Quote July 2019
    public static List<BigMachines__Quote_Product__c> createPECQuoteProducts(Id quoteId) {
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        Set<String> set_ProdAPNs = new Set<String>{'3GP21966ABAA', '3GP89325ABAA', '3GP89322ABAA', 
                                                   'PEC-OTC-PureSuccess'};
        List<Product2> list_Products = [SELECT Id, Name, APN_Number__c, NG5_NA_USD_Price__c 
                                        FROM Product2 
                                        WHERE APN_Number__c IN :set_ProdAPNs];
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            prod.NG5_NA_USD_Price__c = prod.NG5_NA_USD_Price__c == null ? 1 : prod.NG5_NA_USD_Price__c;
            BigMachines__Quote_Product__c objNewOvgQuoteProduct = new BigMachines__Quote_Product__c();
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                                                  BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                                                  Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                                                  Quantity__c=1, BigMachines__Quantity__c=1, BigMachines__Sales_Price__c=prod.NG5_NA_USD_Price__c,
                                                  List_Price__c=prod.NG5_NA_USD_Price__c,Net_Unit_Price__c=prod.NG5_NA_USD_Price__c,
                                                  Ext_List__c=1*prod.NG5_NA_USD_Price__c,Ext_Net_Price__c=1*prod.NG5_NA_USD_Price__c,
                                                  Is_Overage__c=false);
            
            if(prod.APN_Number__c == 'PC-170-NV-PCEDGE-VIR') {
                objNewQuoteProduct.Is_Overage__c = true;
            }
            list_NewQuoteProducts.add(objNewQuoteProduct);                      
            
            if(prod.APN_Number__c == 'PC-170-NV-USR1') {
                objNewOvgQuoteProduct = objNewQuoteProduct.clone(false, true, false, false);
                objNewOvgQuoteProduct.Is_Overage__c = true;
                list_NewQuoteProducts.add(objNewOvgQuoteProduct);
            }      
        }
        system.debug('product list: '+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    //*** Method to create BM purecloud quote line items //
    public static List<BigMachines__Quote_Product__c> createPCQuoteProducts2(Id quoteId) {
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        Set<String> set_ProdAPNs = new Set<String>{'PC-170-NV-USR1', 'PS-170-PURE-SVTOKEN', 'PC-170-NV-PCPENTST', 
            'TH-900-PCEDGE-2120200', 'ED-012-NV-WEXV', 'PCSMS-170-NV-SMS', 
            'PC-170-NV-PCEDGE-VIR', 'PV-170-NV-PCVOICE','CS-012-NV-AD05',
            'PT SERVICES','CS-012-NV-AR01','SY-014-4.0-IE00-B01','SY-014-4.0-IE00-B01','PEC-D-GUIDE'};
                List<Product2> list_Products = [SELECT Id, Name, APN_Number__c, NG5_NA_USD_Price__c 
                                                FROM Product2 
                                                WHERE APN_Number__c IN :set_ProdAPNs];
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            prod.NG5_NA_USD_Price__c = prod.NG5_NA_USD_Price__c == null ? 1 : prod.NG5_NA_USD_Price__c;
            BigMachines__Quote_Product__c objNewOvgQuoteProduct = new BigMachines__Quote_Product__c();
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                Quantity__c=1, BigMachines__Quantity__c=1, BigMachines__Sales_Price__c=prod.NG5_NA_USD_Price__c,
                List_Price__c=prod.NG5_NA_USD_Price__c,Net_Unit_Price__c=prod.NG5_NA_USD_Price__c,
                Ext_List__c=1*prod.NG5_NA_USD_Price__c,Ext_Net_Price__c=1*prod.NG5_NA_USD_Price__c,
                Is_Overage__c=false);
            
            if(prod.APN_Number__c == 'PC-170-NV-PCEDGE-VIR') {
                objNewQuoteProduct.Is_Overage__c = true;
            }
            list_NewQuoteProducts.add(objNewQuoteProduct);                      
            
            if(prod.APN_Number__c == 'PC-170-NV-USR1') {
                objNewOvgQuoteProduct = objNewQuoteProduct.clone(false, true, false, false);
                objNewOvgQuoteProduct.Is_Overage__c = true;
                list_NewQuoteProducts.add(objNewOvgQuoteProduct);
            }      
        }
        system.debug('product list: '+ list_NewQuoteProducts);
        
        return list_NewQuoteProducts;
    }
    
    //*** Method to create orders for BM PC quotes //
    public static List<Order__c> createPCOrders(Id quoteId, Id oppId, Integer intNumOfOrders){
        List<Order__c> list_NewOrders = new List<Order__c>();
        
        for(Integer i=0; i<intNumOfOrders; i++ ){
            Order__c objNewOrder = new Order__c();
            objNewOrder.Quote__c = quoteId;
            objNewOrder.Maintenance_Start__c = Date.today();
            objNewOrder.Maintenance_End__c = Date.today().addYears(1);
            objNewOrder.Opportunity__c = oppId;
            objNewOrder.Numb_of_Maint_Months__c = 12;
            objNewOrder.Status__c = 'Order Submitted';
            list_NewOrders.add(objNewOrder);
        }
        
        insert list_NewOrders;
        return list_NewOrders;  
    }   
    
    //*** Method to create orders for PureEngage Subscription //
    public static List<Order__c> createOrders2(Id quoteId, Id oppId, Integer intNumOfOrders){
        List<Order__c> list_NewOrders = new List<Order__c>();
        
        for(Integer i=0; i<intNumOfOrders; i++ ){
            Order__c objNewOrder = new Order__c();
            objNewOrder.Quote__c = quoteId;
            objNewOrder.Maintenance_Start__c = Date.today();
            objNewOrder.Maintenance_End__c = Date.today().addYears(1);
            objNewOrder.Opportunity__c = oppId;
            objNewOrder.Numb_of_Maint_Months__c = 12;
            objNewOrder.Status__c = 'Order Submitted';
            objNewOrder.Generate_Subscription_Record__c = false;
            objNewOrder.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Cloud Billing Master Order').getRecordTypeId();
            objNewOrder.Ship_software_via__c = 'pickup';
            objNewOrder.Status__c = 'Send to ERP';
            list_NewOrders.add(objNewOrder);
        }
        
        insert list_NewOrders;
        return list_NewOrders;  
    }  
    
    public static List<Order__c> createOrders4(Id quoteId, Id oppId, Integer intNumOfOrders){
        List<Order__c> list_NewOrders = new List<Order__c>();
        
        for(Integer i=0; i<intNumOfOrders; i++ ){
            Order__c objNewOrder = new Order__c();
            objNewOrder.Quote__c = quoteId;
            objNewOrder.Maintenance_Start__c = Date.today();
            objNewOrder.Maintenance_End__c = Date.today().addYears(1);
            objNewOrder.Opportunity__c = oppId;
            objNewOrder.Numb_of_Maint_Months__c = 12;
            objNewOrder.Status__c = 'Order Submitted';
            objNewOrder.Generate_Subscription_Record__c = false;
            objNewOrder.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Hardware Order').getRecordTypeId();
            objNewOrder.Ship_software_via__c = 'pickup';
            objNewOrder.Status__c = 'Send to ERP';
            objNewOrder.Bypass_Service_Contract__c = false;
            objNewOrder.License_FYM_Detail__c = 'Hardware Order';
            list_NewOrders.add(objNewOrder);
        }
        
        insert list_NewOrders;
        return list_NewOrders;  
    } 
    
    public static Order_Line_Item__c createOrderLineItems(Order__c objOrder) {
        
        Order_Line_Item__c objOrderLineItem = new Order_Line_Item__c();
        objOrderLineItem.Contract_Line_Update_Status__c = 'Drop,Split';
        objOrderLineItem.Order__c = objOrder.Id;
        insert objOrderLineItem;
        return objOrderLineItem;
    }
    
    //*** Method to create orders for PureEngage Subscription //
    public static List<Order__c> createOrders3(Id quoteId, Id oppId, Integer intNumOfOrders){
        List<Order__c> list_NewOrders = new List<Order__c>();
        
        for(Integer i=0; i<intNumOfOrders; i++ ){
            Order__c objNewOrder = new Order__c();
            objNewOrder.Quote__c = quoteId;
            objNewOrder.Maintenance_Start__c = Date.today();
            objNewOrder.Maintenance_End__c = Date.today().addYears(1);
            objNewOrder.Opportunity__c = oppId;
            objNewOrder.Numb_of_Maint_Months__c = 12;
            objNewOrder.Status__c = 'Order Submitted';
            objNewOrder.Generate_Subscription_Record__c = false;
            objNewOrder.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('PPU Order').getRecordTypeId();
            list_NewOrders.add(objNewOrder);
        }
        insert list_NewOrders;
        return list_NewOrders;  
    } 
    //*** Method to create BM pureconnect cloud quotes //
    public static List<zqu__Quote__c> createZuoraQuotes(Id oppId, Id acctId, Integer intNumOfQuotes) {
        List<zqu__Quote__c> list_NewQuotes = new List<zqu__Quote__c>();
        for (Integer i=0; i<intNumOfQuotes; i++) {
            zqu__Quote__c objNewQuote = new zqu__Quote__c(zqu__Account__c=acctId, zqu__ApprovalStatus__c='Quote In Progress',
                                                          zqu__Currency__c='USD', Customer_PO_Not_Required__c=true, 
                                                          zqu__Opportunity__c=oppId, zqu__StartDate__c=System.today()+10, 
                                                          zqu__Primary__c=true, zqu__QuoteBusinessType__c='New',
                                                          zqu__Status__c='New', zqu__PaymentTerm__c='Net 30');
            list_NewQuotes.add(objNewQuote);            
        }
        insert list_NewQuotes;
        return list_NewQuotes;
    }
    
    //*** Method to create PureCloud quote line items //
    public static List<zqu__QuoteChargeDetail__c> createZuoraQuoteProducts(Id quoteId) {
        List<zqu__QuoteChargeDetail__c> list_NewQuoteProducts = new List<zqu__QuoteChargeDetail__c>();
        List<zqu__ProductRatePlanCharge__c> list_ProdRtPlChrge = [SELECT Id, zqu__ProductRatePlan__c
                                                                  FROM zqu__ProductRatePlanCharge__c 
                                                                  WHERE zqu__ProductRatePlan__r.zqu__Product__r.OfferingType__c INCLUDES ('PureCloud') LIMIT 1];  
        for(Integer i=0; i<list_ProdRtPlChrge.size(); i++) {
            zqu__QuoteChargeDetail__c objNewQuoteProduct = new zqu__QuoteChargeDetail__c(
                zqu__Quote__c=quoteId, zqu__ProductRatePlanCharge__c=list_ProdRtPlChrge[i].Id,
                zqu__ProductRatePlan__c=list_ProdRtPlChrge[i].zqu__ProductRatePlan__c);
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('$$$$$$'+list_NewQuoteProducts.size());
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    public static List<zqu__QuoteRatePlanCharge__c> setupQuoteRatePlanCharges(zqu__Quote__c objQuote, boolean doInsert)
    {
        List<zqu__QuoteRatePlanCharge__c> list_ZQRPCs = new List<zqu__QuoteRatePlanCharge__c>();
        Map<Id, zqu__QuoteRatePlan__c> map_ZuoraQuoteRatePlan = new Map<Id, zqu__QuoteRatePlan__c>();
        Map<Id, zqu__ProductRatePlanCharge__c> map_ZuoraProductRatePlanCharges = new Map<Id, zqu__ProductRatePlanCharge__c>();
        
        List<zqu__QuoteRatePlan__c> list_ZuoraQuoteRatePlans = setupZuoraQuoteRatePlans(objQuote, true);
        System.assert(list_ZuoraQuoteRatePlans[0].Id != NULL);
        
        List<zqu__ProductRatePlan__c> list_ZuoraProductRatePlans = setupZuoraProductRatePlans(list_ZuoraQuoteRatePlans, true);
        System.assert(list_ZuoraProductRatePlans[0].Id != NULL);
        
        List<zqu__ProductRatePlanCharge__c> list_ZuoraProductRatePlanCharges = setupZuoraProductRatePlanCharges(list_ZuoraProductRatePlans, true);
        System.assert(list_ZuoraProductRatePlanCharges[0].Id != NULL);
        
        List<Id> list_ids = new List<Id>();
        for(zqu__ProductRatePlanCharge__c obj : list_ZuoraProductRatePlanCharges){
            list_ids.add(obj.Id);
        }
        
        list_ZuoraProductRatePlanCharges =  [SELECT Id , zqu__ProductRatePlan__r.zqu__Product__c
                                             FROM zqu__ProductRatePlanCharge__c WHERE Id  IN :list_ids];
        
        
        for(zqu__QuoteRatePlan__c objQRP : list_ZuoraQuoteRatePlans){
            map_ZuoraQuoteRatePlan.put(objQRP.zqu__Product__c, objQRP);            
        }
        
        for(zqu__ProductRatePlanCharge__c objPRPC : list_ZuoraProductRatePlanCharges){
            map_ZuoraProductRatePlanCharges.put(objPRPC.zqu__ProductRatePlan__r.zqu__Product__c, objPRPC);
        }
        for(Id idProd : map_ZuoraProductRatePlanCharges.keySet()){
            zqu__QuoteRatePlanCharge__c objZQRPC = new zqu__QuoteRatePlanCharge__c();
            objZQRPC.zqu__ProductRatePlanCharge__c = map_ZuoraProductRatePlanCharges.get(idProd).Id;
            objZQRPC.zqu__Discount__c = 1;
            objZQRPC.zqu__EffectivePrice__c = 1;
            objZQRPC.zqu__Quantity__c = 1;
            objZQRPC.zqu__UOM__c = 'test UOM';
            objZQRPC.Partner_Price__c = 10;
            objZQRPC.zqu__QuoteRatePlan__c = map_ZuoraQuoteRatePlan.get(idProd).Id;
            list_ZQRPCs.add(objZQRPC);
        }
        if(doInsert)
            insert list_ZQRPCs;
        return list_ZQRPCs;
    }
    
    public static List<zqu__ProductRatePlanCharge__c> setupZuoraProductRatePlanCharges(List<zqu__ProductRatePlan__c> list_ZuoraProductRatePlans, boolean doInsert)
    {
        
        List<zqu__ZUnitOfMeasure__c> list_UOMs = new List<zqu__ZUnitOfMeasure__c>(); 
        
        for(integer i = 0 ; i< list_ZuoraProductRatePlans.size() ; i++){
            zqu__ZUnitOfMeasure__c  objUOM = new zqu__ZUnitOfMeasure__c();
            objUOM.zqu__Active__c = true;
            //objUOM.zqu__BillingEntity__c = onBillingEntity.Id;
            objUOM.zqu__Uom_rounding_mode__c = 'Up';
            objUOM.zqu__UOMFullName__c = 'test'+i;
            list_UOMs.add(objUOM);
        }
        insert list_UOMs ; 
        System.assert(list_UOMs[0].Id != NULL);
        
        List<zqu__ProductRatePlanCharge__c> list_ProductRatePlanCharges = new List<zqu__ProductRatePlanCharge__c>();
        
        for(zqu__ProductRatePlan__c objProductRatePlan : list_ZuoraProductRatePlans){
            zqu__ProductRatePlanCharge__c objPRPC = new zqu__ProductRatePlanCharge__c();
            
            objPRPC.zqu__ProductRatePlan__c = objProductRatePlan.Id;
            list_ProductRatePlanCharges.add(objPRPC);
        }
        
        if(doInsert)
            insert list_ProductRatePlanCharges;
        return list_ProductRatePlanCharges;
    } 
    
    public static List<zqu__QuoteRatePlan__c> setupZuoraQuoteRatePlans(zqu__Quote__c objQuote, boolean doInsert){
        
        List<zqu__QuoteRatePlan__c> list_ZuoraQuoteRatePlans = new  List<zqu__QuoteRatePlan__c>();
        
        zqu__QuoteAmendment__c  objQA = new zqu__QuoteAmendment__c(zqu__Quote__c = objQuote.Id);        
        insert objQA;
        
        List<Product2> list_Products = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 
                                        WHERE OfferingType__c Includes ('PureCloud')
                                        AND ProductShippable__c='Yes' LIMIT 2];
        
        for(Product2 objProduct : list_Products){
            zqu__QuoteRatePlan__c objQuoteRatePlan = new zqu__QuoteRatePlan__c();
            objQuoteRatePlan.zqu__Product__c = objProduct.Id;
            objQuoteRatePlan.zqu__Quote__c = objQuote.Id;
            objQuoteRatePlan.zqu__QuoteAmendment__c = objQA.Id;
            list_ZuoraQuoteRatePlans.add(objQuoteRatePlan);
        }
        if(doInsert)
            insert list_ZuoraQuoteRatePlans;
        return list_ZuoraQuoteRatePlans;
    }
    
    
    public static List<zqu__ProductRatePlan__c> setupZuoraProductRatePlans(List<zqu__QuoteRatePlan__c> list_ZuoraQuoteRatePlans, boolean doInsert){
        
        List<zqu__ZProduct__c> list_ZProduct = new List<zqu__ZProduct__c>();
        for(zqu__QuoteRatePlan__c objQuoteRate : list_ZuoraQuoteRatePlans){
            list_ZProduct.add(new zqu__ZProduct__c(zqu__Active__c = true , zqu__Deleted__c = false, zqu__EffectiveStartDate__c = Date.newInstance(2017, 1, 1), 
                                                   zqu__Product__c = objQuoteRate.zqu__Product__c));
        }
        
        insert list_ZProduct;
        
        Map<Id,zqu__ZProduct__c> map_ZProducts = new Map<Id,zqu__ZProduct__c>();
        
        for(zqu__ZProduct__c obj : list_ZProduct){
            map_ZProducts.put(obj.zqu__Product__c , obj);
        }
        
        List<zqu__ProductRatePlan__c> list_ZuoraProductRatePlans = new List<zqu__ProductRatePlan__c>();
        
        for(zqu__QuoteRatePlan__c objQuoteRate : list_ZuoraQuoteRatePlans){
            zqu__ProductRatePlan__c objProductRatePlan = new zqu__ProductRatePlan__c();
            objProductRatePlan.zqu__Product__c = objQuoteRate.zqu__Product__c;
            objProductRatePlan.zqu__ZProduct__c = map_ZProducts.get(objQuoteRate.zqu__Product__c).Id;
            objProductRatePlan.zqu__EffectiveStartDate__c = Date.newInstance(2017, 1, 1);
            objProductRatePlan.zqu__EffectiveEndDate__c = Date.newInstance(2017, 12, 1);
            list_ZuoraProductRatePlans.add(objProductRatePlan);
        }
        if(doInsert)
            insert list_ZuoraProductRatePlans;
        return list_ZuoraProductRatePlans;
    }
    
    //*** Method to create orders for Zuora quotes //
    public static List<Order__c> createPureCloudOrders(Id quoteId, Id oppId, Integer intNumOfOrders){
        List<Order__c> list_NewOrders = new List<Order__c>();
        
        for(Integer i=0; i<intNumOfOrders; i++ ){
            Order__c objNewOrder = new Order__c();
            objNewOrder.Zuora_Quote__c = quoteId;
            objNewOrder.Maintenance_Start__c = Date.today();
            objNewOrder.Maintenance_End__c = Date.today().addYears(1);
            objNewOrder.Opportunity__c = oppId;
            objNewOrder.Numb_of_Maint_Months__c = 12;
            list_NewOrders.add(objNewOrder);
        }
        
        insert list_NewOrders;
        return list_NewOrders;  
    }
    
    //*** Method to create account order address for Zuora quotes //
    public static List<Account_Order_Address__c> createPureCloudAOAs(Id quoteId){
        List<Account_Order_Address__c> list_NewAOAs = new List<Account_Order_Address__c>();
        List<String> list_addrTypes = new List<String> {'Bill To', 'End User', 'Ship To', 'Sold To'};
            for(Integer i=0; i<list_addrTypes.size(); i++ ){
                Account_Order_Address__c objNewAOA = new Account_Order_Address__c();
                objNewAOA.Zuora_Quote__c = quoteId;
                objNewAOA.Address_Type__c = list_addrTypes[i];
                objNewAOA.Address__c = 'Address 1 - '+i;
                objNewAOA.Address2__c = 'Address 2 - '+i;
                objNewAOA.City__c = 'City'+i;
                objNewAOA.State__c = 'State'+i;
                objNewAOA.Country__c = 'US';
                objNewAOA.Sort_Order__c = i+1;
                objNewAOA.Email__c = 'test@test.com';
                list_NewAOAs.add(objNewAOA);
            }
        
        insert list_NewAOAs;
        return list_NewAOAs;  
    }
    
    // *** Method to pull record types of a sobject ***
    private static Map<String, RecordType> getOrderRecordTypes(String strObjType) {
        Map<String, RecordType> map_rts = new Map<String, RecordType>();
        for(RecordType recType : [SELECT Id, Name FROM RecordType WHERE SobjectType =: strObjType]) {
            map_rts.put(recType.Name, recType);
        }
        return map_rts;
    }
    
    
        public static List<BigMachines__Quote_Product__c> createSubscriptionBurstQuoteProducts(Id quoteId) {
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        Product_Group__c obj_ProductGroup = new Product_Group__c();
        obj_ProductGroup.Name = 'Equip,Guide,Drive,Partner';
        insert obj_ProductGroup;
               List<Product2> list_Products = new List<Product2>();
        for(Integer i=0; i<5; i++) {
            list_Products.add(new Product2(Name='Testproduct' + i,Quantities_Available__c = '1',
                                          Unit_of_Measure__c = 'Seat',Quantity__c = 1 ,Product_Name__c='test',
                                          Taxonomy_Solution_Category__c='Business Optimization', Taxonomy_Solution__c='Integration',
                                          OfferingType__c ='PureEngage Subscription',Shipment_Approval__c='No Approval Required',
                                          Tier__c='Preferred',Seasonal_Licensing_Eligible__c=true,ProductSubFamily__c = 'Data Center Provisioning',zqu__SKU__c = '123'+ i));
        }
        // Insert all Products for prod.
        insert list_Products;      
                                        
        system.debug('product list'+ list_Products);
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            system.debug('product list1'+ list_Products[0]);
            system.debug('product list2'+ list_Products[1]);
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,Bundle__c=obj_ProductGroup.id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000,Quantity__c=100);
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('product listyyy'+ list_NewQuoteProducts);
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }

}