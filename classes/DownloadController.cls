/*
	06/22/2013	Naresh Kumar
*/
public with sharing class DownloadController {	
	    public Boolean isPremiseUser {get; set;}
        public String dltype {get; set;}
        public DownloadController() {

           dltype = 'CD';
           isPremiseUser = ContactUtil.isPremiseUser();
        }
}