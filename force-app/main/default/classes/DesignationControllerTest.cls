@IsTest
public with sharing class DesignationControllerTest {

    @IsTest(SeeAllData=true) 
    public static void testFetchContactDesignations() {

        System.debug('testFetchContactDesignations Confirm appropriate list returned');
        Exception unexpectedException;
        try {

            Contact ContactData = [SELECT Id from Contact where Referee_Rank__c = 'Referee' limit 1];

            System.debug('ContactId = ' + ContactData.Id);

            List<Designation__c> designations = DesignationController.fetchContactDesignations(ContactData.Id);
        
            System.assert( designations != null,'testFetchContactDesignations - A list was not returned');

        } catch (Exception err) {
            System.debug('testFetchContactDesignations err: ' + err);
            unexpectedException = err;
        }    
        system.assertEquals(null, unexpectedException, 'testFetchContactDesignations unexpected Exception');
        System.debug('testFetchContactDesignations completed');

    }
}
