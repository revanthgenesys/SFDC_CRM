public class CloudBillingData {
    public Boolean blnIsPreBill {get; set;}
    public String month {get; set;}
    public String year  {get; set;}
    public String day   {get; set;}
    public String subsidiary {get; set;}
    public String region {get; set;}
    public String contractId {get; set;}
    public String edition {get; set;}

    public CloudBillingData() {}
    public CloudBillingData(Boolean isPreBill, String strMonth, String strYear, String strDay) {
        this.blnIsPreBill = isPreBill;
        this.month = strMonth;
        this.year = strYear;
        this.day = strDay;
    }
    public void debug() {
        System.Debug('blnIsPreBill:' + blnIsPreBill);
        System.Debug('day:' + day);
        System.Debug('month:' + month);
        System.Debug('year:' + year);
        System.Debug('subsidiary:' + subsidiary);
        System.Debug('region:' + region);
        System.Debug('contractId:' + contractId);
        System.Debug('edition:' + edition);
    }
}