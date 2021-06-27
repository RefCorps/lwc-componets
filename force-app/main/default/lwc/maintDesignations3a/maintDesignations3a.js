/**
 * Lightning Web Component for RefCorp Flow Screens used to maintain Designations
 * This component incorporates a table to maintain existing Designations and a
 * select to add new designations.
 * 
 * CREATED BY:          Mike Miller
 * 
 * RELEASE NOTES:       You must deploy LWC richDatatableRC with this component - this allows a richtext column
 * 
 * 2021-02-19 - v0.1.1 - Removed 'Rec Name'
 * 2021-02-25 - v0.1.2 - Hardcoded Designation__c column label = Endorsement -- consider making it a param
 * 2021-02-26 - v0.2.0 - Added ability to exclude picklist values - intent is to omit Rank settings
 * 2021-02-27 - v0.3.0 - Existing endorsements with no end date are added to excludedValues to prevent duplicate endorsements
 * 2021-03-01 - v0.3.1 - Code cleanup - Modified to better support testing
 * 2021-03-02 - v0.3.2 - Code reset Start and End dates when user blanked data - test for update to null
 *                       Note that in this version mulitple changes to a row are distinct events.  A flow may see all events at the
 *                       same time.
 * 2021-03-29 - v0.3.3 - Added exclusion list to params so you table select rank or endorsments only 
 * 2021-03-30 - v0.3.4 - Added tableDisplayEndDate ? columns3 : columns2;
 * 2021-04-14 - v0.4.0 - Fixed issue with table help.  Precoded for delete Button - pending review 
**/
import {
    api,
    LightningElement,
    wire,
    track
} from 'lwc';

import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent }  from 'lightning/platformShowToastEvent';

// NOTE:  For Apex imports, don't use curly braces, also you can designate a defaultExport name that's different from the module-name
import ContactDesignations from '@salesforce/apex/DesignationController.fetchContactDesignations';
import DesignationPicklist from '@salesforce/apex/DesignationController.getDesignationsPicklist';

//const columns = [{ label: 'Rec Name',fieldName: 'Name',type: 'text' },

// row actions
const actions = [
    { label: 'Delete', name: 'delete'},
];

// timezones "America/New_York" "GMT-05:00" - timezone can impact date presentation - (one day less than day)

const columns3 = [
{ label: 'Designation' ,fieldName: 'Designation__c',type: 'text' },
{ label: 'Start Date',
    fieldName: 'Designation_Start_Date__c',
    type: 'date-local', 
    typeAttributes: {year: "numeric", month: "2-digit", day: "2-digit"}, 
    editable: true },
{ label: 'End Date',
    fieldName: 'Designation_End_Date__c',
    type: 'date-local', 
    typeAttributes: {year: "numeric", month: "2-digit", day: "2-digit", timezone: "America/New_York"}, 
    editable: true 
    }
]
// This line can be used to add a Delete function - not doing it now however
// { type: 'action', typeAttributes: { rowActions: actions,  menuAlignment: 'right' } }  

const columns2 = [{ label: 'Designation' ,fieldName: 'Designation__c',type: 'text' },
{ label: 'Start Date',fieldName: 'Designation_Start_Date__c',type: 'date-local', 
    typeAttributes: {year: "numeric", month: "2-digit", day: "2-digit"}, editable: true } ]

export default class MaintDesignations3 extends LightningElement {
    @api designeeId;
    @api selectedDesignation;
    @api selectionStartDate;
    @api selectionEndDate;

    @api outputEditedRows = [];
    @api editedData = [];

    @api suppressBottomBar = false;

    @api selectLabel;
    @api selectHelp;
    @api selectHint;

    @api tableLabel;
    @api tableHelp;
    @api tableHint;
    @api tableDisplayEndDate = false;

    @api excludedValues;

    @api tableCol1Label;
    //@api errorLabel;

    @track inputValue;
    @track columns;
    @track error;

    pDesigneeId; // Parameter used with DesignationController.fetchContactDesignations

    @track data = [];
    origResultData;
    selectedRows = [];

    reload = false;

    mydesignations = [];
    editedPicklistValues = [];
    picklist;

