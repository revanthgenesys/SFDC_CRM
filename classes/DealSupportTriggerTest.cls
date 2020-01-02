@isTest(SeeAllData = true)
public class DealSupportTriggerTest {
    static testmethod void testDealSupport(){
        Test.startTest();
        List<Opportunity> opportunities = [SELECT id, Name, BusinessPartner__c, OwnerId FROM Opportunity WHERE BusinessPartner__c != NULL AND Owner.isActive = true LIMIT 1]; 
        Deal_Support__c ds = new Deal_Support__c(Opportunity__c = opportunities[0].Id, Support_Area__c = 'Business Consulting', Request_Type__c = 'Business Consulting Inquiry', Subject__c = 'test', Description__c = 'test');
        insert ds;

        try{
            ds.Support_Area__c = 'Product Management';
            update ds;
        } catch(Exception ve1){
            // Validation Exception expected ...
        }      
        
        try{
            ds.Support_Area__c = 'Business Consulting';
            ds.Request_Type__c = 'Business Consulting Inquiry';
            update ds;
            
        } catch(Exception ve3){
            // Validation Exception expected ...
        }   

        try{
            ds.Support_Area__c = 'Product Management';
            ds.Request_Type__c = 'End of Life information';
            ds.Solution_Category__c = 'Integration';
            ds.Product__c = 'Third Party Connectors';
            update ds;
        } catch(Exception ve2){
            // Validation Exception expected ...
        }      

        try{
            ds.Support_Area__c = 'Business Consulting';
            ds.Request_Type__c = 'Business Consulting Inquiry';
            update ds;
            
        } catch(Exception ve3){
            // Validation Exception expected ...
        }   
        
        try{
            ds.Support_Area__c = 'Product Management';
            ds.Request_Type__c = 'Roadmap Inquiry/Support';
            ds.Solution_Category__c = 'Integration';
            ds.Product__c = 'Third Party Connectors';
            update ds;
        } catch(Exception ve3){
            // Validation Exception expected ...
        }   

        try{
            ds.Support_Area__c = 'Product Management';
            ds.Request_Type__c = 'Roadmap Inquiry/Support';
            ds.Solution_Category__c = 'Integration';
            ds.Product__c = 'Third Party Connectors ...';
            update ds;
        } catch(Exception ve3){
            // Validation Exception expected ...
        }   
        
        try{
            ds.Support_Area__c = 'Business Consulting';
            ds.Request_Type__c = 'Business Consulting Inquiry';
            update ds;
            
        } catch(Exception ve3){
            // Validation Exception expected ...
        }   
        
        try{ 
            ds.Support_Area__c = 'Customer Care';
            ds.Request_Type__c = 'Compliance';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 
         
        try{ 
            ds.Support_Area__c = 'Deal Factory';
            ds.Country_Name__c = 'United States';
            ds.Request_Type__c = 'Net Pricing';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 
         
        try{ 
            ds.Support_Area__c = 'Finance';
            ds.Country_Name__c = 'Brazil';
            ds.Request_Type__c = 'Order Management On Premise';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 

        try{ 
            ds.Support_Area__c = 'ININ Sales Support';
            ds.Request_Type__c = 'General Inquiry';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 

        try{ 
            ds.Support_Area__c = 'Pricing';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 

        try{ 
            ds.Support_Area__c = 'Professional Services';
            ds.Request_Type__c = 'General Inquiry';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 

        try{ 
            ds.Support_Area__c = 'Sales Ops';
            ds.Request_Type__c = 'Training';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 
        
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 3 Digital Service';
            ds.P2P_Region__c = 'EMEA';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 3 Digital Service';
            ds.P2P_Region__c = 'APAC';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 3 Digital Service';
            ds.P2P_Region__c = 'LATAM';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        }
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 3 Digital Service';
            ds.P2P_Region__c = 'NA';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        }
        
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 4 Digital Sales';
            ds.P2P_Region__c = 'EMEA';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        }
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 4 Digital Sales';
            ds.P2P_Region__c = 'LATAM';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        }
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 4 Digital Sales';
            ds.P2P_Region__c = 'APAC';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        }
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 4 Digital Sales';
            ds.P2P_Region__c = 'NA';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        }
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 5 Automation at Work';
            ds.P2P_Region__c = 'EMEA';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        }
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 5 Automation at Work';
            ds.P2P_Region__c = 'LATAM';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        }
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 5 Automation at Work';
            ds.P2P_Region__c = 'LATAM';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        }
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Play Assistance';
            ds.Primary_Play__c = '2019 Play 5 Automation at Work';
            ds.P2P_Region__c = 'NA';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        }
        
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Migrations Assistance';
            ds.P2P_Region__c = 'EMEA';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Migrations Assistance';
            ds.P2P_Region__c = 'APAC';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 
        
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Migrations Assistance';
            ds.P2P_Region__c = 'LATAM';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 
        
        try{ 
            ds.Support_Area__c = 'Play Support';
            ds.Request_Type__c = 'Migrations Assistance';
            ds.P2P_Region__c = 'NA';
            update ds;
        } catch(Exception ve){
            // any exception handle here ...
        } 
        Test.stopTest();
    }   
    
    //to test DealSupportTrigger to test official Cancellation Date test added by 16/12/2019 by Malavika - INC0439133
    static testmethod void testDealSupport1(){
            Account acc = new Account(Name = 'Test Account',Status__c='Active', Type='Customer',CurrencyIsoCode='USD');
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity';
            opp.AccountId = acc.Id;
            opp.StageName = 'Prospecting';
            opp.CloseDate = Date.today();
            opp.AccountId = acc.Id;
            opp.Probability = 0;
            insert opp;
            
            Deal_Support__c ds = new Deal_Support__c(Opportunity__c = opp.Id, Support_Area__c = 'Sales Ops', Request_Type__c = 'Data Management', Subject__c = 'test', Description__c = 'test',Offering_Type__c = 'Pure Cloud',Trial_Evaluation__c = 'No',Focus_Area__c = 'Account',Requested_Action__c = 'Inactivate Line of Business',Official_Cancelation_Date__c=Date.Today());
            insert ds;
 
             Test.starttest();
             ds.Official_Cancelation_Date__c=ds.Official_Cancelation_Date__c.addDays(2);
             update ds;
             test.stoptest();
    }
     
}