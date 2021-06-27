import { api, LightningElement } from 'lwc';
import PicklistValues from '@salesforce/apex/PicklistCompController.getPickListValues';


export default class gearNewGearItem extends LightningElement {

    @api Category = '';
    @api ItemClothing = '';
	@api ItemMegaphone = '';	
    @api ItemNonTechTool = '';
    @api ItemOther = '';
    @api ItemStopwatch = '';
    @api ItemTechBasedTool = '';
    @api Size = '';	
    @api ClothingFit = '';
    @api Color = '';
    @api Gender = '';
    @api Logo = false;
    @api Description = '';

    objAPIName = 'Gear_Exchange__c';

    fieldCategory = 'Category__c';
    fieldItemClothing = 'Item_Clothing__c';	
    fieldItemMegaphones = 'Item_Megaphones__c';	
    fieldItemNonTechTools = 'Item_Non_tech_Tools__c';
    fieldItemOther = 'Item_Other__c';
    fieldItemStopwatches = 'Item_Stopwatchs__c';
    fieldItemTechBasedTools = 'Item_Tech_Based_Tools__c';
    fieldSize = 'Size__c';	
    fieldClothingFit = 'Clothing_Fit__c';
    fieldColor = 'Color__c';
    fieldGender = 'Gender__c';
    fieldLogo = 'USRowing_Logo__c';

    optionsCategory = [];
    optionsItemClothing = [];
	optionsItemMegaphones = [];	
    optionsItemNonTechTools = [];
    optionsItemOther = [];
    optionsItemStopwatches = [];
    optionsItemTechBasedTools = [];
    optionsSize = [];	
    optionsClothingFit = [];
    optionsColor = [];
    optionsGender = [];

    displayDescription = false;
    displayClothing = false;
    displayMegaphones = false;
    displayNontechtools = false;
    displayStopwatches = false;
    displayTechbasedtools = false;
    displayOtheritems = false;

    selectedCategory;

    description;

    error;

    async connectedCallback() {

        this.logmessage('obj: ' + this.objAPIName + ' field: ' + this.fieldCategory);

        // Category
        PicklistValues({
                pObjAPIName: this.objAPIName,
                pFieldAPIName: this.fieldCategory
            })
            .then(result => {
                this.logmessage('result = ' + JSON.stringify(result));
                this.optionsCategory = this.buildSelectOptions(result);
                //this.logmessage('options = ' + JSON.stringify(this.options));
                this.error = '';
            }).catch(error => {
                console.error("received error: " + error);
                this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
                this.error = error;
            });

        // Item Clothing    
        PicklistValues({
                pObjAPIName: this.objAPIName,
                pFieldAPIName: this.fieldItemClothing
            })
            .then(result => {
                this.logmessage('result = ' + JSON.stringify(result));
                this.optionsItemClothing = this.buildSelectOptions(result);
                //this.logmessage('options = ' + JSON.stringify(this.options));
                this.error = '';
            }).catch(error => {
                console.error("received error: " + error);
                this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
                this.error = error;
            });

        // Item Megaphones    
        PicklistValues({
                pObjAPIName: this.objAPIName,
                pFieldAPIName: this.fieldItemMegaphones
            })
            .then(result => {
                this.logmessage('result = ' + JSON.stringify(result));
                this.optionsItemMegaphones = this.buildSelectOptions(result);
                //this.logmessage('options = ' + JSON.stringify(this.options));
                this.error = '';
            }).catch(error => {
                console.error("received error: " + error);
                this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
                this.error = error;
            });

        // Item Non-tech Tools    
        PicklistValues({
                pObjAPIName: this.objAPIName,
                pFieldAPIName: this.fieldItemNonTechTools
            })
            .then(result => {
                //this.logmessage('result = ' + JSON.stringify(result));
                this.optionsItemNonTechTools = this.buildSelectOptions(result);
                this.logmessage('optionsItemNonTechTools = ' + JSON.stringify(this.optionsItemNonTechTools));
                this.error = '';
            }).catch(error => {
                console.error("received error: " + error);
                this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
                this.error = error;
            });

        // Item Other    
        PicklistValues({
                pObjAPIName: this.objAPIName,
                pFieldAPIName: this.fieldItemOther
            })
            .then(result => {
                this.logmessage('result = ' + JSON.stringify(result));
                this.optionsItemOther = this.buildSelectOptions(result);
                //this.logmessage('options = ' + JSON.stringify(this.options));
                this.error = '';
            }).catch(error => {
                console.error("received error: " + error);
                this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
                this.error = error;
            });

        // Item Stopwatches    
        PicklistValues({
                pObjAPIName: this.objAPIName,
                pFieldAPIName: this.fieldItemStopwatches
            })
            .then(result => {
                this.logmessage('result = ' + JSON.stringify(result));
                this.optionsItemStopwatches = this.buildSelectOptions(result);
                //this.logmessage('options = ' + JSON.stringify(this.options));
                this.error = '';
            }).catch(error => {
                console.error("received error: " + error);
                this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
                this.error = error;
            });

        // Item Tech Based Tools    
        PicklistValues({
                pObjAPIName: this.objAPIName,
                pFieldAPIName: this.fieldItemTechBasedTools
            })
            .then(result => {
                this.logmessage('result = ' + JSON.stringify(result));
                this.optionsItemTechBasedTools = this.buildSelectOptions(result);
                //this.logmessage('options = ' + JSON.stringify(this.options));
                this.error = '';
            }).catch(error => {
                console.error("received error: " + error);
                this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
                this.error = error;
            });

        // Clothing Size    
        PicklistValues({
                pObjAPIName: this.objAPIName,
                pFieldAPIName: this.fieldSize
            })
            .then(result => {
                this.logmessage('result = ' + JSON.stringify(result));
                this.optionsSize = this.buildSelectOptions(result);
                //this.logmessage('options = ' + JSON.stringify(this.options));
                this.error = '';
            }).catch(error => {
                console.error("received error: " + error);
                this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
                this.error = error;
            });

        // Clothing Fit    
        PicklistValues({
                pObjAPIName: this.objAPIName,
                pFieldAPIName: this.fieldClothingFit
            })
            .then(result => {
                this.logmessage('result = ' + JSON.stringify(result));
                this.optionsClothingFit = this.buildSelectOptions(result);
                //this.logmessage('options = ' + JSON.stringify(this.options));
                this.error = '';
            }).catch(error => {
                console.error("received error: " + error);
                this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
                this.error = error;
            });

        // Clothing Color    
        PicklistValues({
                pObjAPIName: this.objAPIName,
                pFieldAPIName: this.fieldColor
            })
            .then(result => {
                this.logmessage('result = ' + JSON.stringify(result));
                this.optionsColor = this.buildSelectOptions(result);
                //this.logmessage('options = ' + JSON.stringify(this.options));
                this.error = '';
            }).catch(error => {
                console.error("received error: " + error);
                this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
                this.error = error;
            });

        // Clothing Gender    
        PicklistValues({
                pObjAPIName: this.objAPIName,
                pFieldAPIName: this.fieldGender
            })
            .then(result => {
                this.logmessage('result = ' + JSON.stringify(result));
                this.optionsGender = this.buildSelectOptions(result);
                //this.logmessage('options = ' + JSON.stringify(this.options));
                this.error = '';
            }).catch(error => {
                console.error("received error: " + error);
                this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
                this.error = error;
            });


    }

