/**
 * Lightning Web Component for RefCorp Flow Screens used to update Status
 * This component incorporates a lightning radio group and pulls data from Contact.Referee_Status__c.
 * 
 * CREATED BY:          Mike Miller
 * 
 * VERSION:             0.1.0
 * 
 * RELEASE NOTES:       You must get current data from Contact to set current Status as first option listed.
 * 
**/import { api, LightningElement, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import REFEREE_STATUS from '@salesforce/schema/Contact.Referee_Status__c';
import {FlowAttributeChangeEvent } from 'tableEditDesignations/node_modules/lightning/flowSupport';

export default class ckbRefereeStatus extends LightningElement {

    @api currentStatus;

    get getCurrentStatus() {
        return this.currentStatus;
    }

    @api selectedStatus;
    @api excludeStatuses;
    @api checkboxLabel;

    @api errorLabel;    // used to loop back an display an error

    editedPicklistValues = [];
    value;
    error;
    checkboxGroupLabel;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: REFEREE_STATUS })
 
    wiredValues({ error, data }) {

        this.selectedStatus = this.currentStatus;

        // test test test uncomment to preview component locally 
        // this.excludeStatuses = this.excludeStatuses ? this.excludeStatuses : 'License Suspended,License Suspended - Safety Compliance,License Suspended - USRowing Admin';

        // console.log("In wiredValues " + data);
        if (data) {
            this.editedPicklistValues = this.buildSelectOptions(data.values);
            this.error = undefined;
        } else {
            this.error = error;
            this.treeModel = undefined;
        }
        this.checkboxGroupLabel = this.checkboxLabel ? this.checkboxLabel : 'Referee Status';

    }

    buildSelectOptions(picklistValues) {

        const listValues = []; 
        Object.keys(picklistValues).forEach((index) => {

            console.log(picklistValues[index]);
            
            if(!this.excludeStatuses.includes( picklistValues[index] )) {
                listValues.push( {label: picklistValues[index], value: picklistValues[index]} );
            }

        });
        
        this.value = this.currentStatus;
        return listValues;
    }

    handleChange(event) {
        this.selectedStatus = event.target.value; 
        const attributeChangeEvent = new FlowAttributeChangeEvent('ckboxGroup', this.selectedStatus);
        this.dispatchEvent(attributeChangeEvent);   
        // console.log("currentStatus1="+this.currentStatus);
    }


}