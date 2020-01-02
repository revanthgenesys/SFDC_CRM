/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestCtrl_06_VF07_PrimaryBusinessPartner {

    static testMethod void myUnitTest() {
    	Opportunity opp= [select id from Opportunity limit 1];
    	Apexpages.Standardcontroller con = new Apexpages.Standardcontroller(opp); 
        Ctrl_06_VF07_PrimaryBusinessPartner ctrl = new Ctrl_06_VF07_PrimaryBusinessPartner(con);
        ctrl.searchtext='*test*';
        list<Account> accounts = ctrl.accounts;
        ctrl.search();
        ctrl.cancel();
        ctrl.save();
    }
    static testMethod void myUnitTest2() {
    	Opportunity opp= [select id from Opportunity limit 1];
    	Pagereference p = Page.VF07_PrimaryBusinessPartner;
    	p.getParameters().put('id',opp.Id);
    	p.getParameters().put('sec','1');
    	Test.setCurrentPage(p);
    	Apexpages.Standardcontroller con = new Apexpages.Standardcontroller(opp); 
        Ctrl_06_VF07_PrimaryBusinessPartner ctrl = new Ctrl_06_VF07_PrimaryBusinessPartner(con);
        ctrl.searchtext='*test*';
        list<Account> accounts = ctrl.accounts;
        ctrl.search();
        ctrl.cancel();
        ctrl.save();
    }
}