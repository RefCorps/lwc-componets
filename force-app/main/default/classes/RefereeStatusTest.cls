@isTest
public class RefereeStatusTest {

    @isTest(SeeAllData=true) 
    public static void testGetLimitedRefereeStatusList() {

        System.debug('Confirm appropriate list returned');
        Exception unexpectedException;
        try {
            
            List<String> picklist = RefereeStatus.getLimitedRefereeStatusList();
            System.assert( picklist != null,'testGetLimitedRefereeStatusList - A list was not returned');

        } catch (Exception err) {
            System.debug('testGetLimitedRefereeStatusList err: ' + err);
            unexpectedException = err;
        }    
        system.assertEquals(null, unexpectedException, 'testGetLimitedRefereeStatusList unexpected Exception');
        System.debug('testGetLimitedRefereeStatusList completed');
    }
    
}