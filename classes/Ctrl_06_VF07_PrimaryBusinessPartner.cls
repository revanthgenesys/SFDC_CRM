public with sharing class Ctrl_06_VF07_PrimaryBusinessPartner {

  public string SelectedId{get;set;}
  public Opportunity opportunity{get;set;}
  
  public string Country{get;set;}
  
  public Boolean isSearch   {get;set;}
  public Boolean isSorting  {get;set;}
  public String OrderBY {get;set;}
  public String log {get;set;}
  public string searchtext{get;set;}
  
  private string searchtextOld='';
  private string OrderByOld='';
  private string OrderBy2='ASC';
  
  private Boolean isDirectTouch = false;
  private Boolean isChannelManager = false;
  
  private Boolean isSecondary = false;
  private Boolean isEditMode = false;
  
  public Ctrl_06_VF07_PrimaryBusinessPartner(Apexpages.Standardcontroller con){
    opportunity = (Opportunity)con.getRecord();
    opportunity = [select id,BusinessPartner__c, name, country__c,country__r.Name from Opportunity where id =:opportunity.Id];
    if(Apexpages.currentPage().getParameters().get('sec')!=null){
      isSecondary = true;
    }
    if(Apexpages.currentPage().getParameters().get('edit')!=null){
        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,'Please note that above Stage 3, a BP has to be selected prior to editing the Opportunity. If no Business Partner is involved in this Opportunity, please click on the Cancel button and tick \'Direct Sales\' box on the Opportunity.'));
      isEditMode = true;
    }

    Country = opportunity.country__r.Name;
    OrderBy2='ASC';
    OrderBy='Name';
    searchtext='';
    isSorting=false;  
    string ProfileName = [Select p.Name, p.Id From Profile p where id=:Userinfo.getProfileId() limit 1].Name;
    if(ProfileName.contains('Direct Touch'))
      isDirectTouch = true;
    else if(ProfileName.contains('Channel Manager'))
      isChannelManager=true;
  }
  
  public list<Account> accounts
  {
    get {
      accounts = (list<Account>)ssc.getRecords();
      return accounts;
    }
    set;
  }
  public ApexPages.StandardSetController ssc {
        get {
            if(ssc == null || isSearch==true)
            {
              // Address 1 City Country Parent Account Type Account Classification Owner
              string sql   = 'Select id, Name,Site,Street1__c,City__c,ParentID,Type,AccountClassification__c,OwnerID, ';
                sql    += ' AccountShortName__c, ALUEGroup__c,PartnerType__c,Country__c,Phone,AccreditationLevel__c,Registered__c,  ';
                sql    += ' Owner.Alias ';
                sql    += ' From Account  ';
                
                sql   += ' where InactiveAccount__c=false and recordTypeID=\''+Config.EMG_BUSINESS_PARTNER_RECORDTYPE+'\' ';
                
              //if(isDirectTouch  || isChannelManager)
              // sql   += ' and Country__c = \'' +opportunity.Country__c+'\' '; 
              //if(isChannelManager)
              //  sql   += ' and ownerId = \'' +Userinfo.getUserId()+'\' ';
        if(searchtext != null && searchtext != '' && isSorting==false)
        {
                
                searchtext=searchtext.trim();
                if(searchtext.endsWith('*'))
            searchtext=searchtext.substring(0,searchtext.length()-1);
                if(searchtext.startsWith('*'))
                  searchtext=searchtext.replaceFirst('[*]','%');
                sql    += ' and  Name like \''+String.escapeSingleQuotes(searchtext)+'%\'' ;
                searchtextOld =searchtext;
        }
              else if(searchtextOld !=null && searchtextOld !='' && searchtext != '')
                sql    += ' and Name like \''+String.escapeSingleQuotes(searchtextOld)+'%\'' ;
              
              if(Country!=null && Country!='')
                sql    += '  and Country__r.Name = \''+Country+'\'' ;
              
              if(isSecondary && opportunity.BusinessPartner__c !=null)
                sql    += '  and id != \''+opportunity.BusinessPartner__c+'\'' ;
              
                sql    += ' Order BY ' ;
              if(OrderBY != null || OrderBY != '' )
                sql   += OrderBY;
              
              if(isSorting==false && OrderBy2!=null)
              {
                sql   += ' ' +OrderBy2;
              }
              else if((OrderByOld ==OrderBy && OrderBy2=='DESC'))
              {
                sql   += ' ASC ' ;
                OrderBy2='ASC';
              }
              else
              {
                sql   += ' DESC' ;
                OrderBy2='DESC';
              }
              
              OrderByOld=OrderBy;
              try{
                  ssc =new ApexPages.StandardSetController(Database.getQueryLocator(sql));
              }
              catch(Exception err)
              {
                Apexpages.addMessages(err);
              }  
        log=sql+' searchtextOld'+searchtextOld+' searchtext'+searchtext;
        
        isSearch=false;
              isSorting=false;
            }
      if(ssc !=null && ssc.getResultSize()>1)
              ssc.setPageSize(25);
            return ssc;
        }
        set;
    }
    public PageReference search()
  {
    return null;
  }
  public PageReference cancel()
  {
    Pagereference p = new Pagereference ('/'+opportunity.Id);
    return p;
  }
  public PageReference save()
  {
    Pagereference p ;
    try{
      if(!isSecondary){
        opportunity.BusinessPartner__c = SelectedId;
        update opportunity;  
      }  
      else{
        p = Page.VF08_SecondaryBP;
        p.getParameters().put('sec',SelectedId);
        p.getParameters().put('oppId',opportunity.Id);
        return p;
      }    
      
    }catch(Exception err)
    {
      Apexpages.addMessages(err);
      return null;
    }
    if(isEditMode)
    {
        p = new PageReference('/' + opportunity.id + '/e');
        p.getParameters().put('nooverride', '1');
        p.getParameters().put('retURL', '/'+opportunity.Id);
    }
    else
        p = new Pagereference ('/'+opportunity.Id);
    return p;
  }
}