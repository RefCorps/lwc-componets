/**
 * Lightning Web Component for RefCorp Flow Screens Community Page
 * This component incorporates a lightning datatable 
 * 
 * CREATED BY:          Mike Miller
 * 
 * RELEASE NOTES:       You must include LWC:  richDatatableRC
 * 
 * 2012-02-22   v0.1.0  Initial deployment for testing layouts.  Includes column sort and row search.
 * 2012-03-22   v0.1.1
 * 
**/

import { LightningElement, track } from 'lwc';

// NOTE:  For Apex imports, don't use curly braces, also you can designate a defaultExport name that's different from the module-name
import GearExchange from '@salesforce/apex/GearExchange.getGearBoxTableData';

/*
const columns = [
    { label: 'Category', fieldName: 'category',type: 'text' },
    { label: 'Item', fieldName: 'item',type: 'text' },
    { label: 'Description', fieldName: 'description', type: 'richtext', wrapText: true},
    { label: 'USRowing Logo', fieldName: 'usrowinglogo',type: 'boolean' },
    { label: 'Offered By', fieldName: 'offered_by', type: 'text', typeAttributes: { Offered_By__r: 'Name' } },
    { label: 'Status', fieldName: 'item_status', type: 'text'}
 ];
 */

// row actions
const actions = [
    { label: 'Record Details', name: 'record_details'},
];
/*
    { label: 'Edit', name: 'edit'}, 
    { label: 'Delete', name: 'delete'}
*/

 const rtcolumns = [
    { label: 'Category', fieldName: 'category',type: 'text', sortable: true, 
        cellAttributes: { class: 'slds-align-top'} },
    { label: 'Item', fieldName: 'item',type: 'text', sortable: true, cellAttributes: { class: 'slds-align-top'} },
    { label: 'Description', fieldName: 'description', type: 'richText', wrapText: true, cellAttributes: { class: 'slds-align-top'} },
    { label: 'USRowing Logo', fieldName: 'usrowinglogo',type: 'boolean', sortable: true, cellAttributes: { class: 'slds-align-top'} },
    { label: 'Offered By', fieldName: 'offered_by', type: 'text', sortable: true, cellAttributes: { class: 'slds-align-top'} },
    { label: 'Offered On', fieldName: 'offered_date', type: 'date', sortable: true, cellAttributes: { class: 'slds-align-top'} },
    { label: 'Status', fieldName: 'item_status', type: 'text', sortable: true, cellAttributes: { class: 'slds-align-top'} }, 
    { type: 'action', typeAttributes: { rowActions: actions,  menuAlignment: 'right' } }
 ];

 const selcolumns = [
    { label: 'Category', fieldName: 'category',type: 'text', sortable: true, cellAttributes: { class: 'slds-align-top'} },
    { label: 'Item', fieldName: 'item',type: 'text', sortable: true, cellAttributes: { class: 'slds-align-top'} },
    { label: 'Description', fieldName: 'description', type: 'richText', wrapText: true, cellAttributes: { class: 'slds-align-top'} },
    { label: 'USRowing Logo', fieldName: 'usrowinglogo',type: 'boolean', sortable: true, cellAttributes: { class: 'slds-align-top'} },
    { label: 'Offered By', fieldName: 'offered_by', type: 'text', sortable: true, cellAttributes: { class: 'slds-align-top'} },
    { label: 'Offered On', fieldName: 'offered_date', type: 'date', sortable: true, cellAttributes: { class: 'slds-align-top'} }
 ];
 

export default class TableGearExchange extends LightningElement {

    @track sortedBy;
    @track sortedDirection;

    @track data = [];
    @track localdata = [];
    //columns = columns;
    @track rtcolumns = rtcolumns;
 
    @track bShowModal = false;
    @track currentRecordId;
    @track isEditForm = false;

    @track selectedRecords = [];
    @track selectedShowModal = false;
//    @track currentRecordId;
//    @track isEditForm = false;
    @track selcolumns = selcolumns;

