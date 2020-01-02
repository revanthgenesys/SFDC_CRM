/***************************************************************************************************************************************
    Class:          UserWorkload
    
    Description:    Calculates the workload score for a list of users. Workload score is based on the 
                    cases owned by the user. Code is designed to run async & is called by a case trigger 
                    when owners change or when new cases are inserted.
    
    Author:         Jeremy Henson                   
    
****************************************************************************************************************************************/
/*@isTest(seeAllData=true)*/
public class UserWorkload {

    
    @future 
    public static void calculateWorkloadFuture(Set<id> userIds){
        calculateWorkload(userIds);
    }

    public static void calculateWorkload(Set<id> userIds){
    final double noskillscore = 2.5;
        List<User> updateUsers = new List<User>{};
        
    //  Map User to Cases (cant do as a nested query of user)
    //  ---------------------------------------------------------------------------------------------------------
        Map<Id, List<Case>> userTOcases = new Map<Id, List<Case>>{};
        for(Case c : [select id, OwnerId, Support_Product__c, Case_Priority_Score__c, Sub_Status_Score__c from Case
                        where OwnerId in: userIds
                        and IsClosed = false]){
                        
                        List<Case> ownersCases = new List<Case>{};
                        if(userTOcases.get(c.OwnerId) != null)ownersCases.addAll(userTOcases.get(c.OwnerId));                       
                        ownersCases.add(c);
                        userTOcases.put(c.ownerId, ownersCases);    
                            
        }
        
    //  Calc score for all the users
    //  ---------------------------------------------------------------------------------------------------------
        for(User u : [select id, 
                        (select Support_Product__c, Skill_Score__c From Genesys_Agent_Skills__r)
                        from User
                        where id in: userIds]){
        
                    //  Map the users products to skills
                        Map<Id, Double> productTOscore = new Map<Id, Double>{};
                        for(Customer_Care_Analyst_Skill__c skill : u.Genesys_Agent_Skills__r){
                            productTOscore.put(skill.Support_Product__c, skill.Skill_Score__c);
                        }
                                                
                    //  Calc scores
                        Double workloadScore = 0;
                        String debug =  'Case Id, Total Score, Product Score, Priority Score, Sub Status Score \r\n';
                        if(userTOcases.get(u.id) != null){
                            for(Case c : userTOcases.get(u.id)){                        
                                Double caseScore = (productTOscore.get(c.Support_Product__c) != null ? productTOscore.get(c.Support_Product__c) : noskillscore)   //  Score for product
                                                    *c.Case_Priority_Score__c                                                                           //  Score for priority                                      
                                                    *c.Sub_Status_Score__c;                                                                             //  Score for status   
                                workloadScore += caseScore;
                                
                                
                                debug +=    c.id+', '+caseScore+', '+
                                            (productTOscore.get(c.Support_Product__c) != null ? productTOscore.get(c.Support_Product__c) : noskillscore)+', '+
                                            c.Case_Priority_Score__c+', '+
                                            c.Sub_Status_Score__c+'\r\n';

                            }
                            
                        //  Add to update list                          
                            updateUsers.add(new User(
                                id = u.id, 
                                Care_Analyst_Workload_Score__c = workloadScore,
                                Score_Calc_Debug__c = debug
                            ));

                            debug += 'TOTAL SCORE FOR USER ID '+u.id+': '+workloadScore;
                            system.debug(debug);

                       }
                            
        }
        
    //  Update the users
        update updateUsers;     
        
    }

    public pageReference recalc(){

        Integer batchScope = 20;
        String query = 'SELECT id FROM User WHERE ID NOT IN ('+ Label.Skip_WorkLoad_Calculation_For_Users +')';
        RecalcWorkloadScoresBatch b = new RecalcWorkloadScoresBatch(query);
        Database.executeBatch(b,batchScope);

        Apexpages.addMessage(
            new Apexpages.Message(
                apexpages.severity.confirm,
                'Recalc job submitted - to check progress view setup > monitor > apex jobs'
            )
        );
        return null;
    }
   


/*  Test Coverage
    ----------------------------------------------------------------------------------------------------------- */
   /* @isTest static void testUserWorkload_CaseInsert(){

    //  Test data           
        integer iSize = 10;                          
        
        Support_Product__c SP = new Support_Product__c(Name = 'tester', Product_Type__c = 'Product', Customer_Available__c = true);
        insert SP;
        
        Customer_Care_Analyst_Skill__c c = new Customer_Care_Analyst_Skill__c(Support_Product__c = SP.id, User__c = Userinfo.getUserId());
        insert c;
        
        List<Case> cases = new List<Case>{};
        test.startTest();
    
        //  Insert some cases       
            for(integer i = 0; i < iSize; i++){             
                cases.add(new Case(Support_Product__c = SP.id));                
            }           
            insert cases;
            
        test.stopTest();


    //  Test the all user recalc
        UserWorkload u = new UserWorkload();
        u.recalc();
        
    }*/

    

}