    lblSelect;
    infoSelect = "Current Endorsements and Rank are displayed in the table above. Candidates and Assistants will typically only appear with Rank.  Referees may have several endorsements associated with rank.";
    lblTable;
    infoTable = "Endorsements are similar to rank, but are not the same.  A member of the corps may have several active endorsements.";

    loadPicklist = false;
    showMyWarningMessage = false;
    myWarningMessage = "Warning";

    hidenseek = "display:none";

    todaysDate;

    useTestData = true; // Provides default test data to facilitate local testing in VSCode
    enableLogging = true; // When true console logging through logmessage is enabled

    // initialize component
     async connectedCallback() {
        
        // BEGIN LOCAL TEST DATA - DEFAULT VALUES

        this.pDesigneeId = '';

        // this.columns = this.tableDisplayEndDate ? columns3 : columns2;
        this.columns = columns3;

        if (this.useTestData) {

            this.logmessage('Default test data is enabled.  Defaults will be used when there is no corresponding parameter');

            this.pDesigneeId = this.designeeId ? this.designeeId : '0036A00000peZM1QAM';
            this.lblSelect = this.selectLabel ? this.selectLabel : 'New Endorsement';
            this.lblTable = this.tableLabel ? this.tableLabel : 'Career Endorsements';
            this.tableCol1Label = this.tableCol1Label ? this.tableCol1Label : 'Endorsements/Rank';
            this.selectHelp = this.selectHelp ? this.selectHelp : this.infoSelect;
            this.tableHelp = this.tableHelp ? this.tableHelp : this.infoTable;
            this.selectHint = this.selectHint ? this.selectHint : 'Select a new option';
            this.tableHint = this.tableHint ? this.tableHint : '(press enter after updating a cell)';

            // this.excludedValues = this.excludedValues ? this.excludedValues : 'Referee,Full Referee,Assistant Referee,Candidate Referee, Emeritus';
            this.excludedValues = this.excludedValues ? this.excludedValues : 'Chief Referee,Emeritus,FISA,Clinician,Mentor,Referee College Faculty,Referee Committee,Regional Coordinator,Staff';

        } else {
            this.pDesigneeId = this.designeeId;
            this.lblSelect = this.selectLabel;
            this.lblTable = this.tableLabel;
            this.selectHint = this.selectHint;
            this.tableHint = this.tableHint;

            // USE DEFAULTS IF NO PROP PROVIDED
            this.selectHelp = this.selectHelp ? this.selectHelp : this.infoSelect;
            this.tableHelp = this.tableHelp ? this.tableHelp : this.infoTable;
            this.excludedValues = this.excludedValues ? this.excludedValues : 'Referee,Full Referee,Assistant Referee,Candidate Referee, Emeritus';

        }

        // END LOCAL TEST DATA  

        if (!this.pDesigneeId) {
            alert('maintDesignations Error - No Designee__c value needed to access records was found! NO DATA CAN BE SELECTED.');
        }

        this.suppressBottomBar = true;

        this.todaysDate = this.getDateYYYYMMDD();

        // THIS WILL REPLACE THE DEFAULT COLUMN LABLE
        if (this.tableCol1Label)
            this.columns[0].label = this.tableCol1Label;

        this.logmessage("In connectedCallback fetchContactDesignations for " + this.pDesigneeId);
        //this.data = [];

        this.excludedValues = this.formatExclusionListForSOQL(this.excludedValues);
        this.logmessage('pDesigneeId=' + this.pDesigneeId + ' pExclusionList=' + this.excludedValues);

        ContactDesignations({
                pDesigneeId: this.pDesigneeId,
                pExclusionList: this.excludedValues
                //pDesigneeId: this.designeeId
            })
            // the then() method returns a Promise. This handles the result from fetchContactDesignations see the import above
            .then(result => {
                
                this.origResultData = result;
                this.data = result;

                //this.logmessage('Designations:  ' + JSON.stringify(result));
                var d;
                this.logmessage('Designation rows returned: ' + Object.keys(this.data).length);
                this.logmessage('Designations returned: ' + JSON.stringify(this.data));

                // Add designation to mydesignations if there is no end date - these will be excluded from the picklist
                var candidate = 'Candidate Referee';
                var candidateFound = false;
                var assistant = 'Assistant Referee';
                var assistantFound = false;
                for (d of this.data) {
                    if (!d.Designation_End_Date__c) {
                        if(d.Designation__c === candidate) 
                            candidateFound = true;
                        this.mydesignations.push(d.Designation__c);
                    }
                }
                if(!candidateFound)
                    this.mydesignations.push(candidate);
                if(!assistantFound)
                    this.mydesignations.push(assistant);
                this.logmessage(this.mydesignations);

                this.editedData = JSON.parse(JSON.stringify(this.data));

                //this.logmessage("processed result-data " + JSON.stringify(this.data));
                //this.logmessage("processed result-editedData " + JSON.stringify(this.editedData));

            }).then(result => {

                // Loading the picklist is dependent upon first fetcing current designations
                // refer to chained promises

                DesignationPicklist().then(result => {
                    this.picklist = result;
                    this.logmessage('Picklist:  ' + JSON.stringify(result));

                    // Add mydesignations to excludedValues
                    var md;
                    if (this.excludedValues) {
                        for (md of this.mydesignations) {
                            if (!this.excludedValues.includes(md))
                                this.excludedValues = this.excludedValues + ',' + md;
                        }
                    }

                    var dl;
                    for (dl of this.picklist) {

                        this.logmessage('mydesignations ' + this.mydesignations);

                        if (this.excludedValues) {
                            if (!this.excludedValues.includes(dl)) {
                                //this.editedPicklistValues.push({
                                //    label: dl,
                                //    value: dl
                                //});
                                this.editedPicklistValues.push(dl);
                            }

                        }

                    }
                    this.loadPicklist = true;

                    // TODO:  THIS WORKS LOCALLY BUT WILL NOT DEPLOY, IT IS NOT RECOMMEDED updateRecord IS NOT WORKING FOR ME
                    // eval($A.get('e.force:refreshView'));
                    // updateRecord({fields: this.picklist});

                }).catch(error => {
                    alert('maintDesignation picklist error:  ' + error);
                });

            }).catch(error => {
                alert('maintDesignation detail error:  ' + error);
            });

    }

/* this will react to changes of data being traced but so far no reload    
    renderedCallback() {
        
        //alert("renderedCallback");
        //var dataload = this.data;
        //var doReload = this.reload;
        //this.justDoIt();
        if(this.reload) {
            console.log('Now DoIt');
            alert("Reload data");
            this.data = this.origResultData;
            this.logmessage('Reloading rows: ' + Object.keys(this.data).length);
            this.logmessage('Reloading data: ' + JSON.stringify(this.data));
            $A.get('e.force:refreshView').fire();
        }
        else
            console.log("Don't DoIt");
        
    }
*/