    /*
    objAPIName = 'Gear_Exchange__c';
    fieldCategory = 'Category__c';
    optionsCategory = [];
    */

    // IMAGES 
    // Base64 Photo Icon
    //photoimg = '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cz0iaHR0cDovL25zLnVzZXBsdXMub3JnL2xkZi94bXAvMS4wLyIKICAgIHhtbG5zOkdJTVA9Imh0dHA6Ly93d3cuZ2ltcC5vcmcveG1wLyIKICAgIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIKICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIgogICB4bXBNTTpEb2N1bWVudElEPSJnaW1wOmRvY2lkOmdpbXA6YTFlYmFmZGUtMzliNS00YWQ3LTkyZDItMmVhZTI2ZjI4Nzc1IgogICB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjFhMTdiMDMwLWU2NDctNGJiYy1iMmEzLTIwY2I1ZDhhZmU5OSIKICAgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjExYzNjZmViLTkxNGYtNGE1NC1hOWM4LTQyM2EzYjQ0YjBkZCIKICAgR0lNUDpBUEk9IjIuMCIKICAgR0lNUDpQbGF0Zm9ybT0iV2luZG93cyIKICAgR0lNUDpUaW1lU3RhbXA9IjE2MTY2MjIxMzU0MTAwMTUiCiAgIEdJTVA6VmVyc2lvbj0iMi4xMC4yMiIKICAgZGM6Rm9ybWF0PSJpbWFnZS9wbmciCiAgIHRpZmY6T3JpZW50YXRpb249IjEiCiAgIHhtcDpDcmVhdG9yVG9vbD0iR0lNUCAyLjEwIj4KICAgPGlwdGNFeHQ6TG9jYXRpb25DcmVhdGVkPgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6TG9jYXRpb25DcmVhdGVkPgogICA8aXB0Y0V4dDpMb2NhdGlvblNob3duPgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6TG9jYXRpb25TaG93bj4KICAgPGlwdGNFeHQ6QXJ0d29ya09yT2JqZWN0PgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6QXJ0d29ya09yT2JqZWN0PgogICA8aXB0Y0V4dDpSZWdpc3RyeUlkPgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6UmVnaXN0cnlJZD4KICAgPHhtcE1NOkhpc3Rvcnk+CiAgICA8cmRmOlNlcT4KICAgICA8cmRmOmxpCiAgICAgIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiCiAgICAgIHN0RXZ0OmNoYW5nZWQ9Ii8iCiAgICAgIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6MjFiNjgzNWItZTE2ZS00MTMzLWI0MzItYzg5YTQyNjg1YjAxIgogICAgICBzdEV2dDpzb2Z0d2FyZUFnZW50PSJHaW1wIDIuMTAgKFdpbmRvd3MpIgogICAgICBzdEV2dDp3aGVuPSIyMDIxLTAzLTI0VDE3OjQyOjE1Ii8+CiAgICA8L3JkZjpTZXE+CiAgIDwveG1wTU06SGlzdG9yeT4KICAgPHBsdXM6SW1hZ2VTdXBwbGllcj4KICAgIDxyZGY6U2VxLz4KICAgPC9wbHVzOkltYWdlU3VwcGxpZXI+CiAgIDxwbHVzOkltYWdlQ3JlYXRvcj4KICAgIDxyZGY6U2VxLz4KICAgPC9wbHVzOkltYWdlQ3JlYXRvcj4KICAgPHBsdXM6Q29weXJpZ2h0T3duZXI+CiAgICA8cmRmOlNlcS8+CiAgIDwvcGx1czpDb3B5cmlnaHRPd25lcj4KICAgPHBsdXM6TGljZW5zb3I+CiAgICA8cmRmOlNlcS8+CiAgIDwvcGx1czpMaWNlbnNvcj4KICA8L3JkZjpEZXNjcmlwdGlvbj4KIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAKPD94cGFja2V0IGVuZD0idyI/PobPVC0AAADAUExURQAAAAAAAFNnjlRqjVRpjVRpjVJrj1NojlRpjVRpjVVpjVVmkVRpjVRqjVBwj1RpjVRpjFNojVVqjlhsiVRpjVNpjVttklRpjVVqjU1mmU5iiVVnjFRojVRpjlVpjlJtiVRojVRpjVRpjVRpjFVpi1VpkFNpjVRpjVNpjkCAgFRpjlVmiFRqjYCAgFVVqlNpjlNrjlRqjVNpjVRpjVRpjWZmmVRpjVRpjVRojVVojVRpjVNojlRojVNmjFRpjVVojlKb3IIAAAABdFJOUwBA5thmAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB+UDGBUqD71plRMAAABySURBVEjH7ZVBCsAgDAQz//90j4JITAYpLbg3l4wE3MSIq6NikmEqFAjKQNCnoE9BmyJVq3gNg6BOQWnrhdxUoUqAM29bMLzkuIZKxmQtb4k9RN7vhT4C9R9XxcgF1o0GIYZQjrtbLC/uvd9D6qu50noArWUF9oehn48AAAAASUVORK5CYII=';
    photo = '<img src=\'data:image/png;base64,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cz0iaHR0cDovL25zLnVzZXBsdXMub3JnL2xkZi94bXAvMS4wLyIKICAgIHhtbG5zOkdJTVA9Imh0dHA6Ly93d3cuZ2ltcC5vcmcveG1wLyIKICAgIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIKICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIgogICB4bXBNTTpEb2N1bWVudElEPSJnaW1wOmRvY2lkOmdpbXA6YTFlYmFmZGUtMzliNS00YWQ3LTkyZDItMmVhZTI2ZjI4Nzc1IgogICB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjFhMTdiMDMwLWU2NDctNGJiYy1iMmEzLTIwY2I1ZDhhZmU5OSIKICAgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjExYzNjZmViLTkxNGYtNGE1NC1hOWM4LTQyM2EzYjQ0YjBkZCIKICAgR0lNUDpBUEk9IjIuMCIKICAgR0lNUDpQbGF0Zm9ybT0iV2luZG93cyIKICAgR0lNUDpUaW1lU3RhbXA9IjE2MTY2MjIxMzU0MTAwMTUiCiAgIEdJTVA6VmVyc2lvbj0iMi4xMC4yMiIKICAgZGM6Rm9ybWF0PSJpbWFnZS9wbmciCiAgIHRpZmY6T3JpZW50YXRpb249IjEiCiAgIHhtcDpDcmVhdG9yVG9vbD0iR0lNUCAyLjEwIj4KICAgPGlwdGNFeHQ6TG9jYXRpb25DcmVhdGVkPgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6TG9jYXRpb25DcmVhdGVkPgogICA8aXB0Y0V4dDpMb2NhdGlvblNob3duPgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6TG9jYXRpb25TaG93bj4KICAgPGlwdGNFeHQ6QXJ0d29ya09yT2JqZWN0PgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6QXJ0d29ya09yT2JqZWN0PgogICA8aXB0Y0V4dDpSZWdpc3RyeUlkPgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6UmVnaXN0cnlJZD4KICAgPHhtcE1NOkhpc3Rvcnk+CiAgICA8cmRmOlNlcT4KICAgICA8cmRmOmxpCiAgICAgIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiCiAgICAgIHN0RXZ0OmNoYW5nZWQ9Ii8iCiAgICAgIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6MjFiNjgzNWItZTE2ZS00MTMzLWI0MzItYzg5YTQyNjg1YjAxIgogICAgICBzdEV2dDpzb2Z0d2FyZUFnZW50PSJHaW1wIDIuMTAgKFdpbmRvd3MpIgogICAgICBzdEV2dDp3aGVuPSIyMDIxLTAzLTI0VDE3OjQyOjE1Ii8+CiAgICA8L3JkZjpTZXE+CiAgIDwveG1wTU06SGlzdG9yeT4KICAgPHBsdXM6SW1hZ2VTdXBwbGllcj4KICAgIDxyZGY6U2VxLz4KICAgPC9wbHVzOkltYWdlU3VwcGxpZXI+CiAgIDxwbHVzOkltYWdlQ3JlYXRvcj4KICAgIDxyZGY6U2VxLz4KICAgPC9wbHVzOkltYWdlQ3JlYXRvcj4KICAgPHBsdXM6Q29weXJpZ2h0T3duZXI+CiAgICA8cmRmOlNlcS8+CiAgIDwvcGx1czpDb3B5cmlnaHRPd25lcj4KICAgPHBsdXM6TGljZW5zb3I+CiAgICA8cmRmOlNlcS8+CiAgIDwvcGx1czpMaWNlbnNvcj4KICA8L3JkZjpEZXNjcmlwdGlvbj4KIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAKPD94cGFja2V0IGVuZD0idyI/PobPVC0AAADAUExURQAAAAAAAFNnjlRqjVRpjVRpjVJrj1NojlRpjVRpjVVpjVVmkVRpjVRqjVBwj1RpjVRpjFNojVVqjlhsiVRpjVNpjVttklRpjVVqjU1mmU5iiVVnjFRojVRpjlVpjlJtiVRojVRpjVRpjVRpjFVpi1VpkFNpjVRpjVNpjkCAgFRpjlVmiFRqjYCAgFVVqlNpjlNrjlRqjVNpjVRpjVRpjWZmmVRpjVRpjVRojVVojVRpjVNojlRojVNmjFRpjVVojlKb3IIAAAABdFJOUwBA5thmAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB+UDGBUqD71plRMAAABySURBVEjH7ZVBCsAgDAQz//90j4JITAYpLbg3l4wE3MSIq6NikmEqFAjKQNCnoE9BmyJVq3gNg6BOQWnrhdxUoUqAM29bMLzkuIZKxmQtb4k9RN7vhT4C9R9XxcgF1o0GIYZQjrtbLC/uvd9D6qu50noArWUF9oehn48AAAAASUVORK5CYII=\' alt=\'Photo\' width=\'15\'  />';
    descriptionPhotos = new Map();

