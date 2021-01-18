import { api, LightningElement, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import REFEREE_STATUS from '@salesforce/schema/Contact.Referee_Status__c';

export default class plRefereeStatus extends LightningElement {

    @api currentStatus;

    get getCurrentStatus() {
        return this.currentStatus;
    }

    editedPicklistValues;
    error;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: REFEREE_STATUS })

    wiredValues({ error, data }) {
        //alert("In wiredValues " + data);
        if (data) {
            //alert("current status = " + this.getCurrentStatus);
            //alert("We have data " + data);
            this.editedPicklistValues = this.buildTreeModel(data.values);
            //alert("populated editedPicklistValues " + this.editedPicklistValues);
            this.error = undefined;
        } else {
            this.error = error;
            this.treeModel = undefined;
        }
    }

    buildTreeModel(picklistValues) {
        //alert("In buildTreeModel " + picklistValues);
        const listValues = []; 

        listValues.push( {label: this.getCurrentStatus, value: this.getCurrentStatus} );

        Object.keys(picklistValues).forEach((index) => {
            if(!picklistValues[index].label.includes("License Suspend")) {
                listValues.push( {label: picklistValues[index].label, value: picklistValues[index].value} );
            }

        });
        //return treeNodes;
        return listValues;
    }


}