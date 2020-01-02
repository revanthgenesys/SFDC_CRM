public with sharing class LicensePaginationController{  
   Map<integer,List<SummaryRecord>> mapSummaryPages = new Map<integer,List<SummaryRecord>>(); 
   public String sourceKey{get;Set;}
   String currentKey;
   public Integer pageSize {get; set;}
   public String title {get; set;} 
   public List<LicenseSummaryWrapper> summaryLst {get; 
   set{
   system.debug('inside summaryLst setter sourceKey: '+sourceKey+' currentKey: '+currentKey);
       //if(mapSummaryPages.size()==0){
        if(!sourceKey.equalsIgnoreCase(currentKey)){
           mapSummaryPages = new Map<integer,List<SummaryRecord>>(); 
           currentKey = sourceKey; 
           summaryLst = value;
           setPagination();
           system.debug('inside if condition currentKey updated:'+currentKey);
       }   
   }
   } 
   public integer intPageNumber{get;set;}  
   public integer intNumberofPages{get;set;}  

   public List<SummaryRecord> getLstRecords(){  
     List<SummaryRecord> lstRec= new List<SummaryRecord>();  
     lstRec.addAll(mapSummaryPages.get(intPageNumber));  
     return lstRec;  
   }  
    public LicensePaginationController() {  
     pageSize = 10;
     title = 'Select Any Add-on Item';
   } 

   public Pagereference setPagination() {  
     integer NumberofRecords = 0;  
     integer pagenumber = 1;  

     for (LicenseSummaryWrapper objRec :summaryLst) {  
       if (NumberofRecords < pageSize) {  
         if (mapSummaryPages.containsKey(pagenumber)){  
           mapSummaryPages.get(pagenumber).add(new SummaryRecord(objRec,false));  
         }  
         else {  
           mapSummaryPages.put(pagenumber,new List<SummaryRecord>{new SummaryRecord(objRec,false)});  
         }  
         NumberofRecords++;  
         if (NumberofRecords == pageSize) {  
           NumberofRecords = 0;  
           pagenumber++;  
         }  
       }  
     }  
     intNumberofPages = mapSummaryPages.size();  
     intPageNumber = 1;  
     getLstRecords();  
     return null;  
   }  
   
   public Integer getColNumber(){
      return Crypto.getRandomInteger();
   } 
   
   public Boolean hasNext {  
     get {  
       if (intNumberofPages <= intPageNumber) {  
         return false;  
       }  
       else {  
         return true;  
       }  
     }  
     set;  
   }  
   public Boolean hasPrevious {  
     get {  
       if (intPageNumber == 1) {  
         return false;  
       }  
       else {  
         return true;  
       }  
     }  
     set;  
   }  
   public void first() {  
      intPageNumber = 1;  
      getLstRecords();  
   }  
   public void last() {  
      intPageNumber = intNumberofPages;   
      getLstRecords();  
   }   
   public void previous() {  
      intPageNumber--;  
      getLstRecords();  
   }  
    public void next() {  
      intPageNumber++;  
      getLstRecords();  
    }  
   
   public class SummaryRecord {  
     public LicenseSummaryWrapper objRec{get;set;}  
     public Boolean Selected{get;set;}   
     public SummaryRecord(LicenseSummaryWrapper objRec, Boolean bSel) {  
       this.objRec = objRec;  
       this.Selected = bSel;  
     }   
   }  
 }