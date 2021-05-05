({
    CSV2JSON: function (component,csv) {

        try {
            console.log('GearImportExportHelper CSV2JSON - Incoming csv =\n' + csv);
            var csvparsed = this.parsecsv(component,csv);
            var json = this.parsedcsv2jsonstring(component,csvparsed);
            console.log('GearImportExportHelper CSV2JSON json: ' + json);
        } catch (err) {
            alert('GearImportExportHelper CSV2JSON Error: ' + err);
        }
        
        return json;
        
    },

    parsecsv : function (component, csv) {
        
        var parsedcsv = {
            headers : [],
            rows : []
        }
    
        var line = []; 
        let headerslines = new Object(parsedcsv);   
        line =  csv.split('\n');
        //console.log('number of lines = ' + line.length);
        var jsonObj = [];
        var clearObj = [];
        var instring = false;
        var headers = line[0].replaceAll('__c','').split(',');
        headerslines.headers = headers;
        var lines = line.length-1;
        var col = '';
        var i = 1;
        for(; i < lines; i++) {
            
            line[i] = line[i].trim();
            line[i] = this.scrubCSVLine(component, line[i]);
            //console.log(line[i]);
            
            var chars = line[i].length;
                //console.log(chars);
                col = '';
                for(var c = 0; c < chars; c++) {
                    var char = line[i][c];
                    if(char === '"' && instring) 
                        instring = false;
                    else if (char === '"' && !instring) 
                        instring = true;
                    if(char === ',' && instring == false) {
                        col = this.scrubCol(component, col);
                        //console.log( '1 col: ' + col );
                        jsonObj.push(col);
                        //console.log('jsonObj: ' + jsonObj);
                        col = '';
                    }
                    if(instring)
                        col = line[i][c] != '"' ? col + line[i][c] : col + "";
                    else
                        col = line[i][c] != ',' ? col + line[i][c] : col + "";
                }
            //if(col.length > 0) {
            //    col = this.scubCol(component, col);
            //    console.log( '2 col: ' + col );
            //    jsonObj.push(col);
            //}
            col = '';
            console.log('jsonObj end: ' + jsonObj);
            headerslines.rows.push(jsonObj);
            jsonObj = [];      
        }
        //headerslines.rows.push(jsonObj);
        return headerslines;
    },

    parsedcsv2jsonstring : function (component, csvparsed) {
 
        var headercount = csvparsed.headers.length;
        var linescount = csvparsed.rows.length;
        var cols = csvparsed.rows[0];
        
        var jsonObj = [];
        var headers = csvparsed.headers;
        console.log('headers: ' + headers);
        for (var i = 0; i < linescount; i++ ) {
            var data = csvparsed.rows[i];
            //console.log('row [' + i + ']: ' + data);
            //console.log('row elements = ' + data.length );
            var obj = {};
            for(var j = 0; j < data.length; j++) {
                //console.log('header: ' + headers[j].trim() + ' element: ' + data[j].trim());
                obj[headers[j].trim()] = data[j].trim();
                //console.log('element: ' + obj);
            }
            jsonObj.push(obj);
        }
        //var jsonObj = string2csv(csv);
        var json = JSON.stringify(jsonObj);
        
        //console.log('GearImportExportHelper parsedcsv2jsonstring json:\n'+ json);
        // alert("GearImportExportHelper CSVJSON json = " + json);
        
        return json;
    },

    scrubCSVLine : function (component, inputLine) {
        var line;
        inputLine = inputLine.trim();
        var n = inputLine.length;
        line = inputLine[0] === '"' ?  '^' : inputLine[0];
        line = line + inputLine.substr(1,n-2);
        line = inputLine[n-1] === '"' ? line + '^' : line + inputLine[n-1];
        line = line.replaceAll('",','^,');
        line = line.replaceAll(',"',',^');
        line = line.replaceAll('""','~');
        line = line.replaceAll('"','~');
        line = line.replaceAll('^','"');
        return line;
    },
    
 	scrubCol : function (component, col) {
        col = col.replaceAll('"','');
        var occ = 0;
        if(col.includes('~')) {
            for(var c=0; c < col.length; c++)
                occ = col[c] === '~' ? (occ + 1) : occ;
        }
        col = col.replaceAll('~','\"');
        if((occ % 2) != 0)
            col = col + '"';
        if(col.includes(','))
            col = '"' + col + '"';
        return col;
    },
    
    InsertGearData : function (component,event,helper,jsonstr){
        // console.log('jsonstr' + jsonstr);
        //alert("GearImportExportHelper InsertGearData jsonstr " + jsonstr);
        var action = component.get('c.insertGearExchangeData');
        //alert("Server Action " + action); 
        action.setParams({
            strGearWS : jsonstr
        });
        
        //document.getElementById("spinner").style.display = "block";
        component.set("v.uploading",true);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {  
                var result=response.getReturnValue();
                //alert("GearImportExportHelper InsertGearData : Data successfully transferred");
                //alert("GearImportExportHelper InsertGearData\nGearImportExport.apxc insertGearExchangeData returned: " + result);

                if(result.includes('ERROR')) {
                    //alert("GearImportExportHelper onLoad - state != SUCCESS");
                    component.set("v.toastTheme","slds-notify slds-notify_toast slds-theme_error");
                    component.set("v.toastClass","slds-icon_container slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top");                 
                    component.set("v.isSubmitCompleted",true); 
                    //component.set("v.isModalOpen", false);               
                    component.set("v.wasSubmitSuccessful",false);
                    component.set('v.toastMessage', "InsertGearData: " + result);
                } else {
                    component.set("v.toastTheme","slds-notify slds-notify_toast slds-theme_success");
                    component.set("v.toastClass","slds-icon_container slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top");                 
                    component.set("v.isSubmitCompleted",true); 
                    //component.set("v.isModalOpen", false);               
                    component.set("v.wasSubmitSuccessful",true);
                    component.set('v.toastMessage'," successfully submitted");
                }
                
                // document.getElementById("spinner").style.display = "none";
                component.set("v.uploading",false);
                
                this.cancelAndClearAfterUpload(component,event,helper);
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                
                document.getElementById("Accspinner").style.display = "none";
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message: " + errors[0].message);
                    component.set("v.toastTheme","slds-notify slds-notify_toast slds-theme_error");
                    component.set("v.toastClass","slds-icon_container slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top");                 
                    component.set("v.isSubmitCompleted",true); 
                    //component.set("v.isModalOpen", false);               
                    component.set("v.wasSubmitSuccessful",false);
                    component.set('v.toastMessage', "InsertGearData: " + errors[0].message);                  }
                } else {
                    //console.log("Unknown error");
                    //alert('Unknown');
                    component.set("v.toastTheme","slds-notify slds-notify_toast slds-theme_error");
                    component.set("v.toastClass","slds-icon_container slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top");                 
                    component.set("v.isSubmitCompleted",true); 
                    component.set("v.wasSubmitSuccessful",false);
                    component.set('v.toastMessage', "InsertGearData: An unknow error was encountered");
                }
            }
        }); 
        
        $A.enqueueAction(action);    
        
    },
    
    cancelAndClearAfterUpload : function (component, event, helper) {
        // Close the showcard display area
        component.set("v.showFileContents", false);
        component.set("v.showImport", false);
        
        // Clear file input
        var fileInput = component.find("file").getElement();
        //alert("fileInput contains: " + fileInput.value);
        fileInput.value = "";
        //fileInput.files[0] = "";
        //fileInput.form.reset();
        
        // Clear the data display
        var divCSV = document.getElementById("divCSV");
        //alert("divCSV contains: " + divCSV);
        divCSV.innerHTML = "";
        
    },
        
    //export helper start from here
    onLoad: function(component, event) {
        //alert("GearImportExportHelper onLoad");
        //call apex class method
        try {var action = component.get('c.fetchGearExchangeData');}
        catch (Err) {
            //alert("GearImportExportHelper onLoad - state != SUCCESS");
            component.set("v.toastTheme","slds-notify slds-notify_toast slds-theme_error");
            component.set("v.toastClass","slds-icon_container slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top");                 
            component.set("v.isSubmitCompleted",true); 
      		//component.set("v.isModalOpen", false);               
           	component.set("v.wasSubmitSuccessful",false);
            component.set('v.toastMessage', Err);
            return;
        }
        action.setCallback(this, function(response){
            //alert("GearImportExportHelper onLoad - response");
            var state = response.getState();
            if (state === "SUCCESS") {
                var gearObj = response.getReturnValue();
                component.set('v.RefGearList', gearObj);
                //var ObjSize = uObj.size;
                //alert("v.RefGearList size=" + gearObj.length);
                component.set('v.RefGearCount', gearObj.length);
                component.set('v.RefGearLoaded',true);
                //alert("GearImportExportHelper onLoad - SUCCESS - process data next");
                this.processDownLoad(component, event);

            } else {
                //alert("GearImportExportHelper onLoad - state != SUCCESS");
                component.set("v.toastTheme","slds-notify slds-notify_toast slds-theme_error");
            	component.set("v.toastClass","slds-icon_container slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top");                 
                component.set("v.isSubmitCompleted",true); 
      		    //component.set("v.isModalOpen", false);               
           		component.set("v.wasSubmitSuccessful",false);
                component.set('v.toastMessage', "fetchGearExchangeData - state != SUCCESS");
            }
            
        });
        $A.enqueueAction(action);
        //alert("GearImportExportHelper onLoad - complete");
    },
    
    processDownLoad : function(component, event) {
              
        //alert("in processDownLoad");

        var stockData = component.get("v.RefGearList");

        // call the helper function which "return" the CSV data as a String   
        var csv = this.convertArrayOfObjectsToCSV(component,stockData);   
        if (csv == null){
            alert("downloadCsv - csv object is null");
            return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'GearExchangeExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file

    }, 

    convertArrayOfObjectsToCSV : function(component,objectRecords){
        //alert("GearImportExportHelper convertArrayOfObjectsToCSV");
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        // in the keys variable store fields API Names as a key 
        // this labels use in CSV file header  
        //keys = ['Name','Phone','AccountNumber' ];
        keys = ['Item_Num__c', 'Date_Recd__c', 'Category__c', 'Item__c', 'Price__c', 'Size__c',
            'Gender__c', 'Color__c', 'Notes__c', 'Donated_by__c', 'Received_by__c', 'Located_at__c',
            'Value__c', 'Distributed_To__c', 'Distribution_Date__c', 'Distributed_By__c',
            'Distribution_Location__c', 'Thanks_Sent_Date__c', 'DisplayOnList__c'];
        
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult = csvStringResult.replaceAll('__c','');
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey]; 
                
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                } 
                // if condition for blank column display if value is empty
                if(objectRecords[i][skey] != undefined){
                    var value = objectRecords[i][skey];
                    value = value.length > 0 ? value.replaceAll('"','""') : value;
                    csvStringResult += '"'+ value +'"'; 
                }else{
                    csvStringResult += '"'+ '' +'"';
                }
                counter++;
                
                
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        // return the CSV formate String 
        return csvStringResult; 
        
    },
})