public with sharing class RegattaController {
    @AuraEnabled
    public static List<Regatta__c> findAll() {
        
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
}