    availableItems;

    enableLogging = true;

    async connectedCallback() {

        GearExchange({
            listytpe: 1
        })
        .then(result => { 
           
            this.data = result;

            this.removeImage(result);            
           
            this.localdata = this.data;
            this.availableItems = this.localdata.length;
            //this.logmessage('GearExchange: ' + JSON.stringify(this.data));
            
        }).catch(error => {
            alert('gear load  error:  ' + JSON.stringify(error));
        });

        /* EVALUATION
        // Category
        PicklistValues({
            pObjAPIName: this.objAPIName,
            pFieldAPIName: this.fieldCategory
        })
        .then(result => {
            this.logmessage('category picklist = ' + JSON.stringify(result));
            this.optionsCategory = this.buildSelectOptions(result);
            //this.logmessage('options = ' + JSON.stringify(this.options));
            this.error = '';
        }).catch(error => {
            console.error("received error: " + JSON.stringify(error));
            this.flowErrorMsg = "Unable to load component.  Received error: " + JSON.stringify(error);
            this.error = error;
        });
        */

    }

    /* removed see PicklistValues above
    buildSelectOptions(picklistValues) {

        const listValues = [];

        //listValues.push( {label: '-- SELECT --', value: '' } );
        Object.keys(picklistValues).forEach((index) => {
            listValues.push( {label: picklistValues[index], value: picklistValues[index]} );
        });

        return listValues;
    }
    */

