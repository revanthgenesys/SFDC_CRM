public class LookupController{
    public String objName {get;set;}
    public String objPrefix {get;set;}
    public String[] fieldAPINames {get;set;}
    public List<String> fieldNames {get;set;}
    public String searchText {get;set;}
    public string searchStr {get;set;}
    public string role {get;set;}
    public string queryStr {get;set;}
    public string query {get;set;}
    public Set<Sobject> objects {get{
        objects=new set<Sobject>();
        
        if((searchStr != null ) || (queryStr != null && queryStr != '')) {
            if(query == null || query == ''){
                query = 'Select ';
                if(role != ''){
                    for(integer i=0; i<fieldAPINames.size();i++)
                        fieldAPINames[i]=  role+'.'+fieldAPINames[i] ;
                }
                for(integer i=0; i<fieldAPINames.size();i++)
                    query+=  fieldAPINames[i] + ',';
                
                query = query.substring(0, query.length()-1);
                query += ' from '+ objName +' where '; 
                if(role=='')
                    query += 'Name ';
                else 
                query += role+'.Name ';
            }
            String dbQuery = query + 'Like \'%' + String.escapeSingleQuotes(searchStr) + '%\'' + queryStr + ' limit 100';
            System.debug('NKC debug dbQuery ['+dbQuery+']');
            if(role != ''){
                List<Sobject> accounts=Database.query(dbQuery);
                Set<string> accountNames = new Set<string>();
                for (Sobject acc : accounts){
                    SObject account = acc.getSObject(role);
                    String name = (String) account.get('name'); 
                    //String roleName = (string)acc.get(role +'.Name');
                    if(!accountNames.contains(name)){
                        objects.add(acc);
                        accountNames.add(name);
                    }
                }
            }else objects.addAll(Database.query(dbQuery));
        }
        return objects;}
      set;}
                                              
                                                  
    public LookupController(){
        if(searchStr == null || searchStr == '')
            searchStr = Apexpages.currentPage().getParameters().get('searchText');
        if(fieldAPINames == null && Apexpages.currentPage().getParameters().get('fields') != null)
            fieldAPINames = Apexpages.currentPage().getParameters().get('fields').split(',');
        objPrefix = Apexpages.currentPage().getParameters().get('op');
        if(role== null)
            role = Apexpages.currentPage().getParameters().get('role');
            queryStr = Apexpages.currentPage().getParameters().get('query');
            if(queryStr != null)
            queryStr = queryStr.replace('\"', '\'');
       if(objPrefix=='810')
            objName = 'ServiceContract';
        if(obJPrefix =='a0y')
            objName = 'Support_Access__c';
        if(objPrefix =='001')
            objName= 'Account';
        if(objPrefix == '003')
            objName = 'Contact';
        fieldNames = new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema ;
        if(role == null || role =='')
            objSchema = schemaMap.get(objName);
        else{
            objSchema = schemaMap.get('Account');
        }
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
        for(String fname : fieldAPINames){
            fieldNames.add(fieldMap.get(fname).getDescribe().getLabel());//It provides to get the object fields label.
        }
    }
    
}