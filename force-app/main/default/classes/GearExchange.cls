public with sharing class GearExchange {

    @AuraEnabled
    public static List<User> fetchBidder(){
       string UserId = UserInfo.getUserId();
       // USE USER ID SINCE SOME USERS MAY NOT HAVE A CONTACT - IT WON'T FAIL - THE CONTANTID WILL BE BLANK
       List<User> bidder = [select name, contactid from user where id =: UserId ];
       //System.debug(LoggingLevel.DEBUG,evaluator); 
       return bidder;
    }


    @AuraEnabled
    public List<Gear_Exchange__c> getUnclaimedGearList() {
        return  GetGearList(1);
    }

    @AuraEnabled
    public List<Gear_Exchange__c> getFullGearList() {
        return  GetGearList(0);
    }

    @AuraEnabled
    public static List<Gear_Exchange__c> GetGearList(Integer listType) {
        
        String searchquery = 'SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, ';
        searchquery = searchquery + 'LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate,  ';
        searchquery = searchquery + 'UserRecordAccessId, Category__c, Item_Clothing__c, Item_Stopwatchs__c, '; 
        searchquery = searchquery + 'Item_Megaphones__c, Item_NonTech_tools__c, Item_Tech_Based_Tools__c, '; 
        searchquery = searchquery + 'Item_Other__c, Size__c, Color__c, Offered_By__c, Value__c, '; 
        searchquery = searchquery + 'Coordinated_By__c, Received_By__c, Date_Recd__c, Location_Recd__c, '; 
        searchquery = searchquery + 'Located_At__c, Distribution_Date__c, Distributed_By__c, '; 
        searchquery = searchquery + 'Distributed_To__c, Thanks_Sent__c, Description__c, US_Rowing_Logo__c, Gender__c '; 
        searchquery = searchquery + 'from Gear_Exchange__c  ';
        
        if(listType == 1)
            searchquery = searchquery + 'WHERE Distributed_To__c = null';
        List<Gear_Exchange__c> eg = Database.query(searchquery);
        return eg;
    }
    
    
}