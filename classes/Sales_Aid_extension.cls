//Ravi V - Sales Aid -  12/06/2013
public class Sales_Aid_extension 
{
//Variables 
public List<Salesaid_Action_Plan__c> lstSAP  = new List<Salesaid_Action_Plan__c>();

public List<Salesaid_Action_Plan__c>  SAPlist ;

 public List<Actionplanwrapper>  wrapperlistedit = new List<Actionplanwrapper>();
 
 public List<Salesaid_Action_Plan__c> finallistinsert  = new List<Salesaid_Action_Plan__c>();
public Sales_Aid__c ActionplanSalesAid {get;set;}

public List<String> editableFields {
        get {
            if (editableFields == null) {
                editableFields = new List<String>();
                editableFields.add('Name');
                editableFields.add('Account_del__c');
                editableFields.add('Account_Executive_del__c');
               
            }
            return editableFields ;
        }
        private set;
    }

List<Error_log__c> errorLogList = new List<Error_log__c>();
private String RecordTypeId, RecordTypeName;
public String rid;
public string URLst;
public String retURL ;
public String ent ;
private static String tempst; 
private static String tempnum;
public string recid;
public Sales_Aid__c sact {get;set;}
public List<Questionwrapper> saqWrapper{get;set;} 
public List<Responsewrapper> saqWrapperedit{get;set;} 
public Sales_Aid__c sactsave{set;get;}
public String SACname;
public String getSACname(){  SACname='Opportunity Assessment - '+opp.name;return SACname;}
public void setSACname(String SACname){this.SACname= SACname;}   
ApexPages.StandardController controller;
public opportunity opp{get;set;}
public Sales_Aid__c obj;
public Sales_Aid__c getobj(){
return this.obj;
}
public void setobj(){
this.obj=obj;
}

//Methods
   public Sales_Aid_extension(ApexPages.StandardController controller)
        { 
        if(!Test.isRunningTest())
            {
               controller.addFields(editableFields);
             }
          
           obj = new sales_aid__c();
           this.controller=controller;
           sact= (Sales_Aid__c)controller.getRecord();
            ActionplanSalesAid=(Sales_Aid__c)controller.getRecord();
           RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
           ent = ApexPages.currentPage().getParameters().get('ent');
           retURL =ApexPages.currentPage().getParameters().get('retURL');
            String pageName = ApexPages.CurrentPage().getUrl();
           string oppid;
           recid = ApexPages.currentPage().getParameters().get('id');//for edit mode
           { 
           oppid= retURL.remove('/');//commented by ankit for time being
          // oppid = '006Z000000FA3wf';
           opp = [select name,account.name,opportunity.owner.firstname,opportunity.owner.lastname,opportunity.owner.name,createddate,StageName,recordtype.name,closedate from opportunity where id=: oppid];
           if(recid ==null)
           {
           if(pageName.contains('Action_Plan_New'))
          {
           obj.name='Action plan - '+opp.name; 
          }
          
          if(pageName.contains('sales_aid_callplan_new'))
          {
           obj.name='Call plan - '+opp.name;
           obj.Sales_Stage_Step_Info_del__c=opp.StageName;
          }
          
         if(pageName.contains('Salesaid_SuccessPlan'))
          {
            sact.name ='Success plan - '+opp.name;
           
          }
               
          if(pageName.contains('sales_aid_new'))
          {
            sact.name = 'Opportunity Assessment - '+opp.name; 
           }       
            }//first if
           }//rectid
           
            for(RecordType rt:[select id,name from recordtype where id = :recordtypeid])
           RecordTypeName = rt.name;
           saqWrapper = new List<Questionwrapper>();
           saqWrapperedit = new  List<Responsewrapper>();
           saqWrapperedit = getupdatequestions();
           List <Sales_Aid_Question__c> tempSAQ = new  List <Sales_Aid_Question__c> ();
            //Ankit..logic to be added
            tempSAQ =[select id,Questions__c,category__c,Sequence_Number__c,options__c,stage__c  from Sales_Aid_Question__c where type__c ='Success Plan' order by Sequence_Number__c];
           //  This Logic is for displaying unique(non-duplicate values) 
           for(Integer i=0;i<tempSAQ.size();i++)
              {
               if(i>0 && tempSAQ[i].category__c==tempSAQ[i-1].category__c)      
                 { 
                  tempst=tempSAQ[i].category__c; 
                  tempSAQ[i].category__c='';
                  }  
              if(i>0 && tempst==tempSAQ[i].category__c )
                 {
                  tempst=tempSAQ[i].category__c; 
                  tempSAQ[i].category__c='';
                 }
              if(i>0 && tempSAQ[i].stage__c==tempSAQ[i-1].stage__c)      
                { 
                 tempnum=tempSAQ[i].stage__c; 
                 tempSAQ[i].stage__c='';
                 }  
              if(i>0 && tempnum==tempSAQ[i].stage__c)
                {
                 tempnum=tempSAQ[i].stage__c; 
                 tempSAQ[i].stage__c='';
                }
           Questionwrapper tempWrapper = new Questionwrapper(tempSAQ[i]);  
          saqWrapper.add(tempWrapper); 
             }
         }
     
        
   public pageReference savequestions()
      {
      
       try
           { 
             List<sales_aid_response__c> SAresponse = new  List<sales_aid_response__c>();
             Sales_Aid__c sac = new Sales_Aid__c(Name= sact.name ,RecordTypeId =recordtypeid,Opportunity__c=retURL.remove('/'),Account_del__c=opp.accountid,Sales_Stage_Step_Info_del__c=opp.StageName,Account_Executive_del__c=opp.ownerid);
             sac.Win_Themes_del__c = sact.Win_Themes_del__c;
             sac.Mutually_agreed_to_next_step_1__c = sact.Mutually_agreed_to_next_step_1__c;
             insert sac;
             sactsave=sac;
             for(integer i =0; i<saqWrapper.size();i++)
                {
                 sales_aid_response__c temp =new sales_aid_response__c ();
                 temp.Question_number__c=saqWrapper[i].SequenceNumber;
                 temp.Sales_Aid__c=sac.id;
                 retURL=retURL.remove('/');
                 temp.Opportunity__c=retURL;
                 //temp.Competitor__c=saqWrapper[i].Competitor;
                 //temp.Genesys__c=saqWrapper[i].genesys;
                 //temp.Neither__c=saqWrapper[i].neither;
                 //temp.Partner__c=saqWrapper[i].Partner;
                 temp.Comments__c=saqWrapper[i].Comments;
                 //temp.Response__c=saqWrapper[i].optionstest;
                 temp.Sales_Aid_Question_txt__c=saqWrapper[i].Question;
                 temp.Sales_Aid_Question__c=saqWrapper[i].QuestionID;
                 temp.category__c=saqWrapper[i].category;
                 temp.stage__c=saqWrapper[i].stage;
                    SAresponse.add(temp);
                 }
             if(SAresponse.size() > 0)
                Insert SAresponse;    
            }   
        catch(Exception e)
             {
              errorLogList.add(new Error_log__c(Error_Level__c = 'High',
              Code_Type__c       = 'Class',
              Snippet_Name__c    = 'Sales_Aid_extension',
              User_Name__c       = UserInfo.getUserName(),
              Object_Name__c     = 'sales_aid_response__c',    
              Error_Description__c  = e.getMessage()
              ));
             }
       finally
        {                           
            if(errorLogList.size() > 0)
            Insert errorLogList;
         }
        return new Pagereference('/'+opp.id);
     }
     