    buildSelectOptions(picklistValues) {

        const listValues = [];

        //listValues.push( {label: '-- SELECT --', value: '' } );
        Object.keys(picklistValues).forEach((index) => {
            listValues.push( {label: picklistValues[index], value: picklistValues[index]} );
        });

        return listValues;
    }

    handleCategory(event){
        // Run code when account is created.
        this.selectedCategory = event.target.value; 
        this.Category = this.selectedCategory;

        this.displayClothing = false;
        this.displayMegaphones = false;
        this.displayNontechtools = false;
        this.displayStopwatches = false;
        this.displayTechbasedtools = false;
        this.displayOtheritems = false;
        this.displayDescription = false;    

        switch(this.selectedCategory) {
            case "Clothing":
                this.displayClothing = true;
                this.displayDescription = true;
                break;
            case "Megaphone(s)":    
                this.displayMegaphones = true;
                this.displayDescription = true;
                break;
            case "Non-tech tools":    
                this.displayNontechtools = true;
                this.displayDescription = true;
                break;
            case "Stopwatch(s)":    
                this.displayStopwatches = true;
                this.displayDescription = true;
                break;
            case "Tech Based Tools":    
                this.displayTechbasedtools = true;
                this.displayDescription = true;
                break;
            default:
                this.displayOtheritems = true;
                this.displayDescription = true;
                break;
        }

    }

    handleItemClothing(event){
        // Run code when account is created.
        this.ItemClothing = event.target.value; 
    }

    handleGender(event){
        // Run code when account is created.
        this.Gender = event.target.value; 
    }

    handleSize(event){
        // Run code when account is created.
        this.Size = event.target.value; 
    }

    handleLogo(event) {
        
        this.Logo = event.target.checked;
        this.logmessage('logo='+ this.Logo);
        
    }

    handleFit(event){
        // Run code when account is created.
        this.ClothingFit = event.target.value; 
    }

    handleColor(event){
        // Run code when account is created.
        this.Color = event.target.value; 
    }

    handleItemMegaphones(event){
        // Run code when account is created.
        this.ItemMegaphone = event.target.value; 
    }

    handleItemNonTechTools(event){
        // Run code when account is created.
        this.ItemNonTechTool = event.target.value; 
    }
    handleItemOther(event){
        // Run code when account is created.
        this.ItemOther = event.target.value; 
    }

    handleItemStopWatches(event){
        // Run code when account is created.
        this.ItemStopwatch = event.target.value; 
    }

    handleTechBasedTools(event){
        // Run code when account is created.
        this.ItemTechBasedTool = event.target.value; 
    }

    handleDescripiton(event){
        // Run code when account is created.
        this.Description = event.target.value; 
    }

   //  THIS IS A LITTLE FUNCTION TO HELP WITH LOGGING
   logmessage(msg) {
        msg = 'loadNewGear: ' + msg;
        console.log(msg);
    }

}