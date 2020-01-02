public with sharing class WowRequestUserAccess{
 public string SC{get;set;}
public List<Wow_Request_Form__c>list_WowReq{get;set;}
public string sCustomURL{get;set;} 
public string BaseURL{get;set;}
// create a list of strings to hold the conditions
string conditions {get;set;}
private integer totalRecs = 0;
private integer OffsetSize = 0;
private integer LimitSize= 25;
public Id UserId {get;set;} 
public Integer page{get;set;}
public Integer totalPages{get;set;}

public WowRequestUserAccess(){
 SC = '';
 conditions ='';
 UserId =UserInfo.getUserId();
 this.page = 1;
 //searchWows();
 
}

public void searchWow(){
totalRecs = 0;
OffsetSize = 0;
searchWows();
SC = '';
}


public Void searchWows(){

System.debug('Total Records is ==>'+totalRecs);
System.debug('OffsetSize is ==>'+OffsetSize);

if(list_WowReq != null && !list_WowReq.isEmpty()){
  list_WowReq.clear();
}
  
 String strQuery ='Select Opportunity_Id__r.Account.id,Opportunity_Id__c,CreatedBy.Name,LastModifiedBy.Name,Id,name,Opportunity_Id__r.Name,Opportunity_Id__r.Account.Name,AssignTo__c,WoW_Status__c,AE__r.Name,SE__r.Name,BC__r.name,Lead__r.Name,createddate,lastmodifiedDate from Wow_Request_Form__c';
 System.debug('SC ==>'+SC);
 conditions ='';
 if (SC!='')
   conditions =  'Name Like\'%' + SC+'%\' ';
 if (SC!='' && conditions !='')  
  strQuery += '  WHERE ' + conditions;  
  
 if(totalRecs !=null && totalRecs ==0){
    List<Wow_Request_Form__c> wowTemp = Database.query(strQuery);
    totalRecs = (wowTemp !=null &&wowTemp .size()>0)?wowTemp .size():0;
 }

 system.debug('strQuery ==>'+strQuery );
 // add sort and limits at the end  
  strQuery += ' ORDER BY CreatedDate DESC LIMIT :LimitSize  OFFSET :OffsetSize';
 system.debug('strQuery ==>'+strQuery);
  list_WowReq =Database.query(strQuery);
  BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());
  sCustomURL = BaseURL + '/apex/wow_Request_Form?id=';
  Decimal pages = Decimal.valueOf(this.totalRecs);
  pages = pages.divide(Decimal.valueOf(LimitSize), 2);
  this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
  strQuery ='';
}

public void FirstPage()
{
this.page = 1;
OffsetSize = 0;
searchWows();
}
public void previous()
{
this.page--;
OffsetSize = (OffsetSize-LimitSize);
searchWows();
}
public void next()
{
this.page++;
OffsetSize = OffsetSize + LimitSize;
system.debug('LimitSize==>'+LimitSize);
system.debug('OffsetSize ==>'+OffsetSize);
searchWows();
}
public void LastPage()
{
this.page = totalPages;
OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
searchWows();
}
public boolean getprev()
{

if(OffsetSize == 0){

return true;
}
else {

return false;
}
}
public boolean getnxt()
{
if((OffsetSize + LimitSize) > totalRecs){

return true;
}
else {

return false;
}
}


}