/*********************************************
09112013 - Suman - For any given account, show
                   total maintained quantity 
                   and puchased qty grouped by product
11272013 suman Version 2 all order lines for purchased qty, 
                    not just active
**********************************************/
global with sharing class LicAuditController2
{

    public PageReference gotoProduct() {
        System.debug('*****'+selectedproduct);
        return new PageReference('/apex/licauditprd?prd='+selectedproduct);
    }
    
    set<string> setOrigLivInv = new set<string>();
    Set<string> setOrd = new set<string>();
    public Contact cnt{get;set;}
    public List<string> lstPrd{get;set;}
    public string accid{get;set;}
    public string selectedProduct{get;set;}
    public string sortField{get;set;}
    public string sortOrder{get;set;}
    public Account acc{get;set;}
    Map<string,decimal> mapPrdPreCnt = new Map<string,decimal>();
    //wrapper class to show in the ui
    public class wrapper implements Comparable 
    {
        LicAuditController2 outerCA;
        public decimal maintainedquantity{get;set;}  
        public decimal purchasedquantity{get;set;}
        public decimal actpurchasedquantity{get;set;}
        public decimal actualquantity{get;set;}
        //lic invoice number,ContractLineItem
        public map<string,List<ContractLineItem>> mapLicInvQty{get;set;} 
        string description;
        public string productid;
        public string baseitem{get;set;}
        public string LineItemIds{get;set;} 
        public string orderLineIds{get;set;} 
        public string actorderLineIds{get;set;} 
        public decimal preQty{get;set;}
        set<string> ordLineNames = new Set<string>();
        
        public wrapper(LicAuditController2 outercls)
        {
            maintainedquantity=0;
            purchasedquantity=0;
            actpurchasedquantity=0;
            actualquantity=0;
            LineItemIds='';
            orderLineIds='';
            actorderLineIds='';
            preQty=0;
            mapLicInvQty = new Map<string,List<ContractLineItem>>();
            ordLineNames = new Set<string>();
            this.outerCA= outercls;
        }
        public Integer compareTo(Object compareTo) 
        {
            Wrapper compareToWra = (Wrapper)compareTo; 
            System.debug('*****compareToWra: '+compareToWra);       
            if(outerCA.sortField=='maintainedquantity')
            {
                
                if(outerCA.sortOrder=='dsc')
                {
                    if (maintainedquantity== compareToWra.maintainedquantity) return 0;
                    if (maintainedquantity< compareToWra.maintainedquantity) return 1;
                    return -1;  
                }
                else
                {
                    if (maintainedquantity== compareToWra.maintainedquantity) return 0;
                    if (maintainedquantity> compareToWra.maintainedquantity) return 1;
                    return -1; 
                }   
            }
            else if(outerCA.sortField=='purchasedquantity')
            {
                
                if(outerCA.sortOrder=='dsc')
                {
                    if (purchasedquantity== compareToWra.purchasedquantity) return 0;
                    if (purchasedquantity< compareToWra.purchasedquantity) return 1;
                    return -1;  
                }
                else
                {
                    if (purchasedquantity== compareToWra.purchasedquantity) return 0;
                    if (purchasedquantity> compareToWra.purchasedquantity) return 1;
                    return -1; 
                }   
            }
            else if(outerCA.sortField=='actpurchasedquantity')
            {
                
                if(outerCA.sortOrder=='dsc')
                {
                    if (actpurchasedquantity== compareToWra.actpurchasedquantity) return 0;
                    if (actpurchasedquantity< compareToWra.actpurchasedquantity) return 1;
                    return -1;  
                }
                else
                {
                    if (actpurchasedquantity== compareToWra.actpurchasedquantity) return 0;
                    if (actpurchasedquantity> compareToWra.actpurchasedquantity) return 1;
                    return -1; 
                }   
            }           
            else if(outerCA.sortField=='product')
            {
                
                if(outerCA.sortOrder=='dsc')
                {
                    return compareToWra.baseitem.compareTo(baseitem);
                }
                else
                {
                    return baseitem.compareTo(compareToWra.baseitem);
                }   
            }            
            else
            return -1;          
        }
    }
    //Main map that holds the data
    public Map<string,wrapper> mapqty{get;set;}
    Map<string,decimal> mapCur= new Map<string,decimal>();
    public LicAuditController2()
    {
        if(mapqty==null)
            mapqty = new Map<string,wrapper>();
        accid=ApexPages.CurrentPage().getparameters().get('accid');
        if(cnt==null)
            cnt = new Contact();
        if(accid!=null && accid!=''&&mapqty.size()==0)
            search();            
        acc = new Account();
    }
    public PageReference search()
    {
        mapqty.clear();
        lstPrd = new List<string>();
        mapqty = new Map<string,wrapper>();
        if(cnt.accountid!=null)
            accid=cnt.accountid;
        System.debug('*****accid'+accid+'****'+cnt.account.name);
        try{
            acc = [SELECT id,name FROM ACCOUNT where id=:accid LIMIT 1];
        }catch(exception e)
        {
            System.debug('*****Exception querying account'+e.getmessage());
        }
        
        //Get contract lines
        for(ContractLineItem cl:[select id,quantity,initial_quantity__c,current_quantity__c,
                                        pricebookentry.product2.id,Lic_Invoice__c,servicecontract.name,
                                        servicecontract.startdate,servicecontract.enddate,Original_Quantity__c,Actual_Original_Quantity__c,
                                        servicecontract.order__r.name,servicecontract.order__r.id,
                                        pricebookentry.product2.description,pricebookentry.product2.Base_Item__c,createddate,servicecontractid,Service_Contract_status__c
                                        from contractlineitem where (servicecontract.End_User_Name__c=:accid OR servicecontract.accountid= :accid)//])
                                        AND servicecontract.Agreement_Status__c = 'Active'
                                        ])
        {
            //if(cl.pricebookentry.product2.Base_Item__c!=null && !cl.pricebookentry.product2.Base_Item__c.contains('- Lab')&& cl.Lic_Invoice__c!='NEW' )
             if(cl.pricebookentry.product2.Base_Item__c!=null)
            {   
                if(mapqty.containsKey(cl.pricebookentry.product2.Base_Item__c))
                {
                    //decimal cnt = mapqty.get(cl.pricebookentry.product2.description).maintainedquantity ;
                    wrapper wra = mapqty.get(cl.pricebookentry.product2.Base_Item__c);
                    if(wra.mapLicInvQty.containsKey(cl.Lic_Invoice__c))
                    {
                        List<ContractLineItem> tempclist = wra.mapLicInvQty.get(cl.Lic_Invoice__c);
                        if(cl.createddate>tempclist[0].createddate)
                        {
                            tempclist.clear();
                            tempclist.add(cl);
                            wra.mapLicInvQty.put(cl.Lic_Invoice__c,tempclist);
                        }
                        else if (cl.createddate==tempclist[0].createddate && cl.current_quantity__c!=null)
                        {
                            tempclist.add(cl);
                            wra.mapLicInvQty.put(cl.Lic_Invoice__c,tempclist);
                        }
                    }
                    else
                    {
                        List<ContractLineItem> tempclist = new List<ContractLineItem>();
                        tempclist.add(cl);
                        wra.mapLicInvQty.put(cl.Lic_Invoice__c,tempclist);
                    }
                    mapqty.put(cl.pricebookentry.product2.Base_Item__c,wra);
                           
                }
                else
                {
                    if(cl.current_quantity__c!=null)
                    {
                        wrapper wra = new wrapper(this);
                        wra.productid = cl.pricebookentry.product2.id;
                        wra.purchasedquantity=0;
                        wra.actpurchasedquantity=0;
                        Map<string,List<ContractLineItem>> mapLicInvQtytmp = new Map<string,List<ContractLineItem>>();
                        List<ContractLineItem> lst = new List<ContractLineItem>();
                        lst.add(cl);
                        mapLicInvQtytmp.put(cl.Lic_Invoice__c,lst);
                        wra.mapLicInvQty = mapLicInvQtytmp.clone();
                        wra.baseitem = cl.pricebookentry.product2.Base_Item__c;
                        mapqty.put(cl.pricebookentry.product2.Base_Item__c,wra);
                    }
                }
            }
        }

        for(AggregateResult ar: [SELECT Product__r.base_item__c bi, Sum(Pre_Oct_2002_Qty__c) cnt 
                                            FROM License_Audit__c WHERE Account__c=:accid
                                            group by Product__r.base_item__c])
        {
            mapPrdPreCnt.put(String.valueOf(ar.get('bi')),Decimal.valueOf(String.valueOf(ar.get('cnt'))));
        }
        
        for(string baseitem:mapqty.keyset())
        {
            wrapper wra = mapqty.get(baseitem);
            double maintQty = 0;
            double purQty = 0;
            double actQty = 0;
            for(string orgLicInv:wra.mapLicInvQty.keySet())
            {
                    setOrigLivInv.addall(wra.mapLicInvQty.keySet());
                    for(ContractLineItem cl:wra.mapLicInvQty.get(orgLicInv))
                    {
                        if(cl.current_quantity__c!=null)
                            maintQty+=cl.current_quantity__c;
                        if(cl.Original_Quantity__c!=null)
                            purQty+=cl.Original_Quantity__c;
                        if(cl.Actual_Original_Quantity__c!=null)
                            actQty+=cl.Actual_Original_Quantity__c;
                        if(wra.LineItemIds=='' || wra.LineItemIds==null)
                            wra.LineItemIds = String.valueOf(cl.id).left(15);
                        else
                            wra.LineItemIds=wra.LineItemIds+','+String.valueOf(cl.id).left(15);
                    }
            }
            wra.maintainedquantity = maintQty;
            //wra.purchasedquantity = purQty;
            wra.actualquantity = actQty;
            mapqty.put(baseitem,wra);
        }
        
        for(Invoice__c inv:[SELECT id,name,Order__c from Invoice__c where name in :setOrigLivInv])
        {
            setOrd.add(inv.order__c);
        }
        
        //Get order lines
        for(Order_Line_Item__c ol:[select id,name,BigMachines_Quantity__c, Order__c,
                                    Product__r.description,Product__r.id,Product__r.Base_Item__c
                                    from Order_Line_Item__c 
                                    where Order__r.End_User_Name__c= :accid 
                                    OR Order__r.Sold_To_Name__c = :accid])
        {
            if(ol.Product__r.Base_Item__c!=null)
            {
                System.debug('*******purchased'+ol.BigMachines_Quantity__c);
                if(mapqty.containsKey(ol.Product__r.Base_Item__c))
                {
                    //decimal cnt = mapqty.get(cl.pricebookentry.product2.description).maintainedquantity ;
                    wrapper wra = mapqty.get(ol.Product__r.Base_Item__c);
                    if(ol.BigMachines_Quantity__c!=null && !wra.ordLineNames.contains(ol.name))
                    {
                        wra.purchasedquantity =wra.purchasedquantity+ ol.BigMachines_Quantity__c;                        
                        if(wra.orderLineIds=='' || wra.orderLineIds==null)
                            wra.orderLineIds = String.valueOf(ol.id).left(15);
                        else
                            wra.orderLineIds=wra.orderLineIds+','+String.valueOf(ol.id).left(15);   
                            
                        //Active purchased
                        if(setOrd.contains(ol.Order__c))
                        {
                            wra.actpurchasedquantity =wra.actpurchasedquantity+ ol.BigMachines_Quantity__c;
                            if(wra.actorderLineIds=='' || wra.actorderLineIds==null)
                                wra.actorderLineIds = String.valueOf(ol.id).left(15);
                            else
                                wra.actorderLineIds=wra.actorderLineIds+','+String.valueOf(ol.id).left(15);
                        }
                        mapqty.put(ol.Product__r.Base_Item__c,wra);
                    }                       
                }
                else
                {
                    if(ol.BigMachines_Quantity__c!=null)
                    {
                        wrapper wra = new wrapper(this);
                        wra.purchasedquantity = ol.BigMachines_Quantity__c;
                        wra.productid = ol.Product__r.id;
                        wra.baseitem = ol.Product__r.Base_Item__c;
                        wra.maintainedquantity=0;
                        set<string> tmpordLineNames = new Set<string>();
                        tmpordLineNames.add(ol.name);
                        wra.ordLineNames = tmpordLineNames;
                        if(wra.orderLineIds=='' || wra.orderLineIds==null)
                            wra.orderLineIds = String.valueOf(ol.id).left(15);
                        else
                            wra.orderLineIds=wra.orderLineIds+','+String.valueOf(ol.id).left(15);
                        if(setOrd.contains(ol.Order__c))
                        {
                            wra.actpurchasedquantity = ol.BigMachines_Quantity__c;
                            if(wra.actorderLineIds=='' || wra.actorderLineIds==null)
                                wra.actorderLineIds = String.valueOf(ol.id).left(15);
                            else
                                wra.actorderLineIds=wra.actorderLineIds+','+String.valueOf(ol.id).left(15);  
                        }
                        mapqty.put(ol.Product__r.Base_Item__c,wra);                     
                    }
                }
            }
        }
        for(string baseitem:mapqty.keyset())
        {
            wrapper wra = mapqty.get(baseitem);
            if(mapPrdPreCnt.containsKey(baseitem))
            {
                wra.preQty = mapPrdPreCnt.get(baseitem);
            }
            mapqty.put(baseitem,wra);
        }
        lstPrd.addAll(mapqty.keySet());
        lstPrd.sort();
        System.debug('****lstPrd'+lstPrd);
        return null;
    }

   public PageReference sort()
    {
        //sortField = sortFieldtmp;
        System.debug('*******sortField:'+sortField);
        System.debug('*******sortOrder:'+sortOrder);
        List<wrapper> lst =mapqty.values();
        if(sortOrder==null)
            sortOrder='asc';
        else if(sortOrder=='asc')
            sortOrder='dsc';
        else if(sortOrder=='dsc')
            sortOrder='asc';
        lst.sort();
        System.debug('******lst:'+lst);
        lstPrd.clear();
        lstprd = new List<string>();
        for(Wrapper wra:lst)
        {
            lstPrd.add(wra.baseitem);
        }
        return null;
    } 
    public PageReference createExcel()
    {
        return Page.licauditexcel2;
    }  
}