    handleSave(event) {
        this.updatedRows = event.detail.draftValues;
        this.logmessage( JSON.stringify(this.updatedRows));
    }

    // -------------------------------------------------------------------------------------

    handleRowActions(event) {
        let actionName = event.detail.action.name;

       this.logmessage('actionName ====> ' + actionName);

        let row = event.detail.row;

        this.logmessage('row ====> ' + row);
        // eslint-disable-next-line default-case
        switch (actionName) {
            case 'record_details':
                // alert('tableGearExchange - record details row ' + JSON.stringify(row));
                this.viewCurrentRecord(row);
                break;
            /*     
            case 'edit':
                this.editCurrentRecord(row);
                break;
            case 'delete':
                this.deleteCons(row);
                break;
            */    
        }
    }

    viewCurrentRecord(currentRow) {
        this.bShowModal = true;
        this.isEditForm = false;
        this.record = currentRow;

        this.logmessage("display id="+ this.record.id);
        var imgrec = this.descriptionPhotos.get(this.record.id);
        if(imgrec) {
        this.logmessage(imgrec);
        //var rec = JSON.stringify(this.record);
        //this.logmessage(rec);
        //rec = rec.replace(this.photo, img);
        //this.logmessage(rec);
        this.record = JSON.parse(imgrec);
        } 

    }

