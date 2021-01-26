import { api, LightningElement, wire, track } from 'lwc';

import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

// NOTE:  For Apex imports, don't use curly braces, also you can designate a defaultExport name that's different from the module-name
import ContactDesignations from '@salesforce/apex/DesignationController.fetchContactDesignations';
import DesignationPicklist from '@salesforce/apex/DesignationController.getDesignationsPicklist';

const columns = [
    {label: 'Rec Name', fieldName: 'Name', type: 'text'},
    {label: 'Designation', fieldName: 'Designation__c', type: 'text'},
    {label: 'Start Date', fieldName: 'Designation_Start_Date__c', type: 'date'},
    {label: 'End Date', fieldName: 'Designation_End_Date__c', type: 'date'}
]

export default class testWithApexDataSource extends LightningElement {

   @api designeeId 
   @api currentDesignation

   @api selectLabel;
   @api errorLabel;

   data;
   columns = columns;

   mydesignations = [];
   editedPicklistValues = [];
   picklist;

   pDesigneeId;

   loadPicklist = false;

   hidenseek = "display:none";

   @track inputValue;
   // initialize component
   async connectedCallback() {

       //alert("designeeId = " + this.designeeId);
       this.pDesigneeId = this.designeeId ? this.designeeId : '0036A00000peZM1QAM';
       //alert("pDesigneeId = " + this.pDesigneeId);

       //alert("In connectedCallback fetchContactDesignations for " + this.pDesigneeId);
       // NOTE: WHE
       ContactDesignations({ pDesigneeId: this.pDesigneeId })
        .then(result=>{
            this.data = result;
            console.log('result:  ' + JSON.stringify(result) );
            var d;
            for (d of this.data) {
                this.mydesignations.push(d.Designation__c);
            }
        }).then(result=>{

            // Loading the picklist is dependent upon first fetcing current designations
            // refer to chained promises
        
            DesignationPicklist().then(result=>{
            this.picklist = result;
            // console.log('result:  ' + JSON.stringify(result) );

            // test test test
            this.editedPicklistValues.push('-- SELECT A NEW DESIGNATION --');

            var dx;
            var max = 0;
            for(dx of this.picklist) {
                if(dx === 'Assistant Referee') {
                    if(max < 1) {
                        max = 1;
                    }    
                };
                if(dx === 'Full Referee') {
                    if(max < 2) {
                        max = 2;
                    }    
                };
            }
            //alert("max="+ max);
            var dl;
            for (dl of this.picklist) {

                if(max == 1) {
                    this.editedPicklistValues.push('Assistant Referee');
                    break;
                } else if(max == 2) {
                    this.editedPicklistValues.push('Full Referee');
                    break;
                } 
                if(!this.mydesignations.includes(dl)) {
                    this.editedPicklistValues.push(dl);
                } 
                //else {
                //    this.editedPicklistValues.push(dl);
                //}
            }
            this.loadPicklist = true;
            
            // TODO:  THIS WORKS LOCALLY BUT WILL NOT DEPLOY, IT IS NOT RECOMMEDED updateRecord IS NOT WORKING FOR ME
            //eval($A.get('e.force:refreshView'));
            // updateRecord({fields: this.picklist});

            }).catch(error=>{
                alert('picklist error:  ' + error);
            });
        
        }).catch(error=>{
                alert('detail error:  ' + error);
        });


   }

   handleChange(event) {
        this.selectedDesignation = event.target.value; 
        const attributeChangeEvent = new FlowAttributeChangeEvent('select', this.selectedDesignation);
        this.dispatchEvent(attributeChangeEvent);   
        this.hidenseek = "display:inline";
    }

}