   public PageReference savecallplan()
      {     obj.Opportunity__c=opp.id;
            obj.Account_del__c=opp.accountid;
            obj.Account_Executive_del__c=opp.ownerid;
            obj.recordtypeid=RecordTypeId;
            insert obj;
            PageReference home = new PageReference('/'+opp.id);
            home.setRedirect(true);
            return home;
       }
     
   public List<Responsewrapper> getupdatequestions()
     {
     
      rid= ApexPages.currentPage().getParameters().get('id');
      List<sales_aid_response__c> tempSAQR = new  List<sales_aid_response__c>();
      tempSAQR = [select id,Response__c,Question_number__c,Sales_Aid_Question__c,category__c,Sales_Aid_Question_txt__c,Competitor__c,Genesys__c,Neither__c,Partner__c,Comments__c,stage__c  from sales_aid_response__c where Sales_Aid__c=:rid order by Question_number__c];
      for(integer i =0; i<tempSAQR.size();i++)
         { 
          Responsewrapper rw = new Responsewrapper(tempSAQR[i]);  
          saqWrapperedit.add(rw); 
          }
      return saqWrapperedit;
     }
        
   public pageReference updatequestions()
    {
      try { 
            errorLogList.clear();
            update sact;
            
            List<sales_aid_response__c> tempSAQRlist = new  List<sales_aid_response__c>();
            for(integer i =0; i<saqWrapperedit.size();i++)
               {
                sales_aid_response__c  tempSAQR = new sales_aid_response__c(id=saqWrapperedit[i].ResponseID);
                tempSAQR.Response__c = saqWrapperedit[i].optionstest;
                tempSAQR.Competitor__c=saqWrapperedit[i].Competitor;
                tempSAQR.Genesys__c=saqWrapperedit[i].genesys;
                tempSAQR.Neither__c=saqWrapperedit[i].neither;
                tempSAQR.Partner__c=saqWrapperedit[i].Partner;
                tempSAQR.Comments__c=saqWrapperedit[i].Comments;
                tempSAQR.Response__c=saqWrapperedit[i].optionstest;
                tempSAQR.Sales_Aid_Question_txt__c=saqWrapperedit[i].Question;
                tempSAQR.category__c=saqWrapperedit[i].category;
                tempSAQRlist.add(tempSAQR);
                }
            update tempSAQRlist;
                                         
            }  catch(Exception e)
             {
              errorLogList.add(new Error_log__c(Error_Level__c = 'High',
              Code_Type__c       = 'Class',
              Snippet_Name__c    = 'Sales_Aid_extension',
              User_Name__c       = UserInfo.getUserName(),
              Object_Name__c     = 'sales_aid_response__c',    
              Error_Description__c  = e.getMessage()
              ));
             }
       finally
        {                           
            if(errorLogList.size() > 0)
            Insert errorLogList;
         }   
        return new Pagereference('/'+opp.id);
     }
     
     
     // Action plan save 
     public PageReference saveActionplan()
     {
            
            obj.Opportunity__c=opp.id;
            obj.Account_del__c=opp.accountid;
            obj.Account_Executive_del__c=opp.ownerid;
            obj.recordtypeid=RecordTypeId;
            upsert obj;
                       
            for(Salesaid_Action_Plan__c temp : lstSAP) 
             {
             String st = temp.owner__c;
             
             if(st!=null)
             if(st.trim()!=null)
             {
              temp.sales_aid__c=obj.id;
              temp.Opportunity__c=opp.id;
              finallistinsert.add(temp);
             }
               }   
                          
            insert finallistinsert;
      return new Pagereference('/'+opp.id);
     
     }
    // Action plan edit
     public PageReference updateActionplan()
     {
        update ActionplanSalesAid ;
            List<Salesaid_Action_Plan__c> finallistinsert  = new List<Salesaid_Action_Plan__c>();
            List<Salesaid_Action_Plan__c> finallistupdate  = new List<Salesaid_Action_Plan__c>();
            List<Salesaid_Action_Plan__c> finallistdelete  = new List<Salesaid_Action_Plan__c>();
            
            for(Salesaid_Action_Plan__c temp : SAPlist) 
             {
              String st = temp.owner__c;
             String sid=temp.id;
             
             if(st!=null && sid==null)
             {
              temp.sales_aid__c=ApexPages.currentPage().getParameters().get('id');
                 temp.opportunity__c=opp.id;
                 finallistinsert.add(temp);
             }
             if(st==null && sid!=null)
             {
             finallistdelete.add(temp);
             }
             if(st!=null && sid!=null)
             {
             finallistupdate.add(temp);
             }
             
             }
             update finallistupdate;
            insert finallistinsert;
            delete finallistdelete;
      return new Pagereference('/'+retURL);
     
     }
     
   
     
     
    //Action plan new page view
     public List<Salesaid_Action_Plan__c> getActionplanlist()
    {
     List<Actionplanwrapper>  wrapperlist = new List<Actionplanwrapper>();
     
    for(Integer i=0;i<10;i++) 
    {
     Actionplanwrapper temp=new Actionplanwrapper(i);
     
      wrapperlist.add(temp);
      }
    
    for(Actionplanwrapper sa:wrapperlist )
    {
    lstSAP.add(sa.SAP);
    }
    return lstSAP;
               
     }
     public string[] getheaders() { 
   return new string [] {'#','Proposed Activity','Details','Owner','Target Date','Complete?'} ;
 }
   // new page redirect 
    public PageReference redirectNew()
     {
        
        String param = getParametersNew() ;
        System.debug('Checking param : '+param);
        return new PageReference('/apex/'+param+'&nooverride=1');
    } 
    
