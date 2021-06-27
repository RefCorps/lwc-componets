import {
    api,
    LightningElement,
} from 'lwc';

import ContactHistory from '@salesforce/apex/ContactHistoryController.getContactHistoryRecords'

const columns = [
    {label: 'ContactName', fieldName: 'ContactName' },
    {label: 'CreatedByName', fieldName: 'CreatedByName' },
    {label: 'CreatedDate', fieldName: 'CreatedDate', type: 'datetime-local'},
    {label: 'Field', fieldName: 'Field'},
    {label: 'NewValue', fieldName: 'NewValue'},
    {label: 'OldValue', fieldName: 'OldValue'}
]


export default class TableContactHistory extends LightningElement {

    @api contactId;
    @api fieldName;

    data;
    columns = columns;

    pContactId;
    pFieldName;

    async connectedCallback() {

        this.pContactId = this.contactId ? this.contactId : '0036A00000peZGwQAM';
        this.pFieldName = this.fieldName ? this.fieldName : 'Referee_Status__c';

        ContactHistory({
            pContactId: this.pContactId,
            pFieldName: this.pFieldName
        })
        .then(result => {
            this.data = result;
            console.log('History results:  ' + JSON.stringify(result));
         }).catch(error => {
            alert('TableContactHistory error:  ' + error);
        });


    }



}