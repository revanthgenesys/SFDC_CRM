public Class ErrorLogItem{
  public Id id {get; set;}
  public String objectTypeItem {get; set;}
  public String ErrorMsg {get; set;}
  
  
static testMethod void testErrorLogItem()
{
	System.debug('START ErrorLogItem.testErrorLogItem');
	Account a = TestCommon.createAccount(true);
	ErrorLogItem erLi = new ErrorLogItem();
	erLi.Id = a.Id;
	erLi.objectTypeItem = 'Account';
	erLi.ErrorMsg = 'Error Message';
	System.debug('END ErrorLogItem.testErrorLogItem');
}   
}