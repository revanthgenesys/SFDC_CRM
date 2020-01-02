public class LMS_LicenseGenerationRequestWrapper {

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
        public String AccountName{get;set;}
        public List<String> MachineIds{get;set;}
        public List<String> MachineNames{get;set;}
        public String ProductName{get;set;}
        public String ProductVersion{get;set;}
        public String Description{get;set;}
        public String GenerationDate{get;set;}
        public String ExpirationDate{get;set;}
        public List<Licenses> Licenses{get;set;}
        public List<Features> Features{get;set;}
        public InvalidatedLicenseIdentifierCollection InvalidatedLicenseIdentifierCollection{get;set;}
        public String BundleName{get;set;}
        public Integer BundleType{get;set;}
        public String LicenseTypeGUID{get;set;}
        public Boolean CombineServersIntoOneBundle{get;set;}
    }

    public class Licenses {
        public String Name {get;set;}
        public String Assigned {get;set;}
        public String Pooled {get;set;}
    }

    public class Features {
        public String Name{get;set;}
    }

    
  /*  public static JSON2Apex parse(String json) {
        return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
    }*/
}