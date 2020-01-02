/* Name           : QuoteRequestDataCenterSubmit
Purpose        : Change the Status of MPLS/RVA/DataCenter QuoteRequest to 'Submitted'
Developer      : Vikas Menon 
Created Date   : 07-Jan-2013
*/
global class QuoteRequestDataCenterSubmit {
    // A Web Service Method that Changes the 'Status' field of MPLS/RVA/DataCenter QuoteRequest to 'Submitted'
    
    webservice static String submitStatus(Id qId){       
        String msg = 'success'; 
        try{
            update new MPLS_RVA_Quote_Request__c(id = qId, status__c = 'Submitted');
        }catch(Exception e){
            msg = 'fail';
            //msg = 'fail Reason - '+e;
        }
        return msg;
        
    }
}