/**
 * Lightning Web Component for RefCorp Flow Screens 
 * This component incorporates a lightning radio group and pulls data from Contact.Referee_Status__c.
 * 
 * CREATED BY:          Mike Miller
 * 
 * VERSION:             0.1.0
 * 
 * RELEASE NOTES:       You must get current data from Contact to set current Status as first option listed.
 * 
**/

import { api, LightningElement, wire } from 'lwc';
import PicklistValues from '@salesforce/apex/PicklistCompController.getPickListValues';

export default class PicklistComp extends LightningElement {

    @api objAPIName;
    @api fieldAPIName;
    @api listLabel;
    
    @api listHelp;
    @api placeHolder;
    @api flowErrorMsg;

    @api currentValue;
    @api selectedValue;
    @api excludedValues;
    @api useRadioButton;

    options = [];
    value;

    async connectedCallback() {

        // BEGIN LOCAL TEST 
        //this.objAPIName = this.objAPIName ? this.objAPIName : 'Designation__c';
        //this.objAPIField = this.objAPIField ? this.objAPIField : 'Designation__c';
        //this.listLabel = this.listLabel ? this.listLabel : 'Picklist Selections';

        //this.placeHolder = this.placeHolder ? this.placeHolder : '--Select an Option--';
        //this.currentValue = this.currentValue ? this.currentValue : 'Current Value';
        //this.flowErrorMsg = this.flowErrorMsg ? this.flowErrorMsg : 'Test flow error msg';
        // END LOCAL TEST

        console.log('obj: ' + this.objAPIName + ' field: ' + this.fieldAPIName);

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
            this.error = error;
        });

    }

    buildSelectOptions(picklistValues) {

        const listValues = [];
        this.excludedValues = this.excludedValues ? this.excludedValues : '';

        if (!this.useRadioButton) {
            if (this.currentValue) {
                listValues.push({
                    label: this.currentValue,
                    value: this.currentValue
                });
            } else if (this.placeHolder) {
                listValues.push({
                    label: this.placeHolder,
                    value: ''
                });
            }
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
        console.log("selectedValue = "+this.selectedValue);
    }


}