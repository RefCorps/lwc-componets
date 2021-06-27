import {
    api,
    LightningElement,
    wire,
    track
} from 'lwc';

import {
    FlowAttributeChangeEvent
} from 'lightning/flowSupport';

// NOTE:  For Apex imports, don't use curly braces, also you can designate a defaultExport name that's different from the module-name
import ContactDesignations from '@salesforce/apex/DesignationController.fetchContactDesignations';
import DesignationPicklist from '@salesforce/apex/DesignationController.getDesignationsPicklist';

const columns = [{ label: 'Rec Name',fieldName: 'Name',type: 'text' },
    { label: 'Designation',fieldName: 'Designation__c',type: 'text' },
    { label: 'Start Date',fieldName: 'Designation_Start_Date__c',type: 'date-local', 
        typeAttributes: {year: "numeric", month: "2-digit", day: "2-digit"}, editable: true },
    { label: 'End Date',fieldName: 'Designation_End_Date__c',type: 'date-local', 
        typeAttributes: {year: "numeric", month: "2-digit", day: "2-digit"}, editable: true } ]

export default class testWithApexDataSource extends LightningElement {

    @api designeeId;
    @api selectedDesignation;
    @api selectionStartDate;
    @api selectionEndDate;

    @api updatedRows;

    @api tableData = [];
    @api outputEditedRows = [];
    @api outputEditedRowsString = '';  // User defined Object
    @api savePreEditData = [];
    @api editedData = [];
    @api outputData = [];

    @api selectLabel;
    @api selectHelp;
    @api tableLabel;
    @api tableHelp;
    // @api errorLabel;

    @track mydata = [];

    pDesigneeId;

    data;
    columns = columns;

    mydesignations = [];
    editedPicklistValues = [];
    picklist;

    lblSelect;
    infoSelect ="Current designations are displayed. Candidates and Assistants will have one designation equal to rank.  Referees may have several as well as rank.";
    lblTable;
    infoTable = "Designations are similar to rank, but are not the same.  A member of the corps may have several designations.";

    loadPicklist = false;

    hidenseek = "display:none";

    todaysDate;

