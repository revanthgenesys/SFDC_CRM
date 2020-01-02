public with sharing class ResetFtpPasswordController {
        
         private final FTP_Access__c fa;
         
         public ResetFtpPasswordController(ApexPages.StandardController stdController) {            
         this.fa = (FTP_Access__c)stdController.getRecord();             
         }
        
         public PageReference resetPassw() {
                String theId = ApexPages.currentPage().getParameters().get('id');
                if (theId == null) {
            return null;
        }
                
                FTP_Access__c fAcs = [SELECT Id, FTP_Password__c FROM FTP_Access__c WHERE Id = :theId];
               
                fAcs.FTP_Password__c = GenerateFtpPassword.GenPasswd();
                update fAcs;
                
                PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
 
         } 
}