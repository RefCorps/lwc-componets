@isTest public with sharing class GearImportExport_Test {

    @isTest(SeeAllData=true)
    public static void testInsertGearExchangeData() {

        String insertGearExchangeDataReturn = '';

        // NORMALLY EXPECTED
        String WorkSheetRow99991 = '[{"Item_Num": "99991", "Date_Recd": "7/25/2017", "Category": "Non-tech tools", "Item": "Flag set", "Price": "0", "Size": "-", "Gender": "-", "Color": "Red and White only", "Notes": "Red and White only", "Donated_by": "Terry Friel Portell", "Received_by": "Terry", "Located_at": "Terry - St. Louis", "Value": "0.00", "Distributed_To": "Chris Galvanek", "Distribution_Date": "4/12/2018", "Distributed_By": "Terry FP","Distribution_Location": "St Louis", "Thanks_Sent_Date": "4/12/2018", "DisplayOnList": "1"}]';
        insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow99991);
        System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow99991 return = ' + insertGearExchangeDataReturn );
        
        // ITEM IS JSON NUM DATES OMITTED 
        String WorkSheetRow99992 = '[{"Item_Num": 99992, "Date_Recd":"", "Category": "Non-tech tools", "Item": "Flag set", "Price": 200, "Size": "-", "Gender": "-", "Color": "Red and White only", "Notes": "", "Donated_by": "Terry Friel Portell", "Received_by": "Terry", "Located_at": "Terry - St. Louis", "Distributed_To": "Chris Galvanek", "Distribution_Date": "", "Distributed_By": "Terry FP","Distribution_Location": "St Louis", "Thanks_Sent_Date":"", "DisplayOnList": "1"}]';
        insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow99992);
		System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow99992 return = ' + insertGearExchangeDataReturn );

        // NORMALLY EXPECTED
        String WorkSheetRow99993 = '[{"Date_Recd": "7/25/2017", "Category": "Non-tech tools", "Item": "Flag set", "Price": "0", "Size": "-", "Gender": "-", "Color": "Red and White only", "Notes": "Red and White only", "Donated_by": "Terry Friel Portell", "Received_by": "Terry", "Located_at": "Terry - St. Louis", "Value": "0.00", "Distributed_To": "Chris Galvanek", "Distribution_Date": "4/12/2018", "Distributed_By": "Terry FP","Distribution_Location": "St Louis", "Thanks_Sent_Date": "4/12/2018", "DisplayOnList": "1"}]';
        insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow99993);
        System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow99993 return = ' + insertGearExchangeDataReturn );

        // DUPLICATE VALUE ??
        String WorkSheetRow1 = '[{"Item_Num": "1", "Date_Recd": "7/25/2017", "Category": "Non-tech tools", "Item": "Flag set", "Price": "0", "Size": "-", "Gender": "-", "Color": "Red and White only", "Notes": "", "Donated_by": "Terry Friel Portell", "Received_by": "Terry", "Located_at": "Terry - St. Louis", "Value": "", "Distributed_To": "Chris Galvanek", "Distribution_Date": "4/12/2018", "Distributed_By": "Terry FP","Distribution_Location": "St Louis", "Thanks_Sent_Date": "", "DisplayOnList": "1"}]';
        insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow1);
		System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow1 return = ' + insertGearExchangeDataReturn );

        String WorkSheetRow0 = '[{}]';
        insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow0);
		System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow0 return = ' + insertGearExchangeDataReturn );

        // NO DATA ??
        String WorkSheetRow00 = '';
        insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow00);
		System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow00 return = ' + insertGearExchangeDataReturn );


    }

	@isTest(SeeAllData=true)
    public static void testfetchGearExchangeData() {
        List <GearExchangeWorkSheet__c> returnConList = GearImportExport.fetchGearExchangeData();
        if(returnConList.size() <= 0) {
            System.debug('GearImportExport_Test testfetchGearExchangeData returned an empty list.' );
        } else {
            System.debug('GearImportExport_Test testfetchGearExchangeData received ' + ' rows');  
        }

    }
    
}