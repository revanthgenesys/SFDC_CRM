@isTest
public class TestUpdateProductDetailsCntrl {
    
    static Contact testContact;
    static User testUser;
    static Case cs;
    static Case cs2;
    static Case cs3;
    static Case cs4;
    static Account testAccount;
    static Support_Product__c prod;
    static Support_Product__c Supcmp;
    static Support_Product__c Supprd;
    static Support_Problem_Category__c prob;
    static Support_Product_Related_Category__c ProbRelCat;
    static void setUpdata() {
        
    Util.Bypass_Trigger_Chk = true;
    Profile prfl = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];      
    testAccount = TestUtil.createAccounts(1, true)[0];
    testContact = TestUtil.createContacts(1, testAccount, true)[0];
    
    List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_Case'];
    
    Supprd = new Support_Product__c(Category__c ='PureEngage Products',Product_Group__c='PureEngage All',
                                    Status__c = 'Active', Customer_Available__c = true, Active__c = true,Product_Type__c = 'Product');
    insert Supprd;
    
    Support_Product__c Supprd2 = new Support_Product__c(Category__c ='Custom PS Applications',Product_Group__c='Custom App for PureCloud',
                                                 Status__c = 'Active', Customer_Available__c = true, Active__c = true,Product_Type__c = 'Product');
    insert Supprd2;
    
    Supcmp = new Support_Product__c(Category__c ='PureEngage Products',Product_Group__c='PureEngage All',Parent_Product__c=Supprd.id,
                                                 Status__c = 'Active', Customer_Available__c = true, Active__c = true,Product_Type__c = 'Component');
    insert Supcmp;
    
    prob = new Support_Problem_Category__c(Name='Provision Server',Category_Name__c='Provision Server',Status__c='Active');
    insert prob;
        
    ProbRelCat = new Support_Product_Related_Category__c(Support_Problem_Category__c=prob.id,Support_Product__c=Supprd.id);
    insert ProbRelCat;
        
    Cloud_Deployment__c CDeploy= new Cloud_Deployment__c(Name='Test',Cloud_Platform__c = 'PureEngage Cloud');
    insert CDeploy;
    
    Cloud_Deployment__c CDeploy2= new Cloud_Deployment__c(Name='Test',Cloud_Platform__c = 'PureCloud');
    insert CDeploy2;
    
    Cloud_Deployment__c CDeploy3= new Cloud_Deployment__c(Name='Test',Cloud_Platform__c = 'PureConnect Cloud');
    insert CDeploy3;
    
    Cloud_Deployment__c CDeploy4= new Cloud_Deployment__c(Name='Test',Cloud_Platform__c = 'Else condition');
    insert CDeploy4;
        
    cs = new Case(subject='Test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectp[0].id,
                  Component__c=Supcmp.id,Support_Product__c=Supprd.id,Cloud_Deployment__c=CDeploy.id,Problem_Category__c=prob.id);                        
    insert cs;
    
    cs2 = new Case(subject='Test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectp[0].id,
                  Component__c=Supcmp.id,Support_Product__c=Supprd2.id,Cloud_Deployment__c=CDeploy2.id);                        
    insert cs2;
    
    cs3 = new Case(subject='Test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectp[0].id,
                  Component__c=Supcmp.id,Support_Product__c=Supprd2.id,Cloud_Deployment__c=CDeploy3.id);                        
    insert cs3;
    
    cs4 = new Case(subject='Test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectp[0].id,
                  Component__c=Supcmp.id,Support_Product__c=Supprd2.id,Cloud_Deployment__c=CDeploy4.id);                        
    insert cs4;
    
  }
    
    static testMethod void PureEngageCloud() {
        setUpdata();
        Case CID=[SELECT ID FROM Case WHERE Cloud_Platform__c = 'PureEngage Cloud'];
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('id',CID.id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(CID);
        
        UpdateProductDetailsCntrl Cnt1= new UpdateProductDetailsCntrl(sc);
        List<SelectOption> selOpts=Cnt1.categories;
        Cnt1.onchangeCategory();
        Cnt1.selectedProduct=Supprd.Id;
        cnt1.selectedCategory='PureEngage Products';
        cnt1.selectedPureCnctGrp='PureEngage All';
        cnt1.selectedComponent=Supcmp.id;
        cnt1.selectedPureCnctProblm=prob.id;
        Cnt1.saveCaseUpdates();
        Test.stopTest();
    }
    
    static testMethod void PureCloud() {
        setUpdata();
        Case CID=[SELECT ID FROM Case WHERE Cloud_Platform__c = 'PureCloud'];
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('id',CID.id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(CID);
        
        UpdateProductDetailsCntrl Cnt1= new UpdateProductDetailsCntrl(sc);
        List<SelectOption> selOpts=Cnt1.categories;
        Cnt1.onchangeCategory();
        Cnt1.saveCaseUpdates();
        Test.stopTest();
    }
    
    static testMethod void PureConnectCloud() {
        setUpdata();
        Case CID=[SELECT ID FROM Case WHERE Cloud_Platform__c = 'PureConnect Cloud'];
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('id',CID.id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(CID);
        
        UpdateProductDetailsCntrl Cnt1= new UpdateProductDetailsCntrl(sc);
        Test.stopTest();
    }
    
    static testMethod void Elsecondition() {
        setUpdata();
        Case CID=[SELECT ID FROM Case WHERE Cloud_Platform__c = 'Else condition'];
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('id',CID.id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(CID);
        
        UpdateProductDetailsCntrl Cnt1= new UpdateProductDetailsCntrl(sc);
        Test.stopTest();
        
    }
    
}