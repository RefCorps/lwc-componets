public with sharing class RegattaController {
    @AuraEnabled
    public static List<Regatta__c> findAll() {
        
        /* 
            RegattaController - findAll() appears in Aura RegattaList 
        */

       //Set<Regatta__c> myset = new Set<Regatta__c>();
       //List<Regatta__c> result =  [SELECT id, name, Regatta_Location__Latitude__s, Regatta_Location__Longitude__s
       //     FROM Regatta__c
       //     WHERE Regatta_Location__Latitude__s != NULL AND Regatta_Location__Longitude__s != NULL
       //     LIMIT 50];
      // myset.addAll(result);
      // List<Regatta__c> results = new List<Regatta__c>();
       //results.addAll(myset);
        
    return [SELECT id, name, Regatta_Location__Latitude__s, Regatta_Location__Longitude__s
            FROM Regatta__c
            WHERE Regatta_Location__Latitude__s != NULL AND Regatta_Location__Longitude__s != NULL
            LIMIT 50];
    }

     @InvocableMethod(label='Completed Regattas')
    //public static List<Regatta__c> GetCompletedUSRowingRegattas(int dayspast) {
      public static List<Regatta__c> GetUSRowingRegattasCompletedToday() {
        string searchquery = 'Select Id, Name, '
        + 'Chief_Referee_User__c, Chief_Referee__c, Chief_Referee__r.Name,  Chief_Referee__r.Email,' 
        + 'Deputy_Chief_User__c, Deputy_Chief__c, Deputy_Chief__r.Name, Deputy_Chief__r.Email,'
        + 'LOC_Primary_Contact__c, LOC__c, '
        + 'Regatta_Course__c, Regatta_Description__c, '
        + 'Regatta_Type__c, '
        + 'Start_Date_Time__c, Start_Date_Year__c, '
        + 'End_Date_Time__c, '
        + 'Total_Regatta_Days__c, '
        + 'US_Rowing_Registered__c '
        + 'FROM Regatta__c '
        + 'where US_Rowing_Registered__c = true '
        //+ 'and End_Date_Time__c >= LAST_N_DAYS:' + dayspast + ' AND End_Date_Time__c <= TODAY';
        + 'and End_Date_Time__c = TODAY';
        List <Regatta__c> regattalist  = Database.query(searchquery);
        return regattalist;

    }


}