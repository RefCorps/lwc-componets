import { api, LightningElement } from 'lwc';

export default class DataCallYears extends LightningElement {

    version = 'v0.1';

    @api selectLabel;
    @api selectHint;
    @api selectedValue;

    options = [];

    STARTDATE = 0;
    ENDDATE = 1;
    
    enableLogging = true; 

    async connectedCallback() {

        console.log('Start Data Call Date Generation');

        this.selectLabel = this.selectLabel ? this.selectLabel : 'Data Call Report Period';
        this.selectHint = this.selectHint ? this.selectHint : 'Select a Data Call Report Period so view other than current year';


         this.options =  this.generateDates();
        
        console.log('End Data Call Date Generation');

    }

    generateDates() {
    
        console.log('>> generateDates');
    
        var listValues = []; 

        var dataCallPeriod = this.currentDataCallYear();
        console.log( dataCallPeriod[this.STARTDATE].toLocaleDateString('en-US') + ' ' + dataCallPeriod[this.ENDDATE].toLocaleDateString('en-US')  );
        // DEFAULT
        var currperiod = dataCallPeriod[this.STARTDATE].toLocaleDateString('en-US') + ' - ' + dataCallPeriod[this.ENDDATE].toLocaleDateString('en-US');
        var year = dataCallPeriod[this.ENDDATE].getFullYear();
        this.selectedValue = year;
        listValues.push({
            label: currperiod,
            value: year
        });
        // OTHER SELECTIONS
        for (var i = 0; i < 30; i++) {
            year--;
            dataCallPeriod = this.getDataCallPeriod(year);
            console.log( dataCallPeriod[this.STARTDATE].toLocaleDateString('en-US') + ' - ' + dataCallPeriod[this.ENDDATE].toLocaleDateString('en-US')  );
            var period = dataCallPeriod[this.STARTDATE].toLocaleDateString('en-US') + ' - ' + dataCallPeriod[this.ENDDATE].toLocaleDateString('en-US');
            listValues.push( {label: period, value: year} );
        }
        console.log('<< generateDates');

        return listValues;

    }
    
    currentDataCallYear() {
        var currdate = new Date();
        var year = currdate.getFullYear();
        if ((currdate.getMonth()+1) < 1) {
            year = year - 1;
            //this.getDataCallPeriod(dataCallYear)
        }
        var dataCallPeriod = this.getDataCallPeriod(year);
        
        return dataCallPeriod;
        
    }
    
    // Calcuate prior data call year
    // returns Date array with 2 elements start date is in element 0 and end date is in element 1
    // NOTE:  THE FULL RANGE AVAILABLE IS 1960 TO 2200
    getDataCallPeriod(dataCallYear) {
        var dataCallDate = new Array(2);
        if (dataCallYear > 1960 && dataCallYear < 2200) {
            // Aug = 7 -- Sept = 8
            dataCallDate[this.STARTDATE] = new Date((dataCallYear-1), 7, 31);
            dataCallDate[this.ENDDATE] = new Date(dataCallYear, 8, 1);
        }
        return dataCallDate;
    }
    
    handleChange(event) {
        this.selectedValue = event.target.value; 
        this.logmessage("selectedValue = "+this.selectedValue);
    }

    logmessage(message) {
        if (this.enableLogging) {
            console.log('picklistComp ' + this.version + ': ' + message);
        }
    }


}