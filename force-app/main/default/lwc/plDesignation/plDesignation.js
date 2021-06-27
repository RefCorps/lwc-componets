/*
    plRefereeDesignation
    This is the JS element of the LWC (Lightning Web Component) bundle 'plRefereeDesignation'
    This was created using Github\lwc-recipes-master\lwc-recipes-master\force-app\main\default\lwc\
        wireGetPicklistValues\wireGetPicklistValues.js
    and
        wireGetPicklistValuesByRecordType.js    
    as models.  

    Wire adapters and JavaScript functions in these modules are built on top of Lightning Data Service (LDS) 
    and User Interface API. Use these wire adapters and functions to work with Salesforce data and metadata.
    See: lightning/uiObjectInfoApi - Get object metadata, and get picklist values.

*/

/*
    The following will import read only live bindings from the module identified
    These imported modules are in 'strict mode' that is they
        1.  silent errors are changed to thrown errors
        2.  optimizes code (sometimes)
        3.  limited the use of future syntax
    The imports below include single {myExport} and {myExport2, myExport3} where myExport is an object or value exported
    I used 'getPicklistValues' to demo the use of aliases
    SEE https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import
*/
import { api, LightningElement, wire } from 'lwc';
// import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { FlowAttributeChangeEvent } from 'tableEditDesignations/node_modules/lightning/flowSupport';

// The following imports a default export (whether it is an object, a function, a class, etc.) (Importing defaults)
import DESIGNATION_LIST from '@salesforce/schema/Designation__c.Designation__c';

/*
    plRefereeDesignation is a class
        'export' keyword labels variables and functions that should be accessible from outside the current module.
        'default' declares the class as a single entity, i.e., a single thing encapsulated by the class 
        'extends' means it inherits methods and properties from 'LightningElement'
        
*/
export default class plDesignation extends LightningElement {


    // BEGIN API VALUES
    // The following values are defined in plRefereeDesignation.js-meta.xml
    
    @api currentDesignation;
    @api defaultDesignation;

    get getCurrentDesignation() {
        this.currentDesignation = this.currentDesignation ? this.currentDesignation : this.defaultDesignation;
        this.localLog('getCurrentDesignation returning ' + this.currentDesignation);
        this.selectedDesignation = this.currentDesignation;
        return this.currentDesignation;
    }

    @api selectedDesignation;

    handleChange(event) {

        //this.currentDesignation = event.target.value;
        this.selectedDesignation = event.target.value; 
        // alert("currentDesignation1="+this.currentDesignation);
        // const attributeChangeEvent = new FlowAttributeChangeEvent('ckboxGroup', this.currentDesignation);
        const attributeChangeEvent = new FlowAttributeChangeEvent('select', this.selectedDesignation);
        this.dispatchEvent(attributeChangeEvent);   
        //alert("currentDesignation2="+attributeChangeEvent.detail.value);
        this.hidenseek = "display:inline";
        alert('hidenseek = ' + this.hidenseek);
    }

    @api selectLabel;

    @api errorLabel;

    // END API VALUES


    // notice we don't declare this as a VAR - it is a property object both of the following will work but
    // but the IDE may complain that the first format needs () before the ;
    //editedPicklistValues;
    editedPicklistValues = [];

    refereeDesignations = [];
    
    error;

    caller_line;

    hidenseek = "display:none";

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: DESIGNATION_LIST })
    
    // @wire(getPLvals, { recordTypeId: '012000000000000AAA', fieldApiName: 'Contact.DESIGNATION_LIST__c' })
    // @wire(getPLvals, { recordTypeId: '012000000000000AAA', fieldApiName: this.FieldAPIName })

    wiredValues({ error, data }) {

        this.localLog("In wiredValues data=" + data + " error=" + error);

        if (data) {
            //alert("myObjectAPIName = " + this.myObjectAPIName);
            //alert("current Designation = " + this.getCurrentDesignation);
            this.localLog("We have data " + data);
            this.editedPicklistValues = this.buildSelectOptions(data.values);
            //this.locallog("populated editedPicklistValues " + this.editedPicklistValues, false);
            this.error = undefined;
        } else {
            this.localLog("received error: " + error);
            this.error = error;
        }
    }

    buildSelectOptions(picklistValues) {
        
        const listValues = []; 

        // test without current Designation
        //currDesignation = this.getCurrentDesignation ? this.getCurrentDesignation : 'test';
        listValues.push( {label: this.getCurrentDesignation, value: this.getCurrentDesignation} );
        this.selectedDesignation = this.getCurrentDesignation;

        Object.keys(picklistValues).forEach((index) => {
            // TODO: either replace or add variable - replace is best
            if(!picklistValues[index].label.includes("License Suspend")) {
                listValues.push( {label: picklistValues[index].label, value: picklistValues[index].value} );
            }

        });

        //return treeNodes;
        return listValues;
    }

    localLog(msg) {
        this.localLog(msg,false);
    }

    //  THIS IS A LITTLE FUNCTION TO HELP WITH LOGGING
    localLog(msg, alrt) {
        
        msg = 'plReference: ' + msg;
        if(alrt) {
            alert(msg);
        } else {
            console.log(msg);
        }
    }

}