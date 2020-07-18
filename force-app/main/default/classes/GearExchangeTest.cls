@isTest public with sharing class GearExchangeTest {
    
    @IsTest(SeeAllData=true) 
    public static void testGetUnclaimedGearList() {
        System.debug('Begin testGetUnclaimedGearList');
        Exception unexpectedException;
        try{
            GearExchange ge = new GearExchange();

             List<Gear_Exchange__c> geUnclaimed = ge.GetUnclaimedGearList();
             System.debug('GetUnclaimedGearList returned ' + geUnclaimed.size() + ' rows');

             List<Gear_Exchange__c> geFull = ge.GetFullGearList();
             System.debug('GetUnclaimedGearList returned ' + geFull.size() + ' rows');    

            List<Gear_Exchange__c> gel = ge.GetGearList(0);
             System.debug('GetUnclaimedGearList returned ' + gel.size() + ' rows');    

        } catch (Exception err) {
            System.debug('testGetUnclaimedGearList err: ' + err);
            unexpectedException = err;
        }    
        System.assertEquals(null, unexpectedException, 'testGetUnclaimedGearList unexpected Exception');
        System.debug('GetUnclaimedGearList completed OK');
    }

}