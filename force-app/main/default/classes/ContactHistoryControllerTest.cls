@isTest public with sharing class ContactHistoryControllerTest {
    
    @IsTest(SeeAllData=true) 
    public static void testGetContactHistoryRecords() {

        String contactid = '0036A00000peZGwQAM';  // Mel
        String fieldname = 'Referee_Status__c';

        System.debug('Begin testGetUnclaimedGearList');
        Exception unexpectedException;
        try{
            List<ContactHistoryController.ContactHistoryRecord> historyrecords = new List<ContactHistoryController.ContactHistoryRecord>();
            historyrecords = ContactHistoryController.getContactHistoryRecords(contactid, fieldname);
            integer sz = historyrecords.size();
            System.debug('testGetContactHistoryRecords returned ' + historyrecords.size() + ' rows');
            for(integer i=0; i < sz; i++) {
                System.debug('testGetContactHistoryRecords [' + (i+1) + '] ContactName: ' + historyrecords[i].ContactName);
                System.debug('testGetContactHistoryRecords [' + (i+1) + '] CreatedByName: ' + historyrecords[i].CreatedByName);
                System.debug('testGetContactHistoryRecords [' + (i+1) + '] CreatedDate: ' + historyrecords[i].CreatedDate);
                System.debug('testGetContactHistoryRecords [' + (i+1) + '] Field: ' + historyrecords[i].Field);
                System.debug('testGetContactHistoryRecords [' + (i+1) + '] NewValue: ' + historyrecords[i].NewValue);
                System.debug('testGetContactHistoryRecords [' + (i+1) + '] OldValue: ' + historyrecords[i].OldValue);
                System.debug('------------------------------------------------------------------------------');
            }
            
            
        } catch (Exception err) {
            System.debug('testGetContactHistoryRecords err: ' + err);
            unexpectedException = err;
        }    
        System.assertEquals(null, unexpectedException, 'testGetContactHistoryRecords unexpected Exception');
        System.debug('testGetContactHistoryRecords completed OK');


    }


}