    handleSelection(event) {
        this.selectedDesignation = event.target.value;
        // DOTO: this is supposed to change date from hidden to visible - not configured correctly
        const attributeChangeEvent = new FlowAttributeChangeEvent('select', this.selectedDesignation);
        this.dispatchEvent(attributeChangeEvent);
        this.hidenseek = "display:inline";
        this.selectionStartDate = this.getDateYYYYMMDD();
        this.logmessage("default startdate " + this.selectionStartDate);
    }

    handleStartDate(event) {
        this.selectionStartDate = event.target.value;
        this.logmessage("selected startdate " + this.selectionStartDate);
    }

    handleCellChange(event) {
        // If suppressBottomBar is false, wait for the Save or Cancel button
        if (this.suppressBottomBar) {

            // test test test
            var et = event.target;

            const changedValue = event.detail.draftValues[0];
            var etv = et.value;
            const idEndDate = "Designation_End_Date__c";
            const idStartDate = "Designation_Start_Date__c";
  
            if (changedValue.hasOwnProperty(idEndDate)) {

                this.logmessage(" >>> End Date changed: " + JSON.stringify(changedValue));
                var startDate = this.findDataValue(changedValue.Id, idStartDate);
                var currEndDate = this.findDataValue(changedValue.Id, idStartDate);
                var startDt = new Date(startDate);

                var newEndDate = changedValue.Designation_End_Date__c;
                var newEndDt = new Date(newEndDate);

                    if (startDt > newEndDt) {
 
                        changedValue.Designation_End_Date__c = currEndDate;
                        event.detail.draftValues[0] = currEndDate;

                        //var thisdate = this.data;
                        //this.data = this.origdata;

                        this.setDataValue(changedValue.Id,idEndDate, currEndDate);
                       
                        this.showToast("End Date Error","End Date cannot be earlier than Start Date");

                        //this.selectedRows = [];
                        
                        this.reload = true;

                        // return refreshApex(this.origResultData);
                        return;
                     
                    }

            }
  
            // end test end test end test

            this.handleSave(event);
            
            event.target.dataset.value = this.editedData;


            this.logmessage("handleSave returned here");
        }
    }

