@isTest
public class ConsultingLeadFormExtTest {
  
  static testMethod void pubtst() {
      ConsultingLeadFormExt  hh = new ConsultingLeadFormExt();
      hh.Company ='Company';
      hh.First_Name ='Company';
      hh.Last_Name  ='Company';
      hh.Job_Title ='Company';
      hh.Phone ='Company';
      hh.Address ='Company';
      hh.City ='Company';
      hh.Postal_Code ='Company';
     
      hh.Company_Website ='Company';
      hh.Country    = Label.DefaultCountry;
      //hh.OwnerId      = Label.DefaultOwner;
      hh.save();
  }
  
}