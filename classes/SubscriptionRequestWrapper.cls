public with sharing class SubscriptionRequestWrapper {
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

    public class SubscriptionRequest {
        public String AccountName{get;set;}
        public String CompanyIdentifier{get;set;}
        public String GenesysIdentifier{get;set;}
        public String S3UserName = 'AKIAIMTO3HCQJ4TH4ULQ';
        public String S3UserPassword = 'bNdJaVKDR0BbxywK2hE7uCWsb7i89Q7yLKdcC1wJ';
        public String ProductName{get;set;}
        public String ProductVersion{get;set;}
        public String Description{get;set;}
        public String GenerationDate{get;set;}
        public String ExpirationDate{get;set;}
        public List<Servers> Servers;
        public List<Licenses> Licenses{get;set;}
        public List<Features> Features{get;set;}
        public InvalidatedLicenseIdentifierCollection InvalidatedLicenseIdentifierCollection{get;set;}
        public String BundleName{get;set;}
        public Integer BundleType{get;set;}
        public List<DisplayInfo> DisplayInfo;
 //       public String LicenseTypeGUID{get;set;}
 //       public Boolean CombineServersIntoOneBundle{get;set;}
    }

    public class Licenses {
        public String Name {get;set;}
        public String Assigned {get;set;}
        public String Pooled {get;set;}
    }

    public class Features {
        public String Name{get;set;}
        public Features(String Name){
        	this.Name = Name;
        }
    }

   public class Servers{
        public String Id;
        public String Name; 
        public Servers(String Id, String Name){
        	this.Id = Id;
        	this.Name = Name;
        }
   }

   public class DisplayInfo{
        public String Description;
        public String User;
        public List<Parts> Parts;

        public DisplayInfo(String Description, String User, List<Parts> Parts){
        	this.Description = Description;
        	this.User = User;
        	this.Parts = Parts;
        }
   } 

   public class Parts{
   		public String PartNumber;
        public String Name;
        public String Quantity;
        public List<Features> Features;
        public List<Licenses> Licenses;

        public Parts(String PartNumber, String Name, String Quantity, List<Features> Features, List<Licenses> Licenses){
        	this.PartNumber = PartNumber;
        	this.Name = Name;
        	this.Quantity = Quantity;
        	this.Features = Features;
   			this.Licenses = Licenses;	
   		}
        
   }
}