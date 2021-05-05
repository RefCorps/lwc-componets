@isTest public with sharing class GearImportExport_Test {


    @isTest(SeeAllData=true)
    public static void confirmUserProfileIsLoaded() {

        System.debug('Confirm Profile exists');
        Exception unexpectedException;
        try {
            Profile RefereeGearCoordinator = [Select Id from Profile where name = 'Referee Gear Coordinator' Limit 1];
            System.debug('confirmUserProfileIsLoaded found ' + RefereeGearCoordinator.Id);
            System.assert( RefereeGearCoordinator != null,'confirmUserProfileIsLoaded - Profile has not been loaded.  The component may not be accessible');

        } catch (Exception err) {
            System.debug('testfetchEvaluator err: ' + err);
            unexpectedException = err;
        }    
        system.assertEquals(null, unexpectedException, 'testfetchEvaluator unexpected Exception');

    }

    @isTest(SeeAllData=true)
    public static void testInsertGearExchangeData() {

            System.debug('Begin testInsertGearExchangeData');
            Exception unexpectedException;
            try {
                String insertGearExchangeDataReturn = '';

                // NORMALLY EXPECTED - NEW Item_Num - insert - Return 'SUCCESS'
                String WorkSheetRow99991 = '[{"Item_Num": "99991", "Date_Recd": "7/25/2017", "Category": "Non-tech tools", "Item": "Flag set", "Price": "0", "Size": "-", "Gender": "-", "Color": "Red and White only", "Notes": "Red and White only", "Donated_by": "Terry Friel Portell", "Received_by": "Terry", "Located_at": "Terry - St. Louis", "Value": "0.00", "Distributed_To": "Chris Galvanek", "Distribution_Date": "4/12/2018", "Distributed_By": "Terry FP","Distribution_Location": "St Louis", "Thanks_Sent_Date": "4/12/2018", "DisplayOnList": "1"}]';
                insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow99991);
                System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow99991 return = ' + insertGearExchangeDataReturn);
                System.assert(insertGearExchangeDataReturn.contains('SUCCESS'), 'GearImportExport_Test testInsertGearExchangeData WorkSheetRow99991');

                // ITEM IS JSON NUM DATES OMITTED - Return 'SUCCESS'
                String WorkSheetRow99992 = '[{"Item_Num": 99992, "Date_Recd":"", "Category": "Non-tech tools", "Item": "Flag set", "Price": 200, "Size": "-", "Gender": "-", "Color": "Red and White only", "Notes": "", "Donated_by": "Terry Friel Portell", "Received_by": "Terry", "Located_at": "Terry - St. Louis", "Distributed_To": "Chris Galvanek", "Distribution_Date": "", "Distributed_By": "Terry FP","Distribution_Location": "St Louis", "Thanks_Sent_Date":"", "DisplayOnList": "1"}]';
                insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow99992);
                System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow99992 return = ' + insertGearExchangeDataReturn);

                // NORMALLY EXPECTED - MISSING Item_Num - Return 'ERROR insertGearExchangeData : Item Num missing from data.'
                String WorkSheetRow99993 = '[{"Date_Recd": "7/25/2017", "Category": "Non-tech tools", "Item": "Flag set", "Price": "0", "Size": "-", "Gender": "-", "Color": "Red and White only", "Notes": "Red and White only", "Donated_by": "Terry Friel Portell", "Received_by": "Terry", "Located_at": "Terry - St. Louis", "Value": "0.00", "Distributed_To": "Chris Galvanek", "Distribution_Date": "4/12/2018", "Distributed_By": "Terry FP","Distribution_Location": "St Louis", "Thanks_Sent_Date": "4/12/2018", "DisplayOnList": "1"}]';
                insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow99993);
                System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow99993 return = ' + insertGearExchangeDataReturn);

                // DUPLICATE VALUE - Item_Num - upsert - Return 'SUCCESS'
                String WorkSheetRow1 = '[{"Item_Num": "1", "Date_Recd": "7/25/2017", "Category": "Non-tech tools", "Item": "Flag set", "Price": "0", "Size": "-", "Gender": "-", "Color": "Red and White only", "Notes": "", "Donated_by": "Terry Friel Portell", "Received_by": "Terry", "Located_at": "Terry - St. Louis", "Value": "", "Distributed_To": "Chris Galvanek", "Distribution_Date": "4/12/2018", "Distributed_By": "Terry FP","Distribution_Location": "St Louis", "Thanks_Sent_Date": "", "DisplayOnList": "1"}]';
                insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow1);
                System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow1 return = ' + insertGearExchangeDataReturn);

                // Empty JSON Object - Return 'ERROR insertGearExchangeData : Item Num missing from data.'
                String WorkSheetRow0 = '[{}]';
                insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow0);
                System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow0 return = ' + insertGearExchangeDataReturn);

                // Empty String - Return 'ERROR insertGearExchangeData : No input data found.'
                String WorkSheetRow00 = '';
                insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow00);
                System.debug('GearImportExport_Test testInsertGearExchangeData WorkSheetRow00 return = ' + insertGearExchangeDataReturn);

                // Missing elements - ERROR insertGearExchangeData :Attempt to de-reference a null object
                String WorkSheetRow99994 = '[{"Item_Num": 99994, "Category": "Non-tech tools", "Item": "Flag set"}]';
                insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow99994);
                System.debug('GearImportExport_Test testInsertGearExchangeData 99994 return = ' + insertGearExchangeDataReturn);

                String WorkSheetRow99999 = '[{"Item_Num": "123456789012345678901234567890", "Date_Recd": "7/25/2017", "Category": "Non-tech tools", "Item": "Flag set", "Price": "0", "Size": "-", "Gender": "-", "Color": "Red and White only", "Notes": "", "Donated_by": "Terry Friel Portell", "Received_by": "Terry", "Located_at": "Terry - St. Louis", "Value": "", "Distributed_To": "Chris Galvanek", "Distribution_Date": "4/12/2018", "Distributed_By": "Terry FP","Distribution_Location": "St Louis", "Thanks_Sent_Date": "", "DisplayOnList": "1"}]';
                insertGearExchangeDataReturn = GearImportExport.insertGearExchangeData(WorkSheetRow99999);
                System.debug('GearImportExport_Test testInsertGearExchangeData Large Item num return = ' + insertGearExchangeDataReturn);

            } catch (Exception err) {
                System.debug('testInsertGearExchangeData err: ' + err);
                unexpectedException = err;
            }
            System.assertEquals(null, unexpectedException, 'testInsertGearExchangeData unexpected Exception');
            System.debug('testInsertGearExchangeData completed OK');

    }

    @isTest
    public static void testFieldWrapper() {

        System.debug('=================================================================================================');
        System.debug('Begin testFieldWrapper');   

        GearImportExport.fieldWrapper wrapper = new GearImportExport.fieldWrapper();
        System.assertEquals(null, wrapper.Item_Num);
        System.assertEquals(null, wrapper.Date_Recd);
        System.assertEquals(null, wrapper.Category);
        System.assertEquals(null, wrapper.Item);
        System.assertEquals(null, wrapper.Price);
        System.assertEquals(null, wrapper.Size);
        System.assertEquals(null, wrapper.Gender);
        System.assertEquals(null, wrapper.Color);
        System.assertEquals(null, wrapper.Notes);
        System.assertEquals(null, wrapper.Donated_by);
        System.assertEquals(null, wrapper.Received_by);
        System.assertEquals(null, wrapper.Located_at);
        System.assertEquals(null, wrapper.Value);
        System.assertEquals(null, wrapper.Distributed_To);
        System.assertEquals(null, wrapper.Distribution_Date);
        System.assertEquals(null, wrapper.Distributed_By);
        System.assertEquals(null, wrapper.Distribution_Location);
        System.assertEquals(null, wrapper.Thanks_Sent_Date);
        System.assertEquals(null, wrapper.DisplayOnList);
        
        wrapper.Item_Num = 'test';
        wrapper.Date_Recd = 'test';
        wrapper.Category = 'test';
        wrapper.Item = 'test';
        wrapper.Price = 'test';
        wrapper.Size = 'test';
        wrapper.Gender = 'test';
        wrapper.Color = 'test';
        wrapper.Notes = 'test';
        wrapper.Donated_by = 'test';
        wrapper.Received_by = 'test';
        wrapper.Located_at = 'test';
        wrapper.Value = 'test';
        wrapper.Distributed_To = 'test';
        wrapper.Distribution_Date = 'test';
        wrapper.Distributed_By = 'test';
        wrapper.Distribution_Location = 'test';
        wrapper.Thanks_Sent_Date = 'test';
        wrapper.DisplayOnList = 'test';
        
        System.assertEquals('test', wrapper.Item_Num);
        System.assertEquals('test', wrapper.Date_Recd);
        System.assertEquals('test', wrapper.Category);
        System.assertEquals('test', wrapper.Item);
        System.assertEquals('test', wrapper.Price);
        System.assertEquals('test', wrapper.Size);
        System.assertEquals('test', wrapper.Gender);
        System.assertEquals('test', wrapper.Color);
        System.assertEquals('test', wrapper.Notes);
        System.assertEquals('test', wrapper.Donated_by);
        System.assertEquals('test', wrapper.Received_by);
        System.assertEquals('test', wrapper.Located_at);
        System.assertEquals('test', wrapper.Value);
        System.assertEquals('test', wrapper.Distributed_To);
        System.assertEquals('test', wrapper.Distribution_Date);
        System.assertEquals('test', wrapper.Distributed_By);
        System.assertEquals('test', wrapper.Distribution_Location);
        System.assertEquals('test', wrapper.Thanks_Sent_Date);
        System.assertEquals('test', wrapper.DisplayOnList);
        System.debug('testFieldWrapper completed');        

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
    
    @isTest(SeeAllData=true)
    public static void testGearExchangeEmailTo() {
        
        User usr = [Select email, name, id FROM user where name = 'Tony Passarello'];
        System.runAs(usr) {
        
        String emailTo = GearImportExport.GearExchangeEmailTo();
        System.debug('GearImportExport_Test testGearExchangeEmailTo returned: ' + emailTo);
        System.assert(emailTo.contains('@'), 'GearImportExport_Test testGearExchangeEmailTo');
            
        }
        
        String emailTo = GearImportExport.GearExchangeEmailTo();
        System.debug('GearImportExport_Test testGearExchangeEmailTo returned: ' + emailTo);
        System.assert(emailTo.contains('@'), 'GearImportExport_Test testGearExchangeEmailTo');
        
        
    }
    
}