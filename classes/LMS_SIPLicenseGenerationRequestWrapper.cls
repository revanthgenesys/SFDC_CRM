public class LMS_SIPLicenseGenerationRequestWrapper {

    public class InvalidatedLicenseIdentifiers {
        public String AccountId;
        public String ProductId;
        public String LiceneseId;
        public String LicenseIdentifier;
        public String MachineId;
        public Boolean IsLicenseActive;
        public InvalidatedLicenseIdentifiers(String accId, String PrdId, String LicId, String Identifier, String MacId, Boolean isActive){
            AccountId = accId;
            ProductId = PrdId;
            LiceneseId = LicId;
            LicenseIdentifier = Identifier;
            MachineId = MacId;
            IsLicenseActive = isActive;
        }
    }

    public class InvalidatedLicenseIdentifierCollection {
        public List<InvalidatedLicenseIdentifiers> InvalidatedLicenseIdentifiers;
    }

    public class LMS_LicenseGenerationRequest {
        public String CompanyName{get;set;}
        public String MachineId{get;set;}
        public String MachineName{get;set;}
        public String ProductName{get;set;}
        public String VersionNumber{get;set;}
        public String Description{get;set;}
        public String GenerationDate{get;set;}
        public String ExpirationDate{get;set;}
        public Map<String,String> Licenses{get;set;}
        public List<String> Features{get;set;}
        public InvalidatedLicenseIdentifierCollection InvalidatedLicenseIdentifierCollection{get;set;}
        public Integer BundleType{get;set;}
        public String LicenseTypeGUID{get;set;}
    }

    
  /*  public static JSON2Apex parse(String json) {
        return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
    }*/
}