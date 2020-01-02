// CAN BE DELETED
// Class formerly used to pass information to BatchCreateCloudMonthlySalesOrdersInfo class
// Now using more generic class CloudBillingData
// Converted to test class to no longer take up governance amounts
// iTracks 29871 Add edition String
@IsTest
public class BatchCreateCloudMonthlySalesOrdersInfo {
    public Boolean blnIsPreBill {get; set;}
    public String month {get; set;}
    public String year  {get; set;}
    public String subsidiary {get; set;}
    public String region {get; set;}
    public String contractId {get; set;}
    public String edition {get; set;}
    public BatchCreateCloudMonthlySalesOrdersInfo(Boolean isPreBill, String strMonth, String strYear) {
        this.blnIsPreBill = isPreBill;
        this.month = strMonth;
        this.year = strYear;
    }
    public void debug() {
        System.Debug('blnIsPreBill:' + blnIsPreBill);
        System.Debug('month:' + month);
        System.Debug('year:' + year);
        System.Debug('subsidiary:' + subsidiary);
        System.Debug('region:' + region);
        System.Debug('contractId:' + contractId);
        System.Debug('edition:' + edition);
    }
}