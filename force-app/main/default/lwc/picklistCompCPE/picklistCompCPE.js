import { LightningElement, api, track } from 'lwc';
import findObjects from '@salesforce/apex/PicklistCompController.getObjectAPINames';
import fetchFields from '@salesforce/apex/PicklistCompController.getObjectPicklistFields';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 350;

export default class PicklistCompCPE extends LightningElement {

    @track _inputVariables = [];

    @track _objAPIName;
    @track _fieldAPIName;
    @track _listLabel;
    @track _listHelp;
    @track _placeHolder;
    @track _currentValue;
    @track _selectedValue;
    @track _excludedValues;
    @track _useRadioButton;

 
    @api get inputVariables() {
        return this._inputVariables;
    }

    set inputVariables(variables) {

        this._inputVariables = variables || [];
        
        console.log("set _inputVariables " + JSON.stringify(this._inputVariables));

        const objAPINameValue = this._inputVariables.find(({ name }) => name === 'objAPIName');
        this._objAPIName = objAPINameValue && objAPINameValue.value;

        const fieldAPINameValue = this._inputVariables.find(({ name }) => name === 'fieldAPIName');
        this._fieldAPIName = fieldAPINameValue && fieldAPINameValue.value;

        if(this._fieldAPIName)
            this.completeSetup = true;

        const listLabelValue = this._inputVariables.find(({ name }) => name === 'listLabel');
        this._listLabel = listLabelValue && listLabelValue.value;
        
        const listHelpValue = this._inputVariables.find(({ name }) => name === 'listHelp');
        this._listHelp = listHelpValue && listHelpValue.value;

        const placeHolderValue = this._inputVariables.find(({ name }) => name === 'placeHolder');
        this._placeHolder = placeHolderValue && placeHolderValue.value;

        const currentValueValue =this._inputVariables.find(({ name }) => name === 'currentValue');
        this._currentValue = currentValueValue && currentValueValue.value;

        const selectedValueValue = this._inputVariables.find(({ name }) => name === 'selectedValue');
        this._selectedValue = selectedValueValue && selectedValueValue.value;

        const excludedValuesValue = this._inputVariables.find(({ name }) => name === 'excludedValue');
        this._excludedValues = excludedValuesValue && excludedValuesValue.value;

        const useRadioButtonValue = this._inputVariables.find(({ name }) => name === 'useRadioButton');  
        this._useRadioButton = useRadioButtonValue && useRadioButtonValue.value;


    }
  
    //@api
    get objAPIName() {
        console.log("get objAPIName");
        const param = this._inputVariables.find(({name}) => name === 'objAPIName');
        return param && param.value;
    }

    set objAPIName(objAPIName) {
        console.log("set objAPIName " + objAPIName);
        this._objAPIName = objAPIName;
    }

    
    //@api 
    get fieldAPIName() {
       
        const param = this._inputVariables.find(({name}) => name === 'fieldAPIName');
        return param && param.value;
    }

    set fieldAPIName(fieldAPIName) {
        console.log("set fieldAPIName " + fieldAPIName);
        this._fieldAPIName = fieldAPIName;
    }

    //@api 
    get listLabel() {
        const param = this._inputVariables.find(({name}) => name === 'listLabel');
        return param && param.value;
    }

    @api
    validate() {
        //const volumeCmp = this.template.querySelector('lightning-slider');
        const validity = [];
  
        return validity;
    }
    
    selectedObjects = [];
    selectedFields = [];
    error;

    handleChange(event) {
        if (event && event.detail) {

            console.log("I saw a change to objAPIName: " + event.detail.key + "  value: " + event.detail.value);

            if(event.detail.value > 0) {

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
            } else {
                
                this._objAPIName = undefined;
                this.displayCombo = false;
                console.log('objAPIName set to undefined - displayCombo = false');
                this.selectedFields = [];
                this._fieldAPIName = undefined;

            }
            
           
            //
        }
    }
 
    handleChange2(event) {
        if (event && event.detail) {

            console.log("I saw field change " + event.detail.value);
            //
            const newValue = event.detail.value;
            const valueChangedEvent = new CustomEvent(
                'configuration_editor_input_value_changed', {
                     bubbles: true,
                     cancelable: false,
                     composed: true,
                     detail: {
                         name: 'fieldAPIName',
                         newValue,
                         newValueDataType: 'String'
                     }
                }
            );
            this.dispatchEvent(valueChangedEvent);
            this.completeSetup = true;
            //
        }
    }

    handleChange3(event) {
        if (event && event.detail) {
            const newValue = event.detail.value;
            const targetName = event.target.name;
            const valueChangedEvent = new CustomEvent(
                'configuration_editor_input_value_changed', {
                     bubbles: true,
                     cancelable: false,
                     composed: true,
                     detail: {
                         name: targetName,
                         newValue,
                         newValueDataType: 'String'
                     }
                }
            );
            this.dispatchEvent(valueChangedEvent);
        }
    }

    handleToggle(event) {
        if (event && event.detail) {
            const newValue = event.detail.value;
            const targetName = event.target.name;
            const valueChangedEvent = new CustomEvent(
                'configuration_editor_input_value_changed', {
                     bubbles: true,
                     cancelable: false,
                     composed: true,
                     detail: {
                         name: targetName,
                         newValue,
                         newValueDataType: 'Boolean'
                     }
                }
            );
            this.dispatchEvent(valueChangedEvent);
        }
    }


    displayCombo = false;
    completeSetup = false;

    handleSelectedObj(event) {

        const obj = event.target.value;
        this._objAPIName = obj;
        this.displayCombo = false;

        this.selectedFields = [];
        fetchFields({ pObjAPIName: this._objAPIName })
        .then((result) => {
            this.selectedFields = this.buildSelectOptions(result);
            this.error = undefined;
            console.log('selectedFields1 ' + JSON.stringify(this.selectedFields));            
            this.displayCombo = true;
        })
        .catch((error) => {
            console.error('error: ' + error);
            this.error = error;
            this.selectedFields = undefined;
        });
        console.log('selectedFields2 ' + JSON.stringify(this.selectedFields));

    }

    handleKeyChange(event) {

        //window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        console.log('searchKey ' + searchKey);
        if(searchKey.length < 3)
            return;

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.selectedObjects = [];
        //this.delayTimeout = setTimeout(() => {
            findObjects({ pMatchObj: searchKey })
                .then((result) => {
                    this.selectedObjects = this.buildSelectOptions(result);
                    this.error = undefined;
                    console.log('selectedObjects1 ' + JSON.stringify(this.selectedObjects));            
                    this.displayCombo = true;
                })
                .catch((error) => {
                    console.error('error: ' + error);
                    this.error = error;
                    this.selectedObjects = undefined;
                });
        //}, DELAY);
        console.log('selectedObjects2 ' + JSON.stringify(this.selectedObjects));
    }

    buildSelectOptions(objList) {
        const listValues = [];
        objList.forEach(obj => {
            listValues.push({label: obj, value:obj});
        });    
        return listValues
    }


}