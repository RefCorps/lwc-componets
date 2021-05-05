({    
    CreateRecord: function (component, event, helper) {
        //alert("GearImportExportController CreateRecord");
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        
        if(!file) {
            alert("No file selected. \nUse the\n\t'Browse...'\nbutton to select a local file.");
        }
        
        if (file){
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                
                //console.log("EVT FN");
                var csv = evt.target.result;
                //console.log('csv file contains'+ csv);
                var result = helper.CSV2JSON(component,csv);
                //console.log('result = ' + result);
                //console.log('Result = '+JSON.parse(result));
                //alert("GearImportExportController CreateRecord - InsertGearData follows");
                helper.InsertGearData(component, event, helper, result);
                
            }
            reader.onerror = function (evt) {
                
                //alert("Error reading file. Invalid file format.");
                //component.set("v.wasSubmitSuccessful",false);
                //component.set('v.toastMessage'," Error reading file.");
                component.set("v.toastTheme","slds-notify slds-notify_toast slds-theme_error");
            	component.set("v.toastClass","slds-icon_container slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top");                 
                component.set("v.isSubmitCompleted",true); 
      		    //component.set("v.isModalOpen", false);               
           		component.set("v.wasSubmitSuccessful",false);
                component.set('v.toastMessage',result);
                
            }
        }
        
    },
    
    cancelAndClear : function (component, event, helper) {
        // Close the showcard display area
        component.set("v.showFileContents", false);
        component.set("v.showImport", false);
        component.set("v.uploadFile","");
        
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
    
    resetShowFileContents : function(component, event, helper) {
        
    	var ckbShowFileContents = component.find("ckbShowFileContents");
        if(ckbShowFileContents.get("v.checked") == true) {
            //alert("showFileContents checked " + ckbShowFileContents.get("v.checked"));
    		component.set("v.showFileContents", true);
        } else {
            //alert("showFileContents checked " + ckbShowFileContents.get("v.checked"));
    		component.set("v.showFileContents", false);
        }
        
	},
    
    showfiledataOrig :  function (component, event, helper){        
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        if (file) {
            component.set("v.showcard", true);
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var table = document.createElement("table");
                var rows = csv.split("\n");
                for (var i = 0; i < rows.length; i++) {
                    var cells = rows[i].split(",");
                    if (cells.length > 1) {
                        var row = table.insertRow(-1);
                        for (var j = 0; j < cells.length; j++) {
                            var cell = row.insertCell(-1);
                            cell.innerHTML = cells[j];
                        }
                    }
                }
                var divCSV = document.getElementById("divCSV");
                divCSV.innerHTML = "";
                divCSV.appendChild(table);
            }
            reader.onerror = function (evt) {
                //console.log("error reading file");
                alert("GearImportExportController showfiledataOrig - Reader Error");
            }
        }
    },    
    
    showfiledata :  function (component, event, helper){        
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        var fileName = file.name;
        component.set("v.uploadFile",fileName);
        if (file) {
            component.set("v.showImport", true);
            console.log("File: " + file);
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var table = document.createElement("table");
                table.style.border = "thin solid black";
                table.style.borderCollapse = "collapse";
                table.style.backgroundColor = "whitesmoke";
                var csvparsed = helper.parsecsv(component,csv);
                // Check for critical headers
                var hcnt = 0;
                for(var h = 0; h < csvparsed.headers.length; h++) {
                    hcnt = (csvparsed.headers[h].includes('Item_Num')) ? hcnt + 1 : hcnt;
                    hcnt = (csvparsed.headers[h].includes('Category')) ? hcnt + 1 : hcnt;
					hcnt = (csvparsed.headers[h].includes('Item')) ? hcnt + 1 : hcnt;                    
                }
                if(hcnt < 3) {
                    var fn = component.get("v.uploadFile");
                    var err = "ERROR: '" + fn + "' missing critical headers: Item_Num, Category, Item";
                    
                    //alert(err);
                    component.set("v.showFileContents", false);
                    component.set("v.showImport", false);
                    component.set("v.uploadFile","");
                    
                    var fileInput = component.find("file").getElement();
                    fileInput.value = "";
                    var divCSV = document.getElementById("divCSV");
                    if(divCSV != null)
                    	divCSV.innerHTML = "";
                    
                    component.set("v.isSubmitCompleted",true);  // enables display
                    component.set("v.toastTheme","slds-notify slds-notify_toast slds-theme_error");
                    component.set("v.toastClass","slds-icon_container slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top");                 
                    component.set('v.toastMessage', err); 
                    
                    return;
                }
                component.set('v.fileGearCount',csvparsed.rows.length);
                var cells = csvparsed.headers;
                var row = table.insertRow(-1);
                for (var j = 0; j < cells.length; j++) {
                    var cell = row.insertCell(-1);
                    cell.innerHTML = cells[j];
                }
                var rows = csvparsed.rows;
                for (var i = 0; i < rows.length; i++) {
                     var cells = rows[i];
                     if (cells.length > 1) {
                         var row = table.insertRow(-1);
                         for (var j = 0; j < cells.length; j++) {
                             var cell = row.insertCell(-1);
                             cell.innerHTML = cells[j];
                         }
                     }
                }

                var ckbShowFileContents = component.find("ckbShowFileContents");
        		if(ckbShowFileContents.get("v.checked") == true) {	
                    component.set("v.showFileContents", true);
                }    
                    var divCSV = document.getElementById("divCSV");
                    divCSV.innerHTML = "";
                    divCSV.appendChild(table);
            	
            }
            reader.onerror = function (evt) {
                console.log("error reading file");
            }
        }
    },    
    
    // export data start from here    
    // ## function call on component load  
    loadRefGear: function(component, event, helper){
 
    var dlText = '<div style="text-align:center">';
    dlText = dlText + '<p>You have requested a download from the GearExchangeWorkSheet data object.</p>';
    dlText = dlText + '<p>This operation will select all records from the data object and load them into a CSV file on your local machine.</p>';
    dlText = dlText + '<p>Do you wish to continue?</p>';
    dlText = dlText + '</div>';
        
        component.set("v.downloadConfirm",dlText);
        
        // DISABLE LOAD ON INIT FOR NOW - 
        //helper.onLoad(component, event);

    },

    // ## function call on Click on the "Download As CSV" Button. 
    downloadCsv : function(component, event, helper) {

        // REPLACED JS CONFIRM WITH MODAL - OK will call this function
        //alert("Download Gear As CSV");
        //if (!confirm("Press OK to confirm that you want to download a file")) {
        //    return;
        //}
        component.set("v.isDownloadModalOpen", false);
        helper.onLoad(component, event);
    },

    downloadCsvOriginal : function(component, event, helper) {

        alert("Download Gear As CSV - Original");

        // get the Records [contact] list from 'ListOfContact' attribute 
        var stockData = component.get("v.RefGearList");
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
        if (csv == null){
            alert("downloadCsv - csv object is null");
            return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }, 
    
    myrefresh : function(component, event, helper) {
        component.set("v.isSubmitCompleted",false);    
        $A.get('e.force:refreshView').fire();
    },
    
    openDownloadModal: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        //alert("in opentDownloadModal");
        component.set("v.isDownloadModalOpen", true);
      },
   
     closeDownloadModal: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isDownloadModalOpen", false);
     }, 

})