@isTest
private class SizeCalReader_test{
   static testMethod void methodSizeCalReader1(){ 
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_test());
      SizeCalReader objSizeCalReader = new SizeCalReader();   
      objSizeCalReader.url = 'http://test.com';
      objSizeCalReader.redirect();
  }
 }