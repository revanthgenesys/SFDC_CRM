public class LicenseRequestWebFormSelections {
	
	public static Map<String, Boolean> visiblFlags(String reqType, String categ, String fileType) {
		
		Map<String, Boolean> flags = new Map<String, Boolean> {
			'isAFRtype'	     => false,
			'fileCatPpu'	 => false,
			'fileCatGenesys' => false,
			'fileThrdPrt'    => false,
			'showClarifyReqGenericPrompt' => false,
			'showDeplType'  => false,
			'showImplType'  => false,
			'showOS'        => false,
			'showPBX'       => false,
			'showSoPo'      => false,
			'showPrimHost'  => false,
			'showBackHost'  => false,
			'showPrimBcDr'  => false,
			'showBackBcDr'  => false,
			'showExtDate'   => false,
			'showThrdParAF'  => false,
			'showIvrConfig'  => false,
			'showExprDate'   => false,
			'showPortType'   => false
		};
		
		if ( reqType == 'Activation File Request' ) 
		      flags.put('isAFRtype', true);	
        if ( categ == 'Pay Per Use/Hosted Activation File' )
               flags.put('fileCatPpu', true);        
        if ( categ == 'Genesys Activation File' )
              flags.put('fileCatGenesys', true);             
        if ( categ == 'Third Party Activation File' )
              flags.put('fileThrdPrt', true);
              
  // Genesric prompt for the Clarify Request text box       
        if ( fileType== 'Business Objects/Interactive Insights' || fileType== 'Audio Codes' ||
             fileType=='Expansion/Add-on to Original Deployment' || fileType== 'Third Party - Audio Codes' ||
             fileType== 'Third Party - Business Objects/Interactive Insights' ||
             fileType== 'Third Party - VMware' || fileType== 'Other' || fileType== 'Convert to Permanent' )             
                flags.put('showClarifyReqGenericPrompt', true); 
  // Deployment Type
        if ( fileType== 'New Deployment' || fileType== 'Additional Lab Files' || 
               fileType== 'Additional Test Files' || fileType== 'Voice Genie' ||
               fileType== 'Third Party - Aria' || fileType== 'Third Party - Business Objects/Interactive Insights' ||
               fileType== 'Third Party - Business Objects/Genesys Reporting' || fileType== 'Third Party - Nuance' ||
               fileType== 'Third Party - Zoom' || fileType== 'Third Party - SilverLining' ||
               fileType== 'GCIP' || fileType== 'Virtual Hold' || fileType== 'SpeechStorm' || fileType== 'Genesys GIR and Speech Analytics')                  
                 flags.put('showDeplType', true);         
 ///Implementation Type
        if ( categ == 'Pay Per Use/Hosted Activation File' || fileType== 'Additional Lab Files' || fileType== 'Voice Genie' || 
               fileType== 'Third Party - Aria' || fileType== 'Third Party - Business Objects/Interactive Insights' ||
               fileType== 'Third Party - Business Objects/Genesys Reporting' || fileType== 'Third Party - Nuance' ||
               fileType== 'Third Party - Zoom' || fileType== 'Third Party - VMware' ||
               fileType== 'Third Party - SilverLining' || fileType== 'GCIP' || fileType== 'GIR and Speech Analytics' ||
               fileType== 'Virtual Hold' || fileType== 'SpeechStorm' || fileType== 'Genesys GIR and Speech Analytics')
                  flags.put('showImplType', true);
   // OS
        if ( fileType== 'New Deployment' || fileType== 'Additional Lab Files' || fileType== 'Partner Lab' ||
               fileType== 'Evaluation' || fileType== 'Additional Test Files' ||
               fileType==  'Seat Reallocation' || fileType== 'Genesys' || fileType== 'Upgrade' ) 
                  flags.put('showOS', true);
 ///PBX/SIP         
         if ( fileType== 'New Deployment' || fileType== 'Additional Lab Files' || fileType== 'Rehost' || 
              fileType== 'Genesys' || fileType== 'Evaluation' || fileType== 'Partner Lab' )                 
                flags.put('showPBX', true);
  //SO or PO                       
        if ( categ == 'Pay Per Use/Hosted Activation File' || fileType== 'New Deployment' || fileType== 'Additional Lab Files' || 
             fileType== 'Expansion/Add-on to Original Deployment' || fileType== 'Rehost' ||
             fileType== 'Evaluation' || fileType== 'Voice Genie' || fileType== 'Partner Lab' ||
             fileType== 'Third Party - Aria' || fileType== 'Third Party - Business Objects/Interactive Insights' ||
             fileType== 'Third Party - Nuance' || fileType== 'Third Party - Audio Codes' ||
             fileType== 'Third Party - Zoom' || fileType== 'Third Party - VMware' ||
             fileType== 'Third Party - SilverLining' || fileType== 'GCIP' || fileType== 'GIR and Speech Analytics' ||
             fileType== 'Virtual Hold' || fileType== 'SpeechStorm' || fileType== 'Genesys GIR and Speech Analytics')
             flags.put('showSoPo', true);         
  //Primary MacId or HostId
        if ( fileType== 'New Deployment' || fileType== 'Additional Lab Files' || fileType== 'Genesys' ||
             fileType== 'Rehost' || fileType== 'Evaluation' || fileType== 'Evaluation' || fileType== 'Partner Lab' ||
             fileType== 'Additional Test Files' || fileType== 'Seat Reallocation' ||
             fileType== 'Voice Genie' || fileType== 'Third Party - Nuance' || fileType== 'Upgrade' )
               flags.put('showPrimHost', true);
  //Backup MacId or HostId
        if ( fileType== 'New Deployment' || fileType== 'Additional Lab Files' || fileType== 'Genesys' ||
             fileType== 'Rehost' || fileType== 'Additional Test Files' || fileType== 'Evaluation' || fileType== 'Partner Lab' )
               flags.put('showBackHost', true);
//Third Party fields               
         if ( fileType== 'Temporary File Extension Third Party' || fileType== 'Temporary File Extension' )
               flags.put('showExtDate', true);
               
         if ( fileType== 'Temporary File Extension Third Party' )  
               flags.put('showThrdParAF', true);
  
         if ( fileType== 'Voice Genie' ) 
             flags.put('showIvrConfig', true);

         if ( fileType== 'Voice Genie' || fileType== 'Additional Test Files' ) 
             flags.put('showExprDate', true);
         
         if (  fileType== 'New Deployment' || fileType== 'Additional Lab Files' || fileType== 'Rehost' || 
               fileType== 'Genesys' || fileType== 'Partner Lab' ) {
             flags.put('showPrimBcDr', true);
             flags.put('showBackBcDr', true);
         }
         
         if ( fileType== 'Genesys' ) 
             flags.put('showPortType', true);
         
         
         return flags;
	}
		
	public static List<SelectOption> implmnts (String categ, String fileType) {
		
		 List<SelectOption> opts = new List<SelectOption>();         
            opts.add(new SelectOption('', '--None--'));
            opts.add(new SelectOption('Add-on', 'Add-on'));
            opts.add(new SelectOption('Temporary', 'Temporary'));
            opts.add(new SelectOption('Migration', 'Migration'));

            if ( categ == 'Pay Per Use/Hosted Activation File' ) {
            	opts.add(new SelectOption('New Deployment', 'New Deployment'));
            	opts.add(new SelectOption('Upgrade', 'Upgrade'));
            	opts.add(new SelectOption('Reallocation', 'Reallocation'));            	
            }
            else if ( fileType == 'Voice Genie' ) {
                opts.add(new SelectOption('Upgrade to GVP', 'Upgrade to GVP'));
                opts.add(new SelectOption('Reallocation', 'Reallocation'));
            }
            else if ( fileType == 'Third Party - SilverLining' ) {
            	opts.add(new SelectOption('New Deployment', 'New Deployment'));
                opts.add(new SelectOption('Evaluation', 'Evaluation'));
                opts.add(new SelectOption('Internal', 'Internal'));
                opts.add(new SelectOption('Partner', 'Partner'));
            }
            else if ( fileType == 'GCIP') {
                opts.add(new SelectOption('Internal', 'Internal'));
                opts.add(new SelectOption('Reallocation', 'Reallocation'));  
            }
            else if ( fileType == 'Third Party - VMware' )  {
                opts.add(new SelectOption('New Deployment', 'New Deployment'));
            }
            else if ( fileType == 'Third Party - Business Objects/Interactive Insights' || 
                      fileType == 'Third Party - Business Objects/Genesys Reporting' )  {
                opts.add(new SelectOption('New Deployment', 'New Deployment'));
                opts.add(new SelectOption('Evaluation', 'Evaluation'));
                opts.add(new SelectOption('Internal', 'Internal'));
                opts.add(new SelectOption('Upgrade', 'Upgrade'));
                opts.add(new SelectOption('Partner', 'Partner'));  
            }
            else  {
            	opts.add(new SelectOption('New Deployment', 'New Deployment'));
                opts.add(new SelectOption('Evaluation', 'Evaluation'));
                opts.add(new SelectOption('Internal', 'Internal'));
                opts.add(new SelectOption('Upgrade', 'Upgrade'));
                opts.add(new SelectOption('Reallocation', 'Reallocation'));
                opts.add(new SelectOption('Partner', 'Partner'));
            } 
            
            opts.sort();
                                  
            return opts;
	}
	
	public static List<SelectOption> deplmnts (String fileType) {
		 List<SelectOption> opts = new List<SelectOption>();         
            opts.add(new SelectOption('', '--None--'));
            opts.add(new SelectOption('Production', 'Production'));
            opts.add(new SelectOption('Lab', 'Lab'));
   //Genesys        
            if ( fileType == 'Additional Test Files' ) {
                opts.add(new SelectOption('Test', 'Test'));
                opts.add(new SelectOption('Disaster Recovery Cold Standby', 'Disaster Recovery Cold Standby'));
                opts.add(new SelectOption('Disaster Recovery Hot Standby', 'Disaster Recovery Hot Standby'));       
                opts.add(new SelectOption('PPU', 'PPU'));
            }
            else if ( fileType == 'New Deployment' ) {
                opts.add(new SelectOption('Test', 'Test'));
                opts.add(new SelectOption('Disaster Recovery Cold Standby', 'Disaster Recovery Cold Standby'));
                opts.add(new SelectOption('Disaster Recovery Hot Standby', 'Disaster Recovery Hot Standby')); 
           }
            else if ( fileType == 'Voice Genie' ) {
                opts.add(new SelectOption('Test', 'Test'));
                opts.add(new SelectOption('Evaluation', 'Evaluation'));
            }
   //BO
            else if ( fileType == 'Third Party - Business Objects/Interactive Insights' || 
                      fileType == 'Third Party - Business Objects/Genesys Reporting' ||
                      fileType == 'Business Objects/Interactive Insights' )  {
                    /// add nothing     
            }
  ////Deployment type
            else {
                opts.add(new SelectOption('Test', 'Test'));
            }                                                
            return opts;
	}

}