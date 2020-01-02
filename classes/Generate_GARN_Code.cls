//RaviV 12/10/2013
global without sharing class Generate_GARN_Code 
{
  webService static String nextValue()
   {
     String next=null;
     Integer maxvalue=0;
     String temp=null;
     
     Global_Setting__c obj1;
     obj1 =  Global_Setting__c.getInstance('GARN');
     temp=obj1.ID__c;
     temp=temp.trim().replaceAll('-',''); 
     Integer firstvalue=Integer.valueOf(temp);
     firstvalue++;
     obj1.ID__c =string.valueof(firstvalue);
     update obj1;
     return string.valueof(obj1.ID__c);
    }
   }