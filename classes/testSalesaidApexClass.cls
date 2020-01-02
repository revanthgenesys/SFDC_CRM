//Ravi V - Sales Aid -  12/06/2013
@isTest(SEEALLDATA=TRUE)

public class testSalesaidApexClass
{  
 
 static testMethod void testClassMethod()
    
    { 
list<Recordtypes__c> lstrecordtype=new   list<Recordtypes__c>();//bulk List of custom setting object for bulk insert

 
     String firstcheck;
     String RecordTypeId;
     List<Responsewrapper> saqWrapperedit;
     String st;
     List<SelectOption> temp = new List<SelectOption>();
     RecordType rt = [select id,Name from RecordType where name='Success Plan'];
     Country__c cc = [select id,Name from Country__c where name='United States'];
     Account a = new Account( Name='Test Account', Status__c = 'Active',Country__c=cc.id); 
     insert a;
     Opportunity opp = new Opportunity( Name='Test Opp',Direct_sales__c=true,accountId=a.id,StageName='3.Evaluate Options',CloseDate=date.today(),Competitor__c='NONE');
     insert opp;
     PageReference pageRef = Page.Salesaid_SuccessPlan;
     pageRef.getParameters().put('retURL','/'+opp.id);
     pageRef.getParameters().put('RecordType',rt.id);
     Test.setCurrentPageReference(pageRef); 
    
     Sales_Aid__c sa = new Sales_Aid__c(name='test sa',RecordTypeId=rt.id);
     insert sa;
     ApexPages.StandardController sc = new ApexPages.StandardController(sa);
    
     Sales_Aid_extension sad = new Sales_Aid_extension(sc);
     
     firstcheck=sad.getParametersNew();
     
     Sales_Aid_Question__c saq = new Sales_Aid_Question__c(category__c='first',options__c=true,Questions__c='this is for testing',Sequence_Number__c=1,Stage__c='one');
     insert saq;
     RecordType rt2 = [select id,Name from RecordType where name='Call Plan'];
      Sales_Aid__c sa1 = new Sales_Aid__c(name='test sac',RecordTypeId=rt2.id);
     insert sa1;
     Questionwrapper qw = new Questionwrapper(saq);
     temp=qw.getOptionsall();
     pageReference pfsave =sad.savequestions();
       pageReference pfsave2 =sad.savecallplan();
       sad.saqWrapperedit=sad.getupdatequestions();
       pageReference pfsave3=sad.updatequestions();
         
           string[] starray=sad.getheaders();
           //List<String> editfieldss=sad.editableFields;
        PageReference pfsave7=sad.redirectNew();
          List<Salesaid_Action_Plan__c>  sapeditluist=sad.getActionplaneditlist();
        List<Salesaid_Action_Plan__c>  sapluist=sad.getActionplanlist();
     saqWrapperedit = sad.getupdatequestions();
      sad.Obj=sa1;
     Salesaid_Action_Plan__c sap = new Salesaid_Action_Plan__c(rownumber__c=1,Complete__c=true,Description__c='testing',Opportunity__c=opp.id,Owner__c='RaviV',Proposed_Activity__c='Sales aid project',sales_aid__c=sa1.id,Target_Date__c=system.today());
     insert sap;
     
     sad.SAPlist=sapeditluist;
         
     Actionplanwrapper aw1 = new Actionplanwrapper(1);
     Actionplanwrapper aw2 = new Actionplanwrapper(sap);
     
     sa1=[select id,recordtypeid from Sales_Aid__c where id=:sa1.id limit 1]; 
     
     System.currentPageReference().getParameters().put('id', sa1.id);
     System.currentPageReference().getParameters().put('RecordType', rt.id);
     System.currentPageReference().getParameters().put('retURL', opp.id);
     
     pageReference pfsave4=sad.saveActionplan();
     PageReference pfsave5=sad.updateActionplan();
     PageReference pfsave6=sad.redirectEdit();
     List<Salesaid_Action_Plan__c> sapeditlist=sad.getEditActionplan();
     st=sad.getParametersEdit();
     
     sales_aid_response__c sar = new sales_aid_response__c (stage__c='testing',Sales_Aid__c=sa.id, Opportunity__c=opp.id,Sales_Aid_Question_txt__c='testing 1',category__c='first',Question_number__c=1,Competitor__c=true,Genesys__c=true,Neither__c=true,Partner__c=true,Response__c='Yes',Comments__c='xyz');
     insert sar;
     sar =[select id,stage__c,Sales_Aid__c,Opportunity__c,Sales_Aid_Question_txt__c,category__c,Question_number__c,Competitor__c,Genesys__c,Neither__c,Partner__c,Response__c,Comments__c from sales_aid_response__c where stage__c='testing' limit 1];
     Responsewrapper rw = new Responsewrapper(sar);
    List<SelectOption> ls2 =rw.getOptionsall();
     
     //pageReference pfupdate =sad.updatequestions();
    }
    }