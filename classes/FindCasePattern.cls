/*
    Naresh Kumar    07/01/2013
*/
public without sharing class FindCasePattern {

    public static String fetchCaseNo(String str){
        Integer caseNumberLength = 10;
        if(str.indexOf('#') >= 0){
            Boolean isSRNumber = false;
            if(str.replace(' ', '').indexOf('SR#') >= 0)
                isSRNumber = true;
            str = str.split('#')[1];
            if(str.contains('-')){
                str = str.split('-')[0];        
                str = str.replace(' ', '');
            }   
            else{
                while(str.indexOf('  ') >= 0)
                    str = str.replace('  ', ' ');
                while(str.substring(0,1) == ' ')
                    str = str.substring(1);
                str = str.split(' ')[0];
            }
            if(str.length() > 7){
                while(!str.substring(str.length() - 1, str.length()).isNumeric()){
                    str = str.substring(0, str.length() - 1);
                }   
            }
            if(isSRNumber == false){    
                if(str.length() < caseNumberLength){
                    while(str.length() < caseNumberLength)
                        str = '0' + str;
                }
            }
            if(str.length() > caseNumberLength)
                str = str.substring(0, caseNumberLength);
                
            str = str.replace(':','');
        }
        return str;
    }
}