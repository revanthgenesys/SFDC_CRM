public class BackOfficeAccountServContractsController {
        
        public transient List<ServiceContract> srvContrLst {get; private set;}
        Id boaId = null;
        
        public BackOfficeAccountServContractsController (ApexPages.StandardController stdController) {
                boaId = stdController.getId();          
        }
        
        public void activeSrvContracts() {
                if (boaId != null)
                  srvContrLst = BackOfficeAccountService.getServiceContractsByBoaId(boaId, 'active');
        }
        
        public void closedSrvContracts() {
                if (boaId != null)
                  srvContrLst = BackOfficeAccountService.getServiceContractsByBoaId(boaId, 'closed');
        }
        
}