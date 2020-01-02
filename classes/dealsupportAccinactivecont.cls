public class dealsupportAccinactivecont {

   

    public String DSId {get;set;}
    public String ResponseCode {get;set;}
    
    public dealsupportAccinactivecont () {
        DSId  = ApexPages.currentPage().getParameters().get('DSId');
        ResponseCode = ApexPages.currentPage().getParameters().get('ResponseCode');
     
    }
    
       
    public PageReference InitPage() {
     List<Deal_Support__c> Dealsupport= [SELECT Id,Name, Owner_Approval__c FROM Deal_Support__c WHERE Id=:DSId LIMIT 1];
        if(!Dealsupport.IsEmpty()){
            Dealsupport[0].Owner_Approval__c = ResponseCode;
            UPDATE Dealsupport;
        }
        return null;
    }
       public PageReference testre(){
       system.debug('testnavanee');
        pagereference pr = new pagereference('/'+DSId);
           return pr ;
        
        }
 
    
  /* public PageReference InitPage() {
        List<Deal_Support__c> Dealsupport= [SELECT Id,Name, Owner_Approval__c FROM Deal_Support__c WHERE Id=:DSId LIMIT 1];
        if(!Dealsupport.IsEmpty()){
            Dealsupport[0].Owner_Approval__c = ResponseCode;
            UPDATE Dealsupport;
        }
        //PageReference pg = new PageReference('/'+DSId);
        PageReference pg = new PageReference(' apex/dealsupportAccinactive?ResponseCode='+ResponseCode+'&DSId='+DSId);
       // apex/dealsupportAccinactive?ResponseCode=Approved&DSId=a8C0t000000CeCXEA0
        pg.setRedirect(true);
        return pg;   
    } */
    
    
}