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
    { label: 'Start Date',fieldName: 'Designation_Start_Date__c',type: 'date' },
    { label: 'End Date',fieldName: 'Designation_End_Date__c',type: 'date' } ]

export default class testWithApexDataSource extends LightningElement {

    @api designeeId
    @api selectedDesignation
    @api selectionStartDate
    @api selectionEndDate


    @api selectLabel;
    @api selectHelp;
    @api tableLabel;
    @api tableHelp;
    // @api errorLabel;

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
        // NOTE: WHE
        ContactDesignations({
                pDesigneeId: this.pDesigneeId
            })
            .then(result => {
                this.data = result;
                console.log('Designations:  ' + JSON.stringify(result));
                var d;
                for (d of this.data) {
                    this.mydesignations.push(d.Designation__c);
                }
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
                    alert('picklist error:  ' + error);
                });

            }).catch(error => {
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