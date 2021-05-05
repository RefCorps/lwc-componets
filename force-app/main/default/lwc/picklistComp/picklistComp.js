/**
 * Lightning Web Component for RefCorp Flow Screens 
 * Designed to be used in Screen Flows, this component incorporates either a lightning radio group or a select list based upon properties
 * 
 * CREATED BY:      Mike Miller
 * 
 * RELEASE NOTES:   1.  Designed to be used in Screen Flows in place of Radio Buttons and Picklist primarily with updates
 *                  2.  Requires Apex Controller PicklistCompController.cls (test with PicklistCompTest.cls)
 *                  3.  You must get current data from your Object to set currentValue as first option listed.
 *                  4.   The order of the picklist is controlled by the order of the values found in the Object Fields’s values.  Use ‘Reorder’ to change order.
 *                  5.  Include a decision in your flow to test 'currentValue' against 'selectedValue' to determine if data value changed
 * 
 * 2012-02-22 - v0.1.1 - If options to be excluded are set the excluded will appear and no options can be selected.  
 *                       Commented out logic associated with local testing.
 * 2012-02-26 - v0.1.2 - Add label hint option - fixed label style
 * 2012-03-01 - v0.1.3 - Code cleanup - Modified to better support testing
 * 
 * 2012-23-01 - v1.1.4 - Code cleanup for deployment to production
**/

import { api, LightningElement, wire } from 'lwc';
import PicklistValues from '@salesforce/apex/PicklistCompController.getPickListValues';

export default class PicklistComp extends LightningElement {

    version = 'v1.1.4';

    @api objAPIName;
    @api fieldAPIName;
    @api listLabel;
    @api listHint;
    @api listHelp;
    // @api placeHolder;  // DEPRECATED
    @api selectHint;
    @api flowErrorMsg;

    @api currentValue;
    @api selectedValue;
    @api excludedValues;
    @api useRadioButton;

    options = [];
    value;

    valueCanBeUpdated = true;

    useTestData = false; // Provides default test data to facilitate local testing in VSCode
    enableLogging = true; // When true console logging through logmessage is enabled

    async connectedCallback() {

        // BEGIN LOCAL TEST 

        if (this.useTestData) {

            this.logmessage('Default test data is enabled.  Defaults will be used when there is no corresponding parameter');

            //this.objAPIName = this.objAPIName ? this.objAPIName : 'Designation__c';
            //this.fieldAPIName = this.fieldAPIName ? this.fieldAPIName : 'Designation__c';
            this.objAPIName = this.objAPIName ? this.objAPIName : 'Contact';
            this.fieldAPIName = this.fieldAPIName ? this.fieldAPIName : 'Referee_Status__c';

            // for status test
            this.excludedValues = this.excludedValues ? this.excludedValues : 'License Suspended,License Suspended - Safety Compliance,License Suspended - USRowing Admin';

            this.placeHolder = this.placeHolder ? this.placeHolder : '--Select an Option--';
            this.currentValue = this.currentValue ? this.currentValue : 'Active';
            this.currentValue = this.currentValue ? this.currentValue : 'License Suspended';
            this.flowErrorMsg = this.flowErrorMsg ? this.flowErrorMsg : 'Status change prohibited';

        } else {
            this.listLabel = this.listLabel ? this.listLabel : 'Current Status';
            this.listHint = this.listHint ? this.listHint : '(select from this list to update)';
        }
        // END LOCAL TEST

        this.logmessage('obj: ' + this.objAPIName + ' field: ' + this.fieldAPIName);

        // If you don't select anything the current value will become the selected value;
        this.selectedValue = this.currentValue;

        PicklistValues({
            pObjAPIName: this.objAPIName, 
            pFieldAPIName: this.fieldAPIName
        })
        .then(result => {

            this.options = this.buildSelectOptions(result);
            this.error = '';

        }).catch(error => {
            console.error("received error: " + error);
            this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
            this.error = error;
        });

    }

    buildSelectOptions(picklistValues) {

        const listValues = [];
        this.excludedValues = this.excludedValues ? this.excludedValues : '';

        if(this.excludedValues.includes( this.currentValue )) {
            this.valueCanBeUpdated = false;
            this.flowErrorMsg = "Change prohibited.  Current selection: " + this.currentValue ;
        }

        if (!this.useRadioButton) {
            if (this.currentValue) {
                listValues.push({
                    label: this.currentValue,
                    value: this.currentValue
                });
            } 
            /*
            else if (this.placeHolder) {
                listValues.push({
                    label: this.placeHolder,
                    value: ''
                });
            }
            */
        }
        if (this.useRadioButton) {
            if (this.currentValue)
                this.value = this.currentValue;
        }

        Object.keys(picklistValues).forEach((index) => {

            if(!this.excludedValues.includes( picklistValues[index] )) {
                listValues.push( {label: picklistValues[index], value: picklistValues[index]} );
            }

        });

        return listValues;
    }

    handleChange(event) {
        this.selectedValue = event.target.value; 
        this.logmessage("selectedValue = "+this.selectedValue);
    }

    logmessage(message) {
        if (this.enableLogging) {
            console.log('picklistComp ' + this.version + ': ' + message);
        }
    }

}