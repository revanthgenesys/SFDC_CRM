public with sharing class UserContributionController {
    
    public UserContributionController(ApexPages.KnowledgeArticleVersionStandardController ctrl) {
        SObject t = ctrl.getRecord();
        String cid = ctrl.getSourceId();
        Case c = [SELECT RecordTypeId, Subject, Description, Component__c, OS__c, Database__c, 
                         Switch__c,  Link__c, X3rd_Party_Products__c, Platform__c,Product_Category_Filter__c,
                         Major_Release__c,Cloud_Product__c,Problem_Description__c,Problem_Root_Cause__c,
                         Resolution_Steps__c,Additional_Recommendations__c
                  FROM Case
                  WHERE Id =: cid];
        if (c != null) {
            t.put('Title', c.Subject);
            String EnvironmentData = '';
            EnvironmentData = append (EnvironmentData + 'Component: ' , c.Component__c);
            EnvironmentData = append (EnvironmentData + 'OS: ' , c.OS__c);
            EnvironmentData = append (EnvironmentData + 'Database: ' , c.Database__c);
            EnvironmentData = append (EnvironmentData + 'Switch: ' , c.Switch__c);
            EnvironmentData = append (EnvironmentData + 'Link: ' , c.Link__c);
            EnvironmentData = append (EnvironmentData + '3rd Party Products: ' , c.X3rd_Party_Products__c);
            
            if (t.getSObjectType() == HOW_TO_TEMPLATE__kav.sObjectType){
                t.put('BENEFITS__c', c.Problem_Description__c);
                t.put('Environment__c', EnvironmentData);
                t.put('SUPPLEMENTAL_INFORMATION__c', c.Additional_Recommendations__c);
                t.put('STEPS_TO_IMPLEMENT__c', c.Resolution_Steps__c);
                
            }else if (t.getSObjectType() == INTERNAL_PROCESSES__kav.sObjectType){
                t.put('QUESTIONSUMMARY__c', c.Description);
                t.put('SUPPLEMENTAL_INFORMATION__c', EnvironmentData);
                
            }else if (t.getSObjectType() == QUESTION_AND_ANSWER__kav.sObjectType){
                t.put('QUESTION_DETAIL__c', c.Problem_Description__c);
                t.put('Environment__c', EnvironmentData);
                t.put('ANSWER__c', c.Resolution_Steps__c);
                t.put('SUPPLEMENTAL_INFORMATION__c', c.Additional_Recommendations__c);
                
            }else if (t.getSObjectType() == SOLUTIONS__kav.sObjectType){
                t.put('Description__c', c.Problem_Description__c);
                t.put('Environment__c', EnvironmentData);
                t.put('ROOT_CAUSE__c', c.Problem_Root_Cause__c);
                t.put('SOLUTION__c', c.Resolution_Steps__c);
                t.put('SUPPLEMENTAL_INFORMATION__c', c.Additional_Recommendations__c);
                
            }else if (t.getSObjectType() == TECHNICAL_ARTICLE__kav.sObjectType){
                t.put('OVERVIEW__c', c.Problem_Description__c);
                t.put('Environment__c', EnvironmentData);
                t.put('DETAIL__c', c.Resolution_Steps__c);
                t.put('SUPPLEMENTAL_INFORMATION__c', c.Additional_Recommendations__c);
                
            }else if (t.getSObjectType() == TECH_NOTES__kav.sObjectType){
                t.put('DETAIL__c', c.Problem_Description__c + '\n' + c.Resolution_Steps__c);
                t.put('Environment__c', EnvironmentData);
                t.put('SUPPLEMENTAL_INFORMATION__c', c.Additional_Recommendations__c);
                
            }else if (t.getSObjectType() == TROUBLESHOOTING_UTILITIES__kav.sObjectType){
                t.put('DETAIL__c', c.Problem_Description__c);
                //t.put('Environment__c', EnvironmentData);
            }
                        
            if(c.Platform__c != null){   
                List<String> tmp = new List<String>();
                tmp.add(c.Platform__c);
                tmp = pkb_Controller.getArticleProductCategories(tmp,false);
                if(!tmp.isEmpty()){
                    ctrl.selectDataCategory('Product',tmp[0]);
                }   
              
              }
                        
           /* if(c.Cloud_Product__c != null){   
                List<String> tmp = new List<String>();
                tmp.add(c.Cloud_Product__c);
                tmp = pkb_Controller.getArticleCloudProductCategories(tmp,false);
                if(!tmp.isEmpty()){
                    ctrl.selectDataCategory('Cloud_Product',tmp[0]);
                }     
            } */
            if(c.Major_Release__c!=null){   
                List<String> tmpV = new List<String>();
                tmpV.add(c.Major_Release__c);
                tmpV = pkb_Controller.getArticleReleaseCategories(tmpV,false);
                if(!tmpV.isEmpty()){
                    ctrl.selectDataCategory('Release',tmpV[0]); 
                }
                
            }
            
        }
    }
    
    private String append (String details, String value) {
        details = (value != null && value.trim() != '') ? details + value +'<br><br>': '';
        return details;
    }
    
    
    public static testMethod void testUserContributionController() {
       /* Case c =  pkb_Test.testCaseInsert();
        String caseId = c.id;
        System.debug('Created Case: ' + caseId);
        ApexPages.currentPage().getParameters().put('sourceId', caseId);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        ApexPages.KnowledgeArticleVersionStandardController ctl =
        new ApexPages.KnowledgeArticleVersionStandardController(new HOW_TO_TEMPLATE__kav());
        new UserContributionController(ctl);
        System.assertEquals(caseId, ctl.getSourceId());
        System.assertEquals(c.Subject, ctl.getRecord().get('Title'));
        System.assertEquals(c.Description, ctl.getRecord().get('BENEFITS__c'));*/
    }
        
}