    handleSave(event) {
        
        const draftValues = event.detail.draftValues;
        const idDesignation = "Designation__c";
        const idEndDate = "Designation_End_Date__c";
        const idStartDate = "Designation_Start_Date__c";

        var dvrows = Object.keys(event.detail.draftValues).length;
        var outrows = Object.keys(this.outputEditedRows).length;

        var editedRow;

        var vIdEndDate = idEndDate;
        var vIdStartDate = idStartDate;

        var before_startdate = "";
        var before_enddate = "";

        var i = 0;
        // this loops across all changes but since the save actually
        // loads to a queue for processing rather than immediate load by the 
        // flow this simply places changes in a queue
        for (i; i < dvrows; i++) {

            // if no rows in queue prep for insert insert to top
            var dvId = draftValues[i].Id;
            var dvIdx = this.getIndex(dvId);
            //if (outrows == 0 || dvIdx > outrows) // empty or no matc
            if(outrows == 0 || dvIdx < 0) // empty or no match
            { 
                this.logmessage(dvrows + " - " + JSON.stringify(draftValues[i]));

                var recordId = draftValues[i].Id;

                before_enddate = this.findDataValue(recordId, idEndDate);
                before_startdate = this.findDataValue(recordId, idStartDate);

                var enddate = "";
                var startdate = "";
                var designationText = "";
                // v0.3.2 THE ORIGINAL CODE WAS SET TO FILL IN THE BLANKS - WE'LL SKIP IF THE KEY IS PRESENT INDICATING A CHANGE
                if(!draftValues[i].hasOwnProperty(vIdEndDate)) {
                    if (!draftValues[i][idEndDate]) {
                        enddate = this.findDataValue(recordId, idEndDate);
                        if (enddate)
                            draftValues[i][idEndDate] = enddate;
                    }
                }
                if(!draftValues[i].hasOwnProperty(vIdStartDate)) {  
                    if (!draftValues[i][idStartDate]) {
                        startdate = this.findDataValue(recordId, idStartDate);
                        if (startdate)
                            draftValues[i][idStartDate] = startdate;
                    }
                }

                this.logmessage("Idx=- before_startdate = " + before_startdate);
                this.logmessage("Idx=- before_enddate = " + before_enddate);

                designationText = this.findDataValue(recordId, idDesignation);
                draftValues[i][idDesignation] = designationText;

                this.logmessage("draftValues [" + i + "] = " + JSON.stringify( draftValues[i] )) ;

                editedRow = draftValues[i];
                // this.outputEditedRows.push(draftValues[i]);

            } else { // Update edited row in output

                // if row is in queue update it

                var recordId = draftValues[i].Id;
                before_enddate = this.findDataValue(recordId, idEndDate);
                before_startdate = this.findDataValue(recordId, idStartDate);

                editedRow = this.outputEditedRows[i];
                var x = this.getIndex(this.outputEditedRows[i].Id);
                if (draftValues[i][idEndDate]) {
                    //this.outputEditedRows[x][idEndDate] = draftValues[i][idEndDate];
                    editedRow[idEndDate] = draftValues[i][idEndDate]; 
                }
                if (draftValues[i][idStartDate]) {
                    //this.outputEditedRows[x][idStartDate] = draftValues[i][idStartDate];
                    editedRow[idStartDate] = draftValues[i][idStartDate];
                }
            }

        }

        this.logmessage("Edited Row = " + JSON.stringify(editedRow) );

        var strEndDate = editedRow.Designation_End_Date__c;
        var endDt = new Date(strEndDate);
        var strStartDate = editedRow.Designation_Start_Date__c;
        var startDt = new Date(strStartDate);
        var designation =  editedRow.Designation__c;

        // this is supposed to validate data before insert to queue
        // it does but table is not changed - tried renderedCallback 
        // as alternative
        if(startDt > endDt) {
            var msg =   "Error: " + designation;
            msg = msg + "\nStart Date: " + strStartDate;
            msg = msg + "\nis greater than\nEnd Date: " + strEndDate;
            msg = msg + "\n" + designation;
            this.logmessage(msg);
            this.showToast('Date Error',msg);
            //alert(msg);

            var a = this.setDataValue(recordId, idStartDate, before_startdate);
            var b = this.setDataValue(recordId, idEndDate, before_enddate);
            
            event.currentTarget.setValue = b;
            event.currentTarget.dataset.value = b;
            event.target.value = b;

            this.logmessage("Unable to update row");
            return;
        }
        // data goes into queue here
        var outputEditedRowsCnt = this.outputEditedRows.length;
        if(outputEditedRowsCnt > 0 ) {
            var rowidx = this.getIndex(editedRow.Id);
            if(rowidx < 0) {
                this.outputEditedRows.push(editedRow);
            }
            else {
                this.outputEditedRows[rowidx] = editedRow;
            }

        } else {
            this.outputEditedRows.push(editedRow);
        }
        this.logmessage(" <<< final rec: " + JSON.stringify(this.outputEditedRows));

    }