    @track inputValue;
    // initialize component
    async connectedCallback() {

        //alert("designeeId = " + this.designeeId);
        this.pDesigneeId = this.designeeId ? this.designeeId : '0036A00000peZM1QAM';
        //alert("pDesigneeId = " + this.pDesigneeId);

        this.lblSelect = this.selectLabel ? this.selectLabel : 'New Designations';
        this.lblTable = this.tableLabel ? this.tableLabel : 'Current Designations';

        this.infoSelect = this.selectHelp ? this.selectHelp : this.infoSelect;
        this.infoTable = this.selectTable ? this.tableHelp : this.infoTable;

        this.todaysDate = this.getDateYYYYMMDD();

        //alert("In connectedCallback fetchContactDesignations for " + this.pDesigneeId);
        // NOTE: We'll get currently assigned designations first - these will go into the table 
        //       We need to wait until this is loaded to build the new designation select options
        ContactDesignations({
                pDesigneeId: this.pDesigneeId
            })
            .then(result => {
                this.data = result;
                this.tableData = this.data;
                console.log('Designations:  ' + JSON.stringify(result));
                var d;
                for (d of this.data) {
                    this.mydesignations.push(d.Designation__c);
                }

// Set table data attributes
//this.mydata = [...data];
this.mydata = this.data;

this.savePreEditData = [...this.mydata];
this.editedData = JSON.parse(JSON.stringify([...this.tableData]));  // Must clone because cached items are read-only
console.log('selectedRows',this.selectedRows);
console.log('keyField:',this.keyField);
console.log('tableData',this.tableData);
console.log('mydata:',this.mydata);

            }).then(result => {

                // Loading the picklist is dependent upon first fetcing current designations
                // refer to chained promises

                DesignationPicklist().then(result => {
                    this.picklist = result;
                    console.log('Picklist:  ' + JSON.stringify(result) );

                    // test test test
                    this.editedPicklistValues.push('-- SELECT A NEW DESIGNATION --');

                    var dl;
                    var md;
                    var dx = 0;
                    for (md of this.mydesignations) {
                        if (md === 'Assistant Referee') {
                            if (dx < 1) {
                                dx = 1;
                                console.log("md=" + md + " dx=" + dx );
                            }
                        }
                        if (md === 'Full Referee') {
                            if (dx < 2) {
                                dx = 2;
                                console.log("md=" + md + " dx=" + dx );
                            }
                        }
                    }
                    console.log("dx="+ dx);
                    //var dl;
                    for (dl of this.picklist) {

                        if (dx == 0) {
                            this.editedPicklistValues.push('Assistant Referee');
                            break;
                        } else if (dx == 1) {
                            this.editedPicklistValues.push('Full Referee');
                            break;
                        }
                        if (!this.mydesignations.includes(dl)) {
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

                }).catch(error => {
                    console.error('picklist error:  ' + error);
                    alert('picklist error:  ' + error);
                });

            }).catch(error => {
                console.error('detail error:  ' + error);
                alert('detail error:  ' + error);
            });


    }

    handleSelection(event) {
        this.selectedDesignation = event.target.value;
        // DOTO: this is supposed to change date from hidden to visible - not configured correctly
        const attributeChangeEvent = new FlowAttributeChangeEvent('select', this.selectedDesignation);
        this.dispatchEvent(attributeChangeEvent);
        this.hidenseek = "display:inline";
        this.selectionStartDate = this.getDateYYYYMMDD();
        console.log("default startdate " + this.selectionStartDate);
    }

    handleStartDate(event) {
        this.selectionStartDate = event.target.value;
        console.log("selected startdate " + this.selectionStartDate);
    }

    /*
    handleSave(event) {
        this.updatedRows = event.detail.draftValues;
        console.log( JSON.stringify(this.updatedRows));
    }
    */

   handleSave(event) {
       
   // alert("In handleSave");

    // Only used with inline editing
    const draftValues = event.detail.draftValues;

    console.log("values = " + Object.keys(event.detail.draftValues).length);
    console.log("draftValues: " + JSON.stringify(draftValues));

    // Apply drafts to mydata
    let data = [...this.mydata];
    console.log("data" + JSON.stringify(data) + " - this.mydata" + JSON.stringify(this.mydata));

    data = data.map(item => {
        const draft = draftValues.find(d => d[this.keyField] == item[this.keyField]);
        if (draft != undefined) {
            let fieldNames = Object.keys(draft);
            fieldNames.forEach(el => item[el] = draft[el]);
           
        }
        //updatedDesignation
        return item;
    });

    // Apply drafts to editedData
    let edata = [...this.editedData];
    edata = edata.map(eitem => {
        const edraft = draftValues.find(d => d[this.keyField] == eitem[this.keyField]);
        if (edraft != undefined) {
            let efieldNames = Object.keys(edraft);
            efieldNames.forEach(ef => {
                // if(this.percentFieldArray.indexOf(ef) != -1) {
                //     eitem[ef] = Number(edraft[ef])*100; // Percent field
                // }
                eitem[ef] = edraft[ef];
                console.log("ef=" + ef);
                console.log("edraft[ef]=" + edraft[ef]);

            });

            // Add/update edited record to output collection
            const orecord = this.outputEditedRows.find(o => o[this.keyField] == eitem[this.keyField]);   // Check to see if already in output collection      
            if (orecord) {
                const otherEditedRows = [];
                this.outputEditedRows.forEach(er => {   // Remove current row so it can be replaced with the new edits
                    if (er[this.keyField] != eitem[this.keyField]) {
                        otherEditedRows.push(er);
                    }
                });
                this.outputEditedRows = [...otherEditedRows];
            } 
            this.outputEditedRows = [...this.outputEditedRows,eitem];     // Add to output attribute collection
            if (this.isUserDefinedObject) {
                this.outputEditedRowsString = JSON.stringify(this.outputEditedRows);                                        //JSON Version
                this.dispatchEvent(new FlowAttributeChangeEvent('outputEditedRowsString', this.outputEditedRowsString));    //JSON Version
            } else {
                this.dispatchEvent(new FlowAttributeChangeEvent('outputEditedRows', this.outputEditedRows));
            }
        }
        return eitem;
    });  

    this.savePreEditData = [...data];   // Resave the current table values
    this.mydata = [...data];            // Reset the current table values
    if (!this.suppressBottomBar) {
        this.columns = [...this.columns];   // Force clearing of the edit highlights
    }
}



    getDateYYYYMMDD() {
        var today = new Date();
        var p = '-';
        var dd = today.getDate();
        var mm = today.getMonth()+1; 
        var yyyy = today.getFullYear();
        dd = dd<10 ? '0'+dd : dd;  
        mm = mm<10 ? '0'+mm : mm;
        return yyyy+p+mm+p+dd;
    }


}