    public String getParametersNew()
     {
        string param = '';
        Map<String, String> strMap = ApexPages.currentPage().getParameters();
        
        set<String> keys = ApexPages.currentPage().getParameters().keySet();
        for(String s : keys)
        {
       if( s=='RecordType' )
        { 
        ID sfdcid=id.valueof(ApexPages.currentPage().getParameters().get(s));
         Recordtypes__c temp=Recordtypes__c.getValues(sfdcid);
        param = temp.new_VF_page__c+ '?'+param;
        }
       
            if(strMap.containsKey(s)) 
            param += s + '=' + EncodingUtil.urlEncode(strMap.get(s),'UTF-8') + '&'; 
            
        }
        if(param.length() > 0) param = param.substring(0, param.length()-1);
        return param;
      }
//Action plan edit view 
      public List<Salesaid_Action_Plan__c> getActionplaneditlist()
    {
       
       wrapperlistedit.clear();  
       
     SAPlist=[select id,rownumber__c,Complete__c,Description__c,Owner__c,Proposed_Activity__c,sales_aid__c,Target_Date__c from Salesaid_Action_Plan__c where sales_aid__c=:ApexPages.currentPage().getParameters().get('id')  ];
     
     Integer listsize=SAPlist.size();
     
     if(listsize<11)
     {
     
     for(Integer i=listsize+1;i<11;i++)
     {
     Actionplanwrapper temp=new Actionplanwrapper(i);
     wrapperlistedit.add(temp);
     
     }
     
     }
     for(Actionplanwrapper sa:wrapperlistedit )
    {
    SAPlist.add(sa.SAP);
    }
      
      return SAPlist;
      
    }
  
