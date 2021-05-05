/*
    plRefereeStatus
    This is the JS element of the LWC (Lightning Web Component) bundle 'plRefereeStatus'
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
import { getPicklistValues as getPLvals } from 'lightning/uiObjectInfoApi';
import { FlowAttributeChangeEvent } from 'plRefereeRank/node_modules/lightning/flowSupport';

// The following imports a default export (whether it is an object, a function, a class, etc.) (Importing defaults)
import REFEREE_STATUS from '@salesforce/schema/Contact.Referee_Status__c';

/*
    plRefereeStatus is a class
        'export' keyword labels variables and functions that should be accessible from outside the current module.
        'default' declares the class as a single entity, i.e., a single thing encapsulated by the class 
        'extends' means it inherits methods and properties from 'LightningElement'
        
*/
export default class plRefereeStatus extends LightningElement {


    // BEGIN API VALUES
    // The following values are defined in plRefereeStatus.js-meta.xml
    
    @api currentStatus;
    @api defaultStatus;

    get getCurrentStatus() {
        this.currentStatus = this.currentStatus ? this.currentStatus : this.defaultStatus;
        this.localLog('getCurrentStatus returning ' + this.currentStatus);
        return this.currentStatus;
    }

    @api selectedStatus;

    handleChange(event) {

        //this.currentStatus = event.target.value;
        this.selectedStatus = event.target.value; 
        // alert("currentStatus1="+this.currentStatus);
        // const attributeChangeEvent = new FlowAttributeChangeEvent('ckboxGroup', this.currentStatus);
        const attributeChangeEvent = new FlowAttributeChangeEvent('select', this.selectedStatus);
        this.dispatchEvent(attributeChangeEvent);   
        //alert("currentStatus2="+attributeChangeEvent.detail.value);

    }

    @api selectLabel;

    @api errorLabel;

    // END API VALUES


    // notice we don't declare this as a VAR - it is a property object both of the following will work but
    // but the IDE may complain that the first format needs () before the ;
    //editedPicklistValues;
    editedPicklistValues = [];

    error;

    caller_line;


    // @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: REFEREE_STATUS })
    @wire(getPLvals, { recordTypeId: '012000000000000AAA', fieldApiName: REFEREE_STATUS })
    // @wire(getPLvals, { recordTypeId: '012000000000000AAA', fieldApiName: 'Contact.Referee_Status__c' })
    // @wire(getPLvals, { recordTypeId: '012000000000000AAA', fieldApiName: this.FieldAPIName })

    wiredValues({ error, data }) {

        this.localLog("In wiredValues data=" + data + " error=" + error);

        if (data) {
            //alert("myObjectAPIName = " + this.myObjectAPIName);
            //alert("current status = " + this.getCurrentStatus);
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

        // test without current status
        //currStatus = this.getCurrentStatus ? this.getCurrentStatus : 'test';
        listValues.push( {label: this.getCurrentStatus, value: this.getCurrentStatus} );
        this.selectedStatus = this.getCurrentStatus;

        Object.keys(picklistValues).forEach((index) => {
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