import { LightningElement, api, track } from 'lwc';

export default class PicklistCompCPE extends LightningElement {

    @track _inputVariables = [];

    @track _objAPIName;
    @track _fieldAPIName;
    @track _listLabel;
 
    @api get inputVariables() {
        return this._inputVariables;
    }

    set inputVariables(variables) {
        this._inputVariables = variables || [];

        const objAPINameValue = this._inputVariables.find(({ id }) => id === 'objAPIName');
        this._objAPIName = objAPINameValue && objAPINameValue.value;
    
        const fieldAPINameValue = this._inputVariables.find(({ id }) => id === 'fieldAPIName');
        this._fieldAPIName = fieldAPINameValue && fieldAPINameValue.value;

        const listLabelValue = this._inputVariables.find(({ id }) => id === 'listLabel');
        this._listLabel = listLabelValue && listLabelValue.value;

    }
  
    @api get objAPIName() {
       
        const param = this.inputVariables.find(({name}) => name === 'objAPIName');
        return param && param.value;
    }

    set objAPIName(objAPIName) {
        this._objAPIName;
    }

    
    @api get fieldAPIName() {
        const param = this.inputVariables.find(({name}) => name === 'fieldAPIName');
        return param && param.value;
    }

    set fieldAPIName(fieldAPIName) {
        this._fieldAPIName;
    }

    @api get listLabel() {
        const param = this.inputVariables.find(({name}) => name === 'listLabel');
        return param && param.value;
    }



    @api
    validate() {
        //const volumeCmp = this.template.querySelector('lightning-slider');
        const validity = [];
  
        return validity;
    }


    handleChange(event) {
        if (event && event.detail) {

            console.log("I saw a change " + event);
            //
            const newValue = event.detail.value;
            const valueChangedEvent = new CustomEvent(
                'configuration_editor_input_value_changed', {
                     bubbles: true,
                     cancelable: false,
                     composed: true,
                     detail: {
                         name: 'objAPIName',
                         newValue,
                         newValueDataType: 'String'
                     }
                }
            );
            this.dispatchEvent(valueChangedEvent);
            //
        }
    }
 
}