     // redirect edit pages
     public PageReference redirectEdit()
     {
        
        String param = getParametersEdit() ;
        System.debug('Checking param : '+param);
        return new PageReference('/apex/'+param+'&nooverride=1');
    }
     
     public List<Salesaid_Action_Plan__c> getEditActionplan()
     {
      rid= ApexPages.currentPage().getParameters().get('id');
      List<Salesaid_Action_Plan__c> tempSAP = new  List<Salesaid_Action_Plan__c>();
      tempSAP = [select id,rownumber__c,Complete__c,Description__c,Owner__c,Proposed_Activity__c,sales_aid__c,Target_Date__c  from Salesaid_Action_Plan__c where sales_aid__c=:rid order by rownumber__c  asc];
      
      return tempSAP;
     }

  public String getParametersEdit()
     {
        string param = '';
        Map<String, String> strMap = ApexPages.currentPage().getParameters();
        
        set<String> keys = ApexPages.currentPage().getParameters().keySet();
        
        obj =[select id,recordtypeid from Sales_Aid__c where id=:ApexPages.currentPage().getParameters().get('id') limit 1];
        
        recordtypeid=obj.recordtypeid;
        
         Recordtypes__c temp=Recordtypes__c.getValues(recordtypeid);
         param = temp.Edit_VF_Page__c+ '?'+param;
         for(String s : keys)
        {
        
        if(strMap.containsKey(s)) 
            param += s + '=' + EncodingUtil.urlEncode(strMap.get(s),'UTF-8') + '&'; 
        
        }
        
        return param;
      }
 }