    /*
    handleRowActions(event) {
        let actionName = event.detail.action.name;

       this.logmessage('actionName ====> ' + actionName);

        let row = event.detail.row;

        this.logmessage('row ====> ' + row);
        // eslint-disable-next-line default-case
        switch (actionName) {
            //
            case 'record_details':
                // alert('tableGearExchange - record details row ' + JSON.stringify(row));
                this.viewCurrentRecord(row);
                break;
            case 'edit':
                this.editCurrentRecord(row);
                break;
            //    
            case 'delete':
                alert('Delete this row ' + row.Designation_Start_Date__c);
                row.Designation_Start_Date__c = '';
                break;

        }
    }
    */

    findDataValue(Id, key) {
        var dataLen = Object.keys(this.data).length;
        var value = "";
        for (var i = 0; i < dataLen; i++) {
            if (this.data[i].Id === Id) {
                value = this.data[i][key];
                break;
            }
        }
        this.logmessage("findDataValue Id = " + Id + " returning " + JSON.stringify(value));
        return value;
    }

    setDataValue(Id, key, value) {
        var dataLen = Object.keys(this.data).length;
        var setValue = "";
        for (var i = 0; i < dataLen; i++) {
            if (this.data[i].Id === Id) {
                this.data[i][key] = value;
                setValue = this.data[i][key];
                break;
            }
        }
        this.logmessage("findDataValue Id = " + Id + " returning " + JSON.stringify(setValue));
        return setValue;
    }

    updateData(updateddata) {
        this.data = updateddata;
    }

    getIndex(Id) {
        var rows = Object.keys(this.outputEditedRows).length;
        //rows = rows + 1;
        var idx = -1;
        for (var i = 0; i < rows; i++) {
            if (this.outputEditedRows[i].Id === Id) {
                idx = i;
                break;
            }
        }
        this.logmessage("getIndex " + Id + " returning " + idx);
        return idx;
    }

    getDateYYYYMMDD() {
        var today = new Date();
        var p = '-';
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();
        dd = dd < 10 ? '0' + dd : dd;
        mm = mm < 10 ? '0' + mm : mm;
        return yyyy + p + mm + p + dd;
    }

    formatExclusionListForSOQL(list) {
        list = list.replaceAll('\'','');
        list = list.replaceAll(', ',',');
        list = list.replaceAll(',','\',\'');
        list = '(\'' + list + '\')';
        this.logmessage('ExclusionList: ' + list);
        return list;
    }


    showToastBtn() {
        
        this.showMyWarningMessage = true;

        /*
        const evt = new ShowToastEvent({
            title: 'Get Help',
            message: 'Salesforce documentation is available in the app. Click ? in the upper-right corner.',
        });
        this.dispatchEvent(evt);
        this.logmessage("What just happended?")
        */
    }

    closeToast() {
        this.showMyWarningMessage = false;
    }

    showToast(mytitle, mymessage) {

        this.showMyWarningMessage = true;
        this.myWarningMessage = mymessage;

    }


    logmessage(message) {
        if (this.enableLogging) {
            console.log('maintDesignations ' + message);
        }
    }
}