/*
 * MultiselectController synchronizes the values of the hidden elements to the
 * SelectOption lists.
 */
public with sharing class BootstrapMultiselectController {
    // SelectOption lists for public consumption
    public SelectOption[] lOptions { get; set; } //available
    public SelectOption[] rOptions { get; set; } //selected
    public sOption[] options { get {
        options = new sOption[]{};
        if(lOptions != null)
            for(SelectOption s : lOptions) options.add(new sOption(s.getLabel(), s.getValue()));
        if(rOptions != null)
            for(SelectOption s : rOptions) options.add(new sOption(s.getLabel(), s.getValue(), true));
        return options;
    } set; }
    
    
    // Parse &-separated values and labels from value and 
    // put them in option
    private void setOptions(SelectOption[] options, String value) {
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
              EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
    }
    
    // Backing for hidden text field containing the options from the
    // left list
    public String selected { get; set {
           selected = value;
           setOptions(rOptions, value);
        }
    }
    
    public String unselected { get; set {
            selected = value;
            setOptions(lOptions, value);
    	}
    }
    
    
    public class sOption {
        public String Name { get; set; }
        public String Value { get; set; }
        public Boolean Selected { get; set; }
        
        public sOption(string Name, string Value) {
            this.Name = Name;
            this.Value = Value;
            this.Selected = false;
        }
        
        public sOption(string Name, string Value, Boolean Selected) {
            this.Name = Name;
            this.Value = Value;
            this.Selected = Selected;
        }
    }
}