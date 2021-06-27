import { api, LightningElement, wire, track } from 'lwc';

// NOTE:  For Apex imports, don't use curly braces, also you can designate a defaultExport name that's different from the module-name
import ContactDesignations from '@salesforce/apex/DesignationController.fetchContactDesignations';

const columns = [
    {label: 'Rec Name', fieldName: 'Name', type: 'text'},
    {label: 'Designation', fieldName: 'Designation__c', type: 'text'},
    {label: 'Start Date', fieldName: 'Designation_Start_Date__c', type: 'date'},
    {label: 'End Date', fieldName: 'Designation_End_Date__c', type: 'date'}
]

export default class testWithApexDataSource extends LightningElement {

   @api designeeId 

   data;
   columns = columns;

   pDesigneeId;

   @track inputValue;
   // initialize component
   async connectedCallback() {

       this.pDesigneeId = this.designeeId ? this.designeeId : '0036A00000peZM1QAM';

       //alert("In connectedCallback fetchContactDesignations for " + this.pDesigneeId);
       // NOTE: WHE
       ContactDesignations({ pDesigneeId: this.pDesigneeId })
        .then(result=>{
            this.data = result;
            console.log('result:  ' + JSON.stringify(result) );
            
        }).catch(error=>{
                alert('error:  ' + error);
        });

   }

}