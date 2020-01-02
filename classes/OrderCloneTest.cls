/*
* Class Name       : OrderCloneTest
* Description      : This Apex Class is test class of the class OrderClone. 
* TestClass        : N/A
* ***************************************************************************************************************
* Developer Note   : *
* ***************************************************************************************************************
*/
@isTest(seealldata=true)
public class OrderCloneTest {
     @isTest
    public static void TestMethod1(){
           Util.Bypass_Trigger_Chk = true;
           Order__c objOrder = TestUtil.createOrders(1,true)[0];
           String strObjName = 'Product2';
           String strWhereCondition = 'APN_Number__c in ( \'3GP00209AAAA\',\'ED-012-NV-WEXV\',\'PC-170-NV-PCPENTST\',\'PS-170-PURE-SVTOKEN\',\'TH-900-PCEDGE-2120200\')';  
           List<Product2> list_Prods = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
           List<Order_Line_Item__c> list_OLI = TestUtil.createOrderLines(list_Prods, objOrder.id, true);
           ServiceContract objSC = TestUtil.createServiceContracts(1,true)[0];
           objSC.ORder__C = objOrder.Id;
           update objSC;
           Account_Order_Address__c objAccountAddressBillTo =  new Account_Order_Address__c(Address_Type__c = 'Bill To',Order__C = objOrder.Id );
           insert objAccountAddressBillTo;  
           Blob objblob = Blob.valueOf('asd;fljalsjdlf;jalksdjf');  
           Attachment objAttachment =  new Attachment(ParentId  = objOrder.Id,Name = 'Test Att ',Body = objblob );
           insert objAttachment;  
           OrderClone.OrderCloneClass(objOrder.Id); 
    }

}