    // closing modal box
    closeModal() {
        this.bShowModal = false;
    }

    // -------------------------------------------------------------------------------------
    // BEGIN SEARCH - THIS CURRENTLY ONLY SEARCH DATA LOADED FROM THE SERVER

    searchKey = '';

    get getClearSelectionButtonClass() {
        return (
            'slds-button slds-button_icon slds-input__icon slds-input__icon_right ' +
            (this.hasSelection() ? '' : 'slds-hide')
        );
    }

    /*
    reloadOnClear() {
        this.elemSearchClear = this.template.querySelector('slds-input__icon slds-input__icon_right slds-button slds-button_icon');
        this.elemSearchClear.onclick = this.tryAgain;
    }

    tryAgain() {
        alert('It worked');
    }
    */ 

    handleOnSearchChange(event) {
        this.searchKey = event.target.value;
        //alert('handleOnSearchChange searchTable follows');
        this.searchTable();
    }

    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            this.searchKey = event.target.value;
            //alert('handleKeyUp searchTable follows');
            this.searchTable();
        }
    }

    handleSearchChange(event) {
        var searchStringLen = event.target.value;
        if(searchStringLen == 0) {
            //alert('handleSearchChange reload data');
            this.data = this.localdata;
        }
    }

    handleClearIhope(event) {
  
        this.logmessage('>> handleClearIhope ' + event.target );
        this.logmessage('>> handleClearIhope ' + event.button );
        
    }

    searchTable() {
        // var len = this.data.length;
        var len = this.localdata.length;
        alert('Search for : ' + this.searchKey + ' across ' + len + ' rows');
        this.data = [];
        for(var i = 0; i < len ; i++) {
            if( JSON.stringify(this.localdata[i]).includes(this.searchKey)) {
                this.data.push(this.localdata[i]);
            }
        }
    }


    // END SEARCH 
    // -------------------------------------------------------------------------------------
    // BEGIN SORT - THIS WILL TAKE THE TABLE DATA TO JSON AND PERFORM A JSON SORT AND FINALLY RETURN THE DATA TO THE TABLE
    updateColumnSorting(event) {
       
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;

        alert('Sort by ' + event.detail.fieldName + ' direction=' + event.detail.sortDirection + '?');

        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        //this.data = this.sortData(fieldName, sortDirection);
        this.sortData(fieldName, sortDirection);
   }

   sortData(fieldName, sortDirection) {
    const desc = -1;
    const asc = 1;
       /*
       let sortResult = Object.assign([], this.data);
       
       this.data = sortResult.sort(function (a, b) {
           if (a[fieldName] < b[fieldName])
               return sortDirection === 'asc' ? desc : asc;
           else if (a[fieldName] > b[fieldName])
               return sortDirection === 'asc' ? asc : desc;
           else
               return 0;
       })
       */
      let parseData = JSON.parse(JSON.stringify(this.data));
      // Return the value stored in the field
      let keyValue = (a) => {
          return a[fieldName];
      };
      this.logmessage('keyValue = ' + keyValue);
      // cheking reverse direction
      let isReverse = sortDirection === 'asc' ? asc : desc;
      // sorting data
      parseData.sort((x, y) => {
          x = keyValue(x) ? keyValue(x) : ''; // handling null values
          y = keyValue(y) ? keyValue(y) : '';
          // sorting values based on direction
          return isReverse * ((x > y) - (y > x));
      });
      
      this.logmessage('Sorted GearExchange: ' + JSON.stringify(parseData));
      this.data = parseData;
   }
   // END SORT 
   // -------------------------------------------------------------------------------------
   // BEGIN PROECESS SELECTED ROWS

   requestItems() {
        
        //alert('In requestItems');

        this.selectedRecords = this.template.querySelector("c-rich-datatable-r-c").getSelectedRows();  
        //this.logmessage( JSON.stringify(selectedRecords) ); 

        var cntSelectedRecords = this.selectedRecords.length;
        this.logmessage('Records selected = ' + cntSelectedRecords);

        if(cntSelectedRecords == 0) {
            alert('No rows were selected, please try again.');
            return;
        }

        //for(var i = 0; i < cntSelectedRecords ; i++) {
        //    this.logmessage( JSON.stringify(selectedRecords[i]) ); 
        //}

        this.viewSelectedRecords();

    }
        viewSelectedRecords() {
            this.selectedShowModal = true;
            this.isEditForm = false;
            this.record = this.selectedRecords;
        }
    
        // closing modal box
        closeSelectRecordsModal() {
            this.selectedShowModal = false;
        }

   // END PROECESS SELECTED ROWS
   // -------------------------------------------------------------------------------------
   // BEGIN IMAGES

   removeImage(gdata) {
    var len = gdata.length;
    
    for(var i = 0; i < len ; i++) {
        if( JSON.stringify(gdata[i]).includes('<img')) {
          var val = JSON.stringify(gdata[i]);
          this.logmessage(val);
          var iBeg = '<img';
          var iEnd = '</img>';
          var keyString = gdata[i].id;
          //var imgString = this.getSubStringValue(val, iBeg, iEnd);
          this.descriptionPhotos.set(keyString, val );
          //this.photo = '<img src=\'data:image/png;base64,' + this.photoimg +  ' alt=\'Photo\' width=\'15\'  />';

          var mod = this.modifyStringValue(val,iBeg,iEnd,this.photo);
          this.logmessage('mod = '  + mod);
          gdata[i] = JSON.parse(mod);
 
        }
    }
    return gdata;
   }
   

   modifyStringValue(str, beg, end, replacewith) {
        var rtr = str;
        if(str.toLowerCase().includes(beg.toLowerCase())) {
           var bpos = str.toLowerCase().indexOf(beg);
           var epos = str.toLowerCase().indexOf(end) + end.length;
           var substr = str.slice(bpos,epos);
           this.logmessage(substr);
           rtr = str.replace(substr,replacewith);
        } 
        return rtr;
   }

   getSubStringValue(str, beg, end) {
    var rtr = str;
    if(str.toLowerCase().includes(beg.toLowerCase())) {
       var bpos = str.toLowerCase().indexOf(beg);
       var epos = str.toLowerCase().indexOf(end) + end.length;
       var substr = str.slice(bpos,epos);
       //this.logmessage(substr);
       rtr = substr;
    } 
    return rtr;
   }

   // END IMAGES
   // -------------------------------------------------------------------------------------

   logmessage(message) {
    if (this.enableLogging) {
        console.log('tableGearExchange v0.1.1: ' + message);
    }
}


}